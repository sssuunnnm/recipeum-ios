# RecipeUm Development Roadmap

This document records the current intended development order.

Unlike `SPEC.md`, this file is allowed to change as implementation reveals new constraints, risks, or better sequencing.

## Current Direction

Build RecipeUm as a local-first iPhone recipe archive before adding sync, AI extraction, or platform expansion.

The immediate goal is to create a reliable core archive that preserves user-entered recipe data even when the original source URL disappears.

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

Implement the smallest useful local recipe archive.

- SwiftData models
- recipe CRUD
- ingredient groups
- natural-language ingredient entry
- multi-line ingredient paste
- basic ingredient parser
- parse review/edit
- cooking steps
- personal notes
- source metadata

### 4. Parser Tests And Edge Cases

Build confidence in the ingredient parser with focused tests.

Important early examples:

- `돼지고기 300g`
- `양파 반 개`
- `계란 2~3개`
- `진간장 2큰술`
- `후추 약간`
- `소금 취향껏`
- `대파 흰 부분 손가락 두 마디 정도`

### 5. Basic CRUD UI

Connect the core archive behavior to a usable app interface.

- recipe list
- add recipe
- edit recipe
- recipe detail
- save and reopen flow
- basic empty states

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
