// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studyLogRepository)
final studyLogRepositoryProvider = StudyLogRepositoryProvider._();

final class StudyLogRepositoryProvider
    extends
        $FunctionalProvider<
          StudyLogRepository,
          StudyLogRepository,
          StudyLogRepository
        >
    with $Provider<StudyLogRepository> {
  StudyLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudyLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyLogRepository create(Ref ref) {
    return studyLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyLogRepository>(value),
    );
  }
}

String _$studyLogRepositoryHash() =>
    r'ac5e3b54cf2ce6574d92683a28b442fd4d82dcdf';

@ProviderFor(getStudyStreak)
final getStudyStreakProvider = GetStudyStreakProvider._();

final class GetStudyStreakProvider
    extends $FunctionalProvider<GetStudyStreak, GetStudyStreak, GetStudyStreak>
    with $Provider<GetStudyStreak> {
  GetStudyStreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getStudyStreakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getStudyStreakHash();

  @$internal
  @override
  $ProviderElement<GetStudyStreak> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetStudyStreak create(Ref ref) {
    return getStudyStreak(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetStudyStreak value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetStudyStreak>(value),
    );
  }
}

String _$getStudyStreakHash() => r'05edc8ee7749aff1c939f9289b05dc8cce5cb88b';
