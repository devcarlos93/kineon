import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/models/user_preferences.dart';

/// Provider del servicio de perfil
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(supabaseClientProvider));
});

/// Servicio para manejar el perfil del usuario en Supabase
class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  /// Guarda las preferencias del usuario actual
  ///
  /// Actualiza la tabla profiles con:
  /// - preferred_genres: Array de IDs de TMDB
  /// - mood_text: Texto del mood
  /// - onboarding_completed: true
  Future<void> savePreferences(UserPreferences preferences) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _client.from(SupabaseTables.profiles).upsert({
      'id': user.id,
      'preferred_genres': preferences.preferredGenres,
      'mood_text': preferences.moodText,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Obtiene las preferencias del usuario actual
  Future<UserPreferences?> getPreferences() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from(SupabaseTables.profiles)
        .select('preferred_genres, mood_text, onboarding_completed')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return UserPreferences.fromJson(response);
  }

  /// Verifica si el usuario ha completado el onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await getPreferences();
    return prefs?.onboardingCompleted ?? false;
  }

  /// Marca el onboarding como saltado (cold start)
  ///
  /// Guarda onboarding_completed = true pero sin preferencias
  Future<void> skipOnboarding() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _client.from(SupabaseTables.profiles).upsert({
      'id': user.id,
      'preferred_genres': <int>[],
      'mood_text': '',
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
