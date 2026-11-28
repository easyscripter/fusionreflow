import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/flow_render.dart';
import 'package:flutter/painting.dart';

/// Test style: Ahem is the default test font, one glyph = one em square.
const testStyle = FlowStyle(
  fontFamily: 'Literata',
  codeFontFamily: 'JetBrainsMono',
  fontSize: 18,
  lineHeight: 1.5,
  padding: EdgeInsets.symmetric(horizontal: 20),
  justify: true,
  textColor: Color(0xFF111111),
  mutedColor: Color(0xFF777777),
  accentColor: Color(0xFF4A3FD0),
);

/// A paragraph of [n] identical words.
FlowText para(int n, {FlowTextRole role = FlowTextRole.body}) =>
    FlowText([FlowTextSpan(List.filled(n, 'слово').join(' '))], role: role);

/// 300 letters without a space.
final String longWord = 'а' * 300;

FlowSection section(List<FlowBlock> blocks, {String? title}) =>
    FlowSection(blocks, title: title);

/// A valid PNG of [width] x [height] made with the engine.
Future<Uint8List> makePng(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const Color(0xFF336699),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// Sum of the page lengths of [pages].
int coveredLength(List<FlowPage> pages) =>
    pages.fold(0, (sum, p) => sum + p.end - p.start);
