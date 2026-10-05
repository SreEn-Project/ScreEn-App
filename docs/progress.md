# 작업 기록

최신 항목을 위에 추가한다. 형식: 날짜 · 기능 ID · 한 일 · 남은 일.

## 2026-10-06 · 빠른 설정에 AI 번역 엔진 선택 (FL-06, NA-18, 이슈 #100, 브랜치 `feat/100-quick-ai-engine`)
- 플로팅 '설정' 버블에 "AI 번역: ML Kit/Gemini AI" 항목을 추가했다. 누르면 결과 닫기처럼 목록이 열려 ML Kit · Gemini AI를 바로 고른다 (탭 순환 아님). 저장은 앱 설정 화면과 같은 엔진 설정(DataStore `engine`)이라 서로 맞는다.
- Gemini API 키가 없으면 Gemini AI 줄은 비활성이고 "Gemini AI: 앱 설정에서 키 등록"으로 안내한다. 키 확인은 `ApiKeyStore`(Keystore)를 서비스가 `hasGeminiKey`로 넘겨 IO 스레드에서 읽는다. 설정에 있는 AI 관련 옵션은 엔진 선택뿐이라 이것만 넣었다.
- 변경: `overlay/OverlayController` · `QuickSettingChoices`(`engines()`, 단위 테스트 추가) · `service/TranslatorService` · 네이티브 strings.xml(ko/en). pubspec · Gradle · Manifest 변경 없음.
- 확인: analyze · flutter test · 네이티브 단위 테스트 · 디버그 빌드 통과. 기기 확인은 하지 않음.

## 2026-10-06 · 빠른 설정 선택을 목록 메뉴로 (FL-06, 이슈 #92, 브랜치 `feat/92-quick-settings-choice-menu`)
- #90의 탭 순환 방식이 불편해, 결과 닫기 · 새 번역 대기를 누르면 선택지 목록이 열려 바로 고르게 바꿨다. 현재 값이 표시된다. 자동 번역 토글은 그대로, 규칙(덮어쓰기에서만, 자동 번역 중 직접 닫기 제외)도 같다.
- 확인: analyze · test · 네이티브 단위 테스트 · 디버그 빌드 통과. 기기 확인은 하지 않음.

## 2026-10-05 · 빠른 설정에 결과 닫기 · 새 번역 대기 시간 (FL-06, NA-19, 이슈 #90, 브랜치 `feat/90-quick-settings-dismiss-wait`)
- 플로팅 '설정' 버블에 항목 2개 추가: ① 결과 닫기 — 눌러서 열리는 목록(바로 · 0.5초 · 1초 · 2초 · 직접 닫기)에서 고른다. 원문 위에 덮기 표시에서만 켜지고(아니면 흐리게), 자동 번역이 켜져 있으면 직접 닫기는 건너뛴다(D-047). ② 새 번역 대기 — 자동 번역이 켜져 있을 때만 나오며 바로 → 1 → 2 → 3초로 돈다.
- 기존 설정 키(`hideAfterInteractionMs`, `autoShowDelayMs`)를 그대로 써서 앱 설정 화면과 값이 같다. 순환 로직은 `QuickSettingChoices`(단위 테스트 있음). 문구는 네이티브 strings.xml(ko/en), 아이콘은 기존 글리프 재사용(글꼴 부분집합 유지).
- 확인: analyze · flutter test · 네이티브 단위 테스트 · 디버그 빌드 통과. 기기 확인은 하지 않음.

## 2026-10-04 · 자동 번역이 켜져 있으면 직접 닫기 사용 불가 (NA-19, FL-06, 이슈 #86, 브랜치 `fix/86-no-manual-close-with-auto`)
- 배경: #82(PR 83) 수정 뒤에도 실기기에서 직접 닫기 + 자동 번역은 닫은 뒤 재번역이 안 됐다 (시간 설정은 정상). 코드로 원인을 못 찾아 사용자 결정으로 조합을 막았다.
- 설정 화면: 자동 번역이 켜져 있으면 닫힘 시간 선택지에서 '직접 닫기'를 뺀다. 저장된 값이 직접 닫기면 즉시로 보인다.
- 네이티브: 자동 번역이 켜져 있으면 저장된 값이 직접 닫기여도 기본 시간(즉시)으로 쓴다 (저장 값은 그대로).
- 확인: analyze · test · 디버그 빌드 통과. 기기 확인은 하지 않음.

