import 'dart:async';
import 'dart:convert';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';

import 'palette.dart';
import 'scene.dart';

class ParticleClock extends StatefulWidget {
  const ParticleClock(this.model);
  final ClockModel model;

  @override
  _ParticleClockState createState() => _ParticleClockState();
}

class _ParticleClockState extends State<ParticleClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  double seek = 0.0;
  double seekIncrement = 1 / 3600;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(ParticleClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  Future<List<Palette>> _loadPalettes() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/palettes.json");
    var palettes = json.decode(data) as List;
    return palettes.map((p) => Palette.fromJson(p)).toList();
  }

  void _updateModel() {
    // Cause the clock to rebuild when the model changes.
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPalettes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Center(
              child: Text("Could not load palettes."),
            ),
          );
        }

        List<Palette> palettes = snapshot.data;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Scene(
              size: constraints.biggest,
              palettes: palettes,
              time: _dateTime,
              brightness: Theme.of(context).brightness,
            );
          },
        );
      },
    );
  }
}
