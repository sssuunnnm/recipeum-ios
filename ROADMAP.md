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

Status: complete.

Build the first useful browsing and retrieval layer on top of the local archive.

UX refinement remains important, but the next priority is to add enough library
functionality to reveal the real interaction patterns before spending a separate
PR on polish.

#### PR 1 — Search And Basic Library Filters

Status: merged.

- search recipes by title
- search recipes by ingredient raw text or parsed ingredient name
- empty search state
- simple category filter using existing category metadata
- tests for search/filter helpers when domain logic is extracted

#### PR 2 — Favorites

Status: merged.

- mark and unmark recipes as favorites
- show favorite state in list and detail
- filter or browse favorite recipes
- persistence tests for favorite state

#### PR 3 — Category And Collection Basics

Status: merged.

- revisit MVP category options with real usage feedback
- category browsing entry point
- detail-level category editing
- defer separate collections until real usage shows that one category is not enough
- keep category behavior local-first and lightweight

### 5. Phase 3 Image Export

Status: next.

Build self-contained export so saved recipes remain useful outside RecipeUm.

Phase 3 should keep export local-first and avoid AI extraction, account systems,
CloudKit, or social sharing features. The target is not a public publishing
system; it is personal ownership through image artifacts and the native iOS
share sheet. PDF export is deferred until real usage shows a need for printable
or document-style artifacts.

#### PR 1 — Export Snapshot, Image Card, And Template Preview

Status: done.

Goal: define the export content once and generate useful image recipe cards.

Suggested tasks:

- create a recipe export snapshot type that copies display-ready recipe data
- include title, serving text, cooking time, category, ingredient groups, steps, notes, and source metadata when present
- preserve ingredient group order, ingredient order, and cooking step order
- add receipt, memo, and recipe card export template options
- build SwiftUI export card views that can render without depending on navigation state
- add a preview/selection screen before sharing
- add an export entry point from recipe detail
- generate an image export locally
- let users save the generated image to Photos or share it through the iOS share sheet
- add tests for snapshot ordering and optional field inclusion

Definition of done:

- a recipe can be exported as an image from the detail screen
- exported content is useful without opening RecipeUm
- missing optional fields do not leave awkward empty sections
- build and relevant tests pass

#### PR 2 — Export UX Polish

Status: in progress.

Goal: make image export choices clear without turning sharing into a social feature.

Suggested tasks:

- provide a lightweight export menu or confirmation flow
- make export actions directly discoverable from recipe detail
- let users choose whether personal notes and source metadata are included
- include personal notes by default when present
- exclude source metadata by default unless the user opts in
- improve export error handling and duplicate-action prevention
- update README and roadmap after PR 1 is merged

Definition of done:

- export actions are discoverable from recipe detail
- failures are shown to the user without dismissing context unexpectedly
- export remains local-only and account-free

#### Deferred — PDF Export

Status: deferred.

PDF export may be added later if users need printable or document-style recipe
artifacts. It should reuse the export snapshot introduced in Phase 3 instead of
reading SwiftData models directly from PDF code.

#### Next Session Starting Point

Start with Phase 3 PR 1 on a new feature branch.

Before coding:

- read `SPEC.md` sections 5.4, 6.10, 7.4, and 10
- inspect `RecipeDetailView`, recipe models, and sorted relationship helpers
- keep export rendering separate from SwiftData mutation code
- commit each task separately

### 6. Parser Tests And Edge Cases

Build confidence in the ingredient parser with focused tests.

Important early examples:

- `돼지고기 300g`
- `양파 반 개`
- `계란 2~3개`
- `진간장 2큰술`
- `후추 약간`
- `소금 취향껏`
- `대파 흰 부분 손가락 두 마디 정도`

### 7. UI Refinement

Polish the archive after Phase 2 exposes the real list, search, favorites, and
category workflows. This section should not duplicate feature scope. Move items
here only when they are refinements that improve the implemented experience
without changing source-of-truth behavior in `SPEC.md`.

- basic empty states
- list sorting and grouping refinements
- detail layout polish
- form validation copy
- small navigation and editing ergonomics
- app icon refinement after a final production icon is chosen

### 8. Future Smart Input

Add assistive input features only after the core archive, editing, search, and
export flows are stable.

Smart Input should reduce entry friction without turning RecipeUm into an AI
recipe generator. All generated or extracted content should remain editable
draft data until the user confirms it.

Candidate directions:

- Vision OCR for photos, recipe books, handwritten notes when readable, and
  screenshots
- Apple Foundation Models for turning pasted or OCR text into a structured
  recipe draft
- ingredient group suggestions such as basic ingredients, sauce, seasoning,
  garnish, and topping
- cooking step cleanup and line splitting
- one-line summary suggestions for the existing recipe summary field
- optional App Intents or Siri entry points after the main flows are stable
- Core Spotlight search improvements for local recipe discovery

Implementation principles:

- keep manual entry, editing, search, and export fully usable without AI or OCR
- preserve user-provided source text whenever practical
- show AI/OCR results as suggestions, not authoritative data
- require user review before saving generated or extracted recipe fields
- prefer Apple on-device technologies when they fit privacy and compatibility
  goals
- hide or disable unsupported assists on devices without the required system
  capabilities

## Deferred Until The Core Is Stable

These features should not shape the first implementation.

- Sign in with Apple
- custom backend
- CloudKit sync
- social features
- public sharing
- AI full recipe extraction from URL as an automatic save flow
- OCR extraction as an automatic save flow
- automatic serving conversion
- shopping list automation

## Roadmap Rules

- Keep this file practical and current.
- Move items when implementation evidence suggests a better order.
- Do not treat roadmap order as product truth; `SPEC.md` remains the source of truth for behavior.
- When roadmap changes reflect a meaningful product or architecture decision, record the reason in `DECISIONS.md`.
