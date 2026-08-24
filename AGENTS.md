# Agent Instructions

## 1. Source of Truth

`SPEC.md` is the product source of truth.

Before implementing a feature:

1. Read the relevant section of `SPEC.md`.
2. Inspect the existing repository and implementation.
3. Confirm that the requested work is consistent with both.

Do not silently invent product behavior that is not defined in the specification.

## 2. Product Principles

- The product is a personal recipe archive, not a social recipe platform.
- A saved recipe must remain useful even if its original URL disappears.
- Prefer local-first architecture.
- Do not require user authentication for the MVP.
- Preserve user-entered data over aggressive automation.
- Natural-language ingredient input is preferred over rigid predefined selections.
- Parsing should assist the user, not override the user.
- Multi-line ingredient paste is a first-class input path.
- Serving conversion must not assume that recipe quantities scale linearly.

## 3. Development Direction

- Prefer SwiftUI.
- Prefer SwiftData for local persistence.
- Prefer native Apple frameworks over third-party libraries when practical.
- Keep business rules outside View code when possible.
- Keep models and parsing logic testable.
- Avoid premature architecture that is not justified by current requirements.
- Avoid adding backend infrastructure unless the specification explicitly requires it.

## 4. Ingredient Parsing Rules

Ingredient parsing must follow these principles:

- Always preserve `rawText`.
- Parse common amounts and units when confidence is reasonable.
- Support non-numeric expressions such as `약간`, `적당량`, and `취향껏`.
- Support ranges such as `2~3개` without forcing them into a single value.
- Support common fractions such as `1/2`, `반`, and similar expressions when practical.
- When uncertain, return a review-required state instead of fabricating a structured value.
- Users must be able to manually correct parsed results.

## 5. Code Quality

- Keep domain logic separate from presentation logic.
- Avoid duplicated parsing or recipe rules across Views.
- Use clear naming that reflects recipe-domain concepts.
- Do not add abstractions solely for theoretical flexibility.
- Add tests for non-trivial domain rules and parsers.
- Include edge cases that previously caused bugs.

## 6. Verification

Before reporting a development task as complete:

1. Build the relevant target.
2. Run relevant tests.
3. Review modified files.
4. Confirm the implementation matches `SPEC.md`.
5. Report unresolved warnings or limitations.

Do not claim a feature works without verifying it when verification is possible.

## 7. Git & Repository Rules

`GIT_WORKFLOW.md` defines the repository workflow for branches, commits, and pull requests.

Unless explicitly requested:

- Do not create or switch branches.
- Do not commit.
- Do not push.
- Do not create, update, merge, or close pull requests.
- Do not modify unrelated files.
- Do not rewrite project history.
- Do not force-push.

When Git work is explicitly requested:

- Follow the branch and commit conventions in `GIT_WORKFLOW.md`.
- Keep each commit focused on one coherent change.
- Inspect the diff before committing.
- Run the relevant build/tests before creating or updating a PR.
- Never merge a PR unless the user explicitly asks for the merge.

## 8. Scope Control

When implementing a requested phase:

- Implement only the requested scope plus necessary supporting code.
- Do not opportunistically add future-phase features.
- Do not add Sign in with Apple, a custom backend, AI extraction, CloudKit sync, or social features unless explicitly requested.
- If implementation reveals a product ambiguity, describe the ambiguity instead of silently choosing a major new behavior.

## 9. Documentation

If an implementation materially changes established behavior:

- Update `SPEC.md` only when explicitly requested or when documentation update is part of the task.
- Record meaningful architectural or product decisions in `DECISIONS.md` when requested.
- Keep code and documentation consistent.
