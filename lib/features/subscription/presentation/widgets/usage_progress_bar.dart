import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subscription_state.dart';
import '../providers/subscription_provider.dart';

/// Barra compacta de uso de créditos IA para el Home.
/// Muestra el uso agregado de todos los endpoints de IA.
/// Siempre visible para free users, badge PRO para pro users.
class UsageProgressBar extends ConsumerWidget {
  const UsageProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    // Pro users: mostrar badge compacto
    if (subscription.isPro) {
      return _ProActiveBadge(colors: colors);
    }

    // Free users: calcular uso agregado
    final endpoints = [
      AIEndpoints.chat,
      AIEndpoints.search,
      AIEndpoints.insight,
      AIEndpoints.picks,
    ];

    int totalUsed = 0;
    int totalLimit = 0;

    for (final ep in endpoints) {
      final usage = subscription.getUsage(ep);
      totalUsed += usage.usedToday;
      totalLimit += usage.dailyLimit;
    }

    final remaining = (totalLimit - totalUsed).clamp(0, totalLimit);
    final progress = totalLimit > 0 ? totalUsed / totalLimit : 0.0;
    final isLow = remaining <= 4;
    final isExhausted = remaining <= 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/profile/subscription');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExhausted
                ? colors.error.withValues(alpha: 0.3)
                : isLow
                    ? colors.warning.withValues(alpha: 0.3)
                    : colors.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: label + count + CTA
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: isExhausted
                      ? colors.error
                      : isLow
                          ? colors.warning
                          : colors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.usageAiCredits,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.usageRemaining(remaining, totalLimit),
                  style: AppTypography.labelSmall.copyWith(
                    color: isExhausted
                        ? colors.error
                        : isLow
                            ? colors.warning
                            : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                // Upgrade arrow
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: colors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: colors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExhausted
                      ? colors.error
                      : isLow
                          ? colors.warning
                          : colors.accent,
                ),
              ),
            ),

            // CTA text when low
            if (isLow) ...[
              const SizedBox(height: 6),
              Text(
                l10n.usageUpgradeCta,
                style: AppTypography.caption.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge compacto para usuarios Pro activos
class _ProActiveBadge extends StatelessWidget {
  final KineonColors colors;

  const _ProActiveBadge({required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.accentPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.all_inclusive_rounded,
            size: 16,
            color: colors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.usageUnlimited,
            style: AppTypography.labelSmall.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
