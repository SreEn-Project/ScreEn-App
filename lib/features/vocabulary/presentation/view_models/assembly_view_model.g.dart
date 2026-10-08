// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assembly_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.

@ProviderFor(AssemblyViewModel)
final assemblyViewModelProvider = AssemblyViewModelFamily._();

/// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.
final class AssemblyViewModelProvider
    extends $AsyncNotifierProvider<AssemblyViewModel, AssemblyState> {
  /// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.
  AssemblyViewModelProvider._({
    required AssemblyViewModelFamily super.from,
    required WordbookSelection super.argument,
  }) : super(
         retry: null,
         name: r'assemblyViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assemblyViewModelHash();

  @override
  String toString() {
    return r'assemblyViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AssemblyViewModel create() => AssemblyViewModel();

  @override
  bool operator ==(Object other) {
    return other is AssemblyViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assemblyViewModelHash() => r'48bbb03a18ee4ee937ee208f54bb2a545050c97f';

/// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.

final class AssemblyViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          AssemblyViewModel,
          AsyncValue<AssemblyState>,
          AssemblyState,
          FutureOr<AssemblyState>,
          WordbookSelection
        > {
  AssemblyViewModelFamily._()
    : super(
        retry: null,
        name: r'assemblyViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.

  AssemblyViewModelProvider call(WordbookSelection selection) =>
      AssemblyViewModelProvider._(argument: selection, from: this);

  @override
  String toString() => r'assemblyViewModelProvider';
}

/// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.

abstract class _$AssemblyViewModel extends $AsyncNotifier<AssemblyState> {
  late final _$args = ref.$arg as WordbookSelection;
  WordbookSelection get selection => _$args;

  FutureOr<AssemblyState> build(WordbookSelection selection);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AssemblyState>, AssemblyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AssemblyState>, AssemblyState>,
              AsyncValue<AssemblyState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
