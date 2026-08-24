# Git & Pull Request Workflow

## 1. Purpose

This document defines the Git workflow for the Recipe Archive project.

The goal is to keep development history understandable, make AI-assisted changes auditable, and ensure that implementation is verified before it reaches `main`.

## 2. Core Principles

- `main` should remain buildable and reviewable.
- Do not develop features directly on `main`.
- One branch should represent one bounded feature, fix, or documentation change.
- Prefer small, reviewable pull requests over large mixed changes.
- A coding agent must not commit, push, create a PR, or merge unless explicitly instructed.
- Never rewrite shared history or force-push unless explicitly requested for a known reason.
- Do not include unrelated formatting or cleanup in a feature PR.

## 3. Branch Naming

Use lowercase branch names with a short kebab-case description.

```text
feat/<topic>
fix/<topic>
refactor/<topic>
test/<topic>
docs/<topic>
chore/<topic>
```

Examples:

```text
feat/ingredient-input
feat/multiline-ingredient-paste
fix/ingredient-parser-fraction
refactor/recipe-editor
test/ingredient-parser-edge-cases
docs/update-spec
```

Keep the branch name about the problem being solved, not the tool used to solve it.

Avoid names such as:

```text
codex-work
ai-update
changes
fix-stuff
new-feature
```

## 4. Commit Convention

Use a Conventional Commit-inspired format:

```text
<type>(<scope>): <summary>
```

Allowed common types:

- `feat` — user-visible feature
- `fix` — bug fix
- `refactor` — code restructuring without intended behavior change
- `test` — tests only
- `docs` — documentation only
- `chore` — maintenance/configuration
- `build` — build system/project configuration

The scope is optional but recommended when it makes the change clearer.

Examples:

```text
feat(recipe): 여러 줄 재료 입력 추가
feat(parser): 재료 수량과 단위 구조화
fix(parser): 반 개 표현 파싱 오류 수정
test(parser): 범위 수량 엣지 케이스 추가
docs(spec): 재료 입력 요구사항 보완
```

### Commit Rules

- Keep one commit focused on one coherent purpose.
- Write the summary so the change is understandable without reading the diff.
- Prefer describing the result, not the action taken.
- Do not use meaningless messages such as `update`, `fix`, `changes`, `work`, or `wip` for finalized commits.
- Do not mention Codex, ChatGPT, or another AI tool in the commit title unless the change itself is specifically about AI tooling.
- Never commit secrets, API keys, provisioning data, local user settings, DerivedData, or unrelated generated files.
- Inspect `git diff` and staged files before committing.

## 5. Commit Size

A commit should be independently understandable.

Good separation example:

```text
feat(model): Ingredient 구조화 필드 추가
feat(parser): 재료 자연어 파서 구현
test(parser): 재료 파서 테스트 추가
feat(recipe): 여러 줄 붙여넣기 UI 연결
```

Do not split changes mechanically when they cannot work or be understood separately. The goal is coherent history, not the maximum number of commits.

## 6. Pull Request Rules

Create a PR only after the requested implementation scope is complete enough to review.

Each PR should:

- solve one clearly defined problem
- reference the relevant `SPEC.md` requirement or development phase when applicable
- explain why the change is needed
- summarize what changed
- state how the implementation was verified
- disclose known limitations or deferred work
- avoid unrelated code changes

### PR Title

Use the same style as commit messages when practical.

```text
feat(recipe): 여러 줄 재료 입력 지원
fix(parser): 분수 수량 파싱 오류 수정
```

## 7. Pull Request Body

Use this structure:

```markdown
## Why

이 변경이 필요한 이유와 해결하려는 문제를 설명한다.

## What

- 주요 변경 사항
- 사용자 동작 변화
- 필요한 모델/서비스 변경

## Verification

- [ ] Build 성공
- [ ] 관련 테스트 통과
- [ ] 주요 사용자 흐름 수동 확인
- [ ] SPEC.md와 구현 일치 확인

## AI-assisted Development

AI를 사용했다면 코드 생성 여부를 나열하기보다 검증 과정에서 의미 있었던 내용을 짧게 기록한다.

예:
- Codex로 초기 parser 구현 후 직접 diff 검토
- `반 개`, `2~3개`, `약간` 케이스가 누락되어 테스트와 구현 보완
- AI가 제안한 선형 인분 변환은 제품 요구사항과 맞지 않아 제외

의미 있는 내용이 없다면 이 섹션은 생략할 수 있다.

## Notes

- 알려진 제한사항
- 후속 작업
- 리뷰 시 특별히 확인할 부분
```

The PR body should describe evidence, not claim that code is correct merely because an AI generated or reviewed it.

## 8. Verification Before PR

Before creating or updating a PR:

1. Inspect the final diff.
2. Confirm no unrelated files were changed.
3. Build the relevant target.
4. Run relevant automated tests.
5. Check behavior against `SPEC.md`.
6. Review important edge cases.
7. Record unresolved warnings or limitations in the PR.

If verification cannot be performed, state exactly what was not verified and why.

## 9. Review Policy

Human judgment remains final even when AI review tools are used.

For AI-generated or AI-reviewed feedback:

- Do not automatically apply every suggestion.
- Check whether the suggestion matches `SPEC.md`.
- Check whether it introduces unnecessary abstraction or scope expansion.
- Reproduce suspected bugs when practical.
- Add regression tests for confirmed behavioral bugs.
- Record meaningful rejected/corrected AI suggestions in `AI_WORKFLOW.md` or `DECISIONS.md` when they provide useful learning evidence.

## 10. Merge Rules

A PR is ready to merge when:

- the requested scope is complete
- required build/tests pass
- blocking review comments are resolved or intentionally rejected with a reason
- documentation is consistent with behavior when the change affects established requirements
- no unrelated or accidental files are included

Merge only when explicitly requested by the user.

Prefer a clean project history. The final merge strategy can be chosen based on the repository state, but avoid unnecessary history rewriting.

## 11. AI Agent Safety

The coding agent must treat Git operations as separate, explicit actions.

An instruction such as:

> Implement Phase 1.

does **not** imply permission to:

- create a branch
- commit
- push
- open a PR
- merge

Those operations require explicit instructions.

Before a requested commit or PR, the agent should summarize:

- changed files
- build/test result
- unresolved issues

This keeps the developer in control of repository history while still allowing AI to automate repetitive Git work when deliberately requested.
