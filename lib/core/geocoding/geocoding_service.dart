import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class GeocodingResult {
  final String displayName;
  final LatLng coordinates;

  const GeocodingResult({required this.displayName, required this.coordinates});
}

class GeocodingService {
  static const String _photonUrl = 'https://photon.komoot.io/api';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  static const String _userAgent = 'VentalGo/1.0 (contact@vental.kz)';

  static Future<List<GeocodingResult>> search(
    String query, {
    LatLng? biasPosition,
    int limit = 5,
  }) async {
    if (query.trim().length < 2) return [];

    try {
      final photonResults = await _searchPhoton(query, biasPosition: biasPosition, limit: limit);
      if (photonResults.isNotEmpty) return photonResults;
    } catch (_) {}

    try {
      return await _searchNominatim(query, limit: limit);
    } catch (_) {}

    return [];
  }

  static Future<List<GeocodingResult>> _searchPhoton(
    String query, {
    LatLng? biasPosition,
    int limit = 5,
  }) async {
    final params = <String, String>{
      'q': query,
      'limit': limit.toString(),
      'lang': 'ru',
    };
    if (biasPosition != null) {
      params['lat'] = biasPosition.latitude.toString();
      params['lon'] = biasPosition.longitude.toString();
    }

    final uri = Uri.parse(_photonUrl).replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = (data['features'] as List?) ?? [];

    return features.map<GeocodingResult>((f) {
      final props = f['properties'] as Map<String, dynamic>;
      final coords = f['geometry']['coordinates'] as List;
      return GeocodingResult(
        displayName: _formatPhotonName(props),
        coordinates: LatLng(
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        ),
      );
    }).toList();
  }

  static String _formatPhotonName(Map<String, dynamic> props) {
    final parts = <String>[];
    if (props['name'] != null) parts.add(props['name'] as String);
    if (props['street'] != null) {
      final street = props['street'] as String;
      if (props['housenumber'] != null) {
        parts.add('$street, ${props['housenumber']}');
      } else {
        parts.add(street);
      }
    }
    if (props['city'] != null) parts.add(props['city'] as String);
    if (parts.isEmpty && props['display_name'] != null) {
      return props['display_name'] as String;
    }
    return parts.join(', ');
  }

  static Future<List<GeocodingResult>> _searchNominatim(
    String query, {
    int limit = 5,
  }) async {
    final params = {
      'q': query,
      'format': 'json',
      'limit': limit.toString(),
      'addressdetails': '1',
    };

    final uri = Uri.parse(_nominatimUrl).replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as List;
    return data.map<GeocodingResult>((item) {
      return GeocodingResult(
        displayName: item['display_name'] as String,
        coordinates: LatLng(
          double.parse(item['lat'] as String),
          double.parse(item['lon'] as String),
        ),
      );
    }).toList();
  }

  // Haversine formula for straight-line distance.
  // NOTE: This is an approximation of real road distance.
  // For accurate road distance use OsrmService.getRoute() — it returns
  // precise distance along actual roads. Haversine is the fallback only.
  static double calculateDistanceKm(LatLng from, LatLng to) {
    const r = 6371.0;
    final dLat = _rad(to.latitude - from.latitude);
    final dLon = _rad(to.longitude - from.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(from.latitude)) *
            math.cos(_rad(to.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
