import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show IconData;

/// Sistema de iconos Neo-cinema de Kineon
/// 
/// Usa CupertinoIcons como base (más elegantes que Material)
/// con iconos custom adicionales cuando necesario
abstract final class AppIcons {
  // ═══════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData home = CupertinoIcons.house_fill;
  static const IconData homeOutline = CupertinoIcons.house;
  
  static const IconData search = CupertinoIcons.search;
  static const IconData searchFill = CupertinoIcons.search_circle_fill;
  
  static const IconData ai = CupertinoIcons.sparkles;
  static const IconData aiFill = CupertinoIcons.wand_stars;
  
  static const IconData library = CupertinoIcons.square_stack_fill;
  static const IconData libraryOutline = CupertinoIcons.square_stack;
  
  static const IconData back = CupertinoIcons.chevron_back;
  static const IconData forward = CupertinoIcons.chevron_forward;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData menu = CupertinoIcons.line_horizontal_3;
  
  // ═══════════════════════════════════════════════════════════════════
  // ACCIONES DE CONTENIDO
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData play = CupertinoIcons.play_fill;
  static const IconData playCircle = CupertinoIcons.play_circle_fill;
  static const IconData pause = CupertinoIcons.pause_fill;
  
  static const IconData heart = CupertinoIcons.heart_fill;
  static const IconData heartOutline = CupertinoIcons.heart;
  
  static const IconData bookmark = CupertinoIcons.bookmark_fill;
  static const IconData bookmarkOutline = CupertinoIcons.bookmark;
  
  static const IconData checkCircle = CupertinoIcons.checkmark_circle_fill;
  static const IconData check = CupertinoIcons.checkmark;
  
  static const IconData star = CupertinoIcons.star_fill;
  static const IconData starOutline = CupertinoIcons.star;
  static const IconData starHalf = CupertinoIcons.star_lefthalf_fill;
  
  static const IconData share = CupertinoIcons.share;
  static const IconData more = CupertinoIcons.ellipsis;
  static const IconData moreCircle = CupertinoIcons.ellipsis_circle;
  
  // ═══════════════════════════════════════════════════════════════════
  // CONTENIDO
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData movie = CupertinoIcons.film;
  static const IconData tv = CupertinoIcons.tv;
  static const IconData person = CupertinoIcons.person_fill;
  static const IconData personOutline = CupertinoIcons.person;
  static const IconData people = CupertinoIcons.person_2_fill;
  
  static const IconData calendar = CupertinoIcons.calendar;
  static const IconData clock = CupertinoIcons.clock;
  static const IconData globe = CupertinoIcons.globe;
  
  static const IconData fire = CupertinoIcons.flame_fill;
  static const IconData trending = CupertinoIcons.chart_bar_fill;
  static const IconData sparkle = CupertinoIcons.sparkles;
  
  // ═══════════════════════════════════════════════════════════════════
  // LISTAS Y CATEGORÍAS
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData list = CupertinoIcons.list_bullet;
  static const IconData grid = CupertinoIcons.square_grid_2x2;
  static const IconData folder = CupertinoIcons.folder_fill;
  static const IconData folderOutline = CupertinoIcons.folder;
  static const IconData add = CupertinoIcons.plus;
  static const IconData addCircle = CupertinoIcons.plus_circle_fill;
  static const IconData minus = CupertinoIcons.minus;
  static const IconData trash = CupertinoIcons.trash;
  static const IconData edit = CupertinoIcons.pencil;
  
  // ═══════════════════════════════════════════════════════════════════
  // UI FEEDBACK
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData info = CupertinoIcons.info_circle_fill;
  static const IconData infoOutline = CupertinoIcons.info_circle;
  static const IconData warning = CupertinoIcons.exclamationmark_triangle_fill;
  static const IconData error = CupertinoIcons.xmark_circle_fill;
  static const IconData success = CupertinoIcons.checkmark_circle_fill;
  
  static const IconData refresh = CupertinoIcons.refresh;
  static const IconData settings = CupertinoIcons.gear;
  static const IconData filter = CupertinoIcons.slider_horizontal_3;
  static const IconData sort = CupertinoIcons.sort_down;
  
  // ═══════════════════════════════════════════════════════════════════
  // SOCIAL / AUTH
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData apple = IconData(0xF04BE, fontFamily: 'CupertinoIcons', fontPackage: 'cupertino_icons');
  
  // ═══════════════════════════════════════════════════════════════════
  // DIRECCIONES
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData up = CupertinoIcons.chevron_up;
  static const IconData down = CupertinoIcons.chevron_down;
  static const IconData left = CupertinoIcons.chevron_left;
  static const IconData right = CupertinoIcons.chevron_right;
  static const IconData expand = CupertinoIcons.arrow_up_left_arrow_down_right;
  static const IconData collapse = CupertinoIcons.arrow_down_right_arrow_up_left;
  
  // ═══════════════════════════════════════════════════════════════════
  // GÉNEROS (Custom - usando iconos más apropiados)
  // ═══════════════════════════════════════════════════════════════════
  
  static const IconData genreAction = CupertinoIcons.bolt_fill;
  static const IconData genreComedy = CupertinoIcons.smiley_fill;
  static const IconData genreDrama = CupertinoIcons.film;
  static const IconData genreHorror = CupertinoIcons.moon_fill;
  static const IconData genreSciFi = CupertinoIcons.rocket_fill;
  static const IconData genreRomance = CupertinoIcons.heart_fill;
  static const IconData genreAnimation = CupertinoIcons.paintbrush_fill;
  static const IconData genreDocumentary = CupertinoIcons.doc_text_fill;
  static const IconData genreThriller = CupertinoIcons.eye_fill;
  static const IconData genreFantasy = CupertinoIcons.wand_stars;
}

/// Tamaños estándar para iconos
abstract final class AppIconSizes {
  /// Extra pequeño - Badges, inline
  static const double xs = 14;
  
  /// Pequeño - Chips, labels
  static const double sm = 18;
  
  /// Medio - Botones, nav items
  static const double md = 22;
  
  /// Grande - Headers, destacados
  static const double lg = 28;
  
  /// Extra grande - Empty states, heroes
  static const double xl = 40;
  
  /// Gigante - Splash, ilustraciones
  static const double xxl = 64;
}
