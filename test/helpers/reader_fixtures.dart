import 'package:flow_render/flow_render.dart';
import 'package:flutter/painting.dart';

/// Page style for reader tests (the default test font is Ahem).
const FlowStyle testFlowStyle = FlowStyle(
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

/// A phone in portrait and the same phone turned.
const Size portrait = Size(360, 500);
const Size landscape = Size(500, 360);

/// A paragraph of [n] identical words.
FlowText para(int n) =>
    FlowText([FlowTextSpan(List.filled(n, 'слово').join(' '))]);

/// Three chapters: 12, 12 and 3 paragraphs of 40 words (several pages each).
FlowBook threeChapters() => FlowBook('Книга', [
  FlowSection([for (var i = 0; i < 12; i++) para(40)], title: 'Первая'),
  FlowSection([for (var i = 0; i < 12; i++) para(40)], title: 'Вторая'),
  FlowSection([for (var i = 0; i < 3; i++) para(40)]),
]);
