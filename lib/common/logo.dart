import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// The Ma Tontine logo, "Le cercle": the members around the pot, white on a
/// green rounded square. Same drawing as the launcher icon.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Ma Tontine',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 100 × 100 grid, as in the logo mockup.
    final unit = size.width / 100;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(26 * unit)),
      Paint()..color = AppColors.primary,
    );
    final white = Paint()..color = Colors.white;
    final center = Offset(50 * unit, 50 * unit);
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      canvas.drawCircle(
        center + Offset(cos(angle), sin(angle)) * (30 * unit),
        6.5 * unit,
        white,
      );
    }
    canvas.drawCircle(center, 12 * unit, white);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
