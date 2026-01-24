import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import 'media_item.dart';

/// Detalles completos de una película
class MovieDetails extends Equatable {
  final int id;
  final String title;
  final String? originalTitle;
  final String? tagline;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final String? releaseDate;
  final int? runtime;
  final int? budget;
  final int? revenue;
  final String? status;
  final List<Genre> genres;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<SpokenLanguage> spokenLanguages;
  final String? homepage;
  final String? imdbId;
  final bool adult;
  final String? originalLanguage;
  final Videos? videos;
  final Credits? credits;
  final List<MediaItem>? similar;
  final List<MediaItem>? recommendations;
  final WatchProviders? watchProviders;

  const MovieDetails({
    required this.id,
    required this.title,
    this.originalTitle,
    this.tagline,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.popularity = 0,
    this.releaseDate,
    this.runtime,
    this.budget,
    this.revenue,
    this.status,
    this.genres = const [],
    this.productionCompanies = const [],
    this.productionCountries = const [],
    this.spokenLanguages = const [],
    this.homepage,
    this.imdbId,
    this.adult = false,
    this.originalLanguage,
    this.videos,
    this.credits,
    this.similar,
    this.recommendations,
    this.watchProviders,
  });

  /// URL completa del poster
  String? get posterUrl => posterPath != null 
      ? '${AppConstants.tmdbPosterLarge}$posterPath'
      : null;

  /// URL completa del backdrop
  String? get backdropUrl => backdropPath != null 
      ? '${AppConstants.tmdbBackdropLarge}$backdropPath'
      : null;

  /// Duración formateada (ej: "2h 30min")
  String? get runtimeFormatted {
    if (runtime == null) return null;
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}min';
    if (hours > 0) return '${hours}h';
    return '${minutes}min';
  }

  /// Año de lanzamiento
  int? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return int.tryParse(releaseDate!.split('-').first);
  }

  /// Géneros como string
  String get genresText => genres.map((g) => g.name).join(', ');

  /// Rating formateado
  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  /// Director (del credits)
  String? get director {
    if (credits == null) return null;
    final directorCrew = credits!.crew.where((c) => c.job == 'Director').toList();
    if (directorCrew.isEmpty) return null;
    return directorCrew.map((c) => c.name).join(', ');
  }

  /// Trailer de YouTube (del videos)
  String? get trailerKey {
    if (videos == null || videos!.results.isEmpty) return null;
    final trailer = videos!.results.firstWhere(
      (v) => v.type == 'Trailer' && v.site == 'YouTube',
      orElse: () => videos!.results.first,
    );
    return trailer.key;
  }

  @override
  List<Object?> get props => [id, title];
}

/// Género
class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Compañía productora
class ProductionCompany extends Equatable {
  final int id;
  final String name;
  final String? logoPath;
  final String? originCountry;

  const ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  String? get logoUrl => logoPath != null 
      ? '${AppConstants.tmdbPosterSmall}$logoPath'
      : null;

  @override
  List<Object?> get props => [id, name];
}

/// País de producción
class ProductionCountry extends Equatable {
  final String iso31661;
  final String name;

  const ProductionCountry({required this.iso31661, required this.name});

  @override
  List<Object?> get props => [iso31661, name];
}

/// Idioma hablado
class SpokenLanguage extends Equatable {
  final String iso6391;
  final String name;
  final String? englishName;

  const SpokenLanguage({
    required this.iso6391,
    required this.name,
    this.englishName,
  });

  @override
  List<Object?> get props => [iso6391, name];
}

/// Videos
class Videos extends Equatable {
  final List<Video> results;

  const Videos({this.results = const []});

  @override
  List<Object?> get props => [results];
}

/// Video individual
class Video extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.official = false,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/mqdefault.jpg';

  @override
  List<Object?> get props => [id, key];
}

/// Créditos
class Credits extends Equatable {
  final List<CastMember> cast;
  final List<CrewMember> crew;

  const Credits({this.cast = const [], this.crew = const []});

  @override
  List<Object?> get props => [cast, crew];
}

/// Miembro del reparto
class CastMember extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order = 0,
  });

  String? get profileUrl => profilePath != null 
      ? '${AppConstants.tmdbPosterSmall}$profilePath'
      : null;

  @override
  List<Object?> get props => [id, name];
}

/// Miembro del equipo
class CrewMember extends Equatable {
  final int id;
  final String name;
  final String? job;
  final String? department;
  final String? profilePath;

  const CrewMember({
    required this.id,
    required this.name,
    this.job,
    this.department,
    this.profilePath,
  });

  String? get profileUrl => profilePath != null
      ? '${AppConstants.tmdbPosterSmall}$profilePath'
      : null;

  @override
  List<Object?> get props => [id, name, job];
}

/// Proveedores de streaming/compra/alquiler
class WatchProviders extends Equatable {
  final String? link; // Link a JustWatch
  final List<WatchProvider> flatrate; // Streaming (Netflix, etc)
  final List<WatchProvider> rent; // Alquiler
  final List<WatchProvider> buy; // Compra

  const WatchProviders({
    this.link,
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
  });

  /// Retorna true si hay algún proveedor disponible
  bool get hasProviders => flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;

  /// Proveedores de streaming (prioridad)
  List<WatchProvider> get streamingProviders => flatrate;

  @override
  List<Object?> get props => [link, flatrate, rent, buy];
}

/// Proveedor individual (Netflix, Prime, etc)
class WatchProvider extends Equatable {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final int displayPriority;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    this.displayPriority = 0,
  });

  /// URL completa del logo
  String? get logoUrl => logoPath != null
      ? '${AppConstants.tmdbPosterSmall}$logoPath'
      : null;

  @override
  List<Object?> get props => [providerId, providerName];
}
