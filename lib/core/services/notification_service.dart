import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../features/home/domain/entities/media_item.dart';
import '../../features/home/presentation/providers/ai_picks_provider.dart';
import '../../features/library/presentation/providers/library_providers.dart';

/// Servicio de notificaciones locales inteligentes
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification IDs
  static const int _pickOfDayId = 1;
  static const int _watchlistReminderId = 2;
  static const int _weeklySummaryId = 3;
  static const int _cinemaReminderId = 4;

  // Preference keys
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyPickOfDayEnabled = 'pick_of_day_enabled';
  static const String _keyWatchlistReminderEnabled = 'watchlist_reminder_enabled';
  static const String _keyWeeklySummaryEnabled = 'weekly_summary_enabled';

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navegar según el payload
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Verifica si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  /// Habilita/deshabilita notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);

    if (enabled) {
      await scheduleAllNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Programa todas las notificaciones según preferencias
  Future<void> scheduleAllNotifications({
    List<MediaItem>? watchlist,
    List<MediaItem>? recommendations,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyNotificationsEnabled) ?? false;

    if (!enabled) return;

    // Pick del día (Lun, Mié, Vie 7:30pm)
    if (prefs.getBool(_keyPickOfDayEnabled) ?? true) {
      await _schedulePickOfDay(recommendations);
    }

    // Recordatorio de watchlist
    if (prefs.getBool(_keyWatchlistReminderEnabled) ?? true) {
      await _scheduleWatchlistReminder(watchlist);
    }

    // Resumen semanal (Dom 6pm)
    if (prefs.getBool(_keyWeeklySummaryEnabled) ?? true) {
      await _scheduleWeeklySummary();
    }

    debugPrint('🔔 All notifications scheduled');
  }

  /// Programa notificación "Pick del día" para Lun, Mié, Vie
  Future<void> _schedulePickOfDay(List<MediaItem>? recommendations) async {
    // Cancelar anteriores
    await _plugin.cancel(_pickOfDayId);
    await _plugin.cancel(_pickOfDayId + 100);
    await _plugin.cancel(_pickOfDayId + 200);

    final now = tz.TZDateTime.now(tz.local);

    // Programar para los próximos días de la semana (Lun=1, Mié=3, Vie=5)
    for (final day in [DateTime.monday, DateTime.wednesday, DateTime.friday]) {
      final scheduledDate = _nextInstanceOfDayTime(day, 19, 30);

      if (scheduledDate.isAfter(now)) {
        final notificationId = _pickOfDayId + (day * 100);

        await _plugin.zonedSchedule(
          notificationId,
          '🎬 Tu pick del día',
          recommendations?.isNotEmpty == true
              ? '${recommendations!.first.title} te está esperando'
              : 'Tenemos una recomendación perfecta para ti',
          scheduledDate,
          _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'pick_of_day',
        );
      }
    }
  }

  /// Programa recordatorio de watchlist
  Future<void> _scheduleWatchlistReminder(List<MediaItem>? watchlist) async {
    await _plugin.cancel(_watchlistReminderId);

    if (watchlist == null || watchlist.isEmpty) return;

    // Programar para mañana a las 8pm si hay items en watchlist
    final scheduledDate = _nextInstanceOfTime(20, 0);

    final item = watchlist.first;

    await _plugin.zonedSchedule(
      _watchlistReminderId,
      '📺 ¿Qué tal esta noche?',
      '${item.title} sigue en tu lista. ¿La vemos hoy?',
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'watchlist:${item.id}',
    );
  }

  /// Programa resumen semanal (Domingo 6pm)
  Future<void> _scheduleWeeklySummary() async {
    await _plugin.cancel(_weeklySummaryId);

    final scheduledDate = _nextInstanceOfDayTime(DateTime.sunday, 18, 0);

    await _plugin.zonedSchedule(
      _weeklySummaryId,
      '🍿 Resumen semanal',
      'Tienes 3 recomendaciones personalizadas para esta semana',
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_summary',
    );
  }

  /// Obtiene la próxima instancia de un día y hora específicos
  tz.TZDateTime _nextInstanceOfDayTime(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Encontrar el próximo día de la semana especificado
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Obtiene la próxima instancia de una hora específica
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Configuración de notificación
  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'kineon_smart',
        'Recomendaciones Inteligentes',
        channelDescription: 'Notificaciones personalizadas de películas y series',
        importance: Importance.high,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Programa un recordatorio de cine para una película
  Future<void> scheduleCinemaReminder({
    required int movieId,
    required String movieTitle,
    required DateTime reminderDate,
  }) async {
    await _plugin.cancel(_cinemaReminderId);

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) return;

    await _plugin.zonedSchedule(
      _cinemaReminderId,
      'Es hora de ir al cine',
      '$movieTitle te espera en la gran pantalla',
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'cinema:$movieId',
    );

    debugPrint('🎬 Cinema reminder scheduled for $movieTitle at $scheduledDate');
  }

  /// Cancela el recordatorio de cine
  Future<void> cancelCinemaReminder() async {
    await _plugin.cancel(_cinemaReminderId);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('🔔 All notifications cancelled');
  }

  /// Muestra una notificación inmediata (para testing)
  Future<void> showTestNotification() async {
    await _plugin.show(
      999,
      '🎬 Kineon',
      'Las notificaciones están funcionando correctamente',
      _getNotificationDetails(),
    );
  }

  /// Obtiene las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}

/// Provider del servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider del estado de notificaciones
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications_enabled') ?? false;
});

