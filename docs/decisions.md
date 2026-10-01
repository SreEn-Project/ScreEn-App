# 설계 결정 기록

새 결정은 맨 아래에 추가한다. 형식: 번호 · 날짜 · 결정 · 이유.

## D-001 · 2026-09-29 · 역할 분담
Flutter는 앱 UI, 번역 서비스(캡처 · 오버레이 · OCR · 번역)는 Kotlin 네이티브.
이유: 서비스가 Flutter 엔진 없이 돌아야 배터리 · 속도에 유리.

## D-002 · 2026-09-29 · 접근성 API 미사용
화면 글자는 MediaProjection 캡처 + OCR로만 얻는다.
이유: Play 정책 · 권한 부담.

## D-003 · 2026-09-29 · 서버 · 단어장 보류
자체 API 서버는 미정(SV- 기능 보류), 단어장(AD-)은 핵심 기능 이후.

## D-004 · 2026-09-29 · 문서 위치
작업 문서는 `docs/`, 작업 규칙은 루트 `CLAUDE.md`. 기능 명세 원본은 Notion.

## D-005 · 2026-09-29 · 앱 이름 · applicationId 보류
앱 이름 미정. applicationId `com.example.translation_poc_app` 유지, 표시 이름은 임시 "화면 번역" / "Screen Translate".
Play 출시 전에 한 번에 바꾼다 (출시 후에는 applicationId 변경 불가).

## D-006 · 2026-09-29 · 상태 관리 Riverpod 유지
비동기 상태(AsyncValue), DI 겸용, 테스트 override가 네이티브 연동 앱에 맞음. 사용자가 Riverpod에 익숙하지 않으므로 첫 화면에서 패턴을 문서화한다.

## D-007 · 2026-09-29 · 디자인 방향
화이트 톤 + 연한 초록 포인트, 미니멀리즘 · 모노톤. Material 3, 그림자 대신 테두리. 상세는 [design.md](design.md).
→ D-008로 대체.

## D-008 · 2026-09-29 · 디자인 토큰 확정 (D-007 대체)
사용자가 팔레트 · 모양을 구체적으로 정함: 배경 #F6F8F5, primary #044B39, primaryContainer #C8EFC1, 카드 24dp + 옅은 그림자(y8 blur24 6%), 알약 버튼 · 칩, 그라데이션은 홈 상단 카드에만, 파랑 계열 금지.
테두리 대신 그림자로 구분하도록 바뀜. ColorScheme에 없는 값(배경, accent, 그라데이션, 그림자)은 `AppTokens` ThemeExtension으로 둔다.
다크 모드는 배경 · surface만 지정받아 나머지는 대비 기준으로 정함 (design.md 표).

## D-010 · 2026-09-29 · 브리지 구조 (NA-01)
- Pigeon 파일은 하나(`pigeons/translator_api.dart`)로 시작하고, 커지면 기능별로 나눈다.
- 네이티브는 Pigeon 타입을 `bridge/` 안에서만 쓴다. 서비스 · 데이터는 자체 모델(`Settings`, `RunState`)을 쓰고 `Mappers.kt`에서 변환 → 서비스가 Flutter 코드 생성물에 묶이지 않음.
- ~~Flutter는 Pigeon 열거형(EngineType 등)을 도메인에서 그대로 쓴다.~~ → D-018에서 도메인 자체 열거형으로 바꿈.
- 이벤트 채널은 네이티브 리스너가 하나뿐이라 Flutter에서 `TranslatorEventBus`로 한 번만 구독해 나눠 쓴다. 현재 값은 조회 API로 가져온다.
- 공유 객체는 Application 클래스 대신 `AppGraph` object (Manifest 변경 없음). 의존성이 늘면 DI 검토.

## D-011 · 2026-09-29 · compileSdk 37
permission_handler_android 14.1이 compileSdk 37을 요구. 설치된 플랫폼 이름이 `android-37.0`이라 `release(37) { minorApiLevel = 0 }`로 지정. AGP 9.1은 36까지 권장한다는 경고가 나오지만 빌드는 됨. AGP를 올릴 때 다시 확인.

## D-012 · 2026-09-29 · Git 흐름
main / develop + 작업 브랜치(Git Flow 축소판). 작업 브랜치 push는 자유, ~~develop · main merge는 사용자 승인 후~~ → D-022. 상세는 [git.md](git.md).
그전까지 만든 기반 세팅 · 디자인 · NA-01 · NA-16은 규칙 이전 작업이라 `main` 초기 커밋 하나로 올리고 `develop`을 거기서 딴다.

## D-013 · 2026-09-29 · UI 퍼블리싱 먼저
사용자 요청으로 1단계 Flutter 화면을 자리 표시 데이터로 먼저 만들고 검증받는다. 브랜치 `ui/stage1-screens` 하나에 화면(기능 ID)별로 커밋하고, 검증 뒤 develop에 merge한다.

