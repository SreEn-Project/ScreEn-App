# 작업 기록

최신 항목을 위에 추가한다. 형식: 날짜 · 기능 ID · 한 일 · 남은 일.

## 2026-09-29 · 1단계 UI 퍼블리싱 (브랜치 `ui/stage1-screens`)
- Git 규칙 · 템플릿 정의 ([git.md](git.md)), GitHub에 main · develop 생성, 기본 브랜치 develop.
- 화면(자리 표시 데이터, 화면 안에서만 상태 변경):
  - FL-01 온보딩: 소개 3장 + 대상 언어 선택, 건너뛰기, 페이지 점, "시작하기 →" 흰 알약
  - FL-02 권한 안내: 다른 앱 위 표시 · 알림 카드, 허용 상태, 둘 다 허용해야 계속하기
  - FL-03 홈: 알림 · 설정 버튼, 상태 카드, 시작/중지 토글, 캡처 모드 선택, 최근 기록 빈 상태
  - FL-04 언어 목록(검색, 원문 인식 불가 표시) · 설정용 언어 선택 화면
  - FL-06 설정: 대상 언어, 언어 모델, 엔진(AI는 비활성 + 이유), 캡처 모드, 고정 영역 초기화, 표시 방식, 버튼 크기 · 투명도, 앱 정보
  - FL-05 언어 모델: Wi-Fi 전용, 받은/받을 수 있는 언어, 진행률(가짜), 대상 전용 배지
  - FL-14 정보: 버전, 개인정보처리방침(주소 미정 → 비활성), 오픈소스 라이선스
- 공통 위젯: IconBadge, CircleIconButton, WhitePillButton, SectionTitle, 열거형 문구 `core/l10n/labels.dart`.
- 테마 보정: 컴포넌트 글자 스타일을 textTheme에서 파생.
- 스크린샷 테스트 `test/screenshots/` (기본 건너뜀): `flutter test --run-skipped -t screenshot test/screenshots` → `build/screenshots/`.
- 남은 일: 사용자 검증 · 피드백 반영 → develop merge(승인 후) → 기능 연결(NA-02~). 오버레이(NA-18 · NA-19)는 네이티브 화면이라 해당 기능 때 만든다.

## 2026-09-29 · NA-01 Pigeon 브리지 · NA-16 설정 저장소
- Pigeon 정의 `pigeons/translator_api.dart` → `lib/core/bridge/translator_api.g.dart`, `android/.../bridge/TranslatorApi.g.kt`.
  - `SettingsHostApi`(설정 조회 · 변경, 네이티브는 suspend), `ServiceHostApi`(서비스 상태 조회), `TranslatorEventApi`(이벤트: 서비스 상태 · 설정 변경).
- 네이티브: `data/settings/`(Settings 모델, DataStore `SettingsRepository`), `service/TranslatorServiceState`(StateFlow, NA-02에서 갱신), `bridge/`(HostApi 구현, 이벤트 핸들러, Pigeon ↔ 네이티브 변환), `AppGraph`(서비스와 공유할 싱글턴), `MainActivity`에서 등록 · 해제.
- Flutter: `core/bridge/bridge_providers.dart`(API · 이벤트 버스 provider), `features/settings`(TranslatorSettings freezed, SettingsRepository), `features/service`(ServiceRepository).
- 테스트: `test/features/settings/pigeon_settings_repository_test.dart` (mocktail). analyze 0, test 통과, debug APK 빌드 성공.
- 기기 실행 확인은 아직 (화면에서 쓰는 곳이 FL-01/FL-03부터).
- 남은 일: NA-02 포그라운드 서비스 · NA-03 서비스 알림.

## 2026-09-29 · 디자인 적용 (D-008)
- [design.md](design.md)를 확정 팔레트 · 모양 · 화면 구성으로 다시 씀.
- 테마: `app_colors.dart` 교체, `app_tokens.dart`(ThemeExtension: 배경 · accent · 그라데이션 · 그림자 · 치수) 추가, `app_theme.dart` 알약 버튼 · 칩 · 시트 28dp.
- 공통 위젯: `lib/core/widgets/app_card.dart`(24dp + 그림자), `accent_title.dart`(한 단어 강조 제목).
- 홈 레이아웃: 인사 + 알림 버튼 → 그라데이션 상태 카드 → 시작 버튼(상태 점) → 캡처 모드 타일 3개 → 최근 기록(칩 필터, 빈 상태). 값은 자리 표시, 동작은 FL-03 이후 연결.
- ARB(ko/en) 문자열 추가. pubspec에 `material_symbols_icons` 추가 (D-009).
- `flutter analyze` 이상 없음, `flutter test` 통과.
- 빌드 해결: app Gradle `compileSdk { version = release(37) { minorApiLevel = 0 } }` (설치된 플랫폼 이름이 `android-37.0`). `flutter build apk --debug` 성공.
- git 저장소 생성 (커밋 없음).
- 남은 일: NA-01 Pigeon 브리지.

## 2026-09-29 · 0단계 기반 세팅
- 디자인 방향 확정: 화이트 + 연한 초록 포인트, 미니멀 · 모노톤 → [design.md](design.md), `lib/app/theme/`.
- pubspec 의존성 추가 (riverpod 3 + generator, go_router, freezed, json_serializable, pigeon, permission_handler, url_launcher, intl, l10n, mocktail).
- 카운터 예제 삭제 → `lib/app` (App, 라우터, 테마), `lib/features/home` (홈 자리 표시), `lib/l10n` (ko/en ARB, 임시 앱 이름 "화면 번역").
- AndroidManifest 권한 추가, 앱 라벨 "화면 번역". app Gradle에 lifecycle-service, coroutines, DataStore, ML Kit(OCR 4종, language-id, translate) 추가. Compose는 NA-18에서 추가.
- `flutter analyze` 이상 없음, `flutter test` 통과.
- 막힌 것: `flutter build apk --debug` 실패. permission_handler_android 14.1.0이 compileSdk 37을 요구하는데 SDK에 `android-37.0`만 있고 `android-37`을 못 찾음 → SDK Platform 37 설치 필요.
- 남은 일: 빌드 확인 → NA-01 Pigeon 브리지.

## 2026-09-29 · 문서 · 규칙 세팅
- 현재 상태 확인: `flutter create` 직후 기본 카운터 앱 (패키지 `translation_poc_app`, applicationId `com.example.translation_poc_app`, Flutter 3.47.3 / Dart 3.13.3). git 저장소 아님, 추가 의존성 없음, iOS 폴더 있음(범위 밖).
- `CLAUDE.md`, `docs/` (README, architecture, roadmap, progress, decisions) 작성.
- Notion 세부 기능 DB에서 1단계(19개) 목록을 [roadmap.md](roadmap.md)에 순서대로 정리.
- 남은 일: 0단계 기반 세팅 (applicationId 확정 필요) → NA-01 Pigeon 브리지부터.
