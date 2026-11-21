import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/config/app_startup.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/repositories/import_repository.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/fusion_reflow_app.dart';
import 'package:fusionreflow/routing/app_router.dart';

import 'fake_book_repository.dart';
import 'fake_import_repository.dart';
import 'fake_rust_core_service.dart';
import 'preload_locale_names.dart';

/// Pumps the whole app with an instantly ready startup, a [size] window and
/// the `ru` locale. [location] starts the router there; [overrides] are added
/// last, so they win. [books] and [imports] are the library and importer
/// fakes (empty ones by default).
Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  String? location,
  List<Override> overrides = const [],
  FakeBookRepository? books,
  FakeImportRepository? imports,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher
    ..localeTestValue = const Locale('ru')
    ..localesTestValue = const [Locale('ru')];
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher
      ..clearLocaleTestValue()
      ..clearLocalesTestValue();
  });
  await preloadLocaleNames(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appStartupProvider.overrideWith((ref) async {}),
        rustCoreServiceProvider.overrideWithValue(FakeRustCoreService()),
        bookRepositoryProvider.overrideWithValue(books ?? FakeBookRepository()),
        importRepositoryProvider.overrideWithValue(
          imports ?? FakeImportRepository(),
        ),
        if (location != null)
          appRouterProvider.overrideWith(
            (ref) => createAppRouter(initialLocation: location),
          ),
        ...overrides,
      ],
      child: const FusionReflowApp(),
    ),
  );
  await tester.pumpAndSettle();
}
