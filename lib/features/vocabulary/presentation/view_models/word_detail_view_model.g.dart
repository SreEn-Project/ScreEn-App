// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.

@ProviderFor(WordDetailViewModel)
final wordDetailViewModelProvider = WordDetailViewModelFamily._();

/// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.
final class WordDetailViewModelProvider
    extends $AsyncNotifierProvider<WordDetailViewModel, VocabularyWord?> {
  /// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.
  WordDetailViewModelProvider._({
    required WordDetailViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDetailViewModelHash();

  @override
  String toString() {
    return r'wordDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WordDetailViewModel create() => WordDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is WordDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDetailViewModelHash() =>
    r'15b46ff42b6697df1991585d5d918ac027b0196d';

/// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.

final class WordDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WordDetailViewModel,
          AsyncValue<VocabularyWord?>,
          VocabularyWord?,
          FutureOr<VocabularyWord?>,
          int
        > {
  WordDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'wordDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.

  WordDetailViewModelProvider call(int id) =>
      WordDetailViewModelProvider._(argument: id, from: this);

  @override
  String toString() => r'wordDetailViewModelProvider';
}

/// 단어 상세 (AD-06). 단어가 없으면(이미 지워짐) null.

abstract class _$WordDetailViewModel extends $AsyncNotifier<VocabularyWord?> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<VocabularyWord?> build(int id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VocabularyWord?>, VocabularyWord?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VocabularyWord?>, VocabularyWord?>,
              AsyncValue<VocabularyWord?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 단어가 들어 있는 단어장마다의 진도 (외움 · 정답률).

@ProviderFor(wordProgress)
final wordProgressProvider = WordProgressFamily._();

/// 단어가 들어 있는 단어장마다의 진도 (외움 · 정답률).

final class WordProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordbookProgress>>,
          List<WordbookProgress>,
          FutureOr<List<WordbookProgress>>
        >
    with
        $FutureModifier<List<WordbookProgress>>,
        $FutureProvider<List<WordbookProgress>> {
  /// 단어가 들어 있는 단어장마다의 진도 (외움 · 정답률).
  WordProgressProvider._({
    required WordProgressFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'wordProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordProgressHash();

  @override
  String toString() {
    return r'wordProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WordbookProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WordbookProgress>> create(Ref ref) {
    final argument = this.argument as int;
    return wordProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordProgressHash() => r'3a94a21399145011588431d81d137fdda65023c8';

/// 단어가 들어 있는 단어장마다의 진도 (외움 · 정답률).

final class WordProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WordbookProgress>>, int> {
  WordProgressFamily._()
    : super(
        retry: null,
        name: r'wordProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 단어가 들어 있는 단어장마다의 진도 (외움 · 정답률).

  WordProgressProvider call(int id) =>
      WordProgressProvider._(argument: id, from: this);

  @override
  String toString() => r'wordProgressProvider';
}
