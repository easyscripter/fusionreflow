// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_paginator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Splits chapters into pages (replaceable in tests).

@ProviderFor(flowPaginator)
final flowPaginatorProvider = FlowPaginatorProvider._();

/// Splits chapters into pages (replaceable in tests).

final class FlowPaginatorProvider
    extends $FunctionalProvider<FlowPaginator, FlowPaginator, FlowPaginator>
    with $Provider<FlowPaginator> {
  /// Splits chapters into pages (replaceable in tests).
  FlowPaginatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flowPaginatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flowPaginatorHash();

  @$internal
  @override
  $ProviderElement<FlowPaginator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlowPaginator create(Ref ref) {
    return flowPaginator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlowPaginator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlowPaginator>(value),
    );
  }
}

String _$flowPaginatorHash() => r'9984739bc83f427a372792a7c8a314508e6854b9';
