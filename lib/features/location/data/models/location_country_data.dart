class LocationCity {
  final String name;
  final double lat;
  final double lng;

  const LocationCity({required this.name, required this.lat, required this.lng});
}

class LocationCountry {
  final String code;
  final String name;
  final String flag;
  final List<LocationCity> cities;

  const LocationCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.cities,
  });
}

class LocationData {
  final String countryCode;
  final String countryName;
  final String cityName;
  final double cityLat;
  final double cityLng;
  final String? savedAddress;
  final double? savedLat;
  final double? savedLng;

  const LocationData({
    required this.countryCode,
    required this.countryName,
    required this.cityName,
    required this.cityLat,
    required this.cityLng,
    this.savedAddress,
    this.savedLat,
    this.savedLng,
  });

  LocationData copyWith({
    String? countryCode,
    String? countryName,
    String? cityName,
    double? cityLat,
    double? cityLng,
    String? savedAddress,
    double? savedLat,
    double? savedLng,
  }) {
    return LocationData(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      cityName: cityName ?? this.cityName,
      cityLat: cityLat ?? this.cityLat,
      cityLng: cityLng ?? this.cityLng,
      savedAddress: savedAddress ?? this.savedAddress,
      savedLat: savedLat ?? this.savedLat,
      savedLng: savedLng ?? this.savedLng,
    );
  }

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'countryName': countryName,
        'cityName': cityName,
        'cityLat': cityLat,
        'cityLng': cityLng,
        if (savedAddress != null) 'savedAddress': savedAddress,
        if (savedLat != null) 'savedLat': savedLat,
        if (savedLng != null) 'savedLng': savedLng,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      countryCode: json['countryCode'] as String,
      countryName: json['countryName'] as String,
      cityName: json['cityName'] as String,
      cityLat: (json['cityLat'] as num).toDouble(),
      cityLng: (json['cityLng'] as num).toDouble(),
      savedAddress: json['savedAddress'] as String?,
      savedLat: json['savedLat'] != null ? (json['savedLat'] as num).toDouble() : null,
      savedLng: json['savedLng'] != null ? (json['savedLng'] as num).toDouble() : null,
    );
  }
}

/// All supported countries with their cities
class SupportedLocations {
  SupportedLocations._();

  static const List<LocationCountry> countries = [
    LocationCountry(
      code: 'KZ',
      name: 'Казахстан',
      flag: '🇰🇿',
      cities: [
        LocationCity(name: 'Астана', lat: 51.1605, lng: 71.4704),
        LocationCity(name: 'Алматы', lat: 43.2220, lng: 76.8512),
        LocationCity(name: 'Шымкент', lat: 42.3417, lng: 69.5901),
        LocationCity(name: 'Ерейментау', lat: 51.6167, lng: 73.1000),
        LocationCity(name: 'Семей', lat: 50.4111, lng: 80.2275),
        LocationCity(name: 'Атырау', lat: 47.1164, lng: 51.8830),
        LocationCity(name: 'Актобе', lat: 50.2839, lng: 57.1670),
        LocationCity(name: 'Тараз', lat: 42.9000, lng: 71.3667),
        LocationCity(name: 'Павлодар', lat: 52.2873, lng: 76.9674),
        LocationCity(name: 'Усть-Каменогорск', lat: 49.9714, lng: 82.6072),
        LocationCity(name: 'Костанай', lat: 53.2144, lng: 63.6246),
        LocationCity(name: 'Кызылорда', lat: 44.8479, lng: 65.4999),
        LocationCity(name: 'Уральск', lat: 51.2333, lng: 51.3667),
        LocationCity(name: 'Петропавловск', lat: 54.8667, lng: 69.1500),
        LocationCity(name: 'Актау', lat: 43.6500, lng: 51.1667),
        LocationCity(name: 'Темиртау', lat: 50.0546, lng: 72.9647),
        LocationCity(name: 'Кокшетау', lat: 53.2833, lng: 69.3833),
        LocationCity(name: 'Туркестан', lat: 43.2975, lng: 68.2517),
        LocationCity(name: 'Кызылорда', lat: 44.8479, lng: 65.4999),
        LocationCity(name: 'Жанаозен', lat: 43.3319, lng: 52.8619),
      ],
    ),
    LocationCountry(
      code: 'UZ',
      name: 'Узбекистан',
      flag: '🇺🇿',
      cities: [
        LocationCity(name: 'Ташкент', lat: 41.2995, lng: 69.2401),
        LocationCity(name: 'Самарканд', lat: 39.6542, lng: 66.9758),
        LocationCity(name: 'Наманган', lat: 40.9983, lng: 71.6726),
        LocationCity(name: 'Андижан', lat: 40.7821, lng: 72.3442),
        LocationCity(name: 'Нукус', lat: 42.4600, lng: 59.6100),
        LocationCity(name: 'Бухара', lat: 39.7747, lng: 64.4286),
        LocationCity(name: 'Фергана', lat: 40.3864, lng: 71.7864),
        LocationCity(name: 'Карши', lat: 38.8610, lng: 65.7914),
        LocationCity(name: 'Коканд', lat: 40.5283, lng: 70.9422),
      ],
    ),
    LocationCountry(
      code: 'KG',
      name: 'Кыргызстан',
      flag: '🇰🇬',
      cities: [
        LocationCity(name: 'Бишкек', lat: 42.8746, lng: 74.5698),
        LocationCity(name: 'Ош', lat: 40.5283, lng: 72.7985),
        LocationCity(name: 'Жалал-Абад', lat: 40.9335, lng: 73.0000),
        LocationCity(name: 'Каракол', lat: 42.4897, lng: 78.3936),
        LocationCity(name: 'Талас', lat: 42.5200, lng: 72.2400),
      ],
    ),
    LocationCountry(
      code: 'RU',
      name: 'Россия',
      flag: '🇷🇺',
      cities: [
        LocationCity(name: 'Москва', lat: 55.7558, lng: 37.6173),
        LocationCity(name: 'Санкт-Петербург', lat: 59.9343, lng: 30.3351),
        LocationCity(name: 'Новосибирск', lat: 54.9885, lng: 82.9207),
        LocationCity(name: 'Екатеринбург', lat: 56.8389, lng: 60.6057),
        LocationCity(name: 'Казань', lat: 55.7887, lng: 49.1221),
        LocationCity(name: 'Омск', lat: 54.9885, lng: 73.3242),
        LocationCity(name: 'Уфа', lat: 54.7388, lng: 55.9721),
        LocationCity(name: 'Красноярск', lat: 56.0153, lng: 92.8932),
      ],
    ),
    LocationCountry(
      code: 'TJ',
      name: 'Таджикистан',
      flag: '🇹🇯',
      cities: [
        LocationCity(name: 'Душанбе', lat: 38.5598, lng: 68.7739),
        LocationCity(name: 'Худжанд', lat: 40.2810, lng: 69.6220),
        LocationCity(name: 'Куляб', lat: 37.9154, lng: 69.7901),
      ],
    ),
    LocationCountry(
      code: 'TM',
      name: 'Туркменистан',
      flag: '🇹🇲',
      cities: [
        LocationCity(name: 'Ашхабад', lat: 37.9601, lng: 58.3261),
        LocationCity(name: 'Туркменабат', lat: 39.0868, lng: 63.5714),
        LocationCity(name: 'Дашогуз', lat: 41.8369, lng: 59.9661),
      ],
    ),
  ];
}
