# 디자인 가이드

방향: **흰 톤 + 연한 초록 포인트, 미니멀 · 모노톤, Material 3, 캐릭터 없음** (2026-09-29 확정, D-008).
Flutter 앱 화면과 네이티브 오버레이(Compose)가 같은 토큰을 쓴다.
코드 위치: `lib/app/theme/` (`app_colors.dart` 색, `app_tokens.dart` 그라데이션 · 그림자 · 치수, `app_theme.dart` 컴포넌트 테마).
화면 코드에서 색 값을 쓰지 않는다. `Theme.of(context).colorScheme` 과 `context.tokens` (ThemeExtension)로만 가져온다.

## 원칙
- 화면 대부분은 흰색 · 회색. 초록은 **포인트에만** (주요 버튼, 강조 글자, 선택 칩, 아이콘 배경, 상태 점).
- 넓은 여백. 기본 간격 8의 배수, 화면 좌우 여백 20, 섹션 사이 24~32.
- 카드는 모서리 큰 흰 카드 + 옅고 넓은 그림자. 테두리는 쓰지 않는다 (입력창 · 구분선만 outline 색).
- 버튼 · 칩은 알약 모양 (완전 둥근 모서리).
- 한 화면에 주요 동작 하나.
- 파랑 계열 색은 쓰지 않는다.

## 색 토큰
| 토큰 | 라이트 | 다크 | 용도 |
|---|---|---|---|
| background | `#F6F8F5` | `#0B1A16` | 화면 배경 (Scaffold) |
| surface | `#FFFFFF` | `#13241F` | 카드 · 시트 |
| primary | `#044B39` | `#C8EFC1` | 주요 버튼, 강조 글자 |
| onPrimary | `#FFFFFF` | `#04261D` | primary 위 글자 |
| primaryContainer | `#C8EFC1` | `#1D3A31` | 선택 칩, 강조 카드, 아이콘 배경 |
| onPrimaryContainer | `#044B39` | `#C8EFC1` | 위 배경의 글자 · 아이콘 |
| secondaryContainer | `#CBF39D` | `#2A4A1F` | 작은 배지, 그라데이션 끝 |
| accent | `#72C613` | `#8FDB3A` | 상태 점 등 아주 작게만 |
| onSurface | `#0F1F1A` | `#E4EDE8` | 본문 글자 |
| onSurfaceVariant | `#6B7570` | `#9AA8A1` | 보조 글자 |
| outline | `#E3E8E4` | `#24362F` | 입력창 테두리 · 구분선 |
| error | `#B3261E` | `#F2B8B5` | 오류 |

다크 모드 primary는 배경 대비를 위해 라이트의 primaryContainer 값을 쓴다. 다크 값 중 background · surface 외에는 이 문서에서 정한 값이다.

## 간격 토큰 (#88)
`AppTokens`의 상수만 쓴다. 숫자를 화면에 직접 적지 않는다.
| 토큰 | 값 | 용도 |
|---|---|---|
| space4 / 8 / 12 / 16 / 24 | 4 · 8 · 12 · 16 · 24 | 일반 gap · margin |
| pagePadding | 20 | 화면 좌우 여백 |
| rowPaddingH / V | 20 / 14 | 카드 안 목록 한 줄 패딩 · 구분선 들여쓰기 |
| cardListPaddingV | 6 | 목록형 카드 위아래 패딩 |
| sectionGap | 24 | 섹션 사이 |
| sectionTitleGap / Indent | 10 / 6 | 섹션 제목과 카드 사이 · 제목 들여쓰기 |

설정 항목에서 현재 값(`_Labeled.value`)은 제목 아래 줄에 둔다 (한 줄에 두면 긴 값이 제목을 민다).

## 그라데이션
- **홈 상단 상태 카드에만** 쓴다: `#FFFFFF → #CBF39D → #C8EFC1` (왼쪽 위 → 오른쪽 아래).
- 다크: `#13241F → #1D3A31 → #2A4A1F`.

