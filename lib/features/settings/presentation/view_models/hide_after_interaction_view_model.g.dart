// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hide_after_interaction_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 조작 뒤 이전 번역 숨김 시간 (ms, #35). 자동 번역과 무관하게 덮어쓰기 결과에 적용된다.
/// 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

@ProviderFor(HideAfterInteractionViewModel)
final hideAfterInteractionViewModelProvider =
    HideAfterInteractionViewModelProvider._();

/// 조작 뒤 이전 번역 숨김 시간 (ms, #35). 자동 번역과 무관하게 덮어쓰기 결과에 적용된다.
/// 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
final class HideAfterInteractionViewModelProvider
    extends $StreamNotifierProvider<HideAfterInteractionViewModel, int> {
  /// 조작 뒤 이전 번역 숨김 시간 (ms, #35). 자동 번역과 무관하게 덮어쓰기 결과에 적용된다.
  /// 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  HideAfterInteractionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hideAfterInteractionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hideAfterInteractionViewModelHash();

  @$internal
  @override
  HideAfterInteractionViewModel create() => HideAfterInteractionViewModel();
}

String _$hideAfterInteractionViewModelHash() =>
    r'9bd83c90d02f7d731c2c1dd2de71ce6374ff889e';

/// 조작 뒤 이전 번역 숨김 시간 (ms, #35). 자동 번역과 무관하게 덮어쓰기 결과에 적용된다.
/// 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

abstract class _$HideAfterInteractionViewModel extends $StreamNotifier<int> {
  Stream<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
