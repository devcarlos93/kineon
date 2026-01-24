import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_profile_data.dart';

/// Card de Kineon Pro con pricing y features
class KineonProCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isUserPro;
  final VoidCallback? onUpgrade;
  final VoidCallback? onManageSubscription;

  const KineonProCard({
    super.key,
    required this.plan,
    this.isUserPro = false,
    this.onUpgrade,
    this.onManageSubscription,
  });

  @override
  State<KineonProCard> createState() => _KineonProCardState();
}

class _KineonProCardState extends State<KineonProCard> {
  BillingPeriod _selectedPeriod = BillingPeriod.monthly;

  double get _currentPrice {
    return _selectedPeriod == BillingPeriod.monthly
        ? widget.plan.monthlyPrice
        : widget.plan.annualPrice / 12;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.strings.profileKineonPro,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              // Premium badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'PREMIUM',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            l10n.strings.profileProSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Billing period toggle
          _BillingPeriodToggle(
            selectedPeriod: _selectedPeriod,
            annualDiscount: widget.plan.annualDiscount,
            onPeriodChanged: (period) {
              HapticFeedback.selectionClick();
              setState(() => _selectedPeriod = period);
            },
          ),

          const SizedBox(height: 20),

          // Features list (localized)
          _LocalizedFeatureRow(
            icon: CupertinoIcons.sparkles,
            title: l10n.strings.profileFeatureUnlimitedAI,
          ),
          _LocalizedFeatureRow(
            icon: CupertinoIcons.chat_bubble_2,
            title: l10n.strings.profileFeatureUnlimitedChat,
          ),
          _LocalizedFeatureRow(
            icon: CupertinoIcons.list_bullet,
            title: l10n.strings.profileFeatureUnlimitedLists,
          ),
          _LocalizedFeatureRow(
            icon: CupertinoIcons.checkmark_seal,
            title: l10n.strings.profileFeatureEarlyAccess,
          ),

          const SizedBox(height: 20),

          // CTA Button
          if (widget.isUserPro)
            _ManageSubscriptionButton(onTap: widget.onManageSubscription)
          else
            _UpgradeButton(
              price: _currentPrice,
              period: _selectedPeriod,
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onUpgrade?.call();
              },
            ),
        ],
      ),
    );
  }
}

/// Toggle de periodo de facturación
class _BillingPeriodToggle extends StatelessWidget {
  final BillingPeriod selectedPeriod;
  final int annualDiscount;
  final ValueChanged<BillingPeriod> onPeriodChanged;

  const _BillingPeriodToggle({
    required this.selectedPeriod,
    required this.annualDiscount,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Monthly
          Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(BillingPeriod.monthly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedPeriod == BillingPeriod.monthly
                      ? colors.surface
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: selectedPeriod == BillingPeriod.monthly
                      ? Border.all(color: colors.surfaceBorder)
                      : null,
                ),
                child: Center(
                  child: Text(
                    l10n.strings.profileMonthly,
                    style: AppTypography.labelMedium.copyWith(
                      color: selectedPeriod == BillingPeriod.monthly
                          ? colors.textPrimary
                          : colors.textTertiary,
                      fontWeight: selectedPeriod == BillingPeriod.monthly
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Annual
          Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(BillingPeriod.annual),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedPeriod == BillingPeriod.annual
                      ? colors.surface
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: selectedPeriod == BillingPeriod.annual
                      ? Border.all(color: colors.surfaceBorder)
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.strings.profileAnnual,
                        style: AppTypography.labelMedium.copyWith(
                          color: selectedPeriod == BillingPeriod.annual
                              ? colors.textPrimary
                              : colors.textTertiary,
                          fontWeight: selectedPeriod == BillingPeriod.annual
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '-$annualDiscount%',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.accent,
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
    );
  }
}

/// Row de feature
class _FeatureRow extends StatelessWidget {
  final ProFeature feature;

  const _FeatureRow({required this.feature});

  IconData get _icon {
    switch (feature.iconName) {
      case 'sparkles':
        return CupertinoIcons.sparkles;
      case 'cloud_download':
        return CupertinoIcons.cloud_download;
      case 'checkmark_seal':
        return CupertinoIcons.checkmark_seal;
      case 'list_bullet_rectangle':
        return CupertinoIcons.list_bullet;
      case 'calendar':
        return CupertinoIcons.calendar;
      case 'tv':
        return CupertinoIcons.tv;
      default:
        return CupertinoIcons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _icon,
              color: colors.accent,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.title,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row de feature con texto localizado
class _LocalizedFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _LocalizedFeatureRow({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colors.accent,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de upgrade
class _UpgradeButton extends StatelessWidget {
  final double price;
  final BillingPeriod period;
  final VoidCallback? onTap;

  const _UpgradeButton({
    required this.price,
    required this.period,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final periodText = period == BillingPeriod.monthly
        ? l10n.strings.profilePerMonth
        : l10n.strings.profilePerMonth;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            '${l10n.strings.profileUpgradeFor} \$${price.toStringAsFixed(2)} $periodText',
            style: AppTypography.labelLarge.copyWith(
              color: colors.textOnAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de gestionar suscripción
class _ManageSubscriptionButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ManageSubscriptionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Center(
          child: Text(
            l10n.strings.profileManageSubscription,
            style: AppTypography.labelLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card compacta de Pro para usuarios que ya son Pro
class KineonProStatusCard extends StatelessWidget {
  final DateTime? expiresAt;
  final VoidCallback? onManageTap;

  const KineonProStatusCard({
    super.key,
    this.expiresAt,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.15),
            colors.accentPurple.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Pro icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.star_fill,
              color: colors.textOnAccent,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.strings.profileProActive,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.strings.profileRenews} ${_formatDate(expiresAt!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Manage button
          GestureDetector(
            onTap: onManageTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Text(
                l10n.strings.profileManage,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
