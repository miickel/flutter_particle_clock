import 'dart:math';

import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'particle.dart';
import 'utils/rnd.dart';

final Color transparent = Color.fromARGB(0, 0, 0, 0);

abstract class ClockFx with ChangeNotifier {
  double width;
  double height;
  double sizeMin;
  Offset center;
  Rect spawnArea;

  Palette palette;
  List<Particle> particles;
  int numParticles;
  DateTime time;

  ClockFx({
    @required Size size,
    @required DateTime time,
    this.numParticles = 5000,
  }) {
    this.time = time;

    particles = List<Particle>(numParticles);
    palette = Palette(components: [transparent, transparent]);
    setSize(size);
  }

  void init() {
    if (palette == null) return;
    for (int i = 0; i < numParticles; i++) {
      var color = Rnd.getItem(palette.components);
      particles[i] = Particle(color: color);
      resetParticle(i);
    }
  }

  void setPalette(Palette palette) {
    this.palette = palette;
    var colors = palette.components.sublist(1);
    var accentColor = colors[colors.length - 1];
    particles.where((p) => p != null).forEach((p) => p.color =
        p.type == ParticleType.noise ? Rnd.getItem(colors) : accentColor);
  }

  void setTime(DateTime time) {
    this.time = time;
  }

  void setSize(Size size) {
    width = size.width;
    height = size.height;
    sizeMin = min(width, height);
    center = Offset(width / 2, height / 2);
    spawnArea = Rect.fromLTRB(
      center.dx - sizeMin / 100,
      center.dy - sizeMin / 100,
      center.dx + sizeMin / 100,
      center.dy + sizeMin / 100,
    );
    init();
  }

  Particle resetParticle(int i) {
    Particle p = particles[i];
    p.size = p.a = p.vx = p.vy = p.life = p.lifeLeft = 0;
    p.x = center.dx;
    p.y = center.dy;
    return p;
  }

  void tick(Duration duration) {
    notifyListeners();
  }
}
