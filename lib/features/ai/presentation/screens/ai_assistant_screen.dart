import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../subscription/subscription.dart';
import '../../../subscription/presentation/widgets/smart_paywall_modal.dart';
import '../providers/ai_chat_provider.dart';

/// Pantalla del Asistente IA
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showWelcomeScreen = true;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Verificar límite de uso
    if (!await ref.checkAIGate(context, AIEndpoints.chat)) {
      return; // Usuario bloqueado, paywall mostrado
    }

    _controller.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();

    // Registrar uso después de enviar
    ref.recordAIUsage(AIEndpoints.chat);
  }

  Future<void> _sendQuickReply(String text) async {
    HapticFeedback.lightImpact();

    // Verificar límite de uso
    if (!await ref.checkAIGate(context, AIEndpoints.chat)) {
      return;
    }

    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
    ref.recordAIUsage(AIEndpoints.chat);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 500,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToDetail(int tmdbId, String contentType) {
    context.push('/details/$contentType/$tmdbId');
  }

  Future<void> _addToList(int tmdbId, String contentType) async {
    HapticFeedback.mediumImpact();
    final type = contentType == 'tv' ? ContentType.tv : ContentType.movie;
    await ref.read(libraryActionsProvider.notifier).addToWatchlist(tmdbId, type);

    if (mounted) {
      final colors = context.colors;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.aiAddedToList,
            style: TextStyle(color: colors.textOnAccent),
          ),
          backgroundColor: colors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(aiChatProvider);
    final mediaQuery = MediaQuery.of(context);

    // Scroll al fondo cuando llegan nuevos mensajes
    ref.listen(aiChatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();

        // Smart paywall: cuando la IA responde por primera vez
        if (next.messages.isNotEmpty &&
            next.messages.last.role == ChatRole.assistant &&
            !next.isLoading) {
          SmartPaywallModal.maybeShow(
            context,
            ref,
            trigger: SmartPaywallTriggers.firstAiChat,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            if (_showWelcomeScreen)
              // Welcome view
              Expanded(child: _buildWelcomeView())
            else ...[
              // Chat content
              Expanded(
                child: state.isLoadingHistory
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colors.accent,
                          strokeWidth: 2,
                        ),
                      )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 16 + mediaQuery.padding.bottom,
                  ),
                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isLoading && index == state.messages.length) {
                      return const _TypingIndicator();
                    }

                    final message = state.messages[index];
                    if (message.role == ChatRole.user) {
                      return _UserBubble(text: message.text);
                    }

                    return _AssistantMessage(
                      message: message,
                      onQuickReply: _sendQuickReply,
                      onOpenDetail: _navigateToDetail,
                      onAddToList: _addToList,
                    );
                  },
                ),
              ),

              // Input
              _buildInput(state.isLoading),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        // Subtle radial glow behind mascot
        Positioned.fill(
          child: Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.08),
                    colors.accent.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Kino mascot
              const KinoMascot(size: 120, mood: KinoMood.greeting),
              const SizedBox(height: 28),

              // Title: "Hola, soy Kino."
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.aiWelcomeHello,
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'Kino.',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                l10n.aiWelcomeGreeting,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textTertiary,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Buttons side by side
              Row(
                children: [
                  // Ver historial (outlined)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showWelcomeScreen = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.accent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              color: colors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.aiViewHistory,
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nuevo chat (filled accent)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(aiChatProvider.notifier).startNewThread();
                        setState(() => _showWelcomeScreen = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.chat_bubble_fill,
                              color: colors.textOnAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.aiNewChat,
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.textOnAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final subscription = ref.watch(subscriptionProvider);
    final usage = subscription.getUsage(AIEndpoints.chat);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.surfaceBorder),
        ),
      ),
      child: Row(
        children: [
          // Kino avatar
          const KinoAvatar(size: 36),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              l10n.aiTitle,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          // New conversation button
          if (!_showWelcomeScreen) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _showWelcomeScreen = true);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.square_pencil,
                  color: colors.accent,
                  size: 17,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // Usage counter / Pro badge
          AIUsageCounter(
            remaining: usage.remaining,
            total: usage.dailyLimit,
            isPro: subscription.isPro,
            onUpgradeTap: () => context.push('/profile/subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(bool isLoading) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.surfaceBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: TextField(
                controller: _controller,
                enabled: !isLoading,
                onSubmitted: (_) => _send(),
                style: TextStyle(
                  fontFamily: AppTypography.bodyMedium.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  hintText: l10n.aiAskKineon,
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.bodyMedium.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isLoading ? null : _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading
                    ? colors.surfaceElevated
                    : colors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.arrow_up,
                color: isLoading ? colors.textTertiary : colors.background,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Indicador de que el asistente está escribiendo
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del asistente (Kino)
          const KinoAvatar(size: 32),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotAnimation(delay: 0),
                const SizedBox(width: 4),
                _DotAnimation(delay: 150),
                const SizedBox(width: 4),
                _DotAnimation(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotAnimation extends StatefulWidget {
  final int delay;
  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.4 + _animation.value * 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Burbuja del usuario
class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.accentPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.accentPurple.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensaje del asistente con cards y quick replies
class _AssistantMessage extends StatelessWidget {
  final ChatMessage message;
  final void Function(String) onQuickReply;
  final void Function(int tmdbId, String contentType) onOpenDetail;
  final void Function(int tmdbId, String contentType) onAddToList;

  const _AssistantMessage({
    required this.message,
    required this.onQuickReply,
    required this.onOpenDetail,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar Kino
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KinoAvatar(size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      AppLocalizations.of(context).aiIntelligence,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Texto del mensaje
                    Text(
                      message.text,
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

          // Cards de películas
          if (message.cards.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...message.cards.map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 42),
                  child: _MovieCard(
                    card: card,
                    onOpen: () => onOpenDetail(card.tmdbId, card.contentType),
                    onAddToList: () => onAddToList(card.tmdbId, card.contentType),
                  ),
                )),
          ],

          // Quick replies
          if (message.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: message.quickReplies.map((reply) {
                  return GestureDetector(
                    onTap: () => onQuickReply(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        reply,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card de película/serie recomendada
class _MovieCard extends StatelessWidget {
  final AiCardItem card;
  final VoidCallback onOpen;
  final VoidCallback onAddToList;

  const _MovieCard({
    required this.card,
    required this.onOpen,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backdropUrl = card.backdropUrl;
    final posterUrl = card.posterUrl;
    final imageUrl = backdropUrl ?? posterUrl;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: colors.surfaceElevated,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: colors.surfaceElevated,
                      child: Icon(
                        CupertinoIcons.film,
                        color: colors.textTertiary,
                        size: 40,
                      ),
                    ),
                  )
                : Container(
                    color: colors.surfaceElevated,
                    child: Icon(
                      CupertinoIcons.film,
                      color: colors.textTertiary,
                      size: 40,
                    ),
                  ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match %
                Text(
                  '${card.match}% MATCH',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Título
                Text(
                  card.title ?? AppLocalizations.of(context).noTitle,
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Razón
                Text(
                  card.reason,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Botones
                Row(
                  children: [
                    // Add to list
                    Expanded(
                      child: GestureDetector(
                        onTap: onAddToList,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.plus,
                                color: colors.background,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context).aiAddToList,
                                style: AppTypography.labelMedium.copyWith(
                                  color: colors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Play / Ver detalle
                    GestureDetector(
                      onTap: onOpen,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.surfaceBorder),
                        ),
                        child: Icon(
                          CupertinoIcons.play_fill,
                          color: colors.textPrimary,
                          size: 20,
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
    );
  }
}
