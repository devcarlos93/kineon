import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/kineon_colors.dart';
import 'kineon_glass.dart';
import 'kineon_skeleton.dart';

/// Poster de película/serie estilo Neo-cinema
///
/// Características:
/// - Overlay con gradiente sutil
/// - Badges de rating/estado
/// - Skeleton loading
/// - Efectos hover
class KineonPoster extends StatefulWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final double? rating;
  final bool showRating;
  final bool showTitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final bool isInWatchlist;
  final bool isFavorite;
  final bool isWatched;

  const KineonPoster({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.rating,
    this.showRating = true,
    this.showTitle = false,
    this.onTap,
    this.onLongPress,
    this.width = 120,
    this.height,
    this.aspectRatio = 2 / 3,
    this.borderRadius,
    this.isInWatchlist = false,
    this.isFavorite = false,
    this.isWatched = false,
  });

  /// Poster pequeño para listas horizontales
  factory KineonPoster.small({
    String? imageUrl,
    String? title,
    double? rating,
    VoidCallback? onTap,
  }) {
    return KineonPoster(
      imageUrl: imageUrl,
      title: title,
      rating: rating,
      width: 100,
      onTap: onTap,
    );
  }

  /// Poster grande para destacados
  factory KineonPoster.large({
    String? imageUrl,
    String? title,
    String? subtitle,
    double? rating,
    VoidCallback? onTap,
  }) {
    return KineonPoster(
      imageUrl: imageUrl,
      title: title,
      subtitle: subtitle,
      rating: rating,
      showTitle: true,
      width: 160,
      onTap: onTap,
    );
  }

  @override
  State<KineonPoster> createState() => _KineonPosterState();
}

class _KineonPosterState extends State<KineonPoster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height => widget.height ?? widget.width / widget.aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del poster
              _buildPosterImage(colors),

              // Título y subtítulo (si showTitle)
              if (widget.showTitle && widget.title != null) ...[
                const SizedBox(height: 10),
                _buildTitleSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(KineonColors colors) {
    return Container(
      width: widget.width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? AppRadii.radiusMd,
        boxShadow: _isPressed ? null : AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? AppRadii.radiusMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            _buildImage(colors),

            // Overlay gradiente
            _buildGradientOverlay(colors),

            // Badges
            _buildBadges(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(KineonColors colors) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildPlaceholder(colors);
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const KineonSkeletonBox(),
      errorWidget: (context, url, error) => _buildPlaceholder(colors),
    );
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Container(
      color: colors.surfaceElevated,
      child: Center(
        child: Icon(
          AppIcons.movie,
          size: widget.width * 0.3,
          color: colors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(KineonColors colors) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              colors.background.withOpacity(0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges(KineonColors colors) {
    return Stack(
      children: [
        // Rating badge (arriba izquierda)
        if (widget.showRating && widget.rating != null)
          Positioned(
            top: 8,
            left: 8,
            child: _RatingBadge(rating: widget.rating!),
          ),

        // Estado badges (arriba derecha)
        if (widget.isFavorite || widget.isInWatchlist)
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                if (widget.isFavorite)
                  _StatusBadge(
                    icon: AppIcons.heart,
                    color: colors.error,
                  ),
                if (widget.isFavorite && widget.isInWatchlist)
                  const SizedBox(height: 4),
                if (widget.isInWatchlist)
                  _StatusBadge(
                    icon: AppIcons.bookmark,
                    color: colors.accent,
                  ),
              ],
            ),
          ),

        // Micro-dot verde lime (abajo derecha) - indica "Visto"
        if (widget.isWatched)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.accentLime,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.background,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentLime.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title!,
          style: AppTypography.h4,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Badge de rating con estrella
class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  Color _getColor(KineonColors colors) {
    if (rating >= 7.5) return colors.accentLime;
    if (rating >= 5.5) return AppColors.warning;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return KineonGlassPill(
      backgroundColor: colors.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.star,
            size: 12,
            color: _getColor(colors),
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.labelSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de estado (favorito, watchlist)
class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 10,
        color: colors.textPrimary,
      ),
    );
  }
}

/// Banner/Backdrop horizontal
class KineonBackdrop extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final double? rating;
  final VoidCallback? onTap;
  final double height;
  final Widget? overlay;

  const KineonBackdrop({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.rating,
    this.onTap,
    this.height = 200,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppRadii.radiusLg,
          boxShadow: AppShadows.md,
        ),
        child: ClipRRect(
          borderRadius: AppRadii.radiusLg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const KineonSkeletonBox(),
                  errorWidget: (context, url, error) => Container(
                    color: colors.surfaceElevated,
                  ),
                )
              else
                Container(color: colors.surfaceElevated),

              // Gradiente
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientFeatured,
                ),
              ),

              // Contenido
              Positioned(
                left: 20,
                bottom: 20,
                right: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rating != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RatingBadge(rating: rating!),
                      ),
                    if (title != null)
                      Text(
                        title!,
                        style: AppTypography.h1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Overlay custom
              if (overlay != null) overlay!,
            ],
          ),
        ),
      ),
    );
  }
}
