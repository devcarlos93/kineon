import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Tipo de acción rápida
enum QuickDecideAction {
  addToList,
  notInterested,
  viewDetails,
}

/// Card de acción rápida para "Un toque y decides"
class QuickDecideCard extends StatefulWidget {
  final QuickDecideAction action;
  final VoidCallback? onTap;

  const QuickDecideCard({
    super.key,
    required this.action,
    this.onTap,
  });

  @override
  State<QuickDecideCard> createState() => _QuickDecideCardState();
}

class _QuickDecideCardState extends State<QuickDecideCard> {
  bool _isPressed = false;

  IconData get _icon {
    switch (widget.action) {
      case QuickDecideAction.addToList:
        return Icons.playlist_add_rounded;
      case QuickDecideAction.notInterested:
        return Icons.not_interested_rounded;
      case QuickDecideAction.viewDetails:
        return Icons.info_outline_rounded;
    }
  }

  String get _label {
    switch (widget.action) {
      case QuickDecideAction.addToList:
        return 'Mi Lista';
      case QuickDecideAction.notInterested:
        return 'No me\ninteresa';
      case QuickDecideAction.viewDetails:
        return 'Ver\ndetalles';
    }
  }

  Color _getIconColor(KineonColors colors) {
    switch (widget.action) {
      case QuickDecideAction.addToList:
        return colors.accent;
      case QuickDecideAction.notInterested:
        return colors.textSecondary;
      case QuickDecideAction.viewDetails:
        return colors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = _getIconColor(colors);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _isPressed
              ? colors.surfaceElevated
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? iconColor.withValues(alpha: 0.3)
                : colors.surfaceBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo circular
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              _label,
              style: AppTypography.labelMedium.copyWith(
                color: colors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección completa "Un toque y decides"
class QuickDecideSection extends StatelessWidget {
  final VoidCallback? onAddToList;
  final VoidCallback? onNotInterested;
  final VoidCallback? onViewDetails;

  const QuickDecideSection({
    super.key,
    this.onAddToList,
    this.onNotInterested,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Un toque y decides',
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Cards horizontales
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              QuickDecideCard(
                action: QuickDecideAction.addToList,
                onTap: onAddToList,
              ),
              const SizedBox(width: 12),
              QuickDecideCard(
                action: QuickDecideAction.notInterested,
                onTap: onNotInterested,
              ),
              const SizedBox(width: 12),
              QuickDecideCard(
                action: QuickDecideAction.viewDetails,
                onTap: onViewDetails,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
