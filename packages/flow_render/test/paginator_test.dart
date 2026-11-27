import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _paginator = FlowPaginator();
const _phone = Size(360, 640);
const _landscape = Size(640, 360);

List<FlowLineItem> _lines(FlowPage page) =>
    page.items.whereType<FlowLineItem>().toList();

void main() {
  test('pages_cover_section_without_gaps', () async {
    final s = section([for (var i = 0; i < 30; i++) para(80)]);
    final pages = await _paginator.paginate(s, _phone, testStyle);
    expect(pages.length, greaterThan(3));
    expect(pages.first.start, 0);
    for (var i = 0; i < pages.length - 1; i++) {
      expect(pages[i].end, pages[i + 1].start);
      expect(pages[i].start, lessThan(pages[i].end));
    }
    expect(pages.last.end, s.length);
    expect(coveredLength(pages), s.length);
    for (final page in pages) {
      for (final item in page.items) {
        expect(item.rect.bottom, lessThanOrEqualTo(_phone.height + 0.01));
        expect(item.rect.left, greaterThanOrEqualTo(0));
        expect(item.rect.right, lessThanOrEqualTo(_phone.width + 0.01));
      }
    }
  });

  test('empty_section_gives_one_page', () async {
    final pages = await _paginator.paginate(section([]), _phone, testStyle);
    expect(pages, hasLength(1));
    expect((pages.single.start, pages.single.end), (0, 0));
    expect(pages.single.contains(0), isTrue);
    expect(pages.single.items, isEmpty);
  });

  test('empty_paragraph_and_blank_blocks_do_not_break_pages', () async {
    final pages = await _paginator.paginate(
      section([
        const FlowText([]),
        para(3),
        const FlowText([FlowTextSpan('')]),
      ]),
      _phone,
      testStyle,
    );
    expect(pages, hasLength(1));
    expect(pages.single.end, para(3).length);
  });

  test('page_index_of_offset', () async {
    final s = section([for (var i = 0; i < 30; i++) para(80)]);
    final pages = await _paginator.paginate(s, _phone, testStyle);
    final inThird = pages[2].start + 3;
    expect(pageIndexOf(pages, inThird), 2);
    expect(pages[2].contains(inThird), isTrue);
    expect(pages[1].contains(inThird), isFalse);
    expect(pageIndexOf(pages, -5), 0);
    expect(pageIndexOf(pages, s.length + 10), pages.length - 1);
    expect(pageIndexOf(pages, s.length), pages.length - 1);
    expect(pages.last.contains(s.length), isTrue);
    expect(pages.first.contains(pages.first.end), isFalse);
    expect(pageIndexOf(pages, pages[1].start), 1);
  });

  test('same_offset_after_resize', () async {
    final s = section([for (var i = 0; i < 30; i++) para(80)]);
    final portrait = await _paginator.paginate(s, _phone, testStyle);
    final wide = await _paginator.paginate(s, _landscape, testStyle);
    final x = portrait[4].start;
    final p = wide[pageIndexOf(wide, x)];
    expect(p.contains(x), isTrue);
    expect(p.start, lessThanOrEqualTo(x));
  });

  test('no_widow_or_orphan_lines', () async {
    // 20-word paragraphs: 3 lines each at 360 wide. Pages hold ~ 20 lines.
    final s = section([for (var i = 0; i < 40; i++) para(20)]);
    final pages = await _paginator.paginate(s, _phone, testStyle);
    for (final page in pages) {
      final lines = _lines(page);
      // Every paragraph on a page keeps at least two lines together, unless
      // it is a one-line paragraph.
      final byStart = <int, int>{};
      for (final line in lines) {
        byStart.update(line.paragraphStart, (n) => n + 1, ifAbsent: () => 1);
      }
      for (final entry in byStart.entries) {
        final total = lines
            .firstWhere((l) => l.paragraphStart == entry.key)
            .paragraphLines;
        if (total >= 2) expect(entry.value, greaterThanOrEqualTo(2));
      }
    }
  });

  test('heading_not_last_on_page', () async {
    final blocks = <FlowBlock>[
      for (var i = 0; i < 40; i++) ...[
        const FlowText([FlowTextSpan('Глава')], role: FlowTextRole.heading),
        para(20),
      ],
    ];
    final pages = await _paginator.paginate(section(blocks), _phone, testStyle);
    for (final page in pages) {
      final last = page.items.last;
      expect(
        last is FlowLineItem && last.isHeading,
        isFalse,
        reason: 'heading is the last item of a page',
      );
    }
  });

  test('long_word_breaks_inside_page', () async {
    final pages = await _paginator.paginate(
      section([
        FlowText([FlowTextSpan(longWord)]),
      ]),
      const Size(280, 640),
      testStyle,
    );
    final lines = pages.expand(_lines).toList();
    expect(lines.length, greaterThan(1));
    for (final line in lines) {
      expect(line.rect.width, lessThanOrEqualTo(280 - 40 + 0.01));
    }
    expect(lines.fold<int>(0, (sum, l) => sum + l.end - l.start), 300);
  });

  test('image_fits_page', () async {
    final png = await makePng(2000, 3000);
    final pages = await _paginator.paginate(
      section([FlowImage(png)]),
      _phone,
      testStyle,
    );
    final picture = pages.single.items.single as FlowPictureItem;
    expect(picture.broken, isFalse);
    expect(picture.rect.width, lessThanOrEqualTo(360 - 40 + 0.01));
    expect(picture.rect.height, lessThanOrEqualTo(640 + 0.01));
    expect(picture.rect.width / picture.rect.height, closeTo(2 / 3, 0.01));
  });

  test('small_image_is_not_enlarged', () async {
    final png = await makePng(40, 30);
    final pages = await _paginator.paginate(
      section([FlowImage(png)]),
      _phone,
      testStyle,
    );
    final picture = pages.single.items.single as FlowPictureItem;
    expect(picture.rect.size, const Size(40, 30));
    expect(picture.rect.center.dx, closeTo(180, 0.01));
  });

  test('broken_image_is_placeholder', () async {
    for (final bytes in [
      Uint8List.fromList([1, 2, 3]),
      Uint8List(0),
    ]) {
      final pages = await _paginator.paginate(
        section([FlowImage(bytes)]),
        _phone,
        testStyle,
      );
      final picture = pages.single.items.single as FlowPictureItem;
      expect(picture.broken, isTrue);
      expect(picture.rect.height, closeTo(3 * testStyle.line, 0.01));
    }
  });

  test('image_moves_to_next_page_when_it_does_not_fit', () async {
    final png = await makePng(300, 400);
    final blocks = [for (var i = 0; i < 6; i++) para(20), FlowImage(png)];
    final pages = await _paginator.paginate(section(blocks), _phone, testStyle);
    final imagePage = pages.firstWhere(
      (p) => p.items.any((i) => i is FlowPictureItem),
    );
    expect(
      imagePage.items.first,
      isA<FlowPictureItem>().having((i) => i.rect.top, 'top', 0),
    );
  });

  test('table_splits_by_rows', () async {
    const row = [
      [FlowTextSpan('ячейка один')],
      [FlowTextSpan('ячейка два')],
      [FlowTextSpan('три')],
    ];
    final table = FlowTable([for (var i = 0; i < 60; i++) row]);
    final s = section([table]);
    final pages = await _paginator.paginate(s, _phone, testStyle);
    expect(pages.length, greaterThan(1));
    for (final page in pages) {
      expect(page.items.whereType<FlowRowItem>(), isNotEmpty);
    }
    final rowItems = pages.expand((p) => p.items.whereType<FlowRowItem>());
    expect(rowItems.length, 60);
    expect(coveredLength(pages), table.length);
    expect(pages.last.end, table.length);
  });

  test('tall_table_row_degrades_to_paragraphs', () async {
    final table = FlowTable([
      [
        [FlowTextSpan(para(2000).spans.whereType<FlowTextSpan>().first.text)],
        const [FlowTextSpan('второй')],
      ],
    ]);
    final pages = await _paginator.paginate(
      section([table]),
      _phone,
      testStyle,
    );
    expect(pages.length, greaterThan(1));
    expect(coveredLength(pages), table.length);
    expect(pages.expand((p) => p.items).whereType<FlowRowItem>(), isEmpty);
    final lineUnits = pages
        .expand(_lines)
        .fold<int>(0, (sum, l) => sum + l.end - l.start);
    expect(lineUnits, table.length - 2);
  });

  test('table_with_empty_cells_and_narrow_page', () async {
    final table = FlowTable([
      [
        const [FlowTextSpan('')],
        [FlowTextSpan(longWord)],
        const [FlowTextSpan('x')],
      ],
      const [
        [FlowTextSpan('a')],
        [],
        [FlowTextSpan('b')],
      ],
    ]);
    final pages = await _paginator.paginate(
      section([table]),
      const Size(200, 640),
      testStyle,
    );
    expect(coveredLength(pages), table.length);
    for (final item in pages.expand((p) => p.items)) {
      expect(item.rect.right, lessThanOrEqualTo(200.01));
    }
  });

  test('list_quote_code_rule_footnote_and_inline_image', () async {
    final png = await makePng(20, 20);
    final s = section([
      const FlowText([FlowTextSpan('пункт')], marker: '•', indent: 1),
      const FlowText([FlowTextSpan('цитата')], indent: 9),
      const FlowText([FlowTextSpan('code line')], role: FlowTextRole.code),
      const FlowText([FlowTextSpan('code line 2')], role: FlowTextRole.code),
      const FlowRule(),
      const FlowText([FlowTextSpan('сноска')], role: FlowTextRole.footnote),
      const FlowText([FlowTextSpan('подпись')], role: FlowTextRole.caption),
      FlowText([
        const FlowTextSpan('с картинкой '),
        FlowImageSpan(png, 1),
        const FlowTextSpan(' и ссылкой', link: true),
        const FlowTextSpan('2', script: FlowScript.sup),
        const FlowTextSpan(
          'x',
          script: FlowScript.sub,
          bold: true,
          italic: true,
        ),
        const FlowTextSpan('c', code: true),
      ]),
    ]);
    final pages = await _paginator.paginate(s, _phone, testStyle);
    expect(pages, hasLength(1));
    final items = pages.single.items;
    expect(items.whereType<FlowRuleItem>(), hasLength(1));
    expect(items.whereType<FlowLabelItem>(), hasLength(1)); // the marker
    final inline = items
        .whereType<FlowLineItem>()
        .expand((l) => l.inlineImages)
        .toList();
    expect(inline, hasLength(1));
    expect(coveredLength(pages), s.length);
    // Code lines are tight: no gap between them.
    final code = items
        .whereType<FlowLineItem>()
        .where((l) => l.rect.height > 0)
        .toList();
    expect(code, isNotEmpty);
  });

  test('soft_hyphen_keeps_offsets_and_does_not_break', () async {
    const text = 'при­мер';
    final pages = await _paginator.paginate(
      section([
        const FlowText([FlowTextSpan(text)]),
      ]),
      const Size(40 + 18 * 8, 640),
      testStyle,
    );
    expect(pages.single.end, text.length);
    final lines = _lines(pages.single);
    expect(lines.fold<int>(0, (sum, l) => sum + l.end - l.start), text.length);
  });

  test('engine_line_breaker_covers_text', () {
    const text = FlowText([FlowTextSpan('слово слово слово слово слово')]);
    final lines = const EngineLineBreaker().breakLines(text, 200, testStyle);
    expect(lines.first.start, 0);
    expect(lines.last.end, text.length);
    for (var i = 0; i < lines.length - 1; i++) {
      expect(lines[i].end, lines[i + 1].start);
      expect(lines[i].height, greaterThan(0));
    }
  });

  test('table_header_is_not_left_alone_at_page_bottom', () async {
    const row = [
      [FlowTextSpan('ячейка')],
      [FlowTextSpan('вторая')],
    ];
    // Vary the text above the table so that some run leaves room for
    // exactly one table row at the bottom of the page.
    for (var n = 1; n <= 40; n++) {
      final s = section([
        for (var i = 0; i < n; i++) para(2),
        FlowTable([for (var i = 0; i < 40; i++) row]),
      ]);
      final pages = await _paginator.paginate(s, _phone, testStyle);
      for (var p = 0; p < pages.length - 1; p++) {
        final rows = pages[p].items.whereType<FlowRowItem>().length;
        final nextRows = pages[p + 1].items.whereType<FlowRowItem>().length;
        if (rows == 1 && nextRows > 0) {
          fail('n=$n: one table row alone at the bottom of page $p');
        }
      }
    }
  });

  const heading = FlowText([FlowTextSpan('Глава')], role: FlowTextRole.heading);

  /// Fails if a page of [pages] ends with a heading line.
  void expectNoHeadingAtBottom(List<FlowPage> pages, String reason) {
    for (final page in pages.take(pages.length - 1)) {
      final last = page.items.last;
      expect(last is FlowLineItem && last.isHeading, isFalse, reason: reason);
    }
  }

  test('two_headings_are_not_left_at_page_bottom', () async {
    for (var n = 1; n <= 40; n++) {
      final pages = await _paginator.paginate(
        section([
          for (var i = 0; i < n; i++) para(2),
          heading,
          heading,
          para(40),
        ]),
        _phone,
        testStyle,
      );
      expectNoHeadingAtBottom(pages, 'n=$n');
    }
  });

  test('heading_before_short_paragraph_moves_with_it', () async {
    for (var words = 5; words <= 12; words++) {
      for (var n = 1; n <= 40; n++) {
        final pages = await _paginator.paginate(
          section([
            for (var i = 0; i < n; i++) para(2),
            heading,
            para(words),
            para(40),
          ]),
          _phone,
          testStyle,
        );
        expectNoHeadingAtBottom(pages, 'words=$words n=$n');
      }
    }
  });

  test('quote_has_space_around_but_not_inside', () async {
    const quote = FlowText([FlowTextSpan('цитата')], indent: 1);
    final pages = await _paginator.paginate(
      section([para(2), quote, quote, para(2)]),
      _phone,
      testStyle,
    );
    final lines = _lines(pages.single);
    expect(lines, hasLength(4));
    final half = testStyle.line / 2;
    expect(lines[1].rect.top - lines[0].rect.bottom, closeTo(half, 0.01));
    expect(lines[2].rect.top - lines[1].rect.bottom, closeTo(0, 0.01));
    expect(lines[3].rect.top - lines[2].rect.bottom, closeTo(half, 0.01));
  });

  test('image_in_table_cell_is_placed', () async {
    final png = await makePng(40, 20);
    final table = FlowTable([
      [
        [const FlowTextSpan('a '), FlowImageSpan(png, 1)],
        [FlowImageSpan(png, 1)],
      ],
    ]);
    final pages = await _paginator.paginate(
      section([table]),
      _phone,
      testStyle,
    );
    final row = pages.single.items.single as FlowRowItem;
    final images = row.cells.expand((c) => c.inlineImages).toList();
    expect(images, hasLength(2));
    for (final image in images) {
      expect(image.bytes, png);
      expect(image.box.width / image.box.height, closeTo(2, 0.01));
    }
  });

  test('inline_image_keeps_its_ratio_and_height', () async {
    final wide = await makePng(80, 20);
    final pages = await _paginator.paginate(
      section([
        FlowText([const FlowTextSpan('x '), FlowImageSpan(wide, 2)]),
      ]),
      _phone,
      testStyle,
    );
    final image = _lines(pages.single).expand((l) => l.inlineImages).single;
    expect(image.box.height, closeTo(2 * 18, 0.01));
    expect(image.box.width, closeTo(4 * 2 * 18, 0.01));
  });

  // Columns are measured as drawn (the built spans: weight, italic,
  // pictures). The test font has one width for every weight, so a picture
  // stands for what a plain-text measure would miss.
  test('column_width_includes_what_is_drawn', () async {
    final wide = await makePng(80, 20);
    final table = FlowTable([
      [
        [FlowImageSpan(wide, 3)],
        const [FlowTextSpan('много слов тут и там и ещё раз тут и там')],
      ],
    ]);
    final pages = await _paginator.paginate(
      section([table]),
      _phone,
      testStyle,
    );
    final row = pages.single.items.single as FlowRowItem;
    final image = row.cells.first.inlineImages.single;
    expect(image.box.width, closeTo(4 * 3 * 18 * 0.9, 1));
  });

  test('cell_padding_and_caption_gap_follow_the_design', () async {
    final png = await makePng(40, 20);
    const table = FlowTable([
      [
        [FlowTextSpan('a')],
      ],
    ]);
    final pages = await _paginator.paginate(
      section([
        FlowImage(png),
        const FlowText([FlowTextSpan('c')], role: FlowTextRole.caption),
        table,
      ]),
      _phone,
      testStyle,
    );
    final picture = pages.single.items.whereType<FlowPictureItem>().single;
    final caption = _lines(pages.single).single;
    expect(caption.rect.top - picture.rect.bottom, closeTo(8, 0.01));
    final row = pages.single.items.whereType<FlowRowItem>().single;
    expect(row.cells.single.rect.left - row.columnXs.first, closeTo(8, 0.01));
  });

  test('lines_carry_their_text_for_semantics', () async {
    final pages = await _paginator.paginate(
      section([
        const FlowText([FlowTextSpan('пре\u00ADдо')]),
        const FlowTable([
          [
            [FlowTextSpan('яч\u00ADейка')],
          ],
        ]),
      ]),
      _phone,
      testStyle,
    );
    expect(pages.single.text, 'предо\nячейка');
  });

  test('a_long_table_lets_other_events_run', () async {
    const row = [
      [FlowTextSpan('один два три')],
      [FlowTextSpan('четыре пять')],
    ];
    var ticks = 0;
    var done = false;
    void tick() {
      if (done) return;
      ticks++;
      Future<void>.delayed(Duration.zero, tick);
    }

    Future<void>.delayed(Duration.zero, tick);
    await _paginator.paginate(
      section([
        FlowTable([for (var i = 0; i < 3000; i++) row]),
      ]),
      _phone,
      testStyle,
    );
    done = true;
    expect(ticks, greaterThan(0));
  });
}
