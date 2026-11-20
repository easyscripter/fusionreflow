// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [ImportRepository].

@ProviderFor(importRepository)
final importRepositoryProvider = ImportRepositoryProvider._();

/// Provides the [ImportRepository].

final class ImportRepositoryProvider
    extends
        $FunctionalProvider<
          ImportRepository,
          ImportRepository,
          ImportRepository
        >
    with $Provider<ImportRepository> {
  /// Provides the [ImportRepository].
  ImportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImportRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImportRepository create(Ref ref) {
    return importRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportRepository>(value),
    );
  }
}

String _$importRepositoryHash() => r'b0bf05d2fec566fe6f54e002820fb847625329b9';
