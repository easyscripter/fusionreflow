import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';
import 'package:fusionreflow/ui/reader/reader_page_metrics.dart';

void main() {
  group('ReaderPageMetrics.of', () {
    test('small phone', () {
      final m = ReaderPageMetrics.of(360);
      expect((m.fontSize, m.line, m.margin), (17, 26, 20));
    });

    test('compact phone', () {
      final m = ReaderPageMetrics.of(390);
      expect((m.fontSize, m.line, m.margin), (18, 28, 24));
    });

    test('phone in landscape follows the window width', () {
      final m = ReaderPageMetrics.of(844);
      expect((m.fontSize, m.line), (21, 32));
      // The text column is 560 wide, centered.
      expect(m.margin, (844 - 560) / 2);
    });

    test('tablet and a narrow medium window', () {
      expect(ReaderPageMetrics.of(1280).margin, (1280 - 560) / 2);
      final medium = ReaderPageMetrics.of(600);
      expect(medium.fontSize, 21);
      expect(medium.margin, 24);
    });
  });

  test('style carries sizes and palette colors', () {
    final style = ReaderPageMetrics.of(390).style(ReaderPalette.dark);

    expect(style.fontSize, 18);
    expect(style.line, closeTo(28, 1e-9));
    expect(style.padding.left, 24);
    expect(style.padding.right, 24);
    expect(style.justify, isTrue);
    expect(style.textColor, ReaderPalette.dark.pageText);
    expect(style.mutedColor, ReaderPalette.dark.onSurfaceVariant);
    expect(style.accentColor, ReaderPalette.dark.accent);
    expect(style.fontFamily, 'Literata');
    expect(style.codeFontFamily, 'JetBrainsMono');
  });
}
