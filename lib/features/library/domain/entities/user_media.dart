import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/domain/entities/media_item.dart';

/// Item en la watchlist del usuario
class WatchlistItem extends Equatable {
  final String id;
  final String odId;
  final int tmdbId;
  final ContentType contentType;
  final WatchStatus status;
  final DateTime addedAt;
  final DateTime? updatedAt;
  final MediaItem? mediaItem;

  const WatchlistItem({
    required this.id,
    required this.odId,
    required this.tmdbId,
    required this.contentType,
    required this.status,
    required this.addedAt,
    this.updatedAt,
    this.mediaItem,
  });

  @override
  List<Object?> get props => [id, odId, tmdbId, contentType, status];

  WatchlistItem copyWith({
    String? id,
    String? odId,
    int? tmdbId,
    ContentType? contentType,
    WatchStatus? status,
    DateTime? addedAt,
    DateTime? updatedAt,
    MediaItem? mediaItem,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      tmdbId: tmdbId ?? this.tmdbId,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaItem: mediaItem ?? this.mediaItem,
    );
  }
}

/// Item favorito del usuario
class FavoriteItem extends Equatable {
  final String id;
  final String odId;
  final int tmdbId;
  final ContentType contentType;
  final DateTime addedAt;
  final MediaItem? mediaItem;

  const FavoriteItem({
    required this.id,
    required this.odId,
    required this.tmdbId,
    required this.contentType,
    required this.addedAt,
    this.mediaItem,
  });

  @override
  List<Object?> get props => [id, odId, tmdbId, contentType];

  FavoriteItem copyWith({
    String? id,
    String? odId,
    int? tmdbId,
    ContentType? contentType,
    DateTime? addedAt,
    MediaItem? mediaItem,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      tmdbId: tmdbId ?? this.tmdbId,
      contentType: contentType ?? this.contentType,
      addedAt: addedAt ?? this.addedAt,
      mediaItem: mediaItem ?? this.mediaItem,
    );
  }
}

/// Item visto por el usuario
class WatchedItem extends Equatable {
  final String id;
  final String odId;
  final int tmdbId;
  final ContentType contentType;
  final DateTime watchedAt;
  final int? rating;
  final String? review;
  final MediaItem? mediaItem;

  const WatchedItem({
    required this.id,
    required this.odId,
    required this.tmdbId,
    required this.contentType,
    required this.watchedAt,
    this.rating,
    this.review,
    this.mediaItem,
  });

  @override
  List<Object?> get props => [id, odId, tmdbId, contentType];

  WatchedItem copyWith({
    String? id,
    String? odId,
    int? tmdbId,
    ContentType? contentType,
    DateTime? watchedAt,
    int? rating,
    String? review,
    MediaItem? mediaItem,
  }) {
    return WatchedItem(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      tmdbId: tmdbId ?? this.tmdbId,
      contentType: contentType ?? this.contentType,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      mediaItem: mediaItem ?? this.mediaItem,
    );
  }
}

/// Lista personalizada del usuario
class CustomList extends Equatable {
  final String id;
  final String odId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int itemCount;
  final String? coverPath;

  const CustomList({
    required this.id,
    required this.odId,
    required this.name,
    this.description,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
    this.itemCount = 0,
    this.coverPath,
  });

  @override
  List<Object?> get props => [id, odId, name];

  CustomList copyWith({
    String? id,
    String? odId,
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
    String? coverPath,
  }) {
    return CustomList(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
      coverPath: coverPath ?? this.coverPath,
    );
  }
}

/// Item dentro de una lista personalizada
class CustomListItem extends Equatable {
  final String id;
  final String listId;
  final int tmdbId;
  final ContentType contentType;
  final DateTime addedAt;
  final int order;
  final String? notes;
  final MediaItem? mediaItem;

  const CustomListItem({
    required this.id,
    required this.listId,
    required this.tmdbId,
    required this.contentType,
    required this.addedAt,
    this.order = 0,
    this.notes,
    this.mediaItem,
  });

  @override
  List<Object?> get props => [id, listId, tmdbId, contentType];

  CustomListItem copyWith({
    String? id,
    String? listId,
    int? tmdbId,
    ContentType? contentType,
    DateTime? addedAt,
    int? order,
    String? notes,
    MediaItem? mediaItem,
  }) {
    return CustomListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      tmdbId: tmdbId ?? this.tmdbId,
      contentType: contentType ?? this.contentType,
      addedAt: addedAt ?? this.addedAt,
      order: order ?? this.order,
      notes: notes ?? this.notes,
      mediaItem: mediaItem ?? this.mediaItem,
    );
  }
}
