# 작업 규칙 (Translation-App)

Android 화면 번역 앱. Flutter(앱 UI) + Kotlin 네이티브(캡처 · 오버레이 · OCR · 번역).
기능 명세의 원본은 Notion 허브: https://app.notion.com/p/3eac450c43a58134937ccc94e2c722fa
프로젝트 문서는 [docs/](docs/README.md)에 있다.

## 진행 방식
- 단계 순서대로 진행한다: 1 MVP → 2 캡처 범위 · 덮어쓰기 → 3 AI 번역 → 4 편의 기능. 단어장(AD-)은 핵심 기능 이후, 서버(SV-)는 결정 전까지 만들지 않는다.
- 작업 단위는 Notion 세부 기능 ID(FL-/NA-/SV-/AD-) 하나. 커밋 메시지와 문서에 ID를 적는다. 예: `feat(FL-01): 온보딩 화면`
- 현재 우선순위: **1단계 UI 퍼블리싱**(Flutter 화면을 자리 표시 데이터로 먼저 완성) → 사용자 검증 · 피드백 → 기능 연결(NA-02~). 퍼블리싱이 끝나면 사용자에게 알린다.
- 규칙 · 절차는 사용자에게 매번 묻지 말고 스스로 정해 docs/에 기록한 뒤 따른다. 사용자가 이미 정한 것은 다시 묻지 않는다.
- 코드 · 설정(pubspec, Gradle, Manifest 등)을 바꿀 때는 무엇을 바꾸는지 보고에 적는다.
- 작업을 마치면 [docs/progress.md](docs/progress.md)에 기록하고, 설계 결정은 [docs/decisions.md](docs/decisions.md)에 남긴다.
- 명세가 모호하거나 Notion과 코드가 다르면 추측하지 말고 사용자에게 묻는다.

## Git (상세: [docs/git.md](docs/git.md))
- 브랜치: `main` · `develop` 보호, 작업은 `feature/<ID>-<요약>` · `ui/<단계>-<요약>` · `fix/` · `chore/` · `docs/`를 `develop`에서 딴다.
- 커밋: `<type>(<ID>): <한국어 요약>` (feat · fix · ui · refactor · test · docs · chore · style).
- 작업 브랜치 커밋 · push는 자유롭게 한다. **`develop` · `main`으로 merge할 때만 사용자에게 알리고 승인받는다.** PR은 `.github/pull_request_template.md` 형식.

## 아키텍처 규칙
- Flutter: MVVM + Riverpod(`riverpod_generator`), feature-first 폴더, 계층은 presentation / domain / data.
- 라우팅 `go_router`, 모델 `freezed` + `json_serializable`.
- Flutter ↔ 네이티브 통신은 Pigeon만 쓴다. 문자열 MethodChannel 금지.
- 번역 서비스는 Flutter 엔진 없이 네이티브에서 돈다 (포그라운드 서비스).
- 번역 엔진은 `TranslationEngine` 인터페이스로 추상화, 실패 시 ML Kit으로 대체.
- 데이터(기록 · 캐시 · 단어장)는 네이티브 Room이 소유, 설정은 네이티브 DataStore. Flutter는 Pigeon으로 조회 · 변경.
- 접근성 API(AccessibilityService)는 쓰지 않는다.
- API 키는 Keystore로 암호화해 기기에만 저장한다. 키 · 비밀값을 코드나 문서에 넣지 않는다.

## 폴더 구조 (목표)
```
lib/
  app/            # 앱 진입, 라우터, 테마
  core/           # 공통 유틸, Pigeon 생성 코드 래퍼
  features/<기능>/
    presentation/ # 화면, ViewModel
    domain/       # 모델, 리포지토리 인터페이스
    data/         # 리포지토리 구현 (Pigeon 호출)
pigeons/          # Pigeon 정의 (.dart)
android/app/src/main/kotlin/.../
  bridge/  service/  capture/  overlay/  ocr/  translate/  data/
```

## 코드 스타일
- `flutter analyze` 경고 0, `dart format` 적용.
- 생성 코드(`*.g.dart`, `*.freezed.dart`, Pigeon 출력)는 직접 수정하지 않는다. `dart run build_runner build -d`, `dart run pigeon --input pigeons/<파일>.dart`로 재생성.
- 디자인은 [docs/design.md](docs/design.md)의 토큰만 쓴다. 색 하드코딩 금지, `Theme.of(context)`로 가져온다.
- UI 문자열은 ARB(`flutter_localizations`)로 관리, 한국어 · 영어.
- ViewModel은 `mocktail`로 단위 테스트를 작성한다.

## 자주 쓰는 명령
- 실행: `flutter run` (Android 기기/에뮬레이터)
- 분석 · 테스트: `flutter analyze`, `flutter test`
- 네이티브 빌드 확인: `flutter build apk --debug`
