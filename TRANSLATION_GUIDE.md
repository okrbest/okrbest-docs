# okrbest-docs 한국어 번역 지침

Mattermost 제품 문서 포크(okrbest-docs)의 한국어 번역 작업 규칙과 용어집입니다.
**처음 합류했다면 [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md)의 절차를 먼저 따라 하세요.**
이 문서는 번역 중 수시로 참조하는 규칙 레퍼런스입니다.

- 브랜치: `feat/ko` · 번역 파일: `source/locales/ko/LC_MESSAGES/**/*.po` · 결과물: `build/html/ko/`
- 담당 현황: [ASSIGNMENTS.md](ASSIGNMENTS.md) · 자동화: Claude CLI에서 `/translate` (지침 준수가 내장됨)

## 1. 핵심 원칙

> **빈 msgstr와 fuzzy 항목은 빌드 시 영어 원문으로 렌더링됩니다(영어 폴백).**
> 미번역은 안전합니다. 진짜 사고는 **마크업이 깨진 번역**입니다(링크 깨짐, 치환 실패).
> 따라서 **양보다 품질**: 확신 없는 항목은 비워 두는 것이 잘못 번역하는 것보다 낫습니다.

규모: 451개 카탈로그, 약 47,000개 문자열. 문서 1개 = .po 1개로 매핑됩니다:

```
source/locales/ko/LC_MESSAGES/<경로>/<문서>.po  ↔  source/<경로>/<문서>.rst (또는 .md)
```

## 2. 사전 준비

- 필수: `git clone` 후 `git switch feat/ko`. .po 편집 자체는 이것으로 충분합니다.
- 검증·빌드(권장): 리포 루트에서 `pipenv install --dev` 1회.
  - 검증: `pipenv run python scripts/validate-ko-po.py <파일|디렉토리>`
  - 한국어 빌드: `make html-ko` / 실시간 미리보기: `make livehtml-ko`
- `make stat-ko`는 sphinx-intl CLI가 필요합니다(`uv tool install sphinx-intl` 또는 `pip install --user sphinx-intl`).
  sphinx-intl은 의도적으로 Pipfile에 없습니다(업스트림 awscli의 docutils 핀과 충돌).
  설치가 번거로우면 `validate-ko-po.py --stats-only`가 같은 통계를 제공합니다.

## 3. 작업 분담 및 우선순위

실시간 담당 현황은 [ASSIGNMENTS.md](ASSIGNMENTS.md)에서 관리합니다. 분량과 우선순위:

| 디렉토리 | 파일 | 문자열(약) | 우선순위 / 비고 |
|---|---:|---:|---|
| end-user-guide/ | 97 | 4,500 | **1순위** — 최종 사용자 노출 최대 |
| deployment-guide/ | 61 | 4,700 | **1순위** |
| administration-guide/ | 158 | 16,800 | **1순위** — 하위 폴더 단위로 2~3명 분할 권장 |
| integrations-guide/ | 21 | 1,400 | 2순위 |
| security-guide/ | 8 | 330 | 2순위 |
| use-case-guide/ | 10 | 320 | 2순위 |
| get-help/ | 4 | 149 | 2순위 |
| product-overview/ (체인지로그 제외) | ~15 | 소량 | 2순위 |
| **product-overview/ 체인지로그·릴리스류** | ~24 | **16,000** | **보류 — 번역하지 않음** (버전 이력 산문, 영어 폴백 허용) |
| 루트 index.po / sphinx.po | 2 | 25+14 | 메인테이너 (일부 완료) |
| recipes/ | 1 | 38 | 잔여분 |
| agents/, _generated/, _static/, samples/, scripts/ | — | — | **제외** (아래 6절) |

> ⚠️ **product-overview의 체인지로그류 파일(`*changelog*`, `*-releases*`, `release-policy` 등 버전 이력 문서)은 절대 번역하지 마세요.** 16,000개 문자열을 소모하는 최대 헛수고 함정입니다.

## 4. .po 파일 형식 규칙

### 4-1. msgstr만 편집한다

```po
# ✅ 올바름 — msgid는 그대로, msgstr만 작성
msgid "Manage your channel settings."
msgstr "채널 설정을 관리합니다."

# ❌ 금지 — msgid 수정 (빌드에서 번역이 통째로 무시됨)
msgid "채널 설정을 관리합니다."
msgstr ""
```

