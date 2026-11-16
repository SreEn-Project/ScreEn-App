import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/repositories/study_log_repository_impl.dart';
import 'domain/repositories/study_log_repository.dart';
import 'domain/usecases/study_log_usecases.dart';

part 'di.g.dart';

@Riverpod(keepAlive: true)
StudyLogRepository studyLogRepository(Ref ref) => StudyLogRepositoryImpl();

@riverpod
GetStudyStreak getStudyStreak(Ref ref) =>
    GetStudyStreak(ref.watch(studyLogRepositoryProvider));
