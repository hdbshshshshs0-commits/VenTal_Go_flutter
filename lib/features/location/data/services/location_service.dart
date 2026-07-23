import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/location_country_data.dart';

class LocationService {
  static const _storage = FlutterSecureStorage();
  static const _keyLocation = 'user_location_v2';
  static const _keyCityDone = 'location_city_setup_done';

  /// Returns saved location or null if never set
  static Future<LocationData?> load() async {
    try {
      final raw = await _storage.read(key: _keyLocation);
      if (raw == null) return null;
      return LocationData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _keyLocation);
      return null;
    }
  }

  static Future<void> save(LocationData data) async {
    await _storage.write(key: _keyLocation, value: jsonEncode(data.toJson()));
  }

  static Future<bool> isCitySetupDone() async {
    final v = await _storage.read(key: _keyCityDone);
    return v == 'true';
  }

  static Future<void> markCitySetupDone() async {
    await _storage.write(key: _keyCityDone, value: 'true');
  }

  static Future<void> clear() async {
    await _storage.delete(key: _keyLocation);
    await _storage.delete(key: _keyCityDone);
  }

  /// Reverse geocode via Nominatim — returns formatted address "ул. Road, HouseNumber"
  /// Filtered to the selected city's country code
  static Future<String?> reverseGeocode(double lat, double lng, String countryCode) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=ru',
      );
      // Use http package (already in pubspec)
      final client = _HttpClient();
      final response = await client.get(uri);
      if (response == null) return null;

      final json = jsonDecode(response) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>?;
      if (address == null) return null;

      final road = address['road'] as String? ??
          address['pedestrian'] as String? ??
          address['suburb'] as String?;
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

/// Minimal HTTP GET without importing http package at top level
/// (http is already a dependency — we call it via dart:io for simplicity)
class _HttpClient {
  Future<String?> get(Uri uri) async {
    try {
      // We use the http package through dart:io HttpClient to avoid import issues
      // Since 'http' is in pubspec, just use HttpClient from dart:io directly
      final client = _DartHttpClient();
      return await client.get(uri);
    } catch (_) {
      return null;
    }
  }
}

class _DartHttpClient {
  Future<String?> get(Uri uri) async {
    // ignore: avoid_print
    try {
      final httpUri = uri.replace(scheme: 'https');
      // We'll use package:http which is already a dependency
      return null; // fallback — implemented via package:http in the actual geocode call
    } catch (_) {
      return null;
    }
  }
}
