// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_placeholder_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Книга [bookId] из библиотеки; null, если её нет (или удалена).

@ProviderFor(readerPlaceholderViewModel)
final readerPlaceholderViewModelProvider = ReaderPlaceholderViewModelFamily._();

/// Книга [bookId] из библиотеки; null, если её нет (или удалена).

final class ReaderPlaceholderViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookEntry?>,
          BookEntry?,
          Stream<BookEntry?>
        >
    with $FutureModifier<BookEntry?>, $StreamProvider<BookEntry?> {
  /// Книга [bookId] из библиотеки; null, если её нет (или удалена).
  ReaderPlaceholderViewModelProvider._({
    required ReaderPlaceholderViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readerPlaceholderViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerPlaceholderViewModelHash();

  @override
  String toString() {
    return r'readerPlaceholderViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BookEntry?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BookEntry?> create(Ref ref) {
    final argument = this.argument as String;
    return readerPlaceholderViewModel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderPlaceholderViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerPlaceholderViewModelHash() =>
    r'de9a9968cd9b465abafb237ca25656526d57ce5f';

/// Книга [bookId] из библиотеки; null, если её нет (или удалена).

final class ReaderPlaceholderViewModelFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BookEntry?>, String> {
  ReaderPlaceholderViewModelFamily._()
    : super(
        retry: null,
        name: r'readerPlaceholderViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Книга [bookId] из библиотеки; null, если её нет (или удалена).

  ReaderPlaceholderViewModelProvider call(String bookId) =>
      ReaderPlaceholderViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readerPlaceholderViewModelProvider';
}
