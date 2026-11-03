// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// Gemini · Groq는 만 18세 확인(FL-09)과 API 키(NA-13)가 있어야, Gemma는 모델을 받아 둬야 고를 수 있다.

@ProviderFor(EngineViewModel)
final engineViewModelProvider = EngineViewModelProvider._();

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// Gemini · Groq는 만 18세 확인(FL-09)과 API 키(NA-13)가 있어야, Gemma는 모델을 받아 둬야 고를 수 있다.
final class EngineViewModelProvider
    extends $StreamNotifierProvider<EngineViewModel, EngineType> {
  /// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  /// Gemini · Groq는 만 18세 확인(FL-09)과 API 키(NA-13)가 있어야, Gemma는 모델을 받아 둬야 고를 수 있다.
  EngineViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineViewModelHash();

  @$internal
  @override
  EngineViewModel create() => EngineViewModel();
}

String _$engineViewModelHash() => r'83035e1b13be1eec0f4b7e7df4210436ea0149be';

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// Gemini · Groq는 만 18세 확인(FL-09)과 API 키(NA-13)가 있어야, Gemma는 모델을 받아 둬야 고를 수 있다.

abstract class _$EngineViewModel extends $StreamNotifier<EngineType> {
  Stream<EngineType> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EngineType>, EngineType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EngineType>, EngineType>,
              AsyncValue<EngineType>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
