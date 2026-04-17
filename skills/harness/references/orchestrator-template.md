# 오케스트레이터 템플릿

현재 Codex에서는 오케스트레이터가 메인 에이전트 역할을 맡는다. 위임이
허용되지 않은 경우에는 실행 문서만 만들고, 위임이 허용된 경우에만 실제
`spawn_agent` 기반 흐름을 설계한다.

## 템플릿 A: 문서 설계 중심 오케스트레이터

```markdown
---
name: {domain}-orchestrator
description: "{도메인} 작업의 역할, 산출물, 검증 규칙을 설계하는 오케스트레이터."
---

# {Domain} Orchestrator

## 목표
- 무엇을 만들 것인지
- 어떤 파일 구조를 쓸 것인지

## 역할 구성
| 이름 | 권장 role | 책임 | 출력 |
|------|-----------|------|------|
| analyst | default | 요구사항 분석 | `_workspace/10_requirements.md` |
| builder | worker | 구현 계획 또는 구현 | `_workspace/20_build.md` |
| reviewer | default | 검토 기준과 QA | `_workspace/30_review.md` |

## 데이터 흐름
1. 입력을 `_workspace/00_input/`에 정리한다.
2. 각 역할이 읽는 파일과 쓰는 파일을 고정한다.
3. 최종 산출물 경로를 별도로 정한다.

## 검증
- 어떤 체크리스트를 통과해야 하는지
- 어떤 경우에 재작업이 필요한지
```

## 템플릿 B: 명시적 위임 허용 시 병렬 오케스트레이터

```markdown
---
name: {domain}-delegated-orchestrator
description: "{도메인} 작업을 병렬 위임까지 포함해 조율하는 오케스트레이터."
---

# {Domain} Delegated Orchestrator

## 실행 조건
- 사용자가 delegation, sub-agent, 병렬 실행을 명시적으로 요청했을 때만 사용

## 역할 구성
| 이름 | agent_type | 책임 | 출력 |
|------|------------|------|------|
| researcher | default | 조사 | `_workspace/10_research.md` |
| builder | worker | 구현 | `_workspace/20_build.md` |
| qa | worker | 검증 | `_workspace/30_qa.md` |

## 흐름
1. 입력을 `_workspace/00_input/request.md`에 저장한다.
2. 독립 작업만 병렬로 `spawn_agent` 한다.
3. 다음 단계가 막힐 때만 `wait_agent`를 사용한다.
4. 보강 요청이 필요하면 `send_input`으로 후속 지시를 보낸다.
5. 작업이 끝나면 `close_agent`로 정리한다.
```

## 템플릿 C: 생성-검수 루프

```markdown
## 역할
| 이름 | agent_type | 책임 |
|------|------------|------|
| producer | worker | 초안 생성 |
| reviewer | default | PASS/FIX/REDO 판정 |

## 루프
1. producer가 초안을 만든다.
2. reviewer가 판정 파일을 만든다.
3. PASS면 종료한다.
4. FIX/REDO면 producer에 수정 지시를 보낸다.
5. 재시도 상한은 2~3회로 둔다.
```

## 데이터 전달 규칙

권장 조합:

- 산출물: 파일 기반
- 재지시: 메인 오케스트레이터 메시지 기반
- 상태 추적: `_workspace/status/`

파일명 규칙:

- `{phase}_{role}_{artifact}.md`
- 예: `10_research_api_surface.md`

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 일부 역할 실패 | 부분 결과로 진행 가능한지 판단하고, 가능하면 누락을 명시한 채 계속 진행 |
| 결과가 불충분 | `send_input`으로 보강 요청 |
| 작업 정의가 틀림 | 기존 결과를 보존한 채 새 역할이나 새 단계로 재설계 |
| 타임아웃 | 확보한 결과만 사용하고 미완료 항목을 보고 |

## 체크리스트

- 위임이 허용된 상황인지 문서에 명시했는가
- 입력 파일과 출력 파일이 구체적인가
- `wait_agent`가 꼭 필요한 단계에만 들어갔는가
- `_workspace/` 경로가 일관적인가
