# 작업 기록

최신 항목을 위에 추가한다. 형식: 날짜 · 기능 ID · 한 일 · 남은 일.

## 2026-09-29 · FL-02 권한 확인 · 요청 (브랜치 `feature/FL-02-permissions`, NA-02 위에 쌓음)
- 사용자 제보: 권한 화면에서 알림 팝업이 안 뜸 → 퍼블리싱용 가짜 동작이었음. 실제로 연결.
- `permission_handler`로 확인 · 요청: 알림은 시스템 팝업(두 번 거부해 막히면 앱 설정), 다른 앱 위 표시는 시스템 설정 화면. 앱으로 돌아오면 다시 확인(AppLifecycleListener).
- `PermissionViewModel`(keepAlive)을 권한 화면 · 홈이 같이 본다. 홈 시작 버튼은 권한이 빠지면 비활성 + "권한을 허용해야 시작할 수 있어요" → 권한 화면.
- 테스트: PermissionViewModel 4개, 첫 실행 흐름 위젯 테스트를 가짜 권한으로. 전체 14개 통과, analyze 0, debug APK 빌드.
- 기기 확인 못 함: 에뮬레이터를 다른 앱이 쓰고 있어 중단.

## 2026-09-29 · NA-02 포그라운드 서비스 · NA-03 서비스 알림 · FL-03 시작/중지 (브랜치 `feature/NA-02-foreground-service`)
- PR #1(1단계 UI) develop에 merge (사용자 승인).
- 네이티브: `TranslatorService`(mediaProjection 포그라운드 서비스), `CaptureConsentActivity`(동의 창, 전체 화면 기본), `ServiceNotification`(채널 · 중지 동작 · 앱 열기), Manifest 등록, 알림 문구 ko/en · 색 리소스. 상태 ERROR 추가 (D-017).
- Pigeon: `ServiceHostApi.startService()` · `stopService()`, `ServiceState.error`.
- Flutter: `ServiceRepository.start/stop`, `ServiceViewModel`(상태 스트림 + toggle), 홈 시작 버튼 · 상태 카드를 실제 상태에 연결(꺼짐 · 동의 대기 · 실행 중 · 오류). 테스트용 `test/fakes.dart`.
- 테스트: ServiceViewModel 6개(mocktail), 전체 통과. analyze 0, debug APK 빌드 성공.
- 에뮬레이터(API 37) 확인: 시작 → 동의 창(전체 화면 기본) → 포그라운드 서비스(type mediaProjection) + 알림 → 홈 "실행 중" 반영 ✅.
  - 추가 확인(사용자 허락 후): 동의 취소 → 꺼짐 · 서비스 없음 ✅ / 앱 "번역 중지" → 서비스 종료 · 꺼짐 ✅ / 알림 "중지" → 서비스 종료, 앱 복귀 시 꺼짐 ✅.
  - 참고: 첫 시험 때 "취소"를 누르려던 탭이 "화면 공유"에 눌려 동의가 한 번 허용됨 → 곧바로 앱을 강제 종료해 세션 종료.
  - **발견**: 알림 권한(POST_NOTIFICATIONS)이 없으면 Android 13+에서 서비스 알림이 보이지 않아 "중지"를 쓸 수 없다. 지금 권한 화면은 자리 표시라 실제로 권한을 요청하지 않음 → FL-02를 실제 권한 요청으로 먼저 연결해야 한다. (시험 때만 adb로 부여 후 원래대로 회수)
- 남은 일: FL-02 실제 권한 확인 · 요청 → NA-04 나머지(세션 관리) · NA-05 프레임 캡처.

## 2026-09-29 · UI 피드백 1차 반영 (D-015, D-016)
- 앱 자체 컴포넌트 `lib/core/ui/` (Pressable, AppPage/AppHeader, AppBottomNav, AppButton, AppIconButton, AppCard/AppSection, AppListTile, AppSwitch, AppSegmented/AppChip, AppSlider/AppProgressBar, AppSearchField, AppBadge/AppStatusPill). 화면에서 Material 버튼 · AppBar · ListTile · Switch · Chip · Slider 제거.
- 테마: 물결 효과 끔, 그림자 primary 물듦, primary 버튼 빛.
- 하단 탭 홈 · 언어 · 설정 (`StatefulShellRoute`, `app_shell.dart`), 대상 언어 · 앱 정보는 덮어 열기. `createRouter(initialLocation)` 추가.
- 홈: 캡처 모드 타일 제거 → 대상 언어 · 언어 모델 타일 + 엔진 줄, 상태 알약(꺼짐/실행 중), "자동 감지 → 대상 언어".
- 언어 탭 = 대상 언어 + 언어 모델, 설정 탭 = 엔진 · 캡처 기본값 · 표시 · 앱 정보.
- 지원하지 않는 기기 언어는 한국어로 표시. 상태 알약 긴 문구 넘침 수정.
- analyze 0, test 통과, debug APK 빌드 성공. 에뮬레이터 실기 확인은 연결이 끊겨 못 함 → 테스트 스크린샷으로 확인.

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
