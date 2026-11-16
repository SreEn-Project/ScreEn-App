# UI 리디자인 계획 (#188)

지시서 2건("기존 UI 기반 리디자인 지시서", "Visual Design 지시서 v2.0")을 현재 코드(develop, #187 반영)와 비교한 1단계 분석.
원칙: 기능 · 상태 관리 · 라우팅 · Pigeon · 권한 · 캡처 로직은 건드리지 않는다. 공통 컴포넌트 public API(생성자)는 유지하고, 필요하면 선택 인자 variant만 추가한다.

## 1. 현재 구현 vs 지시서 차이
| 영역 | 현재 (코드 / design.md) | 지시서 | 작업 |
|---|---|---|---|
| 색 토큰 | design.md 값과 `app_colors.dart` 일치 (라이트 #F6F8F5/#044B39 …, 다크 별도) | 같은 값 유지, 역할만 명확히 | 값 변경 없음. 역할 규칙(accent는 작은 포인트만)만 점검 |
| 표면 | 모든 카드 흰색 + 초록빛 그림자(y8 blur24) | 그림자 약하게/없음, 명도 차 + 1dp 테두리, Level 0~3 표면 | `AppCard`에 variant(flat / panel / emphasis) 추가, 그림자 약화 |
| 모서리 | 카드 24 · 시트 28 · 입력 18 · 버튼 알약 | 스케일 8/12/16/20/24, 버튼은 역할별 M(16) 또는 알약 | 토큰 `radiusS/M/L` 추가. 24는 대표 패널 · 시트만 |
| 카드 남용 | `AppCard(` 사용 25개 파일. 기록 항목 · 단어장 · 설정 행이 각각 큰 카드 | 반복 목록은 평면 행 또는 한 카드 안 행 + 구분선 | 기록 · 단어 · 언어 목록을 그룹 1개 + 행으로 전환 |
| 그림자 | 카드 · 흰 버튼 · 아이콘 버튼 · 탭바에 반복 | 기본 카드 없음~약함, 팝업만 | `cardShadow` 약화, 목록 행엔 미사용 |
| 그라데이션 | 홈 상태 카드 전용 (정책 동일) | 장식용 지양, 홈 Hero만 허용(문서 1) / 기본 미사용(문서 2) | **충돌**: 홈 Hero 유지로 해석 (아래 질문 1) |
| 버튼 | primary 알약 + glow / secondary 흰 알약 + 그림자 / text | Primary 핵심 1개, Secondary는 테두리 + 브랜드 글자, Tertiary 글자 | secondary를 테두리형으로, glow 약화, loading/disabled 점검 |
| 아이콘 버튼 | 흰 원 + 그림자 | 터치 영역 분리, 라벨 | 그림자 제거 · 48dp 터치 영역 · tooltip 점검 |
| AppListTile | 항상 IconBadge(40) 원 + 제목 + 설명 + 값 | 아이콘은 선택적, 값은 primary, 선택은 체크 | 기본 아이콘 배경 크기 축소, 아이콘 없는 행 허용(이미 가능), `selected` 표시용 variant |
| 섹션 제목 | 작은 회색 18/13 제목 + 카드 | 페이지 제목보다 작게, 전체보기는 text | 현행 유지 + 간격 토큰 정리 |
| 구분선 | 카드 안 행마다 | 그룹 안에서만, 기계적 반복 금지 | 사용처 검토 |
| 상태 배지 | 점 + 글자 알약 | 글자 + 아이콘 병행, Hero보다 작게 | 색만으로 구분하는 곳 점검 |
| 검색 · 칩 · 슬라이더 · 스위치 | 자체 컴포넌트 존재 (테두리 없는 알약 검색 + 그림자) | 검색: 표면 + 포커스 테두리, 슬라이더: 값 표시 | 검색 필드 포커스 테두리, 슬라이더 값 라벨 점검 |
| 탭바 | 떠 있는 흰 둥근 바 + 그림자 | 3탭 유지, 본문보다 약하게 | 그림자 약화 |
| 오버레이 Compose | `OverlayTheme` 색 = Flutter 토큰, 흰 원 FAB + 초록 그림자, 결과 시트 카드 안에 카드(원문+번역) | 번역문 우선, 원문 보조, 액션이 결과를 가리지 않게, 카드 중첩 줄이기 | `OverlayTheme`에 반경/그림자 토큰 추가, ResultSheet · WordCardSheet · 메뉴 정리 |
| 하드코딩 | 화면 색 하드코딩 거의 없음 (`Colors.` 4곳, 줄 맞추기 · 낙하 효과) | 제거 | 토큰으로 교체 |
| 타이포 | 32/24/18/15/13 TextTheme (design.md와 동일) | 동일 | 변경 없음. 직접 fontSize 사용처 점검 |

## 2. 두 지시서가 부딪히는 점 (결정 필요)
1. **그라데이션 / 그림자**: 지시서 1은 홈 Hero 그라데이션 · 기존 그림자 토큰 유지, 지시서 2는 그림자 최소화 · 테두리 우선. → 제안: 홈 Hero 그라데이션만 남기고, 카드 그림자는 약하게 + 1dp outline 테두리 병행, 팝업 · 시트만 그림자.
2. **카드 24dp 고정(기존 design.md)** vs 모서리 스케일. → 제안: 스케일 도입, 대표 패널 · 시트만 24~28.
3. **알약 버튼** vs "모두 캡슐 금지". → 제안: 주요 CTA · 칩 · 상태 배지는 알약, 보조 버튼 · 입력은 16dp.
4. 지시서가 요구하는 스크린샷 비교 · 빌드 확인은 이 세션(클라우드, Flutter/Android SDK 없음)에서 못 한다.

## 3. 단계 계획 (단계마다 PR 1개)
| # | 단계 | 주요 파일 |
|---|---|---|
| 2 | 토큰: 반경 스케일 · 약한 그림자 · 테두리 · Compose 대응표 | `app_tokens.dart`, `app_theme.dart`, `OverlayTheme.kt`, design.md |
| 3 | 공통 컴포넌트 (사용처 전수 확인 후 variant 추가) | `lib/core/ui/*` |
| 4 | 홈 | `home_screen.dart` |
| 5 | 결과 시트 · 오버레이 | `ResultSheet.kt`, `WordCardSheet.kt`, `FloatingButton.kt`, `OverlayComponents.kt`, `RegionPicker.kt` |
| 6 | 설정 · AI 설정 | `settings_screen.dart`, `ai_setup_screen.dart`, `ai_*` |
| 7 | 언어 · 언어 선택 | `language_models_screen.dart`, `language_list.dart` |
| 8 | 기록 | `history_*` |
| 9 | 단어장 · 단어 상세 | `wordbooks_screen`, `wordbook_detail_screen`, `word_detail_screen` 등 |
| 10 | 학습 6종 | `learning_start`, `flashcards`, `word_test`, `line_match`, `falling`, `assembly` |
| 11 | 온보딩 · 권한 | `onboarding_screen`, `permission_screen` |
| 12 | 다크 모드 · 일관성 검수 | 전체 |

단계 순서는 지시서 1의 5-5(홈 → 결과 시트 → 설정 …)를 따르되, 공통 컴포넌트가 먼저 바뀌므로 2 · 3단계를 앞에 둔다.

## 4. 검증 한계
이 환경에는 Flutter · Android SDK가 없어 `flutter analyze` · `flutter test` · 빌드 · 스크린샷을 돌리지 못한다. 단계마다 정적 검토만 하고, 실행 확인은 사용자 기기 테스트로 넘긴다.

## 학습 화면 · 온보딩 정리 (#188, 2차)
- 학습/테스트/게임이 같이 쓰는 `study_widgets.dart`를 평평하게: 문제는 카드 없이 큰 글(36sp), 진행은 "3 / 10" + 가는 막대, 맞힌 수는 알약 대신 글자, 결과 점수는 큰 숫자.
- 결과 화면의 틀린 단어 목록과 요약은 `AppCard.flat`. 권한 카드도 flat.
- 온보딩 아래 버튼은 큰 기본(채운) 버튼으로.
- 참고한 흐름: 한 화면에 질문 하나, 큰 글, 아래 고정 버튼, 얇은 진행 막대 (Duolingo · Quizlet · Anki 시안 검색).