원문(msgid)에 오타가 있어도 **절대 고치지 마세요**. 그대로 번역하거나 비워 두고,
[ASSIGNMENTS.md](ASSIGNMENTS.md)의 "메인테이너 메모"에 적어 주세요.

### 4-2. 여러 줄 문자열

긴 문자열은 `msgstr ""` 다음 줄부터 큰따옴표로 감싼 줄을 이어 씁니다. 줄들은 그대로 이어 붙여집니다(공백 자동 삽입 없음 — **줄 경계의 공백을 직접 책임져야 합니다**).

```po
# ✅ 올바름 (실제 index.po에서 발췌)
msgstr ""
"Mattermost의 목표는 안전한 오픈 코어 협업 소프트웨어를 개발·제공하여 고객에게 "
"비교할 수 없는 집중력, 적응성, 회복탄력성을 제공함으로써 전 세계의 미션 크리티컬한 "
"업무를 가속화하는 것입니다."
```

줄을 어디서 끊는지는 자유입니다(정확성과 무관). 단, **번역하지 않는 항목의 줄바꿈을 재정렬하지 마세요** — diff 노이즈만 생깁니다.

### 4-3. 이스케이프

`\"`(큰따옴표)와 `\n`(줄바꿈)은 반드시 보존합니다.

```po
# msgid: "Select \"Save\" to continue."
# ✅ msgstr "계속하려면 \"저장\"을 선택하세요."
# ❌ msgstr "계속하려면 "저장"을 선택하세요."   ← 파싱 에러
```

### 4-4. 건드리지 않는 것

- **헤더 엔트리**: 파일 첫 `msgid ""` 블록 전체 (그 위의 `#, fuzzy` 포함 — 빌드에 영향 없음)
- **`#:` 위치 주석**: 원문 파일·행 표시 (자동 생성)
- **`#~` 폐기 항목**: 과거 번역 보관소 (자동 관리)

### 4-5. fuzzy 처리

`#, fuzzy` 플래그가 붙은 항목은 도구가 **추측으로 채운 번역**이며, 빌드에서 무시됩니다(영어 폴백).

처리 절차: ① 현재 msgid를 기준으로 msgstr 번역을 검증·수정 → ② **그 후에만** `#, fuzzy` 줄 삭제.

```po
# ❌ 절대 금지: 검증 없이 플래그만 삭제 — 오역이 그대로 사이트에 노출됨
```

## 5. 마크업 보존 규칙

번역 전후로 마크업이 1:1로 보존되어야 합니다. `validate-ko-po.py`가 자동 검사하지만, 규칙을 이해하고 작성하세요.

### 5-1. 롤(:doc:, :ref: 등) — 텍스트만 번역, 타겟 불변

```po
# msgid: ":doc:`Channel settings </end-user-guide/channels>` are available."
# ✅ msgstr ":doc:`채널 설정 </end-user-guide/channels>`을 사용할 수 있습니다."
# ❌ msgstr ":doc:`채널 설정 </최종-사용자-가이드/채널>`..."   ← 타겟 번역 금지 (링크 깨짐)
```

타겟만 있는 형태(`` :doc:`/path/page` ``)는 통째로 그대로 복사합니다.

### 5-2. 인라인 리터럴(``...``) — 내용 불변

설정 키, 명령어, 값 등입니다. 백틱 2개와 내용을 그대로 복사합니다.

```po
# msgid: "Set ``EnableOAuthServiceProvider`` to ``true``."
# ✅ msgstr "``EnableOAuthServiceProvider``를 ``true``로 설정합니다."
```

### 5-3. 치환자(|...|) — 글자 그대로 복사

```po
# msgid: "Available on |plans-img-yellow| plans."
# ✅ msgstr "|plans-img-yellow| 플랜에서 사용할 수 있습니다."
```

**msgid 전체가 치환자/식별자 이름인 항목은 번역하지 않습니다** (msgstr 비움):

```po
# _static/badges/*.po 등에서 발견됨
msgid "plans-img"
msgstr ""          # ← 비워 둠. 번역하면 치환 참조가 깨짐
```

### 5-4. 외부 링크 — 텍스트만 번역, URL·꼬리 밑줄 불변

