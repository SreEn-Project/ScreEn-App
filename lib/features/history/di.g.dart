// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historyRepository)
final historyRepositoryProvider = HistoryRepositoryProvider._();

final class HistoryRepositoryProvider
    extends
        $FunctionalProvider<
          HistoryRepository,
          HistoryRepository,
          HistoryRepository
        >
    with $Provider<HistoryRepository> {
  HistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyRepositoryHash();

  @$internal
  @override
  $ProviderElement<HistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoryRepository create(Ref ref) {
    return historyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryRepository>(value),
    );
  }
}

String _$historyRepositoryHash() => r'2b463178c6e2bd428f9f9eae7b3b5af21d2ffe39';

@ProviderFor(searchHistory)
final searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends $FunctionalProvider<SearchHistory, SearchHistory, SearchHistory>
    with $Provider<SearchHistory> {
  SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  $ProviderElement<SearchHistory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchHistory create(Ref ref) {
    return searchHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchHistory>(value),
    );
  }
}

String _$searchHistoryHash() => r'3e28a4669d2672bfc599017c43d09993d3fa76bb';

@ProviderFor(deleteHistoryEntry)
final deleteHistoryEntryProvider = DeleteHistoryEntryProvider._();

final class DeleteHistoryEntryProvider
    extends
        $FunctionalProvider<
          DeleteHistoryEntry,
          DeleteHistoryEntry,
          DeleteHistoryEntry
        >
    with $Provider<DeleteHistoryEntry> {
  DeleteHistoryEntryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteHistoryEntryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteHistoryEntryHash();

  @$internal
  @override
  $ProviderElement<DeleteHistoryEntry> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteHistoryEntry create(Ref ref) {
    return deleteHistoryEntry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteHistoryEntry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteHistoryEntry>(value),
    );
  }
}

String _$deleteHistoryEntryHash() =>
    r'12a87292a3be84b6163d69e021d44709e77c4cb0';

@ProviderFor(clearHistory)
final clearHistoryProvider = ClearHistoryProvider._();

final class ClearHistoryProvider
    extends $FunctionalProvider<ClearHistory, ClearHistory, ClearHistory>
    with $Provider<ClearHistory> {
  ClearHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearHistoryHash();

  @$internal
  @override
  $ProviderElement<ClearHistory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClearHistory create(Ref ref) {
    return clearHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearHistory>(value),
    );
  }
}

String _$clearHistoryHash() => r'11d3e11f7b0259d4f30b2973f8631415b28dded0';
