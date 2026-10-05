// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI 번역 API 키 등록 상태 (NA-13). 값은 네이티브 Keystore에만 있고, 여기선 저장 여부(bool)만 다룬다.

@ProviderFor(ApiKeyViewModel)
final apiKeyViewModelProvider = ApiKeyViewModelProvider._();

/// AI 번역 API 키 등록 상태 (NA-13). 값은 네이티브 Keystore에만 있고, 여기선 저장 여부(bool)만 다룬다.
final class ApiKeyViewModelProvider
    extends $AsyncNotifierProvider<ApiKeyViewModel, bool> {
  /// AI 번역 API 키 등록 상태 (NA-13). 값은 네이티브 Keystore에만 있고, 여기선 저장 여부(bool)만 다룬다.
  ApiKeyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiKeyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiKeyViewModelHash();

  @$internal
  @override
  ApiKeyViewModel create() => ApiKeyViewModel();
}

String _$apiKeyViewModelHash() => r'368321c62044a2bbc97f30e6fa723210d7ad518f';

/// AI 번역 API 키 등록 상태 (NA-13). 값은 네이티브 Keystore에만 있고, 여기선 저장 여부(bool)만 다룬다.

abstract class _$ApiKeyViewModel extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
