import '../../../../core/domain/use_case.dart';
import '../entities/vocabulary.dart';
import '../repositories/vocabulary_repository.dart';

/// 단어장 목록 조회 (AD-04).
final class GetWordbooks implements NoParamsUseCase<List<Wordbook>> {
  const GetWordbooks(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<List<Wordbook>> call() => _repository.wordbooks();
}

/// 단어장 만들기 (AD-04). 이름이 비었으면 null.
final class CreateWordbook implements UseCase<Wordbook?, String> {
  const CreateWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<Wordbook?> call(String name) =>
      _repository.createWordbook(name.trim());
}

class RenameWordbookParams {
  const RenameWordbookParams(this.id, this.name);

  final int id;
  final String name;
}

/// 단어장 이름 바꾸기 (AD-04). 이름이 비었거나 겹치면 false.
final class RenameWordbook implements UseCase<bool, RenameWordbookParams> {
  const RenameWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<bool> call(RenameWordbookParams params) =>
      _repository.renameWordbook(params.id, params.name.trim());
}

/// 단어장 삭제 (AD-04). 안의 단어도 함께 지워진다.
final class DeleteWordbook implements UseCase<void, int> {
  const DeleteWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(int id) => _repository.deleteWordbook(id);
}

class GetWordsParams {
  const GetWordsParams(
    this.wordbookId, {
    this.query = '',
    this.sort = WordSort.newest,
  });

  final int wordbookId;
  final String query;
  final WordSort sort;
}

/// 단어장 안 단어 조회 · 검색 · 정렬 (AD-05).
final class GetWords implements UseCase<List<VocabularyWord>, GetWordsParams> {
  const GetWords(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<List<VocabularyWord>> call(GetWordsParams params) => _repository.words(
    params.wordbookId,
    query: params.query.trim(),
    sort: params.sort,
  );
}

/// 단어 하나 조회 (AD-06). 없으면 null.
final class GetWord implements UseCase<VocabularyWord?, int> {
  const GetWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<VocabularyWord?> call(int id) => _repository.word(id);
}

class MoveWordParams {
  const MoveWordParams(this.id, this.wordbookId);

  final int id;
  final int wordbookId;
}

/// 단어를 다른 단어장으로 옮기기 (AD-05, AD-06).
final class MoveWord implements UseCase<void, MoveWordParams> {
  const MoveWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(MoveWordParams params) =>
      _repository.moveWord(params.id, params.wordbookId);
}

/// 단어 삭제 (AD-05, AD-06).
final class DeleteWord implements UseCase<void, int> {
  const DeleteWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(int id) => _repository.deleteWord(id);
}

class SetMemorizedParams {
  const SetMemorizedParams(this.id, {required this.memorized});

  final int id;
  final bool memorized;
}

/// 외운 단어 표시 (AD-05).
final class SetWordMemorized implements UseCase<void, SetMemorizedParams> {
  const SetWordMemorized(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(SetMemorizedParams params) =>
      _repository.setMemorized(params.id, params.memorized);
}

class SaveWordParams {
  const SaveWordParams(this.wordbookId, this.draft);

  final int wordbookId;
  final WordDraft draft;
}

/// 단어장에 단어 저장 (AD-03). 단어 · 뜻이 비어 있으면 null.
final class SaveWord implements UseCase<int?, SaveWordParams> {
  const SaveWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<int?> call(SaveWordParams params) {
    final draft = params.draft;
    if (draft.word.trim().isEmpty || draft.meaning.trim().isEmpty) {
      return Future.value();
    }
    return _repository.saveWord(params.wordbookId, draft);
  }
}
