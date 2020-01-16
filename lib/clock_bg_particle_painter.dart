import 'dart:ui';

import 'package:flutter/material.dart';

import 'clock_fx.dart';

class ClockBgParticlePainter extends CustomPainter {
  ClockFx fx;

  // ChangeNotifier used as repaint notifier.
  ClockBgParticlePainter({@required this.fx}) : super(repaint: fx);

  @override
  void paint(Canvas canvas, Size size) {
    fx.particles.forEach((p) {
      var pos = Offset(p.x, p.y);

      var paint = Paint()
        ..color = p.color.withAlpha((255 * p.a).floor())
        ..strokeWidth = p.size * .2
        ..style = p.isFilled ? PaintingStyle.fill : PaintingStyle.stroke;

      if (p.isFilled) {
        var rect = Rect.fromCenter(
          center: pos,
          width: p.size,
          height: p.size,
        );

        canvas.drawRect(rect, paint);
      } else {
        canvas.drawCircle(pos, p.size / 1.2, paint);
      }
    });
  }

  @override
  bool shouldRepaint(_) => false;
}
