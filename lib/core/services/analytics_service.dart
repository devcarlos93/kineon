import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Eventos de analytics predefinidos
abstract class AnalyticsEvents {
  // Auth
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String onboardingCompleted = 'onboarding_completed';

  // Library
  static const String addToWatchlist = 'add_to_watchlist';
  static const String removeFromWatchlist = 'remove_from_watchlist';
  static const String addToFavorites = 'add_to_favorites';
  static const String removeFromFavorites = 'remove_from_favorites';
  static const String markAsWatched = 'mark_as_watched';
  static const String removeFromWatched = 'remove_from_watched';

  // AI Features
  static const String aiChatSent = 'ai_chat_sent';
  static const String aiSearchUsed = 'ai_search_used';
  static const String aiInsightViewed = 'ai_insight_viewed';
  static const String aiPicksRefreshed = 'ai_picks_refreshed';

  // Discovery
  static const String searchPerformed = 'search_performed';
  static const String movieDetailViewed = 'movie_detail_viewed';
  static const String tvDetailViewed = 'tv_detail_viewed';
  static const String watchProviderClicked = 'watch_provider_clicked';

  // Engagement
  static const String quickDecisionSwipe = 'quick_decision_swipe';
  static const String preferencesUpdated = 'preferences_updated';
  static const String shareContent = 'share_content';
}

/// Servicio de analytics y observabilidad
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  bool _initialized = false;
  String? _userId;

  /// Inicializa el servicio (llamar en main.dart)
  Future<void> initialize({String? sentryDsn}) async {
    if (_initialized) return;

    // Solo inicializar Sentry si hay DSN y no estamos en debug
    if (sentryDsn != null && sentryDsn.isNotEmpty && !kDebugMode) {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0.2; // 20% de transacciones
          options.profilesSampleRate = 0.1; // 10% de profiling
          options.environment = kDebugMode ? 'development' : 'production';
          options.attachScreenshot = true;
          options.attachViewHierarchy = true;
          // No enviar en debug
          options.beforeSend = (event, hint) {
            if (kDebugMode) return null;
            return event;
          };
        },
      );
    }

    _initialized = true;
    _log('Analytics initialized');
  }

  /// Establece el usuario actual
  void setUser(String? userId, {String? email}) {
    _userId = userId;

    if (userId != null) {
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: userId,
          email: email,
        ));
      });
    } else {
      Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    }

    _log('User set: ${userId ?? "anonymous"}');
  }

  /// Registra un evento
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) {
    final props = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': _userId,
      ...?properties,
    };

    // Log en debug
    _log('Event: $eventName', props);

    // Enviar a Sentry como breadcrumb
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'analytics',
      message: eventName,
      data: props.map((k, v) => MapEntry(k, v?.toString() ?? 'null')),
      level: SentryLevel.info,
    ));
  }

  /// Registra un error
  Future<void> trackError(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
  }) async {
    _log('Error: $message', {'exception': exception.toString()});

    if (!kDebugMode) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          if (message != null) {
            scope.setTag('error_message', message);
          }
          extras?.forEach((key, value) {
            scope.setExtra(key, value);
          });
        },
      );
    }
  }

  /// Registra un mensaje/log
  Future<void> trackMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) async {
    _log('Message [$level]: $message');

    if (!kDebugMode) {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          extras?.forEach((key, value) {
            scope.setExtra(key, value);
          });
        },
      );
    }
  }

  /// Inicia una transacción para medir performance
  ISentrySpan? startTransaction(String name, String operation) {
    if (kDebugMode) return null;

    return Sentry.startTransaction(
      name,
      operation,
      bindToScope: true,
    );
  }

  /// Log interno (solo en debug)
  void _log(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final dataStr = data != null ? ' $data' : '';
      // ignore: avoid_print
      print('[Analytics] $message$dataStr');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION PARA USO FÁCIL
// ═══════════════════════════════════════════════════════════════════════════

extension AnalyticsRef on WidgetRef {
  /// Acceso rápido al servicio de analytics
  AnalyticsService get analytics => read(analyticsServiceProvider);
}

extension AnalyticsProviderRef on Ref {
  /// Acceso rápido al servicio de analytics
  AnalyticsService get analytics => read(analyticsServiceProvider);
}
