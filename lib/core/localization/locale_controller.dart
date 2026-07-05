import 'package:flutter/foundation.dart';

enum AppLocale { ru, kk, en }

class LocaleController extends ChangeNotifier {
  AppLocale _locale = AppLocale.ru;

  AppLocale get locale => _locale;

  void setLocale(AppLocale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }
}
