import 'dart:math';

import 'package:flutter/painting.dart';

import '../palette.dart';

class Rnd {
  static int _seed = DateTime.now().millisecondsSinceEpoch;
  static Random random = Random(_seed);

  static set seed(int val) => random = Random(_seed = val);
  static int get seed => _seed;

  static get ratio => random.nextDouble();

  static int getInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  static double getDouble(double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  static bool getBool([double chance = 0.5]) {
    return random.nextDouble() < chance;
  }

  static List shuffle(List list) {
    for (int i = 0, l = list.length; i < l; i++) {
      int j = random.nextInt(l);
      if (j == i) {
        continue;
      }
      dynamic item = list[j];
      list[j] = list[i];
      list[i] = item;
    }
    return list;
  }

  static dynamic getItem(List list) {
    return list[random.nextInt(list.length)];
  }

  static Palette getPalette(List<Palette> palettes, bool dark) {
    Palette result;
    while (result == null) {
      Palette palette = Rnd.getItem(palettes);
      List<Color> colors = Rnd.shuffle(palette.components);
      var luminance = colors[0].computeLuminance();
      if (dark ? luminance <= .1 : luminance >= .1) {
        var lumDiff = colors
            .sublist(1)
            .asMap()
            .map(
              (i, color) => MapEntry(
                i,
                [i, (luminance - color.computeLuminance()).abs()],
              ),
            )
            .values
            .toList();

        lumDiff.sort((List<num> a, List<num> b) {
          return a[1].compareTo(b[1]);
        });

        List<Color> sortedColors =
            lumDiff.map((d) => colors[d[0] + 1]).toList();

        result = Palette(
          components: [colors[0]] + sortedColors,
        );
      }
    }
    return result;
  }
}
