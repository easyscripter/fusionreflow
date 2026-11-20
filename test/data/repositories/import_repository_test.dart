import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/import_repository.dart';
import 'package:fusionreflow/data/services/bridge_import_event.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';

import '../../helpers/fake_document_picker_service.dart';
import '../../helpers/fake_rust_core_service.dart';

const _epub = ImportSource(
  uri: 'content://a',
  name: 'a.epub',
  format: BookFormat.epub,
);

void main() {
  late FakeDocumentPickerService picker;
  late FakeRustCoreService rustFake;
  late BridgeImportRepository repo;

  setUp(() {
    picker = FakeDocumentPickerService();
    rustFake = FakeRustCoreService();
    repo = BridgeImportRepository(picker: picker, rust: rustFake);
  });

  Future<List<ImportUpdate>> run(
    void Function(StreamController<BridgeImportEvent>) feed, [
    ImportSource source = _epub,
  ]) async {
    final future = repo.convert(source).toList();
    await pumpEventQueue();
    feed(rustFake.importEvents);
    return await future;
  }

  test('pick maps the file and detects its format', () async {
    expect(await repo.pick(), isNull);
    picker.picked = (uri: 'u', name: 'b.FB2.zip', size: 5);
    expect(
      await repo.pick(),
      const ImportSource(
        uri: 'u',
        name: 'b.FB2.zip',
        format: BookFormat.fb2Zip,
        sizeBytes: 5,
      ),
    );
  });

  test('unknown format fails without bridge', () async {
    final updates = await repo
        .convert(const ImportSource(uri: 'u', name: 'a.docx'))
        .toList();
    expect(updates, [
      const ImportUpdate.failed(ImportFailure.unsupportedFormat),
    ]);
    expect(picker.opened, isEmpty);
    expect(rustFake.importCalls, isEmpty);
  });

  test('openFd error is noAccess', () async {
    picker.openFdError = PlatformException(code: 'gone');
    final updates = await repo.convert(_epub).toList();
    expect(updates, [const ImportUpdate.failed(ImportFailure.noAccess)]);
    expect(rustFake.importCalls, isEmpty);
  });

  test('events map to updates', () async {
    final bytes = Uint8List.fromList([1]);
    final updates = await run((c) {
      c
        ..add(const BridgeImportStarted(7))
        ..add(const BridgeImportProgress(done: 1, total: 3))
        ..add(BridgeImportDone(bytes));
      unawaited(c.close());
    });
    expect(updates, [
      const ImportUpdate.progress(done: 1, total: 3),
      ImportUpdate.converted(bytes),
    ]);
    expect(rustFake.importCalls, [(42, BookFormat.epub)]);
  });

  test('bridge failure becomes a failed update', () async {
    final updates = await run(
      (c) => c.add(const BridgeImportFailed(ImportFailure.pdfNotYet)),
    );
    expect(updates, [const ImportUpdate.failed(ImportFailure.pdfNotYet)]);
  });

  test('stream error ends with unreadable', () async {
    final updates = await run((c) => c.addError(AnyhowException('x')));
    expect(updates.last, const ImportUpdate.failed(ImportFailure.unreadable));
  });

  test('stream closed without a final event is unreadable', () async {
    final updates = await run((c) => c.close());
    expect(updates, [const ImportUpdate.failed(ImportFailure.unreadable)]);
  });

  test('cancel before Started is sent after it', () async {
    final future = repo.convert(_epub).toList();
    await pumpEventQueue();
    await repo.cancel();
    expect(rustFake.cancelled, isEmpty);
    rustFake.importEvents
      ..add(const BridgeImportStarted(7))
      ..add(const BridgeImportFailed(ImportFailure.cancelled));
    await future;
    expect(rustFake.cancelled, [7]);
  });

  test('cancel after Started goes to the bridge at once', () async {
    final future = repo.convert(_epub).toList();
    await pumpEventQueue();
    rustFake.importEvents.add(const BridgeImportStarted(7));
    await pumpEventQueue();
    await repo.cancel();
    expect(rustFake.cancelled, [7]);
    rustFake.importEvents.add(
      const BridgeImportFailed(ImportFailure.cancelled),
    );
    await future;
  });

  test('cancel without import is a no-op', () async {
    await repo.cancel();
    expect(rustFake.cancelled, isEmpty);
  });

  test('cancel after the import finished is a no-op', () async {
    await run((c) => c.add(const BridgeImportFailed(ImportFailure.cancelled)));
    await repo.cancel();
    expect(rustFake.cancelled, isEmpty);
  });
}
