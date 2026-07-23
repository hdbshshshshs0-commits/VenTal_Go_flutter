import 'dart:convert';
import 'package:http/http.dart' as http;

/// Nominatim reverse geocoding — returns formatted address "ул. Road, House"
class GeocodingService {
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=ru&zoom=18',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'VenTalGo/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>?;
      if (address == null) return null;

      final road = address['road'] as String? ??
          address['pedestrian'] as String? ??
          address['suburb'] as String? ??
          address['neighbourhood'] as String?;
      final house = address['house_number'] as String?;

      if (road == null) return null;
      if (house != null && house.isNotEmpty) {
        return 'ул. $road, $house';
      }
      return 'ул. $road';
    } catch (_) {
      return null;
    }
  }
}
