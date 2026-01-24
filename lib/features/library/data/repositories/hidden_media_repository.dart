import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import 'library_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELO
// ═══════════════════════════════════════════════════════════════════════════

class HiddenMediaItem {
  final int tmdbId;
  final ContentType contentType;
  final DateTime hiddenAt;

  const HiddenMediaItem({
    required this.tmdbId,
    required this.contentType,
    required this.hiddenAt,
  });

  factory HiddenMediaItem.fromJson(Map<String, dynamic> json) {
    return HiddenMediaItem(
      tmdbId: json['tmdb_id'] as int,
      contentType: json['content_type'] == 'tv' ? ContentType.tv : ContentType.movie,
      hiddenAt: DateTime.parse(json['hidden_at'] as String),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORIO
// ═══════════════════════════════════════════════════════════════════════════

class HiddenMediaRepository {
  final SupabaseClient _client;

  HiddenMediaRepository(this._client);

  /// Oculta un item ("No me interesa")
  Future<void> hide(int tmdbId, ContentType contentType) async {
    await _client.rpc('hide_media', params: {
      'p_tmdb_id': tmdbId,
      'p_content_type': contentType.name,
    });
  }

  /// Desoculta un item (undo)
  Future<void> unhide(int tmdbId, ContentType contentType) async {
    await _client.rpc('unhide_media', params: {
      'p_tmdb_id': tmdbId,
      'p_content_type': contentType.name,
    });
  }

  /// Obtiene todos los IDs ocultos (para filtrar)
  Future<Set<(int, ContentType)>> getHiddenIds() async {
    final result = await _client.rpc('get_hidden_media_ids');

    if (result is! List) return {};

    return result.map((item) {
      final map = item as Map<String, dynamic>;
      final tmdbId = map['tmdb_id'] as int;
      final type = map['content_type'] == 'tv' ? ContentType.tv : ContentType.movie;
      return (tmdbId, type);
    }).toSet();
  }

  /// Verifica si un item está oculto
  Future<bool> isHidden(int tmdbId, ContentType contentType) async {
    final result = await _client.rpc('is_media_hidden', params: {
      'p_tmdb_id': tmdbId,
      'p_content_type': contentType.name,
    });
    return result == true;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final hiddenMediaRepositoryProvider = Provider<HiddenMediaRepository>((ref) {
  return HiddenMediaRepository(ref.watch(supabaseClientProvider));
});

/// Provider que mantiene los IDs ocultos en memoria para filtrado rápido
final hiddenMediaIdsProvider = FutureProvider.autoDispose<Set<(int, ContentType)>>((ref) async {
  final repo = ref.watch(hiddenMediaRepositoryProvider);
  return repo.getHiddenIds();
});

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER PARA ACCIONES
// ═══════════════════════════════════════════════════════════════════════════

class HiddenMediaNotifier extends StateNotifier<Set<(int, ContentType)>> {
  final HiddenMediaRepository _repository;
  final Ref _ref;

  HiddenMediaNotifier(this._repository, this._ref) : super({}) {
    _loadHiddenIds();
  }

  Future<void> _loadHiddenIds() async {
    try {
      final ids = await _repository.getHiddenIds();
      if (mounted) state = ids;
    } catch (_) {}
  }

  /// Oculta un item
  Future<void> hide(int tmdbId, ContentType contentType) async {
    // Optimistic update
    state = {...state, (tmdbId, contentType)};

    try {
      await _repository.hide(tmdbId, contentType);
      // Invalidar providers que dependen de esto
      _ref.invalidate(hiddenMediaIdsProvider);
    } catch (e) {
      // Revertir si falla
      state = state.where((item) => item != (tmdbId, contentType)).toSet();
      rethrow;
    }
  }

  /// Desoculta un item (undo)
  Future<void> unhide(int tmdbId, ContentType contentType) async {
    // Optimistic update
    final previous = state;
    state = state.where((item) => item != (tmdbId, contentType)).toSet();

    try {
      await _repository.unhide(tmdbId, contentType);
      _ref.invalidate(hiddenMediaIdsProvider);
    } catch (e) {
      // Revertir si falla
      state = previous;
      rethrow;
    }
  }

  /// Verifica si un item está oculto (local, rápido)
  bool isHidden(int tmdbId, ContentType contentType) {
    return state.contains((tmdbId, contentType));
  }
}

final hiddenMediaProvider =
    StateNotifierProvider<HiddenMediaNotifier, Set<(int, ContentType)>>((ref) {
  return HiddenMediaNotifier(
    ref.watch(hiddenMediaRepositoryProvider),
    ref,
  );
});
