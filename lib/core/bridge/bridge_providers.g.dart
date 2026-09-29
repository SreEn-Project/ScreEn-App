// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsHostApi)
final settingsHostApiProvider = SettingsHostApiProvider._();

final class SettingsHostApiProvider
    extends
        $FunctionalProvider<SettingsHostApi, SettingsHostApi, SettingsHostApi>
    with $Provider<SettingsHostApi> {
  SettingsHostApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsHostApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHostApiHash();

  @$internal
  @override
  $ProviderElement<SettingsHostApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsHostApi create(Ref ref) {
    return settingsHostApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsHostApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsHostApi>(value),
    );
  }
}

String _$settingsHostApiHash() => r'2c989c476891ac41726a7c31f21222e24e91f586';

@ProviderFor(serviceHostApi)
final serviceHostApiProvider = ServiceHostApiProvider._();

final class ServiceHostApiProvider
    extends $FunctionalProvider<ServiceHostApi, ServiceHostApi, ServiceHostApi>
    with $Provider<ServiceHostApi> {
  ServiceHostApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceHostApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceHostApiHash();

  @$internal
  @override
  $ProviderElement<ServiceHostApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceHostApi create(Ref ref) {
    return serviceHostApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceHostApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceHostApi>(value),
    );
  }
}

String _$serviceHostApiHash() => r'b0e69ee2648a9a1235f2ed157cc50404cfce58f8';

@ProviderFor(translatorEventBus)
final translatorEventBusProvider = TranslatorEventBusProvider._();

final class TranslatorEventBusProvider
    extends
        $FunctionalProvider<
          TranslatorEventBus,
          TranslatorEventBus,
          TranslatorEventBus
        >
    with $Provider<TranslatorEventBus> {
  TranslatorEventBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'translatorEventBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$translatorEventBusHash();

  @$internal
  @override
  $ProviderElement<TranslatorEventBus> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TranslatorEventBus create(Ref ref) {
    return translatorEventBus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranslatorEventBus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranslatorEventBus>(value),
    );
  }
}

String _$translatorEventBusHash() =>
    r'1c5ad2859887c02523e3350d61476bfd38b5aa11';
