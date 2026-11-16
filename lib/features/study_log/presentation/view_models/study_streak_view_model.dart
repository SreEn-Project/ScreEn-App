import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/study_streak.dart';

part 'study_streak_view_model.g.dart';

/// 홈의 연속 학습 일수. 홈이 앞으로 올 때 [refresh]로 다시 읽는다.
@riverpod
class StudyStreakViewModel extends _$StudyStreakViewModel {
  @override
  Future<StudyStreak> build() => ref.watch(getStudyStreakProvider)();

  Future<void> refresh() async {
    state = AsyncData(await ref.read(getStudyStreakProvider)());
  }
}
