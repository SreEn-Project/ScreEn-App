# 작업 기록

최신 항목을 위에 추가한다. 형식: 날짜 · 기능 ID · 한 일 · 남은 일.

## 2026-10-01 · 캡처 범위 모드 (이슈 #12, 브랜치 `feat/12-capture-range-modes`)
- (이슈 #14) 사용자 요청으로 메뉴의 "고정 영역 편집"을 "고정 영역"에 합침: 고정 영역을 고르면 바로 편집 화면이 열리고, 저장 후 버튼 탭 = 번역.
- NA-20 · NA-21 · NA-08 · NA-07 · NA-06(네이티브): 모드 메뉴의 드래그로 지정 · 고정 영역 · 고정 영역 편집을 연결 ("준비 중" 제거). 설계는 D-027.
- 변경: `Settings.fixedRegion` + DataStore 키(`data/settings/NormalizedRegion.kt`), `TranslationPipeline.run(region)` 자르기, `overlay/RegionPicker.kt`(선택 · 편집 화면), `OverlayController` 모드별 탭 동작, 문자열 ko/en 추가.
- 확인: 단위 테스트(NormalizedRegionTest) 통과, Pixel_9 에뮬레이터에서 영역 편집 → 저장 → 탭 시 그 영역 글자 3개만 번역, 드래그 모드에서 영역 선택 창 · 번역 진행 확인.
- 남은 일: 고정 영역 시각 표시(FL-08), 결과 덮어쓰기(NA-22).

## 2026-10-01 · NA-09 번역 속도 개선 (이슈 #11, 브랜치 `feat/11-translation-speed`)
- 단계별 시간 로그 추가: `PipelineTimings`(캡처 · OCR · 언어 감지 · 번역), 태그 `TranslatorService`의 "번역 시간".
- 측정(Pixel_9 (2) 에뮬레이터, 글자 17~21블록 화면): 캡처 0.2~0.3초, 언어 감지 0.1초 이하, 번역 0.3초(첫 회 1.9초), **OCR 17.8초(처음 63초)** → 병목은 문자 인식.
- 조치: 인식 전 이미지를 긴 변 1280px로 줄이고 좌표는 원래 크기로 되돌림(`ScreenTextRecognizer`), 서비스 시작 때 인식기 예열(`warmUp`).
- 결과: 같은 종류 화면 OCR 6.4~7초(약 2.8배 빠름), 전체 약 18초 → 7~9초. 에뮬레이터는 실기기보다 느려 실기기에서는 더 짧을 것.
- 남은 일: 실기기에서 재측정. 더 줄이려면 자동 모드 인식기 3개(한 · 일 · 중)를 줄이는 방법(D-020) — 혼합 화면 정확도와 맞바꿈이라 실기기 결과를 보고 결정.

## 2026-10-01 · NA-18 플로팅 버튼 · 모드 메뉴 · NA-19 결과 목록 시트 (브랜치 `feature/NA-18-floating-button`)
- `overlay/`(Compose, D-024): `OverlayController`(창 4개 관리 · 제스처 · 번역 실행), `FloatingButton`(버튼 · 진행 링 · 닫기 영역 · 모드 메뉴), `ResultSheet`(결과 목록 · 안내), `OverlayComponents`(자체 컴포넌트), `OverlayTheme`(색 토큰 · 아이콘 글꼴), `OverlayWindow`(창 + Lifecycle 주인 + 제스처), `OverlayGeometry`(가장자리 붙기 · 닫기 영역 · 메뉴 위치 · 회전, 순수 로직).
- `translate/TranslationPipeline`: 캡처 → OCR → 언어 감지 → `MlKitTranslationEngine`(NA-12, develop에 먼저 merge된 것) → 결과 조립(`TranslationAssembler`, 순수 로직).
- `ScreenCapturer.awaitFreshFrame()`: 버튼을 숨긴 뒤의 프레임을 기다림. `TranslatorService`: 세션 시작 때 오버레이 띄움 · 종료 때 정리, 회전 전달, 엔진 수명 관리.
- Gradle: Compose 컴파일러 플러그인(Kotlin 2.4.0), `buildFeatures.compose`, compose-bom 2026.09.00(ui · foundation), 테스트용 kotlinx-coroutines-test. 리소스: `res/font/material_symbols_rounded.ttf`(3.4KB 부분 글꼴, D-025), `values-night/colors.xml`, 색 토큰 추가, 오버레이 문구 ko/en.
- 테스트: Kotlin `OverlayGeometryTest` 7 · `TranslationAssemblerTest` 6 · `TranslationPipelineTest` 2 추가 (testDebugUnitTest 37개 전부 통과). flutter analyze 0, flutter test 통과, debug APK 빌드. Flutter 코드 변경 없음.
- 기기 확인 못 함: 에뮬레이터(Pixel_9)를 다른 스레드가 쓰는 중이라 실행하지 않음 → 기기에서 볼 것: 버튼 끌기 · 가장자리 붙기 · 닫기 영역 종료, 길게 눌러 메뉴, 탭 → 결과 시트(캡처에 버튼이 안 찍히는지), 복사, 회전, 다크 모드, 첫 사용 때 언어 모델 내려받기 시간.
- 남은 일: 기기 확인 · 조정, 캡처 모드(2단계), AI로 다시 번역(NA-13), 버튼 크기 · 투명도(FL-07).

## 2026-10-01 · NA-11 번역 엔진 인터페이스 · NA-12 ML Kit 번역 엔진 (브랜치 `feature/NA-11-translation-engine`)
- `translate/TranslationEngine`(NA-11): 엔진 규약(`supports` · `translate` · `isLanguageAvailable` · `downloadLanguage` · `deleteLanguage` · `close`), 요청 · 결과, 오류 종류(`TranslationError`), 예외 대신 `EngineResult`. Gemini 등은 이 인터페이스를 구현해 끼운다.
- `translate/MlKitTranslationEngine`(NA-12): 원문 auto면 Language ID로 감지, 영어 중간 언어 때문에 영어 아닌 쌍은 영어 모델도 필요, 모델이 없으면 (자동 내려받기 켜짐) Wi-Fi 조건 옵션으로 내려받고 번역 / 꺼짐이면 `ModelNotDownloaded`. 같은 언어 · 빈 글자는 그대로 돌려줌.
- `translate/OnDeviceBackend`: ML Kit 호출만 감싼 층(번역기 캐시, RemoteModelManager) + `TranslationErrorMapper`(네트워크 · 저장 공간 · 기타). 규칙을 ML Kit 없이 테스트하려고 분리.
- Gradle은 이미 `translate:17.0.3` 있어 변경 없음. `LanguageDetector`의 `await` 확장을 internal로 열어 재사용.
- Kotlin 단위 테스트 `MlKitTranslationEngineTest` 9개 통과 (testDebugUnitTest 전체 성공). 기기 · APK 확인 안 함 (에뮬레이터 사용 금지 지시).
- 남은 일: 번역 Pigeon 브릿지는 아직 없어 네이티브에만 둠. 서비스(NA-18 이후)에서 엔진 호출 · 캡처 → OCR → 감지 → 번역 연결, 오버레이 표시, ML Kit 대체 로직(NA-13/14 때).

## 2026-09-30 · NA-10 언어 감지 (브랜치 `feature/NA-10-language-detection`, NA-09 위에 쌓음)
- `translate/LanguageDetector`: 블록별 ML Kit Language ID(신뢰도 0.5 미만 = 모름), 대상 언어는 저장된 설정.
- `translate/LanguagePlan`(순수 로직): 언어 코드 정리(지역 · 문자 표기 제거, 옛 코드 변환, 로마자 표기 비라틴 = 모름), 블록별 결정 — 번역 / 대상과 같아 건너뜀 / 엔진 미지원 / 모름. Language ID가 모르면 OCR 추정 언어를 씀 (D-021).
- 서비스 `detectLanguages()`, 디버그 "캡처 테스트"에 결정별 개수 로그. Kotlin 단위 테스트 `LanguagePlanTest` 7개 통과, debug APK 빌드 · analyze · flutter test 통과.
- 기기 확인은 에뮬레이터 대기 (첫 Pixel_9가 디스크 부족으로 안 켜짐).

## 2026-09-30 · NA-09 문자 인식 (브랜치 `feature/NA-09-text-recognition`, NA-05 위에 쌓음)
- `ocr/`: `ScreenTextRecognizer`(ML Kit v2, 인식기는 처음 쓸 때 만들고 서비스 종료 때 닫음), `OcrSelection`(인식기 고르기 · 낮은 신뢰도 거르기 · 결과 고르기, 순수 로직), 블록 · 줄 · 좌표 · 추정 언어 모델.
- 서비스 `recognizeText()`, 디버그 "캡처 테스트"에 인식 결과 · 소요 시간 로그.
- Gradle: `text-recognition-devanagari`, `testImplementation junit` 추가. Kotlin 단위 테스트 `OcrSelectionTest` 6개 통과.
- 기기 확인 못 함: Pixel_5는 종료되어 있고 Pixel_9는 다른 앱(music_download_play_app)이 사용 중.
- 사용자 확인 필요: 자동 모드 인식기 고르기 (D-020).

## 2026-09-30 · NA-05 프레임 캡처 · NA-04 세션 관리 (브랜치 `feature/NA-05-frame-capture`)
- `capture/ScreenCapturer`: VirtualDisplay + ImageReader, 최신 프레임 유지, RGBA → Bitmap(rowStride 패딩 제거), 검은 화면 감지, 회전 대응 (D-019).
- `TranslatorService`: 세션 시작 때 캡처 준비 · 종료 때 해제, `captureFrame()`(NA-18이 부를 곳), 캡처 대상 크기 변경 콜백, 디버그 전용 알림 "캡처 테스트".
- 앱 이름을 문자열 리소스로 (영어 기기에서 "Screen Translate").
- 확인 (Pixel_5 에뮬레이터, API 33 — Pixel_9는 다른 쪽이 조작 중이라 전용 에뮬레이터를 따로 띄움):
  - 세로 1080×2340 ✅, 가로 2340×1080 ✅, 다시 세로 ✅ (첫 구현은 13에서 회전 뒤 화면이 어긋나 수정), 검은 화면 → Blank ✅, 멈춘 화면 반복 캡처 ✅.
  - Android 14+ 회전 경로(onCapturedContentResize)는 기기 확인 전.
- analyze 0, 테스트 16개 통과, debug APK 빌드.

## 2026-09-29 · 클린 아키텍처 적용 (D-018, 브랜치 `refactor/clean-architecture`)
- 기능별 domain(entities · repositories · usecases) / data(datasources · mappers · repositories) / presentation(screens · view_models · widgets) + `di.dart`.
- service · settings · permission: 유스케이스 추가(서비스 4, 설정 7, 권한 3), 데이터소스로 Pigeon · 플러그인 감쌈, 도메인 자체 열거형(ServiceStatus, EngineType 등) + 매퍼.
- ViewModel은 유스케이스만 호출. 화면 파일은 screens/ 등으로 이동.
- `test/architecture_test.dart` 추가 → 도메인이 Flutter를 쓰던 곳(SupportedLanguage.displayName) 발견 · 수정.
- 테스트 16개 통과, analyze 0, debug APK 빌드 성공. 동작 변경 없음.

## 2026-09-29 · FL-02 권한 확인 · 요청 (브랜치 `feature/FL-02-permissions`, NA-02 위에 쌓음)
- 사용자 제보: 권한 화면에서 알림 팝업이 안 뜸 → 퍼블리싱용 가짜 동작이었음. 실제로 연결.
- `permission_handler`로 확인 · 요청: 알림은 시스템 팝업(두 번 거부해 막히면 앱 설정), 다른 앱 위 표시는 시스템 설정 화면. 앱으로 돌아오면 다시 확인(AppLifecycleListener).
- `PermissionViewModel`(keepAlive)을 권한 화면 · 홈이 같이 본다. 홈 시작 버튼은 권한이 빠지면 비활성 + "권한을 허용해야 시작할 수 있어요" → 권한 화면.
- 테스트: PermissionViewModel 4개, 첫 실행 흐름 위젯 테스트를 가짜 권한으로. 전체 14개 통과, analyze 0, debug APK 빌드.
- 기기 확인(Pixel_9, emulator-5554): 알림 "허용하기" → 시스템 팝업 → 허용됨 ✅ / "설정 열기" → 다른 앱 위 표시 설정(Android 11+는 앱 목록이 뜸) → 켜고 돌아오면 허용됨 ✅ / 둘 다 허용 → 홈 시작 버튼 활성 ✅.
- 버그 수정: 동의 창을 둔 채 다른 앱으로 가면 결과가 안 와서 "동의 대기"에 멈추고 시작 버튼이 막혔음 → 동의 화면 singleInstance, 대기 중에 다시 누르면("동의 창 다시 열기") 동의 화면을 다시 띄움, 결과 없이 사라지면 꺼짐으로 되돌림.
  - 수정 후 기기 재현은 끝까지 못 함: 같은 에뮬레이터를 다른 쪽에서 동시에 조작하고 있어(런처로 바뀜 등) 결과를 믿을 수 없어 중단. 로직은 단위 테스트로 확인.

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
