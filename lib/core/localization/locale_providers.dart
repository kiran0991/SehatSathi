import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_storage.dart';

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final stored = readStoredLocaleCode();
    return _localeFromCode(stored ?? 'en');
  }

  void setLocale(Locale locale) {
    state = locale;
    writeStoredLocaleCode(locale.languageCode);
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'hi':
        return const Locale('hi');
      case 'te':
        return const Locale('te');
      default:
        return const Locale('en');
    }
  }
}
