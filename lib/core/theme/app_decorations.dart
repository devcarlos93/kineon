import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sistema de decoraciones Neo-cinema de Kineon
/// 
/// Incluye: radii, shadows, borders, efectos glass
abstract final class AppRadii {
  // ═══════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Extra small - Chips pequeños, badges
  static const double xs = 6;
  
  /// Small - Botones, inputs
  static const double sm = 10;
  
  /// Medium - Cards pequeñas
  static const double md = 14;
  
  /// Large - Cards principales
  static const double lg = 18;
  
  /// Extra large - Modals, sheets
  static const double xl = 24;
  
  /// 2XL - Containers hero
  static const double xxl = 32;
  
  /// Full - Circles, pills
  static const double full = 999;
  
  // ═══════════════════════════════════════════════════════════════════
  // BORDER RADIUS OBJECTS
  // ═══════════════════════════════════════════════════════════════════
  
  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
  
  /// Solo arriba
  static BorderRadius get topLg => const BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  
  static BorderRadius get topXl => const BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

abstract final class AppShadows {
  // ═══════════════════════════════════════════════════════════════════
  // SOMBRAS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Sin sombra
  static const List<BoxShadow> none = [];
  
  /// Sombra sutil - Cards base
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Sombra media - Cards hover
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Sombra grande - Modals, dropdowns
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Sombra extra grande - Sheets
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];
  
  /// Glow turquesa - Elementos destacados
  static List<BoxShadow> get glowAccent => [
    BoxShadow(
      color: AppColors.accent.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Glow morado - Elementos AI
  static List<BoxShadow> get glowPurple => [
    BoxShadow(
      color: AppColors.accentPurple.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Sombra interna sutil
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      blurStyle: BlurStyle.inner,
    ),
  ];
}

abstract final class AppBorders {
  // ═══════════════════════════════════════════════════════════════════
  // BORDES
  // ═══════════════════════════════════════════════════════════════════
  
  /// Borde sutil para separación
  static Border get subtle => Border.all(
    color: AppColors.surfaceBorder,
    width: 1,
  );
  
  /// Borde para glass containers
  static Border get glass => Border.all(
    color: AppColors.textPrimary.withOpacity(0.06),
    width: 1,
  );
  
  /// Borde para focus/selected
  static Border get focus => Border.all(
    color: AppColors.accent.withOpacity(0.5),
    width: 1.5,
  );
  
  /// Borde para hover
  static Border get hover => Border.all(
    color: AppColors.textPrimary.withOpacity(0.1),
    width: 1,
  );
  
  /// Borde inferior fino
  static Border get bottomThin => const Border(
    bottom: BorderSide(
      color: AppColors.surfaceBorder,
      width: 0.5,
    ),
  );
}

abstract final class AppEffects {
  // ═══════════════════════════════════════════════════════════════════
  // BLUR / GLASS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Blur suave para glass effect
  static ImageFilter get blurSm => ImageFilter.blur(sigmaX: 8, sigmaY: 8);
  
  /// Blur medio para overlays
  static ImageFilter get blurMd => ImageFilter.blur(sigmaX: 16, sigmaY: 16);
  
  /// Blur fuerte para modals
  static ImageFilter get blurLg => ImageFilter.blur(sigmaX: 24, sigmaY: 24);
  
  // ═══════════════════════════════════════════════════════════════════
  // DECORACIONES COMPUESTAS
  // ═══════════════════════════════════════════════════════════════════
  
  /// Decoración base para cards
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadii.radiusLg,
    border: AppBorders.subtle,
  );
  
  /// Decoración glass
  static BoxDecoration get glassDecoration => BoxDecoration(
    gradient: AppColors.gradientGlass,
    borderRadius: AppRadii.radiusLg,
    border: AppBorders.glass,
  );
  
  /// Decoración para surface elevada
  static BoxDecoration get elevatedDecoration => BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: AppRadii.radiusLg,
    boxShadow: AppShadows.md,
  );
  
  /// Decoración para modals/sheets
  static BoxDecoration get sheetDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    boxShadow: AppShadows.xl,
  );
  
  /// Decoración para input fields
  static BoxDecoration inputDecoration({bool focused = false}) => BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: AppRadii.radiusMd,
    border: focused ? AppBorders.focus : AppBorders.subtle,
  );
}

// ═══════════════════════════════════════════════════════════════════
// SPACING SYSTEM
// ═══════════════════════════════════════════════════════════════════

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  
  /// Padding horizontal de pantalla
  static const double screenH = 20;
  
  /// Padding vertical de sección
  static const double sectionV = 24;
}

// ═══════════════════════════════════════════════════════════════════
// ANIMATION DURATIONS
// ═══════════════════════════════════════════════════════════════════

abstract final class AppDurations {
  /// Micro-interacciones (hover, tap feedback)
  static const Duration instant = Duration(milliseconds: 100);
  
  /// Transiciones rápidas (chips, toggles)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Transiciones estándar (cards, modals)
  static const Duration normal = Duration(milliseconds: 250);
  
  /// Transiciones suaves (page transitions)
  static const Duration slow = Duration(milliseconds: 350);
  
  /// Animaciones elaboradas (onboarding, empty states)
  static const Duration slower = Duration(milliseconds: 500);
}

abstract final class AppCurves {
  /// Curva estándar para la mayoría de animaciones
  static const Curve standard = Curves.easeOutCubic;
  
  /// Curva para entradas (fade in, slide in)
  static const Curve enter = Curves.easeOut;
  
  /// Curva para salidas (fade out, slide out)
  static const Curve exit = Curves.easeIn;
  
  /// Curva con rebote suave
  static const Curve bounce = Curves.easeOutBack;
  
  /// Curva para elementos que se expanden
  static const Curve expand = Curves.fastOutSlowIn;
}
