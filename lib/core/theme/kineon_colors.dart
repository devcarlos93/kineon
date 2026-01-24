import 'package:flutter/material.dart';

/// Colores adaptativos de Kineon que cambian según el tema (light/dark)
///
/// Uso: `context.colors.background` o `Theme.of(context).extension<KineonColors>()!.background`
@immutable
class KineonColors extends ThemeExtension<KineonColors> {
  // ═══════════════════════════════════════════════════════════════════
  // FONDOS
  // ═══════════════════════════════════════════════════════════════════

  /// Fondo principal de la app
  final Color background;

  /// Superficie de cards, modals, sheets
  final Color surface;

  /// Superficie elevada (para capas sobre surface)
  final Color surfaceElevated;

  /// Borde sutil para separaciones
  final Color surfaceBorder;

  // ═══════════════════════════════════════════════════════════════════
  // TEXTO
  // ═══════════════════════════════════════════════════════════════════

  /// Texto principal
  final Color textPrimary;

  /// Texto secundario
  final Color textSecondary;

  /// Texto terciario/disabled
  final Color textTertiary;

  /// Texto sobre acentos de color
  final Color textOnAccent;

  // ═══════════════════════════════════════════════════════════════════
  // ACENTOS (los mismos en ambos temas)
  // ═══════════════════════════════════════════════════════════════════

  /// Acento primario - Turquesa
  final Color accent;

  /// Acento secundario - Morado
  final Color accentPurple;

  /// Acento terciario - Lime
  final Color accentLime;

  // ═══════════════════════════════════════════════════════════════════
  // ESTADOS
  // ═══════════════════════════════════════════════════════════════════

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // ═══════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═══════════════════════════════════════════════════════════════════

  /// Color de fondo del bottom navigation bar
  final Color navBarBackground;

  /// Color de borde del bottom navigation bar
  final Color navBarBorder;

  /// Color de iconos inactivos en nav
  final Color navIconInactive;

  // ═══════════════════════════════════════════════════════════════════
  // CARDS
  // ═══════════════════════════════════════════════════════════════════

  /// Color de fondo de cards
  final Color cardBackground;

  /// Color de borde de cards
  final Color cardBorder;

  /// Sombra de cards
  final Color cardShadow;

  const KineonColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnAccent,
    required this.accent,
    required this.accentPurple,
    required this.accentLime,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.navBarBackground,
    required this.navBarBorder,
    required this.navIconInactive,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardShadow,
  });

  // ═══════════════════════════════════════════════════════════════════
  // TEMA OSCURO (actual)
  // ═══════════════════════════════════════════════════════════════════

  static const dark = KineonColors(
    // Fondos
    background: Color(0xFF0B0F14),
    surface: Color(0xFF101824),
    surfaceElevated: Color(0xFF162032),
    surfaceBorder: Color(0xFF1E2A3D),
    // Texto
    textPrimary: Color(0xFFEAF0FF),
    textSecondary: Color(0xFF9AA7C0),
    textTertiary: Color(0xFF5C6B82),
    textOnAccent: Color(0xFF0B0F14),
    // Acentos
    accent: Color(0xFF2EE9D8),
    accentPurple: Color(0xFF8B5CF6),
    accentLime: Color(0xFFA3E635),
    // Estados
    success: Color(0xFF2EE9D8),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFEF4444),
    info: Color(0xFF8B5CF6),
    // Navegación
    navBarBackground: Color(0xFF1A1F26),
    navBarBorder: Color(0x14FFFFFF), // white 8%
    navIconInactive: Color(0x80FFFFFF), // white 50%
    // Cards
    cardBackground: Color(0xFF101824),
    cardBorder: Color(0xFF1E2A3D),
    cardShadow: Color(0x4D000000), // black 30%
  );

  // ═══════════════════════════════════════════════════════════════════
  // TEMA CLARO
  // ═══════════════════════════════════════════════════════════════════

  static const light = KineonColors(
    // Fondos - basado en la imagen de referencia
    background: Color(0xFFF0F2F5), // Gris muy claro
    surface: Color(0xFFFFFFFF), // Blanco puro
    surfaceElevated: Color(0xFFF5F7FA), // Gris claro
    surfaceBorder: Color(0xFFE5E7EB), // Borde gris sutil
    // Texto
    textPrimary: Color(0xFF1A1D24), // Negro casi puro
    textSecondary: Color(0xFF5C6370), // Gris medio
    textTertiary: Color(0xFF9CA3AF), // Gris claro
    textOnAccent: Color(0xFF0B0F14), // Oscuro sobre accent
    // Acentos (mismos que dark - el turquesa destaca bien en blanco)
    accent: Color(0xFF14B8A6), // Teal un poco más oscuro para contraste
    accentPurple: Color(0xFF8B5CF6),
    accentLime: Color(0xFF65A30D), // Verde más oscuro para contraste
    // Estados
    success: Color(0xFF14B8A6),
    warning: Color(0xFFD97706), // Naranja más oscuro para contraste
    error: Color(0xFFDC2626),
    info: Color(0xFF8B5CF6),
    // Navegación - crema/blanco como en la imagen
    navBarBackground: Color(0xFFFFFBF5), // Crema muy claro
    navBarBorder: Color(0x14000000), // black 8%
    navIconInactive: Color(0xFF9CA3AF), // Gris
    // Cards - blanco con sombra sutil
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E7EB),
    cardShadow: Color(0x1A000000), // black 10%
  );

  @override
  KineonColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnAccent,
    Color? accent,
    Color? accentPurple,
    Color? accentLime,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? navBarBackground,
    Color? navBarBorder,
    Color? navIconInactive,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardShadow,
  }) {
    return KineonColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      accent: accent ?? this.accent,
      accentPurple: accentPurple ?? this.accentPurple,
      accentLime: accentLime ?? this.accentLime,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      navIconInactive: navIconInactive ?? this.navIconInactive,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  KineonColors lerp(KineonColors? other, double t) {
    if (other == null) return this;
    return KineonColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentLime: Color.lerp(accentLime, other.accentLime, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      navIconInactive: Color.lerp(navIconInactive, other.navIconInactive, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION PARA ACCESO FÁCIL
// ═══════════════════════════════════════════════════════════════════════════

/// Extension para acceder a KineonColors fácilmente
///
/// Uso: `context.colors.background` en vez de
/// `Theme.of(context).extension<KineonColors>()!.background`
extension KineonColorsExtension on BuildContext {
  /// Acceso rápido a los colores adaptativos de Kineon
  KineonColors get colors => Theme.of(this).extension<KineonColors>()!;

  /// Verifica si el tema actual es oscuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