```po
# msgid: "See the `pricing page <https://mattermost.com/pricing>`_ for details."
# ✅ msgstr "자세한 내용은 `가격 페이지 <https://mattermost.com/pricing>`_\ 를 참고하세요."
```

`_` 또는 `__` 꼬리를 정확히 유지합니다. 링크 뒤에 조사가 바로 붙으면 `` `...`_\ 를 ``처럼 백슬래시+공백으로 분리합니다.

Markdown(.md) 원문의 `[텍스트](URL)`도 동일: 텍스트만 번역, URL 불변.

### 5-5. 강조(**굵게**, *기울임*) — 표식 개수 유지 + 조사 분리 필수

⚠️ **rST는 닫는 표식(`**`, `` ` ``) 바로 뒤에 한글이 오면 마크업 인식에 실패합니다**
(`**Add**를` → 굵게가 깨지고 `Add**를`로 그대로 출력됨). 인라인 마크업 뒤에 조사가
바로 붙을 때는 반드시 `\ `(백슬래시+공백)로 분리하세요 — .po 파일 안에서는 `\\ `로 적습니다:

```po
# msgid: "Select **Add** to install."
# ✅ msgstr "**Add**\\ 를 선택해 설치합니다."     ← 렌더링: "Add를" (굵게 정상)
# ❌ msgstr "**Add**를 선택해 설치합니다."        ← 굵게 깨짐 + 빌드 경고
# (조사 대신 공백+명사가 오면 분리 불필요: "**Add** 버튼을 선택합니다.")
```

같은 규칙이 링크·롤·리터럴 뒤 조사에도 적용됩니다(5-4절 참고).

내비게이션 경로는 굵게 표시되며, **관리자 도구의 실제 한국어 라벨**로 번역합니다(7절 용어집):

```po
# msgid: "Go to **System Console > Site Configuration > Customization**."
# ✅ msgstr "**관리자 도구 > 사이트 설정 > 커스터마이징**\\ 으로 이동합니다."
```

### 5-6. 기타

- **이미지 대체 텍스트(alt)**: 일반 msgid로 추출됩니다. **번역 대상**입니다(접근성).
- **msgid 전체가 코드/명령어/설정 조각인 경우**: msgstr를 비워 둡니다(영어 폴백) — 가장 안전합니다.
- **앞뒤 공백**: msgid가 공백으로 시작/끝나면 msgstr도 동일하게 맞춥니다(검증기가 확인).

## 6. 번역 제외 대상

| 대상 | 이유 |
|---|---|
| `agents/` 카탈로그 (아래 예외 제외) | 서브모듈(영문 플러그인 문서) — 영어 유지가 설계 |
| `_generated/` 카탈로그 | 자동 생성 사본 (실제 화면은 부모 카탈로그가 구동 — 아래 6-2절) |
| `_static/badges/` 카탈로그 | msgid가 치환자 이름 — 번역 금지 (5-3절) |
| product-overview 체인지로그류 | 정책상 보류 (3절) |
| 설정 키(`SiteURL` 등), 환경 변수, CLI 명령, 파일 경로, URL, 버전 번호 | 식별자 — 변경 시 동작 깨짐 |
| 라이선스명, 법적 고지 원문 | 법적 정확성 |

기능명(Channels, Playbooks, Boards 등)은 **제외 대상이 아니라 한국어화 대상**입니다 — 7절 용어집을 따릅니다.

### 6-1. 브랜딩: Mattermost → OKR.BEST

이 문서 사이트는 OKR.BEST 제품용입니다. 제품 포크의 UI 번역과 동일하게,
**사용자가 쓰는 제품·플랫폼을 지칭하는 "Mattermost"는 "OKR.BEST"로 옮깁니다.**

```po
# msgid: "Set up your Mattermost server."
# ✅ msgstr "OKR.BEST 서버를 설정합니다."
# msgid: "Get the help you need with Mattermost."
# ✅ msgstr "OKR.BEST에 필요한 도움을 받으세요."
```

**"Mattermost"를 유지하는 경우** (치환하면 사실관계·링크가 틀어짐):

| 유지 대상 | 예 |
|---|---|
| URL·링크 타겟·코드·식별자 | `https://mattermost.com/...` (5절 마크업 규칙상 원래 불변) |
| **외부 Mattermost 서비스로 연결되는 링크의 텍스트·서비스 고유명** — 클릭하면 실제 Mattermost사 서비스가 열림 | Mattermost Academy, Mattermost 커뮤니티 서버, Mattermost 헬프 센터, Mattermost 지원 약관, Mattermost 포럼, Mattermost 제품/개발자 문서(README 포함) |
| 오픈소스 프로젝트·원저작사 지칭 | 기여 안내 문서의 "Mattermost에 기여", "Mattermost, Inc.", 평가 계약·법적 문서명 |
| 제3자 스토어 등록 앱명 | Mattermost for Microsoft 365, Community for Mattermost |
| 에디션·요금제명 | Mattermost Enterprise / Professional / Free (구매·지원이 mattermost.com 기준) |

