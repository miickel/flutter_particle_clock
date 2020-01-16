import 'dart:math';

import 'package:flutter/material.dart';

class ClockSecondsPainter extends CustomPainter {
  final Color accentColor;

  ClockSecondsPainter({@required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset(size.width / 2, size.height / 2);

    var now = DateTime.now();
    var secSize = pi / 50;

    // Animate smoothly with easing.
    var msecs = Curves.easeOutCirc.transform(now.millisecond / 1000);
    msecs = msecs * 2 * pi / 60;

    var timeAngle = (now.second - 1) * (2 * pi / 60) + msecs - secSize / 2;
    timeAngle = timeAngle - pi / 2;

    var radiusInner = size.height * .13;
    var radiusOuter = size.height * .9;

    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = center.dy * .003
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withAlpha(40);

    var outerRect = Rect.fromCenter(
      center: center,
      width: radiusOuter,
      height: radiusOuter,
    );

    var innerRect = Rect.fromCenter(
      center: center,
      width: radiusInner,
      height: radiusInner,
    );

    // Outer track.
    canvas.drawArc(outerRect, 0, pi * 2, false, paint);

    // Inner track.
    canvas.drawArc(innerRect, 0, pi * 2, false, paint);

    paint
      ..strokeWidth = center.dy * .015
      ..color = accentColor;

    // Outer indicator.
    canvas.drawArc(outerRect, timeAngle, secSize, false, paint);

    // Inner indicator.
    canvas.drawArc(
        innerRect, timeAngle - (secSize * 6), secSize * 12, false, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
