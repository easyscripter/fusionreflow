import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/reader/reader_page_metrics.dart';

/// Chapter title above the page text.
class ReaderHeader extends StatelessWidget {
  const new({
    required this.title,
    required this.color,
    this.topInset = 0,
    super.key,
  });

  /// Null: the chapter has no title, the header stays empty.
  final String? title;
  final Color color;

  /// Top area covered by a cutout or a system bar.
  final double topInset;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: readerHeaderHeightFor(topInset),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        readerChromeMargin,
        readerHeaderTopFor(topInset),
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
