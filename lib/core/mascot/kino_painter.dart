import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/kineon_colors.dart';
import 'kino_mood.dart';

/// CustomPainter que dibuja a Kino, la mascota proyector de Kineon.
/// Forma basada en un robot redondeado reinterpretado como proyector cinematográfico.
/// Ojos bicolor: izquierdo teal (accent), derecho morado (accentPurple).
class KinoPainter extends CustomPainter {
  final KineonColors colors;
  final KinoMood mood;
  final double blinkProgress;
  final double lensProgress;
  final double thinkingProgress;
  final bool miniMode;
  final Color? colorOverride;

  KinoPainter({
    required this.colors,
    required this.mood,
    this.blinkProgress = 0.0,
    this.lensProgress = 0.0,
    this.thinkingProgress = 0.0,
    this.miniMode = false,
    this.colorOverride,
  });

  /// Color primario de trazos y ojo izquierdo.
  Color get _primary => colorOverride ?? colors.accent;

  /// Color del ojo derecho.
  Color get _secondary => colorOverride ?? colors.accentPurple;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (miniMode) {
      _paintMini(canvas, w, h);
    } else {
      _paintFull(canvas, w, h);
    }
  }

  // ==========================================
  // MINI MODE (≤36px) - Solo cabeza simplificada
  // ==========================================
  void _paintMini(Canvas canvas, double w, double h) {
    final cx = w / 2;
    final cy = h / 2;
    final bodyW = w * 0.84;
    final bodyH = w * 0.50;

    // Cuerpo
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: bodyW, height: bodyH),
      Radius.circular(bodyH * 0.45),
    );
    canvas.drawRRect(bodyRect, Paint()..color = colors.surface);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = _primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07,
    );

    // Status dot (con bounce sutil)
    final dotBounce = math.sin(lensProgress * math.pi * 2) * w * 0.02;
    canvas.drawCircle(
      Offset(cx, cy - bodyH / 2 - w * 0.06 + dotBounce),
      w * 0.045,
      Paint()..color = _primary,
    );

    // Ojos
    final eyeSpacing = bodyW * 0.19;
    _drawEyes(canvas, cx, cy + bodyH * 0.02, eyeSpacing, bodyH * 0.30);
  }

  // ==========================================
  // FULL MODE (>36px) - Cuerpo completo con detalles
  // ==========================================
  void _paintFull(Canvas canvas, double w, double h) {
    final cx = w / 2;
    final bodyCy = h * 0.44;
    final bodyW = w * 0.72;
    final bodyH = w * 0.40;
    final bodyR = bodyH * 0.45;

    // ── Haz de luz (solo para tamaños grandes) ──
    if (w > 60) {
      _drawLightBeam(canvas, cx, bodyCy + bodyH / 2, w, h);
    }

    // ── Cuerpo principal del proyector ──
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, bodyCy), width: bodyW, height: bodyH),
      Radius.circular(bodyR),
    );
    canvas.drawRRect(bodyRect, Paint()..color = colors.surface);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = _primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04,
    );

    // ── Visor interno (placa frontal oscura) ──
    final visorW = bodyW * 0.80;
    final visorH = bodyH * 0.75;
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, bodyCy), width: visorW, height: visorH),
      Radius.circular(bodyR * 0.70),
    );
    canvas.drawRRect(visorRect, Paint()..color = colors.background);
    canvas.drawRRect(
      visorRect,
      Paint()
        ..color = _primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );

    // ── Ventilas laterales ──
    final ventW = w * 0.10;
    final ventH = w * 0.17;
    _drawVent(canvas, cx - bodyW / 2 - ventW * 0.55, bodyCy, ventW, ventH, w);
    _drawVent(canvas, cx + bodyW / 2 + ventW * 0.55, bodyCy, ventW, ventH, w);

    // ── Indicador de estado ──
    _drawStatusIndicator(canvas, cx, bodyCy - bodyH / 2, w);

    // ── Ojos-lente ──
    final eyeSpacing = bodyW * 0.22;
    final eyeSize = bodyH * 0.30;
    _drawEyes(canvas, cx, bodyCy, eyeSpacing, eyeSize);
  }

  // ==========================================
  // INDICADOR DE ESTADO (reemplaza antena de Trakki)
  // ==========================================
  void _drawStatusIndicator(Canvas canvas, double cx, double bodyTop, double w) {
    final statusY = bodyTop - w * 0.09;
    final bounce = math.sin(lensProgress * math.pi * 2) * w * 0.02;

    // Conector
    canvas.drawLine(
      Offset(cx, bodyTop),
      Offset(cx, statusY + w * 0.03 + bounce),
      Paint()
        ..color = _primary.withValues(alpha: 0.6)
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round,
    );

    // Glow
    canvas.drawCircle(
      Offset(cx, statusY + bounce),
      w * 0.04,
      Paint()
        ..color = _primary.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03),
    );

    // Dot sólido
    canvas.drawCircle(
      Offset(cx, statusY + bounce),
      w * 0.028,
      Paint()..color = _primary,
    );

    // Anillo
    canvas.drawCircle(
      Offset(cx, statusY + bounce),
      w * 0.045,
      Paint()
        ..color = _primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
  }

  // ==========================================
  // VENTILAS LATERALES
  // ==========================================
  void _drawVent(Canvas canvas, double cx, double cy, double vw, double vh, double w) {
    final ventRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: vw, height: vh),
      Radius.circular(vw * 0.38),
    );
    canvas.drawRRect(ventRect, Paint()..color = colors.surface);
    canvas.drawRRect(
      ventRect,
      Paint()
        ..color = _primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );

    // Líneas de ventilación
    final linePaint = Paint()
      ..color = _primary.withValues(alpha: 0.35)
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    final lineW = vw * 0.45;
    for (int i = -1; i <= 1; i++) {
      final ly = cy + i * vh * 0.22;
      canvas.drawLine(Offset(cx - lineW, ly), Offset(cx + lineW, ly), linePaint);
    }
  }

  // ==========================================
  // HAZ DE LUZ
  // ==========================================
  void _drawLightBeam(Canvas canvas, double cx, double beamTop, double w, double h) {
    final beamBottom = h * 0.94;
    final topHalfW = w * 0.13;
    final bottomHalfW = w * 0.28;

    // Brillo del haz según mood
    final beamAlpha = mood == KinoMood.watching ? 0.08 : 0.03;

    final beamPath = Path()
      ..moveTo(cx - topHalfW, beamTop + w * 0.02)
      ..lineTo(cx - bottomHalfW, beamBottom)
      ..lineTo(cx + bottomHalfW, beamBottom)
      ..lineTo(cx + topHalfW, beamTop + w * 0.02)
      ..close();

    canvas.drawPath(
      beamPath,
      Paint()..color = _primary.withValues(alpha: beamAlpha),
    );
    canvas.drawPath(
      beamPath,
      Paint()
        ..color = _primary.withValues(alpha: beamAlpha * 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008,
    );

    // Líneas de escaneo horizontales
    final scanPaint = Paint()
      ..color = _primary.withValues(alpha: 0.04)
      ..strokeWidth = w * 0.006;
    final totalH = beamBottom - beamTop;
    for (int i = 1; i <= 3; i++) {
      final t = i / 4;
      final ly = beamTop + totalH * t;
      final halfW = topHalfW + (bottomHalfW - topHalfW) * t;
      canvas.drawLine(Offset(cx - halfW, ly), Offset(cx + halfW, ly), scanPaint);
    }
  }

  // ==========================================
  // OJOS — Expresiones emocionales
  // ==========================================
  void _drawEyes(Canvas canvas, double cx, double cy, double spacing, double eyeSize) {
    final leftX = cx - spacing;
    final rightX = cx + spacing;

    final isBlinking = blinkProgress > 0.85;

    switch (mood) {
      case KinoMood.happy:
        if (isBlinking) {
          _drawClosedLens(canvas, leftX, cy, eyeSize, _primary);
          _drawClosedLens(canvas, rightX, cy, eyeSize, _secondary);
        } else {
          _drawHappyLens(canvas, leftX, cy, eyeSize, _primary);
          _drawHappyLens(canvas, rightX, cy, eyeSize, _secondary);
        }
        break;

      case KinoMood.excited:
        if (isBlinking) {
          _drawClosedLens(canvas, leftX, cy, eyeSize, _primary);
          _drawClosedLens(canvas, rightX, cy, eyeSize, _secondary);
        } else {
          _drawStarLens(canvas, leftX, cy, eyeSize, _primary);
          _drawStarLens(canvas, rightX, cy, eyeSize, _secondary);
        }
        break;

      case KinoMood.watching:
        if (isBlinking) {
          _drawClosedLens(canvas, leftX, cy, eyeSize, _primary);
          _drawClosedLens(canvas, rightX, cy, eyeSize, _secondary);
        } else {
          _drawWatchingLens(canvas, leftX, cy, eyeSize, _primary);
          _drawWatchingLens(canvas, rightX, cy, eyeSize, _secondary);
        }
        break;

      case KinoMood.thinking:
        _drawThinkingLenses(canvas, leftX, rightX, cy, eyeSize);
        break;

      case KinoMood.sleeping:
        _drawClosedLens(canvas, leftX, cy, eyeSize, _primary);
        _drawClosedLens(canvas, rightX, cy, eyeSize, _secondary);
        if (!miniMode) {
          _drawZzz(canvas, rightX + spacing * 0.7, cy - eyeSize * 1.5);
        }
        break;

      case KinoMood.greeting:
        if (isBlinking) {
          _drawClosedLens(canvas, leftX, cy, eyeSize, _primary);
          _drawClosedLens(canvas, rightX, cy, eyeSize, _secondary);
        } else {
          _drawHappyLens(canvas, leftX, cy, eyeSize, _primary);
          _drawWatchingLens(canvas, rightX, cy, eyeSize, _secondary);
        }
        break;
    }
  }

  /// ^  lente feliz (arco suave hacia arriba)
  void _drawHappyLens(Canvas canvas, double x, double y, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.38
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(x - size * 0.6, y + size * 0.1)
      ..quadraticBezierTo(x, y - size * 0.8, x + size * 0.6, y + size * 0.1);
    canvas.drawPath(path, paint);
  }

  /// O  lente enfocado (circular grande con pupila y highlight)
  void _drawWatchingLens(Canvas canvas, double x, double y, double size, Color color) {
    // Glow externo
    canvas.drawCircle(
      Offset(x, y),
      size * 0.55,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.2),
    );
    // Iris
    canvas.drawCircle(Offset(x, y), size * 0.5, Paint()..color = color);
    // Pupila
    canvas.drawCircle(
      Offset(x, y),
      size * 0.22,
      Paint()..color = colors.background,
    );
    // Highlight
    canvas.drawCircle(
      Offset(x - size * 0.14, y - size * 0.14),
      size * 0.12,
      Paint()..color = colors.textPrimary.withValues(alpha: 0.85),
    );
    // Highlight secundario
    canvas.drawCircle(
      Offset(x + size * 0.12, y + size * 0.12),
      size * 0.06,
      Paint()..color = colors.textPrimary.withValues(alpha: 0.4),
    );
  }

  /// -  lente cerrado (línea horizontal)
  void _drawClosedLens(Canvas canvas, double x, double y, double size, Color color) {
    canvas.drawLine(
      Offset(x - size * 0.45, y),
      Offset(x + size * 0.45, y),
      Paint()
        ..color = color
        ..strokeWidth = size * 0.3
        ..strokeCap = StrokeCap.round,
    );
  }

  /// *  lente estrella (excited/idea)
  void _drawStarLens(Canvas canvas, double x, double y, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    const points = 4;
    final outerR = size * 0.5;
    final innerR = size * 0.22;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / points) - math.pi / 2;
      final px = x + r * math.cos(angle);
      final py = y + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Highlight central
    canvas.drawCircle(
      Offset(x - size * 0.08, y - size * 0.08),
      size * 0.08,
      Paint()..color = colors.textPrimary.withValues(alpha: 0.6),
    );
  }

  /// ._. .  dots animados para thinking
  void _drawThinkingLenses(
    Canvas canvas, double leftX, double rightX, double cy, double size,
  ) {
    final dotR = size * 0.22;
    final dots = [leftX - size * 0.3, leftX + size * 0.3, rightX];
    final dotColors = [_primary, _primary, _secondary];

    for (int i = 0; i < dots.length; i++) {
      final phase = (thinkingProgress + i * 0.33) % 1.0;
      final alpha = 0.3 + 0.7 * ((math.sin(phase * math.pi * 2) + 1) / 2);
      final bounce = math.sin(phase * math.pi * 2) * size * 0.15;
      canvas.drawCircle(
        Offset(dots[i], cy + bounce),
        dotR,
        Paint()..color = dotColors[i].withValues(alpha: alpha),
      );
    }
  }

  /// Zzz para sleeping
  void _drawZzz(Canvas canvas, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: _primary.withValues(alpha: 0.5),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x, y));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: _secondary.withValues(alpha: 0.3),
          fontSize: 7,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(x + 6, y - 8));
  }

  @override
  bool shouldRepaint(covariant KinoPainter old) {
    return old.colors != colors ||
        old.mood != mood ||
        old.blinkProgress != blinkProgress ||
        old.lensProgress != lensProgress ||
        old.thinkingProgress != thinkingProgress ||
        old.miniMode != miniMode ||
        old.colorOverride != colorOverride;
  }
}