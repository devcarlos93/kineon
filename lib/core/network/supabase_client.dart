import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

// =====================================================
// PROVIDERS
// =====================================================

/// Provider para el cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// =====================================================
// CONFIGURACIÓN DE SUPABASE
// =====================================================

/// Clase para inicializar y acceder a Supabase
class SupabaseConfig {
  SupabaseConfig._();

  // ═══════════════════════════════════════════════════════════════════
  // CREDENCIALES DE DESARROLLO
  // En producción, usar --dart-define para sobrescribir
  // ═══════════════════════════════════════════════════════════════════
  static const String _devUrl = 'https://eqbcuobsxwrwqydwkibe.supabase.co';
  static const String _devAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxYmN1b2JzeHdyd3F5ZHdraWJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMzQwMDMsImV4cCI6MjA4NDYxMDAwM30.ZOG6flJDJmMMDu3lK_HNfM5yUctxe8zEljAV8FL5kBQ';

  /// URL de Supabase (usa dart-define o fallback a dev)
  static String get url {
    final envUrl = AppConstants.supabaseUrl;
    return envUrl.isNotEmpty ? envUrl : _devUrl;
  }

  /// Anon Key de Supabase (usa dart-define o fallback a dev)
  static String get anonKey {
    final envKey = AppConstants.supabaseAnonKey;
    return envKey.isNotEmpty ? envKey : _devAnonKey;
  }

  /// Inicializa Supabase
  ///
  /// Llamar en main.dart antes de runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: false, // Cambiar a true para debugging
    );
  }

  // =====================================================
  // ACCESSORS
  // =====================================================

  /// Cliente principal de Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Cliente de autenticación
  static GoTrueClient get auth => client.auth;

  /// Cliente de Storage
  static SupabaseStorageClient get storage => client.storage;

  /// Cliente de Edge Functions
  static FunctionsClient get functions => client.functions;

  /// Sesión actual (null si no está autenticado)
  static Session? get currentSession => auth.currentSession;

  /// Usuario actual (null si no está autenticado)
  static User? get currentUser => currentSession?.user;

  /// Verifica si hay sesión activa
  static bool get isAuthenticated => currentSession != null;

  // =====================================================
  // EDGE FUNCTIONS HELPERS
  // =====================================================

  /// Llama a una Edge Function de forma segura
  static Future<FunctionResponse> callFunction(
    String functionName, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return await functions.invoke(functionName, body: body, headers: headers);
  }
}

// =====================================================
// EXTENSIONES PARA SUPABASE CLIENT
// =====================================================

extension SupabaseClientX on SupabaseClient {
  /// Llama a la Edge Function de TMDB Proxy
  ///
  /// ```dart
  /// final data = await client.callTmdbProxy(
  ///   path: 'movie/popular',
  ///   params: {'page': 1},
  ///   language: 'es-MX',
  ///   region: 'MX',
  /// );
  /// ```
  Future<dynamic> callTmdbProxy({
    required String path,
    Map<String, dynamic>? params,
    String? language,
    String? region,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.tmdbProxy,
      body: {
        'path': path,
        'query': params,
        if (language != null) 'language': language,
        if (region != null) 'region': region,
      },
    );
    return response.data;
  }

  /// Llama a la Edge Function de recomendaciones IA
  ///
  /// ```dart
  /// final data = await client.callAiRecommend(
  ///   prompt: 'Algo como Interstellar pero más corto',
  ///   contentType: 'movie',
  /// );
  /// ```
  Future<dynamic> callAiRecommend({
    required String prompt,
    String contentType = 'both',
    int limit = 5,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.aiRecommend,
      body: {'prompt': prompt, 'content_type': contentType, 'limit': limit},
    );
    return response.data;
  }

  /// Llama a la Edge Function de chat IA
  Future<dynamic> callAiChat({
    required String message,
    required List<Map<String, dynamic>> history,
    String? context,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.aiChat,
      body: {'message': message, 'history': history, 'context': context},
    );
    return response.data;
  }

