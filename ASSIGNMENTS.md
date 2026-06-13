# 번역 담당 현황

**선점(claim) 절차**: 아래 표에서 원하는 행의 담당자 칸에 본인 이름을 적고 상태를 `진행 중`으로 변경 →
`ko(claim): <디렉토리> — <이름>` 으로 커밋 → **즉시 push** (다른 작업자에게 선점 공표).
push가 거부되면 `git pull --rebase origin feat/ko` 후 다시 push — 표 충돌 시 양쪽 행을 모두 살려 병합합니다.

| 디렉토리 | 규모(파일/문자열) | 담당자 | 상태 | 시작일 |
|---|---|---|---|---|
| end-user-guide/ | 97 / ~4,500 | ux-builder | 진행 중 | 2026-06-13 |
| deployment-guide/ | 61 / ~4,700 | 메인테이너 | 진행 중 | 2026-06-13 |
| administration-guide/comply/ | 8 / ~1,100 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/configure/ | 34 / ~6,900 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/manage/ | 37 / ~2,800 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/onboard/ | 34 / ~2,900 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/scale/ | 28 / ~1,400 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/upgrade/ | 13 / ~1,500 | ux-builder | 진행 중 | 2026-06-13 |
| administration-guide/ (루트 4파일) | 4 / 소량 | ux-builder | 진행 중 | 2026-06-13 |
| integrations-guide/ | 21 / ~1,400 | ux-builder | 완료 | 2026-06-13 |
| security-guide/ | 8 / ~330 | ux-builder | 완료 | 2026-06-13 |
| use-case-guide/ | 10 / ~320 | ux-builder | 완료 | 2026-06-13 |
| get-help/ | 4 / 149 | 메인테이너 | 완료(파일럿) | 2026-06-13 |
| product-overview/ (체인지로그 제외) | 27 / ~1,000 | 메인테이너 | 완료 | 2026-06-13 |
| recipes/ | 1 / 38 | ux-builder | 완료 | 2026-06-13 |
| scripts/generate-certificates/ | 1 / ~20 | ux-builder | 진행 중 | 2026-06-13 |
| samples/index.po | 1 / 1 | 메인테이너 | 완료 | 2026-06-13 |
| 루트 index.po + sphinx.po | 2 / 39 | 메인테이너 | 완료 | 2026-06-11 |

번역 제외(담당 불필요): product-overview 체인지로그류, agents/, _generated/, _static/, samples/ 다운로드 자산
— 사유는 [TRANSLATION_GUIDE.md](TRANSLATION_GUIDE.md) 3·6절 참조.
**예외**: `agents/docs/providers.po`·`aws_bedrock_setup.po`·`sovereign_ai.po`·`usage_tips.po` 4개는 사이트 노출 사용자 문서라
번역 대상(가이드 6-2절, 담당: ux-builder). admin_guide·user_guide는 부모 카탈로그
`end-user-guide/agents.po`·`administration-guide/configure/agents-admin-guide.po`에서 번역.
`scripts/generate-certificates/gencert.po`도 렌더링 문서라 번역 대상(가이드 6-3절).
`samples/index.po`는 `samples/index.html`로 렌더링되는 orphan 문서라 번역 대상(가이드 6-4절).

## 메인테이너 메모

원문(msgid) 오류·낡은 내용 발견 시 아래에 기록하세요. 원문은 직접 수정하지 않습니다.

- (예시) `end-user-guide/xxx.po:123` — msgid의 메뉴 경로가 현재 UI와 다름
