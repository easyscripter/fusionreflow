import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/bridge_import_event.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/src/rust/api/book.dart';
import 'package:fusionreflow/src/rust/api/import.dart';
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
  final List<(int, SourceKind)> importCalls = [];
  final List<int> cancelCalls = [];
  List<ImportEvent> importEvents = const [];

  @override
  Stream<ImportEvent> crateApiImportImportBook({
    required int fd,
    required SourceKind kind,
  }) {
    importCalls.add((fd, kind));
    return Stream.fromIterable(importEvents);
  }

  @override
  Future<void> crateApiImportCancelImport({required int jobId}) async {
    cancelCalls.add(jobId);
  }

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

  test('importBook maps format to source kind', () async {
    final service = RustCoreService();
    for (final (format, kind) in [
      (BookFormat.pdf, SourceKind.pdf),
      (BookFormat.epub, SourceKind.epub),
      (BookFormat.fb2, SourceKind.fb2),
      (BookFormat.fb2Zip, SourceKind.fb2Zip),
    ]) {
      await service.importBook(5, format).toList();
      expect(api.importCalls.last, (5, kind));
    }
  });

  test('bridge events map to service events', () async {
    final bytes = Uint8List.fromList([1]);
    api.importEvents = [
      const ImportEvent.started(7),
      const ImportEvent.progress(
        Progress(stage: Stage.pages, done: 1, total: 3),
      ),
      ImportEvent.done(bytes),
    ];
    final events = await RustCoreService()
        .importBook(5, BookFormat.epub)
        .toList();
    expect(events[0], isA<BridgeImportStarted>());
    expect((events[0] as BridgeImportStarted).jobId, 7);
    final progress = events[1] as BridgeImportProgress;
    expect((progress.done, progress.total), (1, 3));
    expect((events[2] as BridgeImportDone).bytes, bytes);
  });

  test('bridge errors map to failures', () async {
    final cases = <ImportError, ImportFailure>{
      const ImportError.unsupported(SourceKind.pdf): ImportFailure.pdfNotYet,
      const ImportError.unsupported(SourceKind.epub):
          ImportFailure.unsupportedFormat,
      const ImportError.corrupted('x'): ImportFailure.unreadable,
      const ImportError.noTextLayer(): ImportFailure.unreadable,
      const ImportError.outOfMemory(): ImportFailure.unreadable,
      const ImportError.cancelled(): ImportFailure.cancelled,
    };
    for (final MapEntry(key: error, value: failure) in cases.entries) {
      api.importEvents = [ImportEvent.failed(error)];
      final events = await RustCoreService()
          .importBook(1, BookFormat.pdf)
          .toList();
      expect((events.single as BridgeImportFailed).failure, failure);
    }
  });

  test('cancelImport delegates to bridge', () async {
    await RustCoreService().cancelImport(9);
    expect(api.cancelCalls, [9]);
  });

  test('rustCoreServiceProvider provides a RustCoreService', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(rustCoreServiceProvider), isA<RustCoreService>());
  });
}
