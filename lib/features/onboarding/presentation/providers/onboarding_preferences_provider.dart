import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../data/services/profile_service.dart';
import '../../domain/models/user_preferences.dart';

/// Keys internas de los moods (se guardan en DB)
const List<String> moodKeys = [
  'happy',
  'epic',
  'reflective',
  'intense',
  'relaxed',
  'nostalgic',
];

/// Obtiene el label localizado para un mood key
String getMoodLabel(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  switch (key) {
    case 'happy':
      return l10n.moodHappy;
    case 'epic':
      return l10n.moodEpic;
    case 'reflective':
      return l10n.moodReflective;
    case 'intense':
      return l10n.moodIntense;
    case 'relaxed':
      return l10n.moodRelaxed;
    case 'nostalgic':
      return l10n.moodNostalgic;
    default:
      return key;
  }
}

/// @deprecated Use moodKeys + getMoodLabel instead
const List<String> availableMoods = moodKeys;

/// Estado del onboarding de preferencias
class OnboardingPreferencesState {
  final Set<Genre> selectedGenres;
  final Set<String> selectedMoods; // Moods predefinidos seleccionados
  final String moodText;
  final bool isSaving;
  final String? error;

  const OnboardingPreferencesState({
    this.selectedGenres = const {},
    this.selectedMoods = const {},
    this.moodText = '',
    this.isSaving = false,
    this.error,
  });

  OnboardingPreferencesState copyWith({
    Set<Genre>? selectedGenres,
    Set<String>? selectedMoods,
    String? moodText,
    bool? isSaving,
    String? error,
  }) {
    return OnboardingPreferencesState(
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedMoods: selectedMoods ?? this.selectedMoods,
      moodText: moodText ?? this.moodText,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  /// Combina moods seleccionados + texto libre para guardar
  String get combinedMoodText {
    final parts = <String>[];
    if (selectedMoods.isNotEmpty) {
      parts.add(selectedMoods.join(', '));
    }
    if (moodText.isNotEmpty) {
      parts.add(moodText);
    }
    return parts.join(' - ');
  }

  /// Convierte a UserPreferences con IDs de TMDB
  UserPreferences toUserPreferences() {
    return UserPreferences(
      preferredGenres: GenreMapping.genresToIds(selectedGenres),
      moodText: combinedMoodText,
      onboardingCompleted: true,
    );
  }

  /// Indica si el usuario ha seleccionado algo
  bool get hasSelections =>
      selectedGenres.isNotEmpty || selectedMoods.isNotEmpty || moodText.isNotEmpty;
}

/// Notifier para el estado de preferencias del onboarding
class OnboardingPreferencesNotifier extends StateNotifier<OnboardingPreferencesState> {
  final ProfileService _profileService;

  OnboardingPreferencesNotifier(this._profileService)
      : super(const OnboardingPreferencesState());

  /// Toggle de un género
  void toggleGenre(Genre genre) {
    final newGenres = Set<Genre>.from(state.selectedGenres);
    if (newGenres.contains(genre)) {
      newGenres.remove(genre);
    } else {
      newGenres.add(genre);
    }
    state = state.copyWith(selectedGenres: newGenres);
  }

  /// Toggle de un mood predefinido
  void toggleMood(String mood) {
    final newMoods = Set<String>.from(state.selectedMoods);
    if (newMoods.contains(mood)) {
      newMoods.remove(mood);
    } else {
      newMoods.add(mood);
    }
    state = state.copyWith(selectedMoods: newMoods);
  }

  /// Actualiza el texto del mood
  void setMoodText(String text) {
    state = state.copyWith(moodText: text);
  }

  /// Guarda las preferencias en Supabase
  Future<bool> savePreferences() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _profileService.savePreferences(state.toUserPreferences());
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Marca el onboarding como saltado (cold start mode)
  Future<bool> skipOnboarding() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _profileService.skipOnboarding();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reinicia el estado
  void reset() {
    state = const OnboardingPreferencesState();
  }
}

/// Provider para el estado de preferencias del onboarding
final onboardingPreferencesProvider = StateNotifierProvider<
    OnboardingPreferencesNotifier, OnboardingPreferencesState>((ref) {
  return OnboardingPreferencesNotifier(ref.watch(profileServiceProvider));
});
