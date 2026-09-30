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
- Notion 기록은 페이지 본문이 아니라 **데이터베이스 행**으로 남긴다 ([진행 기록](https://app.notion.com/p/3eac450c43a581b79e1ceb6229d026f1) 아래).
  - [작업 기록 DB](https://app.notion.com/p/b2eb20d69456469ca2b6340da86d78c3): 작업 단위(기능 ID · PR) 하나 = 한 행. 분류 · 기능 ID · 단계 · 상태 · PR · 브랜치 · 요약을 채우고 본문에 한 일 · 확인 · 남은 일.
  - [설계 결정 DB](https://app.notion.com/p/e75c6bcec72049739f391565d86b77b9): docs/decisions.md와 같은 번호로 한 행. 바뀐 결정은 상태를 "대체됨"으로.
  - 갱신 시점: PR 생성 · merge(상태 변경), 단계 완료, 중요한 결정, 막힌 일. 진행 기록 페이지의 "현재 상태"도 같이 고친다. 상세 원본은 항상 docs/.
  - 새 기능 ID가 나오면 작업 기록 DB의 "기능 ID" 선택지에 추가한다.
- 명세가 모호하거나 Notion과 코드가 다르면 추측하지 말고 사용자에게 묻는다.

## Git (상세: [docs/git.md](docs/git.md))
- 브랜치: `main` · `develop` 보호, 작업은 `feature/<ID>-<요약>` · `ui/<단계>-<요약>` · `fix/` · `chore/` · `docs/`를 `develop`에서 딴다.
- 커밋: `<type>(<ID>): <한국어 요약>` (feat · fix · ui · refactor · test · docs · chore · style).
- 작업 브랜치 커밋 · push는 자유롭게 한다. **`develop` · `main`으로 merge할 때만 사용자에게 알리고 승인받는다.** PR은 `.github/pull_request_template.md` 형식.

## 아키텍처 규칙
- Flutter: **클린 아키텍처** + MVVM(presentation) + Riverpod(`riverpod_generator`), feature-first (D-018, 상세 [docs/architecture.md](docs/architecture.md)).
  - 의존 방향: presentation → domain ← data. **domain은 순수 Dart** (Flutter · Riverpod · Pigeon · 플러그인 import 금지, freezed_annotation만 허용).
  - domain: `entities/`(앱 자체 모델 · 열거형), `repositories/`(인터페이스), `usecases/`(동작 하나당 클래스 하나, `call()`).
  - data: `datasources/`(Pigeon · 플러그인 감싸기), `mappers/`(Pigeon ↔ 엔티티), `repositories/`(구현). Pigeon 타입은 data 밖으로 나가지 않는다.
  - presentation: `screens/` · `view_models/` · `widgets/`. ViewModel은 유스케이스만 부른다 (리포지토리 · data 직접 사용 금지).
  - 연결: 기능마다 `di.dart`(Riverpod provider로 데이터소스 → 리포지토리 → 유스케이스). 테스트는 리포지토리 provider를 바꿔 끼운다.
  - `test/architecture_test.dart`가 의존 규칙을 검사한다.
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
  app/                # 앱 진입, 라우터, 하단 탭, 테마
  core/
    bridge/           # Pigeon 생성 코드 + provider (data 계층에서만 사용)
    domain/           # 유스케이스 공통 규약
    ui/               # 앱 자체 UI 컴포넌트
    l10n/             # 열거형 → 화면 문구
  features/<기능>/
    domain/           # entities/ repositories/ usecases/  (순수 Dart)
    data/             # datasources/ mappers/ repositories/
    presentation/     # screens/ view_models/ widgets/
    di.dart           # 의존성 연결 (Riverpod)
pigeons/              # Pigeon 정의 (.dart)
android/app/src/main/kotlin/.../
  bridge/  service/  capture/  overlay/  ocr/  translate/  data/
```

## 코드 스타일
- `flutter analyze` 경고 0, `dart format` 적용.
- 생성 코드(`*.g.dart`, `*.freezed.dart`, Pigeon 출력)는 직접 수정하지 않는다. `dart run build_runner build -d`, `dart run pigeon --input pigeons/<파일>.dart`로 재생성.
- 디자인은 [docs/design.md](docs/design.md)의 토큰만 쓴다. 색 하드코딩 금지, `Theme.of(context)`로 가져온다.
- 화면은 `lib/core/ui/` 자체 컴포넌트로 만든다. Material 버튼 · AppBar · ListTile · Switch · Chip · Slider · Radio를 화면에서 직접 쓰지 않는다. 필요한 모양이 없으면 core/ui에 컴포넌트를 추가하고 design.md "컴포넌트" 표에 적는다.
- UI 문자열은 ARB(`flutter_localizations`)로 관리, 한국어 · 영어.
- ViewModel은 `mocktail`로 단위 테스트를 작성한다.

## 자주 쓰는 명령
- 실행: `flutter run` (Android 기기/에뮬레이터)
- 분석 · 테스트: `flutter analyze`, `flutter test`
- 네이티브 빌드 확인: `flutter build apk --debug`
