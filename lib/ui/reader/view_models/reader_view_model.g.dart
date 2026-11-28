// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reading of book [bookId]: opens it at the saved position, lays out the
/// current chapter and its neighbours, turns pages and saves the place.

@ProviderFor(ReaderViewModel)
final readerViewModelProvider = ReaderViewModelFamily._();

/// Reading of book [bookId]: opens it at the saved position, lays out the
/// current chapter and its neighbours, turns pages and saves the place.
final class ReaderViewModelProvider
    extends $AsyncNotifierProvider<ReaderViewModel, ReaderState> {
  /// Reading of book [bookId]: opens it at the saved position, lays out the
  /// current chapter and its neighbours, turns pages and saves the place.
  ReaderViewModelProvider._({
    required ReaderViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'readerViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerViewModelHash();

  @override
  String toString() {
    return r'readerViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReaderViewModel create() => ReaderViewModel();

  @override
  bool operator ==(Object other) {
    return other is ReaderViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerViewModelHash() => r'0f5d4ee171ad6eba56e8e03ef088a97dcedc5e6e';

/// Reading of book [bookId]: opens it at the saved position, lays out the
/// current chapter and its neighbours, turns pages and saves the place.

final class ReaderViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ReaderViewModel,
          AsyncValue<ReaderState>,
          ReaderState,
          FutureOr<ReaderState>,
          String
        > {
  ReaderViewModelFamily._()
    : super(
        retry: noRetry,
        name: r'readerViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reading of book [bookId]: opens it at the saved position, lays out the
  /// current chapter and its neighbours, turns pages and saves the place.

  ReaderViewModelProvider call(String bookId) =>
      ReaderViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readerViewModelProvider';
}

/// Reading of book [bookId]: opens it at the saved position, lays out the
/// current chapter and its neighbours, turns pages and saves the place.

abstract class _$ReaderViewModel extends $AsyncNotifier<ReaderState> {
  late final _$args = ref.$arg as String;
  String get bookId => _$args;

  FutureOr<ReaderState> build(String bookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReaderState>, ReaderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReaderState>, ReaderState>,
              AsyncValue<ReaderState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
