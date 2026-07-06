import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class OsrmRouteResult {
  final List<LatLng> geometry;
  final double distanceKm;

  const OsrmRouteResult({required this.geometry, required this.distanceKm});
}

/// Публичный демо-сервер OSRM (router.project-osrm.org) — без гарантий
/// аптайма/лимитов. Для продакшена поднять свой инстанс OSRM.
class OsrmService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  static Future<OsrmRouteResult?> getRoute(LatLng from, LatLng to) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) return null;

      final route = data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;
      final geometry = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
      final distanceMeters = route['distance'] as num;

      return OsrmRouteResult(geometry: geometry, distanceKm: distanceMeters / 1000);
    } catch (_) {
      return null;
    }
  }
}
