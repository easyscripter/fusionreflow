// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Книги библиотеки в выбранном порядке и книга для «Продолжить чтение».

@ProviderFor(LibraryViewModel)
final libraryViewModelProvider = LibraryViewModelProvider._();

/// Книги библиотеки в выбранном порядке и книга для «Продолжить чтение».
final class LibraryViewModelProvider
    extends $StreamNotifierProvider<LibraryViewModel, LibraryState> {
  /// Книги библиотеки в выбранном порядке и книга для «Продолжить чтение».
  LibraryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'libraryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryViewModelHash();

  @$internal
  @override
  LibraryViewModel create() => LibraryViewModel();
}

String _$libraryViewModelHash() => r'd801dd39f061082daab2dc9d4f1a7dfcf03fd59c';

/// Книги библиотеки в выбранном порядке и книга для «Продолжить чтение».

abstract class _$LibraryViewModel extends $StreamNotifier<LibraryState> {
  Stream<LibraryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LibraryState>, LibraryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LibraryState>, LibraryState>,
              AsyncValue<LibraryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
