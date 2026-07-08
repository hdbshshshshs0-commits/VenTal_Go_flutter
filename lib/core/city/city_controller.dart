import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:vental_go/data/models/city_model.dart';

class CityController extends ChangeNotifier {
  static const _storageKey = 'selected_city_id';
  final _storage = const FlutterSecureStorage();

  KzCity _selectedCity = KzCities.ereymentau;
  KzCity get selectedCity => _selectedCity;

  Future<void> load() async {
    final savedId = await _storage.read(key: _storageKey);
    if (savedId != null) {
      _selectedCity = KzCities.byId(savedId);
      notifyListeners();
    }
  }

  Future<void> selectCity(KzCity city) async {
    _selectedCity = city;
    notifyListeners();
    await _storage.write(key: _storageKey, value: city.id);
  }
}