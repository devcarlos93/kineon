import '../../domain/entities/movie_details.dart';
import 'media_item_model.dart';

/// Modelo de datos para MovieDetails que viene de la API
class MovieDetailsModel extends MovieDetails {
  const MovieDetailsModel({
    required super.id,
    required super.title,
    super.originalTitle,
    super.tagline,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.voteAverage,
    super.voteCount,
    super.popularity,
    super.releaseDate,
    super.runtime,
    super.budget,
    super.revenue,
    super.status,
    super.genres,
    super.productionCompanies,
    super.productionCountries,
    super.spokenLanguages,
    super.homepage,
    super.imdbId,
    super.adult,
    super.originalLanguage,
    super.videos,
    super.credits,
    super.similar,
    super.recommendations,
    super.watchProviders,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? json['original_name'] as String?,
      tagline: json['tagline'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String?,
      runtime: json['runtime'] as int?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      status: json['status'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => ProductionCompanyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productionCountries: (json['production_countries'] as List<dynamic>?)
              ?.map((e) => ProductionCountryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      spokenLanguages: (json['spoken_languages'] as List<dynamic>?)
              ?.map((e) => SpokenLanguageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      homepage: json['homepage'] as String?,
      imdbId: json['imdb_id'] as String?,
      adult: json['adult'] as bool? ?? false,
      originalLanguage: json['original_language'] as String?,
      videos: json['videos'] != null 
          ? VideosModel.fromJson(json['videos'] as Map<String, dynamic>) 
          : null,
      credits: json['credits'] != null 
          ? CreditsModel.fromJson(json['credits'] as Map<String, dynamic>) 
          : null,
      similar: json['similar'] != null 
          ? (json['similar']['results'] as List<dynamic>?)
              ?.map((e) => MediaItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      recommendations: json['recommendations'] != null
          ? (json['recommendations']['results'] as List<dynamic>?)
              ?.map((e) => MediaItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      watchProviders: json['watch/providers'] != null
          ? WatchProvidersModel.fromJson(json['watch/providers'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GenreModel extends Genre {
  const GenreModel({required super.id, required super.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}

class ProductionCompanyModel extends ProductionCompany {
  const ProductionCompanyModel({
    required super.id,
    required super.name,
    super.logoPath,
    super.originCountry,
  });

  factory ProductionCompanyModel.fromJson(Map<String, dynamic> json) {
    return ProductionCompanyModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String?,
    );
  }
}

class ProductionCountryModel extends ProductionCountry {
  const ProductionCountryModel({required super.iso31661, required super.name});

  factory ProductionCountryModel.fromJson(Map<String, dynamic> json) {
    return ProductionCountryModel(
      iso31661: json['iso_3166_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class SpokenLanguageModel extends SpokenLanguage {
  const SpokenLanguageModel({
    required super.iso6391,
    required super.name,
    super.englishName,
  });

  factory SpokenLanguageModel.fromJson(Map<String, dynamic> json) {
    return SpokenLanguageModel(
      iso6391: json['iso_639_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
      englishName: json['english_name'] as String?,
    );
  }
}

class VideosModel extends Videos {
  const VideosModel({super.results});

  factory VideosModel.fromJson(Map<String, dynamic> json) {
    return VideosModel(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.key,
    required super.name,
    required super.site,
    required super.type,
    super.official,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      official: json['official'] as bool? ?? false,
    );
  }
}

class CreditsModel extends Credits {
  const CreditsModel({super.cast, super.crew});

  factory CreditsModel.fromJson(Map<String, dynamic> json) {
    return CreditsModel(
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => CrewMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.id,
    required super.name,
    super.character,
    super.profilePath,
    super.order,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}

class CrewMemberModel extends CrewMember {
  const CrewMemberModel({
    required super.id,
    required super.name,
    super.job,
    super.department,
    super.profilePath,
  });

  factory CrewMemberModel.fromJson(Map<String, dynamic> json) {
    return CrewMemberModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      job: json['job'] as String?,
      department: json['department'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }
}

class WatchProvidersModel extends WatchProviders {
  const WatchProvidersModel({
    super.link,
    super.flatrate,
    super.rent,
    super.buy,
  });

  factory WatchProvidersModel.fromJson(Map<String, dynamic> json) {
    // TMDB devuelve providers por país, usamos ES (España) o US como fallback
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final countryData = results['ES'] as Map<String, dynamic>? ??
        results['US'] as Map<String, dynamic>? ??
        results['MX'] as Map<String, dynamic>? ??
        {};

    return WatchProvidersModel(
      link: countryData['link'] as String?,
      flatrate: (countryData['flatrate'] as List<dynamic>?)
              ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rent: (countryData['rent'] as List<dynamic>?)
              ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      buy: (countryData['buy'] as List<dynamic>?)
              ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WatchProviderModel extends WatchProvider {
  const WatchProviderModel({
    required super.providerId,
    required super.providerName,
    super.logoPath,
    super.displayPriority,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) {
    return WatchProviderModel(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String?,
      displayPriority: json['display_priority'] as int? ?? 0,
    );
  }
}
