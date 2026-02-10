import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/story_item.dart';
import 'story_content_overlay.dart';

/// Card fullscreen de una story con Ken Burns animation
class StoryCard extends StatefulWidget {
  final StoryItem story;
  final bool isActive;

  const StoryCard({
    super.key,
    required this.story,
    required this.isActive,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _kenBurnsController;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.easeInOut,
      ),
    );

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive) {
      _kenBurnsController.forward();
    }
  }

  @override
  void didUpdateWidget(StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _kenBurnsController.forward(from: 0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _kenBurnsController.reset();
    }
  }

  @override
  void dispose() {
    _kenBurnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdropUrl = widget.story.backdropUrlFullscreen;

    return Container(
      color: const Color(0xFF0B0F14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop image con Ken Burns
          if (backdropUrl != null)
            AnimatedBuilder(
              animation: _kenBurnsController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: _alignmentAnimation.value,
                  child: child,
                );
              },
              child: CachedNetworkImage(
                imageUrl: backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF0B0F14),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF0B0F14),
                  child: const Center(
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white24,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),

          // Content overlay en bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StoryContentOverlay(story: widget.story),
          ),
        ],
      ),
    );
  }
}
