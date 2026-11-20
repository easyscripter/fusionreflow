// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Готовность приложения: мост Rust инициализирован, хранилище книг открыто
/// (база открыта, уборка сирот прошла). Ошибки не глотаются.

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// Готовность приложения: мост Rust инициализирован, хранилище книг открыто
/// (база открыта, уборка сирот прошла). Ошибки не глотаются.

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Готовность приложения: мост Rust инициализирован, хранилище книг открыто
  /// (база открыта, уборка сирот прошла). Ошибки не глотаются.
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: noRetry,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appStartup(ref);
  }
}

String _$appStartupHash() => r'bbb99ddd660c45712cb8247817c11ef92631e265';
