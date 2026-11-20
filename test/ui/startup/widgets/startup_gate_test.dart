import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/config/app_startup.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/ui/startup/widgets/startup_gate.dart';

import '../../../helpers/fake_rust_core_service.dart';

class _HangingRustCoreService extends FakeRustCoreService {
  @override
  Future<void> init() => Completer<void>().future;
}

Widget _app(List<Override> overrides, void Function() onFirstFrame) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StartupGate(
          onFirstFrame: onFirstFrame,
          child: const Text('child'),
        ),
      ),
    );

void main() {
  testWidgets('ready shows app and allows first frame once', (tester) async {
    var frames = 0;
    await tester.pumpWidget(
      _app([appStartupProvider.overrideWith((ref) async {})], () => frames++),
    );
    await tester.pump();

    expect(find.text('child'), findsOneWidget);
    expect(frames, 1);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(frames, 1);
  });

  testWidgets('default releases the deferred first frame exactly once', (
    tester,
  ) async {
    final binding = tester.binding
      ..resetFirstFrameSent()
      ..deferFirstFrame();
    addTearDown(binding.resetFirstFrameSent);
    expect(binding.sendFramesToEngine, isFalse);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStartupProvider.overrideWith((ref) async {})],
        child: const MaterialApp(home: StartupGate(child: Text('child'))),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(binding.sendFramesToEngine, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(binding.sendFramesToEngine, isTrue);
  });

  testWidgets('loading does not allow first frame', (tester) async {
    var frames = 0;
    final never = Completer<void>();
    await tester.pumpWidget(
      _app([appStartupProvider.overrideWith((ref) => never.future)], () {
        frames++;
      }),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(frames, 0);
  });

  testWidgets('error shows error screen and allows first frame', (
    tester,
  ) async {
    var frames = 0;
    await tester.pumpWidget(
      _app([
        appStartupProvider.overrideWith((ref) async => throw StateError('x')),
      ], () => frames++),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('startup_error')), findsOneWidget);
    expect(find.text('Не удалось запустить приложение'), findsOneWidget);
    expect(
      find.text('Попробуйте ещё раз. Ваши книги на месте.'),
      findsOneWidget,
    );
    expect(find.text('Повторить'), findsOneWidget);
    expect(frames, 1);
  });

  testWidgets('retry reruns startup', (tester) async {
    var frames = 0;
    var starts = 0;
    await tester.pumpWidget(
      _app([
        appStartupProvider.overrideWith((ref) async {
          if (++starts == 1) throw StateError('first');
        }),
      ], () => frames++),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('startup_error')), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    await tester.pump();
    await tester.pump();

    expect(find.text('child'), findsOneWidget);
    expect(starts, 2);
    expect(frames, 1);
  });

  testWidgets('hanging startup times out', (tester) async {
    var frames = 0;
    await tester.pumpWidget(
      _app([
        rustCoreServiceProvider.overrideWithValue(_HangingRustCoreService()),
      ], () => frames++),
    );
    await tester.pump();
    expect(frames, 0);

    await tester.pump(startupTimeout + const Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(const Key('startup_error')), findsOneWidget);
    expect(frames, 1);
  });
}
