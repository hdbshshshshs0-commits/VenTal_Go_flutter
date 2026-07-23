import 'package:flutter/foundation.dart';
import '../../../location/data/models/location_country_data.dart';
import '../../../location/data/services/location_service.dart';

class LocationController extends ChangeNotifier {
  LocationData? _locationData;
  bool _isLoading = true;
  bool _citySetupDone = false;

  LocationData? get locationData => _locationData;
  bool get isLoading => _isLoading;
  bool get isSet => _locationData != null;
  bool get citySetupDone => _citySetupDone;

  /// "City, Country" label for header
  String get headerLabel {
    if (_locationData == null) return '';
    return '${_locationData!.cityName}, ${_locationData!.countryName}';
  }

  /// Short saved address for display
  String get savedAddress => _locationData?.savedAddress ?? '';

  LocationController() {
    _load();
  }

  Future<void> _load() async {
    _locationData = await LocationService.load();
    _citySetupDone = await LocationService.isCitySetupDone();
    _isLoading = false;
    notifyListeners();
  }

  /// Called after country+city are chosen (first-time setup)
  Future<void> setCity(LocationCountry country, LocationCity city) async {
    final existing = _locationData;
    _locationData = LocationData(
      countryCode: country.code,
      countryName: country.name,
      cityName: city.name,
      cityLat: city.lat,
      cityLng: city.lng,
      savedAddress: existing?.savedAddress,
      savedLat: existing?.savedLat,
      savedLng: existing?.savedLng,
    );
    _citySetupDone = true;
    await LocationService.save(_locationData!);
    await LocationService.markCitySetupDone();
    notifyListeners();
  }

  /// Called after address is confirmed on map or text input
  Future<void> setAddress(String address, double lat, double lng) async {
    if (_locationData == null) return;
    _locationData = _locationData!.copyWith(
      savedAddress: address,
      savedLat: lat,
      savedLng: lng,
    );
    await LocationService.save(_locationData!);
    notifyListeners();
  }

  /// For Settings: reset city (re-run picker)
  Future<void> resetCity() async {
    await LocationService.clear();
    _locationData = null;
    _citySetupDone = false;
    notifyListeners();
  }
}
