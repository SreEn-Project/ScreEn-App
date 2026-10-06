// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'falling_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.

@ProviderFor(FallingViewModel)
final fallingViewModelProvider = FallingViewModelFamily._();

/// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.
final class FallingViewModelProvider
    extends $AsyncNotifierProvider<FallingViewModel, FallingState> {
  /// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.
  FallingViewModelProvider._({
    required FallingViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'fallingViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fallingViewModelHash();

  @override
  String toString() {
    return r'fallingViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FallingViewModel create() => FallingViewModel();

  @override
  bool operator ==(Object other) {
    return other is FallingViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fallingViewModelHash() => r'bbdeaa76bef33b290a1d0ea1c4f047038813ab3c';

/// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.

final class FallingViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          FallingViewModel,
          AsyncValue<FallingState>,
          FallingState,
          FutureOr<FallingState>,
          int
        > {
  FallingViewModelFamily._()
    : super(
        retry: null,
        name: r'fallingViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.

  FallingViewModelProvider call(int wordbookId) =>
      FallingViewModelProvider._(argument: wordbookId, from: this);

  @override
  String toString() => r'fallingViewModelProvider';
}

/// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.

abstract class _$FallingViewModel extends $AsyncNotifier<FallingState> {
  late final _$args = ref.$arg as int;
  int get wordbookId => _$args;

  FutureOr<FallingState> build(int wordbookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FallingState>, FallingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FallingState>, FallingState>,
              AsyncValue<FallingState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
