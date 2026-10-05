// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

@ProviderFor(ApiKeyViewModel)
final apiKeyViewModelProvider = ApiKeyViewModelProvider._();

/// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
final class ApiKeyViewModelProvider
    extends $AsyncNotifierProvider<ApiKeyViewModel, String?> {
  /// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
  /// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
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

String _$apiKeyViewModelHash() => r'79b94b5fbcdd188544505ebf71df965f596c79c7';

/// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

abstract class _$ApiKeyViewModel extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
