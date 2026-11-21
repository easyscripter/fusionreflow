// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_details_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Book [bookId] for the card; null when it is missing or deleted.

@ProviderFor(bookDetailsViewModel)
final bookDetailsViewModelProvider = BookDetailsViewModelFamily._();

/// Book [bookId] for the card; null when it is missing or deleted.

final class BookDetailsViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookEntry?>,
          BookEntry?,
          Stream<BookEntry?>
        >
    with $FutureModifier<BookEntry?>, $StreamProvider<BookEntry?> {
  /// Book [bookId] for the card; null when it is missing or deleted.
  BookDetailsViewModelProvider._({
    required BookDetailsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookDetailsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookDetailsViewModelHash();

  @override
  String toString() {
    return r'bookDetailsViewModelProvider'
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
    return bookDetailsViewModel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookDetailsViewModelHash() =>
    r'1bb9144d50dc51367d9766d1703de040c5061728';

/// Book [bookId] for the card; null when it is missing or deleted.

final class BookDetailsViewModelFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BookEntry?>, String> {
  BookDetailsViewModelFamily._()
    : super(
        retry: null,
        name: r'bookDetailsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Book [bookId] for the card; null when it is missing or deleted.

  BookDetailsViewModelProvider call(String bookId) =>
      BookDetailsViewModelProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookDetailsViewModelProvider';
}
