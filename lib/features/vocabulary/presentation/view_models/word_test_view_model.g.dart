// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_test_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.

@ProviderFor(WordTestViewModel)
final wordTestViewModelProvider = WordTestViewModelFamily._();

/// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.
final class WordTestViewModelProvider
    extends $AsyncNotifierProvider<WordTestViewModel, WordTestState> {
  /// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.
  WordTestViewModelProvider._({
    required WordTestViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'wordTestViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordTestViewModelHash();

  @override
  String toString() {
    return r'wordTestViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WordTestViewModel create() => WordTestViewModel();

  @override
  bool operator ==(Object other) {
    return other is WordTestViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordTestViewModelHash() => r'a796d6bf1b84ce1bd3b0493a07dea32530d44a4f';

/// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.

final class WordTestViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WordTestViewModel,
          AsyncValue<WordTestState>,
          WordTestState,
          FutureOr<WordTestState>,
          int
        > {
  WordTestViewModelFamily._()
    : super(
        retry: null,
        name: r'wordTestViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.

  WordTestViewModelProvider call(int wordbookId) =>
      WordTestViewModelProvider._(argument: wordbookId, from: this);

  @override
  String toString() => r'wordTestViewModelProvider';
}

/// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.

abstract class _$WordTestViewModel extends $AsyncNotifier<WordTestState> {
  late final _$args = ref.$arg as int;
  int get wordbookId => _$args;

  FutureOr<WordTestState> build(int wordbookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WordTestState>, WordTestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WordTestState>, WordTestState>,
              AsyncValue<WordTestState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
