import 'package:maplibre_gl/maplibre_gl.dart';

/// Fallback-точка карты — используется, только пока не подгрузился
/// выбранный пользователем город (см. CityController). Ерейментау — главный/дефолтный город.
class DefaultLocation {
  static const LatLng center = LatLng(51.6167, 73.1000);
  static const double defaultZoom = 13;
}
