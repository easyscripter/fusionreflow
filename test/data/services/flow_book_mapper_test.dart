import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/flow_book_mapper.dart';
import 'package:fusionreflow/src/rust/api/book.dart' as rb;

const _plain = rb.Style(
  bold: false,
  italic: false,
  code: false,
  script: rb.Script.normal,
);

rb.Inline _t(String text, {rb.Style style = _plain}) =>
    rb.Inline.text(text: text, style: style);

rb.BlockNode _p(String text) =>
    rb.BlockNode(block: rb.Block.paragraph(inlines: [_t(text)]));

rb.BlockNode _h(String text, int level) => rb.BlockNode(
  block: rb.Block.heading(level: level, inlines: [_t(text)]),
);

rb.TocEntry _toc(int block, String title, {int level = 1}) =>
    rb.TocEntry(level: level, title: title, block: BigInt.from(block));

rb.Book _book(
  List<rb.BlockNode> blocks, {
  List<rb.TocEntry> toc = const [],
  List<rb.Resource> resources = const [],
}) => rb.Book(
  formatVersion: 1,
  converterVersion: 'test',
  sourceHash: 'h',
  meta: const rb.Meta(title: 'Книга', authors: []),
  toc: toc,
  blocks: blocks,
  resources: resources,
);

List<int> _lengths(FlowBook book) => [
  for (final s in book.sections) s.blocks.length,
];

