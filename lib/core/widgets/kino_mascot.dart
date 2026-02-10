import 'package:flutter/material.dart';
import '../mascot/kino_mood.dart';
import '../mascot/kino_widget.dart';

export '../mascot/kino_mood.dart';
export '../mascot/kino_widget.dart';

/// Mascota Kino — Cuerpo completo (para splash, empty states, errors).
class KinoMascot extends StatelessWidget {
  final double size;
  final KinoMood mood;

  const KinoMascot({super.key, this.size = 120, this.mood = KinoMood.happy});

  @override
  Widget build(BuildContext context) {
    return KinoWidget(size: size, mood: mood);
  }
}

/// Avatar compacto de Kino para chat, badges, headers.
class KinoAvatar extends StatelessWidget {
  final double size;
  final KinoMood mood;

  const KinoAvatar({super.key, this.size = 32, this.mood = KinoMood.happy});

  @override
  Widget build(BuildContext context) {
    return KinoWidget(size: size, mood: mood);
  }
}

/// Ícono minimalista de Kino para nav bar, tabs. Legible desde 20px.
class KinoIcon extends StatelessWidget {
  final double size;
  final KinoMood mood;
  final Color? color;

  const KinoIcon({super.key, this.size = 26, this.mood = KinoMood.happy, this.color});

  @override
  Widget build(BuildContext context) {
    return KinoWidget(size: size, mood: mood, color: color);
  }
}