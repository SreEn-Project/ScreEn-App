/// 학습한 날 기록에서 계산한 연속 학습 현황 (순수 Dart).
class StudyStreak {
  const StudyStreak({
    required this.current,
    required this.best,
    required this.week,
    required this.studiedToday,
  });

  static const empty = StudyStreak(
    current: 0,
    best: 0,
    week: [false, false, false, false, false, false, false],
    studiedToday: false,
  );

  /// 지금까지 이어진 연속 일수. 오늘 아직 안 했어도 어제까지 이어졌다면 유지된다.
  final int current;

  /// 기록 중 가장 길었던 연속 일수.
  final int best;

  /// 최근 7일(6일 전 … 오늘)의 학습 여부.
  final List<bool> week;

  final bool studiedToday;

  /// [days]는 'yyyy-MM-dd' 형식의 학습한 날 모음.
  factory StudyStreak.fromDays(Iterable<String> days, DateTime today) {
    final set = days.toSet();
    final base = DateTime(today.year, today.month, today.day);
    // DST로 하루가 23/25시간이어도 날짜가 어긋나지 않게 달력 날짜로 계산한다.
    bool hasDay(int back) => set.contains(
      formatDay(DateTime(base.year, base.month, base.day - back)),
    );

    final studiedToday = hasDay(0);
    var current = 0;
    for (var back = studiedToday ? 0 : 1; hasDay(back); back++) {
      current++;
    }

    final sorted = set.map(DateTime.tryParse).whereType<DateTime>().toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in sorted) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }

    return StudyStreak(
      current: current,
      best: best < current ? current : best,
      week: [for (var back = 6; back >= 0; back--) hasDay(back)],
      studiedToday: studiedToday,
    );
  }

  static String formatDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
