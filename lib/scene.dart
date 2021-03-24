import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'bg_fx.dart';
import 'clock_bg_particle_painter.dart';
import 'clock_face_painter.dart';
import 'clock_fx.dart';
import 'clock_fx_painter.dart';
import 'clock_seconds_painter.dart';
import 'palette.dart';
import 'particle_clock_fx.dart';
import 'utils/rnd.dart';

class Scene extends StatefulWidget {
  final Size? size;
  final List<Palette>? palettes;
  final DateTime? time;
  final Brightness? brightness;

  const Scene({
    Key? key,
    this.size,
    this.palettes,
    this.time,
    this.brightness,
  }) : super(key: key);

  @override
  SceneState createState() => SceneState();
}

class SceneState extends State<Scene> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  ClockFx? _fx;
  BgFx? _bgFx;
  late Palette _palette;
  Color? _bgColor;
  Color? _accentColor;

  @override
  void initState() {
    _ticker = createTicker(_tick)..start();
    _fx = ParticleClockFx(
      size: widget.size!,
      time: widget.time,
    );
    _bgFx = BgFx(
      size: widget.size!,
      time: widget.time,
    );
    _updatePalette();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Scene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time ||
        oldWidget.brightness != widget.brightness) {
      _fx!.setTime(widget.time);
      _bgFx!.setTime(widget.time);

      // Change palette every 15th second to keep things interesting.
      if (widget.time!.second % 15 == 0 ||
          oldWidget.brightness != widget.brightness) {
        _updatePalette();
      }
    }

    if (oldWidget.size != widget.size) {
      _fx!.setSize(widget.size!);
      _bgFx!.setSize(widget.size!);
      _bgFx!.tick(Duration(days: 0)); // Trigger repaint.
    }
  }

  /// Randomly selects a new palette that conforms to the clock's brightness setting.
  /// The background color is set to the first component of the palette, and the accent
  /// color is set to the color of the palette that is furthest from the background color
  /// in terms of luminosity.
  void _updatePalette() {
    var isDarkMode = widget.brightness == Brightness.dark;
    _palette = Rnd.getPalette(widget.palettes, isDarkMode);
    _bgColor = _palette.components![0];
    _accentColor = _palette.components![_palette.components!.length - 1];
    _fx!.setPalette(_palette);
    _bgFx!.setPalette(_palette);
  }

  void _tick(Duration duration) {
    _fx!.tick(duration);
    if (widget.time!.second % 5 == 0) _bgFx!.tick(duration);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeOut,
      color: _bgColor,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            _buildBgBlurFx(),
            _buildClockFace(),
            CustomPaint(
              painter: ClockFxPainter(fx: _fx),
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgBlurFx() {
    return RepaintBoundary(
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: ClockBgParticlePainter(
              fx: _bgFx,
            ),
            child: Container(),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.size!.width * .05,
              sigmaY: 0,
            ),
            // filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(child: Text(" ")),
          ),
        ],
      ),
    );
  }

  Widget _buildClockFace() {
    var faceSize = widget.size!.height * .85;
    return Center(
      child: Container(
        width: faceSize,
        height: faceSize,
        child: Stack(
          children: <Widget>[
            // Paint the second hand.
            CustomPaint(
              size: Size(faceSize, faceSize),
              painter: ClockSecondsPainter(
                accentColor: _accentColor,
              ),
            ),

            // Paint the clock face.
            RepaintBoundary(
              key: Key(_accentColor.toString()),
              child: CustomPaint(
                size: widget.size!,
                painter: ClockFacePainter(
                  accentColor: _accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
