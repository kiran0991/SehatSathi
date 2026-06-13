import 'dart:html' as html;

const _localeStorageKey = 'sehat_sathi_locale';

String? readStoredLocaleCode() {
  return html.window.localStorage[_localeStorageKey];
}

void writeStoredLocaleCode(String localeCode) {
  html.window.localStorage[_localeStorageKey] = localeCode;
}
