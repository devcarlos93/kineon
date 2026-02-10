import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/story_item.dart';

/// Estado de las Stories
class StoriesState {
  final List<StoryItem> stories;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String source;
  final int currentIndex;
  final Set<int> viewedIndices;
  final DateTime? lastUpdated;

  const StoriesState({
    this.stories = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.source = 'none',
    this.currentIndex = 0,
    this.viewedIndices = const {},
    this.lastUpdated,
  });

  StoriesState copyWith({
    List<StoryItem>? stories,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? source,
    int? currentIndex,
    Set<int>? viewedIndices,
    DateTime? lastUpdated,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      source: source ?? this.source,
      currentIndex: currentIndex ?? this.currentIndex,
      viewedIndices: viewedIndices ?? this.viewedIndices,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasStories => stories.isNotEmpty;
  bool get isLastStory => currentIndex >= stories.length - 1;
  StoryItem? get currentStory =>
      stories.isNotEmpty && currentIndex < stories.length
          ? stories[currentIndex]
          : null;
}

/// Notifier para Stories con cache-first pattern
class StoriesNotifier extends StateNotifier<StoriesState> {
  final SupabaseClient _client;
  final CacheService _cache;
  final String language;
  final String region;

  StoriesNotifier(
    this._client,
    this._cache, {
    this.language = 'es-ES',
    this.region = 'ES',
  }) : super(const StoriesState());

  String _getCacheKey() {
    final userId = _client.auth.currentUser?.id ?? 'anonymous';
    final lang = language.split('-').first;
    return 'stories_v1_${userId}_$lang';
  }

  /// Carga stories con estrategia cache-first
  Future<void> loadStories() async {
    if (!mounted) return;

    final cacheKey = _getCacheKey();

    // PASO 1: Cache local para render instantaneo
    final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);

    if (cachedData != null) {
      try {
        final cachedStories = _parseStoriesFromCache(cachedData);
        if (cachedStories.isNotEmpty) {
          state = state.copyWith(
            stories: cachedStories,
            isLoading: false,
            isRefreshing: true,
            source: 'cache',
            lastUpdated: DateTime.now(),
          );
        }
      } catch (_) {}
    }

    // Rate limit: no refetch si data < 5 min
    if (state.stories.isNotEmpty &&
        state.lastUpdated != null &&
        state.source != 'cache') {
      final elapsed = DateTime.now().difference(state.lastUpdated!);
      if (elapsed.inMinutes < 5) {
        state = state.copyWith(isRefreshing: false);
        return;
      }
    }

    if (state.stories.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    // PASO 2: Fetch del servidor
    try {
      final response = await _client.callAiHomePicks(
        pickCount: 12,
        language: language,
        region: region,
        storyMode: true,
      );

      if (!mounted) return;

      if (response == null) {
        throw Exception('Respuesta vacia del servidor');
      }

      final data = response as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Error desconocido');
      }

      final picksList = data['picks'] as List<dynamic>? ?? [];
      final stories = <StoryItem>[];

      for (int i = 0; i < picksList.length; i++) {
        final json = picksList[i] as Map<String, dynamic>;
        // Filtrar items sin backdrop_path (necesario para fullscreen)
        if (json['backdrop_path'] != null) {
          stories.add(StoryItem.fromJson(json, position: stories.length));
        }
      }

      final source = data['source'] as String? ?? 'unknown';

      state = state.copyWith(
        stories: stories,
        isLoading: false,
        isRefreshing: false,
        source: source,
        currentIndex: 0,
        viewedIndices: const {},
        lastUpdated: DateTime.now(),
      );

      await _saveToCache(cacheKey, stories);
    } on FunctionException catch (e) {
      if (!mounted) return;
      if (state.stories.isNotEmpty) {
        state = state.copyWith(isRefreshing: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.reasonPhrase ?? 'Error en Edge Function',
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (state.stories.isNotEmpty) {
        state = state.copyWith(isRefreshing: false);
      } else {
        // Intentar cache stale como ultimo recurso
        final staleData = _cache.getStale<Map<String, dynamic>>(cacheKey);
        if (staleData != null) {
          try {
            final staleStories = _parseStoriesFromCache(staleData);
            if (staleStories.isNotEmpty) {
              state = state.copyWith(
                stories: staleStories,
                isLoading: false,
                isRefreshing: false,
                source: 'cache',
              );
              return;
            }
          } catch (_) {}
        }

        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.toString(),
        );
      }
    }
  }

  List<StoryItem> _parseStoriesFromCache(Map<String, dynamic> data) {
    final picksList = data['picks'] as List<dynamic>? ?? [];
    final stories = <StoryItem>[];
    for (int i = 0; i < picksList.length; i++) {
      final json = picksList[i] as Map<String, dynamic>;
      if (json['backdrop_path'] != null) {
        stories.add(StoryItem.fromJson(json, position: stories.length));
      }
    }
    return stories;
  }

  Future<void> _saveToCache(String key, List<StoryItem> stories) async {
    try {
      await _cache.put(
        key,
        {
          'picks': stories.map((s) => s.toJson()).toList(),
          'cached_at': DateTime.now().toIso8601String(),
        },
        ttlMinutes: 360, // 6 horas
        flush: true,
      );
    } catch (_) {}
  }

  /// Avanza a la siguiente story
  void nextStory() {
    if (state.currentIndex < state.stories.length - 1) {
      markCurrentAsViewed();
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Retrocede a la story anterior
  void previousStory() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Marca la story actual como vista
  void markCurrentAsViewed() {
    final newViewed = Set<int>.from(state.viewedIndices)
      ..add(state.currentIndex);
    state = state.copyWith(viewedIndices: newViewed);
  }

  /// Establece el indice actual directamente
  void setCurrentIndex(int index) {
    if (index >= 0 && index < state.stories.length) {
      state = state.copyWith(currentIndex: index);
    }
  }
}

/// Provider de Stories
/// Uses ref.watch on regionalPrefsProvider to recreate when language changes
final storiesProvider =
    StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  final client = ref.read(supabaseClientProvider);
  final cache = ref.read(cacheServiceProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return StoriesNotifier(
    client,
    cache,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});
