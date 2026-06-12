---
description: .po 파일(또는 디렉토리)을 한국어로 번역하고 검증 후 커밋
argument-hint: <po파일 | 디렉토리> [추가 경로...]
allowed-tools: Read, Edit, Grep, Glob, Bash(pipenv run python scripts/validate-ko-po.py:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*)
---

okrbest-docs의 한국어 번역 작업을 수행한다. 대상: $ARGUMENTS

## 절차 (순서대로 정확히 수행)

### 1. 대상 확정 및 가드

`$ARGUMENTS`의 각 경로를 검사한다. 디렉토리면 그 아래 `**/*.po`를 모두 대상으로 삼는다.

다음은 **거부하고 이유를 보고한 뒤 중단**한다:
- `source/locales/ko/LC_MESSAGES/` 외부 경로 또는 .po가 아닌 파일
- `agents/` 또는 `_generated/` 아래 경로 → "영문 유지가 의도된 설계입니다 (TRANSLATION_GUIDE.md 6절)"
- `_static/` 아래 경로 → "msgid가 치환자 이름이라 번역 금지 대상입니다"
- product-overview의 체인지로그류 파일(`*changelog*`, `*-releases*`, `release-policy*`, `unsupported-legacy-releases*` 등 버전 이력 문서) → "정책상 보류 대상입니다 (가이드 3절)"

이어서 `ASSIGNMENTS.md`를 Read하여 대상 디렉토리의 담당자를 확인한다.
다른 사람이 담당 중이거나 미배정 상태면 **번역을 시작하지 말고** 사용자에게 그 사실을 알리고 계속할지 확인받는다.

### 2. 지침 로드

`TRANSLATION_GUIDE.md` **전체**를 Read한다 (메모리에 의존하지 말 것).
특히 4절(.po 형식), 5절(마크업 보존), 7절(문체), 8절(용어집)을 번역 중 기준으로 삼는다.

### 3. 원문 컨텍스트 로드

각 .po에 대응하는 원문 문서를 Read하여 문맥(제목 위계, 표/목록 구조, UI 흐름)을 파악한다:

```
source/locales/ko/LC_MESSAGES/<경로>/<이름>.po  →  source/<경로>/<이름>.rst (없으면 .md)
루트 index.po → source/index.rst  ·  루트 sphinx.po → 테마 문자열(원문 불필요)
```

### 4. 현황 파악

```
pipenv run python scripts/validate-ko-po.py --stats-only <대상...>
```

이미 100% 번역되고 fuzzy 0인 파일은 "이미 완료"로 보고하고 건너뛴다.

### 5. 번역 실행

파일 단위로 진행한다. 한 번의 Edit에 10~20개 항목씩 묶어 처리한다.

- **msgstr만** 작성한다. msgid·헤더·`#:`·`#~`는 절대 건드리지 않는다.
- 마크업은 가이드 5절대로 1:1 보존. msgid 전체가 코드/식별자/치환자 이름이면 msgstr를 비워 둔다.
- **인라인 마크업(`**굵게**`, 링크, 롤) 바로 뒤에 한글 조사가 붙으면 반드시 `\\ `로 분리한다**
  (예: `**Add**\\ 를`). 분리하지 않으면 rST 마크업이 깨진다 (가이드 5-5절).
- 문체는 합니다체, 용어는 가이드 8절 용어집을 따른다. 용어집에 없는 용어는 8-3절 해결 규칙을 따르고,
  새로 정한 용어를 결과 보고에 명시한다.
- **브랜딩(가이드 6-1절)**: 제품을 지칭하는 "Mattermost"는 "OKR.BEST"로 옮긴다.
  단 외부 Mattermost 서비스 링크 텍스트(Academy·커뮤니티 서버·헬프 센터·지원 약관 등),
  오픈소스 프로젝트·원저작사 지칭, 스토어 앱명, 에디션명(Mattermost Enterprise 등)은 유지한다.
  애매하면 유지하고 결과 보고에 명시한다.
- `#, fuzzy` 항목: 현재 msgid 기준으로 msgstr를 검증·수정한 **후에** `#, fuzzy` 줄을 삭제한다.
- 확신이 없는 항목은 빈 msgstr로 남긴다(영어 폴백이 오역보다 낫다).

### 6. 검증

```
pipenv run python scripts/validate-ko-po.py <처리한 파일들>
```

- exit 1(마크업 오류): 표시된 행을 수정하고 재실행 — 최대 3회 반복
- exit 2(파싱 실패): 따옴표/이스케이프를 수정하고 재실행
- 3회 후에도 실패하면 **커밋하지 않고** 남은 문제를 보고한다

### 7. 커밋 (검증 통과 시에만)

처리한 .po 파일**만** `git add`한다 (`git add -A` 금지). 커밋 메시지:

```
ko(<디렉토리>): <파일명 또는 범위> 번역 (<N>건)
```

**push는 절대 실행하지 않는다.** 대신 다음 안내를 출력한다:
"푸시: `git push || { git pull --rebase origin feat/ko && git push; }` (거부되면 같은 명령 반복)"

### 8. 결과 보고

파일별 표로 보고한다: 번역 N건 / 빈 msgstr로 남김 N건(사유) / fuzzy 해소 N건 / 미번역 잔여 N건,
검증 결과, 커밋 해시, 새로 추가가 필요한 용어집 후보, 같은 디렉토리의 다음 추천 파일.

## 금지 사항 (재확인)

`make update-po-ko` 실행 금지 · msgid/헤더/`#:`/`#~` 수정 금지 · 대상 외 파일 수정 금지 ·
`source/` 원문 수정 금지 · push 금지.
