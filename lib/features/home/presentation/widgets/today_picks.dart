import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/media_item.dart';
import 'poster_card.dart';
import 'skeleton_card.dart';

/// Sección "Para ti hoy" con recomendaciones IA
///
/// Muestra 3 cards grandes verticales con razón de recomendación.
class TodayPicks extends StatelessWidget {
  final List<MediaItem> picks;
  final bool isLoading;
  final Function(MediaItem)? onItemTap;

  const TodayPicks({
    super.key,
    required this.picks,
    this.isLoading = false,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                'Para ti hoy',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Badge "IA CURATED"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'IA CURATED',
                  style: AppTypography.overline.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Cards verticales
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index < 1 ? 16 : 0),
                  child: const SkeletonFeaturedCard(),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: picks.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < picks.length - 1 ? 16 : 0,
                  ),
                  child: FeaturedPosterCard(
                    title: item.title,
                    imageUrl: item.backdropUrl ?? item.posterUrl ?? '',
                    aiReason: item.overview ?? '',
                    onTap: () => onItemTap?.call(item),
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: index * 100),
                    duration: 400.ms,
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: Duration(milliseconds: index * 100),
                    duration: 400.ms,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
