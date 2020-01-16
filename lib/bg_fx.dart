import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'clock_fx.dart';
import 'particle.dart';
import 'utils/rnd.dart';

final easingDelayDuration = Duration(seconds: 15);

class BgFx extends ClockFx {
  BgFx({@required Size size, @required DateTime time})
      : super(
          size: size,
          time: time,
          numParticles: 120,
        );

  @override
  void tick(Duration duration) {
    var secFrac = 1 - (DateTime.now().millisecond / 1000);

    var vecSpeed = duration.compareTo(easingDelayDuration) > 0
        ? max(.2, Curves.easeInOutSine.transform(secFrac))
        : 1;

    particles.forEach((p) {
      p.y -= p.vy * vecSpeed;

      if (p.y > height || p.y < 0 || p.life == 0) {
        _activateParticle(p);
      }
    });

    super.tick(duration);
  }

  void _activateParticle(Particle p) {
    var xRnd = Rnd.getDouble(0, width / 5);
    p.x = Rnd.getBool() ? width - xRnd : 0 + xRnd;
    p.y = Rnd.getDouble(0, height);
    p.a = Rnd.ratio > .95 ? Rnd.getDouble(.6, .8) : Rnd.getDouble(.08, .4);
    p.isFilled = Rnd.getBool();
    p.size = Rnd.getDouble(height / 20, height / 5);

    p.life = 1;

    p.vx = 0;
    p.vy = Rnd.getDouble(-3, 3);

    double v = Rnd.getDouble(.1, .5);

    p.vx = 0;
    p.vy *= v;
  }
}
