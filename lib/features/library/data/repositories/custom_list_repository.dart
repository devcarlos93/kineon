import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/supabase_client.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ENTITIES
// ═══════════════════════════════════════════════════════════════════════════

/// Custom list created by user
class CustomList {
  final String id;
  final String name;
  final String icon;
  final String? description;
  final bool isPublic;
  final bool isRanked;
  final int itemCount;
  final List<ListPreviewItem> previewItems; // Up to 4 items for collage
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomList({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    this.isPublic = false,
    this.isRanked = false,
    required this.itemCount,
    required this.previewItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomList.fromJson(Map<String, dynamic> json) {
    final previewItemsRaw = json['preview_items'] as List<dynamic>? ?? [];
    final previewItems = previewItemsRaw
        .map((item) => ListPreviewItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return CustomList(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🎬',
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isRanked: json['is_ranked'] as bool? ?? false,
      itemCount: json['item_count'] as int? ?? 0,
      previewItems: previewItems,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  CustomList copyWith({
    String? name,
    String? icon,
    String? description,
    bool? isPublic,
    bool? isRanked,
    int? itemCount,
    List<ListPreviewItem>? previewItems,
  }) {
    return CustomList(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      isRanked: isRanked ?? this.isRanked,
      itemCount: itemCount ?? this.itemCount,
      previewItems: previewItems ?? this.previewItems,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Preview item for list collage (minimal info needed for poster)
class ListPreviewItem {
  final int tmdbId;
  final ContentType contentType;
  final String? posterPath;

  const ListPreviewItem({
    required this.tmdbId,
    required this.contentType,
    this.posterPath,
  });

  factory ListPreviewItem.fromJson(Map<String, dynamic> json) {
    return ListPreviewItem(
      tmdbId: json['tmdb_id'] as int,
      contentType: ContentType.fromString(json['content_type'] as String),
      posterPath: json['poster_path'] as String?,
    );
  }

  String? get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w200$posterPath'
      : null;
}

/// Full item in a list
class ListItem {
  final String id;
  final String listId;
  final int tmdbId;
  final ContentType contentType;
  final int position;
  final String? note;
  final String? posterPath;
  final DateTime addedAt;

  const ListItem({
    required this.id,
    required this.listId,
    required this.tmdbId,
    required this.contentType,
    required this.position,
    this.note,
    this.posterPath,
    required this.addedAt,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      tmdbId: json['tmdb_id'] as int,
      contentType: ContentType.fromString(json['content_type'] as String),
      position: json['position'] as int? ?? 0,
      note: json['note'] as String?,
      posterPath: json['poster_path'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  String? get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w200$posterPath'
      : null;
}

/// Item con detalles completos (para mostrar en lista)
class ListItemWithDetails {
  final String id;
  final int tmdbId;
  final ContentType contentType;
  final String? title;
  final String? posterPath;
  final int? releaseYear;
  final DateTime addedAt;

  const ListItemWithDetails({
    required this.id,
    required this.tmdbId,
    required this.contentType,
    this.title,
    this.posterPath,
    this.releaseYear,
    required this.addedAt,
  });

  String? get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w200$posterPath'
      : null;
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  return CustomListRepositoryImpl(ref.watch(supabaseClientProvider));
});

// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════════════════════════════════

abstract class CustomListRepository {
  /// Get all lists for current user with preview items
  Future<List<CustomList>> getUserLists();

  /// Create a new list
  Future<CustomList> createList(String name, String icon);

  /// Update list metadata
  Future<CustomList> updateList(String id, {String? name, String? icon});

  /// Delete a list
  Future<void> deleteList(String id);

  /// Get all items in a list
  Future<List<ListItem>> getListItems(String listId);

  /// Add item to list
  Future<ListItem> addItemToList(
    String listId,
    int tmdbId,
    ContentType contentType, {
    String? note,
    String? posterPath,
  });

  /// Remove item from list
  Future<void> removeItemFromList(String listId, int tmdbId, ContentType contentType);

  /// Check if item is in list
  Future<bool> isItemInList(String listId, int tmdbId, ContentType contentType);

  /// Get lists containing an item
  Future<List<CustomList>> getListsContainingItem(int tmdbId, ContentType contentType);
}

// ═══════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════

class CustomListRepositoryImpl implements CustomListRepository {
  final SupabaseClient _client;

  CustomListRepositoryImpl(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<CustomList>> getUserLists() async {
    try {
      // Get lists with item count and preview items
      final response = await _client
          .from('user_lists')
          .select('''
            *,
            item_count:user_list_items(count),
            preview_items:user_list_items(
              tmdb_id,
              content_type,
              poster_path,
              added_at
            )
          ''')
          .eq('user_id', _userId)
          .order('updated_at', ascending: false);

      final lists = <CustomList>[];
      for (final item in response as List) {
        final json = item as Map<String, dynamic>;

        // Extract item count
        final itemCountData = json['item_count'] as List?;
        final itemCount = itemCountData?.isNotEmpty == true
            ? (itemCountData!.first as Map<String, dynamic>)['count'] as int? ?? 0
            : 0;

        // Extract preview items (limit to 4, ordered by added_at desc)
        final previewItemsRaw = json['preview_items'] as List? ?? [];
        final sortedPreviews = previewItemsRaw.cast<Map<String, dynamic>>().toList()
          ..sort((a, b) {
            final aDate = DateTime.parse(a['added_at'] as String);
            final bDate = DateTime.parse(b['added_at'] as String);
            return bDate.compareTo(aDate);
          });
        final previewItems = sortedPreviews
            .take(4)
            .map((p) => ListPreviewItem(
                  tmdbId: p['tmdb_id'] as int,
                  contentType: ContentType.fromString(p['content_type'] as String),
                  posterPath: p['poster_path'] as String?,
                ))
            .toList();

        lists.add(CustomList(
          id: json['id'] as String,
          name: json['name'] as String,
          icon: json['icon'] as String? ?? '🎬',
          description: json['description'] as String?,
          isPublic: json['is_public'] as bool? ?? false,
          isRanked: json['is_ranked'] as bool? ?? false,
          itemCount: itemCount,
          previewItems: previewItems,
          createdAt: DateTime.parse(json['created_at'] as String),
          updatedAt: DateTime.parse(json['updated_at'] as String),
        ));
      }

      return lists;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CustomList> createList(String name, String icon) async {
    try {
      final response = await _client
          .from('user_lists')
          .insert({
            'user_id': _userId,
            'name': name,
            'icon': icon,
          })
          .select()
          .single();

      return CustomList(
        id: response['id'] as String,
        name: response['name'] as String,
        icon: response['icon'] as String? ?? '🎬',
        description: response['description'] as String?,
        isPublic: response['is_public'] as bool? ?? false,
        isRanked: response['is_ranked'] as bool? ?? false,
        itemCount: 0,
        previewItems: [],
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CustomList> updateList(String id, {String? name, String? icon}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;

      if (updates.isEmpty) {
        // Nothing to update, fetch current
        final current = await _client
            .from('user_lists')
            .select()
            .eq('id', id)
            .eq('user_id', _userId)
            .single();
        return CustomList(
          id: current['id'] as String,
          name: current['name'] as String,
          icon: current['icon'] as String? ?? '🎬',
          description: current['description'] as String?,
          isPublic: current['is_public'] as bool? ?? false,
          isRanked: current['is_ranked'] as bool? ?? false,
          itemCount: 0,
          previewItems: [],
          createdAt: DateTime.parse(current['created_at'] as String),
          updatedAt: DateTime.parse(current['updated_at'] as String),
        );
      }

      final response = await _client
          .from('user_lists')
          .update(updates)
          .eq('id', id)
          .eq('user_id', _userId)
          .select()
          .single();

      return CustomList(
        id: response['id'] as String,
        name: response['name'] as String,
        icon: response['icon'] as String? ?? '🎬',
        description: response['description'] as String?,
        isPublic: response['is_public'] as bool? ?? false,
        isRanked: response['is_ranked'] as bool? ?? false,
        itemCount: 0, // Will be refreshed on next getUserLists
        previewItems: [],
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _client
          .from('user_lists')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ListItem>> getListItems(String listId) async {
    try {
      final response = await _client
          .from('user_list_items')
          .select()
          .eq('list_id', listId)
          .order('position', ascending: true);

      return (response as List)
          .map((item) => ListItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ListItem> addItemToList(
    String listId,
    int tmdbId,
    ContentType contentType, {
    String? note,
    String? posterPath,
  }) async {
    try {
      // Get max position
      final positionResponse = await _client
          .from('user_list_items')
          .select('position')
          .eq('list_id', listId)
          .order('position', ascending: false)
          .limit(1);

      final maxPosition = positionResponse.isNotEmpty
          ? (positionResponse.first['position'] as int? ?? 0)
          : 0;

      final response = await _client
          .from('user_list_items')
          .insert({
            'list_id': listId,
            'tmdb_id': tmdbId,
            'content_type': contentType.value,
            'position': maxPosition + 1,
            if (note != null) 'note': note,
            if (posterPath != null) 'poster_path': posterPath,
          })
          .select()
          .single();

      // Update list's updated_at
      await _client
          .from('user_lists')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', listId);

      return ListItem.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeItemFromList(
    String listId,
    int tmdbId,
    ContentType contentType,
  ) async {
    try {
      await _client
          .from('user_list_items')
          .delete()
          .eq('list_id', listId)
          .eq('tmdb_id', tmdbId)
          .eq('content_type', contentType.value);

      // Update list's updated_at
      await _client
          .from('user_lists')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', listId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isItemInList(
    String listId,
    int tmdbId,
    ContentType contentType,
  ) async {
    try {
      final response = await _client
          .from('user_list_items')
          .select('id')
          .eq('list_id', listId)
          .eq('tmdb_id', tmdbId)
          .eq('content_type', contentType.value)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CustomList>> getListsContainingItem(
    int tmdbId,
    ContentType contentType,
  ) async {
    try {
      // First get list IDs containing this item
      final itemsResponse = await _client
          .from('user_list_items')
          .select('list_id')
          .eq('tmdb_id', tmdbId)
          .eq('content_type', contentType.value);

      if ((itemsResponse as List).isEmpty) return [];

      final listIds = itemsResponse
          .map((item) => item['list_id'] as String)
          .toSet()
          .toList();

      // Then get those lists
      final listsResponse = await _client
          .from('user_lists')
          .select()
          .eq('user_id', _userId)
          .inFilter('id', listIds);

      return (listsResponse as List).map((item) {
        final json = item as Map<String, dynamic>;
        return CustomList(
          id: json['id'] as String,
          name: json['name'] as String,
          icon: json['icon'] as String? ?? '🎬',
          description: json['description'] as String?,
          isPublic: json['is_public'] as bool? ?? false,
          isRanked: json['is_ranked'] as bool? ?? false,
          itemCount: 0,
          previewItems: [],
          createdAt: DateTime.parse(json['created_at'] as String),
          updatedAt: DateTime.parse(json['updated_at'] as String),
        );
      }).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