## D-014 · 2026-09-29 · 언어 이름은 데이터로
ML Kit 59개 언어의 한국어 · 영어 · 자기 언어 이름과 원문 인식 가능 여부는 `features/language/domain/supported_language.dart`에 둔다. UI 문구가 아니라 목록 데이터라 ARB에 118줄을 넣지 않음.
원문 인식 가능 = ML Kit 문자 인식 v2가 읽는 문자(라틴 · 한중일 · 데바나가리). 나머지(아랍 · 키릴 · 태국 등)는 "대상 언어 전용".

## D-015 · 2026-09-29 · 앱 자체 UI 컴포넌트
사용자 피드백: Material 느낌이 강함 → 참고 이미지(부드러운 색 그림자, 가운데 제목, 떠 있는 탭바)처럼 앱 자체 컴포넌트로 관리.
`lib/core/ui/`에 컴포넌트를 두고 화면은 이것만 쓴다. 물결 효과 끄고 눌림 효과(`Pressable`). 그림자는 primary로 물들이고 primary 버튼엔 빛. 팔레트(D-008)는 유지. 목록은 design.md "컴포넌트".
Scaffold · TextField · Icon처럼 모양이 드러나지 않는 기반 위젯은 계속 쓴다.

## D-016 · 2026-09-29 · 홈은 언어 · 모델 중심, 하단 탭 3개
사용자 피드백: 캡처 영역은 떠 있는 버튼 안에서 정하므로 홈에서는 언어와 모델을 설정하는 게 낫다.
홈에서 캡처 모드 타일을 빼고 대상 언어 · 언어 모델 타일과 엔진 줄을 넣는다. 하단 탭 홈 · 언어 · 설정을 두고, 대상 언어 · 모델 관리는 언어 탭, 설정 탭은 엔진 · 캡처 기본값 · 표시.
Notion FL-03 화면 정의(구성 요소 "현재 캡처 모드")와 달라져 Notion 페이지에 변경 메모를 남겼다.

## D-017 · 2026-09-29 · 서비스 시작 흐름 (NA-02 · NA-03 · NA-04 일부)
Android 14+는 mediaProjection 포그라운드 서비스를 캡처 동의 **뒤에만** 시작할 수 있어 NA-02 · NA-03과 NA-04의 동의 부분을 함께 만든다.
- 흐름: Flutter `startService()` → 투명 `CaptureConsentActivity`(상태 STARTING) → 동의 창 → 허용: `TranslatorService` 시작(startForeground → getMediaProjection, RUNNING) / 거부: STOPPED.
- 동의 창은 Android 14+에서 기본이 "앱 하나 공유"라 `MediaProjectionConfig.createConfigForDefaultDisplay()`로 전체 화면을 요청.
- 동의 Activity를 따로 둔 이유: 앱 화면 · 알림 · 빠른 설정 타일(NA-25) 어디서 시작해도 같은 경로. FlutterActivity와 분리.
- 토큰은 한 번만 쓸 수 있어 `START_NOT_STICKY`. 시스템이 공유를 끄면(MediaProjection.Callback.onStop) 서비스도 멈춘다.
- 상태에 ERROR 추가 (FL-03 명세의 "오류"). 다시 시작하면 벗어난다.
- 알림: 채널 IMPORTANCE_LOW(조용히), 누르면 앱 열기, "중지" 동작. 네이티브 문구는 `res/values(-ko)/strings.xml`, 색은 `res/values/colors.xml`(design 토큰과 같게).

## D-018 · 2026-09-29 · 클린 아키텍처 (D-010의 Flutter 부분 대체)
사용자 요청: MVVM만으로는 구조가 지저분해 보임 → 클린 아키텍처 적용.
- 의존 방향 presentation → domain ← data. domain은 순수 Dart(freezed_annotation만 허용).
- domain: 엔티티(앱 자체 열거형 — Pigeon 열거형을 쓰던 D-010을 바꿈), 리포지토리 인터페이스, 유스케이스(동작 하나당 클래스 하나, `call()`; 공통 규약 `core/domain/use_case.dart`).
- data: 데이터소스(Pigeon · permission_handler 감싸기), 매퍼(Pigeon ↔ 엔티티), 리포지토리 구현. Pigeon 타입은 data 밖으로 안 나감.
- presentation: screens / view_models / widgets. ViewModel은 유스케이스만 호출.
- DI: 기능마다 `di.dart`에 Riverpod provider(데이터소스 → 리포지토리 → 유스케이스). 전용 DI 패키지(get_it 등)는 쓰지 않음 — Riverpod이 이미 DI와 테스트 override를 해 줌.
- 규칙은 `test/architecture_test.dart`로 검사 (첫 실행에서 도메인이 Flutter를 import하던 곳 1건을 잡아 고침).
- 네이티브(Kotlin)는 이미 bridge / service / data 로 나뉘어 있어 이번에는 바꾸지 않음.

