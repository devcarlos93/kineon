import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/kineon_colors.dart';

/// Input field premium estilo Neo-cinema
class KineonInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const KineonInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
  });

  /// Input de búsqueda
  factory KineonInput.search({
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onClear,
    bool autofocus = false,
  }) {
    return KineonInput(
      controller: controller,
      hintText: hintText ?? 'Buscar películas, series...',
      prefixIcon: AppIcons.search,
      suffix: controller != null && controller.text.isNotEmpty
          ? Builder(
              builder: (context) {
                final colors = context.colors;
                return GestureDetector(
                  onTap: onClear ?? () => controller.clear(),
                  child: Icon(
                    AppIcons.close,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                );
              },
            )
          : null,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
    );
  }

  @override
  State<KineonInput> createState() => _KineonInputState();
}

class _KineonInputState extends State<KineonInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.labelMedium.copyWith(
              color: _isFocused
                  ? colors.accent
                  : colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input
        AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadii.radiusMd,
            border: Border.all(
              color: _isFocused
                  ? colors.accent.withOpacity(0.5)
                  : colors.surfaceBorder,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: AppTypography.bodyMedium,
            cursorColor: colors.accent,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: colors.textTertiary,
              ),
              prefixIcon: widget.prefix ?? (widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused
                          ? colors.accent
                          : colors.textTertiary,
                    )
                  : null),
              suffixIcon: widget.suffix ?? (widget.obscureText
                  ? GestureDetector(
                      onTap: () => setState(() => _obscureText = !_obscureText),
                      child: Icon(
                        _obscureText
                            ? AppIcons.infoOutline
                            : AppIcons.info,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                    )
                  : null),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '', // Ocultar contador
            ),
          ),
        ),
      ],
    );
  }
}

/// Search bar con estilo glass
class KineonSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool autofocus;
  final bool expanded;

  const KineonSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.autofocus = false,
    this.expanded = true,
  });

  @override
  State<KineonSearchBar> createState() => _KineonSearchBarState();
}

class _KineonSearchBarState extends State<KineonSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: AppRadii.radiusMd,
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.search,
              size: 20,
              color: colors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.search,
                style: AppTypography.bodyMedium,
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Buscar...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_hasText) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _clear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.close,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
