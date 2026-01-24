import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/data/services/profile_service.dart';
import '../../../onboarding/domain/models/user_preferences.dart';

/// Enum de generos con sus IDs de TMDB
enum Genre {
  action(28, Icons.local_fire_department),
  comedy(35, Icons.sentiment_very_satisfied),
  drama(18, Icons.theater_comedy),
  sciFi(878, Icons.rocket_launch),
  horror(27, Icons.psychology_alt),
  romance(10749, Icons.favorite),
  thriller(53, Icons.bolt),
  animation(16, Icons.animation),
  documentary(99, Icons.movie_filter),
  fantasy(14, Icons.auto_awesome);

  final int tmdbId;
  final IconData icon;

  const Genre(this.tmdbId, this.icon);

  /// Obtener label localizado
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case Genre.action:
        return l10n.genreAction;
      case Genre.comedy:
        return l10n.genreComedy;
      case Genre.drama:
        return l10n.genreDrama;
      case Genre.sciFi:
        return l10n.genreSciFi;
      case Genre.horror:
        return l10n.genreHorror;
      case Genre.romance:
        return l10n.genreRomance;
      case Genre.thriller:
        return l10n.genreThriller;
      case Genre.animation:
        return l10n.genreAnimation;
      case Genre.documentary:
        return l10n.genreDocumentary;
      case Genre.fantasy:
        return l10n.genreFantasy;
    }
  }

  /// Obtener genero por ID de TMDB
  static Genre? fromTmdbId(int id) {
    try {
      return Genre.values.firstWhere((g) => g.tmdbId == id);
    } catch (_) {
      return null;
    }
  }
}

/// Bottom sheet para ajustar preferencias rapidamente
///
/// Permite al usuario cambiar su mood y generos favoritos
/// sin salir del Home.
class QuickPreferencesSheet extends ConsumerStatefulWidget {
  final List<int> initialGenres;
  final String initialMood;
  final Future<void> Function()? onSaved;

  const QuickPreferencesSheet({
    super.key,
    this.initialGenres = const [],
    this.initialMood = '',
    this.onSaved,
  });

  /// Muestra el bottom sheet
  static Future<void> show(
    BuildContext context, {
    List<int> initialGenres = const [],
    String initialMood = '',
    Future<void> Function()? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickPreferencesSheet(
        initialGenres: initialGenres,
        initialMood: initialMood,
        onSaved: onSaved,
      ),
    );
  }

  @override
  ConsumerState<QuickPreferencesSheet> createState() =>
      _QuickPreferencesSheetState();
}

class _QuickPreferencesSheetState extends ConsumerState<QuickPreferencesSheet> {
  late Set<Genre> _selectedGenres;
  late TextEditingController _moodController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar generos seleccionados desde IDs
    _selectedGenres = widget.initialGenres
        .map((id) => Genre.fromTmdbId(id))
        .whereType<Genre>()
        .toSet();
    _moodController = TextEditingController(text: widget.initialMood);
  }

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  void _toggleGenre(Genre genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final profileService = ref.read(profileServiceProvider);

      final preferences = UserPreferences(
        preferredGenres: _selectedGenres.map((g) => g.tmdbId).toList(),
        moodText: _moodController.text.trim(),
        onboardingCompleted: true,
      );

      await profileService.savePreferences(preferences);

      // Capturar el callback antes de cerrar
      final onSavedCallback = widget.onSaved;

      if (mounted) {
        Navigator.of(context).pop();
      }

      // Llamar el callback DESPUES de cerrar (ejecuta en el contexto de HomeScreen)
      // Usar Future.microtask para asegurar que se ejecuta después del pop
      Future.microtask(() async {
        await onSavedCallback?.call();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: context.colors.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colors.textOnAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickPrefsTitle,
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.quickPrefsSubtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Mood input
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quickPrefsMoodLabel,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _moodController,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyMedium.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                      cursorColor: colors.accent,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: l10n.quickPrefsMoodHint,
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.bodyMedium.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colors.textTertiary,
                        ),
                        filled: true,
                        fillColor: colors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.surfaceBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.accent),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),

              // Genres
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.quickPrefsGenresLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Genre chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Genre.values.map((genre) {
                    final isSelected = _selectedGenres.contains(genre);
                    return _GenreChip(
                      genre: genre,
                      label: genre.getLabel(l10n),
                      isSelected: isSelected,
                      onTap: () => _toggleGenre(genre),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.surfaceBorder),
                          ),
                          child: Center(
                            child: Text(
                              l10n.quickPrefsCancel,
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _savePreferences,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colors.accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.textOnAccent,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        color: colors.textOnAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.quickPrefsSave,
                                        style: AppTypography.labelLarge.copyWith(
                                          color: colors.textOnAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de genero seleccionable
class _GenreChip extends StatelessWidget {
  final Genre genre;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.genre,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradientPrimary : null,
          color: isSelected ? null : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: colors.surfaceBorder),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              genre.icon,
              size: 16,
              color: isSelected
                  ? colors.textOnAccent
                  : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? colors.textOnAccent
                    : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
