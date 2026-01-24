import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_movie_detail.dart';

/// Sección de trailers y extras con cards horizontales
class TrailersSection extends StatelessWidget {
  final List<MockTrailer> trailers;
  final VoidCallback? onSeeAllTap;

  const TrailersSection({
    super.key,
    required this.trailers,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    if (trailers.isEmpty) {
      return _EmptyTrailers(message: l10n.detailNoTrailers);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.detailTrailers,
                style: AppTypography.overline.copyWith(
                  color: colors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              if (trailers.length > 2 && onSeeAllTap != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onSeeAllTap,
                  child: Text(
                    l10n.detailSeeAll,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal list
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: trailers.length,
            itemBuilder: (context, index) {
              final trailer = trailers[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < trailers.length - 1 ? 12 : 0,
                ),
                child: _TrailerCard(trailer: trailer),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrailerCard extends StatelessWidget {
  final MockTrailer trailer;

  const _TrailerCard({required this.trailer});

  Future<void> _openYouTube() async {
    if (trailer.youtubeKey != null) {
      final url = Uri.parse('https://www.youtube.com/watch?v=${trailer.youtubeKey}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: _openYouTube,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Thumbnail
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: trailer.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colors.surfaceElevated,
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colors.surfaceElevated,
                    child: Icon(
                      CupertinoIcons.play_rectangle,
                      color: colors.textTertiary,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF000000).withValues(alpha: 0),
                        const Color(0xFF000000).withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Play button
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.play_fill,
                    color: colors.textOnAccent,
                    size: 24,
                  ),
                ),
              ),

              // Info at bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trailer.title,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textOnAccent,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          trailer.duration,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textOnAccent.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textOnAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trailer.quality,
                            style: AppTypography.overline.copyWith(
                              color: colors.textOnAccent,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTrailers extends StatelessWidget {
  final String message;

  const _EmptyTrailers({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.play_rectangle,
            color: colors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para la sección de trailers
class TrailersSkeleton extends StatelessWidget {
  const TrailersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
