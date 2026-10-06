import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/vocabulary_native_data_source.dart';
import 'data/repositories/vocabulary_repository_impl.dart';
import 'domain/repositories/vocabulary_repository.dart';
import 'domain/usecases/vocabulary_usecases.dart';

part 'di.g.dart';

// 단어장 기능의 의존성 연결 (D-018). 테스트는 vocabularyRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
VocabularyRepository vocabularyRepository(Ref ref) => VocabularyRepositoryImpl(
  VocabularyNativeDataSource(ref.watch(vocabularyHostApiProvider)),
);

@riverpod
GetWordbooks getWordbooks(Ref ref) =>
    GetWordbooks(ref.watch(vocabularyRepositoryProvider));

@riverpod
CreateWordbook createWordbook(Ref ref) =>
    CreateWordbook(ref.watch(vocabularyRepositoryProvider));

@riverpod
RenameWordbook renameWordbook(Ref ref) =>
    RenameWordbook(ref.watch(vocabularyRepositoryProvider));

@riverpod
DeleteWordbook deleteWordbook(Ref ref) =>
    DeleteWordbook(ref.watch(vocabularyRepositoryProvider));

@riverpod
GetWords getWords(Ref ref) => GetWords(ref.watch(vocabularyRepositoryProvider));

@riverpod
GetWord getWord(Ref ref) => GetWord(ref.watch(vocabularyRepositoryProvider));

@riverpod
MoveWord moveWord(Ref ref) => MoveWord(ref.watch(vocabularyRepositoryProvider));

@riverpod
DeleteWord deleteWord(Ref ref) =>
    DeleteWord(ref.watch(vocabularyRepositoryProvider));

@riverpod
SetWordMemorized setWordMemorized(Ref ref) =>
    SetWordMemorized(ref.watch(vocabularyRepositoryProvider));

@riverpod
SaveWord saveWord(Ref ref) => SaveWord(ref.watch(vocabularyRepositoryProvider));

@riverpod
CreateWordTest createWordTest(Ref ref) =>
    CreateWordTest(ref.watch(vocabularyRepositoryProvider));

@riverpod
CreateFlashcardDeck createFlashcardDeck(Ref ref) =>
    CreateFlashcardDeck(ref.watch(vocabularyRepositoryProvider));

@riverpod
CreateLineMatchGame createLineMatchGame(Ref ref) =>
    CreateLineMatchGame(ref.watch(vocabularyRepositoryProvider));

@riverpod
CreateFallingGame createFallingGame(Ref ref) =>
    CreateFallingGame(ref.watch(vocabularyRepositoryProvider));
