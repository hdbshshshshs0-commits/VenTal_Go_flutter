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