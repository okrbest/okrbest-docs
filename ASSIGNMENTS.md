# 번역 담당 현황

**선점(claim) 절차**: 아래 표에서 원하는 행의 담당자 칸에 본인 이름을 적고 상태를 `진행 중`으로 변경 →
`ko(claim): <디렉토리> — <이름>` 으로 커밋 → **즉시 push** (다른 작업자에게 선점 공표).
push가 거부되면 `git pull --rebase origin feat/ko` 후 다시 push — 표 충돌 시 양쪽 행을 모두 살려 병합합니다.

상태의 % 는 `validate-ko-po.py --stats-only` 기준 번역률(2026-06-15 점검). 자세한 누락 점검 결과는 아래 [누락 점검](#누락-점검-2026-06-15) 참조.
`†` = 잔여 미번역은 모두 **의도적 영어 폴백**(고유 제품명·외부 UI 라벨·식별자·CVE·치환자 정의)으로 확인됨 — 누락 아님.
`*` = 산문은 사실상 완료, 잔여는 감사로그 이벤트 식별자(`` ``createUser`` `` 등) 영어 폴백.

| 디렉토리 | 규모(파일/문자열) | 담당자 | 상태 | 시작일 |
|---|---|---|---|---|
| end-user-guide/ | 97 / ~4,500 | ux-builder | 진행 중 · 95% | 2026-06-13 |
| deployment-guide/ | 61 / ~4,700 | 메인테이너 | 진행 중 · 52% | 2026-06-13 |
| administration-guide/comply/ | 8 / ~1,100 | ux-builder | 진행 중 · 산문 완료* | 2026-06-13 |
| administration-guide/configure/ | 34 / ~6,900 | ux-builder | 진행 중 · 96% | 2026-06-13 |
| administration-guide/manage/ | 37 / ~2,800 | ux-builder | 진행 중 · 86% | 2026-06-13 |
| administration-guide/onboard/ | 34 / ~2,900 | ux-builder | 진행 중 · 87% | 2026-06-13 |
| administration-guide/scale/ | 28 / ~1,400 | ux-builder | 진행 중 · 95% | 2026-06-13 |
| administration-guide/upgrade/ | 13 / ~1,500 | ux-builder | 진행 중 · 90% | 2026-06-13 |
| administration-guide/ (루트 4파일) | 4 / 소량 | ux-builder | 진행 중 · 99% | 2026-06-13 |
| integrations-guide/ | 21 / ~1,400 | ux-builder | 완료 · 92%† | 2026-06-13 |
| security-guide/ | 8 / ~330 | ux-builder | 완료 · 99%† | 2026-06-13 |
| use-case-guide/ | 10 / ~320 | ux-builder | 완료 · 100% | 2026-06-13 |
| get-help/ | 4 / 149 | 메인테이너 | 완료(파일럿) · 86%† | 2026-06-13 |
| product-overview/ (체인지로그 제외) | 27 / ~1,000 | 메인테이너 | 완료† | 2026-06-13 |
| recipes/ | 1 / 38 | ux-builder | 완료 · 100% | 2026-06-13 |
| scripts/generate-certificates/ | 1 / ~20 | ux-builder | 완료 · 96%† | 2026-06-13 |
| samples/index.po | 1 / 1 | 메인테이너 | 완료 · 100% | 2026-06-13 |
| 루트 index.po + sphinx.po | 2 / 39 | 메인테이너 | 완료 · 92%† | 2026-06-11 |

번역 제외(담당 불필요): product-overview 체인지로그류, agents/, _generated/, _static/, samples/ 다운로드 자산
— 사유는 [TRANSLATION_GUIDE.md](TRANSLATION_GUIDE.md) 3·6절 참조.
**예외**: `agents/docs/providers.po`·`aws_bedrock_setup.po`·`sovereign_ai.po`·`usage_tips.po` 4개는 사이트 노출 사용자 문서라
번역 대상(가이드 6-2절, 담당: ux-builder).
상태(2026-06-15): `sovereign_ai.po`·`usage_tips.po` 완료, `providers.po`(169/197)·`aws_bedrock_setup.po`(98/123) 진행 중 — 잔여는 대부분 제공자 제품명·설정 라벨(영어 폴백).
admin_guide·user_guide는 부모 카탈로그
`end-user-guide/agents.po`·`administration-guide/configure/agents-admin-guide.po`에서 번역.
`scripts/generate-certificates/gencert.po`도 렌더링 문서라 번역 대상(가이드 6-3절).
`samples/index.po`는 `samples/index.html`로 렌더링되는 orphan 문서라 번역 대상(가이드 6-4절).

## 누락 점검 (2026-06-15)

`validate-ko-po.py --stats-only` + 산문/폴백 분류기로 담당 `.po` 전체를 재검토했습니다. 전체 번역률 53.5%(24,949/46,605)이나, 미번역 다수는 **번역 제외 대상**(체인지로그·`agents/`·`_generated/`)과 **의도적 영어 폴백**입니다.

- **"완료" 디렉토리 검증 — 누락 없음**: integrations·security·use-case·recipes·scripts·samples·get-help·product-overview(비-체인지로그)의 잔여 미번역은 전부 의도적 영어 폴백(Microsoft 등 고유 제품명, GitHub/Azure/Keycloak 설정폼 라벨·GUID, CVE·패키지 경로, `` |plans-img-yellow| `` 등 치환자 정의)입니다. 한국어 문장이 실수로 빠진 사례는 **발견되지 않았습니다**.
- **체계적 누락 1건 발견 — 가용성 배너 → 해소 완료(2026-06-16)**: `` |plans-img-yellow| Available on `…plans` `` 안내 문장이 전체 249곳은 번역됐으나 `administration-guide/configure/`에서 22곳 미번역이었습니다(예: `smtp-email.po`는 이 배너 1줄만 빠지고 나머지 100% 완료). 검증된 번역문으로 21건(17개 파일)을 채워 커밋했고, 나머지 1건은 아래 `enabling-chinese-japanese-korean-search.po` 커밋에 포함했습니다.

### 미완성 파일 완성 패스 (2026-06-16)

`미완성된 po 파일들을 순차적으로 완성` 요청으로 담당 디렉토리의 미완성 파일을 영역별로 재번역·커밋했습니다. **실제로 번역할 산문이 남아 있던 파일은 소수**였고, 나머지는 이미 산문 완료 상태(잔여 미번역 = 식별자·CLI 명령어·설정 폼 라벨·벤치마크 수치·감사로그 이벤트명 등 의도적 영어 폴백)임을 전수 확인했습니다.

- 커밋한 번역: configure 가용성 배너 21건(17파일) · `enabling-chinese-japanese-korean-search.po` 39건(7→46/49) · `sso-saml-keycloak.po` 1건(alt 텍스트) · `important-upgrade-notes.po` 2건(SQL 안내문).
- 이미 산문 완료(변경 없음)로 확인된 파일: `mmctl-command-line-tool.po`·`command-line-tools.po`·`telemetry.po`·`logging.po`·`generating-support-packet.po`·`error-codes.po`·`agents-admin-guide.po`·`calls-*`(6) · onboard `bulk-loading-data`·`sso-saml-onelogin`·`advanced-permissions-backend-infrastructure`·`delegated-granular-administration` · `backing-storage-benchmarks.po` · comply `compliance-monitoring`·`embedded-json-audit-log-schema` · end-user-guide `keyboard-shortcuts`·`team-keyboard-shortcuts`·`keyboard-accessibility`·`client-availability` · agents 예외 `providers`·`aws_bedrock_setup`.
- 메인테이너 확인 필요(아래 메모 참조): `important-upgrade-notes.po`의 깨진 백틱 msgid 1건.

## 메인테이너 메모

원문(msgid) 오류·낡은 내용 발견 시 아래에 기록하세요. 원문은 직접 수정하지 않습니다.

- (예시) `end-user-guide/xxx.po:123` — msgid의 메뉴 경로가 현재 UI와 다름
- `administration-guide/upgrade/important-upgrade-notes.po` (원문 `...rst:2033` 부근) — `` Mattermost `/platform` repo has been separated... `` msgid의 백틱 개수가 홀수(깨진 인라인 리터럴)라 산문을 번역하면 `validate-ko-po.py`가 리터럴 불일치로 실패합니다. 업스트림 원문 오류이므로 영어 폴백 유지 중. 업스트림에서 백틱 수정 후 재추출 필요.
