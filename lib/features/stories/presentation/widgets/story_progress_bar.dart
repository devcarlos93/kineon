import 'package:flutter/material.dart';

/// Barra de progreso tipo Instagram Stories
class StoryProgressBar extends StatelessWidget {
  final int storyCount;
  final int currentIndex;
  final double currentProgress;

  const StoryProgressBar({
    super.key,
    required this.storyCount,
    required this.currentIndex,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: List.generate(storyCount, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _ProgressSegment(
                isCompleted: index < currentIndex,
                isCurrent: index == currentIndex,
                progress: index == currentIndex ? currentProgress : 0.0,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final double progress;

  const _ProgressSegment({
    required this.isCompleted,
    required this.isCurrent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: isCompleted ? 1.0 : (isCurrent ? progress : 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
