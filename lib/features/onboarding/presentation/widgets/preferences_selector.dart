import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/user_preferences.dart';
import '../providers/onboarding_preferences_provider.dart';

/// Selector de preferencias del onboarding
///
/// Permite seleccionar géneros y escribir un mood preferido
class PreferencesSelector extends ConsumerStatefulWidget {
  final bool isActive;

  const PreferencesSelector({super.key, this.isActive = false});

  @override
  ConsumerState<PreferencesSelector> createState() => _PreferencesSelectorState();
}

class _PreferencesSelectorState extends ConsumerState<PreferencesSelector> {
  final TextEditingController _moodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sincronizar el controller con el estado del provider
    final currentMood = ref.read(onboardingPreferencesProvider).moodText;
    _moodController.text = currentMood;
    _moodController.addListener(_onMoodChanged);
  }

  @override
  void dispose() {
    _moodController.removeListener(_onMoodChanged);
    _moodController.dispose();
    super.dispose();
  }

  void _onMoodChanged() {
    ref.read(onboardingPreferencesProvider.notifier).setMoodText(_moodController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final prefsState = ref.watch(onboardingPreferencesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════
          // TÍTULO
          // ═══════════════════════════════════════════════════════════
          if (widget.isActive) ...[
            Text(
              l10n.prefsTellUs,
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

            Text(
              l10n.prefsYourPreferences,
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.accent,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            Text(
              l10n.prefsSelectDescription,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          ] else ...[
            Text(
              l10n.prefsTellUs,
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.prefsYourPreferences,
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.prefsSelectDescription,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // ═══════════════════════════════════════════════════════════
          // GÉNEROS
          // ═══════════════════════════════════════════════════════════
          _buildSection(
            title: l10n.prefsFavoriteGenres,
            delay: 300,
            child: _buildGenreChips(context, prefsState.selectedGenres),
          ),

          const SizedBox(height: 28),

          // ═══════════════════════════════════════════════════════════
          // MOODS (Input field)
          // ═══════════════════════════════════════════════════════════
          _buildSection(
            title: l10n.prefsMoodQuestion,
            delay: 400,
            child: _buildMoodInput(context, l10n),
          ),

          const SizedBox(height: 100), // Espacio para el footer
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int delay,
    required Widget child,
  }) {
    final colors = context.colors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: colors.textSecondary,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );

    if (widget.isActive) {
      return content.animate().fadeIn(delay: delay.ms, duration: 400.ms).slideY(begin: 0.1);
    }
    return content;
  }

  Widget _buildGenreChips(BuildContext context, Set<Genre> selectedGenres) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: Genre.values.map((genre) {
        final isSelected = selectedGenres.contains(genre);
        return _PreferenceChip(
          label: genre.getLocalizedName(context),
          isSelected: isSelected,
          onTap: () {
            ref.read(onboardingPreferencesProvider.notifier).toggleGenre(genre);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMoodInput(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.surfaceBorder,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _moodController,
        style: AppTypography.bodyMedium.copyWith(
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.prefsMoodHint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: colors.textTertiary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Chip de preferencia seleccionable
class _PreferenceChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PreferenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PreferenceChip> createState() => _PreferenceChipState();
}

class _PreferenceChipState extends State<_PreferenceChip> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? colors.accent.withOpacity(0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? colors.accent
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          widget.label,
          style: AppTypography.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET EXPORTABLE: KineonChips
// ═══════════════════════════════════════════════════════════════════════════

/// Grupo de chips seleccionables reutilizable
class KineonChips extends StatelessWidget {
  final List<String> labels;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final double spacing;
  final double runSpacing;

  const KineonChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onToggle,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: labels.map((label) {
        final isSelected = selected.contains(label);
        return _PreferenceChip(
          label: label,
          isSelected: isSelected,
          onTap: () => onToggle(label),
        );
      }).toList(),
    );
  }
}
