import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'ai_options_view_model.g.dart';

/// AI 번역 옵션 (FL-09 연령 확인, FL-11 말투 · 용어집). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
@riverpod
class AiOptionsViewModel extends _$AiOptionsViewModel {
  @override
  Stream<AiOptions> build() async* {
    yield AiOptions.of(await ref.watch(getSettingsProvider)());
    yield* ref.watch(watchSettingsProvider)().map(AiOptions.of);
  }

  Future<void> setAgeConfirmed(bool confirmed) =>
      ref.read(changeAgeConfirmedProvider)(confirmed);

  Future<void> setTone(AiTone tone) => ref.read(changeAiToneProvider)(tone);

  /// 용어를 더한다. 같은 원문(대소문자 무시)이 있으면 번역어를 바꾼다.
  /// 빈 값이거나 목록이 가득 차면 저장하지 않고 [AddGlossaryResult]로 이유를 알린다.
  Future<AddGlossaryResult> addEntry(String source, String target) async {
    final entry = GlossaryEntry(source: source.trim(), target: target.trim());
    if (entry.source.isEmpty || entry.target.isEmpty) {
      return AddGlossaryResult.empty;
    }
    final current = state.value?.glossary ?? const <GlossaryEntry>[];
    final key = entry.source.toLowerCase();
    final others = current.where((e) => e.source.toLowerCase() != key);
    if (others.length == current.length &&
        current.length >= maxGlossaryEntries) {
      return AddGlossaryResult.full;
    }
    await ref.read(changeGlossaryProvider)([...others, entry]);
    return AddGlossaryResult.added;
  }

  Future<void> removeEntry(GlossaryEntry entry) {
    final current = state.value?.glossary ?? const <GlossaryEntry>[];
    return ref.read(changeGlossaryProvider)([
      for (final e in current)
        if (e != entry) e,
    ]);
  }
}

enum AddGlossaryResult { added, empty, full }

/// 화면이 쓰는 AI 옵션 묶음.
class AiOptions {
  const AiOptions({
    this.ageConfirmed = false,
    this.tone = AiTone.standard,
    this.glossary = const [],
  });

  factory AiOptions.of(TranslatorSettings s) => AiOptions(
    ageConfirmed: s.ageConfirmed,
    tone: s.aiTone,
    glossary: s.glossary,
  );

  final bool ageConfirmed;
  final AiTone tone;
  final List<GlossaryEntry> glossary;
}
