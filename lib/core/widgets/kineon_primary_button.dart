import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Botón primario premium de Kineon
///
/// Estilos disponibles:
/// - `filled` (default): Fondo turquesa sólido
/// - `outline`: Solo borde, fondo transparente
/// - `ghost`: Sin borde ni fondo, solo texto
///
/// Tamaños:
/// - `small`: Padding reducido
/// - `medium` (default): Padding estándar
/// - `large`: Padding extra
enum KineonButtonStyle { filled, outline, ghost }
enum KineonButtonSize { small, medium, large }

class KineonPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final KineonButtonStyle style;
  final KineonButtonSize size;
  final Color? color;
  final bool isLoading;
  final bool expanded;

  const KineonPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.style = KineonButtonStyle.filled,
    this.size = KineonButtonSize.medium,
    this.color,
    this.isLoading = false,
    this.expanded = false,
  });

  /// Constructor para botón con icono de flecha hacia adelante
  const KineonPrimaryButton.next({
    super.key,
    required this.label,
    this.onPressed,
    this.style = KineonButtonStyle.filled,
    this.size = KineonButtonSize.medium,
    this.color,
    this.isLoading = false,
    this.expanded = false,
  })  : leadingIcon = null,
        trailingIcon = Icons.arrow_forward_rounded;

  /// Constructor para botón con solo icono
  factory KineonPrimaryButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    KineonButtonStyle style = KineonButtonStyle.filled,
    KineonButtonSize size = KineonButtonSize.medium,
    Color? color,
    bool isLoading = false,
  }) {
    return KineonPrimaryButton(
      key: key,
      label: '',
      onPressed: onPressed,
      leadingIcon: icon,
      style: style,
      size: size,
      color: color,
      isLoading: isLoading,
    );
  }

  @override
  State<KineonPrimaryButton> createState() => _KineonPrimaryButtonState();
}

class _KineonPrimaryButtonState extends State<KineonPrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Color _primaryColor(KineonColors colors) => widget.color ?? colors.accent;

  EdgeInsets get _padding {
    switch (widget.size) {
      case KineonButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case KineonButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case KineonButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case KineonButtonSize.small:
        return 16;
      case KineonButtonSize.medium:
        return 20;
      case KineonButtonSize.large:
        return 24;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case KineonButtonSize.small:
        return AppTypography.labelMedium;
      case KineonButtonSize.medium:
        return AppTypography.labelLarge;
      case KineonButtonSize.large:
        return AppTypography.labelLarge.copyWith(fontSize: 17);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: _padding,
        decoration: _buildDecoration(isDisabled, colors),
        child: widget.expanded
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildContent(isDisabled, colors),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildContent(isDisabled, colors),
              ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDisabled, KineonColors colors) {
    final primaryColor = _primaryColor(colors);

    switch (widget.style) {
      case KineonButtonStyle.filled:
        return BoxDecoration(
          color: isDisabled
              ? primaryColor.withOpacity(0.3)
              : _isPressed
                  ? primaryColor.withOpacity(0.85)
                  : primaryColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled || _isPressed
              ? null
              : [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        );

      case KineonButtonStyle.outline:
        return BoxDecoration(
          color: _isPressed
              ? primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? primaryColor.withOpacity(0.3)
                : primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        );

      case KineonButtonStyle.ghost:
        return BoxDecoration(
          color: _isPressed
              ? primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        );
    }
  }

  List<Widget> _buildContent(bool isDisabled, KineonColors colors) {
    final primaryColor = _primaryColor(colors);
    final Color textColor;

    switch (widget.style) {
      case KineonButtonStyle.filled:
        textColor = isDisabled
            ? colors.textOnAccent.withOpacity(0.5)
            : colors.textOnAccent;
        break;
      case KineonButtonStyle.outline:
      case KineonButtonStyle.ghost:
        textColor = isDisabled
            ? primaryColor.withOpacity(0.5)
            : primaryColor;
        break;
    }

    if (widget.isLoading) {
      return [
        RotationTransition(
          turns: _loadingController,
          child: Icon(
            Icons.refresh_rounded,
            color: textColor,
            size: _iconSize,
          ),
        ),
      ];
    }

    return [
      if (widget.leadingIcon != null) ...[
        Icon(
          widget.leadingIcon,
          color: textColor,
          size: _iconSize,
        ),
        if (widget.label.isNotEmpty) const SizedBox(width: 8),
      ],
      if (widget.label.isNotEmpty)
        Text(
          widget.label,
          style: _textStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      if (widget.trailingIcon != null) ...[
        if (widget.label.isNotEmpty) const SizedBox(width: 8),
        Icon(
          widget.trailingIcon,
          color: textColor,
          size: _iconSize,
        ),
      ],
    ];
  }
}
