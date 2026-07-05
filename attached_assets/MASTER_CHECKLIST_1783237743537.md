# VenTal Go — мастер-чек-лист реализации (Flutter)

Этот файл — единственный источник правды по коду проекта. Работай строго по порядку разделов сверху вниз. Для каждого файла: создай его по указанному пути (если файла нет — создай, если есть — замени содержимое целиком), вставь код как есть, ничего не меняй в логике без явного запроса.

Стек: Flutter + MapLibre GL (карта на базе OSM/Maputnik style.json) + Provider (state/локализация) + geolocator + url_launcher + shimmer.

Package name проекта: `vental_go`. Все импорты между файлами — через `package:vental_go/...` (не относительные `../../`), это надёжнее при рефакторинге.

---

## РАЗДЕЛ 0 — ЗАВИСИМОСТИ

### Файл: `pubspec.yaml`
Замени секцию `dependencies` и `flutter.assets` целиком на:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  provider: ^6.1.2
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  maplibre_gl: ^0.20.0
  url_launcher: ^6.2.5
  shimmer: ^3.0.0
  geolocator: ^12.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/services/
    - assets/images/icons/
    - assets/images/banners/
    - assets/images/cars/
    - assets/map/
```

**ВАЖНО перед `flutter pub get`:** версия `maplibre_gl: ^0.20.0` указана ориентировочно — на момент выполнения зайди на https://pub.dev/packages/maplibre_gl и проверь актуальную стабильную версию (не dev/beta), впиши точное число. Пакет требует **минимум Kotlin 2.1.0** — проверь `android/settings.gradle.kts` и подними Kotlin plugin версию, если там ниже. Если появится конфликт AGP/Gradle/JDK при сборке — не чини по одному параметру, подними всю цепочку разом (AGP → Gradle wrapper → Kotlin → compileSdk/targetSdk/minSdk → JDK target) и пришли `android/build.gradle.kts` + `android/settings.gradle.kts` + `gradle-wrapper.properties` — тогда дадим точные согласованные числа.

После правки `pubspec.yaml`:
```bash
flutter pub get
```

### Разрешения — Android

Файл: `android/app/src/main/AndroidManifest.xml` — внутри тега `<manifest>`, ДО `<application>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Разрешения — iOS

Файл: `ios/Runner/Info.plist` — внутри `<dict>`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Приложению нужен доступ к геолокации, чтобы показать ваше местоположение на карте</string>
```

### Карта — обязательный файл от пользователя

Файл: `assets/map/style.json` — это файл, экспортированный из Maputnik. Пользователь кладёт его сам. Проверь секцию `"sources"` внутри — там должен быть рабочий URL тайлового сервера, иначе карта будет пустой/серой даже при правильном коде. Это не связано с Flutter-кодом — не пытайся чинить это через Dart.

---

## РАЗДЕЛ 1 — CORE: ЦВЕТА

### Файл: `lib/core/theme/app_colors.dart`
```dart
import 'package:flutter/material.dart';

