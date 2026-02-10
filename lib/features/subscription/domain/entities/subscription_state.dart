/// Estado de suscripción del usuario
enum SubscriptionTier {
  free,
  pro,
}

/// Estado de la suscripción
enum SubscriptionStatus {
  free,
  pro,
  expired,
  gracePeriod,
}

/// Uso de una feature de IA
class AIFeatureUsage {
  final String endpoint;
  final int usedToday;
  final int dailyLimit;
  final int remaining;

  const AIFeatureUsage({
    required this.endpoint,
    required this.usedToday,
    required this.dailyLimit,
    required this.remaining,
  });

  bool get canUse => remaining > 0;
  bool get isLimited => dailyLimit < 100; // Pro tiene 1000, free tiene < 10
  double get usagePercent => dailyLimit > 0 ? usedToday / dailyLimit : 0;

  factory AIFeatureUsage.fromJson(Map<String, dynamic> json) {
    return AIFeatureUsage(
      endpoint: json['endpoint'] as String,
      usedToday: json['used_today'] as int? ?? 0,
      dailyLimit: json['daily_limit'] as int? ?? 5,
      remaining: json['remaining'] as int? ?? 0,
    );
  }

  /// Uso desconocido (para fallback)
  factory AIFeatureUsage.unknown(String endpoint) {
    // Defaults según el endpoint (free tier limits)
    final limit = _getDefaultLimit(endpoint);
    return AIFeatureUsage(
      endpoint: endpoint,
      usedToday: 0,
      dailyLimit: limit,
      remaining: limit,
    );
  }

  /// Límites por defecto para free tier
  static int _getDefaultLimit(String endpoint) {
    switch (endpoint) {
      case 'ai-chat':
        return 4;
      case 'ai-search-plan':
        return 6;
      case 'ai-movie-insight':
        return 3;
      case 'ai-home-picks':
        return 5;
      case 'ai-stories':
        return 5;
      default:
        return 3;
    }
  }
}

/// Estado completo de la suscripción del usuario
class UserSubscription {
  final SubscriptionStatus status;
  final bool isPro;
  final DateTime? expiresAt;
  final String? provider; // 'apple', 'google'
  final String? productId;
  final Map<String, AIFeatureUsage> aiUsage;

  const UserSubscription({
    required this.status,
    required this.isPro,
    this.expiresAt,
    this.provider,
    this.productId,
    this.aiUsage = const {},
  });

  /// Usuario free por defecto
  factory UserSubscription.free() {
    return const UserSubscription(
      status: SubscriptionStatus.free,
      isPro: false,
    );
  }

  /// Obtener uso de un endpoint específico
  AIFeatureUsage getUsage(String endpoint) {
    return aiUsage[endpoint] ?? AIFeatureUsage.unknown(endpoint);
  }

  /// Verificar si puede usar una feature
  bool canUse(String endpoint) {
    return isPro || getUsage(endpoint).canUse;
  }

  /// Obtener remaining de una feature
  int getRemaining(String endpoint) {
    if (isPro) return 999; // Ilimitado para Pro
    return getUsage(endpoint).remaining;
  }

  /// Verificar si está cerca del límite (para mostrar warning)
  bool isNearLimit(String endpoint) {
    if (isPro) return false;
    final usage = getUsage(endpoint);
    return usage.remaining <= 2 && usage.remaining > 0;
  }

  /// Verificar si llegó al límite
  bool isAtLimit(String endpoint) {
    if (isPro) return false;
    return getUsage(endpoint).remaining <= 0;
  }

  factory UserSubscription.fromJson(
    Map<String, dynamic> subscriptionJson,
    List<dynamic> usageJson,
  ) {
    final statusStr = subscriptionJson['status'] as String? ?? 'free';
    final status = SubscriptionStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => SubscriptionStatus.free,
    );

    final aiUsage = <String, AIFeatureUsage>{};
    for (final item in usageJson) {
      final usage = AIFeatureUsage.fromJson(item as Map<String, dynamic>);
      aiUsage[usage.endpoint] = usage;
    }

    return UserSubscription(
      status: status,
      isPro: subscriptionJson['is_pro'] as bool? ?? false,
      expiresAt: subscriptionJson['expires_at'] != null
          ? DateTime.tryParse(subscriptionJson['expires_at'] as String)
          : null,
      provider: subscriptionJson['provider'] as String?,
      productId: subscriptionJson['product_id'] as String?,
      aiUsage: aiUsage,
    );
  }

  UserSubscription copyWith({
    SubscriptionStatus? status,
    bool? isPro,
    DateTime? expiresAt,
    String? provider,
    String? productId,
    Map<String, AIFeatureUsage>? aiUsage,
  }) {
    return UserSubscription(
      status: status ?? this.status,
      isPro: isPro ?? this.isPro,
      expiresAt: expiresAt ?? this.expiresAt,
      provider: provider ?? this.provider,
      productId: productId ?? this.productId,
      aiUsage: aiUsage ?? this.aiUsage,
    );
  }
}

/// Endpoints de IA disponibles
class AIEndpoints {
  static const chat = 'ai-chat';
  static const search = 'ai-search-plan';
  static const insight = 'ai-movie-insight';
  static const picks = 'ai-home-picks';
  static const stories = 'ai-stories';

  /// Nombres amigables para UI
  static String getDisplayName(String endpoint) {
    switch (endpoint) {
      case chat:
        return 'Chat IA';
      case search:
        return 'Búsqueda IA';
      case insight:
        return 'Insights IA';
      case picks:
        return 'Recomendaciones IA';
      case stories:
        return 'Stories IA';
      default:
        return 'IA';
    }
  }
}
