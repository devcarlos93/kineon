import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Map icon name strings (from AI/DB) to Material IconData
IconData collectionIconFromName(String name) {
  const map = <String, IconData>{
    'movie': Icons.movie_outlined,
    'theaters': Icons.theaters_outlined,
    'psychology': Icons.psychology_outlined,
    'explore': Icons.explore_outlined,
    'favorite': Icons.favorite_outlined,
    'bolt': Icons.bolt_outlined,
    'local_fire_department': Icons.local_fire_department_outlined,
    'nightlight': Icons.nightlight_outlined,
    'beach_access': Icons.beach_access_outlined,
    'wb_sunny': Icons.wb_sunny_outlined,
    'cloud': Icons.cloud_outlined,
    'auto_awesome': Icons.auto_awesome_outlined,
    'rocket_launch': Icons.rocket_launch_outlined,
    'diversity_3': Icons.diversity_3_outlined,
    'self_improvement': Icons.self_improvement_outlined,
    'visibility': Icons.visibility_outlined,
    'palette': Icons.palette_outlined,
    'music_note': Icons.music_note_outlined,
    'castle': Icons.castle_outlined,
    'dark_mode': Icons.dark_mode_outlined,
    'mood': Icons.mood_outlined,
    'sentiment_satisfied': Icons.sentiment_satisfied_outlined,
    'flight': Icons.flight_outlined,
    'terrain': Icons.terrain_outlined,
    'water_drop': Icons.water_drop_outlined,
    'spa': Icons.spa_outlined,
    'forest': Icons.forest_outlined,
    'celebration': Icons.celebration_outlined,
    'lightbulb': Icons.lightbulb_outlined,
    'science': Icons.science_outlined,
    'history_edu': Icons.history_edu_outlined,
    'military_tech': Icons.military_tech_outlined,
    'family_restroom': Icons.family_restroom_outlined,
    'sports_esports': Icons.sports_esports_outlined,
    'diamond': Icons.diamond_outlined,
    'emoji_objects': Icons.emoji_objects_outlined,
    'stream': Icons.stream_outlined,
  };
  return map[name] ?? Icons.movie_outlined;
}

/// AI-generated thematic collection
class SmartCollection {
  final String id;
  final String titleEn;
  final String titleEs;
  final String descriptionEn;
  final String descriptionEs;
  final String slug;
  final String? backdropPath;
  final String icon;
  final bool isActive;
  final DateTime weekOf;
  final List<SmartCollectionItem> items;

  const SmartCollection({
    required this.id,
    required this.titleEn,
    required this.titleEs,
    required this.descriptionEn,
    required this.descriptionEs,
    required this.slug,
    this.backdropPath,
    required this.icon,
    this.isActive = true,
    required this.weekOf,
    this.items = const [],
  });

  String localizedTitle(String locale) =>
      locale.startsWith('en') ? titleEn : titleEs;

  String localizedDescription(String locale) =>
      locale.startsWith('en') ? descriptionEn : descriptionEs;

  IconData get iconData => collectionIconFromName(icon);

  String? get backdropUrl => backdropPath != null
      ? '${AppConstants.tmdbBackdropMedium}$backdropPath'
      : null;

  String? get backdropUrlLarge => backdropPath != null
      ? '${AppConstants.tmdbBackdropLarge}$backdropPath'
      : null;

  factory SmartCollection.fromJson(Map<String, dynamic> json) {
    final itemsList = json['smart_collection_items'] as List<dynamic>? ??
        json['items'] as List<dynamic>? ??
        [];

    return SmartCollection(
      id: json['id'] as String,
      titleEn: json['title_en'] as String? ?? '',
      titleEs: json['title_es'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionEs: json['description_es'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String?,
      icon: json['emoji'] as String? ?? json['icon'] as String? ?? 'movie',
      isActive: json['is_active'] as bool? ?? true,
      weekOf: DateTime.parse(json['week_of'] as String),
      items: itemsList
          .map((e) => SmartCollectionItem.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_es': titleEs,
      'description_en': descriptionEn,
      'description_es': descriptionEs,
      'slug': slug,
      'backdrop_path': backdropPath,
      'emoji': icon,
      'is_active': isActive,
      'week_of': weekOf.toIso8601String().split('T').first,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  SmartCollection copyWith({
    String? id,
    String? titleEn,
    String? titleEs,
    String? descriptionEn,
    String? descriptionEs,
    String? slug,
    String? backdropPath,
    String? icon,
    bool? isActive,
    DateTime? weekOf,
    List<SmartCollectionItem>? items,
  }) {
    return SmartCollection(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleEs: titleEs ?? this.titleEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      slug: slug ?? this.slug,
      backdropPath: backdropPath ?? this.backdropPath,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      weekOf: weekOf ?? this.weekOf,
      items: items ?? this.items,
    );
  }
}

/// Item within a smart collection
class SmartCollectionItem {
  final String id;
  final String collectionId;
  final int tmdbId;
  final String contentType;
  final int position;
  final String reasonEn;
  final String reasonEs;

  // Transient fields loaded from TMDB/cache
  final String? title;
  final String? posterPath;
  final double? voteAverage;

  const SmartCollectionItem({
    required this.id,
    required this.collectionId,
    required this.tmdbId,
    required this.contentType,
    required this.position,
    this.reasonEn = '',
    this.reasonEs = '',
    this.title,
    this.posterPath,
    this.voteAverage,
  });

  String localizedReason(String locale) =>
      locale.startsWith('en') ? reasonEn : reasonEs;

  String? get posterUrl => posterPath != null
      ? '${AppConstants.tmdbPosterMedium}$posterPath'
      : null;

  ContentType get contentTypeEnum =>
      contentType == 'tv' ? ContentType.tv : ContentType.movie;

  factory SmartCollectionItem.fromJson(Map<String, dynamic> json) {
    return SmartCollectionItem(
      id: json['id'] as String? ?? '',
      collectionId: json['collection_id'] as String? ?? '',
      tmdbId: json['tmdb_id'] as int,
      contentType: json['content_type'] as String? ?? 'movie',
      position: json['position'] as int? ?? 0,
      reasonEn: json['reason_en'] as String? ?? '',
      reasonEs: json['reason_es'] as String? ?? '',
      title: json['title'] as String?,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'tmdb_id': tmdbId,
      'content_type': contentType,
      'position': position,
      'reason_en': reasonEn,
      'reason_es': reasonEs,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (voteAverage != null) 'vote_average': voteAverage,
    };
  }

  SmartCollectionItem copyWith({
    String? id,
    String? collectionId,
    int? tmdbId,
    String? contentType,
    int? position,
    String? reasonEn,
    String? reasonEs,
    String? title,
    String? posterPath,
    double? voteAverage,
  }) {
    return SmartCollectionItem(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      tmdbId: tmdbId ?? this.tmdbId,
      contentType: contentType ?? this.contentType,
      position: position ?? this.position,
      reasonEn: reasonEn ?? this.reasonEn,
      reasonEs: reasonEs ?? this.reasonEs,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
    );
  }
}
