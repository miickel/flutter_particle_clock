import 'dart:ui';

class Palette {
  List<Color> components;

  Palette({this.components});

  factory Palette.fromJson(List<dynamic> json) {
    var components = json.map((c) => Color(int.tryParse(c))).toList();
    return Palette(components: components);
  }
}
