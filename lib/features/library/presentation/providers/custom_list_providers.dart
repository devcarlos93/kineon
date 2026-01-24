import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/data/repositories/media_repository_impl.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../data/repositories/custom_list_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LÍMITES DE LISTAS PERSONALIZADAS
// ═══════════════════════════════════════════════════════════════════════════

/// Límites para usuarios gratuitos
class ListLimits {
  static const int freeMaxLists = 1;
  static const int freeMaxItemsPerList = 10;

  // Pro: sin límites (usamos números altos)
  static const int proMaxLists = 100;
  static const int proMaxItemsPerList = 500;
}

/// Resultado de verificación de límites
class ListLimitResult {
  final bool allowed;
  final ListLimitReason? reason;
  final int current;
  final int limit;

  const ListLimitResult({
    required this.allowed,
    this.reason,
    this.current = 0,
    this.limit = 0,
  });

  static const ListLimitResult ok = ListLimitResult(allowed: true);
}

enum ListLimitReason {
  maxListsReached,
  maxItemsReached,
}

/// Excepción cuando se alcanza un límite
class ListLimitException implements Exception {
  final ListLimitReason reason;
  final int current;
  final int limit;

  const ListLimitException(this.reason, this.current, this.limit);

  @override
  String toString() => 'ListLimitException: $reason (current: $current, limit: $limit)';
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE LISTAS PERSONALIZADAS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para obtener todas las listas del usuario
final customListsProvider = FutureProvider.autoDispose<List<CustomList>>((ref) async {
  final repo = ref.watch(customListRepositoryProvider);
  return repo.getUserLists();
});

/// Provider para obtener items de una lista específica
final listItemsProvider =
    FutureProvider.autoDispose.family<List<ListItem>, String>((ref, listId) async {
  final repo = ref.watch(customListRepositoryProvider);
  return repo.getListItems(listId);
});

/// Provider para obtener items de una lista con detalles completos (título, año, poster)
final listItemsWithDetailsProvider =
    FutureProvider.autoDispose.family<List<ListItemWithDetails>, String>((ref, listId) async {
  final repo = ref.watch(customListRepositoryProvider);
  final mediaRepo = ref.watch(mediaRepositoryProvider);

  final items = await repo.getListItems(listId);
  final detailedItems = <ListItemWithDetails>[];

  for (final item in items) {
    String? title;
    int? releaseYear;
    String? posterPath = item.posterPath;

    // Fetch details from TMDB
    try {
      if (item.contentType == ContentType.movie) {
        final result = await mediaRepo.getMovieDetails(item.tmdbId);
        result.fold(
          (_) => null,
          (details) {
            title = details.title;
            releaseYear = details.releaseYear;
            posterPath ??= details.posterPath;
          },
        );
      } else {
        final result = await mediaRepo.getTvDetails(item.tmdbId);
        result.fold(
          (_) => null,
          (details) {
            title = details.title;
            releaseYear = details.releaseYear;
            posterPath ??= details.posterPath;
          },
        );
      }
    } catch (_) {
      // Si falla, usamos los datos básicos que tenemos
    }

    detailedItems.add(ListItemWithDetails(
      id: item.id,
      tmdbId: item.tmdbId,
      contentType: item.contentType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
      addedAt: item.addedAt,
    ));
  }

  return detailedItems;
});

/// Provider para verificar si un item está en una lista
class ItemInListParams {
  final String listId;
  final int tmdbId;
  final ContentType contentType;

  const ItemInListParams({
    required this.listId,
    required this.tmdbId,
    required this.contentType,
  });

  @override
  bool operator ==(Object other) =>
      other is ItemInListParams &&
      other.listId == listId &&
      other.tmdbId == tmdbId &&
      other.contentType == contentType;

  @override
  int get hashCode => Object.hash(listId, tmdbId, contentType);
}

final isItemInListProvider =
    FutureProvider.autoDispose.family<bool, ItemInListParams>((ref, params) async {
  final repo = ref.watch(customListRepositoryProvider);
  return repo.isItemInList(params.listId, params.tmdbId, params.contentType);
});

/// Provider para obtener listas que contienen un item
class ItemParams {
  final int tmdbId;
  final ContentType contentType;

  const ItemParams({required this.tmdbId, required this.contentType});

