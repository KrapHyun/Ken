---
name: harness
description: "하네스를 설계하고 Codex용 역할 문서, 스킬, 플러그인 구조를 만든다. '하네스 구성', '하네스 설계', '에이전트 체계 구축', '워크플로우 설계', '기존 하네스 감사/확장' 요청일 때 사용한다. 현재 Codex 런타임 제약을 반영해 재사용 가능한 문서와 installable skill draft를 만들고, 사용자가 명시적으로 위임/병렬 작업을 요청한 경우에만 서브에이전트 오케스트레이션을 제안하거나 실행한다."
---

# Harness Codex

도메인이나 프로젝트에 맞는 하네스를 설계하고, 역할 문서와 스킬, 플러그인
구조까지 한 번에 정리하는 메타 스킬이다.

## 핵심 원칙

1. 일회성 프롬프트가 아니라 재사용 가능한 자산을 만든다.
2. 역할 문서는 `프로젝트/.codex/agents/`에, installable skill draft는
   `프로젝트/.codex/skills/` 또는 플러그인 내부 `skills/`에 둔다.
3. 현재 Codex가 보장하지 않는 런타임 표면은 가정하지 않는다.
4. `spawn_agent`, `send_input`, `wait_agent`, `close_agent`는 사용자가
   명시적으로 위임, 병렬화, 서브에이전트 실행을 요청했을 때만 쓴다.
5. 에이전트 간 데이터 전달은 직접 메시징보다 파일 기반 계약을 우선한다.
6. 하네스는 고정 결과물이 아니라 유지보수되는 시스템으로 취급한다.

## Phase 0: 현황 감사

하네스 작업을 시작하면 먼저 현재 구조를 확인한다.

- `프로젝트/.codex/agents/`
- `프로젝트/.codex/skills/`
- `프로젝트/plugins/`
- `프로젝트/.agents/plugins/marketplace.json`
- 기존 운영 문서가 있다면 `README`, `AGENTS.md`, `CLAUDE.md` 같은 포인터 파일

감사 결과로 다음을 정리한다.

- 신규 구축인지, 기존 하네스 확장인지
- 기존 역할 문서와 스킬 초안이 어디까지 있는지
- 플러그인 패키징이 이미 있는지
- 문서와 실제 구조 사이에 drift가 있는지

## Phase 1: 도메인 분석

1. 사용자 요청에서 도메인과 목표 산출물을 식별한다.
2. 작업 유형을 나눈다.
   생성, 분석, 구현, 검수, 포맷팅, 배포, 운영 등
3. 코드베이스와 파일 구조를 읽고 기술 스택과 주요 경계면을 찾는다.
4. 기존 자산과 중복되는 역할이나 스킬이 있는지 확인한다.
5. 사용자 숙련도를 감지해 이후 문서와 커뮤니케이션 밀도를 조절한다.

## Phase 2: 오케스트레이션 설계

현재 Codex 기준 기본값은 "문서화된 워크플로우 설계"다. 실제 서브에이전트
실행은 사용자가 명시적으로 요청했을 때만 포함한다.

### 실행 모드

- 문서 설계 모드
  역할 문서, 스킬, 파일 계약, 체크리스트만 설계한다.
- 위임 실행 모드
  사용자가 병렬화, 서브에이전트, delegation을 직접 요청했을 때만
  `spawn_agent` 기반 실행 계획을 포함한다.
- 생성-검수 루프
  초안 생성 후 검수와 재지시가 반복되는 워크플로우를 설계한다.

### 패턴 선택

패턴별 기준은 `references/agent-design-patterns.md`를 따른다.

- 파이프라인: 순차 의존 작업
- 팬아웃/팬인: 독립 작업 병렬 분석 후 통합
- 전문가 풀: 입력에 따라 필요한 전문가만 선택
- 생성-검증: 초안과 검수 루프
- 감독자: 메인 오케스트레이터가 동적으로 배치 재분배
- 계층적 위임: 깊게 중첩하지 말고 2단계 이하로 평탄화

## Phase 3: 역할 문서 생성

