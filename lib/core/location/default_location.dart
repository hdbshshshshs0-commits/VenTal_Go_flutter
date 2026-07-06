import 'package:maplibre_gl/maplibre_gl.dart';

/// Нейтральная стартовая точка карты, если геолокация ещё не получена
/// или пользователь её не разрешил. Астана как разумный дефолт для KZ.
class DefaultLocation {
  static const LatLng center = LatLng(51.1605, 71.4704);
  static const double defaultZoom = 13;
}
