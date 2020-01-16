import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'clock_fx.dart';
import 'particle.dart';

// Where handles should start, denoted in percentage of full radius.
const double handlesStart = .1;

// Where noise should start, denoted in percentage of full radius.
const double noiseStart = .15;

class ClockFxPainter extends CustomPainter {
  ClockFx fx;

  // ChangeNotifier used as repaint notifier.
  ClockFxPainter({@required this.fx}) : super(repaint: fx);

  @override
  void paint(Canvas canvas, Size size) {
    fx.particles.forEach((p) {
      var alpha = (p.type == ParticleType.noise
              ? (p.distFrac <= noiseStart) ? 0 : min(160, p.lifeLeft * 3 * 255)
              : (p.distFrac <= handlesStart)
                  ? 255 * Curves.easeIn.transform(p.distFrac / handlesStart)
                  : min(255, p.lifeLeft * 10 * 255))
          .floor();

      var circlePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.size / 4
        ..color = p.color.withAlpha(alpha);

      var particlePosition = Offset(p.x, p.y);

      // Fill some particles.
      if (p.isFilled) {
        circlePaint.style = PaintingStyle.fill;

        // Draw gradient arc stroke on some filled particles.
        if (p.isFlowing && p.distFrac > (p.distribution < 2 ? .16 : .51)) {
          var shader = SweepGradient(
            colors: [
              p.color.withAlpha(0),
              p.color.withAlpha(min(110, alpha)),
            ],
            startAngle: pi,
            endAngle: 2 * pi,
            transform: GradientRotation(p.a),
            stops: [.6, 1],
          ).createShader(Rect.fromCircle(
            center: fx.center,
            radius: p.dist,
          ));

          var gradientPaint = Paint()
            ..strokeWidth = p.size / 2
            ..shader = shader
            ..style = PaintingStyle.stroke;

          canvas.drawCircle(fx.center, p.dist, gradientPaint);
        }
      }

      canvas.drawCircle(particlePosition, p.size, circlePaint);
    });
  }

  @override
  bool shouldRepaint(_) => true;
}
