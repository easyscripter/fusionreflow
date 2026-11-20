import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/repositories/import_repository.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_source.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/ui/import/view_models/import_state.dart';
import 'package:fusionreflow/ui/import/view_models/import_view_model.dart';

import '../../../helpers/book_entry.dart';
import '../../../helpers/fake_book_repository.dart';
import '../../../helpers/fake_import_repository.dart';

const _source = ImportSource(
  uri: 'content://a',
  name: 'a.epub',
  format: BookFormat.epub,
);
final _bytes = Uint8List.fromList([1]);

void main() {
  late FakeBookRepository books;
  late FakeImportRepository imports;
  late ProviderContainer container;

  setUp(() {
    books = FakeBookRepository();
    imports = FakeImportRepository(picked: _source);
    container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWithValue(books),
        importRepositoryProvider.overrideWithValue(imports),
      ],
    )..listen(importViewModelProvider, (_, _) {});
    addTearDown(container.dispose);
  });

  ImportViewModel vm() => container.read(importViewModelProvider.notifier);
  ImportState state() => container.read(importViewModelProvider);

  Future<void> start() async {
    unawaited(vm().pickAndImport());
    await pumpEventQueue();
  }

  Future<void> send(ImportUpdate update) async {
    imports.current.add(update);
    await pumpEventQueue();
  }

  test('pick cancelled stays idle', () async {
    imports.picked = null;
    await vm().pickAndImport();
    expect(state(), const ImportState.idle());
    expect(imports.converted, isEmpty);
  });

  test('progress then added opens book', () async {
    await start();
    expect(state(), const ImportState.running(source: _source));
    await send(const ImportUpdate.progress(done: 1, total: 3));
    expect(
      state(),
      const ImportState.running(source: _source, done: 1, total: 3),
    );
    await send(ImportUpdate.converted(_bytes));
    expect(books.added, hasLength(1));
    expect(books.added.single.$2, BookFormat.epub);
    expect(state(), const ImportState.added(bookId: 'new'));
    vm().acknowledge();
    expect(state(), const ImportState.idle());
  });

  test('cancel does not add the book', () async {
    await start();
    await vm().cancel();
    expect(imports.cancelCalls, 1);
    await send(const ImportUpdate.failed(ImportFailure.cancelled));
    expect(
      state(),
      const ImportState.failed(
        source: _source,
        failure: ImportFailure.cancelled,
      ),
    );
    expect(books.added, isEmpty);
  });

  test('double cancel asks the repository once', () async {
    await start();
    await vm().cancel();
    await vm().cancel();
    expect(imports.cancelCalls, 1);
  });

  test('cancel outside running does nothing', () async {
    await vm().cancel();
    expect(imports.cancelCalls, 0);
  });

  test('converted after cancel is dropped', () async {
    await start();
    await vm().cancel();
    await send(const ImportUpdate.progress(done: 2, total: 3));
    expect(state(), const ImportState.running(source: _source));
    await send(ImportUpdate.converted(_bytes));
    expect(books.added, isEmpty);
    expect(
      state(),
      const ImportState.failed(
        source: _source,
        failure: ImportFailure.cancelled,
      ),
    );
  });

  test('same file again opens existing book', () async {
    final existing = bookEntry(id: 'id1');
    books
      ..emit([existing])
      ..addResult = existing;
    await start();
    await send(ImportUpdate.converted(_bytes));
    expect(state(), const ImportState.added(bookId: 'id1'));
    expect(books.books, [existing]);
  });

  test('pdf goes to pdfNotYet', () async {
    await start();
    await send(const ImportUpdate.failed(ImportFailure.pdfNotYet));
    expect(
      state(),
      const ImportState.failed(
        source: _source,
        failure: ImportFailure.pdfNotYet,
      ),
    );
    expect(books.added, isEmpty);
  });

  test('add error is unreadable', () async {
    books.addError = const BookFormatException('bad');
    await start();
    await send(ImportUpdate.converted(_bytes));
    expect((state() as ImportFailedState).failure, ImportFailure.unreadable);
  });

  test('converted for a source without format is unsupported', () async {
    imports.picked = const ImportSource(uri: 'u', name: 'a.docx');
    await start();
    await send(ImportUpdate.converted(_bytes));
    expect(
      (state() as ImportFailedState).failure,
      ImportFailure.unsupportedFormat,
    );
  });

  test('stream closed without result is unreadable', () async {
    await start();
    await imports.current.close();
    await pumpEventQueue();
    expect((state() as ImportFailedState).failure, ImportFailure.unreadable);
  });

  test('second pick while running is ignored', () async {
    await start();
    await vm().pickAndImport();
    expect(imports.pickCalls, 1);
  });

  test('retry reuses source', () async {
    await start();
    await send(const ImportUpdate.failed(ImportFailure.cancelled));
    unawaited(vm().retry());
    await pumpEventQueue();
    expect(imports.converted, [_source, _source]);
    expect(imports.pickCalls, 1);
    expect(state(), const ImportState.running(source: _source));
  });

  test('retry outside failed does nothing', () async {
    await vm().retry();
    expect(imports.converted, isEmpty);
  });

  test('dismiss returns failed to idle and ignores other states', () async {
    vm().dismiss();
    expect(state(), const ImportState.idle());
    await start();
    vm().dismiss();
    expect(state(), isA<ImportRunning>());
    await send(const ImportUpdate.failed(ImportFailure.unreadable));
    vm().dismiss();
    expect(state(), const ImportState.idle());
  });

  test('acknowledge ignores non-added states', () async {
    await start();
    vm().acknowledge();
    expect(state(), isA<ImportRunning>());
  });

  test('convert throwing an unexpected error ends in unreadable', () async {
    imports.convertError = StateError('bridge is not initialised');
    await vm().pickAndImport();
    expect((state() as ImportFailedState).failure, ImportFailure.unreadable);
  });

  test('stream error from the repository ends in unreadable', () async {
    await start();
    imports.current.addError(StateError('boom'));
    await pumpEventQueue();
    expect((state() as ImportFailedState).failure, ImportFailure.unreadable);
  });

  test('pick error returns to idle and allows another try', () async {
    imports.pickError = PlatformException(code: 'busy');
    await vm().pickAndImport();
    expect(state(), const ImportState.idle());

    imports.pickError = null;
    await start();
    expect(state(), isA<ImportRunning>());
  });

  test('second pick while the picker is open is ignored', () async {
    final gate = Completer<ImportSource?>();
    imports.pickGate = gate;
    final first = vm().pickAndImport();
    await pumpEventQueue();
    await vm().pickAndImport();
    expect(imports.pickCalls, 1);

    gate.complete(null);
    await first;
    await vm().pickAndImport();
    expect(imports.pickCalls, 2);
  });
}
