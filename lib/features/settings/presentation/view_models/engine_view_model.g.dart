// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// AI 엔진은 보류라 선택할 수 없다 ([selectable]).

@ProviderFor(EngineViewModel)
final engineViewModelProvider = EngineViewModelProvider._();

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// AI 엔진은 보류라 선택할 수 없다 ([selectable]).
final class EngineViewModelProvider
    extends $StreamNotifierProvider<EngineViewModel, EngineType> {
  /// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  /// AI 엔진은 보류라 선택할 수 없다 ([selectable]).
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

String _$engineViewModelHash() => r'e1eb531eae0a0c4a3bd69488ab79fb10536cab04';

/// 번역 엔진 선택 (FL-06). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// AI 엔진은 보류라 선택할 수 없다 ([selectable]).

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
