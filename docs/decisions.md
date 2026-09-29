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
- Flutter는 Pigeon 열거형(EngineType 등)을 도메인에서 그대로 쓴다. 같은 값을 세 번 정의하지 않기 위함. 모델 클래스는 freezed로 감싼다.
- 이벤트 채널은 네이티브 리스너가 하나뿐이라 Flutter에서 `TranslatorEventBus`로 한 번만 구독해 나눠 쓴다. 현재 값은 조회 API로 가져온다.
- 공유 객체는 Application 클래스 대신 `AppGraph` object (Manifest 변경 없음). 의존성이 늘면 DI 검토.

## D-011 · 2026-09-29 · compileSdk 37
permission_handler_android 14.1이 compileSdk 37을 요구. 설치된 플랫폼 이름이 `android-37.0`이라 `release(37) { minorApiLevel = 0 }`로 지정. AGP 9.1은 36까지 권장한다는 경고가 나오지만 빌드는 됨. AGP를 올릴 때 다시 확인.

## D-012 · 2026-09-29 · Git 흐름
main / develop + 작업 브랜치(Git Flow 축소판). 작업 브랜치 push는 자유, develop · main merge는 사용자 승인 후. 상세는 [git.md](git.md).
그전까지 만든 기반 세팅 · 디자인 · NA-01 · NA-16은 규칙 이전 작업이라 `main` 초기 커밋 하나로 올리고 `develop`을 거기서 딴다.

## D-013 · 2026-09-29 · UI 퍼블리싱 먼저
사용자 요청으로 1단계 Flutter 화면을 자리 표시 데이터로 먼저 만들고 검증받는다. 브랜치 `ui/stage1-screens` 하나에 화면(기능 ID)별로 커밋하고, 검증 뒤 develop에 merge한다.

## D-014 · 2026-09-29 · 언어 이름은 데이터로
ML Kit 59개 언어의 한국어 · 영어 · 자기 언어 이름과 원문 인식 가능 여부는 `features/language/domain/supported_language.dart`에 둔다. UI 문구가 아니라 목록 데이터라 ARB에 118줄을 넣지 않음.
원문 인식 가능 = ML Kit 문자 인식 v2가 읽는 문자(라틴 · 한중일 · 데바나가리). 나머지(아랍 · 키릴 · 태국 등)는 "대상 언어 전용".

## D-009 · 2026-09-29 · 아이콘 패키지
Material Symbols Rounded 선 아이콘을 위해 `material_symbols_icons` 추가. Flutter 기본 `Icons`에는 Rounded + 선(outline) 조합이 없음.
