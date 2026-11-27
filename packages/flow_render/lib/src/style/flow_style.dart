import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Look of a page: fonts, sizes and colors.
@immutable
class FlowStyle {
  const new({
    required this.fontFamily,
    required this.codeFontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.padding,
    required this.justify,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final String fontFamily;
  final String codeFontFamily;
  final double fontSize;

  /// Line height as a multiple of [fontSize].
  final double lineHeight;

  /// Text margins inside the page.
  final EdgeInsets padding;
  final bool justify;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  /// Height of one body line.
  double get line => fontSize * lineHeight;

  @override
  bool operator ==(Object other) =>
      other is FlowStyle &&
      fontFamily == other.fontFamily &&
      codeFontFamily == other.codeFontFamily &&
      fontSize == other.fontSize &&
      lineHeight == other.lineHeight &&
      padding == other.padding &&
      justify == other.justify &&
      textColor == other.textColor &&
      mutedColor == other.mutedColor &&
      accentColor == other.accentColor;

  @override
  int get hashCode => Object.hash(
    fontFamily,
    codeFontFamily,
    fontSize,
    lineHeight,
    padding,
    justify,
    textColor,
    mutedColor,
    accentColor,
  );
}
