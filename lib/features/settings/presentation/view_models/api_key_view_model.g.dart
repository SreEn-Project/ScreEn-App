// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

@ProviderFor(ApiKeyViewModel)
final apiKeyViewModelProvider = ApiKeyViewModelFamily._();

/// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
final class ApiKeyViewModelProvider
    extends $AsyncNotifierProvider<ApiKeyViewModel, String?> {
  /// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
  /// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.
  ApiKeyViewModelProvider._({
    required ApiKeyViewModelFamily super.from,
    required EngineType super.argument,
  }) : super(
         retry: null,
         name: r'apiKeyViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$apiKeyViewModelHash();

  @override
  String toString() {
    return r'apiKeyViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ApiKeyViewModel create() => ApiKeyViewModel();

  @override
  bool operator ==(Object other) {
    return other is ApiKeyViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$apiKeyViewModelHash() => r'd1f31032e47761612eb9c292128e638809d171fe';

/// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

final class ApiKeyViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ApiKeyViewModel,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          EngineType
        > {
  ApiKeyViewModelFamily._()
    : super(
        retry: null,
        name: r'apiKeyViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
  /// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

  ApiKeyViewModelProvider call(EngineType engine) =>
      ApiKeyViewModelProvider._(argument: engine, from: this);

  @override
  String toString() => r'apiKeyViewModelProvider';
}

/// 엔진([engine])별로 저장된 AI 번역 API 키 (NA-13). 없으면 null. 원본은 네이티브 Keystore 저장소다.
/// 화면은 이 값을 가려서 보여 주고, 눌러서 볼 수 있게 한다.

abstract class _$ApiKeyViewModel extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as EngineType;
  EngineType get engine => _$args;

  FutureOr<String?> build(EngineType engine);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
