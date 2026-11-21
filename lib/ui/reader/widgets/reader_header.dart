import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/reader/reader_page_metrics.dart';

/// Chapter title above the page text.
class ReaderHeader extends StatelessWidget {
  const new({required this.title, required this.color, super.key});

  /// Null: the chapter has no title, the header stays empty.
  final String? title;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: readerHeaderHeight,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        readerChromeMargin,
        readerHeaderTop,
        readerChromeMargin,
        0,
      ),
      child: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: color),
      ),
    ),
  );
}
