import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/subscription_provider.dart';
import '../widgets/paywall_modal.dart';

/// Helper para verificar y gatear features de IA
class GatingHelper {
  /// Verifica si puede usar una feature. Si no puede, muestra paywall.
  ///
  /// Retorna true si puede continuar, false si está bloqueado.
  ///
  /// Uso:
  /// ```dart
  /// if (!await GatingHelper.checkAndGate(context, ref, AIEndpoints.chat)) {
  ///   return; // Usuario bloqueado, paywall mostrado
  /// }
  /// // Continuar con la feature
  /// ```
  static Future<bool> checkAndGate(
    BuildContext context,
    WidgetRef ref,
    String endpoint,
  ) async {
    final subscription = ref.read(subscriptionProvider);

    // Si es Pro, siempre permitir
    if (subscription.isPro) {
      return true;
    }

    // Verificar límite
    final notifier = ref.read(subscriptionProvider.notifier);
    final result = await notifier.checkCanUse(endpoint);

    if (result.canUse) {
      return true;
    }

    // Mostrar paywall
    if (context.mounted) {
      await PaywallModal.show(
        context,
        endpoint: endpoint,
        onUpgrade: () {
          // Navegar a la pantalla de suscripción
          context.push('/profile/subscription');
        },
      );

      // Paywall mostrado, no continuar con la acción
      return false;
    }

    return false;
  }

  /// Verifica localmente (sin llamar al backend) si puede usar
  /// Útil para UI condicional
  static bool canUseLocally(WidgetRef ref, String endpoint) {
    final subscription = ref.read(subscriptionProvider);
    return subscription.canUse(endpoint);
  }

  /// Obtiene el uso restante localmente
  static int getRemaining(WidgetRef ref, String endpoint) {
    final subscription = ref.read(subscriptionProvider);
    return subscription.getRemaining(endpoint);
  }

  /// Registra el uso de una feature (llamar después de uso exitoso)
  static Future<void> recordUsage(WidgetRef ref, String endpoint) async {
    await ref.read(subscriptionProvider.notifier).recordUsage(endpoint);
  }

  /// Muestra un warning si está cerca del límite
  static void showLowUsageWarning(BuildContext context, int remaining) {
    if (remaining <= 0) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                remaining == 1
                    ? 'Te queda 1 uso gratuito hoy'
                    : 'Te quedan $remaining usos gratuitos hoy',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Pro',
          textColor: Colors.white,
          onPressed: () {
            context.push('/profile/subscription');
          },
        ),
      ),
    );
  }
}

/// Extension para usar gating más fácilmente en widgets
extension GatingExtension on WidgetRef {
  /// Verifica y gatea una feature de IA
  Future<bool> checkAIGate(BuildContext context, String endpoint) {
    return GatingHelper.checkAndGate(context, this, endpoint);
  }

  /// Obtiene el uso restante de una feature
  int aiRemaining(String endpoint) {
    return GatingHelper.getRemaining(this, endpoint);
  }

  /// Verifica si puede usar una feature localmente
  bool canUseAI(String endpoint) {
    return GatingHelper.canUseLocally(this, endpoint);
  }

  /// Registra el uso de una feature
  Future<void> recordAIUsage(String endpoint) {
    return GatingHelper.recordUsage(this, endpoint);
  }
}
