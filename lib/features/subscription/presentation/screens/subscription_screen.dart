import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subscription_state.dart';
import '../providers/subscription_provider.dart';

/// Pantalla de suscripción Pro
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearly = true;
  bool _isLoading = false;

  // Precios (estos vendrían de RevenueCat/StoreKit en producción)
  static const _monthlyPrice = 2.99;
  static const _yearlyPrice = 24.99;
  static const _yearlyMonthly = _yearlyPrice / 12;
  static const _savingsPercent = 30;

  Future<void> _handlePurchase() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      // TODO: Integrar RevenueCat o StoreKit
      // Por ahora simulamos la compra
      await Future.delayed(const Duration(seconds: 2));

      // Simular activación Pro
      ref.read(subscriptionProvider.notifier).setPro(
            expiresAt: DateTime.now().add(
              _isYearly ? const Duration(days: 365) : const Duration(days: 30),
            ),
            provider: 'apple', // o 'google'
            productId: _isYearly ? 'pro_yearly' : 'pro_monthly',
          );

      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Bienvenido a Kineon Pro!'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      // TODO: Integrar RestorePurchases de RevenueCat/StoreKit
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron compras anteriores'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: colors.background,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.xmark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            pinned: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Pro Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.star_fill,
                      color: colors.textOnAccent,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Kineon Pro',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Desbloquea todo el poder de la IA',
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features
                  _FeaturesList(),

                  const SizedBox(height: 32),

                  // Plan selector
                  if (!subscription.isPro) ...[
                    _PlanSelector(
                      isYearly: _isYearly,
                      onChanged: (yearly) {
                        HapticFeedback.selectionClick();
                        setState(() => _isYearly = yearly);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Price display
                    _PriceDisplay(
                      isYearly: _isYearly,
                      monthlyPrice: _monthlyPrice,
                      yearlyPrice: _yearlyPrice,
                      yearlyMonthly: _yearlyMonthly,
                    ),

                    const SizedBox(height: 24),

                    // Subscribe button
                    _SubscribeButton(
                      isLoading: _isLoading,
                      onTap: _handlePurchase,
                    ),

                    const SizedBox(height: 16),

                    // Restore purchases
                    GestureDetector(
                      onTap: _isLoading ? null : _handleRestore,
                      child: Text(
                        'Restaurar compras',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Legal text
                    Text(
                      'La suscripcion se renueva automaticamente. '
                      'Puedes cancelar en cualquier momento desde la App Store.',
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    // Pro status card
                    _ProStatusCard(subscription: subscription),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de features Pro
class _FeaturesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final features = [
      (
        'Chat IA ilimitado',
        'Pregunta lo que quieras sin límites',
        CupertinoIcons.chat_bubble_2_fill
      ),
      (
        'Búsqueda inteligente',
        'Encuentra películas con lenguaje natural',
        CupertinoIcons.search
      ),
      (
        'Insights exclusivos',
        'Análisis profundos de cada película',
        CupertinoIcons.lightbulb_fill
      ),
      (
        'Recomendaciones personalizadas',
        'IA que aprende de tus gustos',
        CupertinoIcons.sparkles
      ),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  f.$3,
                  color: colors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.$1,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      f.$2,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: colors.success,
                size: 22,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Selector de plan mensual/anual
class _PlanSelector extends StatelessWidget {
  final bool isYearly;
  final ValueChanged<bool> onChanged;

  const _PlanSelector({
    required this.isYearly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isYearly ? colors.surface : null,
                  borderRadius: BorderRadius.circular(10),
                  border: !isYearly
                      ? Border.all(color: colors.surfaceBorder)
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Mensual',
                    style: AppTypography.labelMedium.copyWith(
                      color: !isYearly
                          ? colors.textPrimary
                          : colors.textTertiary,
                      fontWeight:
                          !isYearly ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isYearly ? colors.surface : null,
                  borderRadius: BorderRadius.circular(10),
                  border: isYearly
                      ? Border.all(color: colors.accent.withValues(alpha: 0.5))
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Anual',
                        style: AppTypography.labelMedium.copyWith(
                          color: isYearly
                              ? colors.textPrimary
                              : colors.textTertiary,
                          fontWeight:
                              isYearly ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-33%',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.w600,
                          ),
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

/// Display de precio
class _PriceDisplay extends StatelessWidget {
  final bool isYearly;
  final double monthlyPrice;
  final double yearlyPrice;
  final double yearlyMonthly;

  const _PriceDisplay({
    required this.isYearly,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlyMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$',
              style: AppTypography.h3.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              isYearly
                  ? yearlyMonthly.toStringAsFixed(2)
                  : monthlyPrice.toStringAsFixed(2),
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/mes',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        if (isYearly) ...[
          const SizedBox(height: 4),
          Text(
            'Facturado anualmente (\$${yearlyPrice.toStringAsFixed(2)}/año)',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Botón de suscribirse
class _SubscribeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SubscribeButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.gradientPrimary,
          color: isLoading ? colors.surfaceElevated : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                )
              : Text(
                  'Comenzar prueba gratis',
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

/// Card de estado Pro para usuarios ya suscritos
class _ProStatusCard extends StatelessWidget {
  final UserSubscription subscription;

  const _ProStatusCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.15),
            colors.accentPurple.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: colors.textOnAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Eres Pro!',
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subscription.expiresAt != null)
                      Text(
                        'Se renueva el ${_formatDate(subscription.expiresAt!)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Center(
              child: Text(
                'Gestionar suscripción',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.textPrimary,
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
