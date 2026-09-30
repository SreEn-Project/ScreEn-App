/// 유스케이스 공통 규약 (D-018). 도메인 계층은 순수 Dart만 쓴다.
///
/// - 유스케이스 하나 = 사용자 동작 · 조회 하나. `call`로 실행한다: `await startService()`.
/// - 입력이 없으면 [NoParams]를 쓰지 않고 `call()`만 둔다.
/// - 리포지토리 인터페이스에만 의존하고, 구현(data 계층)은 모른다.
abstract interface class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

abstract interface class NoParamsUseCase<Result> {
  Future<Result> call();
}

/// 계속 바뀌는 값을 구독하는 유스케이스 (예: 서비스 상태).
abstract interface class StreamUseCase<Result> {
  Stream<Result> call();
}