## 2026-10-04 · 자동 번역 + 직접 닫기에서 닫은 뒤 자동 번역 이어짐 (NA-19, 이슈 #82, 브랜치 `feat/82-auto-resume-after-close`)
- 원인: 사용자가 결과를 닫는 경로(버튼 탭 · 시트 닫기 · 뒤로 가기)가 모두 `dismissSheet()` = 결과 걷기 + 감시 중지라, 자동 번역이 켜져 있어도 닫으면 감시가 멈춰 다시 번역되지 않았다. (#80의 취소 · 화면 이동 중지와는 무관: 그 경로는 자동 번역 감시를 건드리지 않는다.)
- 수정: 사용자 닫기를 `closeByUser()`로 분리. 자동 번역이 켜져 있으면(절전 모드 아님) 결과만 걷고 `watcher.arm()`으로 막이 걷힌 화면을 새 기준으로 다시 잡아 이어 간다. 꺼져 있으면 기존대로 감시도 멈춘다. 새 번역 · 영역 선택 시작은 기존 `dismissSheet()` 그대로.
- 확인: analyze · test · 디버그 빌드 통과. 기기 확인은 하지 않음.

## 2026-10-03 · 번역 취소 · 화면 이동 시 중지 · 로딩 표시 · 깜빡임 (NA-12, NA-22, 이슈 #80, 브랜치 `feat/80-cancel-translate-loading-overlay`)
- 번역 중 버튼 탭 = 취소. 일반 번역도 캡처 뒤 화면이 움직이면 취소(자동 번역과 같은 규칙, D-045).
- 덮어쓰기: OCR로 찾은 글자 자리를 번역 전에 연한 초록 막으로 먼저 보여 주고 숨 쉬듯 깜빡여 로딩을 알린다. 끝난 블록부터 번역문으로 바뀐다.
- 검은 창 깜빡임: 중간 결과마다 막 창을 새로 만들던 것을 같은 창에서 내용만 바꾸도록 고쳤다(원인은 코드로 추정, 기기 확인 전).
- 변경: `overlay/OverlayController` · `OverlayResult`, `translate/TranslationPipeline`(`onPending`). pubspec · Gradle · Manifest 변경 없음.
- 확인: analyze · test · Kotlin 단위 테스트 · 디버그 APK 빌드 통과. 기기 확인 전 (취소 · 화면 이동 중지 · 깜빡임 · 로딩).

## 2026-10-03 · 닫힘 시간 안정화 · 닫힘 시간 · 자동 번역은 덮어쓰기에서만 (NA-19, NA-26, 이슈 #78, 브랜치 `feat/78-hide-overlay-only`)
- 원인: 덮어쓰기 막은 Android 12+에서 뒤 앱이 터치를 받도록 창 알파를 시스템 최대 불투명도로 낮춰 두는데, `OverlayWindow.setHidden(false)`가 알파를 1로 되돌려 한 번 숨겼다 다시 보이면(자동 번역 재번역 · 화면이 번역한 모습으로 돌아옴) 뒤 앱 터치가 막혔다. 처음 알파를 기억해 되돌리도록 고쳤다.
- 화면을 껐다 켜면 감시가 멈춘 채 다시 시작되지 않던 것을, 켜질 때 떠 있는 결과가 감시 대상이면 다시 시작하게 했다. 절전 모드에서도 닫힘 시간만 쓰는 덮기는 감시한다(자동 번역만 배터리를 위해 쉰다). 자동 번역을 쓰지 않을 때는 화면 확인을 250ms마다 해 반응을 빠르게 했다.
- 규칙 정리: **직접 닫기** = 화면 전체를 막고 사용자가 닫을 때까지(자동 번역이 꺼진 덮어쓰기), **닫힘 시간** = 막지 않고 화면이 움직이면 닫힘. 목록 · 문장(하단 시트)은 항상 막고 직접 닫는다 → #76의 '떠 있는 시트'는 걷어냈다.
- 닫힘 시간 설정은 결과 표시가 '본문 위에 표시'일 때만 활성(그 외엔 흐리게 · "본문 위에 표시에서만"). 자동 번역도 같은 조건에서만 켤 수 있다(화면 · 플로팅 메뉴 모두, 저장된 값은 유지).
- 변경: `overlay/OverlayWindow` · `OverlayController` · `ResultSheet`, `autotranslate/AutoTranslateTracker`, Flutter 설정 화면 · `AppSegmented(enabled)` · 자동 번역 ViewModel, ARB · strings.xml. pubspec · Gradle · Manifest 변경 없음.
- 확인: analyze · test · Kotlin 단위 테스트 · 디버그 APK 빌드 통과. 기기 확인은 아직.

## 2026-10-03 · 결과 레이어가 터치를 막지 않고 움직이면 닫힘 (NA-19, 이슈 #76, 브랜치 `feat/76-nonblocking-result-layer`)
- 기본값(조작 뒤 닫힘 시간 = 바로)에서 결과 목록 시트도 뒤 앱을 막지 않는다: 어두운 막 없이 시트 크기만 차지하는 창(`NOT_TOUCH_MODAL`)이라 시트 밖 터치는 아래 앱으로 간다. 화면이 움직이면 기존 감시(#35)가 시트를 숨긴다. 덮어쓰기(원문 위)는 이미 같은 방식이었다.
- 같은 시간 설정의 "안 숨김"을 **"직접 닫기"**로 바꿨다(값 `hideNever` 그대로): 이때는 예전처럼 막이 뒤 앱을 막고 X · 바깥 터치 · 뒤로 가기 · 플로팅 버튼으로만 닫는다. 설정 제목도 "…번역 결과를 닫기까지"로.
- 시트 안에서 스크롤해도 '화면이 움직임'으로 보지 않도록, 영역을 정하지 않았으면 시트가 덮지 않는 위쪽(화면 높이 6~24%)만 지문으로 본다.
- 변경: `overlay/OverlayController` · `overlay/ResultSheet`, ARB 문구(ko/en). pubspec · Gradle · Manifest 변경 없음.
- 남은 일: 기기 확인(스크롤하면 시트가 사라지는지, 시트 안 스크롤은 유지되는지, 직접 닫기 선택 시 막는지).

## 2026-10-03 · 번역이 끝나지 않는 문제 · 자동 번역 하단 시트 깜빡임 (NA-12, NA-26, 이슈 #74, 브랜치 `fix/74-translate-hang-sheet-flicker`)
- 증상 1: 번역이 안 끝나고 버튼의 도는 호(번역 중)가 계속 남는다. 원인(코드로 찾음, 기기 재현 전): 언어 모델이 없으면 Wi-Fi 전용(기본값)으로 내려받는데, Wi-Fi가 아니면 ML Kit 받기가 끝나지 않고 기다리기만 해 파이프라인이 영원히 멈춘다. 고침: `MlKitTranslationEngine`이 60초 안에 모델을 못 받으면 네트워크 실패(`TranslationError.Network`)로 알린다 → 결과 시트가 안내를 보여 주고 버튼이 풀린다. 받기는 ML Kit이 이어 가므로 다시 시도하면 이어서 받는다. 단위 테스트 1건 추가.
- 증상 2: 하단 시트로 결과를 볼 때 자동 번역 주기마다 깜빡임. 원인: 결과가 바뀌면 시트 창을 지우고 새로 만들어 올라오는 애니메이션이 다시 돈다. 고침: 하단 시트(목록)가 떠 있으면 창은 두고 내용만 바꾼다(`sheetOutcome` 상태). 번역 순간 캡처를 위해 잠깐 숨기는 것은 그대로다.
- 변경: `translate/MlKitTranslationEngine` · `overlay/OverlayController`. pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `gradlew testDebugUnitTest` · `flutter build apk --debug` 통과. 에뮬레이터 · 기기 확인 전.
- 남은 일: 기기에서 Wi-Fi 연결 상태로 모델을 받은 뒤에도 안 끝나면 logcat(`TranslationPipeline` · `ScreenTextRecognizer`)로 단계별 시간을 다시 본다.

## 2026-10-02 · 드래그 영역에서는 자동 번역 끄기 · 선택 불가 (NA-26, NA-16, 이슈 #71, 브랜치 `feat/71-auto-off-on-drag`)
- 규칙: 캡처 영역 종류가 드래그가 되면 자동 번역이 꺼진다. 드래그인 동안은 켤 수 없다 (버블 '설정' 메뉴와 앱 설정 화면 모두 비활성). 전체 화면 · 고정 영역은 그대로.
- 네이티브(`SettingsRepository`): `setCaptureRange(DRAG_REGION)`이 같은 편집에서 자동 번역을 끈다. `setAutoTranslate(true)`는 드래그면 무시. 읽을 때도 드래그면 자동 번역을 꺼짐으로 본다(이미 저장된 조합 보정). 오버레이는 설정 흐름을 그대로 받으므로 감시가 멈추고 버튼의 '자동' 배지도 함께 사라진다.
- 버블 메뉴: `MenuOption.enabled` 추가, 비활성 줄은 흐리게 하고 누를 수 없다. 문구 "자동 번역: 드래그 영역에선 사용 불가"(`overlay_setting_auto_translate_drag`).
- 앱 설정: `AutoTranslateSettings.available`(드래그면 false) → 스위치 · 항목 비활성, 설명이 안내 문구(`settingsAutoTranslateDragUnavailable`)로 바뀐다. 단위 테스트 2건 추가.
- 변경: `SettingsRepository.kt` · `FloatingButton.kt` · `OverlayController.kt` · `strings.xml`(영·한) · ARB(영·한) · 설정 화면 · 자동 번역 ViewModel. pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 에뮬레이터 · 기기 확인 전.

## 2026-10-02 · 자동 번역 영역 변경 반영 · 버튼 '자동' 배지 (NA-26, NA-18, 이슈 #69, 브랜치 `fix/69-auto-area-change-badge`)
- 버그: 자동 번역을 켠 뒤 캡처 영역 종류(전체 · 드래그 · 고정)를 바꿔도 켤 때 쓰던 영역(`lastRegion`)으로 계속 번역됐다. 이제 영역 종류나 고정 영역이 바뀌면 이전 영역의 감시 · 결과를 걷고 영역을 비운다. 다음 버튼 탭이 새 영역 종류로 시작한다.
- 버튼: 자동 번역이 켜져 있으면 현재 영역 종류 아이콘 오른쪽 아래에 작고 둥근 "자동/Auto" 배지를 띄운다 (색은 오버레이 테마 primary · onPrimary).
- 변경: `overlay/OverlayController` · `overlay/FloatingButton` · `strings.xml` 영어 · 한국어 1줄. pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `gradlew testDebugUnitTest` · `flutter build apk --debug` 통과. 에뮬레이터 · 기기 확인 전.
- 참고: 열려 있는 옛 PR #9 · #30–#44는 develop과 충돌이 많아(30여 파일) 합치지 않았다. 사용자 결정 대기.

## 2026-10-02 · 빠른 언어 메뉴 재디자인 (NA-18, 이슈 #67, 브랜치 `feat/67-quick-language-header`)
- 플로팅 버튼 버블의 "빠른 언어"를 번역기 앱 모양으로 바꿨다: 위에 "원문 ▾ ⇄ 번역 ▾" 막대, 아래에 고정 높이 스크롤 목록(작고 둥근 알약 모양). 막대 한쪽을 누르면 그쪽이 선택 상태가 되고 목록에서 고르면 그쪽이 바뀐다. ⇄는 두 언어를 맞바꾼다(원문이 자동이면 비활성). 설계는 D-041.
- 변경: `overlay/FloatingButton`(`LanguageMenu` 새로 작성) · `overlay/OverlayController` · `strings.xml` 영어 · 한국어 1줄(맞바꾸기 설명). pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `gradlew assembleDebug testDebugUnitTest` 통과. 에뮬레이터 · 기기 확인 전.
- 다음: 플로팅 버튼 아이콘에 자동 번역 모드 배지.

## 2026-10-02 · 플로팅 버튼 자리 · 서비스 꺼짐 (NA-18, 이슈 #65, 브랜치 `fix/65-floating-button-placement`)
- 증상: 버튼이 놓은 자리에 안 머물고 알림(서비스)이 꺼진다. 기기 재현은 못 했고(에뮬레이터 확인 안 함) 코드에서 찾은 원인 후보를 막았다.
- 고침: (1) 놓은 자리(가장자리 · 높이 비율)를 SharedPreferences에 저장해 서비스가 다시 켜지거나 프로세스가 새로 떠도 같은 자리에 뜬다 (전엔 프로세스 메모리에만 있어 초기 위치로 돌아갔다). (2) 끌기가 시스템에 의해 취소(ACTION_CANCEL)되면 닫기 영역 위여도 서비스를 끄지 않는다. (3) 이미 도는 중에 모르는 명령이 오면 서비스를 끄지 않는다. (4) 화면 공유가 시스템에 의해 끝나 서비스가 꺼질 때 로그를 남긴다 (기기에서 원인 확인용: logcat `TranslatorService`).
- 가장자리에 붙는 동작은 설계대로 그대로다.
- 변경: `overlay/OverlayController` · `overlay/OverlayWindow`(ButtonGestures 취소 구분) · `service/TranslatorService`. pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 기기 확인 전: 계속 꺼지면 logcat에서 "시스템이 화면 공유를 끝냈다"가 보이는지 알려 달라.

## 2026-10-02 · 빠른 설정 타일 (NA-25, 이슈 #63, 브랜치 `feat/63-quick-settings-tile`)
- 알림 패널의 "화면 번역" 타일로 번역을 켜고 끈다. 켜짐이면 타일이 활성, 꺼짐이면 비활성이며 부제가 켜짐 · 꺼짐 · 시작 중으로 바뀐다. 꺼진 상태에서 누르면 캡처 동의 창이 뜨고 동의하면 서비스가 시작된다(앱 화면과 같은 경로). 오버레이 권한이 없으면 앱을 열어 권한 안내로 보낸다. 실행 중에 누르면 서비스를 끈다.
- 네이티브: `service/TranslateTileService`(타일 갱신 · 탭 처리) · `service/TileAction`(탭 동작 결정, 안드로이드 무관). 설계는 D-040.
- 변경: Manifest(`TranslateTileService` 추가, BIND_QUICK_SETTINGS_TILE), `strings.xml` 영어 · 한국어 4줄. pubspec · Gradle 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · Android 단위 테스트(`TileActionTest` 4개) · `gradlew assembleDebug` 통과. 기기 확인 전 (알림 패널 편집에서 타일 추가 → 탭).
- 남은 일: 보류 중인 AI 번역(3단계) · 단어장 · 서버를 제외한 명세 기능은 모두 구현됨.


## 2026-10-02 · 텍스트 선택 번역 (NA-24, 이슈 #61, 브랜치 `feat/61-text-selection-translate`)
- 다른 앱에서 글자를 고르고 메뉴의 "화면 번역"을 누르면 작은 팝업이 떠서 번역문을 보여 주고 복사할 수 있다. 캡처 권한 · 서비스 없이 혼자 돌고, 원문 언어는 ML Kit이 감지, 대상 언어는 앱 설정을 따른다. 번역에 성공하면 번역 기록(NA-23)에 남는다. 이미 대상 언어인 글 · 모델 없음 · 네트워크 실패는 결과 시트와 같은 문구로 안내한다.
- 네이티브: `selection/ProcessTextActivity`(뷰로 그린 팝업, 바깥 탭 · 닫기로 원래 앱 복귀) · `selection/SelectionTranslator`(엔진 호출 · 결과 분류, 안드로이드 무관). `ResultSheet`의 실패 문구 함수를 `translationFailureText`로 공개해 재사용.
- 변경: Manifest(`ProcessTextActivity` 추가, PROCESS_TEXT 인텐트 필터), `values/styles.xml`(`SelectionTheme` 투명 창), `strings.xml` 영어 · 한국어 2줄. pubspec · Gradle 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · Android 단위 테스트(`SelectionTranslatorTest` 5개) · `gradlew assembleDebug` 통과. 기기 확인 전 (다른 앱에서 글자 선택 → 메뉴 "화면 번역").
- 남은 일: NA-25 빠른 설정 타일.

## 2026-10-02 · 앱 UI 다국어 점검 (FL-15, 이슈 #59, 브랜치 `feat/59-app-localization`)
- 점검 결과 Flutter 화면 문구(ARB 한국어 · 영어, `flutter gen-l10n`)와 네이티브 문구(`values/strings.xml` 영어 + `values-ko`)는 앞선 작업에서 이미 모두 옮겨져 있었다. 화면에 남은 한글 · 영어 하드코딩 없음 (남은 한글은 로그 · 개발자용 오류뿐). 언어 이름은 데이터라서 D-014대로 `SupportedLanguage`에 두고 화면 언어에 맞춰 보여 주며, 오버레이는 기기 로케일로 언어 이름을 만든다.
- 앱 화면 언어는 기기 언어를 따르고(한국어 · 영어 외에는 한국어), 명세에 없어 앱 안 언어 선택은 만들지 않았다.
- 새로 추가: `test/l10n_parity_test.dart` — ARB 영어 · 한국어 키 · 자리표시자, strings.xml 영어 · 한국어 이름 · 서식 자리표시자가 어긋나면 실패한다.
- 변경: 테스트 1개만. pubspec · Gradle · Manifest · 앱 코드 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 기기 언어를 영어로 바꿔 보는 확인은 안 함.
- 남은 일: NA-24 텍스트 선택 번역 · NA-25 빠른 설정 타일.

## 2026-10-02 · 로컬 DB · 번역 기록 (NA-23, FL-13, 이슈 #57, 브랜치 `feat/57-translation-history`)
- 번역 결과가 기기의 Room DB에 저장되고, 기록 화면에서 목록 · 검색 · 한 줄 삭제 · 전체 삭제를 한다. 홈 "최근 기록"도 실제 기록(기간 필터 전체 · 오늘 · 이번 주, 최신 3개), "전체 보기"는 기록 화면(`/history`)으로 간다.
- 네이티브: `data/history`(`AppDatabase` · `HistoryDao` · `HistoryRepository`), `AppGraph.historyRepository`, Pigeon `HistoryHostApi` + `TranslationRecord`. `OverlayController`가 번역이 화면에 오를 때 `onTranslated`로 알리고 서비스가 저장한다. 설계는 D-039.
- Flutter: `features/history`(domain · data · di · `HistoryViewModel` · `HistoryScreen` · `HistoryCard`), 홈 최근 기록 연결, ARB 6줄, 테스트 `history_view_model_test`.
- 변경: Gradle(KSP 플러그인 · Room 2.8.5 의존성 · 스키마 내보내기), `android/settings.gradle.kts`, Pigeon 재생성. Manifest · pubspec 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · Android 단위 테스트(`HistoryRepositoryTest`) · `flutter build apk --debug` 통과. 기기 확인 전 (번역 후 기록에 쌓이는지, 검색 · 삭제).
- 남은 일: FL-15 앱 UI 다국어 · NA-24 텍스트 선택 번역 · NA-25 빠른 설정 타일.

## 2026-10-02 · 온보딩 첫 실행 연결 · 정보 화면 실제 값 (FL-01, FL-14, 이슈 #55, 브랜치 `feat/55-onboarding-about`)
- 온보딩이 첫 실행에만 뜬다. `startLocationProvider`(router.dart)가 저장된 설정의 `onboardingCompleted`를 읽어 시작 화면(온보딩 / 홈)을 정하고, 앱은 그 값이 나올 때까지 빈 화면을 둔다. 설정을 못 읽으면 온보딩부터 보여 준다.
- 온보딩 마지막 페이지에서 고른 대상 언어는 `TargetLanguageViewModel`로 바로 저장(기본은 저장된 값 · ko), 시작하기를 누르면 `CompleteOnboarding`으로 완료 표시 후 권한 안내(FL-02, 이미 실제 권한 확인에 연결됨)로 간다. 권한 안내를 끝내기 전에 앱을 닫아도 온보딩은 다시 안 나오며, 권한이 없으면 홈이 권한 안내로 가는 버튼을 보여 준다.
- 정보 화면: 버전은 `package_info_plus`(about 기능에 domain/data/di 추가, `GetAppInfo`), 오픈소스 라이선스는 `showLicensePage`(버전 표시). 개인정보처리방침은 주소 미정이라 그대로 "준비 중".
- 변경: pubspec에 `package_info_plus` 추가. Gradle · Manifest · 네이티브 변경 없음. 온보딩 · 정보 화면 위젯 테스트 추가, 스크린샷 테스트는 실제 라우터로 열도록 정리.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 기기 확인 전 (첫 실행 온보딩 → 재실행 시 홈 직행, 정보 화면 버전 확인).
- 남은 일: NA-23 로컬 DB + FL-13 번역 기록.

## 2026-10-02 · 표시 · 캡처 모드 설정 연결 (FL-07, FL-08, 이슈 #53, 브랜치 `feat/53-display-capture-settings`)
- 설정 화면의 기본 캡처 모드 · 표시 방식 · 버튼 크기 · 투명도 · 고정 영역 초기화가 화면 안 가짜 값이었다. `CaptureSettingsViewModel` · `DisplaySettingsViewModel`이 네이티브 설정(DataStore)을 읽고 쓴다. 캡처 모드 · 표시 방식은 플로팅 버튼 메뉴가 쓰는 값과 같아서 어느 쪽에서 바꿔도 서로 반영된다.
- 새 설정: 버튼 크기(40~72dp, 4단위, 기본 52) · 불투명도(30~100%, 10단위, 기본 100). 실행 중인 플로팅 버튼에 바로 반영: 크기가 바뀌면 `OverlayController.resizeButton`이 버튼 가운데를 유지한 채 창을 다시 키워 가장자리에 붙이고, 투명도는 컴포즈 알파(창 알파는 D-037대로 숨김 전용).
- 고정 영역 초기화: Pigeon `resetFixedRegion`이 저장된 영역을 지운다. `AppSettings.hasFixedRegion`으로 저장 여부만 알려 주고(영역 값은 네이티브 전용 유지), 없으면 버튼이 비활성이다. 지운 뒤 고정 영역 번역을 시작하면 영역을 새로 고르게 된다(NA-21).
- 변경: Pigeon `AppSettings`(buttonSizeDp · buttonOpacityPercent · hasFixedRegion) · `SettingsHostApi`(setButtonSizeDp · setButtonOpacityPercent · resetFixedRegion) + 재생성, Kotlin `Settings` · `SettingsRepository` · `OverlayController` · `FloatingButton`, Flutter 엔티티 · 유스케이스 3개 · ViewModel 2개 · 화면 · ARB 1줄 · 테스트. pubspec · Gradle · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 기기 확인 전 (버튼 크기 · 투명도가 실제로 바뀌는지 보면 된다).
- 남은 일: FL-01 · FL-14 → NA-23 · FL-13.

## 2026-10-02 · 번역 엔진 선택 저장 연결 (FL-06, 이슈 #51, 브랜치 `feat/51-engine-selection`)
- 설정 화면의 엔진 선택이 화면 안 가짜 값이었다. 새 `EngineViewModel`(`features/settings/presentation/view_models`)이 저장된 엔진(DataStore)을 읽고 쓴다. 홈의 엔진 표시도 같은 값.
- AI 엔진(Gemini · Firebase)은 보류라 비활성 유지. ViewModel `select`도 ML Kit 외에는 저장하지 않는다 (`selectable`).
- 네이티브: `TranslatorService.translationEngine(settings)`가 번역 때마다 저장된 엔진을 본다. 지금 구현된 엔진은 ML Kit뿐이라 AI 값이 저장돼 있어도 로그를 남기고 ML Kit으로 대체한다. 엔진이 추가되면 분기만 늘리면 된다.
- 변경: Kotlin `TranslatorService.kt`, Flutter 화면 2개 · ViewModel · 테스트 추가. pubspec · Gradle · Manifest · Pigeon 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · `flutter build apk --debug` 통과. 기기 확인 전.
- 남은 일: FL-07 · FL-08 → FL-01 · FL-14 → NA-23 · FL-13.

## 2026-10-02 · 대상 언어 · 언어 모델 관리 실제 연결 (FL-04, FL-05, 이슈 #49, 브랜치 `feat/49-language-models`)
- 대상 언어: 선택 화면 · 홈 · 언어 탭이 `TargetLanguageViewModel`로 같은 값(DataStore)을 읽고 쓴다. 고르면 바로 저장하고 닫는다 (이전엔 화면 안 가짜 값).
- 언어 모델: 새 Pigeon `ModelHostApi`(받은 목록 · 받기 · 삭제). 네이티브 `LanguageModelManager`가 ML Kit `RemoteModelManager`로 처리. Flutter는 `features/models`(domain · data · di · `LanguageModelsViewModel`) 신설. 홈의 "모델 N개 준비됨"도 실제 값.
- Wi-Fi 전용: 설정 `wifiOnlyModelDownload`(기본 켬, DataStore 키 `wifi_only_model_download`)를 Pigeon `AppSettings` · 엔티티 · 유스케이스까지 추가. 번역 중 자동 내려받기(`MlKitTranslationEngine`)도 이 값을 받을 때마다 읽는다(`downloadPolicyProvider`).
- 진행률: ML Kit이 진행률 · 취소를 주지 않아 "받는 중"은 진행 중 표시(좌우로 오가는 막대)만 나온다. `AppProgressBar`의 `value`를 null 허용(진행 중)으로 확장. 실패하면 "받지 못했어요" 표시 후 다시 받을 수 있다.
- 변경: `pigeons/translator_api.dart`(+ 생성 코드 재생성), ARB(`modelsDownloading` 퍼센트 제거, `modelsDownloadFailed` 추가). 의존성 · Manifest 변경 없음.
- 확인: `flutter analyze` 0 · `flutter test` · Android 단위 테스트 · `flutter build apk --debug` 통과. 기기 확인 전 (실제 받기 · 삭제 · Wi-Fi 전용에서 모바일 데이터 실패).
- 남은 일: FL-06 엔진 선택 → FL-07 · FL-08 → FL-01 · FL-14 → NA-23 · FL-13.

## 2026-10-02 · 플로팅 버튼 자리 검은 네모 수정 (NA-18, 이슈 #47, 브랜치 `fix/47-black-square-flash`)
- 증상: 오른쪽 가장자리 버튼 자리에 버튼 대신 검은 네모가 순간 보인다.
- 원인: 캡처 때 버튼 창의 루트 뷰를 `INVISIBLE` ↔ `VISIBLE`로 바꿨다. 루트 뷰가 보이지 않으면 창의 서피스가 해제되고 다시 보일 때 새로 만들어져, 첫 프레임이 그려지기 전 버퍼가 검게 비친다 (버튼 창 크기 = 정사각형). 결과 창도 같은 방식이라 같은 위험.
- 수정: `OverlayWindow.setHidden()` 추가 — 창은 그대로 두고 창 알파를 0 ↔ 1로 바꾸고, 숨은 동안 `FLAG_NOT_TOUCHABLE`을 건다. 캡처는 숨긴 뒤 새 프레임을 기다리므로(`awaitFreshFrame`) 버튼이 찍히지 않는 것은 그대로. `OverlayController`의 뷰 가시성 호출 11곳을 교체. 설정 · 의존성 변경 없음.
- 기록: D-037. 기기 확인 전 (에뮬레이터 없음).

## 2026-10-02 · 인식 후처리 (NA-11, 이슈 #45, 브랜치 `feat/45-ocr-postprocess`)
- #44(`feat/43-incremental-ocr`) 위에 쌓았다 (merge 전). 문자 인식 결과의 흔한 오인식을 번역 전에 보수적으로 고쳐 오역을 줄인다 (translation.md 개선 계획 4번).
- `ocr/OcrPostProcessor.kt` 추가(순수 Kotlin) + `TranslationPipeline`에서 `OcrCleaner` 뒤 · `OcrBlockMerger` 앞에 호출. 규칙은 translation.md 참고. 설정 · 의존성 변경 없음.
- 테스트 `OcrPostProcessorTest` 추가. 고치지 말아야 할 것(mp3 · win10 · 주소 · 파일 경로 · Illinois · McIntyre · 한글 섞인 줄)도 검증.
- 한계: 1이 i인지 l인지는 알 수 없어 l로 본다(사전 단어는 예외). 영어만. 기기 실측 전.

## 2026-10-02 · 자동 번역 — 바뀐 영역만 다시 인식 (NA-11, 이슈 #43, 브랜치 `feat/43-incremental-ocr`)
- 자동 번역(`incremental`)에서 직전에 읽은 화면과 64×128 밝기 격자를 견줘 변한 칸 주변만 잘라 읽고, 안 바뀐 블록은 이전 결과를 쓴다. 바뀐 칸이 없으면 이전 결과 그대로. 순수 로직 `ocr/ChangedRegions.kt`(+ 테스트), 연결은 `ScreenTextRecognizer`.
- 통째로 읽는 경우: 기준이 없음 · 원문 언어 · 화면 크기가 달라짐, 40% 넘게 변함, 영역 7곳 이상 · 화면 절반 넘음, 블록 자리를 모름, 색을 뒤집어 읽은 화면. 수동 번역은 그대로 전체 인식.
- 변경: `ocr/ChangedRegions.kt` 추가, `ScreenTextRecognizer` · `TranslationPipeline`(recognize에 incremental 인자) · `TranslatorService` · `OverlayController`(자동 번역만 incremental). 설정 · 의존성 변경 없음.
- 확인: Android 단위 테스트 · `flutter analyze` · `flutter test` · `flutter build apk --debug` 통과. 기기 실측(번역 시간 로그의 ocr ms) 전.
- 남은 일: 기기에서 효과 측정, 인식 후처리(별도).

## 2026-10-02 · 번역 점진 표시 (NA-11, 이슈 #41, 브랜치 `feat/41-progressive-display`)
- 수동 번역이 모든 블록이 끝나야 뜨던 것을, 끝난 블록부터 먼저 보여 주고 마지막에 전체 결과로 바꾼다 (translation.md 개선 계획 2번).
- `TranslationPipeline`: `run(onPartial)` 추가, `translateAll(onProgress)`가 블록이 끝날 때마다 알림, `TranslationAssembler.assemblePartial`(안 끝난 블록은 뺌). `OverlayController.translate`가 부분 결과를 시트로 띄움. 자동 번역은 표시 시점 규칙(D-036) 때문에 제외.
- 테스트 2개 추가. analyze · test · debug 빌드 통과. 기기 확인 전 (블록이 많은 화면에서 먼저 뜨는지, 시트 교체 깜박임).
- 다음: 바뀐 영역만 다시 인식 → 인식 후처리.

## 2026-10-02 · 번역 기능 문서 (이슈 #39, 브랜치 `docs/39-translation-doc`)
- [translation.md](translation.md) 추가: 파이프라인 현황, 캐시 방침, 개선 계획. AI 번역은 API 키가 필요해 보류로 기록.
- 다음: 단계별 시간 측정 → 점진 표시.

## 2026-10-01 · 버블 — 이름표를 아이콘 옆(화면 안쪽)으로 (NA-18, 이슈 #37, 브랜치 `feat/37-bubble-label-side`)
- 이름표가 아이콘 아래 고정이라 버블끼리 겹침 → 이름표를 아이콘 옆에 둔다. 오른쪽 가장자리면 아이콘 왼쪽, 왼쪽 가장자리면 오른쪽.
- `FloatingButton.kt`: `BubbleRing` 칸을 아이콘 + 이름표 가로 배치로 바꾸고, 창 안쪽 폭에 이름표 폭을 더함 (`BUBBLE_LABEL_WIDTH_DP` 등). `OverlayGeometry.bubbleAngles` 아래 여유를 아이콘 기준으로 줄임.
- analyze · test · debug 빌드 통과. 기기 확인 전 (가장자리 양쪽, 위 · 아래 끝에서 이름표 겹침 · 잘림 확인 필요).

## 2026-10-01 · 자동 번역 — 표시 시점 · 숨김 일반화 · 블록 캐시 · 켜면 바로 번역 (NA-26, 이슈 #35, 브랜치 `feat/35-auto-show-delay-cache`)
- #34(`feat/33-auto-speed`) 위에 쌓았다 (스택 #24→#28→#30→#32→#34, 아직 merge 전). 설계는 D-036.
- **이전 번역 숨김**을 자동 전용에서 일반 옵션으로: 설정 "표시" 섹션으로 옮기고, 자동 번역이 꺼져도 덮어쓰기 결과에 적용(감시는 숨김만 하고 다시 번역은 안 함). 덮어쓰기 결과는 숨김이 켜져 있으면 터치를 통과시킨다.
- **자동 번역 설정은 "새 번역을 보여 줄 시점" 하나**(바로 / 1 · 2 · 3초): 번역은 화면이 멈추면 바로 시작하고, 올리는 것만 조작이 끝난 뒤 N초까지 미룬다 (그 사이 또 조작하면 취소). #34의 "다시 번역 속도"(확인 간격 · 대기 시간)는 없앴다. 확인 간격은 고정 0.5초(변화가 없으면 최대 1.5초).
- **블록 캐시**(`BlockCache`, 파이프라인): 원문 글자 기준으로 언어 감지 결과와 성공한 번역을 LRU(512개)로 기억해 안 바뀐 블록은 감지 · 번역을 건너뛴다. 설정 없음. 엔진 안에 있던 128개 캐시는 파이프라인 캐시로 합쳤다.
- **자동 번역 켜면 바로 번역**: 버블 메뉴에서 켜면 버튼을 한 번 누른 것처럼 바로 번역을 시작한다. 앱 설정 화면에서 켜면 우리 앱 화면을 찍게 되므로 시작하지 않고, 버튼을 누르면 그때부터 지켜본다.
- 바꾼 곳: Pigeon `AppSettings`(`autoCheckIntervalMs` · `autoSettleMs` · `autoHideMs` 제거, `autoShowDelayMs` · `hideAfterInteractionMs` 추가; 저장 키 `auto_hide_ms`는 그대로 이어받음), `AutoTranslateConfig`/Tracker/Watcher, `OverlayController`, 설정 화면 · 문구(ARB 한/영).
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트 통과(캐시 · 감시 · 표시 시점 신규) · debug APK 빌드. 기기 확인은 사용자 몫.

## 2026-10-01 · 자동 번역 설정 합치기 — "다시 번역 속도" 하나로 (NA-26, 이슈 #33, 브랜치 `feat/33-auto-speed`)
- #32(`feat/31-bubble-hover-select`) 위에 쌓았다 (스택 #24→#28→#30→#32, 아직 merge 전).
- 설정의 "화면 확인 간격"과 "조작이 끝난 뒤 대기 시간"이 헷갈려 **"다시 번역 속도"** 한 줄(빠르게 · 보통 · 절약 · 최대 절약)로 합쳤다. 설계는 D-035.
- 바꾼 곳: `AutoSpeed` 열거형(도메인), `ChangeAutoSpeed` 유스케이스(기존 `ChangeAutoCheckInterval` · `ChangeAutoSettle` 대체), ViewModel `setSpeed`, 설정 화면 · 문구(ARB 한/영). Pigeon · 네이티브 · 저장 키는 그대로.
- 확인: flutter analyze 0 · flutter test 통과 · debug APK 빌드. 기기 확인은 사용자 몫.

## 2026-10-01 · 버블 — 손가락 올리면 앞으로 · 끌었다 놓으면 선택 · 이름표 잘림 수정 (NA-18, 이슈 #31, 브랜치 `feat/31-bubble-hover-select`)
- #30(`feat/29-auto-translate-responsive`) 위에 쌓았다 (버블 코드가 아직 develop에 없음).
- 길게 누른 채 손가락을 버블 위로 옮기면 그 버블이 이름표와 함께 맨 앞으로 올라오고 커진다. 그 위에서 떼면 눌린 것으로 처리 (`ButtonGestures.onHold` · `onHoldRelease`, `OverlayGeometry.bubbleHit`, 판정 반경 34dp).
- 이름표 잘림: 버블 칸에 알파 < 1(눌림 0.85)을 주면 Compose가 칸 크기 오프스크린 레이어로 그려 칸보다 넓은 이름표가 잘렸다 → `graphicsLayer` + `CompositingStrategy.ModulateAlpha`로 바꾸고 눌림은 크기만 바꾼다.
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트(버블 위 판정) 통과 · debug APK 빌드. 기기 확인은 사용자 몫.
- 남은 일: 기기에서 ① 길게 눌러 손가락을 버블로 옮길 때 앞으로 올라오는지 ② 떼면 해당 메뉴가 열리는지 ③ 눌렀다 떼도 이름표가 안 잘리는지.

## 2026-10-01 · 자동 번역 반응성 — 이전 결과 숨김 · 바로 번역 · 번역 중 취소 (NA-26, 이슈 #29, 브랜치 `feat/29-auto-translate-responsive`)
- #28(`feat/27-settings-bubble`) 위에 쌓았다 (자동 번역 코드가 아직 develop에 없음). 설계는 D-034.
- 설정 "자동 번역"에 **이전 번역 숨김 시간**(바로 · 0.5 · 1 · 2초 · 안 숨김) 추가, **조작 뒤 번역까지 기다리는 시간**에 "바로" 선택지(0) 추가, 확인 간격에 0.5초 추가.
- 네이티브: `Settings.autoHideMs` + Pigeon `setAutoHideMs`, `AutoTranslateTracker`(`isStale` · `observe` · `onCanceled`, 대기 0 = 멈춘 걸 본 즉시), `AutoTranslateWatcher`(번역을 자식 작업으로 돌리며 계속 감시, 캡처 뒤 화면이 또 바뀌면 취소), `OverlayController`(낡은 결과 숨김 · 취소 시 복원).
- Flutter: `ChangeAutoHide` 유스케이스, 설정 화면 항목 · 문구(ko/en).
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트 통과(감시 취소 · 숨김 시험 추가) · debug APK 빌드. 기기 확인은 사용자 몫.
- 남은 일: 기기에서 ① 스크롤 뒤 이전 번역이 바로 사라지는지 ② 조작 직후 번역이 빨리 뜨는지, 번역 중 다시 스크롤하면 취소되고 멈춘 뒤 다시 번역되는지 ③ 발열 · 배터리 체감 (확인 간격을 줄여서 늘었을 수 있음).

## 2026-10-01 · 버블 메뉴에 '설정' 추가 (이슈 #27, 브랜치 `feat/27-settings-bubble`)
- 자동 번역 설정이 #24(`feat/23-auto-translate`)에만 있어 그 브랜치 위에 쌓았다. #24가 develop에 merge된 뒤 이 PR을 merge한다. 설계는 D-033.
- 길게 누르기 버블이 3개 → 4개(캡처 범위 · 결과 표시 · 빠른 언어 · **설정**). 설정 버블을 누르면 옵션 메뉴: 인식 언어(자동 · English · 한국어 · 日本語 · 中文)와 자동 번역 켜기 · 끄기.
- 네이티브: `Settings.sourceLanguage`(기본 `auto`, Pigeon 없이 네이티브 전용) + `SettingsRepository.setSourceLanguage`, `TranslatorService`가 문자 인식에 반영, `OverlayController` 설정 메뉴, `OverlayGeometry.bubbleAngles` 4개 · 반지름 96dp, `Symbol.SETTINGS`와 아이콘 글꼴 부분집합에 settings 글자 추가, 문구(ko/en).
- **기기 확인 후 수정**: 빠른 언어 메뉴를 두 열("번역할 언어"=인식 · "번역될 언어"=결과)로 바꾸고 고른 뒤에도 열어 둠. 설정 버블에서 언어 목록 삭제(자동 번역만). 버블 창에 바깥쪽 · 둘레 여백을 줘 눌림 · 90° 몰림에서 잘리지 않게 하고, 버블 그리는 순서(위쪽이 앞 · 누른 버블 맨 앞)로 이름표가 가려지지 않게 함. 덮어쓰기 번역문은 원문 크기(비율 허용 0.6~1.8배, 10~40sp)에 맞추고 가운데 정렬.
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트 통과 · debug APK 빌드. 기기 확인은 사용자 몫.
- 남은 일: 기기에서 ① 버블 4개가 겹치지 않는지(화면 위 · 아래 끝 포함) ② 인식 언어를 고정했을 때 인식이 나아지는지 ③ 앱 설정 화면에도 인식 언어를 노출할지 결정.

## 2026-10-01 · 자동 번역 (이슈 #23, 브랜치 `feat/23-auto-translate`, NA-26)
- (먼저 #20 · #22를 develop에 merge하고 그 위에서 땄다.) 설계는 D-032.
- 설정 탭에 "자동 번역"(기본 꺼짐 · 확인 간격 · 멈춘 뒤 대기 시간). Pigeon `AppSettings`에 `autoTranslate` · `autoCheckIntervalMs` · `autoSettleMs`와 setter 3개 추가 → Flutter 엔티티 · 매퍼 · 리포지토리 · 유스케이스 3개 · `AutoTranslateViewModel` · 설정 화면 섹션 · ARB(ko/en).
- 네이티브: `autotranslate/`(`FrameSignature` · `AutoTranslateTracker`(판단) · `AutoTranslateWatcher`(루프)), `ScreenCapturer.captureSignature`, `OverlayController`(자동 번역 호출 · 결과 창 숨김/교체 · 터치 통과 덮기 · 화면 꺼짐/절전 모드 시 중지), `Settings`/`SettingsRepository`(범위 보정).
- 확인: flutter analyze 0 · flutter test 통과(AutoTranslateViewModel 5개 추가) · Kotlin 단위 테스트(Tracker 12 · Watcher 5 추가) 통과 · debug APK 빌드. 기기 확인은 사용자 몫.
- 남은 일: 기기에서 ① 변화 감지 임계(`FrameSignature.CHANGE_RATIO`)가 알맞은지(헛번역 · 놓침) ② 덮기 막 터치 통과(Android 12+ 알파 보정)와 옅어지는 정도 ③ 열 · 배터리 체감 확인.

## 2026-10-01 · 글자 인식 실패 진단 · 보안 화면 판별 (이슈 #25, 브랜치 `fix/25-ocr-diagnostics`, NA-09 · NA-05)
- 증상: 구글 로그인 화면(영어 본문이 뚜렷)에서 고정 영역 모드(핀 아이콘)로 눌렀더니 '글자를 찾지 못했어요'. 설계는 D-033b.
- 코드로 확인한 것: 오버레이(시트 · 버튼)는 캡처 전에 숨기고 새 프레임을 기다려 찍는다 / 인식 · 정리 · 합치기 · 언어 판별 경로는 영어 본문을 버리지 않는다. 구글 로그인 · 결제 화면은 보안 창(FLAG_SECURE)이라, 시스템이 그 창만 검게 칠하고 상태 표시줄 등은 그대로 준다 → 기존 `isBlank`(표본 전부 검정)에 안 걸려 '글자 없음'으로 나왔을 가능성이 가장 높다. 기기 로그로 확정은 못 함.
- 고침: 글자를 못 읽었는데 인식 대상의 70% 이상이 검정이면 보안 화면 안내(`FrameStats`). 영역 모드에서 글자가 없으면 '영역을 옮기거나 키우세요' 안내(`NoTextInRegion`).
- 진단 로그(태그 `TranslatorService`, `ScreenCapturer`, `ScreenTextRecognizer`): 프레임 크기 · 나이 · 밝기 · 검정 비율, 인식 대상 크기 · 영역, 인식기별 글자 수 · 신뢰도 · 남은 글자, 블록 수, 언어 판별 결과.
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트 · 디버그 빌드. 기기 확인은 사용자 몫.

## 2026-10-01 · 글자 크기 일관화 · 인식 누락 개선 (이슈 #21, 브랜치 `feat/21-font-recall`, NA-09 · NA-10 · NA-22)
- (PR #20이 develop에 아직 없어 그 브랜치에서 땄다.) 설계는 D-031.
- 글자 크기: `OverlayFontPlan`(줄 높이 기반 공통 기준 · 0.85~1.25배 · 11~20sp), 못 맞추면 막을 늘림. `TranslatedItem.lineHeight` 추가.
- 누락: 인식 1600px · 긴 줄 신뢰도 0.3 · 글자 적은 화면은 색 반전 재시도 · 짧은 글자 언어 판별 보정(Language ID 0.2 → 글자 체계 짐작).
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트 · 디버그 빌드 통과. 기기 확인은 사용자 몫.
- 남은 일: 기기에서 글자 크기 · 누락 개선 체감, 시간 로그(`ScreenTextRecognizer`)로 속도 영향 확인.

## 2026-10-01 · 번역 속도 · 정확도 개선 (이슈 #19, 브랜치 `feat/19-speed-accuracy`, NA-09 · NA-10 · NA-11)
- (이슈 #17 브랜치를 base로 포함: 아직 develop에 없었음.) 설계는 D-030.
- 속도: ① 자동 모드에서 인식기 3개를 항상 돌리던 것을 **직전에 잘 읽은 인식기 1개**로 먼저 읽고, 결과가 미덥지 않을 때(글자 12자 미만 · 평균 신뢰도 0.8 미만)만 나머지 둘을 병렬로 추가. ② 직전과 같은 화면(이미지 해시 동일)이면 인식 결과 재사용. ③ 같은 글자 · 언어 쌍 번역 결과 LRU 캐시(128개). ④ 쪼개진 블록을 문단으로 묶어 번역 호출 수 감소.
- 정확도: ① 인접 OCR 블록 문단 묶기(`OcrBlockMerger`: 간격 ≤0.6줄 · 글자 크기 ±25% · 왼쪽 정렬 · 가로 겹침 · 앞 블록이 문장부호로 안 끝날 때만). ② 글자 없는 줄(기호 · 숫자뿐) 제거 · 공백 정리(`OcrCleaner`). ③ 줄 끝 하이픈 낱말 이어 붙임. ④ 언어 감지: 한글 · 가나가 글자의 30% 이상이면 Language ID 결과보다 우선(ko · ja) — 한자 많은 일본어가 zh로 읽히는 문제 보정. 감지에 줄바꿈 없는 한 문단 글자를 사용.
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트(OcrCleanAndMergeTest · ScriptLanguageTest · 하이픈 테스트 추가) 통과 · debug APK 빌드. **전 · 후 시간은 사용자 기기에서 측정** (logcat 태그 `TranslatorService` "번역 시간 … total=…ms"). 이전(#11) 기준 에뮬레이터 약 7~9초, 대부분 OCR.
- 남은 일: 기기에서 시간 · 묶기 오탐(별개 UI 항목이 합쳐지는지) 확인. 필요하면 상수(`MAX_GAP_RATIO` 등) 조정.

## 2026-10-01 · 빠른 언어 편집 · 원문 위에 덮기 (이슈 #17, 브랜치 `feat/17-quick-language-overlay-result`, FL-04 · NA-22)
- (이슈 #16 버블 메뉴 · 문단형 표시 커밋을 base로 포함: 아직 develop에 없었음.) 설계는 D-029.
- 빠른 언어: 설정 탭에 "빠른 언어" 항목 → 편집 화면(`/quick-languages`)에서 언어 목록을 눌러 켜고 끔(최소 1 · 최대 8개). 버블 옵션 메뉴는 여기서 고른 언어만 보여 준다. Pigeon `AppSettings.quickLanguages` · `setQuickLanguages` 추가(기존 네이티브 전용 → Flutter와 공유), Flutter는 엔티티 · 매퍼 · 리포지토리 · `ChangeQuickLanguages` · `QuickLanguagesViewModel` · `QuickLanguagesScreen`, `LanguageList`에 다중 선택(`selectedCodes`).
- 원문 위에 덮기(NA-22): 인식한 글자 영역마다 반투명 검은 막(78%) + 그 위 원문 자리에 흰 번역문(막에 맞춰 22~8sp 자동 조절). 화면을 누르면 닫힘. `TranslatedItem.bounds`(화면 대비 비율, 영역 캡처 오프셋 반영) · `overlay/OverlayResult.kt`. 자리를 아는 번역 항목이 없으면 목록 시트로 대체.
- 확인: flutter analyze 0 · flutter test 통과(QuickLanguagesViewModel 5개) · Kotlin 단위 테스트(OverlayResultTest 3개 포함) 통과 · debug APK 빌드. 기기 확인은 사용자가 직접(에뮬레이터 확인 생략).
- 남은 일: 기기에서 막 위치 · 글자 크기 · 빠른 언어 편집 반영 확인. 설정 화면의 나머지 항목(엔진 · 캡처 모드 · 표시 방식 등)은 아직 UI만 있고 저장 연결 전(FL-06~08).

## 2026-10-01 · 버블 메뉴 · 문단형 표시 (이슈 #16, 브랜치 `feat/16-bubble-menu`, NA-18)
- 길게 누르면 버튼 주위에 카테고리 버블 3개(캡처 범위 · 결과 표시 · 빠른 언어)가 뜨고, 버블을 누르면 그 옵션 메뉴가 열린다. 기존 모드 메뉴는 "캡처 범위" 버블의 옵션 메뉴가 됐다. 설계는 D-028.
- 결과 표시에 **문단**(`paragraph`) 추가: 번역문을 블록 · 문장 구분 없이 한 문단으로 보여 줌. Pigeon `DisplayMode`에 추가 → Flutter 엔티티 · 매퍼 · 라벨 · ARB(ko/en)도 반영.
- 빠른 언어: `Settings.quickLanguages`(기본 ko · en · ja · zh, DataStore, 네이티브 전용). 고르면 대상 언어가 바뀐다. 편집 화면은 FL-04에서.
- 변경: `overlay/FloatingButton.kt`(OptionMenu · BubbleRing), `OverlayController`, `OverlayGeometry.bubbleAngles`, `ResultSheet`(문단 카드 · `paragraphText`), 아이콘 글꼴에 view_list · notes · flip_to_front 추가(D-025 방식으로 재생성), 문자열 ko/en. Pigeon 재생성.
- Notion 명세 갱신: 플로팅 버튼 · 모드 메뉴(O-02), 캡처 범위 · 인식, 오버레이 UI, 개발 기능(사용자 흐름).
- 확인: flutter analyze 0 · flutter test 통과 · Kotlin 단위 테스트(BubbleAndParagraphTest 6개 포함) 통과 · debug APK 빌드. **기기 확인 못 함**: 에뮬레이터가 켜지지 않거나(AVD 정의 파일 누락) 켜져도 화면이 검고 MainActivity가 실행되지 않음.
- 남은 일: 기기에서 버블 위치(화면 위 · 아래 끝, 왼쪽 가장자리) · 옵션 메뉴 · 문단 표시 확인, "원문 위에 덮기"는 NA-22 전까지 목록으로 보임.

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

## AI 번역 엔진 (NA-13, #94)
- Gemini REST 엔진 + ML Kit 대체 엔진 추가. 키 제공자는 비어 있어(키 저장 방식 결정 대기) 동작은 아직 ML Kit과 같다. 새 의존성은 테스트용 org.json뿐. 단위 테스트 6개 추가.

## Gemini API 키 등록 BYOK (NA-13, #96)
- 설정에서 본인 Gemini 키 입력 → Keystore 암호화 저장, 키 값은 Flutter로 내보내지 않음(저장 여부만). 키가 있어야 Gemini 선택 가능, 키 삭제 시 ML Kit 복귀. Pigeon: hasApiKey/setApiKey/clearApiKey. 새 UI 컴포넌트 AppTextField. 기기 실측 전.

## API 키 보기/수정 + 등록됨 오표시 수정 (NA-13, #98)
- 원인: 키 존재를 저장 항목 유무로만 판단해, 백업 복원된(못 읽는) 암호문도 등록됨으로 보임. 이제 복호화 성공해야 등록됨, 키 저장소를 백업에서 제외. 등록된 키는 가려서 채우고 보기 토글 · 수정 · 삭제. Pigeon hasApiKey → getApiKey(String?).
