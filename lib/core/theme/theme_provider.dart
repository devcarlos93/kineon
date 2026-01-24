import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key para guardar el tema en SharedPreferences
const _themeKey = 'app_theme_mode';

/// Modos de tema disponibles
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Provider para el modo de tema actual
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier para manejar cambios de tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadSavedTheme();
  }

  /// Cargar el tema guardado
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      state = _stringToThemeMode(savedTheme);
    }
  }

  /// Cambiar el tema de la aplicación
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));
  }

  /// Cambiar desde string (para integración con perfil)
  Future<void> setThemeModeFromString(String mode) async {
    final themeMode = _stringToThemeMode(mode);
    await setThemeMode(themeMode);
  }

  /// Convertir string a ThemeMode
  /// Nota: 'system' ya no está disponible en UI, se trata como 'dark'
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
      case 'system': // Backward compatibility: system ahora es dark
      default:
        return ThemeMode.dark;
    }
  }

  /// Convertir ThemeMode a string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Provider que resuelve el brillo efectivo (para uso en widgets)
final effectiveBrightnessProvider = Provider<Brightness>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      // Obtener el brillo del sistema
      final platformBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return platformBrightness;
  }
});
