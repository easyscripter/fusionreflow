import 'package:flow_render/src/model/flow_span.dart';
import 'package:flutter/foundation.dart';

/// A block of a chapter. [length] is its size in chapter offsets.
@immutable
sealed class FlowBlock {
  const new();

  int get length;
}

/// What a [FlowText] is; decides its font and spacing.
enum FlowTextRole { body, heading, code, footnote, caption }

/// Paragraph, heading, list item, code line, footnote or caption.
@immutable
class FlowText extends FlowBlock {
  const new(
    this.spans, {
    this.role = FlowTextRole.body,
    this.headingLevel = 1,
    this.indent = 0,
    this.marker,
  });

  final FlowTextRole role;

  /// 1..6, used by [FlowTextRole.heading].
  final int headingLevel;

  /// Nesting level (list depth, quote depth).
  final int indent;

  /// List marker (`•`, `3.`), drawn in the hanging indent.
  final String? marker;
  final List<FlowSpan> spans;

  @override
  int get length => spansLength(spans);

  @override
  bool operator ==(Object other) =>
      other is FlowText &&
      role == other.role &&
      headingLevel == other.headingLevel &&
      indent == other.indent &&
      marker == other.marker &&
      listEquals(spans, other.spans);

  @override
  int get hashCode =>
      Object.hash(role, headingLevel, indent, marker, Object.hashAll(spans));
}

/// A picture on its own. Empty or broken [bytes] draw a frame.
@immutable
class FlowImage extends FlowBlock {
  const new(this.bytes);

  final Uint8List bytes;

  @override
  int get length => 1;

  @override
  bool operator ==(Object other) =>
      other is FlowImage && listEquals(bytes, other.bytes);

  @override
  int get hashCode => Object.hashAll(bytes);
}

/// A grid of cells; every cell is a list of spans.
@immutable
class FlowTable extends FlowBlock {
  const new(this.rows);

  final List<List<List<FlowSpan>>> rows;

  /// Length of row [row]: its cells plus one unit per cell.
  int rowLength(int row) =>
      rows[row].fold(0, (sum, cell) => sum + spansLength(cell) + 1);

  @override
  int get length =>
      List.generate(rows.length, rowLength).fold(0, (a, b) => a + b);

  @override
  bool operator ==(Object other) =>
      other is FlowTable &&
      rows.length == other.rows.length &&
      Iterable<int>.generate(rows.length).every(
        (r) =>
            rows[r].length == other.rows[r].length &&
            Iterable<int>.generate(rows[r].length)
                .every((c) => listEquals(rows[r][c], other.rows[r][c])),
      );

  @override
  int get hashCode => Object.hashAll([
    for (final row in rows)
      for (final cell in row) Object.hashAll(cell),
  ]);
}

/// A horizontal divider.
@immutable
class FlowRule extends FlowBlock {
  const new();

  @override
  int get length => 1;

  @override
  bool operator ==(Object other) => other is FlowRule;

  @override
  int get hashCode => 0;
}