/// Estado de preferencias de notificación
class NotificationPreferences {
  final bool enabled;
  final bool pickOfDay;
  final bool watchlistReminder;
  final bool weeklySummary;

  const NotificationPreferences({
    this.enabled = false,
    this.pickOfDay = true,
    this.watchlistReminder = true,
    this.weeklySummary = true,
  });

  NotificationPreferences copyWith({
    bool? enabled,
    bool? pickOfDay,
    bool? watchlistReminder,
    bool? weeklySummary,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      pickOfDay: pickOfDay ?? this.pickOfDay,
      watchlistReminder: watchlistReminder ?? this.watchlistReminder,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }
}

/// Notifier para preferencias de notificación
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  final NotificationService _service;
  final Ref _ref;

  NotificationPreferencesNotifier(this._service, this._ref) : super(const NotificationPreferences()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      enabled: prefs.getBool('notifications_enabled') ?? false,
      pickOfDay: prefs.getBool('pick_of_day_enabled') ?? true,
      watchlistReminder: prefs.getBool('watchlist_reminder_enabled') ?? true,
      weeklySummary: prefs.getBool('weekly_summary_enabled') ?? true,
    );
  }

  /// Obtiene datos de IA para personalizar notificaciones
  Future<({List<MediaItem>? recommendations, List<MediaItem>? watchlist})> _getAIData() async {
    List<MediaItem>? recommendations;
    List<MediaItem>? watchlist;

    try {
      // Obtener AI Picks
      final aiPicksState = _ref.read(aiPicksProvider);
      if (aiPicksState.picks.isNotEmpty) {
        recommendations = aiPicksState.picks.map((p) => p.item).toList();
      }

      // Obtener Watchlist
      final watchlistAsync = await _ref.read(watchlistWithDetailsProvider.future);
      if (watchlistAsync.isNotEmpty) {
        watchlist = watchlistAsync
            .where((item) => item.bulkItem != null)
            .map((item) => MediaItem(
                  id: item.tmdbId,
                  title: item.bulkItem!.title,
                  overview: item.bulkItem?.overview ?? '',
                  posterPath: item.bulkItem?.posterPath,
                  backdropPath: item.bulkItem?.backdropPath,
                  voteAverage: item.bulkItem?.voteAverage ?? 0,
                  voteCount: 0,
                  genreIds: [],
                  contentType: item.contentType,
                  releaseDate: item.bulkItem?.releaseDate,
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting AI data for notifications: $e');
    }

    return (recommendations: recommendations, watchlist: watchlist);
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    state = state.copyWith(enabled: value);

    if (value) {
      await _service.requestPermission();
      final aiData = await _getAIData();
      await _service.scheduleAllNotifications(
        watchlist: aiData.watchlist,
        recommendations: aiData.recommendations,
      );
    } else {
      await _service.cancelAllNotifications();
    }
  }

  Future<void> setPickOfDay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pick_of_day_enabled', value);
    state = state.copyWith(pickOfDay: value);
    final aiData = await _getAIData();
    await _service.scheduleAllNotifications(
      watchlist: aiData.watchlist,
      recommendations: aiData.recommendations,
    );
  }

  Future<void> setWatchlistReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('watchlist_reminder_enabled', value);
    state = state.copyWith(watchlistReminder: value);
    final aiData = await _getAIData();
    await _service.scheduleAllNotifications(
      watchlist: aiData.watchlist,
      recommendations: aiData.recommendations,
    );
  }

  Future<void> setWeeklySummary(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_summary_enabled', value);
    state = state.copyWith(weeklySummary: value);
    final aiData = await _getAIData();
    await _service.scheduleAllNotifications(
      watchlist: aiData.watchlist,
      recommendations: aiData.recommendations,
    );
  }

  /// Actualiza las notificaciones con los datos de IA más recientes
  /// Llamar después de cargar AI Picks o actualizar watchlist
  Future<void> refreshWithAIData() async {
    if (!state.enabled) return;

    final aiData = await _getAIData();
    await _service.scheduleAllNotifications(
      watchlist: aiData.watchlist,
      recommendations: aiData.recommendations,
    );
    debugPrint('🔔 Notifications refreshed with AI data');
  }
}

/// Provider de preferencias de notificación
final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationPreferencesNotifier(service, ref);
});
