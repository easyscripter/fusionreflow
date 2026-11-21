import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/reader/reader_page_metrics.dart';

/// Chapter, page in the chapter and percent under the page text.
class ReaderFooter extends StatelessWidget {
  const new({
    required this.chapter,
    required this.page,
    required this.percent,
    required this.color,
    super.key,
  });

  /// "Chapter 3 of 27"; null hides it (a chapter without a title).
  final String? chapter;
  final String page;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: readerFooterHeight,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: readerChromeMargin),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 12, color: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(chapter ?? ''), Text(page), Text(percent)],
        ),
      ),
    ),
  );
}
