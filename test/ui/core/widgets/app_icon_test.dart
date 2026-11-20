import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/core/theme/app_icons.dart';
import 'package:fusionreflow/ui/core/widgets/app_icon.dart';

void main() {
  test('every icon asset is a bundled svg', () async {
    for (final asset in AppIcons.all) {
      expect(
        await rootBundle.loadString(asset),
        contains('<svg'),
        reason: asset,
      );
    }
  });

  testWidgets('icon takes size and color from the icon theme', (tester) async {
    await tester.pumpWidget(
      const IconTheme(
        data: IconThemeData(color: Color(0xFF123456), size: 20),
        child: AppIcon(AppIcons.bookmark),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 20);
    expect(svg.height, 20);
    expect(
      svg.colorFilter,
      const ColorFilter.mode(Color(0xFF123456), BlendMode.srcIn),
    );
  });

  testWidgets('explicit size and color win over the theme', (tester) async {
    await tester.pumpWidget(
      const IconTheme(
        data: IconThemeData(color: Color(0xFF123456), size: 20),
        child: AppIcon(AppIcons.tune, size: 24, color: Color(0xFFFF0000)),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 24);
    expect(
      svg.colorFilter,
      const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn),
    );
  });
}
