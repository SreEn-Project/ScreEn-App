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
    r'9068679012fef5ff68980b163574fef230822c03';

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
