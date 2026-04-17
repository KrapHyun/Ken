# Current Codex Workflow Examples

아래 예시는 현재 Codex 제약을 반영한 하네스 예시다. 모두 메인
오케스트레이터 중심이며, 병렬 위임은 명시적 요청이 있을 때만 활성화한다.

## 예시 1: 딥 리서치 하네스

패턴: 팬아웃/팬인

권장 역할:

- `official-researcher` / `default`
- `media-researcher` / `default`
- `community-researcher` / `default`
- `synthesizer` / `default`

데이터 흐름:

1. 요청을 `_workspace/00_input/request.md`에 저장한다.
2. 위임이 허용되면 조사자들을 병렬로 실행한다.
3. 각 조사자는 자기 보고서를 파일로 남긴다.
4. 메인이 결과를 읽고 종합 보고서를 작성한다.

## 예시 2: 코드 리뷰 하네스

패턴: 팬아웃/팬인

권장 역할:

- `security-reviewer` / `explorer`
- `performance-reviewer` / `explorer`
- `test-reviewer` / `explorer`
- `final-reviewer` / `default`

핵심 규칙:

- 리포트는 `_workspace/10_security_review.md` 같은 명시적 경로에 남긴다.
- 리뷰어끼리 직접 조율하지 않는다.
- 최종 판단과 중복 정리는 메인이 수행한다.

## 예시 3: 기능 구현 + QA 하네스

패턴: 생성-검증

권장 역할:

- `builder` / `worker`
- `qa-inspector` / `worker`

흐름:

1. builder가 구현 또는 패치 계획을 만든다.
2. QA가 경계면 교차 비교 중심으로 검증한다.
3. FIX면 builder에 재지시한다.
4. PASS면 최종 요약을 작성한다.

## 예시 4: 대규모 마이그레이션 하네스

패턴: 감독자

권장 역할:

- `migration-supervisor` / `default`
- `migrator-a` / `worker`
- `migrator-b` / `worker`
- `migrator-c` / `worker`

흐름:

1. 메인이 배치 계획 파일을 만든다.
2. 위임이 허용되면 워커들을 배치별로 나눠 실행한다.
3. 완료된 워커에게만 새 배치를 재할당한다.
4. 모든 배치가 끝나면 통합 테스트와 요약을 수행한다.

## 예시 5: 스킬 제작 하네스

패턴: 파이프라인

권장 역할:

- `domain-analyst` / `default`
- `skill-writer` / `worker`
- `skill-tester` / `default`
- `packager` / `worker`

흐름:

1. analyst가 트리거 문구와 사용 사례를 정리한다.
2. writer가 `SKILL.md`와 references 초안을 만든다.
3. tester가 trigger/quality checklist로 검증한다.
4. packager가 plugin manifest와 marketplace 엔트리를 정리한다.
