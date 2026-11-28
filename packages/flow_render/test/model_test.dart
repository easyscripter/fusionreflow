import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('lengths_count_utf16_and_soft_hyphens', () {
    expect(const FlowTextSpan('по­ка').length, 5);
    expect(FlowImage(Uint8List(0)).length, 1);
    expect(FlowImageSpan(Uint8List(0), 1).length, 1);
    const rule = FlowRule();
    expect(rule.length, 1);
    const cell = [FlowTextSpan('аб')];
    const table = FlowTable([
      [cell, cell],
      [cell, cell],
    ]);
    expect(table.length, 12);
    expect(table.rowLength(0), 6);
    const text = FlowText([FlowTextSpan('аб'), FlowTextSpan('в')]);
    expect(text.length, 3);
    expect(const FlowSection([text, table, rule]).length, 3 + 12 + 1);
  });

  test('style value equality', () {
    FlowStyle copy(double fontSize) => FlowStyle(
      fontFamily: testStyle.fontFamily,
      codeFontFamily: testStyle.codeFontFamily,
      fontSize: fontSize,
      lineHeight: testStyle.lineHeight,
      padding: testStyle.padding,
      justify: testStyle.justify,
      textColor: testStyle.textColor,
      mutedColor: testStyle.mutedColor,
      accentColor: testStyle.accentColor,
    );
    expect(testStyle, copy(18));
    expect(testStyle.hashCode, copy(18).hashCode);
    expect(testStyle == copy(20), isFalse);
    expect(testStyle.line, 27);
  });

  test('value equality', () {
    expect(
      const FlowTextSpan('a') == const FlowTextSpan('a', link: true),
      isFalse,
    );
    expect(const FlowTextSpan('a').hashCode, const FlowTextSpan('a').hashCode);
    expect(
      FlowImageSpan(Uint8List(1), 1) == FlowImageSpan(Uint8List(1), 2),
      isFalse,
    );
    expect(
      FlowImageSpan(Uint8List(1), 1).hashCode,
      FlowImageSpan(Uint8List(1), 1).hashCode,
    );
    expect(FlowImage(Uint8List(1)).hashCode, FlowImage(Uint8List(1)).hashCode);
    expect(const FlowRule().hashCode, const FlowRule().hashCode);
    expect(const FlowText([]).hashCode, const FlowText([]).hashCode);
    expect(const FlowSection([]) == const FlowSection([], title: 'x'), isFalse);
    const a = FlowText([FlowTextSpan('x', bold: true)], marker: '•');
    const b = FlowText([FlowTextSpan('x', bold: true)], marker: '•');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == const FlowText([FlowTextSpan('x')]), isFalse);
    expect(
      FlowImage(Uint8List.fromList([1])),
      FlowImage(Uint8List.fromList([1])),
    );
    expect(const FlowRule(), const FlowRule());
    expect(
      FlowImageSpan(Uint8List.fromList([1]), 1),
      FlowImageSpan(Uint8List.fromList([1]), 1),
    );
    const cell = [FlowTextSpan('a')];
    expect(
      const FlowTable([
        [cell],
      ]),
      const FlowTable([
        [cell],
      ]),
    );
    expect(
      const FlowTable([
        [cell],
      ]).hashCode,
      const FlowTable([
        [cell],
      ]).hashCode,
    );
    const section = FlowSection([a], title: 't');
    expect(section, const FlowSection([b], title: 't'));
    expect(section.hashCode, const FlowSection([b], title: 't').hashCode);
    expect(const FlowBook('B', [section]), const FlowBook('B', [section]));
    expect(
      const FlowBook('B', [section]).hashCode,
      const FlowBook('B', [section]).hashCode,
    );
    expect(
      const FlowBook('B', [section]) == const FlowBook('C', [section]),
      isFalse,
    );
  });
}
