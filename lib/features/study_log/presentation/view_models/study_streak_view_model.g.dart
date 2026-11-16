// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_streak_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈의 연속 학습 일수. 홈이 앞으로 올 때 [refresh]로 다시 읽는다.

@ProviderFor(StudyStreakViewModel)
final studyStreakViewModelProvider = StudyStreakViewModelProvider._();

/// 홈의 연속 학습 일수. 홈이 앞으로 올 때 [refresh]로 다시 읽는다.
final class StudyStreakViewModelProvider
    extends $AsyncNotifierProvider<StudyStreakViewModel, StudyStreak> {
  /// 홈의 연속 학습 일수. 홈이 앞으로 올 때 [refresh]로 다시 읽는다.
  StudyStreakViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyStreakViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyStreakViewModelHash();

  @$internal
  @override
  StudyStreakViewModel create() => StudyStreakViewModel();
}

String _$studyStreakViewModelHash() =>
    r'd79aaab062c8fa79048310b6232fb986461a494f';

/// 홈의 연속 학습 일수. 홈이 앞으로 올 때 [refresh]로 다시 읽는다.

abstract class _$StudyStreakViewModel extends $AsyncNotifier<StudyStreak> {
  FutureOr<StudyStreak> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StudyStreak>, StudyStreak>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StudyStreak>, StudyStreak>,
              AsyncValue<StudyStreak>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
