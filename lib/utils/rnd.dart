import 'dart:math';

import 'package:flutter/painting.dart';

import '../palette.dart';

class Rnd {
  static int _seed = DateTime.now().millisecondsSinceEpoch;
  static Random random = Random(_seed);

  static set seed(int val) => random = Random(_seed = val);
  static int get seed => _seed;

  /// Gets the next double.
  static get ratio => random.nextDouble();

  /// Gets a random int between [min] and [max].
  static int getInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  /// Gets a random double between [min] and [max].
  static double getDouble(double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  /// Gets a random boolean with chance [chance].
  static bool getBool([double chance = 0.5]) {
    return random.nextDouble() < chance;
  }

  /// Randomize the positions of items in a list.
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

  /// Randomly selects an item from a list.
  static dynamic getItem(List list) {
    return list[random.nextInt(list.length)];
  }

  /// Gets a random palette from a list of palettes and sorts its' colors by luminance.
  ///
  /// Given if [dark] or not, this method makes sure the luminance of the background color is valid.
  static Palette getPalette(List<Palette>? palettes, bool dark) {
    Palette? result;

    while (result == null) {
      Palette palette = Rnd.getItem(palettes!);
      List<Color> colors = Rnd.shuffle(palette.components!) as List<Color>;

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
            lumDiff.map((d) => colors[d[0] + 1 as int]).toList();

        result = Palette(
          components: [colors[0]] + sortedColors,
        );
      }
    }
    return result;
  }
}
