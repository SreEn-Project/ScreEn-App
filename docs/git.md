# Git 규칙

저장소: https://github.com/Translation-App-Sample/Translation-App (private)

## 브랜치
| 브랜치 | 용도 | 만드는 곳 → 합치는 곳 |
|---|---|---|
| `main` | 배포 가능한 상태. 직접 커밋 금지 | `develop` → `main` (릴리스 때) |
| `develop` | 통합 브랜치. 직접 커밋 금지 | 작업 브랜치 → `develop` |
| `feature/<ID>-<요약>` | 기능 하나 (Notion 기능 ID) | `develop`에서 → `develop`으로 |
| `ui/<단계>-<요약>` | 여러 화면 UI 퍼블리싱 묶음 (화면마다 커밋 분리) | `develop`에서 → `develop`으로 |
| `fix/<ID 또는 이슈번호>-<요약>` | 버그 수정 | `develop`에서 → `develop`으로 |
| `chore/<요약>`, `docs/<요약>` | 설정 · 빌드 · 문서 | `develop`에서 → `develop`으로 |
| `hotfix/<요약>` | 배포본 긴급 수정 | `main`에서 → `main` + `develop` |

- 요약은 영어 소문자 · 하이픈. 예: `feature/NA-02-foreground-service`, `ui/stage1-screens`
- 브랜치 하나에는 한 가지 작업만. 앞 작업이 아직 합쳐지지 않았는데 이어서 해야 하면 앞 브랜치에서 새 브랜치를 따고, PR 설명에 의존 관계를 적는다.

## 커밋 메시지
```
<type>(<ID>): <무엇을 했는지, 한국어, 50자 안쪽>

<필요하면 본문: 왜 바꿨는지, 참고할 점>
```
- type: `feat` 기능 · `fix` 버그 · `ui` 화면 퍼블리싱 · `refactor` · `test` · `docs` · `chore`(빌드 · 설정 · 의존성) · `style`(포맷만)
- ID가 없는 작업은 괄호 생략. 예: `chore: Gradle compileSdk 37로 변경`
- 생성 코드(`*.g.dart`, `*.freezed.dart`, Pigeon 출력)는 원본과 같은 커밋에 넣는다.
- 커밋 전: `dart format`, `flutter analyze` 경고 0, `flutter test` 통과.

## Push · PR · Merge
- 작업 브랜치 push는 자유롭게 한다.
- `develop` · `main`으로의 합치기는 **PR로만** 하고, **merge 전에 사용자에게 알리고 승인을 받는다.**
- PR 제목은 커밋 규칙과 같은 형식. 본문은 `.github/pull_request_template.md`를 채운다.
- merge 방식: 작업 브랜치 → `develop`은 **Squash merge**가 기본. 화면별 커밋을 남겨야 하는 `ui/` 묶음은 **Merge commit**. `develop` → `main`은 Merge commit.
- merge 후 작업 브랜치는 삭제.

## 태그 · 버전
- `main`에 합칠 때 `v<major>.<minor>.<patch>` 태그. 단계 완료 = minor 올림 (1단계 완료 → v0.1.0).
- `pubspec.yaml`의 `version`도 같이 올린다.

## 이슈
- 템플릿: `.github/ISSUE_TEMPLATE/` (기능, 버그). 기능 이슈 제목은 `[ID] 기능 이름`.
