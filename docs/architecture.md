# 아키텍처 요약

원본: [Notion 기술 스택 · 아키텍처](https://app.notion.com/p/3eac450c43a581e29119de09d17c19e7). 이 문서는 코드 작업용 요약이며, 다르면 Notion이 기준이다.

## 역할 분담
- **Flutter**: 앱 화면 (온보딩, 권한 안내, 홈, 설정, 기록, 단어장)
- **Kotlin 네이티브**: 다른 앱 위에서 동작하는 부분 (포그라운드 서비스, MediaProjection 캡처, 오버레이, ML Kit OCR · 언어 감지 · 번역, Room, DataStore, Keystore)
- 통신: Pigeon (타입 안전)

```
Flutter UI → Bloc/Cubit → UseCase → Repository ⇄ Pigeon ⇄ Kotlin 브리지
                                                      └ 포그라운드 서비스
                                                         ├ 캡처 → OCR → 언어 감지 → 번역 엔진 → 오버레이
                                                         └ Room (기록 · 캐시 · 단어장)
```

## Flutter 계층 (클린 아키텍처 + Bloc, D-018 · D-023)
```
presentation ──▶ domain ◀── data
 screens          entities      datasources ──▶ Pigeon(core/bridge) · 플러그인
 bloc ───────▶   usecases      mappers (Pigeon ↔ 엔티티)
 widgets          repositories◀─ repositories (구현)
                  (인터페이스)
            di.dart: 리포지토리 → 유스케이스 → Bloc (get_it, core/di/injector.dart가 모음)
```
- **domain**은 순수 Dart. 앱 자체 엔티티 · 열거형(`ServiceStatus`, `EngineType` …), 리포지토리 인터페이스, 유스케이스(동작 하나 = 클래스 하나, `call()`).
- **data**만 Pigeon 생성 타입 · permission_handler를 안다. 매퍼로 엔티티로 바꿔 내보낸다.
- **presentation**의 Bloc · Cubit은 생성자로 유스케이스만 받는다 (get_it을 직접 꺼내지 않음). 화면은 `BlocProvider`로 받아 `context.watch/read`로 쓰고, `core/ui` 컴포넌트로 그린다.
  - Bloc: 이벤트가 여럿이거나 네이티브 스트림을 구독 (`ServiceBloc`: 구독 요청 · 토글).
  - Cubit: 메서드 몇 개로 끝나는 단순 상태 (`PermissionCubit`: 확인 · 요청).
  - 여러 화면이 공유하거나 탭을 오가도 유지할 것은 `lib/app/app_bloc_providers.dart`(lazy), 화면 하나만 쓰면 그 라우트에서 `BlocProvider`.
- 테스트: Bloc · Cubit은 mocktail 리포지토리 + 실제 유스케이스로 직접 만들어 검증, 위젯 · 스크린샷 테스트는 `setUpFakeNative()`로 get_it의 리포지토리를 가짜로 바꿈, 리포지토리 구현은 Pigeon API를 가짜로 바꿔 매핑까지 검증. `test/architecture_test.dart`가 의존 방향을 검사.

| 기능 | 유스케이스 |
|---|---|
| service | GetServiceStatus · WatchServiceStatus · StartTranslationService · StopTranslationService |
| settings | GetSettings · WatchSettings · ChangeTargetLanguage · ChangeEngine · ChangeCaptureMode · ChangeDisplayMode · CompleteOnboarding |
| permission | CheckPermissions · RequestNotificationPermission · RequestOverlayPermission |

## 번역 파이프라인
1. 플로팅 버튼 탭 또는 영역 선택
2. ImageReader에서 1프레임 (영역이면 잘라내기)
3. ML Kit 문자 인식 → 블록 · 좌표
4. 언어 감지, 원문 = 대상 언어면 건너뜀
5. 캐시 확인 → 엔진 번역 (AI는 블록 묶어 1회 호출, JSON 배열 응답)
6. 오버레이 표시 (목록형 / 원문 위치 덮어쓰기)

## 번역 엔진
`TranslationEngine` 인터페이스 — ML Kit 온디바이스(기본), Gemini(내 키), Firebase AI Logic(구글 로그인). 실패 시 ML Kit 대체.

## 주요 패키지
- Flutter: flutter_bloc, get_it, go_router, freezed, json_serializable, pigeon(dev), permission_handler, url_launcher, flutter_localizations, intl, mocktail(dev). 3단계에 firebase_core · firebase_auth · google_sign_in.
- 네이티브: lifecycle-service, WindowManager + Compose, mlkit text-recognition(+korean/japanese/chinese), language-id, translate, Room, DataStore, coroutines. 3단계에 OkHttp, kotlinx.serialization, firebase-ai.

## 제약
- Android 14+는 캡처 세션마다 사용자 동의, 포그라운드 서비스 유형 `mediaProjection`.
- 보안 화면(은행, OTT)은 검은 화면 → 범위 밖.
- 접근성 API 사용 안 함. iOS 범위 밖.
