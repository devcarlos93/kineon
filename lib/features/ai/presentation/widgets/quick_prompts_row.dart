import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_ai_data.dart';

/// Row de quick prompts para sugerencias rápidas
class QuickPromptsRow extends StatelessWidget {
  final List<QuickPrompt> prompts;
  final ValueChanged<QuickPrompt> onPromptTap;

  const QuickPromptsRow({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return Padding(
            padding: EdgeInsets.only(right: index < prompts.length - 1 ? 10 : 0),
            child: _QuickPromptChip(
              prompt: prompt,
              onTap: () => onPromptTap(prompt),
            ),
          );
        },
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final QuickPrompt prompt;
  final VoidCallback onTap;

  const _QuickPromptChip({
    required this.prompt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.accent.withValues(alpha: 0.15),
              colors.accentPurple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prompt.icon != null) ...[
              Text(
                prompt.icon!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              prompt.text,
              style: AppTypography.labelMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para quick prompts
class QuickPromptsRowSkeleton extends StatelessWidget {
  const QuickPromptsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: EdgeInsets.only(right: index < 3 ? 10 : 0),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
