// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordbooks_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 단어장 목록 (AD-04): 만들기 · 이름 변경 · 삭제.
/// 오버레이에서 단어를 저장해도 이 화면은 열릴 때 다시 읽는다 ([refresh]).

@ProviderFor(WordbooksViewModel)
final wordbooksViewModelProvider = WordbooksViewModelProvider._();

/// 단어장 목록 (AD-04): 만들기 · 이름 변경 · 삭제.
/// 오버레이에서 단어를 저장해도 이 화면은 열릴 때 다시 읽는다 ([refresh]).
final class WordbooksViewModelProvider
    extends $AsyncNotifierProvider<WordbooksViewModel, List<Wordbook>> {
  /// 단어장 목록 (AD-04): 만들기 · 이름 변경 · 삭제.
  /// 오버레이에서 단어를 저장해도 이 화면은 열릴 때 다시 읽는다 ([refresh]).
  WordbooksViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordbooksViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordbooksViewModelHash();

  @$internal
  @override
  WordbooksViewModel create() => WordbooksViewModel();
}

String _$wordbooksViewModelHash() =>
    r'd15daeccb245a41cc2f322b6aa90f39a1120b2d3';

/// 단어장 목록 (AD-04): 만들기 · 이름 변경 · 삭제.
/// 오버레이에서 단어를 저장해도 이 화면은 열릴 때 다시 읽는다 ([refresh]).

abstract class _$WordbooksViewModel extends $AsyncNotifier<List<Wordbook>> {
  FutureOr<List<Wordbook>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Wordbook>>, List<Wordbook>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Wordbook>>, List<Wordbook>>,
              AsyncValue<List<Wordbook>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