/// Единственный источник цветов во всём приложении.
/// Хардкод HEX-цветов в виджетах запрещён — только через AppColors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0B4429); // глубокий матовый изумрудный
  static const Color accent = Color(0xFFA7F3D0); // мятный
  static const Color background = Color(0xFFF8F9FA); // ультра-светлый серый

  static const Color textDark = Color(0xFF1B1F1D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A0B4429);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
}
```

---

## РАЗДЕЛ 2 — CORE: ЛОКАЛИЗАЦИЯ (i18n: русский, казахский, английский)

Архитектура: три файла с переводами (просто `Map<String, String>` каждый) + контроллер текущего языка (`ChangeNotifier`, слушается через Provider) + класс доступа `AppLocalizations`, вызываемый как `context.l10n.t('key')` в любом виджете. Смена языка — `context.read<LocaleController>().setLocale(AppLocale.kk)`, весь экран перерисуется сам благодаря `context.watch` внутри `l10n`.

### Файл: `lib/core/localization/translations/ru.dart`
```dart
const Map<String, String> ruTranslations = {
  // Главный экран
  'search_hint': 'Найти еду, такси, посылку...',
  'tile_food': 'ЕДА',
  'tile_taxi': 'ТАКСИ',
  'tile_parcels': 'ПОСЫЛКИ',
  'chip_shops': 'Магазины',
  'chip_veggies': 'Овощи и фрукты',
  'chip_supplements': 'БАДы',
  'chip_pharmacy': 'Аптеки',
  'banner_collab': 'Рекомендации от Айтыма Жакупова',
  'aitym_screen_title': 'Рекомендации Айтыма',
  'aitym_badge': 'Автор подборки',
  'back': 'Назад',
  'retry': 'Повторить',
  'loading': 'Загрузка...',
  'error_generic': 'Что-то пошло не так. Попробуйте ещё раз.',

  // Такси — классы авто
  'car_class_economy': 'Эконом',
  'car_class_comfort': 'Комфорт',
  'car_class_comfort_plus': 'Комфорт+',
  'car_class_business': 'Бизнес',
  'car_class_eco': 'Эко',

  // Способы оплаты
  'payment_card': 'Карта',
  'payment_cash': 'Наличные',
  'payment_kaspi_transfer': 'Kaspi перевод',
  'payment_halyk_transfer': 'Halyk перевод',

  // Такси — экраны
  'taxi_from': 'Откуда',
  'taxi_to': 'Куда',
  'taxi_order_button': 'Заказать за',
  'taxi_fill_addresses': 'Укажите адреса',
  'taxi_choose_payment': 'Способ оплаты',
  'taxi_searching_driver': 'Ищем водителя',
  'taxi_searching_driver_subtitle': 'Обычно занимает 1-3 минуты',
  'taxi_cancel_search': 'Отменить поиск',
  'taxi_driver_found': 'Водитель найден',
  'taxi_arrives_in': 'Подъедет через',
  'taxi_min_short': 'мин',
  'taxi_call_driver': 'Позвонить',
  'taxi_rate_trip_title': 'Оцените поездку',
  'taxi_rate_comment_hint': 'Комментарий (необязательно)',
  'taxi_rate_submit': 'Отправить',
  'nav_2gis': '2ГИС',
  'nav_yandex': 'Яндекс Навигатор',

  // Геолокация
  'location_disabled': 'Геолокация выключена на устройстве',
  'location_denied': 'Доступ к геолокации отклонён',
  'location_denied_forever': 'Доступ заблокирован навсегда — включите в настройках',

  // Курьер
  'courier_go_online': 'Выйти на смену',
  'courier_searching_orders': 'Ищем заказы для вас',
  'courier_new_order': 'Новый заказ',
  'courier_swipe_to_accept': 'Свайпните, чтобы принять',
  'courier_status_to_restaurant': 'Еду в ресторан',
  'courier_status_picked_up': 'Забрал заказ',
  'courier_status_delivering': 'Везу клиенту',
  'courier_status_delivered': 'Доставлено',
  'courier_meters_left': 'м до точки',
  'courier_sound_settings_title': 'Звук уведомлений',
  'courier_sound_option_1': 'Классический',
  'courier_sound_option_2': 'Мягкий',
  'courier_sound_option_3': 'Бодрый',
  'courier_sound_play': 'Прослушать',
  'courier_sound_select': 'Выбрать',

  // Водитель
  'driver_searching_order': 'Ищем заказ...',
  'driver_new_order': 'Новый заказ',
  'driver_accept': 'Принять',
  'driver_decline': 'Отклонить',
  'driver_categories_title': 'Активные категории',
  'driver_category_taxi': 'Такси',
  'driver_category_food': 'Еда',
  'driver_category_parcels': 'Посылки',

  // Ресторан
  'restaurant_orders_title': 'Заказы',
  'restaurant_status_new': 'Новый',
  'restaurant_status_accepted': 'Принят',
  'restaurant_status_cooking': 'Готовится',
  'restaurant_status_ready': 'Готово',
  'restaurant_status_given_to_courier': 'Передан курьеру',
  'restaurant_accept_order': 'Принять',
  'restaurant_mark_cooking': 'Готовим',
  'restaurant_mark_ready': 'Готово',
  'restaurant_mark_given': 'Передать курьеру',

  // Еда — клиент
  'food_restaurants_title': 'Рестораны',
  'food_min_order': 'мин. заказ',
  'food_delivery_time': 'мин',
  'food_free_delivery': 'Бесплатная доставка',
  'food_menu_search_hint': 'Найти блюдо...',
  'food_add_to_cart': 'В корзину',
  'food_cart_title': 'Корзина',
  'food_cart_empty': 'Корзина пуста',
  'food_go_to_checkout': 'Оформить заказ',
  'food_checkout_title': 'Оформление',
  'food_checkout_address': 'Адрес доставки',
  'food_checkout_time': 'Время доставки',
  'food_checkout_payment': 'Способ оплаты',
  'food_checkout_confirm': 'Подтвердить заказ',
  'food_service_fee': 'Сервисный сбор',
  'food_total': 'Итого',

  // Посылки — клиент
  'parcel_title': 'Отправить посылку',
  'parcel_category_title': 'Категория посылки',
  'parcel_category_up_to_5kg': 'До 5 кг',
  'parcel_category_5_20kg': '5–20 кг',
  'parcel_category_30kg_plus': '30 кг и больше',
  'parcel_delivery_type_title': 'Тип доставки',
  'parcel_delivery_to_address': 'До адреса',
  'parcel_delivery_door_to_door': 'От двери до двери',
  'parcel_sender_title': 'Отправитель',
  'parcel_receiver_title': 'Получатель',
  'parcel_name_hint': 'Имя',
  'parcel_phone_hint': 'Телефон',
  'parcel_address_hint': 'Адрес',
  'parcel_entrance_hint': 'Подъезд',
  'parcel_floor_hint': 'Этаж',
  'parcel_apartment_hint': 'Квартира',
  'parcel_comment_hint': 'Комментарий курьеру (необязательно)',
  'parcel_order_button': 'Заказать за',
};
```

### Файл: `lib/core/localization/translations/kk.dart`
```dart
const Map<String, String> kkTranslations = {
  'search_hint': 'Тамақ, такси, сәлемдеме табу...',
  'tile_food': 'ТАМАҚ',
  'tile_taxi': 'ТАКСИ',
  'tile_parcels': 'СӘЛЕМДЕМЕ',
  'chip_shops': 'Дүкендер',
  'chip_veggies': 'Көкөніс пен жеміс',
  'chip_supplements': 'БАД',
  'chip_pharmacy': 'Дәріхана',
  'banner_collab': 'Айтым Жакуповтың ұсыныстары',
  'aitym_screen_title': 'Айтымның ұсыныстары',
  'aitym_badge': 'Автор таңдауы',
  'back': 'Артқа',
  'retry': 'Қайталау',
  'loading': 'Жүктелуде...',
  'error_generic': 'Бірдеңе дұрыс болмады. Қайталап көріңіз.',

  'car_class_economy': 'Эконом',
  'car_class_comfort': 'Комфорт',
  'car_class_comfort_plus': 'Комфорт+',
  'car_class_business': 'Бизнес',
  'car_class_eco': 'Эко',

  'payment_card': 'Карта',
  'payment_cash': 'Қолма-қол',
  'payment_kaspi_transfer': 'Kaspi аударым',
  'payment_halyk_transfer': 'Halyk аударым',

  'taxi_from': 'Қайдан',
  'taxi_to': 'Қайда',
  'taxi_order_button': 'Тапсырыс беру',
  'taxi_fill_addresses': 'Мекенжайларды көрсетіңіз',
  'taxi_choose_payment': 'Төлем тәсілі',
  'taxi_searching_driver': 'Жүргізуші іздеуде',
  'taxi_searching_driver_subtitle': 'Әдетте 1-3 минут алады',
  'taxi_cancel_search': 'Іздеуді тоқтату',
  'taxi_driver_found': 'Жүргізуші табылды',
  'taxi_arrives_in': 'Келеді',
  'taxi_min_short': 'мин',
  'taxi_call_driver': 'Қоңырау шалу',
  'taxi_rate_trip_title': 'Сапарды бағалаңыз',
  'taxi_rate_comment_hint': 'Пікір (міндетті емес)',
  'taxi_rate_submit': 'Жіберу',
  'nav_2gis': '2ГИС',
  'nav_yandex': 'Яндекс Навигатор',

  'location_disabled': 'Құрылғыда геолокация өшірулі',
  'location_denied': 'Геолокацияға қол жеткізу қабылданбады',
  'location_denied_forever': 'Мүлдем бұғатталған — баптауларда қосыңыз',

  'courier_go_online': 'Ауысымға шығу',
  'courier_searching_orders': 'Сізге тапсырыс іздеп жатырмыз',
  'courier_new_order': 'Жаңа тапсырыс',
  'courier_swipe_to_accept': 'Қабылдау үшін сырғытыңыз',
  'courier_status_to_restaurant': 'Мейрамханаға барамын',
  'courier_status_picked_up': 'Тапсырысты алдым',
  'courier_status_delivering': 'Клиентке апарамын',
  'courier_status_delivered': 'Жеткізілді',
  'courier_meters_left': 'м нүктеге дейін',
  'courier_sound_settings_title': 'Хабарландыру дыбысы',
  'courier_sound_option_1': 'Классикалық',
  'courier_sound_option_2': 'Жұмсақ',
  'courier_sound_option_3': 'Сергек',
  'courier_sound_play': 'Тыңдау',
  'courier_sound_select': 'Таңдау',

  'driver_searching_order': 'Тапсырыс іздеп жатырмыз...',
  'driver_new_order': 'Жаңа тапсырыс',
  'driver_accept': 'Қабылдау',
  'driver_decline': 'Бас тарту',
  'driver_categories_title': 'Белсенді санаттар',
  'driver_category_taxi': 'Такси',
  'driver_category_food': 'Тамақ',
  'driver_category_parcels': 'Сәлемдеме',

  'restaurant_orders_title': 'Тапсырыстар',
  'restaurant_status_new': 'Жаңа',
  'restaurant_status_accepted': 'Қабылданды',
  'restaurant_status_cooking': 'Дайындалуда',
  'restaurant_status_ready': 'Дайын',
  'restaurant_status_given_to_courier': 'Курьерге берілді',
  'restaurant_accept_order': 'Қабылдау',
  'restaurant_mark_cooking': 'Дайындаймыз',
  'restaurant_mark_ready': 'Дайын',
  'restaurant_mark_given': 'Курьерге беру',

  'food_restaurants_title': 'Мейрамханалар',
  'food_min_order': 'мин. тапсырыс',
  'food_delivery_time': 'мин',
  'food_free_delivery': 'Тегін жеткізу',
  'food_menu_search_hint': 'Тағам іздеу...',
  'food_add_to_cart': 'Себетке',
  'food_cart_title': 'Себет',
  'food_cart_empty': 'Себет бос',
  'food_go_to_checkout': 'Рәсімдеу',
  'food_checkout_title': 'Рәсімдеу',
  'food_checkout_address': 'Жеткізу мекенжайы',
  'food_checkout_time': 'Жеткізу уақыты',
  'food_checkout_payment': 'Төлем тәсілі',
  'food_checkout_confirm': 'Тапсырысты растау',
  'food_service_fee': 'Қызмет ақысы',
  'food_total': 'Барлығы',

  'parcel_title': 'Сәлемдеме жіберу',
  'parcel_category_title': 'Сәлемдеме санаты',
  'parcel_category_up_to_5kg': '5 кг дейін',
  'parcel_category_5_20kg': '5–20 кг',
  'parcel_category_30kg_plus': '30 кг және одан көп',
  'parcel_delivery_type_title': 'Жеткізу түрі',
  'parcel_delivery_to_address': 'Мекенжайға дейін',
  'parcel_delivery_door_to_door': 'Есіктен есікке',
  'parcel_sender_title': 'Жіберуші',
  'parcel_receiver_title': 'Алушы',
  'parcel_name_hint': 'Аты',
  'parcel_phone_hint': 'Телефон',
  'parcel_address_hint': 'Мекенжай',
  'parcel_entrance_hint': 'Подъезд',
  'parcel_floor_hint': 'Қабат',
  'parcel_apartment_hint': 'Пәтер',
  'parcel_comment_hint': 'Курьерге пікір (міндетті емес)',
  'parcel_order_button': 'Тапсырыс беру',
};
```

### Файл: `lib/core/localization/translations/en.dart`
```dart
const Map<String, String> enTranslations = {
  'search_hint': 'Find food, taxi, delivery...',
  'tile_food': 'FOOD',
  'tile_taxi': 'TAXI',
  'tile_parcels': 'PARCELS',
  'chip_shops': 'Shops',
  'chip_veggies': 'Fruits & Veggies',
  'chip_supplements': 'Supplements',
  'chip_pharmacy': 'Pharmacy',
  'banner_collab': 'Recommendations by Aitym Zhakupov',
  'aitym_screen_title': "Aitym's picks",
  'aitym_badge': 'Curated by author',
  'back': 'Back',
  'retry': 'Retry',
  'loading': 'Loading...',
  'error_generic': 'Something went wrong. Please try again.',

  'car_class_economy': 'Economy',
  'car_class_comfort': 'Comfort',
  'car_class_comfort_plus': 'Comfort+',
  'car_class_business': 'Business',
  'car_class_eco': 'Eco',

  'payment_card': 'Card',
  'payment_cash': 'Cash',
  'payment_kaspi_transfer': 'Kaspi transfer',
  'payment_halyk_transfer': 'Halyk transfer',

  'taxi_from': 'From',
  'taxi_to': 'To',
  'taxi_order_button': 'Order for',
  'taxi_fill_addresses': 'Enter addresses',
  'taxi_choose_payment': 'Payment method',
  'taxi_searching_driver': 'Finding a driver',
  'taxi_searching_driver_subtitle': 'Usually takes 1-3 minutes',
  'taxi_cancel_search': 'Cancel search',
  'taxi_driver_found': 'Driver found',
  'taxi_arrives_in': 'Arrives in',
  'taxi_min_short': 'min',
  'taxi_call_driver': 'Call',
  'taxi_rate_trip_title': 'Rate your trip',
  'taxi_rate_comment_hint': 'Comment (optional)',
  'taxi_rate_submit': 'Submit',
  'nav_2gis': '2GIS',
  'nav_yandex': 'Yandex Navigator',

  'location_disabled': 'Location is disabled on this device',
  'location_denied': 'Location access denied',
  'location_denied_forever': 'Access permanently blocked — enable it in settings',

  'courier_go_online': 'Go online',
  'courier_searching_orders': 'Looking for orders for you',
  'courier_new_order': 'New order',
  'courier_swipe_to_accept': 'Swipe to accept',
  'courier_status_to_restaurant': 'Heading to restaurant',
  'courier_status_picked_up': 'Picked up order',
  'courier_status_delivering': 'Delivering to client',
  'courier_status_delivered': 'Delivered',
  'courier_meters_left': 'm to point',
  'courier_sound_settings_title': 'Notification sound',
  'courier_sound_option_1': 'Classic',
  'courier_sound_option_2': 'Soft',
  'courier_sound_option_3': 'Energetic',
  'courier_sound_play': 'Play',
  'courier_sound_select': 'Select',

  'driver_searching_order': 'Searching for order...',
  'driver_new_order': 'New order',
  'driver_accept': 'Accept',
  'driver_decline': 'Decline',
  'driver_categories_title': 'Active categories',
  'driver_category_taxi': 'Taxi',
  'driver_category_food': 'Food',
  'driver_category_parcels': 'Parcels',

  'restaurant_orders_title': 'Orders',
  'restaurant_status_new': 'New',
  'restaurant_status_accepted': 'Accepted',
  'restaurant_status_cooking': 'Cooking',
  'restaurant_status_ready': 'Ready',
  'restaurant_status_given_to_courier': 'Given to courier',
  'restaurant_accept_order': 'Accept',
  'restaurant_mark_cooking': 'Start cooking',
  'restaurant_mark_ready': 'Mark ready',
  'restaurant_mark_given': 'Hand to courier',

  'food_restaurants_title': 'Restaurants',
  'food_min_order': 'min order',
  'food_delivery_time': 'min',
  'food_free_delivery': 'Free delivery',
  'food_menu_search_hint': 'Search dish...',
  'food_add_to_cart': 'Add to cart',
  'food_cart_title': 'Cart',
  'food_cart_empty': 'Cart is empty',
  'food_go_to_checkout': 'Checkout',
  'food_checkout_title': 'Checkout',
  'food_checkout_address': 'Delivery address',
  'food_checkout_time': 'Delivery time',
  'food_checkout_payment': 'Payment method',
  'food_checkout_confirm': 'Confirm order',
  'food_service_fee': 'Service fee',
  'food_total': 'Total',

  'parcel_title': 'Send a parcel',
  'parcel_category_title': 'Parcel category',
  'parcel_category_up_to_5kg': 'Up to 5 kg',
  'parcel_category_5_20kg': '5–20 kg',
  'parcel_category_30kg_plus': '30 kg and more',
  'parcel_delivery_type_title': 'Delivery type',
  'parcel_delivery_to_address': 'To address',
  'parcel_delivery_door_to_door': 'Door to door',
  'parcel_sender_title': 'Sender',
  'parcel_receiver_title': 'Receiver',
  'parcel_name_hint': 'Name',
  'parcel_phone_hint': 'Phone',
  'parcel_address_hint': 'Address',
  'parcel_entrance_hint': 'Entrance',
  'parcel_floor_hint': 'Floor',
  'parcel_apartment_hint': 'Apartment',
  'parcel_comment_hint': "Comment for courier (optional)",
  'parcel_order_button': 'Order for',
};
```

### Файл: `lib/core/localization/locale_controller.dart`
```dart
import 'package:flutter/foundation.dart';