  /// Llama a la Edge Function de AI Home Picks
  ///
  /// Obtiene recomendaciones personalizadas usando IA + TMDB discover
  /// ```dart
  /// final data = await client.callAiHomePicks(
  ///   pickCount: 5,
  ///   language: 'es-MX',
  ///   region: 'MX',
  /// );
  /// ```
  Future<dynamic> callAiHomePicks({
    int pickCount = 5,
    String? language,
    String? region,
  }) async {
    final session = auth.currentSession;
    final token = session?.accessToken;

    final url = Uri.parse('${SupabaseConfig.url}/functions/v1/${EdgeFunctions.aiHomePicks}');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'apikey': SupabaseConfig.anonKey,
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = <String, dynamic>{
      'pick_count': pickCount,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
    };

    final httpResponse = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw FunctionException(
          status: 408,
          details: 'Request timeout after 30 seconds',
          reasonPhrase: 'Timeout',
        );
      },
    );

    if (httpResponse.statusCode != 200) {
      throw FunctionException(
        status: httpResponse.statusCode,
        details: httpResponse.body,
        reasonPhrase: httpResponse.reasonPhrase,
      );
    }

    return jsonDecode(httpResponse.body);
  }

  /// Llama a la Edge Function de TMDB Bulk
  ///
  /// Obtiene detalles de múltiples películas/series en una sola llamada
  /// ```dart
  /// final items = await client.callTmdbBulk(
  ///   ids: [123, 456, 789],
  ///   contentType: 'movie',
  ///   language: 'es-MX',
  ///   region: 'MX',
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> callTmdbBulk({
    required List<int> ids,
    String contentType = 'movie',
    String language = 'es-ES',
    String? region,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.tmdbBulk,
      body: {
        'ids': ids,
        'content_type': contentType,
        'language': language,
        if (region != null) 'region': region,
      },
    );

    if (response.data == null) {
      return [];
    }

    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Llama a la Edge Function de AI Movie Insight
  ///
  /// Genera insights personalizados para una película/serie usando IA
  /// ```dart
  /// final insight = await client.callAiMovieInsight(
  ///   tmdbId: 123,
  ///   contentType: 'movie',
  ///   title: 'Inception',
  ///   overview: 'Un ladrón que...',
  ///   genres: ['Sci-Fi', 'Action'],
  ///   voteAverage: 8.8,
  /// );
  /// ```
  Future<Map<String, dynamic>> callAiMovieInsight({
    required int tmdbId,
    required String contentType,
    required String title,
    required String overview,
    required List<String> genres,
    required double voteAverage,
    int? runtime,
    int? releaseYear,
    String? director,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.aiMovieInsight,
      body: {
        'tmdb_id': tmdbId,
        'content_type': contentType,
        'title': title,
        'overview': overview,
        'genres': genres,
        'vote_average': voteAverage,
        if (runtime != null) 'runtime': runtime,
        if (releaseYear != null) 'release_year': releaseYear,
        if (director != null) 'director': director,
      },
    );

    if (response.data == null) {
      throw FunctionException(
        status: response.status,
        details: 'No data returned from ai-movie-insight',
      );
    }

    return response.data as Map<String, dynamic>;
  }

  /// Llama a la Edge Function de AI Search Plan
  ///
  /// Convierte búsqueda natural → filtros TMDB estructurados
  /// ```dart
  /// final plan = await client.callAiSearchPlan(
  ///   query: 'Algo como Interstellar pero más corto',
  ///   mediaType: 'movie',
  ///   language: 'es-MX',
  ///   region: 'MX',
  /// );
  /// ```
  Future<Map<String, dynamic>> callAiSearchPlan({
    required String query,
    String mediaType = 'movie',
    List<int>? selectedGenreIds,
    String? moodChip,
    String? language,
    String? region,
  }) async {
    final response = await functions.invoke(
      EdgeFunctions.aiSearchPlan,
      body: {
        'query': query,
        'media_type': mediaType,
        if (selectedGenreIds != null) 'selected_genre_ids': selectedGenreIds,
        if (moodChip != null) 'mood_chip': moodChip,
        if (language != null) 'language': language,
        if (region != null) 'region': region,
      },
    );

    if (response.data == null) {
      throw FunctionException(
        status: response.status,
        details: 'No data returned from ai-search-plan',
      );
    }

    return response.data as Map<String, dynamic>;
  }
}
