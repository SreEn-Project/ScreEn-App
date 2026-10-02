// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryViewModel)
final historyViewModelProvider = HistoryViewModelProvider._();

final class HistoryViewModelProvider
    extends $AsyncNotifierProvider<HistoryViewModel, HistoryState> {
  HistoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyViewModelHash();

  @$internal
  @override
  HistoryViewModel create() => HistoryViewModel();
}

String _$historyViewModelHash() => r'495171b27734af78441c31adcbfa6834bb1f8d63';

abstract class _$HistoryViewModel extends $AsyncNotifier<HistoryState> {
  FutureOr<HistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HistoryState>, HistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HistoryState>, HistoryState>,
              AsyncValue<HistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.

@ProviderFor(recentHistory)
final recentHistoryProvider = RecentHistoryFamily._();

/// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.

final class RecentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          List<HistoryEntry>,
          FutureOr<List<HistoryEntry>>
        >
    with
        $FutureModifier<List<HistoryEntry>>,
        $FutureProvider<List<HistoryEntry>> {
  /// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.
  RecentHistoryProvider._({
    required RecentHistoryFamily super.from,
    required HistoryPeriod super.argument,
  }) : super(
         retry: null,
         name: r'recentHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentHistoryHash();

  @override
  String toString() {
    return r'recentHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryEntry>> create(Ref ref) {
    final argument = this.argument as HistoryPeriod;
    return recentHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentHistoryHash() => r'710bd686fcfca177165ba3a6006b746b791deb6a';

/// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.

final class RecentHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<HistoryEntry>>, HistoryPeriod> {
  RecentHistoryFamily._()
    : super(
        retry: null,
        name: r'recentHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 홈 "최근 기록": 기간별 최신 몇 개. 홈이 다시 보일 때 invalidate해서 새로 읽는다.

  RecentHistoryProvider call(HistoryPeriod period) =>
      RecentHistoryProvider._(argument: period, from: this);

  @override
  String toString() => r'recentHistoryProvider';
}