enum AppLocale { ru, kk, en }

/// Единая точка управления текущим языком приложения.
/// Слушатели (виджеты через Provider) перерисовываются автоматически
/// при вызове setLocale — никакой ручной пересборки экранов не нужно.
class LocaleController extends ChangeNotifier {
  AppLocale _locale = AppLocale.ru;

  AppLocale get locale => _locale;

  void setLocale(AppLocale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }
}
```

### Файл: `lib/core/localization/app_localizations.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'locale_controller.dart';
import 'translations/ru.dart';
import 'translations/kk.dart';
import 'translations/en.dart';

class AppLocalizations {
  final AppLocale locale;

  const AppLocalizations(this.locale);

  static const Map<AppLocale, Map<String, String>> _tables = {
    AppLocale.ru: ruTranslations,
    AppLocale.kk: kkTranslations,
    AppLocale.en: enTranslations,
  };

  String t(String key) {
    return _tables[locale]?[key] ?? ruTranslations[key] ?? key;
  }
}

/// Удобный доступ: context.l10n.t('key')
/// Через context.watch подписывается на LocaleController — при смене
/// языка виджет, использующий это, автоматически перерисуется.
extension LocalizationContext on BuildContext {
  AppLocalizations get l10n {
    final controller = watch<LocaleController>();
    return AppLocalizations(controller.locale);
  }
}
```

---

## РАЗДЕЛ 3 — CORE: ГЕОЛОКАЦИЯ

### Файл: `lib/core/location/location_service.dart`
```dart
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {}

class LocationPermissionDeniedForeverException implements Exception {}

class LocationService {
  static Future<LatLng> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationServiceDisabledException();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Поток обновлений позиции — для live-tracking водителя/курьера.
  static Stream<LatLng> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((p) => LatLng(p.latitude, p.longitude));
  }
}
```

---

## РАЗДЕЛ 4 — CORE: КАРТА (MapLibre GL)

**ВАЖНО:** классы называются `MapLibreMap` и `MapLibreMapController` (заглавные L и R) — это точное имя из пакета `maplibre_gl`, не путать с "Maplibre" с маленькой буквы.

### Файл: `lib/core/maps/widgets/center_pin.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Свой пин по центру карты — фиксирован на экране, карта двигается под ним.
/// Используется для выбора адреса (такси, посылки).
class CenterPin extends StatelessWidget {
  const CenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 22),
              ),
              Container(width: 3, height: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/core/maps/widgets/driver_car_marker.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Виджет-иконка машины водителя для отображения через SymbolManager
/// (addImage + Symbol) MapLibre, либо как оверлей поверх карты, если
/// координата конвертируется в экранные пиксели через controller.toScreenLocation.
/// Замени на Image.asset('assets/images/cars/car_marker.png'), когда будет
/// готова кастомная иконка машины.
class DriverCarMarker extends StatelessWidget {
  final double rotationDegrees;

  const DriverCarMarker({super.key, this.rotationDegrees = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * 3.1415926535 / 180,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
```

### Файл: `lib/core/maps/map_widget.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'widgets/center_pin.dart';

/// Единый виджет карты на базе MapLibre GL + style.json из Maputnik.
/// Используется клиентом (выбор адреса), водителем и курьером (live-карта).
class AppMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final bool showCenterPin;
  final void Function(MapLibreMapController controller)? onMapReady;

  const AppMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 15,
    this.showCenterPin = false,
    this.onMapReady,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          styleString: 'asset://assets/map/style.json',
          myLocationEnabled: true,
          onMapCreated: (controller) => _controller = controller,
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            if (_controller != null) widget.onMapReady?.call(_controller!);
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

### Файл: `lib/core/maps/navigation_deeplinks.dart`
```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Диплинки на внешние навигаторы. Если приложение не установлено,
/// откроется веб-версия (fallback) — поведение самих сервисов.
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
```

### Файл: `lib/core/maps/widgets/navigation_buttons_row.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../navigation_deeplinks.dart';

/// Плотный ряд кнопок навигации — используется и курьером, и водителем.
class NavigationButtonsRow extends StatelessWidget {
  final LatLng destination;

  const NavigationButtonsRow({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NavButton(
            label: context.l10n.t('nav_2gis'),
            onTap: () => NavigationDeeplinks.open2Gis(destination),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NavButton(
            label: context.l10n.t('nav_yandex'),
            onTap: () => NavigationDeeplinks.openYandexNavigator(destination),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
    );
  }
}
```

---

## РАЗДЕЛ 5 — CORE: ОБЩИЕ ВИДЖЕТЫ (скелетоны, пульс-индикатор геозоны)

### Файл: `lib/core/widgets/skeleton_box.dart`
```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Базовый прямоугольник-скелетон. Из него собираются скелетоны любых
/// экранов — экран открывается мгновенно, скелетон показывается,
/// пока данные не пришли, потом сам заменяется на контент.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
```

### Файл: `lib/core/widgets/pulse_indicator.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

/// Пульсирующий импульс от точки — используется у курьера, чтобы
/// показать зону 100-150м вокруг ресторана/клиента (шаг 35 чек-листа).
class PulseIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PulseIndicator({super.key, this.color = AppColors.primary, this.size = 60});

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - _controller.value).clamp(0.0, 1.0),
                child: Container(
                  width: widget.size * _controller.value,
                  height: widget.size * _controller.value,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withOpacity(0.3)),
                ),
              ),
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## РАЗДЕЛ 6 — APP.DART / MAIN.DART

### Файл: `lib/app/app.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/locale_controller.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VenTal Go',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const MainHubScreen(),
      ),
    );
  }
}
```

### Файл: `lib/main.dart`
```dart
import 'package:flutter/material.dart';

import 'app/app.dart';

void main() {
  runApp(const SuperApp());
}
```


---

## РАЗДЕЛ 7 — ГЛАВНЫЙ ЭКРАН (MAIN HUB)

Логика: адрес-пилюля сверху → 3 крупные круглые плитки (Еда/Такси/Посылки) → горизонтальный скролл мелких категорий → автокарусель баннеров (Айтым + промо) → плавающая строка поиска снизу с прыгающей лупой поверх всего.

### Файл: `lib/features/main_hub/data/models/service_tile_model.dart`
```dart
class ServiceTileModel {
  final String id;
  final String labelKey;
  final String iconPath;
  final int sortOrder;

  const ServiceTileModel({
    required this.id,
    required this.labelKey,
    required this.iconPath,
    this.sortOrder = 0,
  });
}
```

### Файл: `lib/features/main_hub/presentation/widgets/address_pill.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class AddressPill extends StatelessWidget {
  final String address;
  final VoidCallback? onTap;

  const AddressPill({super.key, required this.address, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(address, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 18),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/widgets/main_services_row.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';

class MainServicesRow extends StatelessWidget {
  final List<ServiceTileModel> tiles;
  final void Function(ServiceTileModel tile) onTap;

  const MainServicesRow({super.key, required this.tiles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tiles
          .map((tile) => _MainServiceCircle(
                label: context.l10n.t(tile.labelKey),
                imagePath: tile.iconPath,
                onTap: () => onTap(tile),
              ))
          .toList(),
    );
  }
}

class _MainServiceCircle extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _MainServiceCircle({required this.label, required this.imagePath, required this.onTap});

  @override
  State<_MainServiceCircle> createState() => _MainServiceCircleState();
}

class _MainServiceCircleState extends State<_MainServiceCircle> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 14, offset: Offset(0, 6))],
              ),
              padding: const EdgeInsets.all(14),
              child: ClipOval(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 8),
            Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/widgets/related_services_row.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';

class RelatedServicesRow extends StatelessWidget {
  final List<ServiceTileModel> tiles;
  final void Function(ServiceTileModel tile) onTap;

  const RelatedServicesRow({super.key, required this.tiles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return _RelatedCircle(
            label: context.l10n.t(tile.labelKey),
            imagePath: tile.iconPath,
            onTap: () => onTap(tile),
          );
        },
      ),
    );
  }
}

class _RelatedCircle extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _RelatedCircle({required this.label, required this.imagePath, required this.onTap});

  @override
  State<_RelatedCircle> createState() => _RelatedCircleState();
}