판단 기준: **그 문장이 "지금 독자가 쓰는 제품"을 말하면 OKR.BEST, "Mattermost사(社)의
외부 자원·원본 프로젝트"를 말하면 Mattermost.** 애매하면 유지하고 ASSIGNMENTS.md 메모에 남기세요.

### 6-2. Agents 문서 예외 (서브모듈이지만 번역 대상)

`source/agents/`는 서브모듈이라 카탈로그 전체를 제외하는 것이 기본이지만, 일부는 **실제 OKR.BEST
사이트 내비게이션에 노출되는 사용자/관리자 문서**입니다. 렌더링 경로에 따라 번역 위치가 다릅니다:

| 사이트 페이지 | 원문 연결 방식 | **번역할 카탈로그** |
|---|---|---|
| 엔드유저 → AI 에이전트 | `end-user-guide/agents.rst`가 `user_guide.md`를 `include` | **`end-user-guide/agents.po`** (제외 아님) |
| 관리자 → Agents 관리 가이드 | `agents-admin-guide.rst`가 `admin_guide.md`를 `include` | **`administration-guide/configure/agents-admin-guide.po`** (제외 아님) |
| ↳ LLM 공급자 설정 | `agents-admin-guide` toctree의 standalone 페이지 | **`agents/docs/providers.po`** ✅예외 |
| ↳ AWS Bedrock 설정 | 〃 | **`agents/docs/aws_bedrock_setup.po`** ✅예외 |
| ↳ 소버린 AI 구현 | 〃 | **`agents/docs/sovereign_ai.po`** ✅예외 |

- `include`되는 문서(admin_guide·user_guide)의 번역 문자열은 **삽입되는 부모 페이지 카탈로그**에 들어 있습니다.
  따라서 `agents/docs/admin_guide.po`·`user_guide.po`와 `_generated/agents/docs/*.po`는 사이트에 안 보이는
  **고아 중복본**이므로 번역하지 마세요(헛수고). 부모 카탈로그 2개를 번역하면 됩니다.
- toctree의 standalone 페이지 3개(`providers`·`aws_bedrock_setup`·`sovereign_ai`)는 부모가 없으므로
  유일한 카탈로그가 `agents/docs/` 아래에 있습니다 — 이 3개만 예외로 번역합니다.
  (이 `.po`들은 서브모듈이 아니라 메인 리포의 `locales/`에 있어 서브모듈 갱신으로 덮어쓰이지 않습니다.)
- `agents/`의 나머지(`README`·`AGENTS.md`·`CLAUDE.md`·`mcpserver/`·`.claude/`·`skills/`·`usage_tips`·
  `upgrading_to_2.0`·`features/*` 등)는 toctree 참조가 없는 저장소·개발용 파일이므로 계속 제외합니다.

## 7. 문체 규칙

**기준 예시: `source/locales/ko/LC_MESSAGES/index.po`의 기번역 항목.**

| 규칙 | ✅ | ❌ |
|---|---|---|
| 합니다체 | ~할 수 있습니다 / ~하세요(지시) | ~할 수 있어요 / ~함 |
| 평서 종결 | 채널을 생성합니다. | 채널을 생성한다. |
| 외래어 표기 | 라이선스, 아카이브, 릴리스 | 라이센스, 아카이브, 릴리즈 |
| 영한 띄어쓰기 | Docker 컨테이너, OKR.BEST 서버 | Docker컨테이너 |
| 조사 직결 | OKR.BEST는, API를, ``true``로 | OKR.BEST 는 |
| "you" 처리 | (주어 생략) 채널을 만들 수 있습니다 | 당신은 채널을 만들 수… |
| 명령형 지시 | 저장을 선택하세요 | 저장을 선택하십시오(과격식) |

- 구두점: 문장 끝 마침표 유지, rST 의미 기호(백틱·별표·파이프)를 한국어 따옴표 등으로 바꾸지 않습니다.
- 단위·숫자: 원문 그대로 (GB, ms, 30 days → 30일).

## 8. 용어집

**용어 기준 = okrbest 제품 포크의 실제 한국어 UI** (문서를 읽는 사용자가 화면에서 보는 표기와 일치해야 합니다):

