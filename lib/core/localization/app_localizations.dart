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

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n {
    final controller = watch<LocaleController>();
    return AppLocalizations(controller.locale);
  }
}
