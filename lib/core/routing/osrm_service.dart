import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../geocoding/geocoding_service.dart';

class OsrmRouteResult {
  final List<LatLng> geometry;
  final double distanceKm;

  const OsrmRouteResult({required this.geometry, required this.distanceKm});
}

class OsrmService {
  // NOTE: Public OSRM demo server — no SLA or uptime guarantees.
  // For production deploy your own OSRM instance:
  // https://github.com/Project-OSRM/osrm-backend
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  static Future<OsrmRouteResult?> getRoute(LatLng from, LatLng to) async {
    final url = '$_baseUrl/${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return _haversineFallback(from, to);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return _haversineFallback(from, to);

      final routes = data['routes'] as List;
      if (routes.isEmpty) return _haversineFallback(from, to);

      final route = routes[0] as Map<String, dynamic>;
      final distanceM = (route['distance'] as num).toDouble();
      final coordsList = route['geometry']['coordinates'] as List;

      final geometry = coordsList.map<LatLng>((c) {
        final pair = c as List;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      return OsrmRouteResult(
        geometry: geometry,
        distanceKm: distanceM / 1000.0,
      );
    } catch (_) {
      return _haversineFallback(from, to);
    }
  }

  // Fallback when OSRM server is unreachable — returns straight-line distance.
  static OsrmRouteResult _haversineFallback(LatLng from, LatLng to) {
    return OsrmRouteResult(
      geometry: [from, to],
      distanceKm: GeocodingService.calculateDistanceKm(from, to),
    );
  }
}
