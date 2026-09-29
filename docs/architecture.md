# 아키텍처 요약

원본: [Notion 기술 스택 · 아키텍처](https://app.notion.com/p/3eac450c43a581e29119de09d17c19e7). 이 문서는 코드 작업용 요약이며, 다르면 Notion이 기준이다.

## 역할 분담
- **Flutter**: 앱 화면 (온보딩, 권한 안내, 홈, 설정, 기록, 단어장)
- **Kotlin 네이티브**: 다른 앱 위에서 동작하는 부분 (포그라운드 서비스, MediaProjection 캡처, 오버레이, ML Kit OCR · 언어 감지 · 번역, Room, DataStore, Keystore)
- 통신: Pigeon (타입 안전)

```
Flutter UI → ViewModel(Riverpod) → Repository ⇄ Pigeon ⇄ Kotlin 브리지
                                                      └ 포그라운드 서비스
                                                         ├ 캡처 → OCR → 언어 감지 → 번역 엔진 → 오버레이
                                                         └ Room (기록 · 캐시 · 단어장)
```

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
- Flutter: flutter_riverpod, riverpod_generator, go_router, freezed, json_serializable, pigeon(dev), permission_handler, url_launcher, flutter_localizations, intl, mocktail(dev). 3단계에 firebase_core · firebase_auth · google_sign_in.
- 네이티브: lifecycle-service, WindowManager + Compose, mlkit text-recognition(+korean/japanese/chinese), language-id, translate, Room, DataStore, coroutines. 3단계에 OkHttp, kotlinx.serialization, firebase-ai.

## 제약
- Android 14+는 캡처 세션마다 사용자 동의, 포그라운드 서비스 유형 `mediaProjection`.
- 보안 화면(은행, OTT)은 검은 화면 → 범위 밖.
- 접근성 API 사용 안 함. iOS 범위 밖.
