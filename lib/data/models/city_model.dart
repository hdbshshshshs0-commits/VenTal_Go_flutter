import 'package:maplibre_gl/maplibre_gl.dart';

class KzCity {
  final String id;
  final String displayName;
  final LatLng center;

  const KzCity({required this.id, required this.displayName, required this.center});
}

class KzCities {
  KzCities._();

  /// Ерейментау — главный/дефолтный город.
  static const KzCity ereymentau = KzCity(
    id: 'ereymentau',
    displayName: 'Ерейментау',
    center: LatLng(51.6167, 73.1000),
  );

  static const List<KzCity> all = [
    ereymentau,
    KzCity(id: 'astana', displayName: 'Астана', center: LatLng(51.1605, 71.4704)),
    KzCity(id: 'almaty', displayName: 'Алматы', center: LatLng(43.2220, 76.8512)),
    KzCity(id: 'shymkent', displayName: 'Шымкент', center: LatLng(42.3417, 69.5901)),
    KzCity(id: 'karaganda', displayName: 'Караганда', center: LatLng(49.8047, 73.1094)),
    KzCity(id: 'aktobe', displayName: 'Актобе', center: LatLng(50.2839, 57.1670)),
    KzCity(id: 'taraz', displayName: 'Тараз', center: LatLng(42.9000, 71.3667)),
    KzCity(id: 'pavlodar', displayName: 'Павлодар', center: LatLng(52.2873, 76.9674)),
    KzCity(id: 'ustkamenogorsk', displayName: 'Усть-Каменогорск', center: LatLng(49.9714, 82.6072)),
    KzCity(id: 'semey', displayName: 'Семей', center: LatLng(50.4111, 80.2275)),
    KzCity(id: 'atyrau', displayName: 'Атырау', center: LatLng(47.1164, 51.8830)),
    KzCity(id: 'kostanay', displayName: 'Костанай', center: LatLng(53.2144, 63.6246)),
    KzCity(id: 'kyzylorda', displayName: 'Кызылорда', center: LatLng(44.8479, 65.4999)),
    KzCity(id: 'uralsk', displayName: 'Уральск', center: LatLng(51.2333, 51.3667)),
    KzCity(id: 'petropavlovsk', displayName: 'Петропавловск', center: LatLng(54.8667, 69.1500)),
    KzCity(id: 'aktau', displayName: 'Актау', center: LatLng(43.6500, 51.1667)),
    KzCity(id: 'temirtau', displayName: 'Темиртау', center: LatLng(50.0546, 72.9647)),
    KzCity(id: 'turkistan', displayName: 'Туркестан', center: LatLng(43.2975, 68.2517)),
    KzCity(id: 'kokshetau', displayName: 'Кокшетау', center: LatLng(53.2833, 69.3833)),
  ];

  static KzCity byId(String id) => all.firstWhere((c) => c.id == id, orElse: () => ereymentau);
}