/// Constantes de la aplicación Kineon
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Kineon';
  static const String appVersion = '1.0.0';

  // Supabase - Las URLs/Keys se obtienen de variables de entorno
  // NUNCA expongas tokens en el código
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // TMDB Image Base URLs (públicas, no sensibles)
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String tmdbPosterSmall = '$tmdbImageBaseUrl/w185';
  static const String tmdbPosterMedium = '$tmdbImageBaseUrl/w342';
  static const String tmdbPosterLarge = '$tmdbImageBaseUrl/w500';
  static const String tmdbBackdropSmall = '$tmdbImageBaseUrl/w300';
  static const String tmdbBackdropMedium = '$tmdbImageBaseUrl/w780';
  static const String tmdbBackdropLarge = '$tmdbImageBaseUrl/w1280';
  static const String tmdbOriginal = '$tmdbImageBaseUrl/original';

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const int maxCacheItems = 100;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

/// Rutas de las Edge Functions de Supabase
class EdgeFunctions {
  EdgeFunctions._();

  static const String tmdbProxy = 'tmdb-proxy';
  static const String tmdbBulk = 'tmdb-bulk';
  static const String aiRecommend = 'ai-recommend';
  static const String aiChat = 'ai-chat';
  static const String aiHomePicks = 'ai-home-picks';
  static const String aiMovieInsight = 'ai-movie-insight';
  static const String aiSearchPlan = 'ai-search-plan';
}

/// Nombres de las tablas en Supabase
class SupabaseTables {
  SupabaseTables._();

  static const String profiles = 'profiles';
  static const String userMovieState = 'user_movie_state';
  static const String userRatings = 'user_ratings';
  static const String userLists = 'user_lists';
  static const String userListItems = 'user_list_items';
}

/// Tipos de contenido (película o serie)
enum ContentType {
  movie('movie'),
  tv('tv');

  final String value;
  const ContentType(this.value);

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.movie,
    );
  }
}

/// Estados de visualización (coinciden con enum en DB)
enum WatchStatus {
  none('none'),           // Solo favorito, sin estado de lista
  watchlist('watchlist'),
  watching('watching'),
  watched('watched'),
  dropped('dropped'),
  onHold('on_hold');

  final String value;
  const WatchStatus(this.value);

  static WatchStatus fromString(String value) {
    return WatchStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WatchStatus.none,
    );
  }

  // Nombres para UI (se usarán con localización)
  String get displayNameEs {
    switch (this) {
      case WatchStatus.none:
        return 'Sin estado';
      case WatchStatus.watchlist:
        return 'Por ver';
      case WatchStatus.watching:
        return 'Viendo';
      case WatchStatus.watched:
        return 'Visto';
      case WatchStatus.dropped:
        return 'Abandonado';
      case WatchStatus.onHold:
        return 'En pausa';
    }
  }
}
