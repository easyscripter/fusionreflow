import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/library/widgets/book_cover.dart';

Future<void> _pump(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(
    home: Center(
      child: SizedBox(
        width: 150,
        child: BookCover(title: 'Дюна', author: 'Фрэнк', color: Colors.blue),
      ),
    ),
  ),
);

void main() {
  testWidgets('author is at the top and title at the bottom', (tester) async {
    await _pump(tester);

    final cover = tester.getRect(find.byType(BookCover));
    final author = tester.getRect(find.text('Фрэнк'));
    final title = tester.getRect(find.text('Дюна'));
    expect(author.top - cover.top, lessThan(16));
    expect(cover.bottom - title.bottom, lessThan(16));
  });
}
