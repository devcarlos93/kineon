import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/navigation/route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../library/data/repositories/hidden_media_repository.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../domain/entities/media_item.dart';
import '../providers/ai_picks_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/ai_picks_section.dart';
import '../widgets/home_header.dart';
import '../widgets/horizontal_carousel.dart';
import '../widgets/quick_preferences_sheet.dart';
import '../widgets/skeleton_card.dart';
import 'media_list_screen.dart';

/// Pantalla principal Home de Kineon
///
/// Composición:
/// - Header: saludo + avatar + notificaciones
/// - Para ti hoy: 3 recomendaciones IA
/// - Un toque y decides: acciones rápidas
/// - Carruseles: Trending, Estrenos, Mejor valoradas, etc.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  bool _isRefiningPicks = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos reales al iniciar
    Future.microtask(() {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Suscribirse al RouteObserver para detectar cuando volvemos a esta pantalla
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      kineonRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    kineonRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando volvemos a Home desde otra pantalla (ej: Detail)
    // Refrescar los estados de la biblioteca para actualizar micro-dots
    ref.invalidate(homeMediaStatesProvider);
  }

  Future<void> _loadData() async {
    // Cargar todo en paralelo para mayor velocidad
    final prefs = SharedPreferences.getInstance();

    // Iniciar cargas en paralelo (no await individual)
    ref.read(homeProvider.notifier).loadHomeData();
    ref.read(userPreferencesProvider.notifier).loadPreferences();

    // Verificar preferencias nuevas
    final prefsInstance = await prefs;
    final hasNewPreferences = prefsInstance.getBool('new_preferences_saved') ?? false;

    // Cargar AI picks con estrategia cache-first
    // Pedimos 5 para que después de filtrar ocultos, queden al menos 3
    if (hasNewPreferences) {
      prefsInstance.remove('new_preferences_saved');
      ref.read(aiPicksProvider.notifier).refresh(pickCount: 5);
    } else {
      ref.read(aiPicksProvider.notifier).loadPicks(pickCount: 5);
    }

    // Actualizar notificaciones en background
    ref.read(notificationPreferencesProvider.notifier).refreshWithAIData();
  }

  Future<void> _refresh() async {
    // Refrescar AI picks y capturar si fue rate limited
    final aiRefreshFuture = ref.read(aiPicksProvider.notifier).refresh(pickCount: 5);

    // Refrescar todo en paralelo
    await Future.wait([
      ref.read(homeProvider.notifier).refresh(),
      aiRefreshFuture,
      ref.read(userPreferencesProvider.notifier).refresh(),
    ]);

    // Verificar si AI picks fue rate limited
    final aiDidRefresh = await aiRefreshFuture;
    if (!aiDidRefresh && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ya tienes recomendaciones frescas ✨',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          backgroundColor: context.colors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Actualizar notificaciones con datos de IA frescos
    ref.read(notificationPreferencesProvider.notifier).refreshWithAIData();
  }

  void _openQuickPreferences() {
    final prefs = ref.read(userPreferencesProvider);
    QuickPreferencesSheet.show(
      context,
      initialGenres: prefs.preferredGenres,
      initialMood: prefs.moodText,
      onSaved: () async {
        // Mostrar skeleton de refinamiento
        if (mounted) {
          setState(() => _isRefiningPicks = true);
        }

        // Refrescar preferencias
        await ref.read(userPreferencesProvider.notifier).refresh();

        // Forzar refresh de AI picks (invalida cache y obtiene nuevos)
        await ref.read(aiPicksProvider.notifier).refresh(pickCount: 5);

        // Ocultar skeleton de refinamiento
        if (mounted) {
          setState(() => _isRefiningPicks = false);
        }
      },
    );
  }

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.userMetadata?['full_name'] != null) {
      return user!.userMetadata!['full_name'].toString().split(' ').first;
    }
    if (user?.email != null) {
      return user!.email!.split('@').first;
    }
    return 'Cinefilo';
  }

  String? get _avatarUrl {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['avatar_url'] as String?;
  }

  void _onMediaTap(MediaItem item) {
    final type = item.contentType == ContentType.movie ? 'movie' : 'tv';
    context.push('/details/$type/${item.id}');
  }

  /// Añade un item específico a Mi Lista
  void _handleAddToListItem(MediaItem item) async {
    final success = await ref.read(libraryActionsProvider.notifier).addToWatchlist(
      item.id,
      item.contentType,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
            ? '"${item.title}" añadido a Mi Lista'
            : 'No se pudo añadir a Mi Lista',
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: success ? SnackBarAction(
          label: 'Ver',
          textColor: colors.accent,
          onPressed: () => _onMediaTap(item),
        ) : null,
      ),
    );
  }

  /// Oculta un item específico ("No me interesa")
  void _handleNotInterestedItem(MediaItem item) async {
    try {
      await ref.read(hiddenMediaProvider.notifier).hide(
        item.id,
        item.contentType,
      );

      if (!mounted) return;

      // Refrescar AI picks para que obtenga nuevas recomendaciones
      ref.read(aiPicksProvider.notifier).refresh(pickCount: 5);

      ScaffoldMessenger.of(context).clearSnackBars();
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${item.title}" oculto',
            style: TextStyle(color: colors.textPrimary),
          ),
          backgroundColor: colors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: colors.accent,
            onPressed: () async {
              await ref.read(hiddenMediaProvider.notifier).unhide(
                item.id,
                item.contentType,
              );
              ref.read(aiPicksProvider.notifier).refresh(pickCount: 5);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo ocultar el contenido',
            style: TextStyle(color: colors.textPrimary),
          ),
          backgroundColor: colors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final aiPicks = ref.watch(aiPicksProvider);
    final userPrefs = ref.watch(userPreferencesProvider);
    final mediaStatesAsync = ref.watch(homeMediaStatesProvider);
    final mediaStates = mediaStatesAsync.valueOrNull ?? {};
    final hiddenIds = ref.watch(hiddenMediaProvider);
    final isLoading = state.isLoading;
    final l10n = AppLocalizations.of(context);

    // Filtrar items ocultos
    bool isNotHidden(MediaItem item) =>
        !hiddenIds.contains((item.id, item.contentType));

    // Pedimos 5 picks pero mostramos solo 3 (para que después de filtrar ocultos queden suficientes)
    final filteredPicks = aiPicks.picks
        .where((pick) => isNotHidden(pick.item))
        .take(3)
        .toList();
    final filteredTrendingMovies = state.trendingMovies.where(isNotHidden).toList();
    final filteredNowPlaying = state.nowPlayingMovies.where(isNotHidden).toList();
    final filteredTopRated = state.topRatedMovies.where(isNotHidden).toList();
    final filteredPopular = state.popularMovies.where(isNotHidden).toList();
    final filteredTrendingTv = state.trendingTv.where(isNotHidden).toList();
    final filteredUpcoming = state.upcomingMovies.where(isNotHidden).toList();

    final colors = context.colors;

    // Error state
    if (state.error != null && state.trendingMovies.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        body: HomeErrorState(
          message: state.error!,
          onRetry: _refresh,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.accent,
        backgroundColor: colors.surface,
        child: CustomScrollView(
          slivers: [
            // Safe area padding
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
            ),

            // ══════════════════════════════════════════════════════
            // HEADER
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: HomeHeader(
                userName: _userName,
                avatarUrl: _avatarUrl,
                onAvatarTap: () {
                  context.goToProfile();
                },
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ══════════════════════════════════════════════════════
            // PARA TI HOY (Recomendaciones IA + Acciones)
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: AIPicksSection(
                picks: filteredPicks,
                isLoading: aiPicks.isLoading || (filteredPicks.isEmpty && isLoading),
                isRefining: _isRefiningPicks,
                isRefreshing: aiPicks.isRefreshing,
                source: aiPicks.source,
                personalizationType: aiPicks.personalizationType,
                hasPreferences: userPrefs.hasPreferences,
                mediaStates: mediaStates,
                onItemTap: _onMediaTap,
                onAddToList: _handleAddToListItem,
                onNotInterested: _handleNotInterestedItem,
                onRefresh: _refresh,
                onRefinePreferences: _openQuickPreferences,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ══════════════════════════════════════════════════════
            // TENDENCIAS PELICULAS
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homeTrending,
                      items: filteredTrendingMovies,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.trendingMovies);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ══════════════════════════════════════════════════════
            // ESTRENOS (Now Playing)
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homeNewReleases,
                      items: filteredNowPlaying,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.nowPlaying);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ══════════════════════════════════════════════════════
            // MEJOR VALORADAS
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homeTopRated,
                      items: filteredTopRated,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.topRated);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ══════════════════════════════════════════════════════
            // POPULARES
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homePopular,
                      items: filteredPopular,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.popular);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ══════════════════════════════════════════════════════
            // SERIES EN TENDENCIA
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homeTrendingTv,
                      items: filteredTrendingTv,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.trendingTv);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ══════════════════════════════════════════════════════
            // PROXIMOS ESTRENOS
            // ══════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: isLoading
                  ? const SkeletonCarouselSection()
                  : HorizontalCarousel(
                      title: l10n.homeUpcoming,
                      items: filteredUpcoming,
                      mediaStates: mediaStates,
                      onSeeAll: () {
                        context.goToMediaList(MediaListType.upcoming);
                      },
                      onItemTap: _onMediaTap,
                    ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            ),

            // Espacio inferior para bottom nav + safe area
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de error premium
class HomeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con gradiente
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.2),
                    colors.accentPurple.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Algo salio mal',
              style: AppTypography.h2.copyWith(color: colors.textPrimary),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Boton retry con gradiente
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: colors.textOnAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reintentar',
                      style: AppTypography.labelLarge.copyWith(
                        color: colors.textOnAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
