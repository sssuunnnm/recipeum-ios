# RecipeUm

좋아하는 레시피를 나만의 것으로.

RecipeUm is a local-first iPhone app for preserving recipes as a personal archive.
It saves the recipe itself, not just the original link.

## Overview

Recipes discovered on YouTube, blogs, or the web can disappear, become private,
or change over time. RecipeUm is built around the idea that a saved recipe should
remain useful even when its original source is no longer available.

The current app focuses on manual entry, natural-language ingredient input,
multi-line paste, local persistence, editable recipe detail fields, and basic
library browsing.

## Current Features

- Local recipe list
- Create, read, update, and delete recipes
- Natural-language ingredient input
- Multi-line ingredient paste
- Basic Korean ingredient parsing
- Ingredient raw text preservation
- Ingredient groups using `[group name]` headers
- Cooking steps
- Personal notes
- Source metadata
- Category selection
- Recipe search by title or ingredient
- Category browsing
- Favorites
- Local persistence with SwiftData
- Unit tests for parser, model ordering, save/reopen, draft conversion, library filtering, and favorites flows

## Tech Stack

| Area | Technology |
| --- | --- |
| Platform | iOS |
| UI | SwiftUI |
| Persistence | SwiftData |
| Language | Swift |
| Tests | Swift Testing, XCTest project setup |
| Minimum iOS | iOS 17.0 |

## Project Structure

```text
RecipeUm/
├── RecipeUm.xcodeproj
├── RecipeUm/
│   ├── Models/
│   ├── Parsing/
│   ├── IngredientInput/
│   ├── RecipeList/
│   ├── RecipeEditing/
│   ├── RecipeDetail/
│   ├── ContentView.swift
│   └── RecipeUmApp.swift
├── RecipeUmTests/
└── RecipeUmUITests/
```

Root documents:

- `SPEC.md` — product source of truth
- `ROADMAP.md` — current development order
- `DECISIONS.md` — product and engineering decisions
- `AGENTS.md` — coding agent instructions
- `GIT_WORKFLOW.md` — branch, commit, and PR rules
- `AI_WORKFLOW.md` — AI-assisted development workflow

## Development Status

Phase 1 Core Archive is complete:

- PR 1: core models and ingredient parser
- PR 2: ingredient input and review flow
- PR 3: recipe CRUD and detail fields

Phase 2 Library Experience is complete:

- PR 1: search and basic library filters
- PR 2: favorites
- PR 3: category browsing and lightweight collection decision

Next phase:

- Phase 3 Image Export: receipt/memo/card image templates, preview selection, Photos save, and native iOS share sheet

## Not In Scope Yet

- User accounts
- Custom backend
- CloudKit sync
- Social features
- Public recipe sharing
- AI-based full recipe extraction
- OCR extraction
- Automatic serving conversion
- PDF export
- Separate collection model

## License

No open-source license has been selected yet.

Until a license is added, this project is not licensed for external reuse.
