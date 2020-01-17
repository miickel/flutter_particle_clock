import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'clock_fx.dart';
import 'particle.dart';

/// Where handles should start, denoted in percentage of full radius.
const double handlesStart = .1;

/// Where noise should start, denoted in percentage of full radius.
const double noiseStart = .15;

/// Alpha value for noise particles.
const double noiseAlpha = 160;

class ClockFxPainter extends CustomPainter {
  ClockFx fx;

  // ChangeNotifier used as repaint notifier.
  ClockFxPainter({@required this.fx}) : super(repaint: fx);

  @override
  void paint(Canvas canvas, Size size) {
    fx.particles.forEach((p) {
      double a;

      // Fade in particles by calculating alpha based on distance.
      if (p.type == ParticleType.noise) {
        a = max(0.0, (p.distFrac - .13) / p.distFrac) * 255;
        a = min(a, min(noiseAlpha, p.lifeLeft * 3 * 255));
      } else {
        a = p.distFrac <= handlesStart
            ? 255 * Curves.easeIn.transform(p.distFrac / handlesStart)
            : min(255, p.lifeLeft * 10 * 255);
      }

      var alpha = a.floor();

      var circlePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.size / 4
        ..color = p.color.withAlpha(alpha);

      var particlePosition = Offset(p.x, p.y);

      // Fill some particles.
      if (p.isFilled) {
        circlePaint.style = PaintingStyle.fill;

        // Draw gradient arc stroke on some filled particles.
        if (p.isFlowing) {
          var threshold = p.distribution < 2 ? .2 : .4;
          var flowAlpha = max(0, (p.distFrac - threshold) / p.distFrac) * alpha;
          var shader = SweepGradient(
            colors: [
              p.color.withAlpha(0),
              p.color.withAlpha(flowAlpha.floor()),
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
