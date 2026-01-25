import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/services/revenue_cat_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de suscripción Pro con RevenueCat
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mostrar paywall de RevenueCat automáticamente al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRevenueCatPaywall();
    });
  }

  Future<void> _showRevenueCatPaywall() async {
    final result = await RevenueCatService().presentPaywall();

    if (!mounted) return;

    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      // Usuario compró o restauró - mostrar éxito y volver
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Bienvenido a Kineon Pro!'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (result == PaywallResult.cancelled) {
      // Usuario canceló - volver
      Navigator.of(context).pop(false);
    }
    // Si es error, se queda en la pantalla fallback
  }

  Future<void> _handleRestore() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final result = await RevenueCatService().restorePurchases();

      if (!mounted) return;

      final colors = context.colors;

      if (result.isPro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Compras restauradas con éxito!'),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
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
    final status = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: status.when(
        data: (sub) {
          if (sub.isPro) {
            return _ProStatusScreen(
              expirationDate: sub.expirationDate,
              managementUrl: sub.managementUrl,
              onManage: () async {
                // Mostrar Customer Center de RevenueCat
                await RevenueCatService().presentCustomerCenter();
              },
            );
          }
          return _FallbackPaywall(
            isLoading: _isLoading,
            onShowPaywall: _showRevenueCatPaywall,
            onRestore: _handleRestore,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _FallbackPaywall(
          isLoading: _isLoading,
          onShowPaywall: _showRevenueCatPaywall,
          onRestore: _handleRestore,
        ),
      ),
    );
  }
}

/// Paywall de fallback si el de RevenueCat no carga
class _FallbackPaywall extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onShowPaywall;
  final VoidCallback onRestore;

  const _FallbackPaywall({
    required this.isLoading,
    required this.onShowPaywall,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomScrollView(
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
                const SizedBox(height: 40),

                // Pro Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.star_fill,
                    color: colors.textOnAccent,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Kineon Pro',
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Desbloquea todo el poder de la IA para descubrir películas y series',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Features
                _FeatureItem(
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  title: 'Chat IA ilimitado',
                  subtitle: 'Pregunta lo que quieras sin límites',
                ),
                _FeatureItem(
                  icon: CupertinoIcons.search,
                  title: 'Búsqueda inteligente',
                  subtitle: 'Encuentra contenido con lenguaje natural',
                ),
                _FeatureItem(
                  icon: CupertinoIcons.sparkles,
                  title: 'Recomendaciones personalizadas',
                  subtitle: 'IA que aprende de tus gustos',
                ),
                _FeatureItem(
                  icon: CupertinoIcons.list_bullet,
                  title: 'Listas ilimitadas',
                  subtitle: 'Crea todas las listas que quieras',
                ),

                const SizedBox(height: 40),

                // Subscribe button
                GestureDetector(
                  onTap: isLoading ? null : onShowPaywall,
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
                              'Ver planes',
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.textOnAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Restore purchases
                GestureDetector(
                  onTap: isLoading ? null : onRestore,
                  child: Text(
                    'Restaurar compras',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Item de feature
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
              icon,
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
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
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
  }
}

/// Pantalla para usuarios que ya son Pro
class _ProStatusScreen extends StatelessWidget {
  final DateTime? expirationDate;
  final String? managementUrl;
  final VoidCallback onManage;

  const _ProStatusScreen({
    this.expirationDate,
    this.managementUrl,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: colors.background,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: colors.textOnAccent,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  '¡Eres Pro!',
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Tienes acceso a todas las funciones premium de Kineon',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (expirationDate != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Próxima renovación',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                _formatDate(expirationDate!),
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Manage subscription button
                GestureDetector(
                  onTap: onManage,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.surfaceBorder),
                    ),
                    child: Center(
                      child: Text(
                        'Gestionar suscripción',
                        style: AppTypography.labelLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
