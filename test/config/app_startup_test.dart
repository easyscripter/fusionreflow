import 'dart:typed_data';

import 'package:flow_render/flow_render.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/config/app_startup.dart';
import 'package:fusionreflow/data/repositories/book_repository.dart';
import 'package:fusionreflow/data/services/rust_core_service.dart';
import 'package:fusionreflow/domain/models/book_entry.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/reading_position.dart';

import '../helpers/fake_rust_core_service.dart';

class _FakeBookRepository implements BookRepository {
  new(this.log, {this.error});

  final List<String> log;
  final Exception? error;

  @override
  Stream<List<BookEntry>> watchAll() async* {
    log.add('repo.watchAll');
    final failure = error;
    if (failure != null) throw failure;
    yield const [];
  }

  @override
  Stream<BookEntry?> watch(String id) => throw UnimplementedError();

  @override
  Future<FlowBook> open(String id) => throw UnimplementedError();

  @override
  Future<BookEntry> add(
    Uint8List bytes,
    BookFormat format, {
    int? sourceSize,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List> load(String id) => throw UnimplementedError();

  @override
  Future<void> savePosition(
    String id,
    ReadingPosition position,
    double progress,
  ) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

ProviderContainer _container(
  List<String> log, {
  Exception? rustError,
  Exception? repoError,
}) {
  final container = ProviderContainer(
    overrides: [
      rustCoreServiceProvider.overrideWithValue(
        FakeRustCoreService(log: log, initError: rustError),
      ),
      bookRepositoryProvider.overrideWithValue(
        _FakeBookRepository(log, error: repoError),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('inits rust then opens repository', () async {
    final log = <String>[];
    final container = _container(log);

    await container.read(appStartupProvider.future);

    expect(log, ['rust.init', 'repo.watchAll']);
    expect(container.read(appStartupProvider), isA<AsyncData<void>>());
  });

  test('rust failure is an error', () async {
    final log = <String>[];
    final container = _container(log, rustError: Exception('no bridge'));

    await expectLater(
      container.read(appStartupProvider.future),
      throwsException,
    );

    expect(container.read(appStartupProvider), isA<AsyncError<void>>());
    expect(log, ['rust.init']);
  });

  test('repository failure is an error', () async {
    final container = _container([], repoError: Exception('no db'));

    await expectLater(
      container.read(appStartupProvider.future),
      throwsException,
    );

    expect(container.read(appStartupProvider), isA<AsyncError<void>>());
  });
}
