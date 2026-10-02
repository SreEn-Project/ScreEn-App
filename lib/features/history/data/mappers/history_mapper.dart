import '../../../../core/bridge/translator_api.g.dart' as pigeon;
import '../../domain/entities/history_entry.dart';

// Pigeon 타입 ↔ 도메인 엔티티. 도메인은 Pigeon을 모른다 (D-018).

extension TranslationRecordMapper on pigeon.TranslationRecord {
  HistoryEntry toEntity() => HistoryEntry(
    id: id,
    original: original,
    translated: translated,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    translatedAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  );
}
