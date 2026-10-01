// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_languages_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 플로팅 버튼 "빠른 언어" 목록 편집 (FL-04). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

@ProviderFor(QuickLanguagesViewModel)
final quickLanguagesViewModelProvider = QuickLanguagesViewModelProvider._();

/// 플로팅 버튼 "빠른 언어" 목록 편집 (FL-04). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
final class QuickLanguagesViewModelProvider
    extends $StreamNotifierProvider<QuickLanguagesViewModel, List<String>> {
  /// 플로팅 버튼 "빠른 언어" 목록 편집 (FL-04). 네이티브 설정(DataStore)이 원본이라
  /// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  QuickLanguagesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickLanguagesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickLanguagesViewModelHash();

  @$internal
  @override
  QuickLanguagesViewModel create() => QuickLanguagesViewModel();
}

String _$quickLanguagesViewModelHash() =>
    r'af1000ae714b2bd185b822f9d990608858dc9f3e';

/// 플로팅 버튼 "빠른 언어" 목록 편집 (FL-04). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

abstract class _$QuickLanguagesViewModel extends $StreamNotifier<List<String>> {
  Stream<List<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
