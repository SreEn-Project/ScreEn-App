// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_match_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 선 잇기 매칭 (AD-11).

@ProviderFor(LineMatchViewModel)
final lineMatchViewModelProvider = LineMatchViewModelFamily._();

/// 선 잇기 매칭 (AD-11).
final class LineMatchViewModelProvider
    extends $AsyncNotifierProvider<LineMatchViewModel, LineMatchState> {
  /// 선 잇기 매칭 (AD-11).
  LineMatchViewModelProvider._({
    required LineMatchViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineMatchViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineMatchViewModelHash();

  @override
  String toString() {
    return r'lineMatchViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LineMatchViewModel create() => LineMatchViewModel();

  @override
  bool operator ==(Object other) {
    return other is LineMatchViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineMatchViewModelHash() =>
    r'288c2e5ea228705225e0e80d46fab26e60c2be0b';

/// 선 잇기 매칭 (AD-11).

final class LineMatchViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          LineMatchViewModel,
          AsyncValue<LineMatchState>,
          LineMatchState,
          FutureOr<LineMatchState>,
          int
        > {
  LineMatchViewModelFamily._()
    : super(
        retry: null,
        name: r'lineMatchViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 선 잇기 매칭 (AD-11).

  LineMatchViewModelProvider call(int wordbookId) =>
      LineMatchViewModelProvider._(argument: wordbookId, from: this);

  @override
  String toString() => r'lineMatchViewModelProvider';
}

/// 선 잇기 매칭 (AD-11).

abstract class _$LineMatchViewModel extends $AsyncNotifier<LineMatchState> {
  late final _$args = ref.$arg as int;
  int get wordbookId => _$args;

  FutureOr<LineMatchState> build(int wordbookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LineMatchState>, LineMatchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LineMatchState>, LineMatchState>,
              AsyncValue<LineMatchState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
