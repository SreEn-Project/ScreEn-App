import '../../../../core/domain/use_case.dart';
import '../entities/study_streak.dart';
import '../repositories/study_log_repository.dart';

class GetStudyStreak implements NoParamsUseCase<StudyStreak> {
  const GetStudyStreak(this._repository);
  final StudyLogRepository _repository;

  @override
  Future<StudyStreak> call() => _repository.streak();
}
