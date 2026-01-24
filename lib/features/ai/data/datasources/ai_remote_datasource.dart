import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Datasource para comunicación con Edge Functions de AI
class AiRemoteDatasource {
  final SupabaseClient _client;

  AiRemoteDatasource(this._client);

  /// Obtiene recomendaciones personalizadas de AI
  Future<AiRecommendResponse> getRecommendations({
    required String prompt,
    String contentType = 'both',
    int limit = 5,
  }) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw const AuthException(message: 'Usuario no autenticado');
    }

    final url = Uri.parse(
      '${AppConstants.supabaseUrl}/functions/v1/ai-recommend',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
        'apikey': AppConstants.supabaseAnonKey,
      },
      body: jsonEncode({
        'prompt': prompt,
        'content_type': contentType,
        'limit': limit,
      }),
    );

    if (response.statusCode == 401) {
      throw const AuthException(message: 'Sesión expirada');
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw ServerException(
        message: error['error'] ?? 'Error al obtener recomendaciones',
        code: error['code'],
      );
    }

    final data = jsonDecode(response.body);
    return AiRecommendResponse.fromJson(data);
  }
}

// =====================================================
// MODELOS DE RESPUESTA
// =====================================================

class AiRecommendResponse {
  final bool success;
  final String prompt;
  final String contentType;
  final List<AiRecommendation> recommendations;
  final AiRecommendMeta meta;

  AiRecommendResponse({
    required this.success,
    required this.prompt,
    required this.contentType,
    required this.recommendations,
    required this.meta,
  });

  factory AiRecommendResponse.fromJson(Map<String, dynamic> json) {
    return AiRecommendResponse(
      success: json['success'] ?? false,
      prompt: json['prompt'] ?? '',
      contentType: json['content_type'] ?? 'both',
      recommendations: (json['recommendations'] as List? ?? [])
          .map((r) => AiRecommendation.fromJson(r))
          .toList(),
      meta: AiRecommendMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class AiRecommendation {
  final int tmdbId;
  final String title;
  final String contentType;
  final String reason;
  final List<String> tags;
  final double confidence;

  // Campos adicionales para UI (se llenan después con TMDB)
  String? posterPath;
  String? overview;
  double? voteAverage;
  String? releaseDate;

  AiRecommendation({
    required this.tmdbId,
    required this.title,
    required this.contentType,
    required this.reason,
    required this.tags,
    required this.confidence,
    this.posterPath,
    this.overview,
    this.voteAverage,
    this.releaseDate,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      tmdbId: json['tmdb_id'] ?? 0,
      title: json['title'] ?? '',
      contentType: json['content_type'] ?? 'movie',
      reason: json['reason'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tmdb_id': tmdbId,
    'title': title,
    'content_type': contentType,
    'reason': reason,
    'tags': tags,
    'confidence': confidence,
  };
}

class AiRecommendMeta {
  final int watchlistCount;
  final int favoritesCount;
  final int watchedCount;
  final int ratingsCount;
  final DateTime? generatedAt;

  AiRecommendMeta({
    required this.watchlistCount,
    required this.favoritesCount,
    required this.watchedCount,
    required this.ratingsCount,
    this.generatedAt,
  });

  factory AiRecommendMeta.fromJson(Map<String, dynamic> json) {
    final history = json['user_history'] ?? {};
    return AiRecommendMeta(
      watchlistCount: history['watchlist_count'] ?? 0,
      favoritesCount: history['favorites_count'] ?? 0,
      watchedCount: history['watched_count'] ?? 0,
      ratingsCount: history['ratings_count'] ?? 0,
      generatedAt: json['generated_at'] != null 
          ? DateTime.tryParse(json['generated_at']) 
          : null,
    );
  }
}
