import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../providers/subscription_provider.dart';

/// Modal de paywall positivo - se muestra después de momentos de entusiasmo,
/// no de frustración. Tono diferente al PaywallModal estándar.
class SmartPaywallModal extends ConsumerWidget {
  final String trigger;

  const SmartPaywallModal({super.key, required this.trigger});

  /// Muestra el smart paywall si aplica (free user, no mostrado antes para este trigger)
  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref, {
    required String trigger,
  }) async {
    final subscription = ref.read(subscriptionProvider);
    if (subscription.isPro) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'smart_paywall_shown_$trigger';

    // Solo mostrar una vez por trigger
    if (prefs.getBool(key) == true) return;

    // Marcar como mostrado
    await prefs.setBool(key, true);

    // Pequeño delay para que el usuario disfrute el momento
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!context.mounted) return;

    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartPaywallModal(trigger: trigger),
    );
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

              const SizedBox(height: 28),

              // Kino excited
              const KinoMascot(size: 72, mood: KinoMood.excited),

              const SizedBox(height: 20),

              // Título positivo
              Text(
                l10n.smartPaywallTitle,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                l10n.smartPaywallSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // CTA principal - "Probar Pro gratis"
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  context.push('/profile/subscription');
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
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
                          l10n.smartPaywallCta,
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

              const SizedBox(height: 8),

              // Hint de trial
              Text(
                l10n.smartPaywallTrialHint,
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),

              const SizedBox(height: 12),

              // Dismiss
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.smartPaywallDismiss,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Triggers predefinidos para el smart paywall
class SmartPaywallTriggers {
  static const firstAiChat = 'first_ai_chat';
  static const firstAiPick = 'first_ai_pick_viewed';
  static const firstSearch = 'first_ai_search';
  static const secondList = 'second_list_created';
}
