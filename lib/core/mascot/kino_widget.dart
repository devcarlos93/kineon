import 'package:flutter/material.dart';
import '../theme/kineon_colors.dart';
import 'kino_mood.dart';
import 'kino_painter.dart';

/// Widget animado de Kino, la mascota proyector IA de Kineon.
///
/// Tamaños recomendados:
/// - 20-36: mini (solo cabeza simplificada)
/// - 44-56: medium (cabeza + detalles)
/// - 64-120: large (full detail + haz de luz)
class KinoWidget extends StatefulWidget {
  final double size;
  final KinoMood mood;
  final bool animated;
  final Color? color;

  const KinoWidget({
    super.key,
    required this.size,
    this.mood = KinoMood.happy,
    this.animated = true,
    this.color,
  });

  @override
  State<KinoWidget> createState() => _KinoWidgetState();
}

class _KinoWidgetState extends State<KinoWidget> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _lensController;
  late AnimationController _thinkingController;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _lensController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.animated) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(KinoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood || oldWidget.animated != widget.animated) {
      _stopAll();
      if (widget.animated) {
        _startAnimations();
      }
    }
  }

  void _startAnimations() {
    // Blink: solo en moods con ojos abiertos
    final blinkMoods = {KinoMood.happy, KinoMood.excited, KinoMood.greeting, KinoMood.watching};
    if (blinkMoods.contains(widget.mood)) {
      _blinkController.repeat();
    }

    // Lens pulse: siempre excepto sleeping
    if (widget.mood != KinoMood.sleeping) {
      _lensController.repeat();
    }

    // Thinking: solo en thinking
    if (widget.mood == KinoMood.thinking) {
      _thinkingController.repeat();
    }
  }

  void _stopAll() {
    _blinkController.stop();
    _blinkController.value = 0;
    _lensController.stop();
    _lensController.value = 0;
    _thinkingController.stop();
    _thinkingController.value = 0;
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _lensController.dispose();
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KineonColors>()!;
    final isMini = widget.size <= 36;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _blinkController,
        _lensController,
        _thinkingController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: KinoPainter(
            colors: colors,
            mood: widget.mood,
            blinkProgress: _blinkController.value,
            lensProgress: _lensController.value,
            thinkingProgress: _thinkingController.value,
            miniMode: isMini,
            colorOverride: widget.color,
          ),
        );
      },
    );
  }
}