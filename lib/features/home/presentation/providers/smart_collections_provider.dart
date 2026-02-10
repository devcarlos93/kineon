import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/smart_collection.dart';

/// State for Smart Collections
class SmartCollectionsState {
  final List<SmartCollection> collections;
  final bool isLoading;
  final String? error;

  const SmartCollectionsState({
    this.collections = const [],
    this.isLoading = true,
    this.error,
  });

  SmartCollectionsState copyWith({
    List<SmartCollection>? collections,
    bool? isLoading,
    String? error,
  }) {
    return SmartCollectionsState(
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasData => collections.isNotEmpty;
}

/// Notifier for Smart Collections with cache-first strategy
class SmartCollectionsNotifier extends StateNotifier<SmartCollectionsState> {
  final SupabaseClient _client;
  final CacheService _cache;
  final String language;
  final String region;

  String get _cacheKey => '${language.split('-').first}_smart_collections_v1';
  static const int _cacheTtlMinutes = 10080; // 7 days

  SmartCollectionsNotifier(
    this._client,
    this._cache, {
    this.language = 'es-ES',
    this.region = 'ES',
  }) : super(const SmartCollectionsState()) {
    loadCollections();
  }

  /// Load collections with cache-first strategy
  Future<void> loadCollections() async {
    if (!mounted) return;

    // STEP 1: Load from cache for instant render
    final cachedData = _cache.get<Map<String, dynamic>>(_cacheKey);

    if (cachedData != null) {
      try {
        final cached = _parseFromCache(cachedData);
        if (cached.isNotEmpty) {
          state = state.copyWith(
            collections: cached,
            isLoading: false,
          );
        }
      } catch (_) {}
    }

    // If cache is fresh and has data, don't refetch
    if (state.hasData) {
      state = state.copyWith(isLoading: false);
      // Still try to refresh in background but don't block
      _fetchFromServer();
      return;
    }

    // No cache — show loading
    if (!state.hasData) {
      state = state.copyWith(isLoading: true, error: null);
    }

    await _fetchFromServer();
  }

  Future<void> _fetchFromServer() async {
    try {
      // Fetch active collections with their items
      final response = await _client
          .from('smart_collections')
          .select('*, smart_collection_items(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);

      if (!mounted) return;

      final collections = (response as List<dynamic>)
          .map((json) => SmartCollection.fromJson(json as Map<String, dynamic>))
          .toList();

      // Enrich items with TMDB metadata
      final enriched = await _enrichWithTmdb(collections);

      if (!mounted) return;

      state = state.copyWith(
        collections: enriched,
        isLoading: false,
      );

      // Save to cache
      await _saveToCache(enriched);
    } catch (e) {
      if (!mounted) return;
      if (state.hasData) {
        // Keep cached data on error
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Enrich collection items with TMDB metadata (poster, title, rating)
  Future<List<SmartCollection>> _enrichWithTmdb(
    List<SmartCollection> collections,
  ) async {
    final enriched = <SmartCollection>[];

    for (final collection in collections) {
      if (collection.items.isEmpty) {
        enriched.add(collection);
        continue;
      }

      // Group items by content type for bulk fetching
      final movieIds = collection.items
          .where((i) => i.contentType == 'movie')
          .map((i) => i.tmdbId)
          .toList();

      final tvIds = collection.items
          .where((i) => i.contentType == 'tv')
          .map((i) => i.tmdbId)
          .toList();

      final tmdbData = <int, Map<String, dynamic>>{};

      try {
        // Fetch movie metadata via bulk endpoint
        if (movieIds.isNotEmpty) {
          final movieResults = await _client.callTmdbBulk(
            ids: movieIds,
            contentType: 'movie',
            language: language,
            region: region,
          );
          for (final item in movieResults) {
            final id = item['id'] as int?;
            if (id != null) tmdbData[id] = item;
          }
        }

        // Fetch TV metadata via bulk endpoint
        if (tvIds.isNotEmpty) {
          final tvResults = await _client.callTmdbBulk(
            ids: tvIds,
            contentType: 'tv',
            language: language,
            region: region,
          );
          for (final item in tvResults) {
            final id = item['id'] as int?;
            if (id != null) tmdbData[id] = item;
          }
        }
      } catch (e) {
        // If TMDB fails, still show collections without metadata
      }

      // Merge TMDB data into items
      final enrichedItems = collection.items.map((item) {
        final data = tmdbData[item.tmdbId];
        if (data == null) return item;

        return item.copyWith(
          title: data['title'] as String? ??
              data['name'] as String? ??
              item.title,
          posterPath: data['poster_path'] as String? ?? item.posterPath,
          voteAverage: (data['vote_average'] as num?)?.toDouble() ??
              item.voteAverage,
        );
      }).toList();

      enriched.add(collection.copyWith(items: enrichedItems));
    }

    return enriched;
  }

  List<SmartCollection> _parseFromCache(Map<String, dynamic> data) {
    final list = data['collections'] as List<dynamic>? ?? [];
    return list
        .map((json) => SmartCollection.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToCache(List<SmartCollection> collections) async {
    try {
      await _cache.put(
        _cacheKey,
        {
          'collections': collections.map((c) => c.toJson()).toList(),
          'cached_at': DateTime.now().toIso8601String(),
        },
        ttlMinutes: _cacheTtlMinutes,
        flush: true,
      );
    } catch (_) {}
  }

  /// Force refresh (clear cache + reload)
  Future<void> refresh() async {
    if (!mounted) return;
    await _cache.delete(_cacheKey);
    state = state.copyWith(isLoading: true);
    await _fetchFromServer();
  }

  /// Find collection by slug
  SmartCollection? findBySlug(String slug) {
    try {
      return state.collections.firstWhere((c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }

  /// Load a single collection by slug from server
  Future<SmartCollection?> loadBySlug(String slug) async {
    // Check cached first
    final cached = findBySlug(slug);
    if (cached != null) return cached;

    try {
      final response = await _client
          .from('smart_collections')
          .select('*, smart_collection_items(*)')
          .eq('slug', slug)
          .maybeSingle();

      if (response == null) return null;

      final collection = SmartCollection.fromJson(response);

      // Enrich with TMDB
      final enriched = await _enrichWithTmdb([collection]);
      return enriched.isNotEmpty ? enriched.first : collection;
    } catch (_) {
      return null;
    }
  }
}

/// Provider for Smart Collections
/// Uses ref.watch on regionalPrefsProvider to recreate when language changes
final smartCollectionsProvider =
    StateNotifierProvider<SmartCollectionsNotifier, SmartCollectionsState>(
        (ref) {
  final client = ref.read(supabaseClientProvider);
  final cache = ref.read(cacheServiceProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return SmartCollectionsNotifier(
    client,
    cache,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});
