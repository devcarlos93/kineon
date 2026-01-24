import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import '../theme/kineon_colors.dart';

/// Chip elegante estilo Neo-cinema
///
/// Variantes:
/// - Default: outline sutil
/// - Filled: fondo con color
/// - Accent: con color de acento
/// - Glass: efecto transparente
enum KineonChipVariant { outline, filled, accent, glass }

class KineonChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final KineonChipVariant variant;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;

  const KineonChip({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.trailing,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    this.variant = KineonChipVariant.outline,
    this.accentColor,
    this.padding,
  });

  /// Chip con icono a la izquierda
  factory KineonChip.icon({
    required String label,
    required IconData icon,
    bool selected = false,
    VoidCallback? onTap,
    KineonChipVariant variant = KineonChipVariant.outline,
  }) {
    return KineonChip(
      label: label,
      icon: icon,
      selected: selected,
      onTap: onTap,
      variant: variant,
    );
  }

  @override
  State<KineonChip> createState() => _KineonChipState();
}

class _KineonChipState extends State<KineonChip>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Color _accentColor(KineonColors colors) => widget.accentColor ?? colors.accent;

  Color _backgroundColor(KineonColors colors) {
    final accentColor = _accentColor(colors);

    if (!widget.enabled) {
      return colors.surface.withOpacity(0.5);
    }

    switch (widget.variant) {
      case KineonChipVariant.outline:
        return widget.selected
            ? accentColor.withOpacity(0.12)
            : Colors.transparent;
      case KineonChipVariant.filled:
        return widget.selected
            ? accentColor.withOpacity(0.15)
            : colors.surfaceElevated;
      case KineonChipVariant.accent:
        return widget.selected
            ? accentColor
            : accentColor.withOpacity(0.12);
      case KineonChipVariant.glass:
        return widget.selected
            ? colors.textPrimary.withOpacity(0.1)
            : colors.textPrimary.withOpacity(0.04);
    }
  }

  Color _borderColor(KineonColors colors) {
    final accentColor = _accentColor(colors);

    if (!widget.enabled) {
      return colors.surfaceBorder.withOpacity(0.5);
    }

    switch (widget.variant) {
      case KineonChipVariant.outline:
        return widget.selected
            ? accentColor.withOpacity(0.5)
            : colors.surfaceBorder;
      case KineonChipVariant.filled:
        return widget.selected
            ? accentColor.withOpacity(0.3)
            : colors.surfaceBorder;
      case KineonChipVariant.accent:
        return widget.selected
            ? accentColor
            : accentColor.withOpacity(0.3);
      case KineonChipVariant.glass:
        return colors.textPrimary.withOpacity(0.08);
    }
  }

  Color _textColor(KineonColors colors) {
    final accentColor = _accentColor(colors);

    if (!widget.enabled) {
      return colors.textTertiary;
    }

    if (widget.variant == KineonChipVariant.accent && widget.selected) {
      return colors.textOnAccent;
    }

    return widget.selected
        ? accentColor
        : colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = _backgroundColor(colors);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? bgColor.withOpacity(
                  bgColor.opacity + 0.05,
                )
              : bgColor,
          borderRadius: AppRadii.radiusFull,
          border: Border.all(
            color: _borderColor(colors),
            width: widget.selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 6),
            ] else if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 16,
                color: _textColor(colors),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: AppTypography.labelMedium.copyWith(
                color: _textColor(colors),
                fontWeight: widget.selected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 6),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Grupo de chips con selección
class KineonChipGroup extends StatelessWidget {
  final List<String> labels;
  final List<IconData>? icons;
  final int? selectedIndex;
  final Set<int>? selectedIndices;
  final ValueChanged<int>? onSelected;
  final bool multiSelect;
  final KineonChipVariant variant;
  final double spacing;
  final double runSpacing;

  const KineonChipGroup({
    super.key,
    required this.labels,
    this.icons,
    this.selectedIndex,
    this.selectedIndices,
    this.onSelected,
    this.multiSelect = false,
    this.variant = KineonChipVariant.outline,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: List.generate(labels.length, (index) {
        final isSelected = multiSelect
            ? (selectedIndices?.contains(index) ?? false)
            : selectedIndex == index;

        return KineonChip(
          label: labels[index],
          icon: icons != null && index < icons!.length ? icons![index] : null,
          selected: isSelected,
          variant: variant,
          onTap: () => onSelected?.call(index),
        );
      }),
    );
  }
}

/// Badge pequeño para contadores/estados
class KineonBadge extends StatelessWidget {
  final String? label;
  final int? count;
  final Color? color;
  final bool dot;
  final double size;

  const KineonBadge({
    super.key,
    this.label,
    this.count,
    this.color,
    this.dot = false,
    this.size = 18,
  });

  const KineonBadge.dot({
    super.key,
    this.color,
    this.size = 8,
  })  : dot = true,
        label = null,
        count = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = color ?? colors.accent;

    if (dot) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
      );
    }

    final text = label ?? (count != null ? '$count' : '');

    return Container(
      height: size,
      constraints: BoxConstraints(minWidth: size),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.radiusFull,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: colors.textOnAccent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
