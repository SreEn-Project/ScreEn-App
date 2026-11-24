import '../entities/study_streak.dart';

abstract interface class StudyLogRepository {
  /// 오늘을 학습한 날로 기록한다.
  Future<void> markToday();

  Future<StudyStreak> streak();
}
