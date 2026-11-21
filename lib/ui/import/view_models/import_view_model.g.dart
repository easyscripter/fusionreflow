// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Импорт одной книги; не прерывается при смене вкладки (keepAlive).

@ProviderFor(ImportViewModel)
final importViewModelProvider = ImportViewModelProvider._();

/// Импорт одной книги; не прерывается при смене вкладки (keepAlive).
final class ImportViewModelProvider
    extends $NotifierProvider<ImportViewModel, ImportState> {
  /// Импорт одной книги; не прерывается при смене вкладки (keepAlive).
  ImportViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importViewModelHash();

  @$internal
  @override
  ImportViewModel create() => ImportViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportState>(value),
    );
  }
}

String _$importViewModelHash() => r'30dbffff6034155d7a52672f76d09eee4fb044c6';

/// Импорт одной книги; не прерывается при смене вкладки (keepAlive).

abstract class _$ImportViewModel extends $Notifier<ImportState> {
  ImportState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ImportState, ImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportState, ImportState>,
              ImportState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
