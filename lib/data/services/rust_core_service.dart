import 'dart:typed_data';

import 'package:fusionreflow/data/services/bridge_import_event.dart';
import 'package:fusionreflow/domain/models/book_format.dart';
import 'package:fusionreflow/domain/models/import_update.dart';
import 'package:fusionreflow/src/rust/api/book.dart' as rust_book;
import 'package:fusionreflow/src/rust/api/import.dart' as rust_import;
import 'package:fusionreflow/src/rust/api/text.dart' as rust_text;
import 'package:fusionreflow/src/rust/frb_generated.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rust_core_service.g.dart';

/// Thin, stateless wrapper over the Rust core bridge.
///
/// The only place in the app that talks to the generated bridge code
/// (`lib/src/rust/**`); repositories depend on this service instead.
class RustCoreService {
  /// Creates the service; `_load` loads the native library (injectable for
  /// tests).
  new({this._load = RustLib.init});

  final Future<void> Function() _load;
  Future<void>? _loading;

  /// Loads the native library; safe to call again (retry after a failed or
  /// timed-out start, tests that already initialised the bridge). Concurrent
  /// calls share one load, so the bridge is never initialised twice.
  Future<void> init() {
    if (RustLib.instance.initialized) return Future.value();
    return _loading ??= _load().catchError((Object error, StackTrace stack) {
      _loading = null; // let the next call retry
      Error.throwWithStackTrace(error, stack);
    });
  }

  /// Inserts soft hyphens (U+00AD) at allowed break points of ru/en words.
  String hyphenate(String text) => rust_text.hyphenate(text: text);

  /// Reads the catalog data (title, authors, hashes) of CBOR-encoded [bytes].
  ///
  /// Runs on the bridge's thread pool, so a large book does not block the UI.
  /// Bridge errors (`FormatError`) are not caught here.
  Future<rust_book.BookMeta> bookMeta(Uint8List bytes) =>
      rust_book.bookMeta(bytes: bytes);

  /// Converts the file behind [fd] (Rust takes ownership and closes it).
  /// The first event is `Started(jobId)`; the stream ends after `Done` or
  /// `Failed`.
  Stream<BridgeImportEvent> importBook(int fd, BookFormat format) =>
      rust_import.importBook(fd: fd, kind: _kindOf(format)).map(_eventOf);

  /// Asks the running import [jobId] to stop; unknown ids are ignored.
  Future<void> cancelImport(int jobId) =>
      rust_import.cancelImport(jobId: jobId);

  static BridgeImportEvent _eventOf(rust_import.ImportEvent event) =>
      switch (event) {
        rust_import.ImportEvent_Started(:final field0) => BridgeImportStarted(
          field0,
        ),
        rust_import.ImportEvent_Progress(:final field0) => BridgeImportProgress(
          done: field0.done,
          total: field0.total,
        ),
        rust_import.ImportEvent_Done(:final field0) => BridgeImportDone(field0),
        rust_import.ImportEvent_Failed(:final field0) => BridgeImportFailed(
          _failureOf(field0),
        ),
      };

  static ImportFailure _failureOf(rust_import.ImportError error) =>
      switch (error) {
        rust_import.ImportError_Unsupported(:final field0) =>
          field0 == rust_import.SourceKind.pdf
              ? ImportFailure.pdfNotYet
              : ImportFailure.unsupportedFormat,
        rust_import.ImportError_Cancelled() => ImportFailure.cancelled,
        rust_import.ImportError_Corrupted() ||
        rust_import.ImportError_NoTextLayer() ||
        rust_import.ImportError_OutOfMemory() => ImportFailure.unreadable,
      };

  static rust_import.SourceKind _kindOf(BookFormat format) => switch (format) {
    BookFormat.pdf => rust_import.SourceKind.pdf,
    BookFormat.epub => rust_import.SourceKind.epub,
    BookFormat.fb2 => rust_import.SourceKind.fb2,
    BookFormat.fb2Zip => rust_import.SourceKind.fb2Zip,
  };
}

/// Provides the [RustCoreService].
@Riverpod(keepAlive: true)
RustCoreService rustCoreService(Ref ref) => RustCoreService();
