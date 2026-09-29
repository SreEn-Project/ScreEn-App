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
| 카드 그림자 | y 8, blur 24, 검정 6% (다크: 검정 24%) |
| 큰 버튼 높이 | 56dp |

## 글자
- 시스템 기본 글꼴. 제목은 **굵고 크게**, 제목 속 **한 단어만 primary 색**으로 강조한다.
- 큰 제목 32 Bold, 화면 제목 24 Bold, 섹션 18 SemiBold, 본문 15 Regular, 보조 13 Regular.

## 아이콘
- Material Symbols **Rounded**, 선(채움 0) 아이콘. 패키지 `material_symbols_icons`, `Symbols.xxx_rounded`.
- 아이콘 배경이 필요하면 primaryContainer 원 위에 onPrimaryContainer 아이콘.

## 화면
### 홈
1. 인사 문구(제목, 한 단어 강조) + 오른쪽 알림 버튼(흰 원)
2. 그라데이션 상태 카드: 대상 언어 · 번역 엔진 · 캡처 모드
3. 큰 시작 버튼: primary 알약, 앞에 accent 초록 점 (켜짐 상태 표시)
4. 캡처 모드 타일 3개 (전체 화면 · 영역 선택 · 고정 영역), 흰 카드 + 아이콘 원
5. 최근 기록: 칩 필터 + 목록 카드

### 온보딩
- 큰 제목(한 단어 강조) + 설명 + 하단 "시작하기 →" 흰 알약 버튼(그림자).

## 오버레이 (네이티브)
- 플로팅 버튼: 흰 원 + 옅은 그림자, 아이콘 primary.
- 결과 시트: 흰 하단 시트(상단 28dp)에 카드 목록. 카드마다 원문(회색 작은 글자) · 번역문(본문).
- 원문 위치 덮어쓰기(NA-22)는 원래 화면에 맞춰야 하므로 이 팔레트를 강제하지 않는다.
- 다른 앱 위에 뜨므로 가독성 우선: 불투명 배경, 큰 글자, 빨리 닫힘.
