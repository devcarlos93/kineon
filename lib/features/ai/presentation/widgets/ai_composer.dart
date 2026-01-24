import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Composer de entrada para el chat de IA
class AiComposer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final String? hintText;

  const AiComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<AiComposer> createState() => _AiComposerState();
}

class _AiComposerState extends State<AiComposer> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isEmpty || widget.isLoading) return;
    HapticFeedback.mediumImpact();
    widget.onSend();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.surfaceBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.surfaceBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      placeholder: widget.hintText ?? l10n.strings.aiAskKineon,
                      placeholderStyle: AppTypography.bodyMedium.copyWith(
                        color: colors.textTertiary,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.transparent,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Send button
          GestureDetector(
            onTap: _handleSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _hasText && !widget.isLoading
                    ? AppColors.gradientPrimary
                    : null,
                color: _hasText && !widget.isLoading
                    ? null
                    : colors.surface,
                shape: BoxShape.circle,
                border: _hasText && !widget.isLoading
                    ? null
                    : Border.all(color: colors.surfaceBorder),
              ),
              child: widget.isLoading
                  ? const CupertinoActivityIndicator()
                  : Icon(
                      CupertinoIcons.arrow_up,
                      color: _hasText
                          ? AppColors.textOnAccent
                          : colors.textTertiary,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton del composer
class AiComposerSkeleton extends StatelessWidget {
  const AiComposerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
