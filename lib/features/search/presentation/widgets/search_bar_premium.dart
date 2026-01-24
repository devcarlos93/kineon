import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Material, TextField, InputDecoration, InputBorder;
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Search bar premium con icono IA y micrófono
class SearchBarPremium extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? suggestionText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;
  final VoidCallback? onClear;
  final bool isLoading;

  const SearchBarPremium({
    super.key,
    required this.controller,
    this.hintText = 'Algo como Interstellar...',
    this.suggestionText,
    this.onChanged,
    this.onSubmitted,
    this.onMicTap,
    this.onClear,
    this.isLoading = false,
  });

  @override
  State<SearchBarPremium> createState() => _SearchBarPremiumState();
}

class _SearchBarPremiumState extends State<SearchBarPremium> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? colors.accent.withValues(alpha: 0.5)
                  : colors.surfaceBorder,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // AI Icon
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _AIIcon(isActive: _isFocused || widget.controller.text.isNotEmpty),
              ),

              // Text field
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyMedium.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                    cursorColor: colors.accent,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.bodyMedium.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading or clear/mic button
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CupertinoActivityIndicator(),
                )
              else if (widget.controller.text.isNotEmpty)
                CupertinoButton(
                  padding: const EdgeInsets.only(right: 12),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.controller.clear();
                    _focusNode.unfocus();
                    widget.onClear?.call();
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: colors.textTertiary,
                    size: 20,
                  ),
                )
              else
                CupertinoButton(
                  padding: const EdgeInsets.only(right: 12),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onMicTap?.call();
                  },
                  child: Icon(
                    CupertinoIcons.mic,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),

        // Suggestion text
        if (widget.suggestionText != null && widget.controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Text(
              'Try "${widget.suggestionText}"',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// Icono de IA con gradiente
class _AIIcon extends StatelessWidget {
  final bool isActive;

  const _AIIcon({this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.gradientPrimary : null,
        color: isActive ? null : colors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        CupertinoIcons.sparkles,
        color: isActive ? AppColors.textOnAccent : colors.textTertiary,
        size: 16,
      ),
    );
  }
}

/// Skeleton del search bar
class SearchBarSkeleton extends StatelessWidget {
  const SearchBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
