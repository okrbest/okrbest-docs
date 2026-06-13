<!-- 이 파일이 작업 규칙의 단일 원본입니다. Codex CLI는 이 파일을 자동 로드하고,
     Claude Code는 CLAUDE.md의 `@AGENTS.md` import로 같은 내용을 읽습니다.
     규칙은 이 파일만 고치면 양쪽 도구에 반영됩니다 (CLAUDE.md는 수정 불필요). -->

# okrbest-docs

Mattermost 제품 문서(Sphinx 8.2 + Furo, pipenv)의 okrbest 포크.
한국어(ko) 번역 작업 진행 중 — 브랜치 `feat/ko`, 번역 파일 `source/locales/ko/LC_MESSAGES/**/*.po`.

- 번역 절차(신규 작업자 진입점): [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md)
- 번역 규칙·용어집: [TRANSLATION_GUIDE.md](TRANSLATION_GUIDE.md)
- 담당 현황: [ASSIGNMENTS.md](ASSIGNMENTS.md)
- 번역 자동화: Claude Code `/translate <po파일|디렉토리>` · Codex CLI `/skills` → `translate`(또는 `$translate <po파일|디렉토리>`).
  스킬 정의 — Claude: [.claude/commands/translate.md](.claude/commands/translate.md), Codex: [.codex/skills/translate/SKILL.md](.codex/skills/translate/SKILL.md).

## 한국어 번역 작업 시 절대 규칙 (.po 파일을 편집할 때만 적용)

1. **msgstr만 편집한다.** msgid, 헤더 엔트리, `#:` 주석, `#~` 항목은 절대 수정 금지.
2. **마크업 1:1 보존**: `:doc:`/`:ref:` 타겟, ``리터럴`` 내용, `|치환자|`, URL은 원문 그대로.
   msgid 전체가 코드·식별자·치환자 이름이면 msgstr를 비워 둔다(영어 폴백).
3. **합니다체** + TRANSLATION_GUIDE.md 8절 용어집 준수 (okrbest 제품 한국어 UI 기준 —
   예: System Console → 관리자 도구, Direct Message → 개인 메시지).
   **제품 지칭 "Mattermost"는 "OKR.BEST"로 리브랜딩** — 단 외부 Mattermost 서비스
   링크·원저작사·앱명·에디션명은 유지 (가이드 6-1절).
4. [ASSIGNMENTS.md](ASSIGNMENTS.md)에서 **본인이 맡은 디렉토리의 파일만** 편집한다.
5. `agents/`, `_generated/`, `_static/`, product-overview 체인지로그류는 **번역하지 않는다**.
   단 예외: `agents/docs/providers.po`·`aws_bedrock_setup.po`·`sovereign_ai.po`·`usage_tips.po` 4개는 사이트에 노출되는
   사용자 문서라 번역 대상이다 (가이드 6-2절). admin_guide·user_guide 본문은 부모 카탈로그
   `end-user-guide/agents.po`·`administration-guide/configure/agents-admin-guide.po`에서 번역한다.
   `source/scripts/`의 `gencert.po`(SAML 인증서 가이드)도 렌더링 문서라 번역 대상이다 (가이드 6-3절).
   `source/samples/`의 다운로드 샘플 자산은 번역하지 않지만, `samples/index.po`는 렌더링 문서라
   번역 대상이다 (가이드 6-4절).
6. **`make update-po-ko` 절대 실행 금지**(메인테이너 전용). `source/` 원문도 수정 금지.
7. 커밋 전 `pipenv run python scripts/validate-ko-po.py <파일>` 통과 필수.
   커밋 메시지: `ko(<디렉토리>): <파일> 번역 (<N>건)`. push는 사람이 직접.

## 빌드 (참고)

- `make html` → 영어 사이트 `build/html/` · `make html-ko` → 한국어 사이트 `build/html/ko/`
- `make livehtml-ko` → 한국어 실시간 미리보기 (.po 저장 시 자동 갱신)
- `make stat-ko` → 진행률 (sphinx-intl 필요 — Pipfile에 없음: 업스트림 awscli의 docutils 핀과
  충돌하므로 `uv tool install sphinx-intl`로 별도 설치. 대안: `validate-ko-po.py --stats-only`)
- 의존성 설치: `pipenv install --dev` (Python 3.12 필요 시 `uv python install 3.12` 후
  `pipenv install --dev --python "$(uv python find 3.12)"`)
