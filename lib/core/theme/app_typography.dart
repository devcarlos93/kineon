import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema tipográfico Neo-cinema de Kineon
/// 
/// Fuentes:
/// - Títulos: Space Grotesk (geométrica, futurista)
/// - Cuerpo: Inter (legible, moderna)
abstract final class AppTypography {
  // ═══════════════════════════════════════════════════════════════════
  // FUENTES BASE
  // ═══════════════════════════════════════════════════════════════════
  
  static String get _fontDisplay => GoogleFonts.spaceGrotesk().fontFamily!;
  static String get _fontBody => GoogleFonts.inter().fontFamily!;
  
  // ═══════════════════════════════════════════════════════════════════
  // DISPLAY (Títulos grandes, heroes)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Display Large - Heroes, splash
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );
  
  /// Display Medium - Títulos principales
  static TextStyle get displayMedium => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.15,
    color: AppColors.textPrimary,
  );
  
  /// Display Small - Subtítulos grandes
  static TextStyle get displaySmall => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // HEADINGS (Secciones, cards)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Heading 1 - Títulos de sección
  static TextStyle get h1 => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimary,
  );
  
  /// Heading 2 - Subtítulos de sección
  static TextStyle get h2 => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  /// Heading 3 - Títulos de cards
  static TextStyle get h3 => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
    color: AppColors.textPrimary,
  );
  
  /// Heading 4 - Subtítulos de cards
  static TextStyle get h4 => TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // BODY (Texto de contenido)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Body Large - Descripciones principales
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Body Medium - Texto estándar
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  /// Body Small - Texto secundario
  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textSecondary,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // LABELS (UI elements)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Label Large - Botones principales
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  /// Label Medium - Chips, tabs
  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  /// Label Small - Badges, captions
  static TextStyle get labelSmall => TextStyle(
    fontFamily: _fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // ESPECIALES
  // ═══════════════════════════════════════════════════════════════════
  
  /// Overline - Categorías, etiquetas superiores
  static TextStyle get overline => TextStyle(
    fontFamily: _fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.2,
    color: AppColors.textSecondary,
  );
  
  /// Caption - Metadatos, timestamps
  static TextStyle get caption => TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
    color: AppColors.textTertiary,
  );
  
  /// Mono - Números, códigos
  static TextStyle get mono => TextStyle(
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // VARIANTES DE COLOR
  // ═══════════════════════════════════════════════════════════════════
  
  /// Texto secundario
  static TextStyle secondary(TextStyle style) => style.copyWith(
    color: AppColors.textSecondary,
  );
  
  /// Texto terciario
  static TextStyle tertiary(TextStyle style) => style.copyWith(
    color: AppColors.textTertiary,
  );
  
  /// Texto con acento turquesa
  static TextStyle accent(TextStyle style) => style.copyWith(
    color: AppColors.accent,
  );
  
  /// Texto con acento morado
  static TextStyle purple(TextStyle style) => style.copyWith(
    color: AppColors.accentPurple,
  );
}
