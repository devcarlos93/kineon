import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_ai_data.dart';
import 'ai_recommendation_card.dart';

/// Lista de mensajes del chat de IA
class AiMessageList extends StatelessWidget {
  final List<AiMessage> messages;
  final ScrollController? scrollController;
  final Function(AiMovieRecommendation) onRecommendationTap;
  final Function(AiMovieRecommendation) onAddToList;
  final Function(AiMovieRecommendation) onViewDetails;
  final bool isTyping;

  const AiMessageList({
    super.key,
    required this.messages,
    this.scrollController,
    required this.onRecommendationTap,
    required this.onAddToList,
    required this.onViewDetails,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == messages.length) {
          return const _TypingIndicator();
        }

        final message = messages[index];
        return _MessageBubble(
          message: message,
          onRecommendationTap: onRecommendationTap,
          onAddToList: onAddToList,
          onViewDetails: onViewDetails,
        );
      },
    );
  }
}

/// Burbuja de mensaje individual
class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  final Function(AiMovieRecommendation) onRecommendationTap;
  final Function(AiMovieRecommendation) onAddToList;
  final Function(AiMovieRecommendation) onViewDetails;

  const _MessageBubble({
    required this.message,
    required this.onRecommendationTap,
    required this.onAddToList,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _UserMessage(content: message.content);
    }

    return _AiMessage(
      message: message,
      onRecommendationTap: onRecommendationTap,
      onAddToList: onAddToList,
      onViewDetails: onViewDetails,
    );
  }
}

/// Mensaje del usuario
class _UserMessage extends StatelessWidget {
  final String content;

  const _UserMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                content,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de la IA
class _AiMessage extends StatelessWidget {
  final AiMessage message;
  final Function(AiMovieRecommendation) onRecommendationTap;
  final Function(AiMovieRecommendation) onAddToList;
  final Function(AiMovieRecommendation) onViewDetails;

  const _AiMessage({
    required this.message,
    required this.onRecommendationTap,
    required this.onAddToList,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar and text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.accent,
                      colors.accentPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kineon',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.content,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Recommendations
          if (message.recommendations != null &&
              message.recommendations!.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...message.recommendations!.map((rec) => AiRecommendationCard(
                  recommendation: rec,
                  onTap: () => onRecommendationTap(rec),
                  onAddToList: () => onAddToList(rec),
                  onViewDetails: () => onViewDetails(rec),
                )),
          ],
        ],
      ),
    );
  }
}

/// Indicador de que la IA está escribiendo
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent,
                  colors.accentPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Typing animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kineon',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final value = (_controller.value - delay) % 1.0;
                          final opacity = (value < 0.5)
                              ? value * 2
                              : 2 - value * 2;
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(
                                alpha: 0.3 + (opacity * 0.7),
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.strings.aiThinking,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado vacío para el chat de IA
class AiEmptyState extends StatelessWidget {
  const AiEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI icon with gradient
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.2),
                    colors.accentPurple.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: colors.accent,
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.strings.aiWelcomeTitle,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.strings.aiWelcomeSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
