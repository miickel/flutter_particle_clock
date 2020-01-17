import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'clock_fx.dart';
import 'particle.dart';
import 'utils/rnd.dart';

final easingDelayDuration = Duration(seconds: 10);

/// Probabilities of Hour, Minute, Noise.
final particleDistributions = [2, 4, 100];

/// Number of "arms" to emit noise particles from center.
final int noiseAngles = 2000;

/// Threshold for particles to go rouge. Lower = more particles.
final rougeDistributionLmt = 85;

/// Threshold for particles to go jelly. Lower = more particles.
final jellyDistributionLmt = 97;

class ParticleClockFx extends ClockFx {
  ParticleClockFx({@required Size size, @required DateTime time})
      : super(
          size: size,
          time: time,
        );

  @override
  void tick(Duration duration) {
    var secFrac = DateTime.now().millisecond / 1000;

    var vecSpeed = duration.compareTo(easingDelayDuration) > 0
        ? max(.2, Curves.easeInOutSine.transform(1 - secFrac))
        : 1;

    var vecSpeedInv = Curves.easeInSine.transform(secFrac);

    // Used to avoid emitting all particles at once.
    var maxSpawnPerTick = 10;

    particles.asMap().forEach((i, p) {
      // Movement
      p.x -= p.vx * vecSpeed;
      p.y -= p.vy * vecSpeed;

      p.dist = _getDistanceFromCenter(p);
      p.distFrac = p.dist / (sizeMin / 2);

      p.lifeLeft = p.life - p.distFrac;

      // Gradually reduce the speed of Noise particles.
      if (p.type == ParticleType.noise) {
        p.vx -= p.lifeLeft * p.vx * .001;
        p.vy -= p.lifeLeft * p.vy * .001;
      }

      // Gradually reduce the size of all particles.
      if (p.lifeLeft < .3) {
        p.size -= p.size * .0015;
      }

      // Make some of the particles go rouge.
      if (p.distribution > rougeDistributionLmt &&
          p.distribution < jellyDistributionLmt) {
        var r = Rnd.getDouble(.2, 2.5) * vecSpeedInv * p.distFrac;
        p.x -= p.vx * r + (p.distFrac * Rnd.getDouble(-.4, .4));
        p.y -= p.vy * r + (p.distFrac * Rnd.getDouble(-.4, .4));
      }

      // Make some of the particles ease back, for a jelly effect.
      if (p.distribution >= jellyDistributionLmt) {
        var r = Rnd.getDouble(.1, .9) * vecSpeedInv * (1 - p.lifeLeft);
        p.x += p.vx * r;
        p.y += p.vy * r;
      }

      // Reset particles once they are invisible or at the edge.
      if (p.lifeLeft <= 0 || p.size <= .5) {
        resetParticle(i);
        if (maxSpawnPerTick > 0) {
          _activateParticle(p);
          maxSpawnPerTick--;
        }
      }
    });

    super.tick(duration);
  }

  void _activateParticle(Particle p) {
    p.x = Rnd.getDouble(spawnArea.left, spawnArea.right);
    p.y = Rnd.getDouble(spawnArea.top, spawnArea.bottom);
    p.isFilled = Rnd.getBool();
    p.size = Rnd.getDouble(3, 8);
    p.isFlowing = false;
    p.distFrac = 0;

    p.distribution = Rnd.getInt(1, particleDistributions[2]);

    if (p.distribution < particleDistributions[0]) {
      p.type = ParticleType.hour;
    } else if (p.distribution < particleDistributions[1]) {
      p.type = ParticleType.minute;
    } else {
      p.type = ParticleType.noise;
    }

    double angle;

    switch (p.type) {
      case ParticleType.hour:
        angle = _getHourRadians();
        p.life = Rnd.getDouble(.5, .55);
        p.size = sizeMin * .010;
        p.isFlowing = Rnd.ratio > .85;
        p.color = palette.components[palette.components.length - 1];
        break;

      case ParticleType.minute:
        angle = _getMinuteRadians();
        p.life = Rnd.getDouble(.68, .73);
        p.size = sizeMin * .008;
        p.isFlowing = Rnd.ratio > .6;
        p.color = palette.components[palette.components.length - 1];
        break;

      case ParticleType.noise:
        // Find a random angle while avoiding clutter at the hour & minute hands.
        var am = _getMinuteRadians();
        var ah = _getHourRadians() % (pi * 2);
        var d = pi / 18;

        // Probably not the most efficient solution right here.
        do {
          angle = Rnd.ratio * pi * 2;
        } while (_isBetween(angle, am - d, am + d) ||
            _isBetween(angle, ah - d, ah + d));

        p.life = Rnd.getDouble(0.75, .8);
        p.size = sizeMin *
            (Rnd.ratio > .8
                ? Rnd.getDouble(.0015, .003)
                : Rnd.getDouble(.002, .006));
        break;
    }

    // Particle movement vector.
    p.vx = sin(-angle);
    p.vy = cos(-angle);

    // Particle movement angle.
    p.a = atan2(p.vy, p.vx) + pi;

    // Add some speed randomeness.
    double v = p.type == ParticleType.noise
        ? Rnd.getDouble(.5, 1)
        : Rnd.getDouble(.3, .4);

    p.vx *= v;
    p.vy *= v;
  }

  /// Gets the radians of the hour hand.
  double _getHourRadians() =>
      (time.hour * pi / 6) +
      (time.minute * pi / (6 * 60)) +
      (time.second * pi / (360 * 60));

  /// Gets the radians of the minute hand.
  double _getMinuteRadians() =>
      (time.minute * (2 * pi) / 60) + (time.second * pi / (30 * 60));

  /// Checks if a value is between two other values.
  bool _isBetween(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// Calculates the distance from center using pythagoras rate.
  double _getDistanceFromCenter(Particle p) {
    var a = pow(center.dx - p.x, 2);
    var b = pow(center.dy - p.y, 2);
    return sqrt(a + b);
  }
}