## D-019 · 2026-09-30 · 프레임 캡처 방식 (NA-05)
- 세션 시작 때 VirtualDisplay(AUTO_MIRROR) + ImageReader(RGBA_8888, 버퍼 2)를 만들고 세션 동안 유지. Android 14+는 토큰 하나로 VirtualDisplay를 한 번만 만들 수 있다.
- 미러링은 화면이 바뀔 때만 프레임을 보내므로, 들어오는 최신 프레임 하나를 **계속 들고** 있다가 요청 때 Bitmap으로 바꾼다 → 멈춘 화면도 바로 찍힘.
- 회전: Android 14+는 `onCapturedContentResize`에서 resize(시스템이 알려 준 크기), 13 이하는 설정 변경 때 VirtualDisplay를 새 크기로 다시 만든다 (13에서 resize는 비율이 어긋나는 것을 에뮬레이터에서 확인).
- 전부 검은 프레임(밝기 ≤ 8, 24×24 표본)은 Blank → 보안 화면 안내에 쓴다.
- 디버그 빌드에만 알림 "캡처 테스트" 동작(앱 캐시에 PNG 저장). 플로팅 버튼(NA-18)이 생기면 캡처 전에 오버레이를 숨긴다.

## D-020 · 2026-09-30 · 문자 인식기 고르기 (NA-09) — 사용자 확인 필요
명세 "자동이면 라틴 + 선택 언어 병행"에서 "선택 언어"가 무엇인지 모호하고, 아직 원문 언어 설정이 없다. 임시로:
- 원문 언어를 정하면 그 문자 체계 인식기 하나 (ko/ja/zh/데바나가리, 그 밖은 라틴).
- 자동이면 한국어 · 일본어 · 중국어 인식기를 병렬로 돌리고(각각 라틴도 읽음) "글자 수 × 신뢰도" 합이 큰 결과를 고른다.
- 신뢰도 0.5 미만 줄은 버리고, 줄이 남지 않은 블록도 버린다.
- 속도가 문제면(인식기 3개) 자동 모드를 줄이는 쪽으로 조정. 실제 소요 시간은 기기에서 재야 함.

## D-021 · 2026-09-30 · 블록별 언어 결정 (NA-10)
- 원문 언어는 블록마다 ML Kit Language ID로 감지(신뢰도 0.5 미만이면 모름). 모르면 OCR 인식기가 추정한 언어를 쓴다.
- 결정: 대상 언어와 같음 → 건너뜀 / 엔진이 원문으로 못 받음 → 미지원(안내) / 둘 다 모름 → 번역 안 함 / 그 밖 → 번역.
- 코드 정리: "zh-Hant" → "zh", "iw" → "he", "in" → "id", "nb" → "no", "fil" → "tl". "ja-Latn"처럼 로마자로 적은 비라틴 언어는 해당 모델로 번역할 수 없어 모름으로 본다.
- 엔진 지원 언어는 주입받는다 (기본 ML Kit 번역 59개). AI 엔진(3단계)은 자기 지원 목록을 넘긴다.

## D-022 · 2026-09-30 · develop merge는 스스로, 검토는 기능 묶음 단위 (D-012 일부 대체)
사용자 결정: "develop에 작업 알아서 다 merge하고, 기능이 어느 정도 개발되었다 싶으면 검토 요청".
develop merge는 analyze · test · 빌드 통과 후 스스로. main merge만 승인. 검토 요청은 한 흐름이 기기에서 돌 때처럼 의미 있는 묶음마다.

