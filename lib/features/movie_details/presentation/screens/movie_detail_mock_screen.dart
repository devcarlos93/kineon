import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Material, ScaffoldMessenger, SnackBar, SnackBarBehavior, RoundedRectangleBorder;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/data/repositories/media_repository_impl.dart';
import '../../../home/domain/entities/movie_details.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../library/presentation/widgets/add_to_list_modal.dart';
import '../../../profile/presentation/providers/profile_preferences_provider.dart';
import '../../../subscription/subscription.dart';
import '../../data/mock_movie_detail.dart';
import '../providers/movie_details_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/ai_recommendation.dart';
import '../widgets/cast_section.dart';
import '../widgets/detail_hero.dart';
import '../widgets/detail_states.dart';
import '../widgets/synopsis_section.dart';
import '../widgets/trailers_section.dart';
import '../widgets/in_theaters_section.dart';
import '../widgets/watch_providers_section.dart';

/// Pantalla de detalle de película con diseño Stitch (datos reales de TMDB)
class MovieDetailMockScreen extends ConsumerStatefulWidget {
  final int movieId;
  final bool isMovie;

  const MovieDetailMockScreen({
    super.key,
    required this.movieId,
    this.isMovie = true,
  });

  @override
  ConsumerState<MovieDetailMockScreen> createState() => _MovieDetailMockScreenState();
}

