import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/movie_details.dart';
import '../../../home/presentation/widgets/media_card.dart';
import '../../../library/data/repositories/library_repository.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../library/presentation/widgets/add_to_list_modal.dart';
import '../providers/movie_details_provider.dart';
import '../widgets/watch_providers_section.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  final int id;
  final bool isMovie;

  const MovieDetailsScreen({
    super.key,
    required this.id,
    required this.isMovie,
  });

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isMovie) {
        ref.read(movieDetailsProvider.notifier).loadMovieDetails(widget.id);
      } else {
        ref.read(movieDetailsProvider.notifier).loadTvDetails(widget.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(movieDetailsProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final details = state.details;
    if (details == null) return const SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con backdrop
          _buildAppBar(details),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y acciones
                  _buildHeader(details),
                  const SizedBox(height: 16),

                  // Info rápida
                  _buildQuickInfo(details),
                  const SizedBox(height: 24),

                  // Dónde verla (Watch Providers)
                  WatchProvidersSection(
                    tmdbId: widget.id,
                    isMovie: widget.isMovie,
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  if (details.overview != null && details.overview!.isNotEmpty)
                    _buildOverview(details),

                  // Géneros
                  if (details.genres.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildGenres(details),
                  ],

                  // Cast
                  if (details.credits != null && details.credits!.cast.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCast(details),
                  ],

                  // Similares
                  if (details.similar != null && details.similar!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSimilar(details),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(MovieDetails details) {
    final colors = context.colors;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: colors.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (details.backdropUrl != null)
              CachedNetworkImage(
                imageUrl: details.backdropUrl!,
                fit: BoxFit.cover,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withOpacity(0.8),
                    colors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              AddToListModal.show(
                context,
                tmdbId: widget.id,
                contentType: widget.isMovie ? ContentType.movie : ContentType.tv,
                title: details.title,
                posterPath: details.posterPath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(MovieDetails details) {
    final contentType = widget.isMovie ? ContentType.movie : ContentType.tv;
    final mediaStateAsync = ref.watch(mediaStateProvider(MediaStateParams(
      tmdbId: widget.id,
      contentType: contentType,
    )));
    final mediaState = mediaStateAsync.valueOrNull;
    final isFav = mediaState?.isFavorite ?? false;
    final inWatchlist = mediaState?.isInWatchlist ?? false;
    final isWatched = mediaState?.isWatched ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        if (details.posterUrl != null)
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: details.posterUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 100.ms),
              if (details.tagline != null && details.tagline!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  details.tagline!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ).animate().fadeIn(delay: 150.ms),
              ],
              const SizedBox(height: 12),

              // Botones de acción
              Row(
                children: [
                  _ActionButton(
                    icon: isFav ? Icons.favorite : Icons.favorite_outline,
                    color: isFav ? Colors.red : null,
                    onTap: () {
                      ref.read(libraryActionsProvider.notifier).toggleFavorite(
                            widget.id,
                            contentType,
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: inWatchlist ? Icons.bookmark : Icons.bookmark_outline,
                    color: inWatchlist ? context.colors.accent : null,
                    onTap: () {
                      if (inWatchlist) {
                        ref.read(libraryActionsProvider.notifier).removeFromWatchlist(
                              widget.id,
                              contentType,
                            );
                      } else {
                        ref.read(libraryActionsProvider.notifier).addToWatchlist(
                              widget.id,
                              contentType,
                            );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: isWatched ? Icons.check_circle : Icons.check_circle_outline,
                    color: isWatched ? context.colors.accent : null,
                    onTap: () {
                      if (isWatched) {
                        ref.read(libraryActionsProvider.notifier).removeFromWatched(
                              widget.id,
                              contentType,
                            );
                      } else {
                        ref.read(libraryActionsProvider.notifier).markAsWatched(
                              widget.id,
                              contentType,
                            );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.playlist_add,
                    onTap: () {
                      AddToListModal.show(
                        context,
                        tmdbId: widget.id,
                        contentType: contentType,
                        title: details.title,
                        posterPath: details.posterPath,
                      );
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(MovieDetails details) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        // Rating
        _InfoChip(
          icon: Icons.star_rounded,
          label: details.ratingFormatted,
          color: _getRatingColor(details.voteAverage),
        ),

        // Año
        if (details.releaseYear != null)
          _InfoChip(
            icon: Icons.calendar_today,
            label: '${details.releaseYear}',
          ),

        // Duración
        if (details.runtimeFormatted != null)
          _InfoChip(
            icon: Icons.schedule,
            label: details.runtimeFormatted!,
          ),

        // Director
        if (details.director != null)
          _InfoChip(
            icon: Icons.movie_creation_outlined,
            label: details.director!,
          ),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildOverview(MovieDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopsis',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          details.overview!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildGenres(MovieDetails details) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: details.genres
          .map(
            (genre) => Chip(
              label: Text(genre.name),
              backgroundColor: context.colors.surface,
            ),
          )
          .toList(),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildCast(MovieDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reparto',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: details.credits!.cast.take(10).length,
            itemBuilder: (context, index) {
              final cast = details.credits!.cast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: cast.profileUrl != null
                          ? CachedNetworkImageProvider(cast.profileUrl!)
                          : null,
                      backgroundColor: context.colors.surface,
                      child: cast.profileUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cast.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (cast.character != null)
                      Text(
                        cast.character!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textTertiary,
                              fontSize: 10,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSimilar(MovieDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'También te puede gustar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: details.similar!.take(10).length,
            itemBuilder: (context, index) {
              final item = details.similar![index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MediaCard(
                  item: item,
                  onTap: () {
                    final type = widget.isMovie ? 'movie' : 'tv';
                    context.push('/details/$type/${item.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 450.ms);
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7) return AppColors.ratingHigh;
    if (rating >= 5) return AppColors.ratingMedium;
    return AppColors.ratingLow;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color ?? colors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
