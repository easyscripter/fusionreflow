import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flow_render/src/model/flow_block.dart';
import 'package:flow_render/src/model/flow_span.dart';
import 'package:flow_render/src/style/flow_style.dart';
import 'package:flutter/widgets.dart';

const _softHyphen = '­';
// Zero-width, never breaks, takes no space: same length as the soft hyphen,
// so offsets stay 1:1 (hyphenation is drawn by 5.B).
const _wordJoiner = '⁠';

/// First-line indent of a body paragraph, in em.
const double firstLineIndentEm = 1.3;

/// Font size of [block] in pixels.
double roleFontSize(FlowText block, FlowStyle style) => switch (block.role) {
  FlowTextRole.body => style.fontSize,
  FlowTextRole.heading =>
    style.fontSize *
        switch (block.headingLevel) {
          1 => 1.25,
          2 => 1.15,
          _ => 1.05,
        },
  FlowTextRole.code ||
  FlowTextRole.footnote ||
  FlowTextRole.caption => style.fontSize * 0.85,
};

/// Alignment of the lines of [block].
TextAlign roleAlign(FlowText block, FlowStyle style) => switch (block.role) {
  FlowTextRole.heading || FlowTextRole.caption => TextAlign.center,
  FlowTextRole.code => TextAlign.left,
  FlowTextRole.body ||
  FlowTextRole.footnote => style.justify ? TextAlign.justify : TextAlign.left,
};

/// Whether the first line of [block] starts with an indent.
bool hasFirstLineIndent(FlowText block) =>
    block.role == FlowTextRole.body &&
    block.marker == null &&
    block.indent == 0;

/// Text of a paragraph ready for a `TextPainter`.
class BuiltText {
  const new(this.span, this.placeholders, this.images, this.prefix);

  final TextSpan span;

  /// Placeholder sizes in the order of the placeholders in [span].
  final List<PlaceholderDimensions> placeholders;

  /// Bytes of every placeholder; null for the indent one.
  final List<Uint8List?> images;

  /// Painter units before the first unit of the block text (the indent
  /// placeholder).
  final int prefix;
}

FontWeight? _weight(FlowTextSpan span, FlowText block) {
  if (span.bold) return FontWeight.w700;
  if (block.role == FlowTextRole.heading) return FontWeight.w600;
  return null;
}

TextStyle _spanStyle(
  FlowTextSpan span,
  FlowText block,
  FlowStyle style,
  double size,
) {
  final weight = _weight(span, block);
  final script = span.script;
  return TextStyle(
    fontFamily: span.code || block.role == FlowTextRole.code
        ? style.codeFontFamily
        : style.fontFamily,
    fontSize: script == FlowScript.normal ? null : size * 0.75,
    fontWeight: weight,
    // Literata is a variable font: the axis has to be set too.
    fontVariations: weight == null
        ? null
        : [ui.FontVariation('wght', weight.value.toDouble())],
    fontStyle: span.italic ? FontStyle.italic : null,
    color: span.link ? style.accentColor : null,
    fontFeatures: switch (script) {
      FlowScript.normal => null,
      FlowScript.sup => const [ui.FontFeature.superscripts()],
      FlowScript.sub => const [ui.FontFeature.subscripts()],
    },
  );
}

/// Builds the inline tree of [block] (the indent placeholder first, if any).
BuiltText buildText(FlowText block, FlowStyle style) {
  final size = roleFontSize(block, style);
  final placeholders = <PlaceholderDimensions>[];
  final images = <Uint8List?>[];
  final children = <InlineSpan>[];
  var prefix = 0;
  if (hasFirstLineIndent(block)) {
    prefix = 1;
    children.add(const WidgetSpan(child: SizedBox.shrink()));
    placeholders.add(
      PlaceholderDimensions(
        size: Size(size * firstLineIndentEm, 0),
        alignment: ui.PlaceholderAlignment.bottom,
      ),
    );
    images.add(null);
  }
  for (final span in block.spans) {
    switch (span) {
      case FlowTextSpan():
        children.add(
          TextSpan(
            text: span.text.replaceAll(_softHyphen, _wordJoiner),
            style: _spanStyle(span, block, style, size),
          ),
        );
      case FlowImageSpan():
        children.add(
          const WidgetSpan(
            child: SizedBox.shrink(),
            alignment: ui.PlaceholderAlignment.middle,
          ),
        );
        final side = span.heightEm * size;
        placeholders.add(
          PlaceholderDimensions(
            size: Size(side, side),
            alignment: ui.PlaceholderAlignment.middle,
          ),
        );
        images.add(span.bytes);
    }
  }
  return BuiltText(
    TextSpan(
      style: TextStyle(
        fontFamily: block.role == FlowTextRole.code
            ? style.codeFontFamily
            : style.fontFamily,
        fontSize: size,
        height: style.lineHeight,
        color: block.role == FlowTextRole.footnote
            ? style.mutedColor
            : style.textColor,
        fontWeight: block.role == FlowTextRole.heading
            ? FontWeight.w600
            : FontWeight.w400,
        fontVariations: [
          ui.FontVariation(
            'wght',
            block.role == FlowTextRole.heading ? 600 : 400,
          ),
        ],
      ),
      children: children,
    ),
    placeholders,
    images,
    prefix,
  );
}

/// Lays out [built] in [width] pixels.
TextPainter layoutPainter(BuiltText built, TextAlign align, double width) {
  final painter =
      TextPainter(
          text: built.span,
          textAlign: align,
          textDirection: TextDirection.ltr,
        )
        ..setPlaceholderDimensions(built.placeholders)
        ..layout(minWidth: width, maxWidth: width);
  return painter;
}

/// A single-line label (marker, cell): sized to its text, no wrapping.
TextPainter layoutLabel(String text, TextStyle style) => TextPainter(
  text: TextSpan(text: text, style: style),
  textDirection: TextDirection.ltr,
)..layout();
