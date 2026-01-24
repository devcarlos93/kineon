import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/subscription_state.dart';

/// Provider del estado de suscripción del usuario
class SubscriptionNotifier extends StateNotifier<UserSubscription> {
  final SupabaseClient _client;

  SubscriptionNotifier(this._client) : super(UserSubscription.free()) {
    _init();
  }

  Future<void> _init() async {
    await loadSubscription();

    // Escuchar cambios de auth para recargar
    _client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        loadSubscription();
      } else if (data.event == AuthChangeEvent.signedOut) {
        state = UserSubscription.free();
      }
    });
  }

  /// Carga el estado de suscripción y uso de IA
  Future<void> loadSubscription() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = UserSubscription.free();
      return;
    }

    try {
      // Cargar suscripción y uso en paralelo
      final results = await Future.wait([
        _client.rpc('get_subscription_status', params: {'p_user_id': user.id}),
        _client.rpc('get_daily_ai_usage', params: {'p_user_id': user.id}),
      ]);

      final subscriptionData = results[0] as Map<String, dynamic>? ?? {};
      final usageData = results[1] as List<dynamic>? ?? [];

      debugPrint('📊 Subscription data: $subscriptionData');
      debugPrint('📊 Usage data: $usageData');

      state = UserSubscription.fromJson(subscriptionData, usageData);
    } catch (e) {
      // En caso de error, mantener estado actual o free
      if (!mounted) return;
      // Log error pero no bloquear al usuario
      debugPrint('❌ Error loading subscription: $e');
    }
  }

  /// Refresca el uso de IA (después de usar una feature)
  Future<void> refreshUsage() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final usageData = await _client.rpc(
        'get_daily_ai_usage',
        params: {'p_user_id': user.id},
      ) as List<dynamic>? ?? [];

      final aiUsage = <String, AIFeatureUsage>{};
      for (final item in usageData) {
        final usage = AIFeatureUsage.fromJson(item as Map<String, dynamic>);
        aiUsage[usage.endpoint] = usage;
      }

      if (mounted) {
        state = state.copyWith(aiUsage: aiUsage);
      }
    } catch (e) {
      debugPrint('Error refreshing usage: $e');
    }
  }

  /// Verifica si puede usar una feature (llama al backend)
  Future<CanUseResult> checkCanUse(String endpoint) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return CanUseResult(
        canUse: false,
        reason: LimitReason.notAuthenticated,
        remaining: 0,
      );
    }

    // Si es Pro, siempre puede
    if (state.isPro) {
      return CanUseResult(canUse: true, remaining: 999);
    }

    try {
      final result = await _client.rpc('check_daily_limit', params: {
        'p_user_id': user.id,
        'p_endpoint': endpoint,
      }) as Map<String, dynamic>;

      final allowed = result['allowed'] as bool? ?? false;
      final remaining = result['remaining'] as int? ?? 0;

      if (!allowed) {
        return CanUseResult(
          canUse: false,
          reason: LimitReason.dailyLimitReached,
          remaining: remaining,
          dailyLimit: result['daily_limit'] as int? ?? 3,
        );
      }

      return CanUseResult(canUse: true, remaining: remaining);
    } catch (e) {
      // Fail-open: permitir en caso de error
      return CanUseResult(canUse: true, remaining: -1);
    }
  }

  /// Registra que se usó una feature (llamar después de uso exitoso)
  Future<void> recordUsage(String endpoint) async {
    // Refrescar el uso después de un pequeño delay
    await Future.delayed(const Duration(milliseconds: 500));
    await refreshUsage();
  }

  /// Actualiza el estado a Pro (después de compra exitosa)
  void setPro({
    required DateTime expiresAt,
    required String provider,
    required String productId,
  }) {
    state = state.copyWith(
      status: SubscriptionStatus.pro,
      isPro: true,
      expiresAt: expiresAt,
      provider: provider,
      productId: productId,
    );
  }

  /// Revierte a Free (suscripción expirada)
  void setFree() {
    state = state.copyWith(
      status: SubscriptionStatus.free,
      isPro: false,
    );
  }
}

/// Resultado de verificación de uso
class CanUseResult {
  final bool canUse;
  final LimitReason? reason;
  final int remaining;
  final int? dailyLimit;

  CanUseResult({
    required this.canUse,
    this.reason,
    required this.remaining,
    this.dailyLimit,
  });
}

/// Razón por la que no puede usar
enum LimitReason {
  dailyLimitReached,
  notAuthenticated,
  subscriptionExpired,
}

/// Provider principal de suscripción
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, UserSubscription>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionNotifier(client);
});

/// Provider de uso restante para un endpoint específico
final aiUsageProvider = Provider.family<AIFeatureUsage, String>((ref, endpoint) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.getUsage(endpoint);
});

/// Provider para verificar si es Pro
final isProProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPro;
});

/// Provider para verificar si puede usar una feature
final canUseAIProvider = Provider.family<bool, String>((ref, endpoint) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.canUse(endpoint);
});
