import 'package:flutter/material.dart';

/// Paleta de colores Neo-cinema premium de Kineon
/// 
/// Estilo: Futurista suave, minimal, editorial
/// NO usar con Material 3
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════
  // FONDOS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Fondo principal de la app - Negro profundo azulado
  static const Color background = Color(0xFF0B0F14);
  
  /// Superficie de cards, modals, sheets
  static const Color surface = Color(0xFF101824);
  
  /// Superficie elevada (para capas sobre surface)
  static const Color surfaceElevated = Color(0xFF162032);
  
  /// Borde sutil para separaciones
  static const Color surfaceBorder = Color(0xFF1E2A3D);
  
  // ═══════════════════════════════════════════════════════════════════
  // TEXTO
  // ═══════════════════════════════════════════════════════════════════
  
  /// Texto principal - Blanco azulado suave
  static const Color textPrimary = Color(0xFFEAF0FF);
  
  /// Texto secundario - Gris azulado
  static const Color textSecondary = Color(0xFF9AA7C0);
  
  /// Texto terciario/disabled - Gris más tenue
  static const Color textTertiary = Color(0xFF5C6B82);
  
  /// Texto sobre acentos de color
  static const Color textOnAccent = Color(0xFF0B0F14);
  
  // ═══════════════════════════════════════════════════════════════════
  // ACENTOS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Acento primario - Turquesa neón suave
  static const Color accent = Color(0xFF2EE9D8);
  
  /// Acento secundario - Morado vibrante
  static const Color accentPurple = Color(0xFF8B5CF6);
  
  /// Acento terciario - Lime (solo micro-detalles)
  static const Color accentLime = Color(0xFFA3E635);
  
  // ═══════════════════════════════════════════════════════════════════
  // ESTADOS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Estado de éxito
  static const Color success = Color(0xFF2EE9D8);
  
  /// Estado de warning
  static const Color warning = Color(0xFFFBBF24);
  
  /// Estado de error
  static const Color error = Color(0xFFEF4444);
  
  /// Estado de información
  static const Color info = Color(0xFF8B5CF6);
  
  // ═══════════════════════════════════════════════════════════════════
  // ALIASES (compatibilidad con código existente)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Alias: primary → accent
  static const Color primary = accent;
  
  /// Alias: secondary → accentPurple  
  static const Color secondary = accentPurple;
  
  /// Superficie más clara (para shimmer highlights)
  static const Color surfaceLight = Color(0xFF1A2536);
  
  /// Rating alto (verde lime)
  static const Color ratingHigh = accentLime;
  
  /// Rating medio (amarillo)
  static const Color ratingMedium = warning;
  
  /// Rating bajo (rojo)
  static const Color ratingLow = error;
  
  /// Texto sobre color secundario
  static const Color textOnSecondary = textOnAccent;
  
  // ═══════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════════════════════════════
  
  /// Gradiente principal turquesa → morado
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentPurple],
  );
  
  /// Gradiente morado → turquesa (invertido)
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accent],
  );
  
  /// Gradiente para overlays de posters
  static const LinearGradient gradientPosterOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x00000000),
      Color(0x80000000),
      Color(0xE6000000),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );
  
  /// Gradiente para featured banners
  static const LinearGradient gradientFeatured = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xF00B0F14),
      Color(0x800B0F14),
      Colors.transparent,
    ],
  );
  
  /// Gradiente glass effect
  static const LinearGradient gradientGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AEAF0FF),
      Color(0x08EAF0FF),
    ],
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // OPACIDADES ESTÁNDAR
  // ═══════════════════════════════════════════════════════════════════
  
  /// Opacidad para elementos hover
  static const double opacityHover = 0.08;
  
  /// Opacidad para elementos pressed
  static const double opacityPressed = 0.12;
  
  /// Opacidad para elementos disabled
  static const double opacityDisabled = 0.38;
  
  /// Opacidad para glass containers
  static const double opacityGlass = 0.06;
  
  /// Opacidad para borders sutiles
  static const double opacityBorder = 0.08;
  
  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Color con opacidad para overlays
  static Color overlay(double opacity) => Colors.black.withOpacity(opacity);
  
  /// Accent con opacidad
  static Color accentWith(double opacity) => accent.withOpacity(opacity);
  
  /// Purple con opacidad
  static Color purpleWith(double opacity) => accentPurple.withOpacity(opacity);
}
