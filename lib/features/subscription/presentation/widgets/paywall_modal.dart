import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subscription_state.dart';

/// Modal de Paywall cuando el usuario llega al límite
class PaywallModal extends ConsumerWidget {
  final String endpoint;
  final VoidCallback? onUpgrade;
  final VoidCallback? onClose;

  const PaywallModal({
    super.key,
    required this.endpoint,
    this.onUpgrade,
    this.onClose,
  });

  /// Muestra el modal de paywall
  static Future<bool?> show(
    BuildContext context, {
    required String endpoint,
    VoidCallback? onUpgrade,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallModal(
        endpoint: endpoint,
        onUpgrade: onUpgrade,
      ),
    );
  }

  String _getFeatureName(AppStrings strings) {
    switch (endpoint) {
      case AIEndpoints.chat:
        return strings.paywallFeatureAIChat;
      case AIEndpoints.search:
        return strings.paywallFeatureAISearch;
      case AIEndpoints.insight:
        return strings.paywallFeatureAIInsight;
      case AIEndpoints.picks:
        return strings.paywallFeatureAIPicks;
      default:
        return 'IA';
    }
  }

  int get _dailyLimit {
    switch (endpoint) {
      case AIEndpoints.chat:
        return 4;
      case AIEndpoints.picks:
        return 5;
      case AIEndpoints.search:
        return 6;
      case AIEndpoints.insight:
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.accent.withValues(alpha: 0.2),
                      colors.accentPurple.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.accent,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                l10n.strings.paywallTitle,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                l10n.strings.paywallDescription(_dailyLimit, _getFeatureName(l10n.strings)),
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Pro features preview
              _ProFeaturesPreview(l10n: l10n),

              const SizedBox(height: 24),

              // Upgrade button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                  onUpgrade?.call();
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: colors.textOnAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.strings.paywallUpgrade,
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

              const SizedBox(height: 12),

              // Maybe later button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                  onClose?.call();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.surfaceBorder),
                  ),
                  child: Center(
                    child: Text(
                      l10n.strings.paywallComeback,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reset time info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.strings.paywallResetTime,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Preview de features Pro
class _ProFeaturesPreview extends StatelessWidget {
  final AppLocalizations l10n;

  const _ProFeaturesPreview({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final features = [
      (l10n.strings.paywallFeatureChat, Icons.chat_bubble_outline_rounded),
      (l10n.strings.paywallFeatureSearch, Icons.search_rounded),
      (l10n.strings.paywallFeatureRecommendations, Icons.auto_awesome_rounded),
      (l10n.strings.paywallFeatureLists, Icons.playlist_add_rounded),
      (l10n.strings.paywallFeatureEarlyAccess, Icons.rocket_launch_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PRO',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textOnAccent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.strings.paywallProIncludes,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: colors.success,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      f.$1,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Widget de contador de uso restante
class AIUsageCounter extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isPro;
  final VoidCallback? onUpgradeTap;

  const AIUsageCounter({
    super.key,
    required this.remaining,
    required this.total,
    this.isPro = false,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (isPro) {
      return _ProBadge(onTap: onUpgradeTap);
    }

    final isLow = remaining <= 1;

    return GestureDetector(
      onTap: onUpgradeTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isLow
              ? colors.warning.withValues(alpha: 0.15)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLow
                ? colors.warning.withValues(alpha: 0.3)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: isLow ? colors.warning : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '$remaining/$total',
              style: AppTypography.labelSmall.copyWith(
                color: isLow ? colors.warning : colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de Pro
class _ProBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const _ProBadge({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 14,
              color: colors.textOnAccent,
            ),
            const SizedBox(width: 4),
            Text(
              'PRO',
              style: AppTypography.labelSmall.copyWith(
                color: colors.textOnAccent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de "Upgrade to Pro" para mostrar en headers
class UpgradeProBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const UpgradeProBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: colors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              'Pro',
              style: AppTypography.labelSmall.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
