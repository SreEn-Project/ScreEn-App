import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/study_streak.dart';
import '../../domain/repositories/study_log_repository.dart';

const _key = 'study_days';
const _maxDays = 400;

/// 학습한 날(yyyy-MM-dd)만 기기에 저장한다. 화면용 기록이라 shared_preferences를 쓴다 (D-072).
class StudyLogRepositoryImpl implements StudyLogRepository {
  StudyLogRepositoryImpl({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  Future<List<String>> _days() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> markToday() async {
    try {
      final today = StudyStreak.formatDay(_now());
      final prefs = await SharedPreferences.getInstance();
      final days = prefs.getStringList(_key) ?? <String>[];
      if (days.contains(today)) return;
      final next = [...days, today];
      final trimmed = next.length > _maxDays
          ? next.sublist(next.length - _maxDays)
          : next;
      await prefs.setStringList(_key, trimmed);
    } catch (_) {
      // 기록하지 못해도 학습 자체에는 영향이 없다.
    }
  }

  @override
  Future<StudyStreak> streak() async =>
      StudyStreak.fromDays(await _days(), _now());
}