void main() {
  test('sections_from_toc', () {
    final book = flowBookOf(
      _book(
        [for (var i = 0; i < 15; i++) _p('p$i')],
        toc: [
          _toc(0, 'Предисловие'),
          _toc(5, 'Часть первая'),
          _toc(5, 'Глава 1', level: 2),
          _toc(12, 'Глава 2'),
        ],
      ),
    );
    expect(book.title, 'Книга');
    expect(_lengths(book), [5, 7, 3]);
    expect(book.sections.map((s) => s.title), [
      'Предисловие',
      'Глава 1',
      'Глава 2',
    ]);
  });

  test('toc_does_not_start_at_zero_gets_untitled_first_section', () {
    final book = flowBookOf(
      _book([for (var i = 0; i < 6; i++) _p('p$i')], toc: [_toc(3, 'Глава')]),
    );
    expect(_lengths(book), [3, 3]);
    expect(book.sections.map((s) => s.title), [null, 'Глава']);
    // A preface before the first entry is a chapter, not a chunk.
    expect(book.sections.any((s) => s.chunk), isFalse);
  });

  test('unsorted_and_out_of_range_toc', () {
    final book = flowBookOf(
      _book(
        [for (var i = 0; i < 15; i++) _p('p$i')],
        toc: [_toc(12, 'c'), _toc(3, 'b'), _toc(999, 'x'), _toc(-1, 'y')],
      ),
    );
    expect(_lengths(book), [3, 9, 3]);
  });

  test('sections_from_headings_without_toc', () {
    final book = flowBookOf(
      _book([
        _p('a'),
        _p('b'),
        _h('Гла­ва один', 1),
        _p('c'),
        _h('подзаголовок', 3),
        _p('d'),
        _p('e'),
        _h('Глава два', 2),
        _p('f'),
      ]),
    );
    expect(_lengths(book), [2, 5, 2]);
    expect(book.sections.map((s) => s.title), [
      null,
      'Глава один',
      'Глава два',
    ]);
  });

  test('all_toc_entries_out_of_range_falls_back_to_headings', () {
    final book = flowBookOf(
      _book([_p('a'), _h('Глава', 1), _p('b')], toc: [_toc(50, 'x')]),
    );
    expect(_lengths(book), [1, 2]);
  });

  test('chunks_without_headings', () {
    final book = flowBookOf(_book([for (var i = 0; i < 450; i++) _p('p')]));
    expect(_lengths(book), [200, 200, 50]);
    expect(book.sections.every((s) => s.title == null), isTrue);
    expect(book.sections.every((s) => s.chunk), isTrue);
  });

  test('empty_book', () {
    final book = flowBookOf(_book([]));
    expect(book.sections, hasLength(1));
    expect(book.sections.single.blocks, isEmpty);
    expect(book.sections.single.title, isNull);
  });

  test('maps_every_block_kind', () {
    final png = Uint8List.fromList([1, 2, 3]);
    const bold = rb.Style(
      bold: true,
      italic: true,
      code: true,
      script: rb.Script.sub,
    );
    final book = flowBookOf(
      _book(
        [
          rb.BlockNode(
            block: rb.Block.paragraph(
              inlines: [
                _t('a', style: bold),
                rb.Inline.link(
                  target: const rb.LinkTarget.external_('https://x'),
                  inlines: [_t('l')],
                ),
                const rb.Inline.noteRef(id: 'n1', label: '[1]'),
                const rb.Inline.image(
                  res: rb.ResourceId(field0: 7),
                  heightEm: 1.5,
                ),
                const rb.Inline.image(
                  res: rb.ResourceId(field0: 99),
                  heightEm: 1,
                ),
              ],
            ),
          ),
          _h('Заголовок', 3),
          rb.BlockNode(
            block: rb.Block.listItem(
              marker: const rb.ListMarker.number(3),
              depth: 2,
              inlines: [_t('i')],
            ),
          ),
          rb.BlockNode(
            block: rb.Block.listItem(
              marker: const rb.ListMarker.bullet(),
              depth: 0,
              inlines: [_t('b')],
            ),
          ),
          rb.BlockNode(
            block: rb.Block.quote(
              blocks: [
                _p('q'),
                rb.BlockNode(block: rb.Block.quote(blocks: [_p('qq')])),
              ],
            ),
          ),
          const rb.BlockNode(block: rb.Block.code(lines: ['x = 1', 'y = 2'])),
          rb.BlockNode(
            block: rb.Block.footnote(id: 'n1', blocks: [_p('сноска')]),
          ),
          rb.BlockNode(
            block: rb.Block.figure(
              image: const rb.ResourceId(field0: 7),
              caption: [_t('подпись')],
            ),
          ),
          const rb.BlockNode(
            block: rb.Block.figure(
              image: rb.ResourceId(field0: 7),
              caption: [],
            ),
          ),
          const rb.BlockNode(
            block: rb.Block.formula(image: rb.ResourceId(field0: 7)),
          ),
          const rb.BlockNode(
            block: rb.Block.fixedPage(image: rb.ResourceId(field0: 404)),
          ),
          rb.BlockNode(
            block: rb.Block.table(
              rb.Table(
                rows: [
                  [
                    [_t('c1')],
                    [_t('c2')],
                  ],
                ],
              ),
            ),
          ),
          const rb.BlockNode(block: rb.Block.separator()),
        ],
        resources: [
          rb.Resource(
            id: const rb.ResourceId(field0: 7),
            mime: 'image/png',
            data: png,
          ),
        ],
      ),
    );
    final blocks = book.sections.single.blocks;
    expect(blocks[0], isA<FlowText>());
    final spans = (blocks[0] as FlowText).spans;
    expect(
      spans[0],
      const FlowTextSpan(
        'a',
        bold: true,
        italic: true,
        code: true,
        script: FlowScript.sub,
      ),
    );
    expect(spans[1], const FlowTextSpan('l', link: true));
    expect(
      spans[2],
      const FlowTextSpan('[1]', link: true, script: FlowScript.sup),
    );
    expect(spans[3], FlowImageSpan(png, 1.5));
    expect(spans[4], FlowImageSpan(Uint8List(0), 1));
    expect(
      blocks[1],
      const FlowText(
        [FlowTextSpan('Заголовок')],
        role: FlowTextRole.heading,
        headingLevel: 3,
      ),
    );
    expect(
      blocks[2],
      const FlowText([FlowTextSpan('i')], marker: '3.', indent: 2),
    );
    expect(blocks[3], const FlowText([FlowTextSpan('b')], marker: '•'));
    expect(blocks[4], const FlowText([FlowTextSpan('q')], indent: 1));
    expect(blocks[5], const FlowText([FlowTextSpan('qq')], indent: 2));
    expect(
      blocks[6],
      const FlowText([FlowTextSpan('x = 1')], role: FlowTextRole.code),
    );
    expect(
      blocks[7],
      const FlowText([FlowTextSpan('y = 2')], role: FlowTextRole.code),
    );
    expect(
      blocks[8],
      const FlowText([FlowTextSpan('сноска')], role: FlowTextRole.footnote),
    );
    expect(blocks[9], FlowImage(png));
    expect(
      blocks[10],
      const FlowText([FlowTextSpan('подпись')], role: FlowTextRole.caption),
    );
    expect(blocks[11], FlowImage(png)); // figure without a caption
    expect(blocks[12], FlowImage(png)); // formula
    expect(blocks[13], FlowImage(Uint8List(0))); // missing resource
    expect(
      blocks[14],
      const FlowTable([
        [
          [FlowTextSpan('c1')],
          [FlowTextSpan('c2')],
        ],
      ]),
    );
    expect(blocks[15], const FlowRule());
    expect(blocks, hasLength(16));
  });
}
