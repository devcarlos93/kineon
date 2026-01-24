import 'package:flutter/material.dart';

/// Idiomas soportados por la aplicación
abstract final class L10n {
  /// Lista de locales soportados
  static const supportedLocales = [
    Locale('es'), // Español (por defecto)
    Locale('en'), // Inglés
  ];

  /// Locale por defecto
  static const defaultLocale = Locale('es');

  /// Obtener el nombre del idioma para mostrar
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// Obtener la bandera/emoji del idioma
  static String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}
