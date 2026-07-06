# VenTal Go — мастер-чек-лист V2 (авторизация, профиль, посылки, геокодинг, успех заказа)

Работать строго по разделам сверху вниз. Это дополнение к MASTER_CHECKLIST.md — не дублирует такси (уже описан в отдельном промпте с фиксом Positioned.fill), фокус на новых экранах.

**Важно перед стартом:** тестовые аккаунты (водитель/курьер/клиент/админ/ресторан) реализованы как ЛОКАЛЬНЫЙ MOCK-сервис авторизации внутри приложения — реального бэкенда ещё нет. Это explicitly не хардкод бизнес-логики, а временная заглушка ИМЕННО для авторизации, четко помеченная TODO — когда будет готов Go-бэкенд, метод `AuthService.login()` меняется на реальный HTTP-запрос, остальной код (экраны, навигация по ролям) не меняется.

---

## РАЗДЕЛ 1 — МАСКА ТЕЛЕФОНА (переиспользуемый виджет на всё приложение)

### Файл: `lib/core/widgets/phone_input_field.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Маска ввода телефона: +7 ХХХ ХХХ ХХХХ.
/// Используется везде в приложении, где вводится номер телефона
/// (регистрация, посылки — отправитель/получатель, профиль).
class PhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const PhoneInputField({super.key, required this.onChanged, this.initialValue});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer('+7 ');
    for (int i = 0; i < trimmed.length; i++) {
      buffer.write(trimmed[i]);
      if (i == 2 || i == 5) buffer.write(' ');
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '+7 ');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [_PhoneMaskFormatter()],
      onChanged: (value) {
        final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
        widget.onChanged('+$digitsOnly');
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
```

---

## РАЗДЕЛ 2 — ГЕОКОДИРОВАНИЕ (Photon + Nominatim)

### Файл: `pubspec.yaml` — добавить
```yaml
  http: ^1.2.1
```

### Файл: `lib/core/geocoding/geocoding_service.dart`
```dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class AddressSuggestion {
  final String displayName;
  final LatLng position;

  const AddressSuggestion({required this.displayName, required this.position});
}

/// Геокодирование через Photon (основной, https://photon.komoot.io) с
/// fallback на Nominatim (https://nominatim.openstreetmap.org).
/// Оба публичные бесплатные сервисы — при активном проде рекомендуется
/// поднять свой инстанс Photon (github.com/komoot/photon), публичный
/// демо-сервер троттлит при высокой нагрузке.
class GeocodingService {
  static const String _photonUrl = 'https://photon.komoot.io/api';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<AddressSuggestion>> search(String query, {LatLng? biasPosition}) async {
    if (query.trim().length < 3) return [];

    try {
      final uri = Uri.parse(_photonUrl).replace(queryParameters: {
        'q': query,
        'limit': '5',
        'lang': 'ru',
        if (biasPosition != null) 'lat': biasPosition.latitude.toString(),
        if (biasPosition != null) 'lon': biasPosition.longitude.toString(),
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          return features.map((f) => _fromPhotonFeature(f)).toList();
        }
      }
    } catch (_) {
      // переходим к fallback ниже
    }

    return _searchNominatim(query);
  }

  static AddressSuggestion _fromPhotonFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final coords = feature['geometry']['coordinates'] as List;
    final parts = [props['name'], props['street'], props['city'], props['country']]
        .where((p) => p != null && p.toString().isNotEmpty)
        .toSet()
        .join(', ');
    return AddressSuggestion(
      displayName: parts.isEmpty ? 'Без названия' : parts,
      position: LatLng(coords[1] as double, coords[0] as double),
    );
  }

  static Future<List<AddressSuggestion>> _searchNominatim(String query) async {
    try {
      final uri = Uri.parse(_nominatimUrl).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'accept-language': 'ru',
      });
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'VenTalGo/1.0 (contact: support@vental.go)'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) {
          return AddressSuggestion(
            displayName: item['display_name'] as String,
            position: LatLng(double.parse(item['lat']), double.parse(item['lon'])),
          );
        }).toList();
      }
    } catch (_) {
      // оба недоступны
    }
    return [];
  }

  /// Прямое расстояние (гаверсинус) — fallback, если OSRM недоступен.
  static double calculateDistanceKm(LatLng from, LatLng to) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(to.latitude - from.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(from.latitude)) * math.cos(_degToRad(to.latitude)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180);
}
```

### Файл: `lib/features/taxi/presentation/widgets/address_autocomplete_field.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final IconData icon;
  final String hintKey;
  final LatLng? biasPosition;
  final void Function(String address, LatLng coordinates) onAddressSelected;

  const AddressAutocompleteField({
    super.key,
    required this.icon,
    required this.hintKey,
    required this.onAddressSelected,
    this.biasPosition,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  List<AddressSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 3) {
        setState(() => _suggestions = []);
        return;
      }
      setState(() => _loading = true);
      final results = await GeocodingService.search(value, biasPosition: widget.biasPosition);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    });
  }

  void _select(AddressSuggestion suggestion) {
    _controller.text = suggestion.displayName;
    setState(() => _suggestions = []);
    widget.onAddressSelected(suggestion.displayName, suggestion.position);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  decoration: InputDecoration(hintText: context.l10n.t(widget.hintKey), border: InputBorder.none, isDense: true),
                ),
              ),
              if (_loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  title: Text(suggestion.displayName, style: const TextStyle(fontSize: 13)),
                  onTap: () => _select(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
```

---

## РАЗДЕЛ 3 — МАРШРУТ (OSRM)

### Файл: `lib/core/routing/osrm_service.dart`
```dart
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
```

### Файл: `lib/core/maps/map_widget.dart` — обновить (добавить отрисовку маршрута + центр-пин своим изображением)
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'widgets/center_pin.dart';

class AppMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final bool showCenterPin;
  final List<LatLng>? routePoints;
  final void Function(MapLibreMapController controller)? onMapReady;

  const AppMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.routePoints,
    this.onMapReady,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;
  Line? _routeLine;

  @override
  void didUpdateWidget(AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints != oldWidget.routePoints && _styleLoaded) {
      _updateRouteLine();
    }
  }

  Future<void> _updateRouteLine() async {
    final ctrl = _controller;
    if (ctrl == null) return;

    if (_routeLine != null) {
      await ctrl.removeLine(_routeLine!);
      _routeLine = null;
    }

    final points = widget.routePoints;
    if (points != null && points.length >= 2) {
      _routeLine = await ctrl.addLine(
        LineOptions(
          geometry: points,
          lineColor: '#0B4429', // AppColors.primary — наш фирменный цвет маршрута
          lineWidth: 4.5,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(target: widget.initialPosition, zoom: widget.initialZoom),
          styleString: 'asset://assets/map/style.json',
          myLocationEnabled: true,
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) {
              widget.onMapReady?.call(_controller!);
              _updateRouteLine();
            }
          },
        ),
        if (widget.showCenterPin) const CenterPin(),
        if (!_styleLoaded)
          Container(
            color: AppColors.divider,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
```

### Файл: `lib/core/maps/widgets/center_pin.dart` — обновить (реальное изображение вместо нарисованного кодом)
```dart
import 'package:flutter/material.dart';

/// Своё изображение пина — положить файл в assets/images/icons/center_pin.png
class CenterPin extends StatelessWidget {
  const CenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Image.asset('assets/images/icons/center_pin.png', width: 48, height: 64),
        ),
      ),
    );
  }
}
```
Путь для картинки: `assets/images/icons/center_pin.png` — уже сгенерирован и прислан отдельным архивом, просто положите.

---

## РАЗДЕЛ 4 — АВТОРИЗАЦИЯ (mock-сервис + тестовые аккаунты)

### Файл: `lib/features/auth/data/models/user_role.dart`
```dart
enum UserRole { client, courier, driver, restaurant, admin }
```

### Файл: `lib/features/auth/data/models/auth_user_model.dart`
```dart
import 'user_role.dart';

class AuthUserModel {
  final String phone;
  final String name;
  final UserRole role;

  const AuthUserModel({required this.phone, required this.name, required this.role});
}
```

### Файл: `lib/features/auth/data/services/auth_service.dart`
```dart
import '../models/auth_user_model.dart';
import '../models/user_role.dart';

/// MOCK-авторизация. Реального бэкенда ещё нет — вход проверяется по
/// зашитому списку тестовых пар (телефон, пароль) ниже. Когда появится
/// Go-бэкенд, метод login() меняется на реальный HTTP POST /auth/login,
/// сигнатура (принимает phone+password, возвращает AuthUserModel?) не
/// меняется — экраны трогать не придётся.
class AuthService {
  static final List<({String phone, String password, AuthUserModel user})> _testAccounts = [
    (
      phone: '+77001234501',
      password: 'client123',
      user: const AuthUserModel(phone: '+77001234501', name: 'Тестовый клиент', role: UserRole.client),
    ),
    (
      phone: '+77001234502',
      password: 'courier123',
      user: const AuthUserModel(phone: '+77001234502', name: 'Тестовый курьер', role: UserRole.courier),
    ),
    (
      phone: '+77001234503',
      password: 'driver123',
      user: const AuthUserModel(phone: '+77001234503', name: 'Тестовый водитель', role: UserRole.driver),
    ),
    (
      phone: '+77001234504',
      password: 'restaurant123',
      user: const AuthUserModel(phone: '+77001234504', name: 'Тестовый ресторан', role: UserRole.restaurant),
    ),
    (
      phone: '+77001234505',
      password: 'admin123',
      user: const AuthUserModel(phone: '+77001234505', name: 'Тестовый админ', role: UserRole.admin),
    ),
  ];

  static Future<AuthUserModel?> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // имитация сетевого запроса
    for (final account in _testAccounts) {
      if (account.phone == phone && account.password == password) {
        return account.user;
      }
    }
    return null;
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: очистка токена/сессии, когда появится реальный бэкенд
  }
}
```

**Тестовые аккаунты (сохраните себе для проверки):**
```
Клиент:     +77001234501 / client123
Курьер:     +77001234502 / courier123
Водитель:   +77001234503 / driver123
Ресторан:   +77001234504 / restaurant123
Админ:      +77001234505 / admin123
```

### Файл: `lib/features/auth/presentation/state/auth_controller.dart`
```dart
import 'package:flutter/foundation.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthUserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  Future<bool> login(String phone, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await AuthService.login(phone, password);
    isLoading = false;
    if (user == null) {
      errorMessage = 'auth_invalid_credentials';
      notifyListeners();
      return false;
    }
    currentUser = user;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await AuthService.logout();
    currentUser = null;
    notifyListeners();
  }
}
```

### Файл: `lib/features/auth/presentation/screens/login_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/phone_input_field.dart';
import '../state/auth_controller.dart';
import 'package:vental_go/app/role_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phone = '';
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit(AuthController auth) async {
    final success = await auth.login(_phone, _passwordController.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleRouter()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.t('auth_login_title'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 24),
              PhoneInputField(onChanged: (value) => _phone = value),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: context.l10n.t('auth_password_hint'),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(context.l10n.t(auth.errorMessage!), style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: auth.isLoading ? null : () => _submit(auth),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(context.l10n.t('auth_login_button'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Добавить ключи в `ru.dart`/`kk.dart`/`en.dart`:
```dart
'auth_login_title': 'Вход', // kk: 'Кіру', en: 'Sign in'
'auth_password_hint': 'Пароль', // kk: 'Құпия сөз', en: 'Password'
'auth_login_button': 'Войти', // kk: 'Кіру', en: 'Log in'
'auth_invalid_credentials': 'Неверный номер или пароль', // kk: 'Нөмір немесе құпия сөз қате', en: 'Invalid phone or password'
```

### Файл: `lib/app/role_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/data/models/user_role.dart';
import 'package:vental_go/features/auth/presentation/screens/login_screen.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';
import 'package:vental_go/features/courier_panel/presentation/screens/courier_home_screen.dart';
import 'package:vental_go/features/driver_panel/presentation/screens/driver_home_screen.dart';
import 'package:vental_go/features/restaurant_panel/presentation/screens/restaurant_orders_kanban_screen.dart';

/// Направляет пользователя на нужный интерфейс по роли после логина.
/// Админ временно ведёт на главный экран клиента — отдельный
/// админ-интерфейс не запрошен, TODO на будущее.
class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (user == null) return const LoginScreen();

    switch (user.role) {
      case UserRole.client:
      case UserRole.admin:
        return const MainHubScreen();
      case UserRole.courier:
        return const CourierHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.restaurant:
        return const RestaurantOrdersKanbanScreen();
    }
  }
}
```

### Файл: `lib/app/app.dart` — обновить (подключить AuthController + RoleRouter как home)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/locale_controller.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'role_router.dart';

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VenTal Go',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const RoleRouter(),
      ),
    );
  }
}
```

---

## РАЗДЕЛ 5 — ПРОФИЛЬ (по вашему ТЗ)

### Файл: `lib/features/profile/presentation/widgets/account_card.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: AppColors.accent, child: Icon(Icons.person, color: AppColors.primary, size: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(user?.phone ?? '—', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {}, // TODO: заглушка редактирования профиля
            child: Text(context.l10n.t('profile_edit'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/profile/presentation/widgets/profile_section_card.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class ProfileSectionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileSectionCard({super.key, required this.icon, required this.label, required this.onTap});

  @override
  State<ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<ProfileSectionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5))),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/profile/presentation/screens/profile_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/auth/presentation/state/auth_controller.dart';
import 'package:vental_go/features/auth/presentation/screens/login_screen.dart';
import '../widgets/account_card.dart';
import '../widgets/profile_section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      (icon: Icons.person_outline_rounded, key: 'profile_section_account'),
      (icon: Icons.location_on_outlined, key: 'profile_section_addresses'),
      (icon: Icons.payment_rounded, key: 'profile_section_payment'),
      (icon: Icons.receipt_long_outlined, key: 'profile_section_history'),
      (icon: Icons.settings_outlined, key: 'profile_section_settings'),
      (icon: Icons.support_agent_rounded, key: 'profile_section_support'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('profile_title')),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AccountCard(),
            const SizedBox(height: 20),
            ...sections.map((s) => ProfileSectionCard(
                  icon: s.icon,
                  label: context.l10n.t(s.key),
                  onTap: () {}, // TODO: переходы на реальные экраны разделов
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(context.l10n.t('profile_logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Ключи локализации:
```dart
'profile_title': 'Профиль', // kk: 'Профиль', en: 'Profile'
'profile_edit': 'Редактировать', // kk: 'Өзгерту', en: 'Edit'
'profile_section_account': 'Аккаунт', // kk: 'Аккаунт', en: 'Account'
'profile_section_addresses': 'Адреса', // kk: 'Мекенжайлар', en: 'Addresses'
'profile_section_payment': 'Оплата', // kk: 'Төлем', en: 'Payment'
'profile_section_history': 'История', // kk: 'Тарих', en: 'History'
'profile_section_settings': 'Настройки', // kk: 'Баптаулар', en: 'Settings'
'profile_section_support': 'Поддержка', // kk: 'Қолдау', en: 'Support'
'profile_logout': 'Выйти', // kk: 'Шығу', en: 'Log out'
```

---

## РАЗДЕЛ 6 — ПАРЯЩИЙ ТАБ-БАР (Главная/Профиль) на главном экране клиента

### Файл: `lib/features/main_hub/presentation/widgets/floating_tab_bar.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTabBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 60,
      right: 60,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              _tabItem(icon: Icons.home_rounded, index: 0),
              _tabItem(icon: Icons.person_rounded, index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem({required IconData icon, required int index}) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
```

Подключение в `MainHubScreen`: обернуть текущий `Scaffold body: Stack` в `IndexedStack`/условие показа `MainHubScreen` контента vs `ProfileScreen` в зависимости от состояния `_currentTabIndex`, и добавить `FloatingTabBar` в `Stack` рядом с `FloatingSearchBar` (либо заменить `FloatingSearchBar` на таб-бар на индексе профиля — решить по месту, когда будете собирать).

---

## РАЗДЕЛ 7 — ПОСЫЛКИ (полная пересборка по вашему сценарию)

Логика: **шаг 1** — категория веса (уже есть) → **шаг 2** — данные отправителя (переключатель "от двери до двери" / "здание до здания" СВЕРХУ экрана; если "здание до здания" — поля этаж/квартира/домофон скрыты) → **шаг 3** — данные получателя (тот же виджет формы, БЕЗ переключателя типа доставки — он общий на заказ, задаётся один раз в шаге 2) → **шаг 4** — карта с маршрутом (переиспользуем стиль из такси: наша линия маршрута, плавная анимация) → кнопка "Подтвердить" → кастомный экран успеха.

### Файл: `lib/features/parcels/data/models/parcel_contact_model.dart`
```dart
enum DeliveryScope { doorToDoor, buildingToBuilding }

class ParcelContactModel {
  final String name;
  final String phone;
  final String address;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? intercomCode;
  final String? comment;

  const ParcelContactModel({
    required this.name,
    required this.phone,
    required this.address,
    this.entrance,
    this.floor,
    this.apartment,
    this.intercomCode,
    this.comment,
  });

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty;
}
```

### Файл: `lib/features/parcels/presentation/widgets/parcel_contact_form.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/phone_input_field.dart';
import '../../data/models/parcel_contact_model.dart';

/// Универсальная форма контакта — используется и для отправителя, и для
/// получателя. showDetailFields=false скрывает этаж/квартиру/домофон
/// (режим "здание до здания"). showDetailFields всегда true для формы
/// получателя, если у отправителя выбрано "от двери до двери".
class ParcelContactForm extends StatefulWidget {
  final String titleKey;
  final bool showDetailFields;
  final ValueChanged<ParcelContactModel> onChanged;

  const ParcelContactForm({
    super.key,
    required this.titleKey,
    required this.showDetailFields,
    required this.onChanged,
  });

  @override
  State<ParcelContactForm> createState() => _ParcelContactFormState();
}

class _ParcelContactFormState extends State<ParcelContactForm> {
  final _name = TextEditingController();
  String _phone = '';
  final _address = TextEditingController();
  final _entrance = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _intercom = TextEditingController();
  final _comment = TextEditingController();

  void _emit() {
    widget.onChanged(ParcelContactModel(
      name: _name.text,
      phone: _phone,
      address: _address.text,
      entrance: widget.showDetailFields ? _entrance.text : null,
      floor: widget.showDetailFields ? _floor.text : null,
      apartment: widget.showDetailFields ? _apartment.text : null,
      intercomCode: widget.showDetailFields ? _intercom.text : null,
      comment: _comment.text,
    ));
  }

  Widget _field(TextEditingController controller, String hintKey, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines ?? 1,
        onChanged: (_) => _emit(),
        decoration: InputDecoration(
          hintText: context.l10n.t(hintKey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [_name, _address, _entrance, _floor, _apartment, _intercom, _comment]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t(widget.titleKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _field(_name, 'parcel_name_hint'),
        PhoneInputField(onChanged: (v) { _phone = v; _emit(); }),
        const SizedBox(height: 8),
        _field(_address, 'parcel_address_hint'),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: widget.showDetailFields
              ? Column(
                  children: [
                    Row(children: [
                      Expanded(child: _field(_entrance, 'parcel_entrance_hint')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_floor, 'parcel_floor_hint')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_apartment, 'parcel_apartment_hint')),
                    ]),
                    _field(_intercom, 'parcel_intercom_hint'),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _field(_comment, 'parcel_comment_hint', maxLines: 2),
      ],
    );
  }
}
```

### Файл: `lib/features/parcels/presentation/widgets/delivery_scope_selector.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_contact_model.dart';

class DeliveryScopeSelector extends StatelessWidget {
  final DeliveryScope selected;
  final ValueChanged<DeliveryScope> onSelect;

  const DeliveryScopeSelector({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _button(context, DeliveryScope.doorToDoor, 'parcel_delivery_door_to_door')),
        const SizedBox(width: 8),
        Expanded(child: _button(context, DeliveryScope.buildingToBuilding, 'parcel_delivery_building_to_building')),
      ],
    );
  }

  Widget _button(BuildContext context, DeliveryScope scope, String labelKey) {
    final isSelected = scope == selected;
    return GestureDetector(
      onTap: () => onSelect(scope),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          context.l10n.t(labelKey),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isSelected ? AppColors.textLight : AppColors.textDark),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/parcels/presentation/screens/parcel_route_screen.dart` (шаг 4 — карта с маршрутом)
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import 'parcel_success_screen.dart';

class ParcelRouteScreen extends StatefulWidget {
  final LatLng fromPosition;
  final LatLng toPosition;
  final int price;

  const ParcelRouteScreen({super.key, required this.fromPosition, required this.toPosition, required this.price});

  @override
  State<ParcelRouteScreen> createState() => _ParcelRouteScreenState();
}

class _ParcelRouteScreenState extends State<ParcelRouteScreen> {
  List<LatLng>? _routePoints;
  MapLibreMapController? _controller;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final result = await OsrmService.getRoute(widget.fromPosition, widget.toPosition);
    if (!mounted) return;
    setState(() {
      _routePoints = result?.geometry ?? [widget.fromPosition, widget.toPosition];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: widget.fromPosition,
              routePoints: _routePoints,
              onMapReady: (controller) => _controller = controller,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    // TODO: отправить заказ посылки на бэкенд
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelSuccessScreen()));
                  },
                  child: Text(
                    '${context.l10n.t('parcel_confirm_button')} ${widget.price} ${context.l10n.t('currency_tg')}',
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## РАЗДЕЛ 8 — КАСТОМНЫЙ ЭКРАН "ЗАКАЗ ОФОРМЛЕН" (еда + посылки, НЕ такси)

### Файл: `lib/core/widgets/order_success_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

/// Общий переиспользуемый экран успеха — используется и едой, и
/// посылками (НЕ такси, у такси своя логика поиска водителя).
class OrderSuccessScreen extends StatefulWidget {
  final String titleKey;
  final String subtitleKey;

  const OrderSuccessScreen({
    super.key,
    this.titleKey = 'order_success_title',
    this.subtitleKey = 'order_success_subtitle',
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      context.l10n.t(widget.titleKey),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.t(widget.subtitleKey),
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainHubScreen()),
                    (route) => false,
                  ),
                  child: Text(context.l10n.t('order_success_button'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/parcels/presentation/screens/parcel_success_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/widgets/order_success_screen.dart';

class ParcelSuccessScreen extends StatelessWidget {
  const ParcelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrderSuccessScreen(
      titleKey: 'parcel_success_title',
      subtitleKey: 'parcel_success_subtitle',
    );
  }
}
```

В `CheckoutScreen` (еда) — заменить текущий переход после подтверждения заказа на:
```dart
Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderSuccessScreen(
  titleKey: 'food_success_title',
  subtitleKey: 'food_success_subtitle',
)));
```

Ключи локализации:
```dart
'order_success_button': 'На главную', // kk: 'Басты бетке', en: 'Back to home'
'parcel_success_title': 'Посылка отправлена!', // kk: 'Сәлемдеме жіберілді!', en: 'Parcel sent!'
'parcel_success_subtitle': 'Курьер уже в пути к отправителю', // kk: 'Курьер жіберушіге бара жатыр', en: 'Courier is on the way to the sender'
'food_success_title': 'Заказ оформлен!', // kk: 'Тапсырыс рәсімделді!', en: 'Order placed!'
'food_success_subtitle': 'Ресторан уже готовит ваш заказ', // kk: 'Мейрамхана тапсырысыңызды дайындауда', en: 'Restaurant is preparing your order'
'parcel_confirm_button': 'Подтвердить за', // kk: 'Растау', en: 'Confirm for'
'parcel_delivery_building_to_building': 'Здание — здание', // kk: 'Ғимарат — ғимарат', en: 'Building to building'
'parcel_intercom_hint': 'Домофон/пароль', // kk: 'Домофон/құпия сөз', en: 'Intercom/code'
```

---

## ПОРЯДОК СБОРКИ ДЛЯ АГЕНТА

1. Сначала — фикс такси: `Positioned.fill` вместо `Positioned(bottom:0)` в `taxi_order_screen.dart` (см. отдельный промпт про такси).
2. Раздел 1 (маска телефона) — общий виджет, ставится один раз.
3. Раздел 2-3 (геокодинг + OSRM + карта с маршрутом + центр-пин) — положить `center_pin.png` из присланного архива в `assets/images/icons/center_pin.png`.
4. Раздел 4 (авторизация) — mock-сервис, RoleRouter, LoginScreen. Проверить вход всеми 5 тестовыми аккаунтами.
5. Раздел 5 (профиль) — экран профиля, кнопка логаут должна реально возвращать на LoginScreen.
6. Раздел 6 (парящий таб-бар) — подключить к MainHubScreen.
7. Раздел 7 (посылки) — пересобрать флоу: категория → отправитель (с DeliveryScopeSelector) → получатель (без селектора типа доставки) → карта с маршрутом → успех.
8. Раздел 8 (экран успеха) — подключить и к еде, и к посылкам, НЕ трогать такси.
9. После каждого раздела — `flutter analyze`, показать, что ошибок нет, прежде чем переходить к следующему.
10. В конце — полная сборка `flutter clean && flutter pub get && flutter build apk --release`, показать результат.

---

## РАЗДЕЛ 9 — КАРТА НЕ ДОЛЖНА ЖДАТЬ ГЕОЛОКАЦИЮ

Текущая проблема: экраны такси/курьера/водителя показывают спиннер и НЕ рисуют карту, пока не получено разрешение на геолокацию. Это неправильно — карта должна появляться сразу (с нейтральной дефолтной точкой), а реальное местоположение пользователя запрашивается отдельно, по кнопке на самой карте (как в Google Maps/2ГИС — синяя точка появляется только после того, как пользователь явно разрешил).

### Файл: `lib/core/location/default_location.dart` (новый)
```dart
import 'package:maplibre_gl/maplibre_gl.dart';

/// Нейтральная стартовая точка карты, если геолокация ещё не получена
/// или пользователь её не разрешил. Астана как разумный дефолт для KZ.
class DefaultLocation {
  static const LatLng center = LatLng(51.1605, 71.4704);
  static const double defaultZoom = 13;
}
```

### Файл: `lib/core/maps/widgets/locate_me_button.dart` (новый)
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Плавающая круглая кнопка на карте — запрашивает геолокацию по нажатию,
/// а не блокирует загрузку карты автоматическим запросом при открытии экрана.
class LocateMeButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const LocateMeButton({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: isLoading
              ? const Padding(padding: EdgeInsets.all(13), child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
```

### Файл: `lib/core/maps/map_widget.dart` — обновить (карта всегда грузится сразу, геолокация — по запросу)
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/location/location_service.dart';
import 'package:vental_go/core/location/default_location.dart';
import 'widgets/center_pin.dart';
import 'widgets/locate_me_button.dart';

class AppMapWidget extends StatefulWidget {
  final LatLng? initialPosition; // null допустим — тогда старт с DefaultLocation
  final double initialZoom;
  final bool showCenterPin;
  final bool showLocateButton;
  final List<LatLng>? routePoints;
  final void Function(MapLibreMapController controller)? onMapReady;
  final ValueChanged<LatLng>? onUserLocationFound;

  const AppMapWidget({
    super.key,
    this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.showLocateButton = true,
    this.routePoints,
    this.onMapReady,
    this.onUserLocationFound,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;
  bool _locatingUser = false;
  Line? _routeLine;

  @override
  void didUpdateWidget(AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints != oldWidget.routePoints && _styleLoaded) {
      _updateRouteLine();
    }
  }

  Future<void> _updateRouteLine() async {
    final ctrl = _controller;
    if (ctrl == null) return;

    if (_routeLine != null) {
      await ctrl.removeLine(_routeLine!);
      _routeLine = null;
    }

    final points = widget.routePoints;
    if (points != null && points.length >= 2) {
      _routeLine = await ctrl.addLine(
        LineOptions(
          geometry: points,
          lineColor: '#0B4429',
          lineWidth: 4.5,
          lineOpacity: 0.9,
          lineJoin: 'round',
        ),
      );
    }
  }

  /// Запрашивается ТОЛЬКО по нажатию на LocateMeButton — не при открытии экрана.
  Future<void> _handleLocateMe() async {
    setState(() => _locatingUser = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
      widget.onUserLocationFound?.call(position);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить геолокацию')), // TODO: t-ключ через контекст диалога/снекбара
      );
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPosition = widget.initialPosition ?? DefaultLocation.center;

    return Stack(
      alignment: Alignment.center,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(target: startPosition, zoom: widget.initialZoom),
          styleString: 'asset://assets/map/style.json',
          myLocationEnabled: false, // включаем синюю точку только после ручного разрешения через LocateMeButton
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) {
              widget.onMapReady?.call(_controller!);
              _updateRouteLine();
            }
          },
        ),
        if (widget.showCenterPin) const CenterPin(),
        if (!_styleLoaded)
          Container(
            color: AppColors.divider,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (widget.showLocateButton && _styleLoaded)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(child: LocateMeButton(onTap: _handleLocateMe, isLoading: _locatingUser)),
          ),
      ],
    );
  }
}
```

### Как это меняет экраны такси/курьера/водителя

Убрать паттерн "ждём геолокацию → показываем спиннер вместо карты → потом рисуем карту". Вместо этого:
```dart
// Было (убрать):
_userPosition == null
    ? Container(color: AppColors.divider, child: Center(child: ...))
    : AppMapWidget(initialPosition: _userPosition!, ...)

// Стало:
AppMapWidget(
  initialPosition: _userPosition, // может быть null — виджет сам подставит DefaultLocation
  onUserLocationFound: (position) => setState(() => _userPosition = position),
  ...
)
```

Карта рисуется мгновенно при открытии экрана (с дефолтной точкой Астаны), а `_userPosition` заполняется только когда пользователь сам нажмёт кнопку "Найти меня" на карте — тогда камера плавно долетает до реальной позиции.

**Файлы, которые нужно пройти этим паттерном:**
- `lib/features/taxi/presentation/screens/taxi_order_screen.dart`
- `lib/features/courier_panel/presentation/screens/courier_home_screen.dart`
- `lib/features/driver_panel/presentation/screens/driver_home_screen.dart`

В каждом — убрать блокирующую проверку `_userPosition == null ? spinner : map`, оставить прямой вызов `AppMapWidget(initialPosition: _userPosition, onUserLocationFound: ...)`. `_locationErrorKey`-логику (сообщения "геолокация выключена" и т.п.) — убрать полностью как самостоятельный блокирующий экран; вместо неё ошибка geolocation теперь просто показывается как `SnackBar` при нажатии кнопки "Найти меня" (уже реализовано внутри `_handleLocateMe`), не мешая пользоваться картой без геолокации вообще.

---

## ПОРЯДОК СБОРКИ — ОБНОВЛЁН

Из предыдущего порядка **убрать пункт про "починить карту"** — карта уже работает, это подтверждено. Добавить между пунктами 3 и 4:

**3.5. Убрать блокирующую геолокацию.** Обновить `map_widget.dart` (Раздел 9), добавить `LocateMeButton` и `DefaultLocation`, пройтись по такси/курьеру/водителю — убрать спиннер-блокировку, карта должна рисоваться сразу при открытии экрана независимо от статуса геолокации.