class _RelatedCircleState extends State<_RelatedCircle> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: const EdgeInsets.all(10),
                child: ClipOval(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/widgets/promo_carousel.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class PromoCarouselItem {
  final String imagePath;
  final String? titleKey;
  final VoidCallback? onTap;

  const PromoCarouselItem({required this.imagePath, this.titleKey, this.onTap});
}

class PromoCarousel extends StatefulWidget {
  final List<PromoCarouselItem> items;

  const PromoCarousel({super.key, required this.items});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.items.isEmpty) return;
      _currentPage = (_currentPage + 1) % widget.items.length;
      _controller.animateToPage(_currentPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: item.onTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(item.imagePath, fit: BoxFit.cover),
                        if (item.titleKey != null)
                          Positioned(
                            left: 16,
                            bottom: 14,
                            right: 16,
                            child: Text(
                              context.l10n.t(item.titleKey!),
                              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/widgets/floating_search_bar.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class FloatingSearchBar extends StatefulWidget {
  const FloatingSearchBar({super.key});

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) => Transform.translate(offset: Offset(0, _bounceAnimation.value), child: child),
                child: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(context.l10n.t('search_hint'), style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/screens/aitym_recommendations_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class AitymRecommendationsScreen extends StatelessWidget {
  const AitymRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        title: Text(context.l10n.t('aitym_screen_title')),
      ),
      body: Center(child: Text(context.l10n.t('back'))),
    );
  }
}
```

### Файл: `lib/features/main_hub/presentation/screens/main_hub_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import '../../data/models/service_tile_model.dart';
import '../widgets/address_pill.dart';
import '../widgets/main_services_row.dart';
import '../widgets/related_services_row.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/floating_search_bar.dart';
import 'aitym_recommendations_screen.dart';
import 'package:vental_go/features/taxi/presentation/screens/taxi_order_screen.dart';
import 'package:vental_go/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:vental_go/features/parcels/presentation/screens/parcel_order_screen.dart';

class MainHubScreen extends StatelessWidget {
  const MainHubScreen({super.key});

  static const _mainTiles = [
    ServiceTileModel(id: 'food', labelKey: 'tile_food', iconPath: 'assets/images/services/food.png', sortOrder: 1),
    ServiceTileModel(id: 'taxi', labelKey: 'tile_taxi', iconPath: 'assets/images/services/taxi.png', sortOrder: 2),
    ServiceTileModel(id: 'parcels', labelKey: 'tile_parcels', iconPath: 'assets/images/services/parcels.png', sortOrder: 3),
  ];

  static const _relatedTiles = [
    ServiceTileModel(id: 'shops', labelKey: 'chip_shops', iconPath: 'assets/images/icons/shops.png'),
    ServiceTileModel(id: 'veggies', labelKey: 'chip_veggies', iconPath: 'assets/images/icons/veggies.png'),
    ServiceTileModel(id: 'supplements', labelKey: 'chip_supplements', iconPath: 'assets/images/icons/supplements.png'),
    ServiceTileModel(id: 'pharmacy', labelKey: 'chip_pharmacy', iconPath: 'assets/images/icons/pharmacy.png'),
  ];

  void _handleMainTileTap(BuildContext context, ServiceTileModel tile) {
    switch (tile.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'parcels':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelOrderScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                const AddressPill(address: 'Мангилик Ел, 28'), // TODO: реальный адрес из геолокации/профиля
                const SizedBox(height: 20),
                MainServicesRow(tiles: _mainTiles, onTap: (tile) => _handleMainTileTap(context, tile)),
                const SizedBox(height: 20),
                RelatedServicesRow(tiles: _relatedTiles, onTap: (_) {}),
                const SizedBox(height: 24),
                PromoCarousel(
                  items: [
                    PromoCarouselItem(
                      imagePath: 'assets/images/banners/collab_aitym.png',
                      titleKey: 'banner_collab',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AitymRecommendationsScreen()),
                      ),
                    ),
                    const PromoCarouselItem(imagePath: 'assets/images/banners/promo_1.png'),
                    const PromoCarouselItem(imagePath: 'assets/images/banners/promo_2.png'),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const FloatingSearchBar(),
        ],
      ),
    );
  }
}
```

---

## РАЗДЕЛ 8 — ТАКСИ (клиент)

Логика полного пути: **TaxiOrderScreen** (карта на весь экран + Bottom Sheet снизу с классами авто и оплатой) → нажатие "Заказать" → **TaxiSearchingDriverScreen** (анимация поиска) → водитель найден → **TaxiRideInProgressScreen** (кастомный маркер машины двигается по карте в реальном времени, кнопки навигации 2ГИС/Яндекс) → завершение → **TaxiRatingScreen** (звёзды + комментарий).

### Файл: `lib/features/taxi/data/models/car_class_model.dart`
```dart
enum CityType { smallCity, bigCity }

enum CarClass { economy, comfort, comfortPlus, business, eco }

class CarClassPricing {
  final CarClass carClass;
  final int minPrice;
  final int kmRate;
  final String photoPath;

  const CarClassPricing({
    required this.carClass,
    required this.minPrice,
    required this.kmRate,
    required this.photoPath,
  });
}

extension CarClassLabel on CarClass {
  String get stringKey {
    switch (this) {
      case CarClass.economy:
        return 'car_class_economy';
      case CarClass.comfort:
        return 'car_class_comfort';
      case CarClass.comfortPlus:
        return 'car_class_comfort_plus';
      case CarClass.business:
        return 'car_class_business';
      case CarClass.eco:
        return 'car_class_eco';
    }
  }
}
```

### Файл: `lib/features/taxi/data/models/payment_method_model.dart`
```dart
enum PaymentMethod { card, cash, kaspiTransfer, halykTransfer }

extension PaymentMethodLabel on PaymentMethod {
  String get stringKey {
    switch (this) {
      case PaymentMethod.card:
        return 'payment_card';
      case PaymentMethod.cash:
        return 'payment_cash';
      case PaymentMethod.kaspiTransfer:
        return 'payment_kaspi_transfer';
      case PaymentMethod.halykTransfer:
        return 'payment_halyk_transfer';
    }
  }

  /// Путь к иконке способа оплаты. Положи свои PNG сюда:
  /// assets/images/icons/payment_card.png, payment_cash.png,
  /// payment_kaspi.png, payment_halyk.png
  String get iconPath {
    switch (this) {
      case PaymentMethod.card:
        return 'assets/images/icons/payment_card.png';
      case PaymentMethod.cash:
        return 'assets/images/icons/payment_cash.png';
      case PaymentMethod.kaspiTransfer:
        return 'assets/images/icons/payment_kaspi.png';
      case PaymentMethod.halykTransfer:
        return 'assets/images/icons/payment_halyk.png';
    }
  }
}
```

### Файл: `lib/features/taxi/data/models/ride_model.dart`
```dart
import 'package:maplibre_gl/maplibre_gl.dart';

import 'car_class_model.dart';
import 'payment_method_model.dart';

enum RideStatus { searching, driverAssigned, driverArriving, inProgress, completed, cancelled }

class RideModel {
  final String id;
  final LatLng fromPosition;
  final LatLng toPosition;
  final String fromAddress;
  final String toAddress;
  final double distanceKm;
  final CarClass carClass;
  final PaymentMethod paymentMethod;
  final int price;
  final RideStatus status;

  const RideModel({
    required this.id,
    required this.fromPosition,
    required this.toPosition,
    required this.fromAddress,
    required this.toAddress,
    required this.distanceKm,
    required this.carClass,
    required this.paymentMethod,
    required this.price,
    this.status = RideStatus.searching,
  });
}
```

### Файл: `lib/features/taxi/data/pricing/taxi_pricing_calculator.dart`
```dart
import '../models/car_class_model.dart';

/// Тарифы такси — ваши реальные цифры + класс Эко (+15% к Комфорт+
/// по каждому типу города). Комиссия сервиса 6% карта + 4% налог СМЗ
/// (водитель получает 90% при карте, 100% при наличке/переводе).
class TaxiPricingCalculator {
  static const Map<CityType, List<CarClassPricing>> _table = {
    CityType.smallCity: [
      CarClassPricing(carClass: CarClass.economy, minPrice: 500, kmRate: 60, photoPath: 'assets/images/cars/economy.png'),
      CarClassPricing(carClass: CarClass.comfort, minPrice: 700, kmRate: 80, photoPath: 'assets/images/cars/comfort.png'),
      CarClassPricing(carClass: CarClass.comfortPlus, minPrice: 900, kmRate: 100, photoPath: 'assets/images/cars/comfort_plus.png'),
      CarClassPricing(carClass: CarClass.business, minPrice: 1100, kmRate: 120, photoPath: 'assets/images/cars/business.png'),
      CarClassPricing(carClass: CarClass.eco, minPrice: 1035, kmRate: 115, photoPath: 'assets/images/cars/eco.png'),
    ],
    CityType.bigCity: [
      CarClassPricing(carClass: CarClass.economy, minPrice: 1100, kmRate: 80, photoPath: 'assets/images/cars/economy.png'),
      CarClassPricing(carClass: CarClass.comfort, minPrice: 1200, kmRate: 100, photoPath: 'assets/images/cars/comfort.png'),
      CarClassPricing(carClass: CarClass.comfortPlus, minPrice: 1300, kmRate: 120, photoPath: 'assets/images/cars/comfort_plus.png'),
      CarClassPricing(carClass: CarClass.business, minPrice: 1500, kmRate: 150, photoPath: 'assets/images/cars/business.png'),
      CarClassPricing(carClass: CarClass.eco, minPrice: 1495, kmRate: 138, photoPath: 'assets/images/cars/eco.png'),
    ],
  };

  static const double cardCommissionRate = 0.06;
  static const double taxRate = 0.04;

  static List<CarClassPricing> classesFor(CityType cityType) => _table[cityType]!;

  static int calculatePrice({required CityType cityType, required CarClass carClass, required double distanceKm}) {
    final pricing = _table[cityType]!.firstWhere((p) => p.carClass == carClass);
    return (pricing.minPrice + pricing.kmRate * distanceKm).round();
  }

  static int driverEarningsCard(int ridePrice) => (ridePrice * (1 - cardCommissionRate - taxRate)).round();