- webapp(1차): <https://raw.githubusercontent.com/okrbest/okrbest/master/webapp/channels/src/i18n/ko.json> — 평면 객체 `{키: 번역}`
- server(보조): <https://raw.githubusercontent.com/okrbest/okrbest/master/server/i18n/ko.json> — 배열 `[{id, translation}]`
- 두 출처가 다르면 **webapp 우선**.

### 8-1. 핵심 용어 (포크 ko.json 검증 완료)

| 영어 | 한국어 | 비고 |
|---|---|---|
| Mattermost (제품 지칭) | **OKR.BEST** | 리브랜딩 — 예외는 6-1절 |
| channel | 채널 | |
| Direct Message (DM) | 개인 메시지 | ⚠️ "다이렉트 메시지" 아님 |
| Group Message | 그룹 메시지 | |
| team | 팀 | |
| thread | 스레드 | |
| mention | 멘션 | |
| notification | 알림 | |
| message | 메시지 | |
| post | 글 | 메시지(message)와 구분 |
| pinned messages | 고정된 메시지 | |
| saved messages | 저장된 메시지 | |
| drafts | 임시글 | |
| **System Console** | **관리자 도구** | ⚠️ "시스템 콘솔" 아님 |
| Site Configuration | 사이트 설정 | |
| settings | 설정 | |
| Boards | 보드 | |
| Playbooks | 플레이북 | |
| Calls | 통화 | |
| integrations | 통합 | |
| incoming webhook | 수신 웹훅 | |
| outgoing webhook | 발신 웹훅 | |
| slash command | 슬래시 명령어 | |
| bot account | 봇 계정 | |
| plugin | 플러그인 | |
| member | 구성원 | "멤버" 지양 |
| guest | 게스트 | |
| status | 상태 | |
| custom status | 사용자 정의 상태 | |
| emoji | 이모지 | |
| favorites | 즐겨찾기 | |
| archived | 보관됨 / 보관된 | |
| workspace | 워크스페이스 | |
| permissions | 권한 | |
| System Admin | 시스템 관리자 | |
| Channel Admin | 채널 관리자 | |
| username | 사용자 ID | ⚠️ "사용자명" 아님 |
| display name | 표시명 | |
| password | 비밀번호 | 관리자 도구 메뉴 라벨은 "패스워드" |
| profile picture | 프로필 사진 | |
| keyboard shortcuts | 키보드 단축키 | |
| sign up | 회원가입 | |
| log in / log out | 로그인 / 로그아웃 | |
| High Availability | 고가용성 | |
| data retention policy | 데이터 보존 정책 | |
| license | 라이선스 | |
| compliance | 컴플라이언스 | 관리자 도구 메뉴 라벨은 "감사" |

### 8-2. 관리자 도구 내비게이션 라벨 (경로 표기용)

문서의 `**System Console > ...**` 경로는 아래 실제 메뉴 라벨로 옮깁니다:

| 영어 메뉴 | 한국어 메뉴 |
|---|---|
| Environment | 환경 |
| Web Server | 웹서버 |
| Database | 데이터베이스 |
| File Storage | 파일 저장소 |
| Push Notification Server | 푸시 알림 서버 |
| Rate Limiting | 속도 제한 |
| Logging | 로그 |
| Session Lengths | 세션길이 |
| Site Configuration | 사이트 설정 |
| Customization | 커스터마이징 |
| Localization | 지역화 |
| Users and Teams | 사용자와 팀 |
| Notifications | 알림 |
| Public Links | 공개 링크 |
| Authentication | 인증 |
| MFA | MFA |
| Guest Access | 게스트 접근(Beta) |
| User Management | 사용자 관리 |
| Edition and License | 라이선스와 에디션 |
| Experimental | 실험적 기능 |

### 8-3. 미등재 용어 해결 규칙

1. 위 두 ko.json에서 검색 (webapp 우선)
2. **있으면**: 그 표기를 사용하고 이 용어집에 행 추가 → `ko(glossary): <용어> 추가` 커밋
3. **없으면**: 국내 기술 문서 관행 표기를 쓰고, 비고에 `비공식` 표기 후 행 추가

용어집 수정은 행 추가만 하므로(append-only) 병렬 작업 충돌이 거의 없습니다.

## 9. 세션 워크플로

