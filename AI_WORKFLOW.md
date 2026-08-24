# AI Development Workflow

## 1. Purpose

This document records how generative AI is used during the Recipe Archive project.

The goal is not to maximize generated code. The goal is to use AI to reduce repetitive work while keeping product decisions, verification, and final responsibility with the developer.

## 2. Tool Roles

### ChatGPT

Primary role:

- product discovery
- requirement refinement
- specification design
- architecture discussion
- edge-case exploration
- review of AI-generated implementation plans

### Codex / Coding Agent

Primary role:

- repository analysis
- implementation
- refactoring
- test creation
- build and test execution
- implementation verification against the specification

### Code Review AI

When used, the role is:

- identify potential bugs
- identify maintainability issues
- identify missing edge cases
- provide a second review perspective

AI review comments are suggestions, not automatically accepted truth.

## 3. Core Workflow

```text
Product idea
    ↓
Discuss requirements and edge cases
    ↓
Update SPEC.md
    ↓
Define agent constraints in AGENTS.md
    ↓
Ask coding agent to inspect repository
    ↓
Implement one bounded phase
    ↓
Build / test
    ↓
Review generated changes
    ↓
Accept, reject, or revise AI suggestions
    ↓
Record meaningful decisions or mistakes
```

## 4. Context Management Strategy

The project uses persistent repository documents to reduce repeated prompting and context loss.

### SPEC.md

Defines what the product should do.

### AGENTS.md

Defines how the coding agent should work.

### DECISIONS.md

Records why meaningful product or engineering choices were made.

### GIT_WORKFLOW.md

Defines branch, commit, pull request, verification, review, and merge rules so AI-assisted repository changes remain auditable and developer-controlled.

The intended pattern is:

> Put stable context in the repository instead of repeatedly explaining it in every prompt.

## 5. Prompt Strategy

Prompts to a coding agent should usually contain:

1. the specific phase or goal
2. relevant specification section
3. files or areas to inspect first
4. explicit scope boundaries
5. verification requirements
6. repository safety rules

Example structure:

```text
Implement Phase 1 ingredient input from SPEC.md.

Before modifying code:
- inspect the current project structure
- read SPEC.md and AGENTS.md
- identify the existing data model and relevant Views

Requirements:
- support single-line natural-language ingredient input
- support multi-line paste
- preserve raw input
- parse common amount/unit patterns
- allow review and manual correction

Do not:
- add AI APIs
- add CloudKit
- add authentication
- implement serving conversion

After implementation:
- build
- run relevant tests
- summarize changed files and remaining limitations
```

## 6. Verification Strategy

AI-generated code is not considered correct simply because it compiles.

Verification should include:

- build success
- relevant automated tests
- manual inspection of changed code
- comparison with `SPEC.md`
- edge-case review
- correction of AI-generated assumptions

## 7. Human Judgment Areas

The developer should retain final judgment for:

- product scope
- UX tradeoffs
- data ownership
- privacy
- architecture complexity
- whether AI-generated behavior matches real user needs
- whether a recommendation should be accepted

## 8. AI Mistakes and Corrections Log

Record cases where AI output was incomplete, incorrect, over-engineered, or inconsistent with real usage.

### Example — Serving conversion

Initial idea:

- multiply ingredient amounts linearly when serving count changes

Problem found:

- cooking quantities do not always scale linearly
- seasoning, water, heat, pan size, and cooking time can behave differently

Decision:

- do not implement automatic serving multiplication in the MVP
- store serving information as metadata first
- revisit a future serving guide only after real usage validates the need

### Example — Ingredient structure

Initial tension:

- free-text input is fast
- fully structured input is better for future features

Decision:

- accept natural-language input
- parse into structured fields when possible
- always preserve raw text
- let the user review and correct parser output

This balances UX and data quality without forcing database-style input.

## 9. AI Efficiency Goals

Use AI to reduce:

- repetitive boilerplate
- initial repository exploration time
- test scaffolding effort
- documentation drift
- repeated context explanation
- time spent finding obvious implementation defects

Do not use AI to avoid understanding the codebase.

## 10. Portfolio / Interview Evidence

Useful evidence to preserve during development:

- before/after examples of requirements refined through AI discussion
- examples of AI suggestions that were rejected or corrected
- parser edge cases discovered through AI-assisted review
- test cases added after AI review
- examples where repository-level context reduced prompt repetition
- measurable reductions in implementation or review effort when available

The strongest AI-utilization story should show a repeatable process rather than simply stating that AI generated code.
