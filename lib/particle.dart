import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Particle {
  double x;
  double y;
  double a;
  double vx;
  double vy;
  double dist;
  double distFrac;
  double size;
  double life;
  double lifeLeft;
  bool isFilled;
  bool isFlowing;
  Color color;
  int distribution;
  ParticleType type;

  Particle({
    this.x = 0,
    this.y = 0,
    this.a = 0,
    this.vx = 0,
    this.vy = 0,
    this.dist = 0,
    this.distFrac = 0,
    this.size = 0,
    this.life = 0,
    this.lifeLeft = 0,
    this.isFilled = false,
    this.isFlowing = false,
    this.color = Colors.black,
    this.distribution = 0,
    this.type = ParticleType.noise,
  });
}

enum ParticleType {
  hour,
  minute,
  noise,
}
