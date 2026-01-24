import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';

/// Key para guardar el idioma en SharedPreferences
const _localeKey = 'app_locale';

/// Provider para el locale actual de la aplicación
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier para manejar cambios de idioma
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(L10n.defaultLocale) {
    _loadSavedLocale();
  }

  /// Cargar el idioma guardado
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      final locale = Locale(savedLocale);
      if (L10n.supportedLocales.contains(locale)) {
        state = locale;
      }
    }
  }

  /// Cambiar el idioma de la aplicación
  Future<void> setLocale(Locale locale) async {
    if (!L10n.supportedLocales.contains(locale)) return;

    state = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Alternar entre idiomas disponibles
  Future<void> toggleLocale() async {
    final currentIndex = L10n.supportedLocales.indexOf(state);
    final nextIndex = (currentIndex + 1) % L10n.supportedLocales.length;
    await setLocale(L10n.supportedLocales[nextIndex]);
  }
}
