import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/data/services/database/app_database.dart';
import 'package:fusionreflow/domain/models/book_format.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('migrates v1 to v2', () async {
    final dir = Directory.systemTemp.createTempSync('db_v1_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    // Schema v1: the books table without `description` and `sourceSize`.
    final v1 = NativeDatabase(
      file,
      setup: (raw) {
        raw
          ..execute('''
CREATE TABLE books (
  id TEXT NOT NULL, title TEXT NOT NULL, authors TEXT NOT NULL,
  language TEXT NULL, format INTEGER NOT NULL, source_hash TEXT NOT NULL UNIQUE,
  converter_version TEXT NOT NULL, added_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, last_read_at INTEGER NULL,
  chapter INTEGER NOT NULL DEFAULT 0, "offset" INTEGER NOT NULL DEFAULT 0,
  progress REAL NOT NULL DEFAULT 0, deleted_at INTEGER NULL,
  PRIMARY KEY (id)
)''')
          ..execute(
            'INSERT INTO books (id, title, authors, format, source_hash, '
            'converter_version, added_at, updated_at, progress) VALUES '
            "('a', 'Old', '[\"X\"]', 1, 'h', 'v', 0, 0, 0.5)",
          )
          ..execute('PRAGMA user_version = 1');
      },
    );
    await v1.ensureOpen(_NoUser());
    await v1.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final rows = await db.select(db.books).get();

    expect(db.schemaVersion, 2);
    expect(rows.single.title, 'Old');
    expect(rows.single.format, BookFormat.epub);
    expect(rows.single.progress, 0.5);
    expect(rows.single.description, isNull);
    expect(rows.single.sourceSize, isNull);
  });
}

class _NoUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
