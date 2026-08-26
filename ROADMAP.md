# RecipeUm Development Roadmap

This document records the current intended development order.

Unlike `SPEC.md`, this file is allowed to change as implementation reveals new constraints, risks, or better sequencing.

## Current Direction

Build RecipeUm as a local-first iPhone recipe archive before adding sync, AI extraction, or platform expansion.

The immediate goal is to create a reliable core archive that preserves user-entered recipe data even when the original source URL disappears.

## Planning Levels

Use three levels when planning implementation work.

- Phase: product-level milestone from `SPEC.md`
- PR: reviewable delivery unit sized for CodeRabbit and human review
- Task: concrete implementation step inside a PR

PRs should be large enough to produce meaningful review feedback, but small enough that model, parser, persistence, and UI risks do not become indistinguishable.

## Development Order

### 1. Repository Hygiene

Status: complete for initial setup.

Set up the project foundation before application code grows.

- `.gitignore`
- `README.md`
- license decision: no open-source license yet
- root folder and Xcode project layout: generated app project in top-level `RecipeUm/`
- initial repository conventions

### 2. Xcode Project Setup

Status: complete for initial setup.

Create the iOS app project.

- SwiftUI app target
- SwiftData-ready configuration
- iPhone-first layout direction
- app display name decision: `RecipeUm`
- deployment target: iOS 17.0
- test target setup

### 3. Phase 1 Core Archive

Status: complete.

Implemented the smallest useful local recipe archive.

#### PR 1 — Core Models And Ingredient Parser

Status: merged.

- SwiftData recipe domain models
- ingredient group, ingredient, cooking step, and source metadata models
- basic ingredient parser
- raw ingredient text preservation
- parser tests for common Korean recipe input

#### PR 2 — Ingredient Input And Review Flow

Status: merged.

- single-line natural-language ingredient input
- multi-line ingredient paste
- parsed result display
- review/edit state for uncertain parsing
- manual correction of parsed fields

#### PR 3 — Recipe CRUD And Detail Fields

Status: merged.

- recipe list
- create, read, update, and delete recipes
- cooking steps
- personal notes
- source metadata
- save and reopen flow

### 4. Phase 2 Library Experience

Build the first useful browsing and retrieval layer on top of the local archive.

UX refinement remains important, but the next priority is to add enough library
functionality to reveal the real interaction patterns before spending a separate
PR on polish.

#### PR 1 — Search And Basic Library Filters

Status: complete.

- search recipes by title
- search recipes by ingredient raw text or parsed ingredient name
- empty search state
- simple category filter using existing category metadata
- tests for search/filter helpers when domain logic is extracted

#### PR 2 — Favorites

Status: complete.

- mark and unmark recipes as favorites
- show favorite state in list and detail
- filter or browse favorite recipes
- persistence tests for favorite state

#### PR 3 — Category And Collection Basics

Status: next.

- revisit MVP category options with real usage feedback
- category browsing entry point
- basic collection direction if categories alone are not enough
- keep category behavior local-first and lightweight

### 5. Parser Tests And Edge Cases

Build confidence in the ingredient parser with focused tests.

Important early examples:

- `돼지고기 300g`
- `양파 반 개`
- `계란 2~3개`
- `진간장 2큰술`
- `후추 약간`
- `소금 취향껏`
- `대파 흰 부분 손가락 두 마디 정도`

### 6. UI Refinement

Polish the archive after Phase 2 exposes the real list, search, favorites, and
category workflows. This section should not duplicate feature scope. Move items
here only when they are refinements that improve the implemented experience
without changing source-of-truth behavior in `SPEC.md`.

- basic empty states
- list sorting and grouping refinements
- detail layout polish
- form validation copy
- small navigation and editing ergonomics

## Deferred Until The Core Is Stable

These features should not shape the first implementation.

- Sign in with Apple
- custom backend
- CloudKit sync
- social features
- public sharing
- AI full recipe extraction from URL
- OCR extraction
- automatic serving conversion
- shopping list automation

## Roadmap Rules

- Keep this file practical and current.
- Move items when implementation evidence suggests a better order.
- Do not treat roadmap order as product truth; `SPEC.md` remains the source of truth for behavior.
- When roadmap changes reflect a meaningful product or architecture decision, record the reason in `DECISIONS.md`.
