/// 번역 기록 한 줄 (NA-23, FL-13): 번역된 블록 하나. 같은 원문 · 번역을 다시 번역하면 [translatedAt]만 새로 고쳐진다.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.original,
    required this.translated,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translatedAt,
  });

  final int id;
  final String original;
  final String translated;

  /// BCP-47 언어 코드.
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime translatedAt;
}

/// 기록 목록의 기간 필터.
enum HistoryPeriod {
  all,
  today,
  week;

  /// 이 기간의 시작 시각 ([now] 기준). 전체면 null.
  DateTime? start(DateTime now) => switch (this) {
    HistoryPeriod.all => null,
    HistoryPeriod.today => DateTime(now.year, now.month, now.day),
    HistoryPeriod.week => now.subtract(const Duration(days: 7)),
  };
}
