import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/library_harness.dart';

void main() {
  testWidgets('empty view follows the design', (tester) async {
    await pumpLibrary(tester);

    expect(
      tester.getSize(find.byKey(const Key('library_empty_art'))),
      const Size(140, 120),
    );
    expect(find.byType(SvgPicture), findsWidgets);
    expect(
      tester.widget<Text>(find.text('Здесь пока нет книг')).style?.fontSize,
      21,
    );
    expect(
      tester
          .widget<Text>(find.text('Нажмите «Добавить» внизу справа'))
          .style
          ?.fontSize,
      13,
    );
    expect(
      tester.widget<Text>(find.text('EPUB · FB2 · FB2.ZIP')).style?.fontSize,
      12.5,
    );
    final message = find.textContaining('Добавьте файл EPUB или FB2');
    expect(tester.getSize(message).width, lessThanOrEqualTo(290));
  });
}
