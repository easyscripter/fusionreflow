import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/shell/widgets/app_logo.dart';
import 'package:fusionreflow/ui/shell/widgets/rail_settings_button.dart';
import 'package:fusionreflow/ui/spikes/widgets/hyphen_spike_screen.dart';

import '../../../helpers/pump_app.dart';

const _tablet = Size(820, 1180);
const _spikeButton = Key('open_hyphen_spike');

/// Records `SystemNavigator.pop` calls; returns the counter.
List<String> _trackSystemPop(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      calls.add(call.method);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

Finder _inBar(String text) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(text));

void main() {
  testWidgets('phone shows navigation bar', (tester) async {
    await pumpApp(tester);

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations, hasLength(3));
    for (final label in ['Библиотека', 'Закладки', 'Настройки']) {
      expect(_inBar(label), findsOneWidget);
    }
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('library_screen')), findsOneWidget);
  });

  testWidgets('small phone shows navigation bar', (tester) async {
    await pumpApp(tester, size: const Size(360, 640));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet portrait shows rail', (tester) async {
    await pumpApp(tester, size: _tablet);

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations, hasLength(2));
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(AppLogo), findsOneWidget);
    final settingsY = tester.getTopLeft(find.byType(RailSettingsButton)).dy;
    final bookmarksY = tester
        .getTopLeft(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Закладки'),
          ),
        )
        .dy;
    expect(settingsY, greaterThan(bookmarksY));
  });

  testWidgets('tablet landscape shows rail', (tester) async {
    await pumpApp(tester, size: const Size(1180, 820));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('bar switches sections', (tester) async {
    await pumpApp(tester);

    await tester.tap(_inBar('Закладки'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookmarks_screen')), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(_inBar('Настройки'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings_screen')), findsOneWidget);
  });

  testWidgets('rail switches sections and settings button selects settings', (
    tester,
  ) async {
    await pumpApp(tester, size: _tablet);

    await tester.tap(find.byType(RailSettingsButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      isNull,
    );
    expect(
      tester
          .widget<RailSettingsButton>(find.byType(RailSettingsButton))
          .selected,
      isTrue,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Закладки'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookmarks_screen')), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
  });

  testWidgets('branches keep their state', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(_spikeButton));
    await tester.pumpAndSettle();
    expect(find.byType(HyphenSpikeScreen), findsOneWidget);

    await tester.tap(_inBar('Закладки'));
    await tester.pumpAndSettle();
    await tester.tap(_inBar('Библиотека'));
    await tester.pumpAndSettle();

    expect(find.byType(HyphenSpikeScreen), findsOneWidget);
  });

  testWidgets('tapping active item returns to section root', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(_spikeButton));
    await tester.pumpAndSettle();

    await tester.tap(_inBar('Библиотека'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('library_screen')), findsOneWidget);
    expect(find.byType(HyphenSpikeScreen), findsNothing);
  });

  testWidgets('layout switches on resize and keeps the section', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(_inBar('Закладки'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = _tablet;
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const Key('bookmarks_screen')), findsOneWidget);
  });

  testWidgets('back from bookmarks goes to library', (tester) async {
    final systemCalls = _trackSystemPop(tester);
    await pumpApp(tester);
    await tester.tap(_inBar('Закладки'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('library_screen')), findsOneWidget);
    expect(systemCalls, isNot(contains('SystemNavigator.pop')));
  });

  testWidgets('back from library exits', (tester) async {
    final systemCalls = _trackSystemPop(tester);
    await pumpApp(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(systemCalls, contains('SystemNavigator.pop'));
  });

  testWidgets('back inside a section pops its stack', (tester) async {
    final systemCalls = _trackSystemPop(tester);
    await pumpApp(tester);
    await tester.tap(find.byKey(_spikeButton));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('library_screen')), findsOneWidget);
    expect(systemCalls, isNot(contains('SystemNavigator.pop')));
  });
}
