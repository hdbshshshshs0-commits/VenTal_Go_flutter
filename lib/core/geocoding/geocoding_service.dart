import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class AddressSuggestion {
  final String displayName;
  final LatLng position;

  const AddressSuggestion({required this.displayName, required this.position});
}

class GeocodingService {
  static const String _photonUrl = 'https://photon.komoot.io/api';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<AddressSuggestion>> search(String query, {LatLng? biasPosition, String? cityName}) async {
    if (query.trim().length < 3) return [];

    final effectiveQuery = (cityName != null && !query.toLowerCase().contains(cityName.toLowerCase()))
        ? '$query, $cityName'
        : query;

    try {
      final uri = Uri.parse(_photonUrl).replace(queryParameters: {
        'q': effectiveQuery,
        'limit': '8',
        'lang': 'ru',
        if (biasPosition != null) 'lat': biasPosition.latitude.toString(),
        if (biasPosition != null) 'lon': biasPosition.longitude.toString(),
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          final results = features.map((f) => _fromPhotonFeature(f)).toList();
          return _filterByCity(results, cityName);
        }
      }
    } catch (_) {
      // переходим к fallback ниже
    }

    final fallback = await _searchNominatim(effectiveQuery);
    return _filterByCity(fallback, cityName);
  }

  static List<AddressSuggestion> _filterByCity(List<AddressSuggestion> results, String? cityName) {
    if (cityName == null) return results;
    final filtered = results.where((r) => r.displayName.toLowerCase().contains(cityName.toLowerCase())).toList();
    // если фильтр вычистил всё (сервис не указал город в ответе) — лучше нефильтрованные варианты, чем пусто
    return filtered.isNotEmpty ? filtered : results;
  }

  static AddressSuggestion _fromPhotonFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final coords = feature['geometry']['coordinates'] as List;
    final parts = [props['name'], props['street'], props['city'], props['country']]
        .where((p) => p != null && p.toString().isNotEmpty)
        .toSet()
        .join(', ');
    return AddressSuggestion(
      displayName: parts.isEmpty ? 'Без названия' : parts,
      position: LatLng(coords[1] as double, coords[0] as double),
    );
  }

  static Future<List<AddressSuggestion>> _searchNominatim(String query) async {
    try {
      final uri = Uri.parse(_nominatimUrl).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '8',
        'accept-language': 'ru',
      });
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'VenTalGo/1.0 (contact: support@vental.go)'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) {
          return AddressSuggestion(
            displayName: item['display_name'] as String,
            position: LatLng(double.parse(item['lat']), double.parse(item['lon'])),
          );
        }).toList();
      }
    } catch (_) {
      // оба недоступны
    }
    return [];
  }

  static double calculateDistanceKm(LatLng from, LatLng to) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(to.latitude - from.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(from.latitude)) * math.cos(_degToRad(to.latitude)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180);
}