import 'dart:math';
import 'package:flutter/material.dart';

/// The number of sections to divide the clock face.
final int arms = 60;

/// Which parts of the sections to indicate quarters.
final int quarters = (arms / 12).floor();

class ClockFacePainter extends CustomPainter {
  final Color accentColor;

  ClockFacePainter({@required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    var cx = size.width / 2;
    var cy = size.height / 2;
    var radius = min(size.width / 2, size.height / 2);
    var circleRaidus = radius * .012;

    var paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = circleRaidus * .5
      ..color = accentColor;

    for (var i = 1; i <= arms; i++) {
      var angle = i * 360 / arms;
      var a = -angle * pi / 180;
      var point = Offset(cx + radius * cos(a), cy + radius * sin(a));

      if (i % quarters == 0) {
        canvas.drawCircle(
          point,
          circleRaidus * 2,
          paint
            ..color = accentColor
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawCircle(
          point,
          circleRaidus,
          paint
            ..color = accentColor.withAlpha(100)
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
