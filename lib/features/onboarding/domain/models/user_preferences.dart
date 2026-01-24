import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Modelo de preferencias de usuario para onboarding
class UserPreferences {
  final List<int> preferredGenres;
  final String moodText;
  final bool onboardingCompleted;

  const UserPreferences({
    this.preferredGenres = const [],
    this.moodText = '',
    this.onboardingCompleted = false,
  });

  UserPreferences copyWith({
    List<int>? preferredGenres,
    String? moodText,
    bool? onboardingCompleted,
  }) {
    return UserPreferences(
      preferredGenres: preferredGenres ?? this.preferredGenres,
      moodText: moodText ?? this.moodText,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_genres': preferredGenres,
      'mood_text': moodText,
      'onboarding_completed': onboardingCompleted,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredGenres: json['preferred_genres'] != null
          ? List<int>.from(json['preferred_genres'])
          : [],
      moodText: json['mood_text'] ?? '',
      onboardingCompleted: json['onboarding_completed'] ?? false,
    );
  }

  bool get hasPreferences => preferredGenres.isNotEmpty || moodText.isNotEmpty;
}

/// Enum de géneros con sus IDs de TMDB
enum Genre {
  action(28),
  comedy(35),
  drama(18),
  sciFi(878),
  horror(27),
  romance(10749),
  thriller(53),
  animation(16),
  documentary(99),
  fantasy(14);

  final int tmdbId;
  const Genre(this.tmdbId);

  /// Obtiene el nombre localizado del género
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Genre.action:
        return l10n.genreAction;
      case Genre.comedy:
        return l10n.genreComedy;
      case Genre.drama:
        return l10n.genreDrama;
      case Genre.sciFi:
        return l10n.genreSciFi;
      case Genre.horror:
        return l10n.genreHorror;
      case Genre.romance:
        return l10n.genreRomance;
      case Genre.thriller:
        return l10n.genreThriller;
      case Genre.animation:
        return l10n.genreAnimation;
      case Genre.documentary:
        return l10n.genreDocumentary;
      case Genre.fantasy:
        return l10n.genreFantasy;
    }
  }

  /// Obtiene un Genre desde su ID de TMDB
  static Genre? fromTmdbId(int id) {
    return Genre.values.cast<Genre?>().firstWhere(
      (g) => g?.tmdbId == id,
      orElse: () => null,
    );
  }
}

/// Mapeo de géneros UI -> TMDB IDs
class GenreMapping {
  GenreMapping._();

  /// Convierte set de géneros a lista de IDs de TMDB
  static List<int> genresToIds(Set<Genre> genres) {
    return genres.map((g) => g.tmdbId).toList();
  }

  /// Convierte lista de IDs de TMDB a set de géneros
  static Set<Genre> idsToGenres(List<int> ids) {
    return ids
        .map((id) => Genre.fromTmdbId(id))
        .whereType<Genre>()
        .toSet();
  }
}
