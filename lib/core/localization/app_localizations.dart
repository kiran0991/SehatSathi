import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, String> _translations;

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('te')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localization != null, 'AppLocalizations not found in context.');
    return localization!;
  }

  String text(String key, {Map<String, String>? params}) {
    var value = _translations[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }

  String languageLabel(String code) {
    switch (code) {
      case 'hi':
        return text('languageHindi');
      case 'te':
        return text('languageTelugu');
      default:
        return text('languageEnglish');
    }
  }

  String healthOptionLabel(String value) {
    switch (value) {
      case 'None':
        return text('optionNone');
      case 'Diabetes':
        return text('optionDiabetes');
      case 'Hypertension':
        return text('optionHypertension');
      case 'Dairy':
        return text('optionDairy');
      case 'Gluten':
        return text('optionGluten');
      case 'Peanut':
        return text('optionPeanut');
      case 'Weight Loss':
        return text('optionWeightLoss');
      case 'Healthy Eating':
        return text('optionHealthyEating');
      default:
        return value;
    }
  }

  String ingredientLabel(String value, {bool keepEnglish = true}) {
    if (locale.languageCode == 'en') {
      return value;
    }

    final translated = _translateIngredient(value);
    if (translated == null || translated == value) {
      return value;
    }

    return keepEnglish ? '$value ($translated)' : translated;
  }

  String? _translateIngredient(String value) {
    final normalized = value.toLowerCase().trim();

    String? translated;
    switch (locale.languageCode) {
      case 'hi':
        translated = switch (normalized) {
          'whole wheat' => 'साबुत गेहूं',
          'oats' => 'ओट्स',
          'millet' => 'मिलेट',
          'nuts' => 'मेवे',
          'almond' => 'बादाम',
          'peanut' => 'मूंगफली',
          'sugar' => 'चीनी',
          'glucose' => 'ग्लूकोज़',
          'corn syrup' => 'कॉर्न सिरप',
          'maida' => 'मैदा',
          'refined wheat flour' => 'रिफाइंड गेहूं का आटा',
          'salt' => 'नमक',
          'sodium' => 'सोडियम',
          'palm oil' => 'पाम ऑयल',
          'hydrogenated' => 'हाइड्रोजेनेटेड वसा',
          'preservative' => 'प्रिज़र्वेटिव',
          'artificial flavor' => 'कृत्रिम फ्लेवर',
          'cocoa' => 'कोको',
          'dairy' => 'डेयरी',
          'gluten' => 'ग्लूटेन',
          _ => null,
        };
        break;
      case 'te':
        translated = switch (normalized) {
          'whole wheat' => 'సంపూర్ణ గోధుమ',
          'oats' => 'ఓట్స్',
          'millet' => 'మిల్లెట్',
          'nuts' => 'పప్పులు',
          'almond' => 'బాదం',
          'peanut' => 'పల్లీలు',
          'sugar' => 'చక్కెర',
          'glucose' => 'గ్లూకోజ్',
          'corn syrup' => 'కార్న్ సిరప్',
          'maida' => 'మైదా',
          'refined wheat flour' => 'రిఫైన్ చేసిన గోధుమ పిండి',
          'salt' => 'ఉప్పు',
          'sodium' => 'సోడియం',
          'palm oil' => 'పామ్ ఆయిల్',
          'hydrogenated' => 'హైడ్రోజనేటెడ్ కొవ్వులు',
          'preservative' => 'ప్రిజర్వేటివ్',
          'artificial flavor' => 'కృత్రిమ రుచి',
          'cocoa' => 'కోకో',
          'dairy' => 'డైరీ',
          'gluten' => 'గ్లూటెన్',
          _ => null,
        };
        break;
    }

    if (translated != null) {
      return translated;
    }

    for (final entry in _ingredientContainsMap(locale.languageCode).entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  Map<String, String> _ingredientContainsMap(String languageCode) {
    return switch (languageCode) {
      'hi' => {
        'whole wheat': 'साबुत गेहूं',
        'oats': 'ओट्स',
        'millet': 'मिलेट',
        'nuts': 'मेवे',
        'almond': 'बादाम',
        'peanut': 'मूंगफली',
        'sugar': 'चीनी',
        'glucose': 'ग्लूकोज़',
        'corn syrup': 'कॉर्न सिरप',
        'maida': 'मैदा',
        'refined wheat flour': 'रिफाइंड गेहूं का आटा',
        'salt': 'नमक',
        'sodium': 'सोडियम',
        'palm oil': 'पाम ऑयल',
        'hydrogenated': 'हाइड्रोजेनेटेड वसा',
        'preservative': 'प्रिज़र्वेटिव',
        'artificial flavor': 'कृत्रिम फ्लेवर',
        'cocoa': 'कोको',
        'dairy': 'डेयरी',
        'gluten': 'ग्लूटेन',
      },
      'te' => {
        'whole wheat': 'సంపూర్ణ గోధుమ',
        'oats': 'ఓట్స్',
        'millet': 'మిల్లెట్',
        'nuts': 'పప్పులు',
        'almond': 'బాదం',
        'peanut': 'పల్లీలు',
        'sugar': 'చక్కెర',
        'glucose': 'గ్లూకోజ్',
        'corn syrup': 'కార్న్ సిరప్',
        'maida': 'మైదా',
        'refined wheat flour': 'రిఫైన్ చేసిన గోధుమ పిండి',
        'salt': 'ఉప్పు',
        'sodium': 'సోడియం',
        'palm oil': 'పామ్ ఆయిల్',
        'hydrogenated': 'హైడ్రోజనేటెడ్ కొవ్వులు',
        'preservative': 'ప్రిజర్వేటివ్',
        'artificial flavor': 'కృత్రిమ రుచి',
        'cocoa': 'కోకో',
        'dairy': 'డైరీ',
        'gluten': 'గ్లూటెన్',
      },
      _ => const {},
    };
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final code = isSupported(locale) ? locale.languageCode : 'en';
    final raw = await rootBundle.loadString('assets/l10n/$code.json');
    final map = Map<String, dynamic>.from(json.decode(raw) as Map);
    return AppLocalizations(
      Locale(code),
      map.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