## D-024 · 2026-10-01 · 오버레이 구조 (NA-18, NA-19)
- **Compose로 그린다** (foundation만, Material 컴포넌트 없음 — 모양은 `overlay/OverlayComponents.kt`에 Flutter `core/ui`와 같게). 창마다 WindowManager `TYPE_APPLICATION_OVERLAY` + 자체 Lifecycle · SavedState 주인(서비스에는 Activity가 없음).
- 창 4개: 플로팅 버튼(포커스 없음), 닫기 영역(끄는 동안만, 터치 안 받음), 모드 메뉴(버튼 옆 WRAP 창, 바깥 터치로 닫힘), 결과 시트(전체 화면, 포커스를 받아 뒤로 가기로 닫힘).
- 버튼 제스처는 Compose가 아니라 View 층에서 화면 좌표(rawX/Y)로 처리 — 창이 손가락을 따라 움직여 창 기준 좌표가 흔들리기 때문. 놓으면 가까운 좌우 가장자리에 붙고 시스템 막대는 피한다(`OverlayGeometry`, 순수 로직 · 단위 테스트).
- 캡처: 버튼을 숨김(INVISIBLE) → 숨긴 뒤의 새 프레임을 기다림(최대 200ms, 이어서 50ms 안의 프레임 하나 더) → 찍고 곧바로 다시 보임 + 번역 끝날 때까지 도는 링. D-019의 "최신 프레임을 들고 있는" 방식이라 기다리지 않으면 버튼이 찍힌다.
- ~~1단계는 전체 화면만~~ → D-027에서 드래그 지정 · 고정 영역 · 고정 영역 편집이 연결됨.
- 닫기 영역에 놓으면 서비스 종료(알림 "중지"와 같음). 버튼 위치는 프로세스 안에서만 기억(표시 설정 FL-07 때 저장 검토).
- 결과: 블록마다 줄을 이어 한 문단으로 만들어(ja · zh 등은 공백 없이) 엔진에 동시에 요청. 모두 실패하면 목록 대신 이유(Wi-Fi 필요 · 저장 공간 · 모델 없음)를 안내하고, 일부만 실패하면 그 카드에 "번역하지 못했어요". 미지원 언어는 원문 + 안내.
- 복사: 카드별 번역문, 전체 복사는 빈 줄로 잇는다. "AI로 다시 번역"은 ML Kit 결과일 때 비활성으로 보이고 NA-13에서 연결.
- 엔진은 서비스가 `MlKitTranslationEngine` 하나를 세션 동안 가진다(설정 엔진과 무관, AI 엔진이 생기면 고르기 · 대체).
- 다크 모드: `res/values-night/colors.xml` (design.md 다크 열).
- 다른 앱 위 표시 권한이 없으면 버튼을 띄우지 않고 서비스만 돈다 (권한 화면이 시작 전에 막는다).

## D-025 · 2026-10-01 · 오버레이 아이콘은 Material Symbols 부분 글꼴
Flutter와 같은 Material Symbols Rounded 선 아이콘을 쓰되, 원본 글꼴(15MB) 대신 쓰는 글자만 남긴 3.4KB 글꼴 `res/font/material_symbols_rounded.ttf`를 넣는다. 코드포인트는 `overlay/OverlayTheme.kt`의 `Symbol`.
아이콘을 추가할 때 다시 만드는 법 (fonttools, 원본은 pub 캐시 `material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf`, 코드포인트는 같은 패키지 `symbols.dart`):
```
pip install fonttools
pyftsubset MaterialSymbolsRounded.ttf --unicodes="U+e5d0,U+e3be,..." --layout-features='' --no-hinting --output-file=sub.ttf
python -c "from fontTools.ttLib import TTFont; from fontTools.varLib import instancer; instancer.instantiateVariableFont(TTFont('sub.ttf'), {'FILL':0,'wght':400,'GRAD':0,'opsz':24}).save('material_symbols_rounded.ttf')"
```

## D-009 · 2026-09-29 · 아이콘 패키지
Material Symbols Rounded 선 아이콘을 위해 `material_symbols_icons` 추가. Flutter 기본 `Icons`에는 Rounded + 선(outline) 조합이 없음.

## D-027 · 2026-10-01 · 캡처 범위 모드 (NA-06 · NA-07 · NA-08 · NA-20 · NA-21, 이슈 #12)
- 메뉴에서 고른 모드가 버튼 탭 동작을 정한다: 전체 화면 = 바로 번역, 드래그로 지정 = 영역 선택 창이 뜨고 손을 떼면 그 영역만 번역, 고정 영역 = 저장된 영역만 번역(저장된 게 없으면 편집부터).
- 메뉴는 전체 화면 · 드래그로 지정 · 고정 영역 세 개. 고정 영역을 고르면 모드가 바뀌면서 바로 영역 편집 화면이 열리고(저장된 영역이 있으면 그 자리에서 시작), 옮기기 · 모서리 크기 조절 후 "저장"하면 끝. 이후 버튼 탭 = 그 영역 번역. 별도 "고정 영역 편집" 항목은 없다 (이슈 #14, 사용자 요청. Notion 명세의 4항목과 다름 — 명세 갱신 필요).
- 영역은 **화면 대비 비율(0..1)** 로 DataStore에 문자열(`left,top,right,bottom`)로 저장 — 회전 · 해상도가 달라도 같은 자리. 네이티브 전용 설정이라 Pigeon에는 넣지 않았다 (FL-08에서 Flutter가 필요로 하면 그때 추가).
- 자르기는 파이프라인이 한다: 전체 화면을 찍은 뒤 영역만 비트맵으로 잘라 문자 인식에 넘긴다 (캡처 자체를 줄이지 않는 건 D-019의 "최신 프레임" 방식 때문).
- 영역 선택 창은 전체 화면 오버레이(포커스를 받아 뒤로 가기로 취소), 바깥은 어둡게 덮는다. 최소 한 변 56dp.
