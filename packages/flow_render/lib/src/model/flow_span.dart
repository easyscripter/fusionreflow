import 'package:flutter/foundation.dart';

/// Vertical shift of a text span.
enum FlowScript { normal, sup, sub }

/// A run of inline content. [length] counts UTF-16 units of the chapter text.
@immutable
sealed class FlowSpan {
  const new();

  /// Units this span takes in the chapter offsets.
  int get length;
}

/// Styled text. A soft hyphen (U+00AD) counts like any other unit.
@immutable
class FlowTextSpan extends FlowSpan {
  const new(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.link = false,
    this.script = FlowScript.normal,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool code;
  final bool link;
  final FlowScript script;

  @override
  int get length => text.length;

  @override
  bool operator ==(Object other) =>
      other is FlowTextSpan &&
      text == other.text &&
      bold == other.bold &&
      italic == other.italic &&
      code == other.code &&
      link == other.link &&
      script == other.script;

  @override
  int get hashCode => Object.hash(text, bold, italic, code, link, script);
}

/// An image inside a line, [heightEm] tall. Takes one unit.
@immutable
class FlowImageSpan extends FlowSpan {
  const new(this.bytes, this.heightEm);

  final Uint8List bytes;
  final double heightEm;

  @override
  int get length => 1;

  @override
  bool operator ==(Object other) =>
      other is FlowImageSpan &&
      heightEm == other.heightEm &&
      listEquals(bytes, other.bytes);

  @override
  int get hashCode => Object.hash(heightEm, Object.hashAll(bytes));
}

/// Total length of [spans].
int spansLength(List<FlowSpan> spans) =>
    spans.fold(0, (sum, span) => sum + span.length);
