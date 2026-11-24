import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/study_log/domain/entities/study_streak.dart';

void main() {
  final today = DateTime(2026, 3, 10);

  test('기록이 없으면 0', () {
    final s = StudyStreak.fromDays(const [], today);
    expect(s.current, 0);
    expect(s.best, 0);
    expect(s.studiedToday, isFalse);
  });

  test('오늘까지 이어진 연속 일수', () {
    final s = StudyStreak.fromDays([
      '2026-03-08',
      '2026-03-09',
      '2026-03-10',
    ], today);
    expect(s.current, 3);
    expect(s.studiedToday, isTrue);
    expect(s.week.last, isTrue);
  });

  test('오늘 아직 안 했어도 어제까지 이어졌다면 유지', () {
    final s = StudyStreak.fromDays(['2026-03-08', '2026-03-09'], today);
    expect(s.current, 2);
    expect(s.studiedToday, isFalse);
  });

  test('하루 빠지면 끊기고 최고 기록은 남는다', () {
    final s = StudyStreak.fromDays([
      '2026-03-01',
      '2026-03-02',
      '2026-03-03',
      '2026-03-04',
      '2026-03-09',
    ], today);
    expect(s.current, 1);
    expect(s.best, 4);
  });

  test('월 경계를 넘어서도 이어진다', () {
    final s = StudyStreak.fromDays([
      '2026-02-28',
      '2026-03-01',
    ], DateTime(2026, 3, 1));
    expect(s.current, 2);
  });
}
