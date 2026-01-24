import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_profile_data.dart';

/// Sección de preferencias de la app
class PreferencesSection extends StatelessWidget {
  final bool hideSpoilers;
  final String selectedRegion;
  final String selectedAppearance;
  final String selectedLanguage;
  final ValueChanged<bool> onSpoilersChanged;
  final VoidCallback onRegionTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback? onLanguageTap;

  const PreferencesSection({
    super.key,
    required this.hideSpoilers,
    required this.selectedRegion,
    required this.selectedAppearance,
    required this.selectedLanguage,
    required this.onSpoilersChanged,
    required this.onRegionTap,
    required this.onAppearanceTap,
    this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            l10n.strings.profileAppPreferences,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Hide spoilers toggle
          _PreferenceRowToggle(
            icon: CupertinoIcons.eye_slash,
            title: l10n.strings.profileHideSpoilers,
            value: hideSpoilers,
            onChanged: onSpoilersChanged,
          ),

          const SizedBox(height: 12),

          // Streaming region
          _PreferenceRowNavigation(
            icon: CupertinoIcons.globe,
            title: l10n.strings.profileStreamingRegion,
            value: selectedRegion,
            onTap: onRegionTap,
          ),

          const SizedBox(height: 12),

          // Appearance
          _PreferenceRowNavigation(
            icon: CupertinoIcons.moon,
            title: l10n.strings.profileAppearance,
            value: selectedAppearance,
            onTap: onAppearanceTap,
          ),

          if (onLanguageTap != null) ...[
            const SizedBox(height: 12),

            // Language
            _PreferenceRowNavigation(
              icon: CupertinoIcons.textformat,
              title: l10n.strings.profileLanguage,
              value: selectedLanguage,
              onTap: onLanguageTap!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Row de preferencia con toggle
class _PreferenceRowToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceRowToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colors.textSecondary,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),

          // Toggle
          CupertinoSwitch(
            value: value,
            activeTrackColor: colors.accent,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

/// Row de preferencia con navegación
class _PreferenceRowNavigation extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PreferenceRowNavigation({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colors.textSecondary,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),

            // Value
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.accent,
              ),
            ),

            const SizedBox(width: 8),

            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal de selección de región
class RegionSelectorModal extends StatelessWidget {
  final String selectedRegionCode;
  final ValueChanged<StreamingRegion> onRegionSelected;

  const RegionSelectorModal({
    super.key,
    required this.selectedRegionCode,
    required this.onRegionSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String selectedRegionCode,
    required ValueChanged<StreamingRegion> onRegionSelected,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => RegionSelectorModal(
        selectedRegionCode: selectedRegionCode,
        onRegionSelected: onRegionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.strings.profileSelectRegion,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),

          // Regions list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: availableRegions.length,
              itemBuilder: (context, index) {
                final region = availableRegions[index];
                final isSelected = region.code == selectedRegionCode;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onRegionSelected(region);
                    Navigator.pop(context);
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
                      children: [
                        Text(
                          region.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            region.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? colors.accent
                                  : colors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
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

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Modal de selección de apariencia
class AppearanceSelectorModal extends StatelessWidget {
  final String selectedAppearance;
  final ValueChanged<String> onAppearanceSelected;

  const AppearanceSelectorModal({
    super.key,
    required this.selectedAppearance,
    required this.onAppearanceSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String selectedAppearance,
    required ValueChanged<String> onAppearanceSelected,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => AppearanceSelectorModal(
        selectedAppearance: selectedAppearance,
        onAppearanceSelected: onAppearanceSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    final options = [
      (l10n.strings.profileDarkMode, Icons.dark_mode_outlined),
      (l10n.strings.profileLightMode, Icons.light_mode_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.strings.profileAppearance,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),

            // Options
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: options.map((option) {
                  final isSelected = option.$1 == selectedAppearance;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onAppearanceSelected(option.$1);
                      Navigator.pop(context);
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
                        children: [
                          Icon(
                            option.$2,
                            color: isSelected
                                ? colors.accent
                                : colors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option.$1,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected
                                    ? colors.accent
                                    : colors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
