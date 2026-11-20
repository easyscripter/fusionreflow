import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/core/theme/app_cover_palette.dart';

import '../../../helpers/contrast.dart';

void main() {
  test('white text contrast ≥ 4.5', () {
    for (final color in AppCoverPalette.colors) {
      expect(
        contrastRatio(const Color(0xFFFFFFFF), color),
        greaterThanOrEqualTo(4.5),
        reason: '$color',
      );
    }
  });

  test('same hash same color', () {
    expect(AppCoverPalette.forBook('ab12'), AppCoverPalette.forBook('ab99'));
    expect(AppCoverPalette.forBook('zz'), AppCoverPalette.colors.first);
    expect(AppCoverPalette.forBook(''), AppCoverPalette.colors.first);
    expect(AppCoverPalette.forBook('0f'), AppCoverPalette.colors[15 % 8]);
  });

  test('name picks a palette color deterministically', () {
    expect(AppCoverPalette.forName('a.pdf'), AppCoverPalette.forName('a.pdf'));
    expect(AppCoverPalette.colors, contains(AppCoverPalette.forName('x')));
  });
}
