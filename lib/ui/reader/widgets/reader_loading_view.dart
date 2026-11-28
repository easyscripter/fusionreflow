import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';

/// A spinner on the page background while the book opens.
class ReaderLoadingView extends StatelessWidget {
  const new({required this.palette, super.key});

  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: 40,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        color: palette.accent,
        backgroundColor: palette.surfaceVariant,
      ),
    ),
  );
}
