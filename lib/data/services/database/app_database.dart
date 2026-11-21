import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fusionreflow/data/services/database/books_table.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// The app's SQLite database.
@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  /// Opens the database on the query executor [e].
  new(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(books, books.description);
        await m.addColumn(books, books.sourceSize);
      }
    },
  );
}

/// Provides the database; created on first use and closed on dispose.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase(driftDatabase(name: 'fusionreflow'));
  ref.onDispose(database.close);
  return database;
}
