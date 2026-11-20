import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/src/rust/api/book.dart';
import 'package:fusionreflow/src/rust/frb_generated.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

const _meta = BookMeta(
  title: 'T',
  authors: ['A'],
  sourceHash: 'h',
  converterVersion: 'c',
);

/// Bridge API double: only hyphenation is implemented, anything else fails.
class _FakeRustLibApi implements RustLibApi {
  final List<String> hyphenated = [];
  final List<List<int>> metaCalls = [];

  @override
  Future<BookMeta> crateApiBookBookMeta({required List<int> bytes}) async {
    metaCalls.add(bytes);
    return _meta;
  }

  @override
  String crateApiTextHyphenate({required String text}) {
    hyphenated.add(text);
    return 'bridge:$text';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakeRustLibApi api;

  setUp(() {
    api = _FakeRustLibApi();
    RustLib.initMock(api: api);
  });

  tearDown(RustLib.dispose);

  test('RustCoreService.hyphenate calls the bridge with the text', () {
    final service = RustCoreService();

    expect(service.hyphenate('слово'), 'bridge:слово');
    expect(api.hyphenated, ['слово']);
  });

  test('init is idempotent', () async {
    final service = RustCoreService();

    await service.init();
    await service.init();
  });

  group('init without a loaded bridge', () {
    setUp(RustLib.dispose);

    test('parallel calls load the bridge once', () async {
      final loads = <Completer<void>>[];
      final service = RustCoreService(
        load: () {
          loads.add(Completer<void>());
          return loads.last.future;
        },
      );

      final first = service.init();
      final second = service.init();
      expect(loads, hasLength(1));
      loads.single.complete();
      await Future.wait([first, second]);
    });

    test('a failed load can be retried', () async {
      var calls = 0;
      final service = RustCoreService(
        load: () async {
          if (++calls == 1) throw Exception('boom');
        },
      );

      await expectLater(service.init(), throwsException);
      await service.init();

      expect(calls, 2);
    });

    test('retry while the first load hangs joins it', () async {
      final hang = Completer<void>();
      var calls = 0;
      final service = RustCoreService(
        load: () {
          calls++;
          return hang.future;
        },
      );

      unawaited(service.init());
      unawaited(service.init());

      expect(calls, 1);
      hang.complete();
    });
  });

  test('bookMeta delegates to bridge', () async {
    final service = RustCoreService();
    final bytes = Uint8List.fromList([1, 2]);

    expect(await service.bookMeta(bytes), _meta);
    expect(api.metaCalls, [bytes]);
  });

  test('rustCoreServiceProvider provides a RustCoreService', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(rustCoreServiceProvider), isA<RustCoreService>());
  });
}
