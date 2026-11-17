import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/routing/app_router.dart';
import 'package:fusionreflow/routing/app_routes.dart';

import '../helpers/pump_app.dart';

/// Path the router currently shows (the router lives in the app's scope).
String _path(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(appRouterProvider)
        .routeInformationProvider
        .value
        .uri
        .path;

void main() {
  testWidgets('starts at library', (tester) async {
    await pumpApp(tester);

    expect(_path(tester), AppRoutes.library);
  });

  testWidgets('unknown path redirects to library', (tester) async {
    await pumpApp(tester);
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(appRouterProvider)
        .go('/nope');
    await tester.pumpAndSettle();

    expect(_path(tester), AppRoutes.library);
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });
}