역할이 분리될 가치가 있으면 `프로젝트/.codex/agents/{name}.md`를 만든다.
이 파일은 자동 실행 타입이 아니라 재사용 가능한 역할 문서다.

현재 Codex에서 역할 선택은 다음을 기준으로 한다.

- `default`: 범용 분석, 조사, 문서화
- `explorer`: 읽기 중심 탐색과 코드베이스 분석
- `worker`: 파일 수정, 구현, 테스트 수정

역할 문서에는 최소한 다음이 들어가야 한다.

- 핵심 역할
- 작업 원칙
- 입력/출력 프로토콜
- 에러 핸들링
- 협업 규칙

협업 규칙은 "누구에게 직접 메시지를 보낸다"가 아니라 "메인 오케스트레이터를
통해 어떤 파일을 읽고 어떤 파일을 쓴다"로 정의한다.

## Phase 4: 스킬 생성

각 역할이나 오케스트레이터가 사용할 스킬을 `SKILL.md` 형태로 만든다.

### 스킬 구조

```text
skill-name/
├── SKILL.md
├── references/
├── scripts/
└── assets/
```

### 작성 원칙

- description은 적극적으로 쓴다.
- 스킬이 하는 일과 트리거 상황을 둘 다 적는다.
- 본문은 lean하게 유지하고 세부 내용은 `references/`로 분리한다.
- 반복 코드가 드러나면 `scripts/`로 번들링한다.
- 특정 예시 하나에 과적합하지 말고 원리 수준으로 일반화한다.

상세 작성 규칙은 `references/skill-writing-guide.md`를 읽는다.

## Phase 5: 플러그인 패키징

스킬을 배포 가능한 형태로 만들려면 Codex 플러그인 구조로 묶는다.

필수 항목:

- `.codex-plugin/plugin.json`
- `skills/`
- 필요 시 `.agents/plugins/marketplace.json`

repo-local 플러그인이라면 보통 다음 구조를 쓴다.

```text
project-root/
├── .agents/plugins/marketplace.json
└── plugins/
    └── your-plugin/
        ├── .codex-plugin/plugin.json
        └── skills/
```

## Phase 6: 검증

다음을 확인한다.

- 역할 문서 경로가 일관적인가
- 스킬 frontmatter가 있는가
- description이 실제 요청을 충분히 트리거할 만큼 구체적인가
- 문서에서 지원하지 않는 Codex 런타임 기능을 가정하지 않았는가
- 위임 실행 모드가 있다면 "명시적 요청이 있을 때만"이라는 조건이 반영됐는가

테스트 방법론은 `references/skill-testing-guide.md`를 읽는다.

## Phase 7: 운영 및 확장

기존 하네스를 다룰 때는 다음 순서로 진행한다.

1. 현재 역할 문서와 스킬을 재감사한다.
2. 새 요청이 기존 구조에 어떤 영향을 주는지 표기한다.
3. 영향받는 역할 문서와 스킬만 수정한다.
4. 패키징과 marketplace 엔트리가 여전히 맞는지 검증한다.
5. 변경 이력을 간단한 운영 문서나 README에 남긴다.

## 산출물 체크리스트

- [ ] `프로젝트/.codex/agents/` 또는 동등한 역할 문서 디렉토리
- [ ] `프로젝트/.codex/skills/` 또는 플러그인 내부 `skills/`
- [ ] 오케스트레이터 스킬 또는 실행 설계 문서
- [ ] 파일 기반 데이터 전달 규약
- [ ] 검증 체크리스트
- [ ] 플러그인으로 배포할 경우 `.codex-plugin/plugin.json`
- [ ] repo-local 배포일 경우 `.agents/plugins/marketplace.json`

## 참고 문서

- 패턴 선택: `references/agent-design-patterns.md`
- 오케스트레이터 템플릿: `references/orchestrator-template.md`
- 예시 워크플로우: `references/team-examples.md`
- 스킬 작성: `references/skill-writing-guide.md`
- 스킬 검증: `references/skill-testing-guide.md`
- QA 역할 설계: `references/qa-agent-guide.md`
