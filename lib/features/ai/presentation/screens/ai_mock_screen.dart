import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_ai_data.dart';
import '../widgets/ai_composer.dart';
import '../widgets/ai_message_list.dart';
import '../widgets/ai_states.dart';
import '../widgets/quick_decision_card.dart';
import '../widgets/quick_prompts_row.dart';

/// Pantalla de IA con mock data y diseño Stitch
class AiMockScreen extends StatefulWidget {
  const AiMockScreen({super.key});

  @override
  State<AiMockScreen> createState() => _AiMockScreenState();
}

class _AiMockScreenState extends State<AiMockScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isLoading = false;
  bool _isQuickDecisionMode = false;
  int _quickDecisionIndex = 0;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(AiMessage(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _textController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Simular respuesta de IA
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add(mockAiResponse);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _handleQuickPrompt(QuickPrompt prompt) {
    HapticFeedback.lightImpact();
    _textController.text = prompt.text;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleRecommendationTap(AiMovieRecommendation recommendation) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to movie detail
  }

  void _handleAddToList(AiMovieRecommendation recommendation) {
    HapticFeedback.mediumImpact();
    setState(() {
      final index = _findRecommendationIndex(recommendation.id);
      if (index != (-1, -1)) {
        final message = _messages[index.$1];
        final recs = List<AiMovieRecommendation>.from(message.recommendations!);
        recs[index.$2] = recommendation.copyWith(
          inWatchlist: !recommendation.inWatchlist,
        );
        _messages[index.$1] = AiMessage(
          id: message.id,
          content: message.content,
          isUser: message.isUser,
          timestamp: message.timestamp,
          recommendations: recs,
        );
      }
    });
  }

  void _handleViewDetails(AiMovieRecommendation recommendation) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to movie detail
  }

  (int, int) _findRecommendationIndex(int id) {
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (message.recommendations != null) {
        for (int j = 0; j < message.recommendations!.length; j++) {
          if (message.recommendations![j].id == id) {
            return (i, j);
          }
        }
      }
    }
    return (-1, -1);
  }

  void _enterQuickDecisionMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isQuickDecisionMode = true;
      _quickDecisionIndex = 0;
    });
  }

  void _exitQuickDecisionMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isQuickDecisionMode = false;
    });
  }

  void _handleQuickDecisionLike(QuickDecisionItem item) {
    setState(() {
      _quickDecisionIndex++;
    });
  }

  void _handleQuickDecisionDislike(QuickDecisionItem item) {
    setState(() {
      _quickDecisionIndex++;
    });
  }

  void _handleQuickDecisionSkip(QuickDecisionItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      _quickDecisionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (_isQuickDecisionMode) {
      return _buildQuickDecisionMode();
    }

    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Header
          AiHeader(
            onHistoryTap: () {
              // TODO: Show history
            },
            onSettingsTap: _enterQuickDecisionMode,
          ),

          // Quick prompts (solo si no hay mensajes)
          if (_messages.isEmpty) ...[
            const SizedBox(height: 8),
            QuickPromptsRow(
              prompts: defaultQuickPrompts,
              onPromptTap: _handleQuickPrompt,
            ),
          ],

          // Messages or empty state
          Expanded(
            child: _messages.isEmpty
                ? const AiEmptyState()
                : AiMessageList(
                    messages: _messages,
                    scrollController: _scrollController,
                    onRecommendationTap: _handleRecommendationTap,
                    onAddToList: _handleAddToList,
                    onViewDetails: _handleViewDetails,
                    isTyping: _isLoading,
                  ),
          ),

          // Quick prompts (si hay mensajes)
          if (_messages.isNotEmpty && !_isLoading) ...[
            const SizedBox(height: 8),
            QuickPromptsRow(
              prompts: defaultQuickPrompts,
              onPromptTap: _handleQuickPrompt,
            ),
            const SizedBox(height: 8),
          ],

          // Composer
          AiComposer(
            controller: _textController,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDecisionMode() {
    final colors = context.colors;
    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Header
          QuickDecisionHeader(
            onClose: _exitQuickDecisionMode,
            current: _quickDecisionIndex + 1,
            total: mockQuickDecisionItems.length,
          ),

          // Card stack
          Expanded(
            child: Center(
              child: QuickDecisionStack(
                items: mockQuickDecisionItems,
                currentIndex: _quickDecisionIndex,
                onLike: _handleQuickDecisionLike,
                onDislike: _handleQuickDecisionDislike,
                onSkip: _handleQuickDecisionSkip,
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 32,
            ),
            child: QuickDecisionButtons(
              onDislike: () {
                if (_quickDecisionIndex < mockQuickDecisionItems.length) {
                  _handleQuickDecisionDislike(
                    mockQuickDecisionItems[_quickDecisionIndex],
                  );
                }
              },
              onSkip: () {
                if (_quickDecisionIndex < mockQuickDecisionItems.length) {
                  _handleQuickDecisionSkip(
                    mockQuickDecisionItems[_quickDecisionIndex],
                  );
                }
              },
              onLike: () {
                if (_quickDecisionIndex < mockQuickDecisionItems.length) {
                  _handleQuickDecisionLike(
                    mockQuickDecisionItems[_quickDecisionIndex],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
