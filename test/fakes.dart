import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:translation_poc_app/features/about/di.dart';
import 'package:translation_poc_app/features/about/domain/entities/app_info.dart';
import 'package:translation_poc_app/features/about/domain/repositories/app_info_repository.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/history/di.dart';
import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';
import 'package:translation_poc_app/features/history/domain/repositories/history_repository.dart';
import 'package:translation_poc_app/features/models/di.dart';
import 'package:translation_poc_app/features/models/domain/repositories/model_repository.dart';
import 'package:translation_poc_app/features/permission/di.dart';
import 'package:translation_poc_app/features/permission/domain/entities/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:translation_poc_app/features/vocabulary/di.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:translation_poc_app/features/service/di.dart';
import 'package:translation_poc_app/features/service/domain/entities/service_status.dart';
import 'package:translation_poc_app/features/service/domain/repositories/service_repository.dart';

/// 네이티브 없이 화면을 띄우는 위젯 · 스크린샷 테스트용 가짜 서비스.
class FakeServiceRepository implements ServiceRepository {
  FakeServiceRepository([this._state = ServiceStatus.stopped]);

  ServiceStatus _state;

  @override
  Future<ServiceStatus> currentStatus() async => _state;

  @override
  Stream<ServiceStatus> watchStatus() => const Stream.empty();

  @override
  Future<void> start() async => _state = ServiceStatus.running;

  @override
  Future<void> stop() async => _state = ServiceStatus.stopped;
}

/// 요청하면 바로 허용되는 가짜 권한.
class FakePermissionRepository implements PermissionRepository {
  FakePermissionRepository({this.overlay = false, this.notification = false});

  bool overlay;
  bool notification;

  @override
  Future<AppPermissions> check() async =>
      AppPermissions(overlay: overlay, notification: notification);

  @override
  Future<void> requestNotification() async => notification = true;

  @override
  Future<void> requestOverlay() async => overlay = true;
}

/// 기본 설정을 돌려주는 가짜 설정 저장소 (바꾸면 기억만 한다).
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const TranslatorSettings()]);

  TranslatorSettings settings;

  @override
  Future<TranslatorSettings> load() async => settings;

  @override
  Stream<TranslatorSettings> watch() => const Stream.empty();

  @override
  Future<void> setTargetLanguage(String languageCode) async =>
      settings = settings.copyWith(targetLanguage: languageCode);

  @override
  Future<void> setEngine(EngineType engine) async =>
      settings = settings.copyWith(engine: engine);

  @override
  Future<void> setCaptureMode(CaptureMode mode) async =>
      settings = settings.copyWith(captureMode: mode);

  @override
  Future<void> setDisplayMode(DisplayMode mode) async =>
      settings = settings.copyWith(displayMode: mode);

  @override
  Future<void> setQuickLanguages(List<String> languageCodes) async =>
      settings = settings.copyWith(quickLanguages: languageCodes);

  @override
  Future<void> setAutoTranslate(bool enabled) async =>
      settings = settings.copyWith(autoTranslate: enabled);

  @override
  Future<void> setAutoShowDelayMs(int ms) async =>
      settings = settings.copyWith(autoShowDelayMs: ms);

  @override
  Future<void> setHideAfterInteractionMs(int ms) async =>
      settings = settings.copyWith(hideAfterInteractionMs: ms);

  @override
  Future<void> setWifiOnlyModelDownload(bool enabled) async =>
      settings = settings.copyWith(wifiOnlyModelDownload: enabled);

  @override
  Future<void> setButtonSizeDp(int dp) async =>
      settings = settings.copyWith(buttonSizeDp: dp);

  @override
  Future<void> setButtonOpacityPercent(int percent) async =>
      settings = settings.copyWith(buttonOpacityPercent: percent);

  @override
  Future<void> resetFixedRegion() async =>
      settings = settings.copyWith(hasFixedRegion: false);

  @override
  Future<void> setOnboardingCompleted(bool completed) async =>
      settings = settings.copyWith(onboardingCompleted: completed);

  @override
  Future<void> setAgeConfirmed(bool confirmed) async =>
      settings = settings.copyWith(ageConfirmed: confirmed);

  @override
  Future<void> setAiTone(AiTone tone) async =>
      settings = settings.copyWith(aiTone: tone);

  @override
  Future<void> setGemmaPolish(bool enabled) async =>
      settings = settings.copyWith(gemmaPolish: enabled);

  @override
  Future<void> setGlossary(List<GlossaryEntry> entries) async =>
      settings = settings.copyWith(glossary: entries);

  /// 엔진별 저장된 키.
  final apiKeys = <EngineType, String?>{};

  /// Gemini 키 (기존 테스트용 바로가기).
  String? get apiKey => apiKeys[EngineType.gemini];
  set apiKey(String? value) => apiKeys[EngineType.gemini] = value;

  @override
  Future<String?> getApiKey(EngineType engine) async => apiKeys[engine];

  @override
  Future<void> setApiKey(EngineType engine, String apiKey) async =>
      apiKeys[engine] = apiKey;

  @override
  Future<void> clearApiKey(EngineType engine) async => apiKeys[engine] = null;

  String? testResult;

  @override
  Future<String?> testApiKey(EngineType engine, String apiKey) async =>
      testResult;

  /// null이면 PIN이 꺼진 상태.
  String? apiKeyPin;

  @override
  Future<bool> isApiKeyPinEnabled() async => apiKeyPin != null;

  @override
  Future<bool> verifyApiKeyPin(String pin) async =>
      apiKeyPin == null || apiKeyPin == pin;

  @override
  Future<bool> setApiKeyPin(String newPin, String? currentPin) async {
    if (apiKeyPin != null && apiKeyPin != currentPin) return false;
    apiKeyPin = newPin;
    return true;
  }

  @override
  Future<bool> clearApiKeyPin(String currentPin) async {
    if (apiKeyPin != currentPin) return false;
    apiKeyPin = null;
    return true;
  }

  @override
  Future<void> resetApiKeyProtection() async {
    apiKeys.clear();
    apiKeyPin = null;
  }
}

