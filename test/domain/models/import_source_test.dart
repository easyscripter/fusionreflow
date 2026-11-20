import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';

void main() {
  test('format by extension', () {
    expect(bookFormatOfFileName('a.EPUB'), BookFormat.epub);
    expect(bookFormatOfFileName('a.fb2'), BookFormat.fb2);
    expect(bookFormatOfFileName('a.fb2.zip'), BookFormat.fb2Zip);
    expect(bookFormatOfFileName('a.FB2.ZIP'), BookFormat.fb2Zip);
    expect(bookFormatOfFileName('a.pdf'), BookFormat.pdf);
    expect(bookFormatOfFileName('a.zip'), isNull);
    expect(bookFormatOfFileName('a.docx'), isNull);
    expect(bookFormatOfFileName('a'), isNull);
  });

  test('title of file name drops the format extension', () {
    expect(bookTitleOfFileName('War.and.Peace.epub'), 'War.and.Peace');
    expect(bookTitleOfFileName('b.FB2.zip'), 'b');
    expect(bookTitleOfFileName('noext'), 'noext');
    expect(bookTitleOfFileName('.hidden'), '.hidden');
  });
}
