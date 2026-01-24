import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

/// Loading State premium reutilizable
///
/// Uso básico:
/// ```dart
/// KineonLoadingState()
/// ```
///
/// Con mensaje:
/// ```dart
/// KineonLoadingState(message: 'Cargando películas...')
/// ```
///
/// Compacto (inline):
/// ```dart
/// KineonLoadingState.compact()
/// ```
class KineonLoadingState extends StatefulWidget {
  final String? message;
  final bool compact;
  final bool overlay;

  const KineonLoadingState({
    super.key,
    this.message,
    this.compact = false,
    this.overlay = false,
  });

  /// Loading compacto para uso inline
  factory KineonLoadingState.compact({Key? key}) {
    return KineonLoadingState(key: key, compact: true);
  }

  /// Loading como overlay sobre contenido
  factory KineonLoadingState.overlay({Key? key, String? message}) {
    return KineonLoadingState(key: key, message: message, overlay: true);
  }

  @override
  State<KineonLoadingState> createState() => _KineonLoadingStateState();
}

class _KineonLoadingStateState extends State<KineonLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (widget.compact) {
      return _buildCompact(colors);
    }
    if (widget.overlay) {
      return _buildOverlay(colors);
    }
    return _buildFull(colors);
  }

  Widget _buildFull(KineonColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animado
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _KineonLoadingIcon(colors: colors),
              );
            },
          ),

          if (widget.message != null) ...[
            const SizedBox(height: 20),
            Text(
              widget.message!,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(KineonColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CupertinoActivityIndicator(
            color: colors.accent,
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(width: 12),
          Text(
            widget.message!,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverlay(KineonColors colors) {
    return Container(
      color: colors.background.withValues(alpha: 0.8),
      child: _buildFull(colors),
    );
  }
}

/// Icono de loading de Kineon
class _KineonLoadingIcon extends StatelessWidget {
  final KineonColors colors;

  const _KineonLoadingIcon({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.15),
            colors.accentPurple.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CupertinoActivityIndicator(
          color: colors.accent,
          radius: 14,
        ),
      ),
    );
  }
}

/// Skeleton loader para cards
class KineonSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const KineonSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Skeleton circular (para avatars)
  factory KineonSkeleton.circle({Key? key, required double size}) {
    return KineonSkeleton(
      key: key,
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  /// Skeleton para texto
  factory KineonSkeleton.text({Key? key, double width = 100, double height = 14}) {
    return KineonSkeleton(
      key: key,
      width: width,
      height: height,
      borderRadius: 4,
    );
  }

  @override
  State<KineonSkeleton> createState() => _KineonSkeletonState();
}

class _KineonSkeletonState extends State<KineonSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                colors.surfaceElevated,
                colors.surfaceElevated.withValues(alpha: 0.5),
                colors.surfaceElevated,
              ],
            ),
          ),
        );
      },
    );
  }
}
