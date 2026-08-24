# Recipe Archive Specification

## 1. Product Overview

Recipe Archive is an iPhone app for preserving recipes discovered on external platforms such as YouTube, blogs, and the web as a personal, durable recipe archive.

The core idea is simple:

> Save the recipe itself, not just the link.

A source URL may disappear, become private, or be deleted. A saved recipe must remain usable even if the original source is no longer accessible.

## 2. Problem

Useful recipes are often stored only as bookmarks or links to external content.

This creates several problems:

- YouTube videos may be deleted or made private.
- Blog posts may disappear or be edited.
- Saved links do not preserve ingredients, steps, personal notes, or modifications.
- A recipe that has been repeatedly adjusted to personal taste can be lost together with the original source.

Recipe Archive solves this by turning external recipes into user-owned structured recipe records.

## 3. Product Principles

### 3.1 Archive-first

The saved recipe must remain usable independently of the original source.

### 3.2 Local-first

Recipe data should be stored locally first. Cloud sync may be added later, but the product must not depend on a custom backend for the MVP.

### 3.3 Fast input, structured storage

Users should be able to enter ingredients in natural language, while the app attempts to convert them into structured ingredient data.

### 3.4 Never lose the original input

Automatic parsing must never destroy the user's original text. Raw input should be preserved so that parsing mistakes can be corrected later.

### 3.5 Personal recipe evolution

A saved recipe is not a frozen copy. Users should be able to modify it, add personal notes, and gradually turn it into their own version.

### 3.6 Exportable ownership

Users should be able to export recipes as an image or PDF so that recipes remain accessible outside the app.

## 4. MVP Scope

The MVP should focus on creating and maintaining a personal recipe archive.

### Included

- Create, read, update, and delete recipes
- Recipe title
- Optional representative image
- Serving information as descriptive metadata
- Cooking time
- Ingredient groups
- Natural-language ingredient entry
- Multi-line ingredient paste
- Ingredient parsing and review
- Cooking steps
- Personal notes
- Original source URL and source memo
- Search
- Favorites
- Basic categories or collections
- Export recipe as image
- Export recipe as PDF
- Local persistence with SwiftData

### Not required for MVP

- Sign in with Apple
- Custom user accounts
- Custom backend server
- Server database
- Social features
- Public recipe sharing
- Following other users
- Automatic YouTube video download
- Automatic copying of copyrighted source content
- AI-based full recipe extraction from a URL
- OCR-based recipe extraction
- Automatic serving conversion
- Shopping list automation
- Android or web support

## 5. Core User Flow

### 5.1 Create a recipe

1. User taps Add Recipe.
2. User enters a recipe manually or pastes ingredient text.
3. User enters recipe metadata.
4. User enters or pastes ingredients.
5. App parses ingredients into structured fields where possible.
6. User reviews and corrects parsed results.
7. User adds cooking steps.
8. User optionally adds a source URL and personal notes.
9. User saves the recipe.

### 5.2 View a recipe

1. User opens the recipe library.
2. User searches or browses recipes.
3. User selects a recipe.
4. Recipe detail shows ingredients, steps, notes, source, and metadata.

### 5.3 Edit a recipe

1. User opens a saved recipe.
2. User edits ingredients, steps, notes, or metadata.
3. Updated data replaces the current recipe while preserving the recipe identity.

### 5.4 Export a recipe

1. User opens a recipe.
2. User selects Share / Export.
3. User chooses Image or PDF.
4. App generates a self-contained recipe artifact.
5. User saves or shares the generated file through the iOS share sheet.

## 6. Functional Requirements

## 6.1 Recipe

A recipe should support:

- title
- optional short description
- optional representative image
- serving text
- preparation or cooking time
- ingredient groups
- ordered cooking steps
- personal notes
- optional source information
- favorite state
- created date
- updated date

## 6.2 Ingredient Input

Ingredient input should prioritize speed.

Users may enter ingredients one line at a time or paste multiple lines at once.

Example input:

```text
돼지고기 300g
양파 반 개
대파 1대
진간장 2큰술
설탕 1큰술
후추 약간
```

The app should attempt to parse each line into structured fields.

Example:

```text
rawText: "돼지고기 300g"
name: "돼지고기"
amountText: "300"
amountValue: 300
unit: "g"
parseStatus: parsed
```

Another example:

```text
rawText: "후추 약간"
name: "후추"
amountText: "약간"
amountValue: nil
unit: nil
parseStatus: parsed
```

If parsing is uncertain, the app should preserve the raw text and mark the item for review instead of guessing aggressively.

Example:

```text
rawText: "대파 흰 부분 손가락 두 마디 정도"
parseStatus: needsReview
```

## 6.3 Multi-line Ingredient Paste

The user should be able to paste a block of ingredient text copied from YouTube descriptions, blogs, or other websites.

