// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_picker_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [DocumentPickerService].

@ProviderFor(documentPickerService)
final documentPickerServiceProvider = DocumentPickerServiceProvider._();

/// Provides the [DocumentPickerService].

final class DocumentPickerServiceProvider
    extends
        $FunctionalProvider<
          DocumentPickerService,
          DocumentPickerService,
          DocumentPickerService
        >
    with $Provider<DocumentPickerService> {
  /// Provides the [DocumentPickerService].
  DocumentPickerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentPickerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentPickerServiceHash();

  @$internal
  @override
  $ProviderElement<DocumentPickerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentPickerService create(Ref ref) {
    return documentPickerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentPickerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentPickerService>(value),
    );
  }
}

String _$documentPickerServiceHash() =>
    r'3b916021e83fe32e560f7676fb7fefbfbcfec164';
