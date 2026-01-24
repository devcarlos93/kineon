import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo de Kineon reutilizable
///
/// Usa el SVG del icono de la app con gradiente turquesa → morado.
/// El tamaño por defecto es 40x40.
class KineonLogo extends StatelessWidget {
  final double size;

  const KineonLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/kineon_logo.svg',
      width: size,
      height: size,
    );
  }
}
