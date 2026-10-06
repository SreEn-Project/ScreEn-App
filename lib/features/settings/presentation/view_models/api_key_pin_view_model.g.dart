// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_pin_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ApiKeyPinViewModel)
final apiKeyPinViewModelProvider = ApiKeyPinViewModelProvider._();

final class ApiKeyPinViewModelProvider
    extends $AsyncNotifierProvider<ApiKeyPinViewModel, ApiKeyPinState> {
  ApiKeyPinViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiKeyPinViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiKeyPinViewModelHash();

  @$internal
  @override
  ApiKeyPinViewModel create() => ApiKeyPinViewModel();
}

String _$apiKeyPinViewModelHash() =>
    r'2ed149f2771c16645c18b81ebaf671809bff99a7';

abstract class _$ApiKeyPinViewModel extends $AsyncNotifier<ApiKeyPinState> {
  FutureOr<ApiKeyPinState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ApiKeyPinState>, ApiKeyPinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ApiKeyPinState>, ApiKeyPinState>,
              AsyncValue<ApiKeyPinState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
