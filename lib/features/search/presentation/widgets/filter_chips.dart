import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_search_data.dart';

/// Row de filter chips con dropdowns
class FilterChipsRow extends StatelessWidget {
  final SearchFilter filter;
  final ValueChanged<SearchFilter> onFilterChanged;

  const FilterChipsRow({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Genre filter
          _FilterChip(
            label: l10n.strings.searchFilterGenre,
            value: filter.genre,
            isActive: filter.genre != null,
            onTap: () => _showGenreModal(context),
          ),

          const SizedBox(width: 10),

          // Mood filter
          _FilterChip(
            label: l10n.strings.searchFilterMood,
            value: filter.mood,
            isActive: filter.mood != null,
            onTap: () => _showMoodModal(context),
          ),

          const SizedBox(width: 10),

          // Runtime filter
          _FilterChip(
            label: l10n.strings.searchFilterRuntime,
            value: filter.maxRuntime != null ? '< ${filter.maxRuntime}m' : null,
            isActive: filter.maxRuntime != null,
            onTap: () => _showRuntimeModal(context),
          ),

          const SizedBox(width: 10),

          // Year filter
          _FilterChip(
            label: l10n.strings.searchFilterYear,
            value: filter.yearFrom != null ? '${filter.yearFrom}' : null,
            isActive: filter.yearFrom != null,
            onTap: () => _showYearModal(context),
          ),

          const SizedBox(width: 10),

          // Rating filter
          _FilterChip(
            label: l10n.strings.searchFilterRating,
            value: filter.minRating != null ? '${filter.minRating}+' : null,
            isActive: filter.minRating != null,
            onTap: () => _showRatingModal(context),
          ),
        ],
      ),
    );
  }

  void _showGenreModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterGenre,
        clearText: l10n.strings.searchClear,
        options: availableGenres,
        selectedValue: filter.genre,
        onSelect: (value) {
          onFilterChanged(filter.copyWith(genre: value, clearGenre: value == null));
          Navigator.pop(ctx);
        },
        onClear: () {
          onFilterChanged(filter.copyWith(clearGenre: true));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showMoodModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterMood,
        clearText: l10n.strings.searchClear,
        options: availableMoods,
        selectedValue: filter.mood,
        onSelect: (value) {
          onFilterChanged(filter.copyWith(mood: value, clearMood: value == null));
          Navigator.pop(ctx);
        },
        onClear: () {
          onFilterChanged(filter.copyWith(clearMood: true));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showRuntimeModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    final runtimes = ['60', '90', '120', '150', '180'];
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterMaxRuntime,
        clearText: l10n.strings.searchClear,
        options: runtimes.map((r) => '< $r min').toList(),
        selectedValue: filter.maxRuntime != null ? '< ${filter.maxRuntime} min' : null,
        onSelect: (value) {
          if (value != null) {
            final minutes = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
            onFilterChanged(filter.copyWith(maxRuntime: minutes));
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          onFilterChanged(filter.copyWith(clearRuntime: true));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showYearModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    final currentYear = DateTime.now().year;
    final years = List.generate(30, (i) => (currentYear - i).toString());
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterYear,
        clearText: l10n.strings.searchClear,
        options: years,
        selectedValue: filter.yearFrom?.toString(),
        onSelect: (value) {
          if (value != null) {
            onFilterChanged(filter.copyWith(yearFrom: int.parse(value)));
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          onFilterChanged(filter.copyWith(clearYear: true));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showRatingModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    final ratings = ['6.0', '7.0', '7.5', '8.0', '8.5', '9.0'];
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterMinRating,
        clearText: l10n.strings.searchClear,
        options: ratings.map((r) => '$r+').toList(),
        selectedValue: filter.minRating != null ? '${filter.minRating}+' : null,
        onSelect: (value) {
          if (value != null) {
            final rating = double.parse(value.replaceAll('+', ''));
            onFilterChanged(filter.copyWith(minRating: rating));
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          onFilterChanged(filter.copyWith(clearRating: true));
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// Chip individual de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colors.accent.withValues(alpha: 0.4)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? label,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? colors.accent : colors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_down,
              color: isActive ? colors.accent : colors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal de filtro con opciones
class _FilterModal extends StatelessWidget {
  final String title;
  final String clearText;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelect;
  final VoidCallback onClear;

  const _FilterModal({
    required this.title,
    required this.clearText,
    required this.options,
    this.selectedValue,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.h4,
                ),
                if (selectedValue != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onClear,
                    child: Text(
                      clearText,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == selectedValue;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(option);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.accent.withValues(alpha: 0.15)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colors.accent.withValues(alpha: 0.4)
                            : colors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? colors.accent
                                : colors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark,
                            color: colors.accent,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Skeleton de filter chips
class FilterChipsSkeleton extends StatelessWidget {
  const FilterChipsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(4, (index) {
          return Container(
            width: 90,
            height: 44,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }
}
