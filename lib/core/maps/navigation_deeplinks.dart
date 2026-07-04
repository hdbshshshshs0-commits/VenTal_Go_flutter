import 'package:url_launcher/url_launcher.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class NavigationDeeplinks {
  static Future<void> open2Gis(LatLng destination) async {
    final uri = Uri.parse(
      'dgis://2gis.ru/routeSearch/rsType/car/to/${destination.longitude},${destination.latitude}',
    );
    final fallback = Uri.parse(
      'https://2gis.ru/routeSearch/rsType/car/to/${destination.longitude},${destination.latitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openYandexNavigator(LatLng destination) async {
    final uri = Uri.parse(
      'yandexnavi://build_route_on_map?lat_to=${destination.latitude}&lon_to=${destination.longitude}',
    );
    final fallback = Uri.parse(
      'https://yandex.ru/maps/?rtext=~${destination.latitude},${destination.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}