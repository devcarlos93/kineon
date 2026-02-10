import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/services/analytics_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELOS
// ═══════════════════════════════════════════════════════════════════════════

enum ChatRole { user, assistant }

/// Mensaje del chat
class ChatMessage {
  final String? id; // ID de Supabase (null si no persistido)
  final ChatRole role;
  final String text;
  final List<AiCardItem> cards;
  final List<String> quickReplies;

  const ChatMessage({
    this.id,
    required this.role,
    required this.text,
    this.cards = const [],
    this.quickReplies = const [],
  });

  /// Convierte a JSON para guardar metadata
  Map<String, dynamic> toMetaJson() {
    return {
      if (cards.isNotEmpty)
        'picks': cards
            .map((c) => {
                  'tmdb_id': c.tmdbId,
                  'match': c.match,
                  'reason': c.reason,
                  'content_type': c.contentType,
                })
            .toList(),
      if (quickReplies.isNotEmpty) 'quick_replies': quickReplies,
    };
  }

  /// Crea desde registro de Supabase
  static ChatMessage fromSupabase(
    Map<String, dynamic> row, {
    List<AiCardItem> hydratedCards = const [],
  }) {
    final meta = row['meta_json'] as Map<String, dynamic>? ?? {};
    final picks = (meta['picks'] as List<dynamic>?) ?? [];
    final quickReplies = (meta['quick_replies'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];

    // Usar cards hidratadas si las hay, sino crear básicas desde meta
    final cards = hydratedCards.isNotEmpty
        ? hydratedCards
        : picks
            .map((p) => AiCardItem(
                  tmdbId: (p['tmdb_id'] as num?)?.toInt() ?? 0,
                  match: (p['match'] as num?)?.toInt() ?? 80,
                  reason: p['reason'] as String? ?? '',
                  contentType: p['content_type'] as String? ?? 'movie',
                ))
            .where((c) => c.tmdbId > 0)
            .toList();

    return ChatMessage(
      id: row['id'] as String?,
      role: row['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
      text: row['content'] as String? ?? '',
      cards: cards,
      quickReplies: quickReplies,
    );
  }
}

/// Item de recomendación con datos de TMDB
class AiCardItem {
  final int tmdbId;
  final int match;
  final String reason;
  final String contentType; // 'movie' o 'tv'

  // Datos hidratados de TMDB
  final String? title;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;

  const AiCardItem({
    required this.tmdbId,
    required this.match,
    required this.reason,
    required this.contentType,
    this.title,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
  });

  String? get posterUrl => posterPath != null
      ? '${AppConstants.tmdbPosterMedium}$posterPath'
      : null;

  String? get backdropUrl => backdropPath != null
      ? '${AppConstants.tmdbBackdropMedium}$backdropPath'
      : null;

  AiCardItem copyWithTmdbData({
    String? title,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    String? releaseDate,
  }) {
    return AiCardItem(
      tmdbId: tmdbId,
      match: match,
      reason: reason,
      contentType: contentType,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════════════

class AiChatState {
  final String? threadId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? error;

  const AiChatState({
    this.threadId,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.error,
  });

  AiChatState copyWith({
    String? threadId,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingHistory,
    String? error,
  }) {
    return AiChatState(
      threadId: threadId ?? this.threadId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

class AiChatNotifier extends StateNotifier<AiChatState> {
  final SupabaseClient _client;
  final AnalyticsService _analytics;
  final String _language;
  final String _region;

  AiChatNotifier(
    this._client,
    this._analytics, {
    required String language,
    required String region,
  })  : _language = language,
        _region = region,
        super(const AiChatState()) {
    // Cargar historial al iniciar
    _loadChatHistory();
  }

  /// Carga el historial del chat desde Supabase
  Future<void> _loadChatHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // Usuario no autenticado - mostrar welcome
      state = AiChatState(messages: [_getWelcomeMessage(_language)]);
      return;
    }

    state = state.copyWith(isLoadingHistory: true);

    try {
      // Obtener o crear thread con timeout
      final threadResult = await _client.rpc(
        'get_or_create_chat_thread',
        params: {'p_user_id': userId},
      ).timeout(const Duration(seconds: 10));

      // El resultado puede venir como String directamente o necesitar conversión
      final threadId = threadResult?.toString();
      if (threadId == null || threadId.isEmpty) {
        state = AiChatState(messages: [_getWelcomeMessage(_language)]);
        return;
      }

      // Cargar mensajes del thread con timeout
      final messagesResult = await _client.rpc(
        'load_chat_messages',
        params: {'p_thread_id': threadId, 'p_limit': 50},
      ).timeout(const Duration(seconds: 10));

      // Asegurar que es una lista
      final List<dynamic> messagesList;
      if (messagesResult is List) {
        messagesList = messagesResult;
      } else {
        messagesList = [];
      }

      if (messagesList.isEmpty) {
        // Thread nuevo o sin mensajes - mostrar welcome
        state = AiChatState(
          threadId: threadId,
          messages: [_getWelcomeMessage(_language)],
        );
        return;
      }

      // Convertir mensajes (sin hidratar para cargar más rápido)
      List<ChatMessage> messages = [];
      for (final row in messagesList) {
        if (row is! Map<String, dynamic>) continue;
        messages.add(ChatMessage.fromSupabase(row));
      }

      // Si después de procesar no hay mensajes válidos, mostrar welcome
      if (messages.isEmpty) {
        state = AiChatState(
          threadId: threadId,
          messages: [_getWelcomeMessage(_language)],
        );
        return;
      }

      // Actualizar quick_replies del último mensaje assistant al idioma actual
      messages = _localizeLastQuickReplies(messages);

      // Mostrar mensajes sin hidratar primero (carga rápida)
      state = AiChatState(
        threadId: threadId,
        messages: messages,
        isLoadingHistory: false,
      );

      // Hidratar cards en background (no bloquea UI)
      _hydrateMessagesInBackground(messages, threadId);
    } catch (e, stack) {
      // Error cargando - mostrar welcome y loguear error
      // ignore: avoid_print
      print('Error loading chat history: $e\n$stack');
      state = AiChatState(
        messages: [_getWelcomeMessage(_language)],
        isLoadingHistory: false,
        error: e.toString(),
      );
    }
  }

  /// Hidrata las cards de los mensajes en background
  Future<void> _hydrateMessagesInBackground(List<ChatMessage> messages, String threadId) async {
    try {
      final hydratedMessages = <ChatMessage>[];

      for (final msg in messages) {
        if (msg.cards.isNotEmpty) {
          final hydratedCards = await _hydrateTmdbData(msg.cards);
          hydratedMessages.add(ChatMessage(
            id: msg.id,
            role: msg.role,
            text: msg.text,
            cards: hydratedCards,
            quickReplies: msg.quickReplies,
          ));
        } else {
          hydratedMessages.add(msg);
        }
      }

      // Actualizar estado solo si aún estamos en el mismo thread
      if (mounted && state.threadId == threadId) {
        state = state.copyWith(messages: hydratedMessages);
      }
    } catch (e) {
      // Silently fail - messages already shown without hydration
    }
  }

  /// Guarda un mensaje en Supabase
  Future<void> _saveMessage(ChatMessage message) async {
    final threadId = state.threadId;
    if (threadId == null) return;

    try {
      await _client.rpc(
        'save_chat_message',
        params: {
          'p_thread_id': threadId,
          'p_role': message.role == ChatRole.user ? 'user' : 'assistant',
          'p_content': message.text,
          'p_meta_json': message.toMetaJson(),
        },
      );
    } catch (e) {
      // No fallar si no se puede guardar, solo loguear
      // ignore: avoid_print
      print('Error saving chat message: $e');
    }
  }

  /// Obtiene el mensaje de bienvenida usando l10n
  static ChatMessage _getWelcomeMessage(String language) {
    final langCode = language.split('-').first;
    final l10n = AppLocalizations(Locale(langCode));
    return ChatMessage(
      role: ChatRole.assistant,
      text: l10n.aiWelcomeMessage,
      quickReplies: [
        l10n.aiQuickReplyRelax,
        l10n.aiQuickReplySciFi,
        l10n.aiQuickReplyCouple,
        l10n.aiQuickReplySurprise,
      ],
    );
  }

  /// Reemplaza los quick_replies del último mensaje assistant con los del idioma actual
  List<ChatMessage> _localizeLastQuickReplies(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    // Buscar el último mensaje del asistente con quick replies
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.role == ChatRole.assistant && msg.quickReplies.isNotEmpty) {
        final updated = List<ChatMessage>.from(messages);
        updated[i] = ChatMessage(
          id: msg.id,
          role: msg.role,
          text: msg.text,
          cards: msg.cards,
          quickReplies: _getDefaultQuickReplies(),
        );
        return updated;
      }
    }
    return messages;
  }

  /// Quick replies por defecto en el idioma actual
  List<String> _getDefaultQuickReplies() {
    final langCode = _language.split('-').first;
    final l10n = AppLocalizations(Locale(langCode));
    return [
      l10n.aiQuickReplyRelax,
      l10n.aiQuickReplySciFi,
      l10n.aiQuickReplyCouple,
      l10n.aiQuickReplySurprise,
    ];
  }

  /// Obtiene el mensaje de error usando l10n
  ChatMessage _getErrorMessage() {
    final langCode = _language.split('-').first;
    final l10n = AppLocalizations(Locale(langCode));
    return ChatMessage(
      role: ChatRole.assistant,
      text: l10n.aiErrorMessage,
      quickReplies: [
        l10n.aiQuickReplyRetry,
        l10n.aiQuickReplyPopular,
        l10n.aiQuickReplySurprise,
      ],
    );
  }

  /// Obtiene el mensaje de rate limit según el idioma
  ChatMessage _getRateLimitMessage(int waitSeconds) {
    final isSpanish = _language.startsWith('es');
    final waitText = waitSeconds > 60
        ? (isSpanish ? 'un momento' : 'a moment')
        : '$waitSeconds ${isSpanish ? "segundos" : "seconds"}';

    return ChatMessage(
      role: ChatRole.assistant,
      text: isSpanish
          ? 'Estás enviando mensajes muy rápido. Espera $waitText antes de continuar.'
          : 'You\'re sending messages too fast. Wait $waitText before continuing.',
      quickReplies: const [],
    );
  }

  /// Envía un mensaje al asistente
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      role: ChatRole.user,
      text: text.trim(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Guardar mensaje del usuario (background)
    _saveMessage(userMessage);

    try {
      // Construir historial para la IA
      final history = state.messages
          .where((m) => m.text.trim().isNotEmpty)
          .take(10)
          .map((m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      // Llamar a la Edge Function
      final response = await _client.functions.invoke(
        EdgeFunctions.aiChat,
        body: {
          'message': text.trim(),
          'history': history,
          'language': _language,
          'region': _region,
          'user_prefs': {
            'preferred_genres': <int>[],
            'mood_text': '',
          },
        },
      );

      if (!mounted) return;

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('No response from AI');
      }

      // Parsear respuesta
      final assistantMessageText = data['assistant_message'] as String? ?? '';
      final picks = (data['picks'] as List<dynamic>?) ?? [];
      final quickReplies = (data['quick_replies'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [];

      // Crear cards de las recomendaciones
      List<AiCardItem> cards = picks.map((p) {
        final pick = p as Map<String, dynamic>;
        return AiCardItem(
          tmdbId: (pick['tmdb_id'] as num?)?.toInt() ?? 0,
          match: (pick['match'] as num?)?.toInt() ?? 80,
          reason: pick['reason'] as String? ?? '',
          contentType: pick['content_type'] as String? ?? 'movie',
        );
      }).where((c) => c.tmdbId > 0).toList();

      // Hidratar con datos de TMDB
      if (cards.isNotEmpty) {
        cards = await _hydrateTmdbData(cards);
      }

      if (!mounted) return;

      final aiMessage = ChatMessage(
        role: ChatRole.assistant,
        text: assistantMessageText,
        cards: cards,
        quickReplies: quickReplies,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      // Guardar mensaje del asistente (background)
      _saveMessage(aiMessage);

      // Track analytics
      _analytics.trackEvent(
        AnalyticsEvents.aiChatSent,
        properties: {
          'picks_count': cards.length,
          'has_quick_replies': quickReplies.isNotEmpty,
        },
      );
    } on FunctionException catch (e) {
      if (!mounted) return;

      // Manejar rate limit (429)
      ChatMessage errorMessage;
      if (e.status == 429) {
        // Intentar parsear wait_seconds del error
        int waitSeconds = 5;
        try {
          final errorData = e.details as Map<String, dynamic>?;
          waitSeconds = (errorData?['waitSeconds'] as num?)?.toInt() ?? 5;
        } catch (_) {}
        errorMessage = _getRateLimitMessage(waitSeconds);
      } else {
        errorMessage = _getErrorMessage();
      }

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        messages: [...state.messages, _getErrorMessage()],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Hidrata las cards con datos de TMDB usando tmdb-bulk
  Future<List<AiCardItem>> _hydrateTmdbData(List<AiCardItem> cards) async {
    try {
      // Separar por tipo
      final movieCards = cards.where((c) => c.contentType == 'movie').toList();
      final tvCards = cards.where((c) => c.contentType == 'tv').toList();

      final results = await Future.wait([
        if (movieCards.isNotEmpty)
          _client.callTmdbBulk(
            ids: movieCards.map((c) => c.tmdbId).toList(),
            contentType: 'movie',
            language: _language,
            region: _region,
          )
        else
          Future.value(<Map<String, dynamic>>[]),
        if (tvCards.isNotEmpty)
          _client.callTmdbBulk(
            ids: tvCards.map((c) => c.tmdbId).toList(),
            contentType: 'tv',
            language: _language,
            region: _region,
          )
        else
          Future.value(<Map<String, dynamic>>[]),
      ]);

      // Crear mapa de id -> datos
      final Map<int, Map<String, dynamic>> tmdbMap = {};

      for (final item in results[0]) {
        final id = (item['id'] as num?)?.toInt();
        if (id != null) tmdbMap[id] = item;
      }

      if (results.length > 1) {
        for (final item in results[1]) {
          final id = (item['id'] as num?)?.toInt();
          if (id != null) tmdbMap[id] = item;
        }
      }

      // Actualizar cards con datos de TMDB
      return cards.map((card) {
        final tmdbData = tmdbMap[card.tmdbId];
        if (tmdbData == null) return card;

        return card.copyWithTmdbData(
          title: tmdbData['title'] as String? ?? tmdbData['name'] as String?,
          posterPath: tmdbData['poster_path'] as String?,
          backdropPath: tmdbData['backdrop_path'] as String?,
          voteAverage: (tmdbData['vote_average'] as num?)?.toDouble(),
          releaseDate: tmdbData['release_date'] as String? ??
              tmdbData['first_air_date'] as String?,
        );
      }).toList();
    } catch (e) {
      // Si falla la hidratación, devolver cards sin datos extra
      return cards;
    }
  }

  /// Inicia un nuevo thread (nueva conversación)
  Future<void> startNewThread() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      clear();
      return;
    }

    state = state.copyWith(isLoadingHistory: true);

    try {
      final threadResult = await _client.rpc(
        'start_new_chat_thread',
        params: {'p_user_id': userId},
      );

      final threadId = threadResult as String?;

      state = AiChatState(
        threadId: threadId,
        messages: [_getWelcomeMessage(_language)],
      );
    } catch (e) {
      state = AiChatState(
        messages: [_getWelcomeMessage(_language)],
        error: e.toString(),
      );
    }
  }

  /// Limpia el chat (nueva conversación local)
  void clear() {
    state = AiChatState(
      threadId: state.threadId,
      messages: [_getWelcomeMessage(_language)],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  final analytics = ref.read(analyticsServiceProvider);

  return AiChatNotifier(
    client,
    analytics,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});