1. `git pull --rebase origin feat/ko`
2. [ASSIGNMENTS.md](ASSIGNMENTS.md)에서 본인 담당 확인 (미배정이면 먼저 claim — WORKFLOW 문서 2절)
3. 번역: Claude CLI에서 `/translate <파일|디렉토리>` 또는 수동 편집
4. 검증: `pipenv run python scripts/validate-ko-po.py <파일>` → `OK` 확인
5. 커밋: `ko(<디렉토리>): <파일> 번역 (<N>건)` (11절 컨벤션)
6. 푸시: `git push || { git pull --rebase origin feat/ko && git push; }`
7. 진행률: `validate-ko-po.py --stats-only <본인 디렉토리>` 또는 `make stat-ko`
8. 주기적으로(파일마다 아님): `make html-ko` 후 `build/warnings-ko.log` 훑어보기

## 10. 검증 도구

```bash
pipenv run python scripts/validate-ko-po.py [--stats-only] [--quiet] <PATH...>
```

| exit | 의미 | 대응 |
|---|---|---|
| 0 | 통과 (미번역·fuzzy는 에러 아님) | 커밋 가능 |
| 1 | 번역된 항목의 마크업 깨짐 | 표시된 행 수정 후 재실행 |
| 2 | .po 문법 파싱 실패 / 잘못된 경로 | 따옴표·이스케이프 확인 |
| 3 | 사용법 오류 | 인자 확인 |

검사 항목: 롤(:doc:/:ref:) 이름·타겟, ``리터럴`` 내용, |치환자|, 링크 URL, `**` 표식 개수, 앞뒤 공백.

## 11. Git 규칙

- 작업 브랜치: **feat/ko 직접 커밋** (PR 없음). 단, 커밋 전 검증 통과는 필수.
- 본인 담당 디렉토리의 .po + ASSIGNMENTS.md(본인 행)만 수정합니다.
- **`make update-po-ko` 절대 실행 금지** — 카탈로그 갱신은 메인테이너 전용 (전체 .po가 일괄 변경되어 모든 작업자와 충돌).
- `source/` 원문, conf.py, Makefile 수정 금지.
- `.mo`는 커밋 금지(이미 gitignore 처리됨).

커밋 메시지 컨벤션:

```
ko(end-user-guide): preferences.po 번역 (87건)      # 번역
ko(claim): administration-guide/manage — 홍길동      # 담당 선점
ko(glossary): retention policy 추가                  # 용어집 행 추가
```

푸시 경쟁(병렬 작업 시 흔함):

```bash
git push || { git pull --rebase origin feat/ko && git push; }
```

실패하면 같은 명령을 반복합니다. 서로 다른 디렉토리의 .po는 구조적으로 충돌하지 않습니다.
ASSIGNMENTS.md에서 충돌하면 양쪽 행을 모두 살려 병합하세요. 본인 .po 파일에서 충돌하면
(본인만 편집하므로 비정상 상황) 본인 로컬 버전을 채택합니다.

## 12. FAQ / 문제 해결

**Q. 번역했는데 빌드에 한국어가 안 보입니다.**
해당 항목에 `#, fuzzy`가 남아 있는지 확인하세요(4-5절). 또는 `make html-ko`를 다시 실행하세요(.po 변경은 자동 반영되지만 캐시 이슈 시 `rm -rf build/doctrees-ko`).

**Q. `build/warnings-ko.log`에 경고가 있습니다.**
en 빌드(`build/warnings.log`)에도 있는 경고면 기존 문서 이슈로 무시합니다. **ko에만 있는** `inconsistent references` / `undefined label` 경고는 본인 번역의 롤·타겟 실수입니다 — 해당 .po를 수정하세요.

**Q. msgid 원문이 이상합니다(오타, 낡은 내용).**
원문은 업스트림 소유입니다. 절대 고치지 말고 ASSIGNMENTS.md 하단 "메인테이너 메모"에 기록하세요.

**Q. 한 페이지만 미리 보고 싶습니다.**
`make livehtml-ko` 실행 후 `http://127.0.0.1:8000/<경로>/<문서>.html` 접속. .po 저장 시 자동 갱신됩니다.

**Q. fuzzy가 수백 개인 파일을 만났습니다.**
업스트림 동기화 직후의 정상 상태입니다. fuzzy 항목은 기존 번역이 초안으로 들어 있으니 msgid 변경분만 반영하면 빠르게 처리됩니다.

**Q. 파일 절반만 번역하고 멈춰도 되나요?**
됩니다. 미번역 항목은 영어로 표시될 뿐입니다. 검증만 통과하면 커밋하세요.