Each non-empty line should be treated as one ingredient candidate.

After parsing, the app should show a review screen or review state where users can correct:

- ingredient name
- amount
- unit
- parsing errors

The original line must remain available until the user explicitly confirms or edits it.

## 6.4 Ingredient Groups

Recipes should support multiple ingredient groups.

Example:

```text
기본 재료
- 돼지고기 300g
- 양파 반 개

양념
- 고추장 2큰술
- 간장 1큰술
- 설탕 1큰술
```

Users should be able to add, rename, reorder, and remove groups.

## 6.5 Cooking Steps

Cooking instructions should be stored as ordered steps rather than one long text block.

Each step should support:

- order
- instruction text
- optional image in a later phase

This structure should allow a future Cooking Mode without redesigning the data model.

## 6.6 Personal Notes

Personal notes must be stored separately from the canonical cooking steps.

Example:

```text
원래 레시피: 중불에서 5분 볶기
My Note: 우리 집 인덕션에서는 4단계로 4분 정도가 적당함
```

Personal notes are a core feature because recipes should evolve into the user's own version over time.

## 6.7 Source

A recipe may have an optional source.

Source fields may include:

- type
- URL
- source memo or title

The source must be treated as metadata only.

If the URL becomes inaccessible, the saved recipe must remain fully usable.

The MVP must not download or preserve the original YouTube video or copyrighted webpage content.

## 6.8 Search and Favorites

Users should be able to search recipes by at least recipe title.

Favorites should provide a simple way to access frequently used recipes.

Tag or ingredient-based search may be added later.

## 6.9 Categories / Collections

The MVP may provide lightweight categorization.

Examples:

- 한식
- 양식
- 일식
- 중식
- 디저트

Collections may later be expanded into user-defined groups such as:

- 자취 요리
- 엄마 레시피
- 손님용
- 자주 만드는 요리

Avoid over-designing taxonomy in the first implementation.

## 6.10 Export

A recipe should be exportable as:

- image recipe card
- PDF recipe sheet

Exported content should be useful without opening Recipe Archive.

At minimum, exports should contain:

- recipe title
- serving information
- cooking time when available
- ingredients
- cooking steps
- personal notes when included by the user

The source URL may be included as optional metadata.

## 7. Data Rules

### 7.1 Ingredient raw input must be preserved

Do not discard the raw ingredient text after parsing.

### 7.2 Structured parsing is assistive, not authoritative

The parser may suggest structured values, but users must be able to override all parsed fields.

### 7.3 Serving information is metadata in the MVP

The MVP may store values such as "2인분" but must not automatically multiply ingredient amounts when users change serving size.

Cooking quantities do not always scale linearly.

### 7.4 Source independence

Deleting or losing access to a source URL must never delete or invalidate the local recipe.

### 7.5 Data preservation over automation

When a parser cannot confidently understand an ingredient, preserve the original expression instead of forcing a numeric representation.

Examples:

- 약간
- 취향껏
- 적당량
- 반 개
- 2~3개

## 8. UX Rules

- Recipe creation must not feel like filling out a database form.
- Prefer natural text entry over large predefined ingredient dictionaries.
- Do not require users to select ingredient names from a fixed list.
- Parsing should happen after or during input without interrupting typing.
- Multi-line paste should be a first-class input method.
- Review parsed results before final storage when ambiguity exists.
- Optional fields should remain optional.
- The app should work without account registration.

## 9. Technical Direction

Initial implementation direction:

- iOS / iPhone
- SwiftUI-first
- SwiftData local persistence
- Native Apple frameworks preferred
- No required third-party dependencies for MVP
- No custom backend for MVP
- CloudKit / iCloud sync considered after local MVP stability

## 10. Development Phases

### Phase 1 — Core Archive

- SwiftData models
- Recipe CRUD
- Ingredient groups
- Natural-language ingredient entry
- Multi-line ingredient paste
- Basic ingredient parser
- Parse review/edit
- Cooking steps
- Personal notes
- Source metadata

### Phase 2 — Library Experience

- Search
- Favorites
- Categories / basic collections
- Improved recipe detail UI

### Phase 3 — Export

- Recipe image export
- PDF export
- iOS share sheet

### Phase 4 — Data Durability

- iCloud / CloudKit sync
- Export / import backup strategy

### Phase 5 — Smart Input

Only after the core archive is stable:

- Share Sheet URL intake
- URL metadata extraction
- AI-assisted recipe draft generation
- Image / OCR assisted extraction
- Improved natural-language ingredient parsing

## 11. Out of Scope Principles

Do not add a feature only because it is technically interesting.

A feature should support at least one of these goals:

1. Make recipes easier to archive.
2. Make saved recipes easier to reuse.
3. Make recipe data more durable.
4. Reduce repetitive manual input.

When uncertain, prefer a smaller local-first implementation.