/// 받은 모델을 기억만 하는 가짜 모델 저장소.
class FakeModelRepository implements ModelRepository {
  FakeModelRepository([Set<String> installed = const {'ko', 'en'}])
    : installed = {...installed};

  final Set<String> installed;

  @override
  Future<Set<String>> downloaded() async => {...installed};

  @override
  Future<void> download(String languageCode, {required bool wifiOnly}) async =>
      installed.add(languageCode);

  @override
  Future<void> delete(String languageCode) async =>
      installed.remove(languageCode);
}

/// 기록을 메모리에 들고 있는 가짜 번역 기록 저장소 (최신순).
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository([List<HistoryEntry> entries = const []])
    : entries = [...entries];

  final List<HistoryEntry> entries;

  @override
  Future<List<HistoryEntry>> search({
    String query = '',
    DateTime? since,
    required int limit,
  }) async {
    final q = query.toLowerCase();
    return entries
        .where(
          (e) =>
              (since == null || !e.translatedAt.isBefore(since)) &&
              (q.isEmpty ||
                  e.original.toLowerCase().contains(q) ||
                  e.translated.toLowerCase().contains(q)),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<void> delete(int id) async => entries.removeWhere((e) => e.id == id);

  @override
  Future<void> clear() async => entries.clear();
}

/// 고정된 앱 버전을 돌려주는 가짜 앱 정보.
class FakeAppInfoRepository implements AppInfoRepository {
  const FakeAppInfoRepository();

  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.2.3', buildNumber: '45');
}

/// 메모리에 단어장 · 단어를 두는 가짜 저장소. 네이티브 Room 규칙을 따라 한다:
/// 이름 중복 금지, 옮길 때 같은 단어가 있으면 합침.
class FakeVocabularyRepository implements VocabularyRepository {
  FakeVocabularyRepository({
    List<Wordbook> books = const [],
    List<VocabularyWord> words = const [],
  }) : books = [...books],
       savedWords = [...words];

  final List<Wordbook> books;
  final List<VocabularyWord> savedWords;

  int _nextId = 100;

  Wordbook _counted(Wordbook book) {
    final inBook = savedWords.where((w) => w.wordbookId == book.id);
    return Wordbook(
      id: book.id,
      name: book.name,
      wordCount: inBook.length,
      memorizedCount: inBook.where((w) => w.memorized).length,
      createdAt: book.createdAt,
      correctCount: inBook.fold(0, (a, w) => a + w.correctCount),
      attemptCount: inBook.fold(0, (a, w) => a + w.attemptCount),
    );
  }

  @override
  Future<List<Wordbook>> wordbooks() async => [
    for (final b in books) _counted(b),
  ];

  @override
  Future<Wordbook?> createWordbook(String name) async {
    if (name.isEmpty) return null;
    for (final book in books) {
      if (book.name == name) return _counted(book);
    }
    final book = Wordbook(
      id: _nextId++,
      name: name,
      wordCount: 0,
      memorizedCount: 0,
      createdAt: DateTime(2026, 10, 6),
    );
    books.add(book);
    return book;
  }

  @override
  Future<bool> renameWordbook(int id, String name) async {
    if (name.isEmpty) return false;
    for (final book in books) {
      if (book.name == name) return book.id == id;
    }
    final index = books.indexWhere((b) => b.id == id);
    final old = books[index];
    books[index] = Wordbook(
      id: id,
      name: name,
      wordCount: old.wordCount,
      memorizedCount: old.memorizedCount,
      createdAt: old.createdAt,
    );
    return true;
  }

  @override
  Future<void> deleteWordbook(int id) async {
    books.removeWhere((b) => b.id == id);
    savedWords.removeWhere((w) => w.wordbookId == id);
  }

  @override
  Future<List<VocabularyWord>> words(
    int wordbookId, {
    String query = '',
    WordSort sort = WordSort.newest,
  }) async {
    final q = query.toLowerCase();
    final found = savedWords
        .where(
          (w) =>
              w.wordbookId == wordbookId &&
              (q.isEmpty ||
                  w.word.toLowerCase().contains(q) ||
                  w.meaning.toLowerCase().contains(q)),
        )
        .toList();
    found.sort(
      (a, b) => switch (sort) {
        WordSort.newest => b.savedAt.compareTo(a.savedAt),
        WordSort.oldest => a.savedAt.compareTo(b.savedAt),
        WordSort.alphabetical => a.word.toLowerCase().compareTo(
          b.word.toLowerCase(),
        ),
        WordSort.accuracyHigh ||
        WordSort.accuracyLow => b.savedAt.compareTo(a.savedAt),
      },
    );
    return found;
  }

  @override
  Future<VocabularyWord?> word(int id) async =>
      savedWords.where((w) => w.id == id).firstOrNull;

  VocabularyWord _copy(
    VocabularyWord w, {
    int? wordbookId,
    bool? memorized,
    int? correctCount,
    int? attemptCount,
  }) => VocabularyWord(
    id: w.id,
    wordbookId: wordbookId ?? w.wordbookId,
    word: w.word,
    meaning: w.meaning,
    pronunciation: w.pronunciation,
    partOfSpeech: w.partOfSpeech,
    contextMeaning: w.contextMeaning,
    sentence: w.sentence,
    sourceApp: w.sourceApp,
    sourceLanguage: w.sourceLanguage,
    targetLanguage: w.targetLanguage,
    memorized: memorized ?? w.memorized,
    savedAt: w.savedAt,
    correctCount: correctCount ?? w.correctCount,
    attemptCount: attemptCount ?? w.attemptCount,
  );

  @override
  Future<void> moveWord(int id, int wordbookId) async {
    final index = savedWords.indexWhere((w) => w.id == id);
    final moving = savedWords[index];
    final duplicate = savedWords.any(
      (w) => w.wordbookId == wordbookId && w.word == moving.word,
    );
    if (duplicate) {
      savedWords.removeAt(index);
    } else {
      savedWords[index] = _copy(moving, wordbookId: wordbookId);
    }
  }

  @override
  Future<void> deleteWord(int id) async =>
      savedWords.removeWhere((w) => w.id == id);

  @override
  Future<void> setMemorized(int id, bool memorized) async {
    final index = savedWords.indexWhere((w) => w.id == id);
    savedWords[index] = _copy(savedWords[index], memorized: memorized);
  }

  /// 테스트에서 확인하려고 받은 결과를 모아 둔다.
  final List<WordAnswer> recorded = [];

  @override
  Future<void> recordAnswers(List<WordAnswer> answers) async {
    recorded.addAll(answers);
    for (final a in answers) {
      final i = savedWords.indexWhere((w) => w.id == a.wordId);
      if (i < 0) continue;
      final w = savedWords[i];
      savedWords[i] = _copy(
        w,
        correctCount: w.correctCount + (a.correct ? 1 : 0),
        attemptCount: w.attemptCount + 1,
      );
    }
  }

  @override
  Future<int?> saveWord(int wordbookId, WordDraft draft) async {
    if (draft.word.trim().isEmpty || draft.meaning.trim().isEmpty) return null;
    final id = _nextId++;
    savedWords.removeWhere(
      (w) => w.wordbookId == wordbookId && w.word == draft.word.trim(),
    );
    savedWords.add(
      VocabularyWord(
        id: id,
        wordbookId: wordbookId,
        word: draft.word.trim(),
        meaning: draft.meaning.trim(),
        pronunciation: draft.pronunciation,
        partOfSpeech: draft.partOfSpeech,
        contextMeaning: draft.contextMeaning,
        sentence: draft.sentence,
        sourceLanguage: draft.sourceLanguage,
        targetLanguage: draft.targetLanguage,
        memorized: false,
        savedAt: DateTime(2026, 10, 7),
      ),
    );
    return id;
  }

  @override
  Future<bool> updateWord(int id, WordDraft draft) async {
    final i = savedWords.indexWhere((w) => w.id == id);
    final word = draft.word.trim();
    if (i < 0 || word.isEmpty || draft.meaning.trim().isEmpty) return false;
    final w = savedWords[i];
    if (savedWords.any(
      (o) => o.id != id && o.wordbookId == w.wordbookId && o.word == word,
    )) {
      return false;
    }
    savedWords[i] = VocabularyWord(
      id: w.id,
      wordbookId: w.wordbookId,
      word: word,
      meaning: draft.meaning.trim(),
      pronunciation: draft.pronunciation,
      partOfSpeech: draft.partOfSpeech,
      contextMeaning: draft.contextMeaning,
      sentence: draft.sentence,
      sourceApp: w.sourceApp,
      sourceLanguage: w.sourceLanguage,
      targetLanguage: w.targetLanguage,
      memorized: w.memorized,
      savedAt: w.savedAt,
      correctCount: w.correctCount,
      attemptCount: w.attemptCount,
    );
    return true;
  }
}

/// 네이티브 연결 provider를 가짜로 바꾼다.
List<Override> fakeNativeOverrides({
  ServiceStatus service = ServiceStatus.stopped,
  bool permissionsGranted = false,
  bool onboardingCompleted = false,
  FakeSettingsRepository? settings,
  FakeVocabularyRepository? vocabulary,
}) => [
  serviceRepositoryProvider.overrideWithValue(FakeServiceRepository(service)),
  settingsRepositoryProvider.overrideWithValue(
    settings ??
        FakeSettingsRepository(
          TranslatorSettings(onboardingCompleted: onboardingCompleted),
        ),
  ),
  appInfoRepositoryProvider.overrideWithValue(const FakeAppInfoRepository()),
  modelRepositoryProvider.overrideWithValue(FakeModelRepository()),
  historyRepositoryProvider.overrideWithValue(FakeHistoryRepository()),
  vocabularyRepositoryProvider.overrideWithValue(
    vocabulary ?? FakeVocabularyRepository(),
  ),
  permissionRepositoryProvider.overrideWithValue(
    FakePermissionRepository(
      overlay: permissionsGranted,
      notification: permissionsGranted,
    ),
  ),
];
