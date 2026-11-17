import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/core/theme/app_brand.dart';
import 'package:fusionreflow/ui/shell/widgets/app_logo.dart';

void main() {
  testWidgets('logo has brand background and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: AppLogo()),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AppLogo),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect((box.decoration as BoxDecoration).color, const Color(0xFF0C0F22));
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppBrand.logoMarkAsset);
    expect(find.bySemanticsLabel('FusionReflow'), findsOneWidget);
  });
}