## 모양 · 그림자
| 항목 | 값 |
|---|---|
| 카드 모서리 | 24dp |
| 하단 시트 상단 모서리 | 28dp |
| 버튼 · 칩 | 알약 (StadiumBorder) |
| 입력창 | 16dp |
| 카드 그림자 | y 8, blur 24, primary 10% (다크: 검정 32%) — 초록으로 살짝 물든 그림자 |
| primary 버튼 빛 | y 10, blur 24, spread −4, primary 32% (다크: #C8EFC1 20%) |
| 큰 버튼 높이 | 56dp |

## 글자
- 시스템 기본 글꼴. 제목은 **굵고 크게**, 제목 속 **한 단어만 primary 색**으로 강조한다.
- 큰 제목 32 Bold, 화면 제목 24 Bold, 섹션 18 SemiBold, 본문 15 Regular, 보조 13 Regular.

## 아이콘
- Material Symbols **Rounded**, 선(채움 0) 아이콘. 패키지 `material_symbols_icons`, `Symbols.xxx_rounded`.
- 아이콘 배경이 필요하면 primaryContainer 원 위에 onPrimaryContainer 아이콘.

## 컴포넌트 (D-015)
Material 느낌을 줄이려고 앱 자체 컴포넌트를 `lib/core/ui/`에 두고 화면은 이것만 쓴다 (`import 'core/ui/ui.dart'`).
화면 코드에서 `AppBar` · `ListTile` · `FilledButton` · `TextButton` · `OutlinedButton` · `Switch` · `Chip` · `Slider` · `Radio`를 쓰지 않는다.

| 컴포넌트 | 모양 |
|---|---|
| `Pressable` | 누르면 97% 크기 + 살짝 흐려짐. 물결(ripple) 효과는 테마에서 끔 |
| `AppPage` · `AppHeader` | 배경 + 가운데 제목 헤더(왼쪽 뒤로가기, 오른쪽 동작 하나) + 스크롤 본문 |
| `AppBottomNav` | 떠 있는 흰 둥근 탭바 + 그림자, 고른 탭은 primary 아이콘 + 아래 짧은 막대 |
| `AppButton` | primary: 초록 알약 + 아래로 번지는 빛 / secondary: 흰 알약 + 그림자 / text |
| `AppIconButton` | 흰 원 + 그림자(기본), primary 원 + 빛(filled), 배경 없음(plain) |
| `AppCard` · `AppSection` | 24dp 흰 카드 + 초록 그림자 / 작은 회색 섹션 제목 + 카드 |
| `AppListTile` · `AppDivider` | 아이콘 원 + 제목 + 회색 설명 + 오른쪽 값(primary) · › / 가는 구분선 |
| `AppSwitch` | 알약 트랙(켜짐 primary) + 흰 손잡이 |
| `AppSegmented` · `AppChip` | 회색 트랙 안에서 고른 칸만 흰 알약으로(`enabled: false`면 흐리게 · 누를 수 없음) / 선택 시 primary 알약 |
| `AppSlider` · `AppProgressBar` | 가는 알약 트랙 + 흰 원 손잡이(primary 테두리) |
| `AppSearchField` | 테두리 없는 흰 알약 + 그림자 |
| `AppTextField` | 입력창 (흰 둥근 사각형 + 그림자). 기본 한 줄, `maxLines`로 여러 줄(예문). `obscure`로 API 키 등을 가린다. `onSubmitted`(완료 키) · `enabled`(false면 입력 불가) |
| `AppBadge` · `AppStatusPill` · `StatusDot` | 작은 연두 배지 / 점 + 글자 알약 / 켜짐 점(accent) |
| `IconBadge` · `AccentTitle` | 연한 초록 원 + 선 아이콘 / 한 단어 강조 제목 |
| `AppToast` | 잠깐 뜨는 한 줄 메시지: 흰 알약 + 그림자 + 성격 아이콘(성공 · 안내 primary, 오류 error). 탭바 위, 2.4초, 한 번에 하나. `AppToast.show(context, 문구, kind:)`. SnackBar 금지 |
| `AppNotice` | 화면 안 안내 배너: 둥근 16dp 사각형 + 아이콘 + 글자. info(회색) · success(primaryContainer) · error(error 10%). 테스트 결과 · 입력 오류 · 안내 문구 |
| `AppEmptyState` | 빈 목록 · 검색 결과 없음: 연한 초록 원 아이콘 + 제목 + (설명) + (동작 버튼) |
| `showAppConfirm` | 되돌릴 수 없는 동작 전 확인 하단 시트: 제목 + 설명 + primary 확인 + secondary 취소. AlertDialog 금지 |

## 알림 · 시스템 메시지 (D-061)
메시지는 **성격과 지속 시간**으로 고른다. 같은 상황은 같은 모양을 쓴다.
| 상황 | 쓰는 것 |
|---|---|
| 방금 한 동작의 결과(저장 · 삭제 · 실패), 잠깐 알리면 끝 | `AppToast` (Flutter) / `OverlayToast` (오버레이) |
| 화면에 남아 있어야 하는 안내 · 검증 결과 · 입력 오류 | `AppNotice` |
| 목록이 비었거나 검색 결과가 없음 | `AppEmptyState` |
| 되돌릴 수 없는 동작 확인 | `showAppConfirm` |
| 값 하나의 상태(받기 실패 등) | 목록 줄의 상태 글자(error 색) |
- 문구는 "~했어요 / ~해 주세요" 해요체 한 문장. 원인과 해결을 함께 말한다(예: "받지 못했어요. 인터넷 연결을 확인해 주세요").
- 오류는 error 색 아이콘으로만 구분하고 배경 전체를 빨갛게 칠하지 않는다(알림은 흰 바탕 유지).
- 시스템 `SnackBar` · `AlertDialog` · 안드로이드 `Toast`는 쓰지 않는다. 오버레이 위 짧은 안내는 `OverlayToast`(흰 알약 + 초록 그림자 + 아이콘, 터치 통과, 3.2초).
- 상시 알림(포그라운드 서비스, NA-03)은 시스템이 그리므로 모양은 못 바꾼다: 브랜드 작은 아이콘 + primary 강조색, 제목 + 한 줄 설명, "중지" 동작 하나, 조용한 채널(IMPORTANCE_LOW, 소리 · 진동 없음). 문구는 해요체.

## 화면 구조
하단 탭 3개: **홈 · 언어 · 설정** (`lib/app/app_shell.dart`). 대상 언어 선택 · 앱 정보는 탭 위로 덮어 연다.

### 홈 (D-016)
캡처 범위는 떠 있는 버튼 메뉴에서 고르므로 홈에 두지 않는다.
1. 인사 문구(제목, 한 단어 강조) + 오른쪽 알림 버튼(흰 원)
2. 그라데이션 상태 카드: 상태 알약(꺼짐/실행 중) · "자동 감지 → 대상 언어" · 엔진
3. 큰 시작 버튼: primary 알약 + 빛, 앞에 상태 점 / 아래 "영역은 버튼을 길게 눌러 바꿈" 안내
4. 번역 설정: 대상 언어 타일 · 언어 모델 타일(준비 수 + 진행 막대) 나란히, 아래 번역 엔진 줄
5. 최근 기록: 칩 필터 + 목록 카드

### 언어 탭
대상 언어 줄 → Wi-Fi에서만 받기 → 받은 언어 · 받을 수 있는 언어 목록(받기 · 삭제 · 진행률)

### 설정 탭
번역 엔진(라디오) · AI 번역 설정 → 캡처(기본 모드, 고정 영역 초기화) → 표시(결과 방식, 버튼 크기 · 투명도) → 앱 정보

### 온보딩
- 큰 제목(한 단어 강조) + 설명 + 하단 "시작하기 →" 흰 알약 버튼(그림자).

## 오버레이 (네이티브, Compose — D-024)
색은 `res/values(-night)/colors.xml`(이 문서 토큰과 같음)을 `OverlayTheme.colors`로만 가져온다. 아이콘은 같은 Material Symbols Rounded 부분 글꼴(D-025).
- 플로팅 버튼: 흰 원 52dp + 초록 그림자, 현재 모드 아이콘 primary. 번역 중에는 둘레에 도는 호(primary, 바탕 링 primaryContainer). 끄는 동안 108%.
- 닫기 영역: 아래 가운데 흰 원 60dp + ×, 버튼이 들어오면 primary로 채워지고 120%.
- 모드 메뉴: 버튼 옆 흰 카드(24dp) + 그림자, 줄마다 아이콘 원 + 이름. 고른 모드는 primaryContainer 줄, 준비 중인 모드는 흐리게 + "준비 중".
- 결과 시트: 어두운 막(scrim) 위 흰 하단 시트(상단 28dp, 화면 75%까지) · 손잡이. 머리: "번역 결과" + 엔진 배지 + "자동 감지 → 대상 언어" + 닫기. 카드(20dp, background 색)마다 원문(회색 13) · 번역문(16) · 복사. 아래 primary "전체 복사" + secondary "AI로 다시 번역". 결과가 없으면 같은 시트에 아이콘 원 + 제목 + 설명 + "닫기".

| 오버레이 컴포넌트 (`overlay/OverlayComponents.kt`) | 모양 |
|---|---|
| `Modifier.pressable` | Flutter `Pressable`과 같음 (97% + 흐려짐, 물결 없음) |
| `PillButton` | primary 초록 알약 + 빛 / secondary 연한 배경 알약 |
| `PlainIconButton` | 배경 없는 원형 아이콘 버튼 |
| `OverlayBadge` · `SymbolBadge` | 연두 배지 / 연한 초록 원 + 선 아이콘 |
| `OverlayToast` · `ToastPill` | 흰 알약 + 초록 그림자 + 아이콘 + 한 줄(최대 3줄). 아래 가운데, 터치 통과, 스스로 사라짐. 시스템 Toast 대신 (예: AI 실패 → ML Kit 대체 안내) |
- 원문 위치 덮어쓰기(NA-22)는 원래 화면에 맞춰야 하므로 이 팔레트를 강제하지 않는다.
- 다른 앱 위에 뜨므로 가독성 우선: 불투명 배경, 큰 글자, 빨리 닫힘.
