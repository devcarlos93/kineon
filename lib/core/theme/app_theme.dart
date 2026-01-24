import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_decorations.dart';
import 'kineon_colors.dart';

// Re-export para conveniencia
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_decorations.dart';
export 'app_icons.dart';
export 'kineon_colors.dart';

/// Tema Neo-cinema de Kineon
/// 
/// NO usa Material 3 - Diseño custom premium
abstract final class AppTheme {
  /// Tema oscuro principal (único tema de la app)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false, // ¡IMPORTANTE! NO Material 3
      brightness: Brightness.dark,
      
      // ═══════════════════════════════════════════════════════════════
      // COLORES BASE
      // ═══════════════════════════════════════════════════════════════
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      dividerColor: AppColors.surfaceBorder,
      hintColor: AppColors.textTertiary,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentLime,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnAccent,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
        outline: AppColors.surfaceBorder,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // TIPOGRAFÍA
      // ═══════════════════════════════════════════════════════════════
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h2,
        titleMedium: AppTypography.h3,
        titleSmall: AppTypography.h4,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // APP BAR
      // ═══════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.h2,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // BOTTOM NAV (aunque usamos custom)
      // ═══════════════════════════════════════════════════════════════
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // CARDS
      // ═══════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // DIALOGS
      // ═══════════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusXl,
        ),
        titleTextStyle: AppTypography.h2,
        contentTextStyle: AppTypography.bodyMedium,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // BOTTOM SHEET
      // ═══════════════════════════════════════════════════════════════
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.textTertiary,
        dragHandleSize: const Size(36, 4),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // INPUTS
      // ═══════════════════════════════════════════════════════════════
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: BorderSide(
            color: AppColors.accent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // ELEVATED BUTTONS (fallback, preferir KineonButton)
      // ═══════════════════════════════════════════════════════════════
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.radiusMd,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // TEXT BUTTONS
      // ═══════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.radiusSm,
          ),
          textStyle: AppTypography.labelMedium,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // OUTLINED BUTTONS
      // ═══════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.radiusMd,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // ICON BUTTONS
      // ═══════════════════════════════════════════════════════════════
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          highlightColor: AppColors.textPrimary.withOpacity(0.08),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // CHIPS (fallback, preferir KineonChip)
      // ═══════════════════════════════════════════════════════════════
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.accent.withOpacity(0.15),
        disabledColor: AppColors.surface,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusFull,
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // DIVIDERS
      // ═══════════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 0.5,
        space: 1,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // SCROLLBAR
      // ═══════════════════════════════════════════════════════════════
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.textTertiary.withOpacity(0.5),
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(4),
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // PROGRESS INDICATORS
      // ═══════════════════════════════════════════════════════════════
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.surfaceElevated,
        circularTrackColor: AppColors.surfaceElevated,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // SNACKBAR
      // ═══════════════════════════════════════════════════════════════
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // TABS
      // ═══════════════════════════════════════════════════════════════
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // SPLASH / RIPPLE
      // ═══════════════════════════════════════════════════════════════
      splashColor: AppColors.accent.withOpacity(0.1),
      highlightColor: AppColors.textPrimary.withOpacity(0.05),
      splashFactory: InkSparkle.splashFactory,

      // ═══════════════════════════════════════════════════════════════
      // KINEON COLORS EXTENSION
      // ═══════════════════════════════════════════════════════════════
      extensions: const [KineonColors.dark],
    );
  }

  /// Tema claro
  static ThemeData get lightTheme {
    // Colores para tema claro
    const background = Color(0xFFF5F7FA);
    const surface = Color(0xFFFFFFFF);
    const surfaceElevated = Color(0xFFF0F2F5);
    const surfaceBorder = Color(0xFFE0E4EA);
    const textPrimary = Color(0xFF1A1D24);
    const textSecondary = Color(0xFF5C6370);
    const textTertiary = Color(0xFF9CA3AF);

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,

      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: surfaceBorder,
      hintColor: textTertiary,

      colorScheme: ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentLime,
        surface: surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnAccent,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
        outline: surfaceBorder,
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: textPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: textPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: textPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: textPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: textPrimary),
        titleLarge: AppTypography.h2.copyWith(color: textPrimary),
        titleMedium: AppTypography.h3.copyWith(color: textPrimary),
        titleSmall: AppTypography.h4.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: textPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: textSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: textTertiary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h2.copyWith(color: textPrimary),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
          side: BorderSide(color: surfaceBorder),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        labelStyle: AppTypography.labelMedium.copyWith(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.radiusMd,
          borderSide: BorderSide(
            color: AppColors.accent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.radiusMd,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: AppColors.accent.withOpacity(0.15),
        disabledColor: surface,
        labelStyle: AppTypography.labelMedium.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusFull,
          side: BorderSide(color: surfaceBorder),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: surfaceBorder,
        thickness: 0.5,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: surfaceElevated,
        circularTrackColor: surfaceElevated,
      ),

      splashColor: AppColors.accent.withOpacity(0.1),
      highlightColor: textPrimary.withOpacity(0.05),
      splashFactory: InkSparkle.splashFactory,

      // ═══════════════════════════════════════════════════════════════
      // KINEON COLORS EXTENSION
      // ═══════════════════════════════════════════════════════════════
      extensions: const [KineonColors.light],
    );
  }
}
