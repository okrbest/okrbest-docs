# 병렬 번역 작업 절차 (Claude CLI)

여러 작업자가 각자 Claude CLI(Claude Code) 세션으로 **동시에** 번역하는 절차입니다.
처음 합류했다면 이 문서를 위에서부터 순서대로 따라 하세요.
번역 규칙·용어집 등 상세 내용은 [TRANSLATION_GUIDE.md](TRANSLATION_GUIDE.md)에 있습니다 — 이 문서는 절차만 다룹니다.

## 1. 최초 1회 준비

```bash
git clone git@github.com:okrbest/okrbest-docs.git
cd okrbest-docs
git switch feat/ko
```

Claude CLI 설치·로그인(이미 사용 중이면 생략):

```bash
npm install -g @anthropic-ai/claude-code
claude        # 첫 실행 시 로그인 안내를 따름
```

> ⚠️ **반드시 리포 루트(okrbest-docs/)에서 `claude`를 실행하세요.**
> 다른 디렉토리에서 실행하면 `/translate` 스킬과 번역 규칙(CLAUDE.md)이 로드되지 않습니다.

검증 도구 준비(권장 — `/translate`가 커밋 전 검증에 사용). 둘 중 **하나만** 해당됩니다:

**경우 A** — pipenv와 Python 3.12가 이미 설치되어 있으면 이 한 줄로 끝:

```bash
pipenv install --dev
```

**경우 B** — pipenv 또는 Python 3.12가 없으면 아래 3줄을 **순서대로** 실행합니다
(경우 A의 명령은 실행하지 않습니다 — 마지막 줄이 그 역할을 대신합니다):

```bash
uv python install 3.12
uv tool install pipenv
pipenv install --dev --python "$(uv python find 3.12)"
```

## 2. 담당 디렉토리 선점 (claim)

동시 작업 충돌을 막는 유일한 규칙은 **"디렉토리는 한 사람만"**입니다.

1. [ASSIGNMENTS.md](ASSIGNMENTS.md)를 열어 `미배정` 행을 고른다 (우선순위는 표의 위쪽부터)
2. 담당자 칸에 이름을 적고 상태를 `진행 중`으로 바꾼다
3. 커밋하고 **즉시 push**한다 (선점 공표 — push가 늦으면 다른 사람과 겹칠 수 있음):

```bash
git add ASSIGNMENTS.md
git commit -m "ko(claim): end-user-guide — 홍길동"
git push || { git pull --rebase origin feat/ko && git push; }
```

push 충돌로 ASSIGNMENTS.md가 겹치면 양쪽 행을 모두 살려 병합 후 다시 push합니다.

## 3. 번역하기 — /translate 스킬

리포 루트에서 `claude` 실행 후:

```
/translate source/locales/ko/LC_MESSAGES/end-user-guide/preferences.po     # 파일 1개
/translate source/locales/ko/LC_MESSAGES/end-user-guide/collaborate/       # 하위 디렉토리
```

**스킬이 자동으로 하는 일**: 대상 검사(제외 대상·타인 담당 거부) → 번역 지침·용어집 로드 →
원문 문서로 문맥 파악 → msgstr 번역 → 검증 스크립트 실행 → **검증 통과 시에만 커밋** → 결과 보고.

**스킬이 하지 않는 일**: `git push`(사람이 직접 — 4절), 다른 디렉토리 번역, 카탈로그 갱신(`make update-po-ko`).

- 권장 작업 단위: **세션당 1~3개 파일**. 컨텍스트가 길어지면 품질이 떨어지므로 파일을 끝내면 새 세션을 여세요.
- 결과 보고에서 확인할 것: `빈 msgstr로 남김`(사유가 코드/식별자면 정상), `fuzzy 잔여 0`,
  `용어집 후보`(있으면 가이드 8-3절 절차로 용어집에 추가).
- 스킬 없이 수동으로 번역해도 됩니다 — 그 경우 [TRANSLATION_GUIDE.md](TRANSLATION_GUIDE.md) 4·5·7·8절을 직접 준수하고
  커밋 전 검증을 잊지 마세요: `pipenv run python scripts/validate-ko-po.py <파일>`

## 4. 푸시

스킬이 커밋까지 만들어 두므로, 세션이 끝나면 직접 push합니다:

```bash
git push || { git pull --rebase origin feat/ko && git push; }
```

여러 명이 동시에 push하면 거부가 자주 발생합니다 — **같은 명령을 그대로 반복**하면 됩니다.
서로 다른 디렉토리의 .po는 구조적으로 충돌하지 않으니 rebase는 항상 깨끗하게 끝납니다.

진행률 확인:

```bash
pipenv run python scripts/validate-ko-po.py --stats-only source/locales/ko/LC_MESSAGES/<내 디렉토리>
# 또는 (sphinx-intl 설치 시) make stat-ko
```

## 5. 병행 작업 5칙 (요약)

1. **본인이 선점한 디렉토리의 .po만** 편집한다 (+ ASSIGNMENTS.md의 본인 행)
2. **msgid·헤더·`#:`·`#~`는 불가침** — msgstr만 편집
3. **`make update-po-ko` 절대 금지** — 전체 카탈로그가 변경되어 모든 작업자와 충돌 (메인테이너 전용)
4. **커밋 전 검증 통과 필수** (스킬 사용 시 자동)
5. push 거부는 정상 — `git pull --rebase` 후 재시도

## 6. 중단·재개와 문제 해결

**세션을 중단했다가 이어서 하려면**: 리포 루트에서 `claude` 재실행 → `git status`로 미커밋 변경 확인 →
같은 파일로 `/translate`를 다시 호출하면 현황(번역/미번역)을 파악해 이어서 진행합니다.

**/translate가 목록에 없을 때**: 리포 루트에서 실행했는지 확인하세요 (`.claude/commands/translate.md`가 보이는 위치).

**스킬이 "다른 사람 담당"이라며 멈출 때**: ASSIGNMENTS.md를 확인하세요. 본인 담당이 맞으면 claim 커밋이 push됐는지 확인합니다.

**fuzzy 항목이 수백 개일 때**: 업스트림 동기화 직후의 정상 상태입니다. 가이드 4-5절 절차대로 처리하면 기존 번역이 초안으로 남아 있어 빠릅니다.

**원문(msgid)이 이상할 때**: 고치지 말고 [ASSIGNMENTS.md](ASSIGNMENTS.md) 하단 "메인테이너 메모"에 기록하세요.

**내 번역을 사이트로 확인하고 싶을 때**:

```bash
make livehtml-ko    # http://127.0.0.1:8000 — .po 저장 시 자동 갱신
```