  @override
  bool operator ==(Object other) =>
      other is ItemParams &&
      other.tmdbId == tmdbId &&
      other.contentType == contentType;

  @override
  int get hashCode => Object.hash(tmdbId, contentType);
}

final listsContainingItemProvider =
    FutureProvider.autoDispose.family<List<CustomList>, ItemParams>((ref, params) async {
  final repo = ref.watch(customListRepositoryProvider);
  return repo.getListsContainingItem(params.tmdbId, params.contentType);
});

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER PARA ACCIONES
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para manejar acciones de listas personalizadas
class CustomListActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomListRepository _repository;
  final Ref _ref;

  CustomListActionsNotifier(this._repository, this._ref)
      : super(const AsyncData(null));

  bool get _isPro => _ref.read(isProProvider);

  int get _maxLists => _isPro ? ListLimits.proMaxLists : ListLimits.freeMaxLists;
  int get _maxItemsPerList => _isPro ? ListLimits.proMaxItemsPerList : ListLimits.freeMaxItemsPerList;

  /// Verifica si puede crear una nueva lista
  Future<ListLimitResult> canCreateList() async {
    if (_isPro) return ListLimitResult.ok;

    try {
      final lists = await _repository.getUserLists();
      if (lists.length >= _maxLists) {
        return ListLimitResult(
          allowed: false,
          reason: ListLimitReason.maxListsReached,
          current: lists.length,
          limit: _maxLists,
        );
      }
      return ListLimitResult.ok;
    } catch (e) {
      return ListLimitResult.ok; // Fail-open
    }
  }

  /// Verifica si puede añadir items a una lista
  Future<ListLimitResult> canAddItemToList(String listId) async {
    if (_isPro) return ListLimitResult.ok;

    try {
      final items = await _repository.getListItems(listId);
      if (items.length >= _maxItemsPerList) {
        return ListLimitResult(
          allowed: false,
          reason: ListLimitReason.maxItemsReached,
          current: items.length,
          limit: _maxItemsPerList,
        );
      }
      return ListLimitResult.ok;
    } catch (e) {
      return ListLimitResult.ok; // Fail-open
    }
  }

  /// Crear nueva lista
  Future<CustomList?> createList(String name, String icon) async {
    if (!mounted) return null;

    // Verificar límite
    final limitCheck = await canCreateList();
    if (!limitCheck.allowed) {
      state = AsyncError(
        ListLimitException(limitCheck.reason!, limitCheck.current, limitCheck.limit),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncLoading();
    try {
      final list = await _repository.createList(name, icon);
      _invalidateLists();
      if (!mounted) return list;
      state = const AsyncData(null);
      return list;
    } catch (e) {
      if (!mounted) return null;
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  /// Actualizar lista (nombre/icon)
  Future<bool> updateList(String id, {String? name, String? icon}) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.updateList(id, name: name, icon: icon);
      _invalidateLists();
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Eliminar lista
  Future<bool> deleteList(String id) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.deleteList(id);
      _invalidateLists();
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Agregar item a lista
  Future<bool> addItemToList(
    String listId,
    int tmdbId,
    ContentType contentType, {
    String? note,
    String? posterPath,
  }) async {
    if (!mounted) return false;

    // Verificar límite
    final limitCheck = await canAddItemToList(listId);
    if (!limitCheck.allowed) {
      state = AsyncError(
        ListLimitException(limitCheck.reason!, limitCheck.current, limitCheck.limit),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      await _repository.addItemToList(
        listId,
        tmdbId,
        contentType,
        note: note,
        posterPath: posterPath,
      );
      _invalidateLists();
      _ref.invalidate(listItemsProvider(listId));
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Quitar item de lista
  Future<bool> removeItemFromList(
    String listId,
    int tmdbId,
    ContentType contentType,
  ) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.removeItemFromList(listId, tmdbId, contentType);
      _invalidateLists();
      _ref.invalidate(listItemsProvider(listId));
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  void _invalidateLists() {
    _ref.invalidate(customListsProvider);
  }
}

/// Provider para acciones de listas personalizadas
final customListActionsProvider =
    StateNotifierProvider<CustomListActionsNotifier, AsyncValue<void>>((ref) {
  return CustomListActionsNotifier(
    ref.watch(customListRepositoryProvider),
    ref,
  );
});