class _MovieDetailMockScreenState extends ConsumerState<MovieDetailMockScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  MovieDetails? _movieDetails;
  MockMovieDetail? _movie;

  /// Para usuarios free: controla si se debe cargar el AI insight
  /// Pro users siempre lo cargan automáticamente
  bool _userRequestedAiInsight = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(mediaRepositoryProvider);

      final result = widget.isMovie
          ? await repository.getMovieDetails(widget.movieId)
          : await repository.getTvDetails(widget.movieId);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _hasError = true;
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (details) {
          _movieDetails = details;
          _movie = _convertToMockDetail(details);
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Convierte MovieDetails de TMDB a MockMovieDetail para reutilizar widgets
  MockMovieDetail _convertToMockDetail(MovieDetails details) {
    // Convertir cast
    final cast = details.credits?.cast.take(10).map((c) => MockCastMember(
      id: c.id,
      name: c.name,
      character: c.character ?? '',
      profileUrl: c.profileUrl,
    )).toList() ?? [];

    // Convertir trailers
    final trailers = details.videos?.results
        .where((v) => v.site == 'YouTube')
        .take(5)
        .map((v) => MockTrailer(
          id: v.id,
          title: v.name,
          thumbnailUrl: v.youtubeThumbnail,
          duration: '', // TMDB no proporciona duración
          quality: v.type,
          youtubeKey: v.key,
        )).toList() ?? [];

    // AI recommendation se obtiene del provider, aquí solo placeholder vacío
    const aiRecommendation = MockAIRecommendation(
      bullets: [],
      tags: [],
    );

    return MockMovieDetail(
      id: details.id,
      title: details.title,
      posterUrl: details.posterUrl ?? '',
      backdropUrl: details.backdropUrl ?? '',
      year: details.releaseYear ?? 0,
      runtime: details.runtime ?? 0,
      rating: details.voteAverage,
      synopsis: details.overview ?? 'Sin sinopsis disponible.',
      genres: details.genres.map((g) => g.name).toList(),
      cast: cast,
      trailers: trailers,
      aiRecommendation: aiRecommendation,
      // Estados se manejan aparte con Riverpod
      inWatchlist: false,
      isFavorite: false,
      isSeen: false,
    );
  }

  /// Crea los parámetros para el AI insight provider
  AiInsightParams? _getAiInsightParams() {
    if (_movieDetails == null) return null;

    return AiInsightParams(
      tmdbId: _movieDetails!.id,
      contentType: widget.isMovie ? 'movie' : 'tv',
      title: _movieDetails!.title,
      overview: _movieDetails!.overview ?? '',
      genres: _movieDetails!.genres.map((g) => g.name).toList(),
      voteAverage: _movieDetails!.voteAverage,
      runtime: _movieDetails!.runtime,
      releaseYear: _movieDetails!.releaseYear,
      director: _movieDetails!.director,
    );
  }

  ContentType get _contentType => widget.isMovie ? ContentType.movie : ContentType.tv;

  void _toggleWatchlist(bool currentState) async {
    HapticFeedback.mediumImpact();

    final actions = ref.read(libraryActionsProvider.notifier);
    if (currentState) {
      await actions.removeFromWatchlist(widget.movieId, _contentType);
      _showSnackBar(
        'Eliminado de watchlist',
        icon: CupertinoIcons.bookmark,
        color: context.colors.textSecondary,
      );
    } else {
      await actions.addToWatchlist(widget.movieId, _contentType);
      _showSnackBar(
        'Añadido a watchlist',
        icon: CupertinoIcons.bookmark_fill,
        color: context.colors.accent,
      );
    }
  }

  void _toggleFavorite(bool currentState) async {
    HapticFeedback.mediumImpact();

    await ref.read(libraryActionsProvider.notifier).toggleFavorite(
      widget.movieId,
      _contentType,
    );

    _showSnackBar(
      currentState ? 'Eliminado de favoritos' : 'Añadido a favoritos',
      icon: currentState ? CupertinoIcons.heart : CupertinoIcons.heart_fill,
      color: currentState ? context.colors.textSecondary : const Color(0xFFFF4D6D),
    );
  }

  void _toggleSeen(bool currentState) async {
    HapticFeedback.mediumImpact();

    final actions = ref.read(libraryActionsProvider.notifier);
    if (currentState) {
      await actions.removeFromWatched(widget.movieId, _contentType);
      _showSnackBar(
        'Desmarcado como visto',
        icon: CupertinoIcons.checkmark_circle,
        color: context.colors.textSecondary,
      );
    } else {
      await actions.markAsWatched(widget.movieId, _contentType);
      _showSnackBar(
        'Marcado como visto',
        icon: CupertinoIcons.checkmark_circle_fill,
        color: context.colors.accent,
      );
    }
  }

  void _addToList() {
    if (_movie == null) return;
    HapticFeedback.lightImpact();
    AddToListModal.show(
      context,
      tmdbId: widget.movieId,
      contentType: widget.isMovie ? ContentType.movie : ContentType.tv,
      title: _movie!.title,
      posterPath: _movieDetails?.posterPath,
    );
  }

  void _showSnackBar(String message, {required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: context.colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Solicita AI insight con verificación de gating
  Future<void> _requestAiInsight() async {
    HapticFeedback.mediumImpact();

    // Verificar límite de uso
    if (!await ref.checkAIGate(context, AIEndpoints.insight)) {
      return; // Usuario bloqueado, paywall mostrado
    }

    // Registrar uso
    ref.recordAIUsage(AIEndpoints.insight);

    // Activar carga del insight
    setState(() {
      _userRequestedAiInsight = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observar estados de biblioteca
    final mediaStateAsync = ref.watch(mediaStateProvider(MediaStateParams(
      tmdbId: widget.movieId,
      contentType: _contentType,
    )));
    final mediaState = mediaStateAsync.valueOrNull;
    final inWatchlist = mediaState?.isInWatchlist ?? false;
    final isFavorite = mediaState?.isFavorite ?? false;
    final isSeen = mediaState?.isWatched ?? false;

    final colors = context.colors;

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: Material(
        color: Colors.transparent,
        child: _buildContent(inWatchlist, isFavorite, isSeen),
      ),
    );
  }

  Widget _buildContent(bool inWatchlist, bool isFavorite, bool isSeen) {
    if (_isLoading) {
      return const DetailLoadingState();
    }

    if (_hasError || _movie == null) {
      return DetailErrorState(
        onRetry: _loadData,
        onBack: () => context.pop(),
      );
    }

    // Obtener estado de suscripción
    final subscription = ref.watch(subscriptionProvider);
    final isPro = subscription.isPro;

    // Obtener AI insight del provider
    // Pro users: siempre cargar automáticamente
    // Free users: solo cargar si lo solicitaron
    final aiInsightParams = _getAiInsightParams();
    final shouldLoadAiInsight = isPro || _userRequestedAiInsight;
    final aiInsightAsync = (aiInsightParams != null && shouldLoadAiInsight)
        ? ref.watch(aiInsightProvider(aiInsightParams))
        : null;

    return CustomScrollView(
      slivers: [
        // Hero section
        SliverToBoxAdapter(
          child: DetailHero(
            movie: _movie!,
            onBackTap: () => context.pop(),
          ).animate().fadeIn(duration: 400.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Action buttons
        SliverToBoxAdapter(
          child: ActionButtonsRow(
            inWatchlist: inWatchlist,
            isFavorite: isFavorite,
            isSeen: isSeen,
            onWatchlistTap: () => _toggleWatchlist(inWatchlist),
            onFavoriteTap: () => _toggleFavorite(isFavorite),
            onSeenTap: () => _toggleSeen(isSeen),
            onAddToListTap: _addToList,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Synopsis
        SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, _) {
              final hideSpoilers = ref.watch(profilePreferencesProvider).preferences.hideSpoilers;
              return SynopsisSection(
                synopsis: _movie!.synopsis,
                hideSpoilers: hideSpoilers,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Ver en cines (solo películas en cartelera)
        if (widget.isMovie && _movieDetails != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InTheatersSection(details: _movieDetails!),
            ).animate().fadeIn(delay: 230.ms, duration: 400.ms),
          ),

        if (widget.isMovie && _movieDetails != null)
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Watch Providers (dónde verla)
        SliverToBoxAdapter(
          child: WatchProvidersSection(
            tmdbId: widget.movieId,
            isMovie: widget.isMovie,
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // AI Recommendation module (from AI provider)
        // Mostrar botón "Ask AI" para usuarios free que no han solicitado insight
        if (!isPro && !_userRequestedAiInsight && aiInsightParams != null)
          SliverToBoxAdapter(
            child: _AskAIButton(
              onTap: _requestAiInsight,
              remaining: subscription.getUsage(AIEndpoints.insight).remaining,
              total: subscription.getUsage(AIEndpoints.insight).dailyLimit,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),

        if (!isPro && !_userRequestedAiInsight && aiInsightParams != null)
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Mostrar insight si está cargando o ya disponible
        if (aiInsightAsync != null)
          SliverToBoxAdapter(
            child: aiInsightAsync.when(
              loading: () => const AIRecommendationSkeleton()
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),
              error: (_, __) => const SizedBox.shrink(),
              data: (aiInsight) {
                if (aiInsight.isEmpty) return const SizedBox.shrink();
                return AIRecommendationModule(
                  recommendation: MockAIRecommendation(
                    bullets: aiInsight.bullets,
                    tags: aiInsight.tags,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
              },
            ),
          ),

        if (aiInsightAsync != null)
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Trailers section
        if (_movie!.trailers.isNotEmpty)
          SliverToBoxAdapter(
            child: TrailersSection(
              trailers: _movie!.trailers,
              onSeeAllTap: () {
                // TODO: Navigate to all trailers
              },
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),

        if (_movie!.trailers.isNotEmpty)
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Cast section
        if (_movie!.cast.isNotEmpty)
          SliverToBoxAdapter(
            child: CastSection(
              cast: _movie!.cast,
              onSeeAllTap: () {
                // TODO: Navigate to full cast
              },
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ),

        // Bottom padding for safe area
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 32,
          ),
        ),
      ],
    );
  }
}

/// Botón para solicitar AI Insight (usuarios free)
class _AskAIButton extends StatelessWidget {
  final VoidCallback onTap;
  final int remaining;
  final int total;

  const _AskAIButton({
    required this.onTap,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.accent.withValues(alpha: 0.15),
                colors.accentPurple.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.sparkles,
                  color: colors.textOnAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta a la IA',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '¿Por qué debería verla? Obtén insights personalizados',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Badge de usos restantes
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? colors.accent.withValues(alpha: 0.15)
                      : colors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$remaining/$total',
                  style: AppTypography.labelSmall.copyWith(
                    color: remaining > 0 ? colors.accent : colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                color: colors.accent,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