  static int driverEarningsCash(int ridePrice) => ridePrice;
}
```

Положи фото машин по классам в: `assets/images/cars/economy.png`, `comfort.png`, `comfort_plus.png`, `business.png`, `eco.png`. Пропиши папку в `pubspec.yaml` assets (уже добавлено в Разделе 0).

### Файл: `lib/features/taxi/presentation/widgets/address_input_field.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class AddressInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  const AddressInputField({super.key, required this.icon, required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/widgets/car_class_card.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';

/// Плотная карточка класса авто внутри Bottom Sheet — фото машины слева,
/// название и цена справа. Пользователь выбирает тапом.
class CarClassCard extends StatelessWidget {
  final CarClassPricing pricing;
  final double distanceKm;
  final bool isSelected;
  final VoidCallback onTap;

  const CarClassCard({
    super.key,
    required this.pricing,
    required this.distanceKm,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = (pricing.minPrice + pricing.kmRate * distanceKm).round();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 40,
              child: Image.asset(pricing.photoPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.t(pricing.carClass.stringKey),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              ),
            ),
            Text(
              '$price тг',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/widgets/payment_method_selector.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/payment_method_model.dart';

/// Кнопка текущего способа оплаты слева снизу. Тап открывает выпадающий
/// список остальных способов (не отдельный экран).
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({super.key, required this.selected, required this.onChanged});

  void _showDropdown(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu<PaymentMethod>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy - 8, position.dx + 200, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: PaymentMethod.values.map((method) {
        return PopupMenuItem<PaymentMethod>(
          value: method,
          child: Row(
            children: [
              Image.asset(method.iconPath, width: 22, height: 22),
              const SizedBox(width: 10),
              Text(context.l10n.t(method.stringKey)),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(selected.iconPath, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(context.l10n.t(selected.stringKey), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/widgets/taxi_screen_skeleton.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/widgets/skeleton_box.dart';

class TaxiScreenSkeleton extends StatelessWidget {
  const TaxiScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 52),
          const SizedBox(height: 10),
          const SkeletonBox(width: double.infinity, height: 52),
          const SizedBox(height: 20),
          ...List.generate(4, (i) => const Padding(padding: EdgeInsets.only(bottom: 8), child: SkeletonBox(width: double.infinity, height: 58))),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/widgets/car_class_bottom_sheet.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/pricing/taxi_pricing_calculator.dart';
import 'address_input_field.dart';
import 'car_class_card.dart';
import 'payment_method_selector.dart';
import 'taxi_screen_skeleton.dart';

/// Главный Bottom Sheet экрана такси. Выезжает снизу поверх карты и
/// содержит: поля адресов, список классов авто с фото (Bottom Sheet
/// стиль референсов Яндекс Go / Bolt, но в нашей цветовой гамме),
/// выбор оплаты слева внизу, кнопку заказа справа внизу.
class CarClassBottomSheet extends StatefulWidget {
  final bool dataLoaded;
  final CityType cityType;
  final String fromAddress;
  final String toAddress;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final CarClass selectedClass;
  final ValueChanged<CarClass> onClassSelected;
  final PaymentMethod selectedPayment;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final double distanceKm;
  final VoidCallback onOrder;

  const CarClassBottomSheet({
    super.key,
    required this.dataLoaded,
    required this.cityType,
    required this.fromAddress,
    required this.toAddress,
    required this.onFromChanged,
    required this.onToChanged,
    required this.selectedClass,
    required this.onClassSelected,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.distanceKm,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: !dataLoaded
            ? const TaxiScreenSkeleton()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  AddressInputField(
                    icon: Icons.trip_origin,
                    hint: context.l10n.t('taxi_from'),
                    value: fromAddress,
                    onChanged: onFromChanged,
                  ),
                  const SizedBox(height: 8),
                  AddressInputField(
                    icon: Icons.location_on,
                    hint: context.l10n.t('taxi_to'),
                    value: toAddress,
                    onChanged: onToChanged,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Column(
                        children: TaxiPricingCalculator.classesFor(cityType).map((pricing) {
                          return CarClassCard(
                            pricing: pricing,
                            distanceKm: distanceKm,
                            isSelected: pricing.carClass == selectedClass,
                            onTap: () => onClassSelected(pricing.carClass),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PaymentMethodSelector(selected: selectedPayment, onChanged: onPaymentChanged),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: distanceKm > 0 ? onOrder : null,
                            child: Text(
                              distanceKm > 0
                                  ? '${context.l10n.t('taxi_order_button')} ${TaxiPricingCalculator.calculatePrice(cityType: cityType, carClass: selectedClass, distanceKm: distanceKm)} тг'
                                  : context.l10n.t('taxi_fill_addresses'),
                              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/screens/taxi_order_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../widgets/car_class_bottom_sheet.dart';
import 'taxi_searching_driver_screen.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  bool _dataLoaded = false;
  LatLng? _userPosition;
  String? _locationErrorKey;

  String fromAddress = '';
  String toAddress = '';
  CarClass selectedClass = CarClass.economy;
  PaymentMethod selectedPayment = PaymentMethod.card;
  final CityType cityType = CityType.bigCity;
  double distanceKm = 0; // TODO: расчёт через геокодер (Photon/Nominatim) по введённым адресам

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = position);
    } on LocationServiceDisabledException {
      setState(() => _locationErrorKey = 'location_disabled');
    } on LocationPermissionDeniedException {
      setState(() => _locationErrorKey = 'location_denied');
    } on LocationPermissionDeniedForeverException {
      setState(() => _locationErrorKey = 'location_denied_forever');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _dataLoaded = true);
  }

  void _handleOrder() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiSearchingDriverScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _userPosition == null
                ? Container(
                    color: AppColors.divider,
                    child: Center(
                      child: _locationErrorKey != null
                          ? Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.t(_locationErrorKey!), textAlign: TextAlign.center))
                          : const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : AppMapWidget(initialPosition: _userPosition!, showCenterPin: true),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CarClassBottomSheet(
              dataLoaded: _dataLoaded,
              cityType: cityType,
              fromAddress: fromAddress,
              toAddress: toAddress,
              onFromChanged: (v) => setState(() => fromAddress = v),
              onToChanged: (v) => setState(() => toAddress = v),
              selectedClass: selectedClass,
              onClassSelected: (c) => setState(() => selectedClass = c),
              selectedPayment: selectedPayment,
              onPaymentChanged: (p) => setState(() => selectedPayment = p),
              distanceKm: distanceKm,
              onOrder: _handleOrder,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/screens/taxi_searching_driver_screen.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'taxi_ride_in_progress_screen.dart';

class TaxiSearchingDriverScreen extends StatefulWidget {
  const TaxiSearchingDriverScreen({super.key});

  @override
  State<TaxiSearchingDriverScreen> createState() => _TaxiSearchingDriverScreenState();
}

class _TaxiSearchingDriverScreenState extends State<TaxiSearchingDriverScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    // TODO: заменить на реальный WebSocket-запрос статуса поиска водителя.
    _mockTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TaxiRideInProgressScreen()));
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: 24),
            Text(context.l10n.t('taxi_searching_driver'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(context.l10n.t('taxi_searching_driver_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(context.l10n.t('taxi_cancel_search')),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/screens/taxi_ride_in_progress_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/maps/widgets/navigation_buttons_row.dart';
import 'taxi_rating_screen.dart';

/// Экран активной поездки — карта с живой позицией водителя (кастомный
/// маркер машины, шаг из нашего обсуждения), карточка с инфо о водителе
/// снизу, кнопки навигации 2ГИС/Яндекс.
class TaxiRideInProgressScreen extends StatefulWidget {
  const TaxiRideInProgressScreen({super.key});

  @override
  State<TaxiRideInProgressScreen> createState() => _TaxiRideInProgressScreenState();
}

class _TaxiRideInProgressScreenState extends State<TaxiRideInProgressScreen> {
  // TODO: заменить на реальный поток координат водителя с бэкенда (WebSocket).
  static const LatLng _mockDestination = LatLng(51.1605, 71.4704);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(initialPosition: _mockDestination),
            // TODO: добавить кастомный маркер машины (DriverCarMarker) поверх карты,
            // обновляемый через SymbolManager.update() при получении новых координат.
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: AppColors.divider, child: Icon(Icons.person, color: AppColors.textDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Водитель', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text('${context.l10n.t('taxi_arrives_in')} 3 ${context.l10n.t('taxi_min_short')}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const NavigationButtonsRow(destination: _mockDestination),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        // TODO: вызывается реальным событием "поездка завершена" с бэкенда
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TaxiRatingScreen()));
                      },
                      child: const Text('Завершить (тест)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/taxi/presentation/screens/taxi_rating_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

class TaxiRatingScreen extends StatefulWidget {
  const TaxiRatingScreen({super.key});

  @override
  State<TaxiRatingScreen> createState() => _TaxiRatingScreenState();
}

class _TaxiRatingScreenState extends State<TaxiRatingScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: отправить {rating, comment} на бэкенд
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainHubScreen()),
      (route) => false,
    );
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
              Text(context.l10n.t('taxi_rate_trip_title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starIndex),
                    icon: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.warning,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.t('taxi_rate_comment_hint'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _submit,
                  child: Text(context.l10n.t('taxi_rate_submit'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
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

---

## РАЗДЕЛ 9 — КУРЬЕР

Логика: **CourierHomeScreen** (карта на весь экран, Bottom Sheet снизу). Оффлайн → тумблер/свайп "Выйти на смену" → онлайн, ищем заказы → приходит новый заказ, Bottom Sheet трансформируется в карточку со свайпом для принятия → после принятия статусы идут по цепочке (Еду в ресторан → Забрал заказ → Везу клиенту → Доставлено), каждая кнопка смены статуса — с геопривязкой (текст в метрах + пульс-индикатор). Отдельно — **CourierSoundSettingsScreen** (список из 3 карточек звука).

### Файл: `lib/features/courier_panel/data/models/courier_order_status.dart`
```dart
enum CourierOrderStatus { offline, searching, newOrderIncoming, headingToRestaurant, pickedUp, delivering, delivered }
```

### Файл: `lib/features/courier_panel/presentation/widgets/geo_proximity_indicator.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/pulse_indicator.dart';

/// Показывает курьеру расстояние до точки текстом + пульсирующий импульс.
/// Кнопка смены статуса (передаётся снаружи) активна только когда
/// distanceMeters <= 150 (шаг 35 чек-листа).
class GeoProximityIndicator extends StatelessWidget {
  final int distanceMeters;

  const GeoProximityIndicator({super.key, required this.distanceMeters});

  bool get isInZone => distanceMeters <= 150;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseIndicator(color: isInZone ? AppColors.success : AppColors.warning, size: 36),
        const SizedBox(width: 10),
        Text(
          '$distanceMeters ${context.l10n.t('courier_meters_left')}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isInZone ? AppColors.success : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
```

### Файл: `lib/features/courier_panel/presentation/widgets/courier_order_bottom_sheet.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/courier_order_status.dart';
import 'geo_proximity_indicator.dart';

/// Единый Bottom Sheet курьера — меняет содержимое в зависимости от
/// CourierOrderStatus. Один и тот же виджет проходит все стадии смены,
/// не открывая новых экранов — по вашему решению.
class CourierOrderBottomSheet extends StatelessWidget {
  final CourierOrderStatus status;
  final int distanceMeters;
  final VoidCallback onGoOnline;
  final VoidCallback onAcceptOrder;
  final VoidCallback onAdvanceStatus;

  const CourierOrderBottomSheet({
    super.key,
    required this.status,
    required this.distanceMeters,
    required this.onGoOnline,
    required this.onAcceptOrder,
    required this.onAdvanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: SafeArea(top: false, child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (status) {
      case CourierOrderStatus.offline:
        return _OfflineContent(onGoOnline: onGoOnline);
      case CourierOrderStatus.searching:
        return _SearchingContent();
      case CourierOrderStatus.newOrderIncoming:
        return _NewOrderContent(onAccept: onAcceptOrder);
      case CourierOrderStatus.headingToRestaurant:
      case CourierOrderStatus.pickedUp:
      case CourierOrderStatus.delivering:
      case CourierOrderStatus.delivered:
        return _ActiveOrderContent(status: status, distanceMeters: distanceMeters, onAdvance: onAdvanceStatus);
    }
  }
}

class _OfflineContent extends StatelessWidget {
  final VoidCallback onGoOnline;
  const _OfflineContent({required this.onGoOnline});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: onGoOnline,
        child: Text(context.l10n.t('courier_go_online'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

class _SearchingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 12),
        Text(context.l10n.t('courier_searching_orders'), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NewOrderContent extends StatelessWidget {
  final VoidCallback onAccept;
  const _NewOrderContent({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.t('courier_new_order'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 16),
        // Свайп для принятия — реализовано через Dismissible-подобный жест
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 200) onAccept();
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(18)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(context.l10n.t('courier_swipe_to_accept'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveOrderContent extends StatelessWidget {
  final CourierOrderStatus status;
  final int distanceMeters;
  final VoidCallback onAdvance;

  const _ActiveOrderContent({required this.status, required this.distanceMeters, required this.onAdvance});

  String _statusKey() {
    switch (status) {
      case CourierOrderStatus.headingToRestaurant:
        return 'courier_status_to_restaurant';
      case CourierOrderStatus.pickedUp:
        return 'courier_status_picked_up';
      case CourierOrderStatus.delivering:
        return 'courier_status_delivering';
      case CourierOrderStatus.delivered:
        return 'courier_status_delivered';
      default:
        return '';
    }
  }

  bool get _buttonEnabled => distanceMeters <= 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.t(_statusKey()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            GeoProximityIndicator(distanceMeters: distanceMeters),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonEnabled ? AppColors.primary : AppColors.divider,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _buttonEnabled ? onAdvance : null,
            child: Text(context.l10n.t(_statusKey()), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
```

### Файл: `lib/features/courier_panel/presentation/screens/courier_home_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../../data/models/courier_order_status.dart';
import '../widgets/courier_order_bottom_sheet.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  LatLng? _position;
  CourierOrderStatus _status = CourierOrderStatus.offline;
  int _distanceMeters = 500;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
    } catch (_) {
      // TODO: показать ошибку доступа к геолокации в UI
    }
  }

  void _goOnline() {
    setState(() => _status = CourierOrderStatus.searching);
    // TODO: заменить на реальную WebSocket-подписку на новые заказы
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _status = CourierOrderStatus.newOrderIncoming);
    });
  }

  void _acceptOrder() {
    setState(() {
      _status = CourierOrderStatus.headingToRestaurant;
      _distanceMeters = 500;
    });
    // TODO: реальное обновление _distanceMeters из потока геолокации + координаты точки
  }

  void _advanceStatus() {
    setState(() {
      switch (_status) {
        case CourierOrderStatus.headingToRestaurant:
          _status = CourierOrderStatus.pickedUp;
          _distanceMeters = 800;
          break;
        case CourierOrderStatus.pickedUp:
          _status = CourierOrderStatus.delivering;
          break;
        case CourierOrderStatus.delivering:
          _status = CourierOrderStatus.delivered;
          _distanceMeters = 0;
          break;
        case CourierOrderStatus.delivered:
          _status = CourierOrderStatus.searching;
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted) return;
            setState(() => _status = CourierOrderStatus.newOrderIncoming);
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _position == null
                ? Container(color: AppColors.divider, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : AppMapWidget(initialPosition: _position!),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CourierOrderBottomSheet(
              status: _status,
              distanceMeters: _distanceMeters,
              onGoOnline: _goOnline,
              onAcceptOrder: _acceptOrder,
              onAdvanceStatus: _advanceStatus,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/courier_panel/presentation/screens/courier_sound_settings_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class CourierSoundSettingsScreen extends StatefulWidget {
  const CourierSoundSettingsScreen({super.key});

  @override
  State<CourierSoundSettingsScreen> createState() => _CourierSoundSettingsScreenState();
}

class _CourierSoundSettingsScreenState extends State<CourierSoundSettingsScreen> {
  int _selectedIndex = 0;
  final List<String> _labelKeys = ['courier_sound_option_1', 'courier_sound_option_2', 'courier_sound_option_3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('courier_sound_settings_title')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _labelKeys.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.music_note_rounded, color: isSelected ? AppColors.primary : AppColors.textDark),
                const SizedBox(width: 12),
                Expanded(child: Text(context.l10n.t(_labelKeys[index]), style: const TextStyle(fontWeight: FontWeight.w600))),
                TextButton(
                  onPressed: () {
                    // TODO: воспроизвести звук через package:audioplayers или аналог
                  },
                  child: Text(context.l10n.t('courier_sound_play')),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = index),
                  child: Text(
                    context.l10n.t('courier_sound_select'),
                    style: TextStyle(color: isSelected ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## РАЗДЕЛ 10 — ВОДИТЕЛЬ

Логика: **DriverHomeScreen** — карта на весь экран, тумблер онлайн/офлайн (свайп), при новом заказе — тот же принцип Bottom Sheet, но принятие **тапом на кнопку**, не свайпом (ваше уточнение — отличие от курьера). Переключение активных категорий (такси/еда/посылки) — тумблеры в профиле, отдельный виджет `CategoryToggleRow`.

### Файл: `lib/features/driver_panel/presentation/widgets/online_offline_toggle.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class OnlineOfflineToggle extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const OnlineOfflineToggle({super.key, required this.onChanged});

  @override
  State<OnlineOfflineToggle> createState() => _OnlineOfflineToggleState();
}

class _OnlineOfflineToggleState extends State<OnlineOfflineToggle> {
  bool isOnline = false;

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => isOnline = !isOnline);
    widget.onChanged(isOnline);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      onHorizontalDragEnd: (_) => _toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 84,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: isOnline ? AppColors.success : Colors.grey.shade400, borderRadius: BorderRadius.circular(24)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(isOnline ? Icons.bolt : Icons.power_settings_new, size: 18, color: isOnline ? AppColors.success : Colors.grey),
          ),
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/driver_panel/presentation/widgets/incoming_order_card.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

/// В отличие от курьера — принятие тапом на кнопку, без свайпа.
class IncomingOrderCard extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final int driverEarnings;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingOrderCard({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.driverEarnings,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.t('driver_new_order'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('$driverEarnings тг', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 16),
          Row(children: [const Icon(Icons.trip_origin, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(fromAddress, style: const TextStyle(fontSize: 14)))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.location_on, size: 16, color: AppColors.error), const SizedBox(width: 8), Expanded(child: Text(toAddress, style: const TextStyle(fontSize: 14)))]),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(context.l10n.t('driver_decline')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(context.l10n.t('driver_accept'), style: const TextStyle(color: AppColors.textLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/driver_panel/presentation/widgets/category_toggle_row.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class CategoryToggleRow extends StatefulWidget {
  const CategoryToggleRow({super.key});

  @override
  State<CategoryToggleRow> createState() => _CategoryToggleRowState();
}

class _CategoryToggleRowState extends State<CategoryToggleRow> {
  bool taxiEnabled = true;
  bool foodEnabled = false;
  bool parcelsEnabled = false;

  Widget _row(String labelKey, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.t(labelKey), style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t('driver_categories_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        _row('driver_category_taxi', taxiEnabled, (v) => setState(() => taxiEnabled = v)),
        _row('driver_category_food', foodEnabled, (v) => setState(() => foodEnabled = v)),
        _row('driver_category_parcels', parcelsEnabled, (v) => setState(() => parcelsEnabled = v)),
      ],
    );
  }
}
```

### Файл: `lib/features/driver_panel/presentation/screens/driver_home_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../widgets/online_offline_toggle.dart';
import '../widgets/incoming_order_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  LatLng? _driverPosition;
  bool isOnline = false;
  bool isSearchingOrder = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _driverPosition = position);
    } catch (_) {
      // TODO: показать ошибку доступа к геолокации в UI
    }
  }

  void _onToggleOnline(bool value) {
    setState(() {
      isOnline = value;
      isSearchingOrder = value;
    });
    if (value) {
      // TODO: заменить на реальную WebSocket-подписку на заказы такси
      Future.delayed(const Duration(seconds: 2), _showIncomingOrder);
    }
  }

  void _showIncomingOrder() {
    if (!mounted || !isOnline) return;
    setState(() => isSearchingOrder = false);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => IncomingOrderCard(
        fromAddress: 'ул. Мангилик Ел, 28',
        toAddress: 'ул. Кабанбай батыра, 15',
        driverEarnings: 890, // TODO: TaxiPricingCalculator.driverEarningsCard(realPrice)
        onAccept: () => Navigator.pop(context),
        onDecline: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _driverPosition == null
                ? Container(color: AppColors.divider, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : AppMapWidget(initialPosition: _driverPosition!),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnlineOfflineToggle(onChanged: _onToggleOnline),
                  if (isSearchingOrder)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          Text(context.l10n.t('driver_searching_order'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
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

## РАЗДЕЛ 11 — РЕСТОРАН

Логика: канбан-доска с 5 колонками (Новый/Принят/Готовится/Готово/Передан курьеру), горизонтальный скролл между колонками, каждая карточка заказа передвигается в следующую колонку по кнопке (не drag-n-drop, просто кнопка действия на карточке — надёжнее в реализации).

### Файл: `lib/features/restaurant_panel/data/models/restaurant_order_status.dart`
```dart
enum RestaurantOrderStatus { newOrder, accepted, cooking, ready, givenToCourier }

extension RestaurantOrderStatusLabel on RestaurantOrderStatus {
  String get titleKey {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return 'restaurant_status_new';
      case RestaurantOrderStatus.accepted:
        return 'restaurant_status_accepted';
      case RestaurantOrderStatus.cooking:
        return 'restaurant_status_cooking';
      case RestaurantOrderStatus.ready:
        return 'restaurant_status_ready';
      case RestaurantOrderStatus.givenToCourier:
        return 'restaurant_status_given_to_courier';
    }
  }

  String get actionLabelKey {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return 'restaurant_accept_order';
      case RestaurantOrderStatus.accepted:
        return 'restaurant_mark_cooking';
      case RestaurantOrderStatus.cooking:
        return 'restaurant_mark_ready';
      case RestaurantOrderStatus.ready:
        return 'restaurant_mark_given';
      case RestaurantOrderStatus.givenToCourier:
        return '';
    }
  }

  RestaurantOrderStatus? get next {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return RestaurantOrderStatus.accepted;
      case RestaurantOrderStatus.accepted:
        return RestaurantOrderStatus.cooking;
      case RestaurantOrderStatus.cooking:
        return RestaurantOrderStatus.ready;
      case RestaurantOrderStatus.ready:
        return RestaurantOrderStatus.givenToCourier;
      case RestaurantOrderStatus.givenToCourier:
        return null;
    }
  }
}

class RestaurantOrderModel {
  final String id;
  final String clientName;
  final int total;
  RestaurantOrderStatus status;

  RestaurantOrderModel({required this.id, required this.clientName, required this.total, required this.status});
}
```

### Файл: `lib/features/restaurant_panel/presentation/widgets/order_card.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';

class OrderCard extends StatelessWidget {
  final RestaurantOrderModel order;
  final VoidCallback onAdvance;

  const OrderCard({super.key, required this.order, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text('${order.total} тг', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
          if (order.status.actionLabelKey.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: onAdvance,
                child: Text(context.l10n.t(order.status.actionLabelKey), style: const TextStyle(fontSize: 12.5, color: AppColors.textLight, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/restaurant_panel/presentation/widgets/kanban_column.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';
import 'order_card.dart';

class KanbanColumn extends StatelessWidget {
  final RestaurantOrderStatus status;
  final List<RestaurantOrderModel> orders;
  final void Function(RestaurantOrderModel order) onAdvance;

  const KanbanColumn({super.key, required this.status, required this.orders, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.divider.withOpacity(0.4), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.t(status.titleKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${orders.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderCard(order: orders[index], onAdvance: () => onAdvance(orders[index])),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Файл: `lib/features/restaurant_panel/presentation/screens/restaurant_orders_kanban_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';
import '../widgets/kanban_column.dart';

class RestaurantOrdersKanbanScreen extends StatefulWidget {
  const RestaurantOrdersKanbanScreen({super.key});

  @override
  State<RestaurantOrdersKanbanScreen> createState() => _RestaurantOrdersKanbanScreenState();
}

class _RestaurantOrdersKanbanScreenState extends State<RestaurantOrdersKanbanScreen> {
  // TODO: заменить мок-данные на реальные заказы с бэкенда (WebSocket-подписка).
  final List<RestaurantOrderModel> _orders = [
    RestaurantOrderModel(id: '1042', clientName: 'Асхат Б.', total: 4200, status: RestaurantOrderStatus.newOrder),
    RestaurantOrderModel(id: '1041', clientName: 'Динара К.', total: 6800, status: RestaurantOrderStatus.cooking),
    RestaurantOrderModel(id: '1040', clientName: 'Ержан С.', total: 3100, status: RestaurantOrderStatus.ready),
  ];

  void _advance(RestaurantOrderModel order) {
    final next = order.status.next;
    if (next == null) return;
    setState(() => order.status = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('restaurant_orders_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: RestaurantOrderStatus.values.map((status) {
              final ordersInColumn = _orders.where((o) => o.status == status).toList();
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: KanbanColumn(status: status, orders: ordersInColumn, onAdvance: _advance),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
```

---

## РАЗДЕЛ 12 — ЕДА (клиент)

Логика: **RestaurantListScreen** (вертикальная лента карточек в стиле Wolt) → тап на карточку → **RestaurantMenuScreen** (категории блюд сверху с быстрым переключением, список блюд под ними) → **CartScreen** (список товаров, промежуточная сумма) → **CheckoutScreen** (адрес, время, оплата, финальная сумма с учётом сервисного сбора).

### Файл: `lib/features/food/data/models/restaurant_model.dart`
```dart
class RestaurantModel {
  final String id;
  final String name;
  final String imagePath;
  final double rating;
  final int deliveryTimeMin;
  final int minOrderAmount;
  final bool freeDelivery;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.deliveryTimeMin,
    required this.minOrderAmount,
    required this.freeDelivery,
  });
}
```

### Файл: `lib/features/food/data/models/menu_item_model.dart`
```dart
class MenuCategoryModel {
  final String id;
  final String name;

  const MenuCategoryModel({required this.id, required this.name});
}

class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String imagePath;
  final int price;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.imagePath,
    required this.price,
  });
}
```

### Файл: `lib/features/food/data/pricing/food_pricing_calculator.dart`
```dart
/// Экономика еды — из зафиксированного чек-листа:
/// - мин. сумма заказа 3500тг
/// - бесплатная доставка от 7000тг
/// - сервисный сбор с клиента: 5% (заказ до 13000тг) / 3.5% (заказ свыше 13000тг, вместо 5%)
/// - комиссия ресторана: 15% (до 13000тг) / 10% (свыше 13000тг) — учитывается на стороне бэкенда,
///   здесь только то, что видит клиент.
/// - база курьера 700тг + км по типу транспорта (пеший 60, вело/скутер/электробайк 80, машина 100)
class FoodPricingCalculator {
  static const int minOrderAmount = 3500;
  static const int freeDeliveryThreshold = 7000;
  static const int largeOrderThreshold = 13000;

  static const double serviceFeeStandard = 0.05;
  static const double serviceFeeLargeOrder = 0.035;

  static const int courierBaseFee = 700;
  static const Map<String, int> courierKmRateByTransport = {
    'walk': 60,
    'bike': 80,
    'scooter': 80,
    'ebike': 80,
    'car': 100,
  };

  static double serviceFeeRate(int subtotal) => subtotal > largeOrderThreshold ? serviceFeeLargeOrder : serviceFeeStandard;

  static int serviceFeeAmount(int subtotal) => (subtotal * serviceFeeRate(subtotal)).round();

  static bool isDeliveryFree(int subtotal) => subtotal >= freeDeliveryThreshold;

  static int calculateTotal(int subtotal) {
    final fee = serviceFeeAmount(subtotal);
    return subtotal + fee;
  }
}
```

### Файл: `lib/features/food/presentation/widgets/restaurant_card.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_model.dart';

/// Карточка ресторана в стиле Wolt — крупное фото сверху, инфо снизу.
class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(restaurant.imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      Text(' ${restaurant.rating}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_rounded, size: 15, color: Colors.black45),
                      Text(' ${restaurant.deliveryTimeMin} ${context.l10n.t('food_delivery_time')}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.freeDelivery
                        ? context.l10n.t('food_free_delivery')
                        : '${context.l10n.t('food_min_order')} ${restaurant.minOrderAmount} тг',
                    style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Файл: `lib/features/food/presentation/widgets/menu_category_tabs.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import '../../data/models/menu_item_model.dart';

class MenuCategoryTabs extends StatelessWidget {
  final List<MenuCategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelect;

  const MenuCategoryTabs({super.key, required this.categories, required this.selectedCategoryId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;
          return GestureDetector(
            onTap: () => onSelect(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(
                category.name,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? AppColors.textLight : AppColors.textDark),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Файл: `lib/features/food/presentation/screens/restaurant_list_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/skeleton_box.dart';
import '../../data/models/restaurant_model.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  bool _loaded = false;
  List<RestaurantModel> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // TODO: заменить на реальный запрос к Go-бэкенду
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _restaurants = const [
        RestaurantModel(id: '1', name: 'Еда города', imagePath: 'assets/images/services/food.png', rating: 4.7, deliveryTimeMin: 35, minOrderAmount: 3500, freeDelivery: false),
        RestaurantModel(id: '2', name: 'Карима центр', imagePath: 'assets/images/services/food.png', rating: 4.5, deliveryTimeMin: 40, minOrderAmount: 3500, freeDelivery: true),
      ];
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('food_restaurants_title')),
      ),
      body: !_loaded
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(4, (i) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(width: double.infinity, height: 180))),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantMenuScreen(restaurant: restaurant))),
                );
              },
            ),
    );
  }
}
```

### Файл: `lib/features/food/presentation/screens/restaurant_menu_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/skeleton_box.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/menu_item_model.dart';
import '../widgets/menu_category_tabs.dart';
import 'cart_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  bool _loaded = false;
  List<MenuCategoryModel> _categories = [];
  List<MenuItemModel> _items = [];
  String _selectedCategoryId = '';
  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // TODO: заменить на реальный запрос меню ресторана с бэкенда
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _categories = const [
        MenuCategoryModel(id: 'starters', name: 'Закуски'),
        MenuCategoryModel(id: 'main', name: 'Основные'),
        MenuCategoryModel(id: 'desserts', name: 'Десерты'),
      ];
      _items = const [
        MenuItemModel(id: '1', categoryId: 'starters', name: 'Салат Цезарь', imagePath: 'assets/images/services/food.png', price: 1800),
        MenuItemModel(id: '2', categoryId: 'main', name: 'Бешбармак', imagePath: 'assets/images/services/food.png', price: 3200),
        MenuItemModel(id: '3', categoryId: 'desserts', name: 'Чак-чак', imagePath: 'assets/images/services/food.png', price: 900),
      ];
      _selectedCategoryId = _categories.first.id;
      _loaded = true;
    });
  }

  void _addToCart(String itemId) {
    setState(() => _cart[itemId] = (_cart[itemId] ?? 0) + 1);
  }

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final visibleItems = _items.where((i) => i.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(widget.restaurant.name),
      ),
      floatingActionButton: _cartCount > 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CartScreen(items: _items, cart: _cart)),
              ),
              label: Text('${context.l10n.t('food_cart_title')} ($_cartCount)', style: const TextStyle(color: AppColors.textLight)),
              icon: const Icon(Icons.shopping_bag_rounded, color: AppColors.textLight),
            )
          : null,
      body: !_loaded
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(4, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(width: double.infinity, height: 90))),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 12),
                MenuCategoryTabs(categories: _categories, selectedCategoryId: _selectedCategoryId, onSelect: (id) => setState(() => _selectedCategoryId = id)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(item.imagePath, width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${item.price} тг', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
                              onPressed: () => _addToCart(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
```

### Файл: `lib/features/food/presentation/screens/cart_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/pricing/food_pricing_calculator.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final List<MenuItemModel> items;
  final Map<String, int> cart;

  const CartScreen({super.key, required this.items, required this.cart});

  int get _subtotal {
    int total = 0;
    cart.forEach((itemId, qty) {
      final item = items.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = cart.entries.where((e) => e.value > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('food_cart_title')),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text(context.l10n.t('food_cart_empty')))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final entry = cartItems[index];
                      final item = items.firstWhere((i) => i.id == entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text('${item.name} × ${entry.value}', style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('${item.price * entry.value} тг', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: _subtotal >= FoodPricingCalculator.minOrderAmount
                          ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(subtotal: _subtotal)))
                          : null,
                      child: Text(
                        '${context.l10n.t('food_go_to_checkout')} · $_subtotal тг',
                        style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
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

### Файл: `lib/features/food/presentation/screens/checkout_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/pricing/food_pricing_calculator.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final int subtotal;

  const CheckoutScreen({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final serviceFee = FoodPricingCalculator.isDeliveryFree(subtotal) ? 0 : FoodPricingCalculator.serviceFeeAmount(subtotal);
    final total = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('food_checkout_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckoutRow(labelKey: 'food_checkout_address', value: 'ул. Мангилик Ел, 28'), // TODO: реальный выбор адреса
            const Divider(height: 32),
            _CheckoutRow(labelKey: 'food_checkout_time', value: '35-45 мин'),
            const Divider(height: 32),
            _CheckoutRow(labelKey: 'food_checkout_payment', value: 'Карта'), // TODO: PaymentMethodSelector из features/taxi переиспользовать
            const Divider(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(context.l10n.t('food_service_fee')),
              Text('$serviceFee тг'),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(context.l10n.t('food_total'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('$total тг', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  // TODO: отправить заказ на бэкенд
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainHubScreen()), (route) => false);
                },
                child: Text(context.l10n.t('food_checkout_confirm'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final String labelKey;
  final String value;

  const _CheckoutRow({required this.labelKey, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.t(labelKey), style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
```

---

## РАЗДЕЛ 13 — ПОСЫЛКИ (клиент)

Логика: без карты, только ручной ввод. Выбор категории веса → выбор типа доставки (до адреса / от двери до двери) → форма отправителя (имя, телефон, адрес, подъезд, этаж, квартира) → форма получателя (то же самое) → комментарий курьеру → расчёт цены по тарифам → кнопка заказа.

### Файл: `lib/features/parcels/data/models/parcel_model.dart`
```dart
enum ParcelCategory { upTo5kg, from5To20kg, from30kgPlus }

enum ParcelDeliveryType { toAddress, doorToDoor }

class ParcelContactInfo {
  final String name;
  final String phone;
  final String address;
  final String entrance;
  final String floor;
  final String apartment;

  const ParcelContactInfo({
    required this.name,
    required this.phone,
    required this.address,
    required this.entrance,
    required this.floor,
    required this.apartment,
  });

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty;
}
```

### Файл: `lib/features/parcels/data/pricing/parcel_pricing_calculator.dart`
```dart
import '../models/parcel_model.dart';

/// Тарифы посылок — база + километраж, из зафиксированного чек-листа.
/// Клиент платит базу+км, курьер получает базу+км (меньше на маржу
/// сервиса), километраж полностью передаётся курьеру.
class ParcelPricingCalculator {
  static const Map<ParcelCategory, ({int clientBase, int courierBase, int kmRate})> _table = {
    ParcelCategory.upTo5kg: (clientBase: 1000, courierBase: 800, kmRate: 60),
    ParcelCategory.from5To20kg: (clientBase: 2000, courierBase: 1500, kmRate: 80),
    ParcelCategory.from30kgPlus: (clientBase: 3500, courierBase: 3000, kmRate: 100),
  };

  static int calculateClientPrice({required ParcelCategory category, required double distanceKm}) {
    final rates = _table[category]!;
    return (rates.clientBase + rates.kmRate * distanceKm).round();
  }

  static int calculateCourierEarnings({required ParcelCategory category, required double distanceKm}) {
    final rates = _table[category]!;
    return (rates.courierBase + rates.kmRate * distanceKm).round();
  }
}
```

### Файл: `lib/features/parcels/presentation/screens/parcel_order_screen.dart`
```dart
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_model.dart';
import '../../data/pricing/parcel_pricing_calculator.dart';
import 'package:vental_go/features/main_hub/presentation/screens/main_hub_screen.dart';

class ParcelOrderScreen extends StatefulWidget {
  const ParcelOrderScreen({super.key});

  @override
  State<ParcelOrderScreen> createState() => _ParcelOrderScreenState();
}

class _ParcelOrderScreenState extends State<ParcelOrderScreen> {
  ParcelCategory _category = ParcelCategory.upTo5kg;
  ParcelDeliveryType _deliveryType = ParcelDeliveryType.toAddress;

  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _senderAddress = TextEditingController();
  final _senderEntrance = TextEditingController();
  final _senderFloor = TextEditingController();
  final _senderApartment = TextEditingController();

  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _receiverAddress = TextEditingController();
  final _receiverEntrance = TextEditingController();
  final _receiverFloor = TextEditingController();
  final _receiverApartment = TextEditingController();

  final _comment = TextEditingController();

  // TODO: расстояние должно считаться геокодером (Photon/Nominatim) по
  // введённым адресам отправителя/получателя. Пока 0 — кнопка неактивна.
  double _distanceKm = 0;

  bool get _formValid =>
      _senderName.text.isNotEmpty &&
      _senderPhone.text.isNotEmpty &&
      _senderAddress.text.isNotEmpty &&
      _receiverName.text.isNotEmpty &&
      _receiverPhone.text.isNotEmpty &&
      _receiverAddress.text.isNotEmpty;

  @override
  void dispose() {
    for (final c in [
      _senderName, _senderPhone, _senderAddress, _senderEntrance, _senderFloor, _senderApartment,
      _receiverName, _receiverPhone, _receiverAddress, _receiverEntrance, _receiverFloor, _receiverApartment,
      _comment,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(TextEditingController controller, String hintKey, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
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

  Widget _sectionTitle(String labelKey) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(context.l10n.t(labelKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = ParcelPricingCalculator.calculateClientPrice(category: _category, distanceKm: _distanceKm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('parcel_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.l10n.t('parcel_category_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          _CategorySelector(selected: _category, onSelect: (c) => setState(() => _category = c)),

          const SizedBox(height: 20),
          Text(context.l10n.t('parcel_delivery_type_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          _DeliveryTypeSelector(selected: _deliveryType, onSelect: (t) => setState(() => _deliveryType = t)),

          _sectionTitle('parcel_sender_title'),
          _field(_senderName, 'parcel_name_hint'),
          _field(_senderPhone, 'parcel_phone_hint', keyboardType: TextInputType.phone),
          _field(_senderAddress, 'parcel_address_hint'),
          Row(children: [
            Expanded(child: _field(_senderEntrance, 'parcel_entrance_hint')),
            const SizedBox(width: 8),
            Expanded(child: _field(_senderFloor, 'parcel_floor_hint')),
            const SizedBox(width: 8),
            Expanded(child: _field(_senderApartment, 'parcel_apartment_hint')),
          ]),

          _sectionTitle('parcel_receiver_title'),
          _field(_receiverName, 'parcel_name_hint'),
          _field(_receiverPhone, 'parcel_phone_hint', keyboardType: TextInputType.phone),
          _field(_receiverAddress, 'parcel_address_hint'),
          Row(children: [
            Expanded(child: _field(_receiverEntrance, 'parcel_entrance_hint')),
            const SizedBox(width: 8),
            Expanded(child: _field(_receiverFloor, 'parcel_floor_hint')),
            const SizedBox(width: 8),
            Expanded(child: _field(_receiverApartment, 'parcel_apartment_hint')),
          ]),

          const SizedBox(height: 8),
          _field(_comment, 'parcel_comment_hint'),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _formValid
                  ? () {
                      // TODO: отправить заказ на бэкенд
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainHubScreen()), (route) => false);
                    }
                  : null,
              child: Text(
                '${context.l10n.t('parcel_order_button')} $price тг',
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final ParcelCategory selected;
  final ValueChanged<ParcelCategory> onSelect;

  const _CategorySelector({required this.selected, required this.onSelect});

  String _labelKey(ParcelCategory c) {
    switch (c) {
      case ParcelCategory.upTo5kg:
        return 'parcel_category_up_to_5kg';
      case ParcelCategory.from5To20kg:
        return 'parcel_category_5_20kg';
      case ParcelCategory.from30kgPlus:
        return 'parcel_category_30kg_plus';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ParcelCategory.values.map((c) {
        final isSelected = c == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(c),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(
                context.l10n.t(_labelKey(c)),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? AppColors.textLight : AppColors.textDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DeliveryTypeSelector extends StatelessWidget {
  final ParcelDeliveryType selected;
  final ValueChanged<ParcelDeliveryType> onSelect;

  const _DeliveryTypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _typeButton(context, ParcelDeliveryType.toAddress, 'parcel_delivery_to_address'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _typeButton(context, ParcelDeliveryType.doorToDoor, 'parcel_delivery_door_to_door'),
        ),
      ],
    );
  }

  Widget _typeButton(BuildContext context, ParcelDeliveryType type, String labelKey) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
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

---

## РАЗДЕЛ 14 — ПОРЯДОК СБОРКИ ДЛЯ АГЕНТА

Строго по шагам, не пропуская:

1. Обнови `pubspec.yaml` (Раздел 0), проверь версию `maplibre_gl` на pub.dev перед установкой.
2. Добавь разрешения геолокации в `AndroidManifest.xml` и `Info.plist` (Раздел 0).
3. Убедись, что `assets/map/style.json` существует (кладёт пользователь).
4. Создай все файлы Раздела 1 (core: цвета, локализация, геолокация, карта, скелетоны, pulse-индикатор).
5. Создай `lib/app/app.dart` и `lib/main.dart` (Раздел 6).
6. Создай все файлы Раздела 7 (главный экран).
7. Создай все файлы Раздела 8 (такси) — это самый большой раздел, не торопись.
8. Создай все файлы Раздела 9 (курьер).
9. Создай все файлы Раздела 10 (водитель).
10. Создай все файлы Раздела 11 (ресторан).
11. Создай все файлы Раздела 12 (еда).
12. Создай все файлы Раздела 13 (посылки).
13. Выполни `flutter pub get`, затем `flutter clean && flutter pub get && flutter build apk --release` (или `flutter run` для быстрой проверки).
14. Если возникнет ошибка версий Android/Gradle/Kotlin — не исправляй по одному параметру. Пришли `android/build.gradle.kts`, `android/settings.gradle.kts`, `gradle-wrapper.properties` — сначала согласуй всю цепочку.

### Изображения, которые нужно положить (пути):
```
assets/images/services/food.png
assets/images/services/taxi.png
assets/images/services/parcels.png
assets/images/icons/shops.png
assets/images/icons/veggies.png
assets/images/icons/supplements.png
assets/images/icons/pharmacy.png
assets/images/icons/payment_card.png
assets/images/icons/payment_cash.png
assets/images/icons/payment_kaspi.png
assets/images/icons/payment_halyk.png
assets/images/banners/collab_aitym.png
assets/images/banners/promo_1.png
assets/images/banners/promo_2.png
assets/images/cars/economy.png
assets/images/cars/comfort.png
assets/images/cars/comfort_plus.png
assets/images/cars/business.png
assets/images/cars/eco.png
assets/map/style.json  (пользователь кладёт сам)
```

### Что осознанно оставлено как TODO (не хардкод, а честные заглушки до бэкенда):
- Расчёт расстояния между адресами (такси, посылки) — нужен геокодер Photon/Nominatim, отдельная задача.
- Реальные координаты водителя/курьера в реальном времени — нужен WebSocket с бэкенда.
- Реальные данные ресторанов/меню/заказов — нужны эндпоинты Go-бэкенда.
- Кастомный маркер машины на карте (`DriverCarMarker`) — нужно подключить через `SymbolManager` MapLibre, обновляя позицию по потоку координат.
- Звук уведомлений (курьер/ресторан) — нужен пакет типа `audioplayers` + сами звуковые файлы.

Дальше по плану: подключение бэкенда (Go + Postgres + PostGIS) и экономики (Python) — отдельный документ, не в этом файле.
