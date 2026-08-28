# Product & Engineering Decisions

This file records decisions that materially affect product behavior, architecture, or development workflow.

---

## D001 — Recipe data must not depend on the source URL

### Context

The project originated from the problem of useful recipe videos or pages disappearing from external platforms.

### Decision

The original URL is stored only as source metadata.

Ingredients, steps, notes, and other recipe data must remain usable even when the original URL is unavailable.

### Consequence

The app behaves as a recipe archive rather than a bookmark manager.

---

## D002 — No Sign in with Apple in the MVP

### Context

The initial product is a personal iPhone recipe archive.

There are no MVP requirements for social features, a web client, Android support, or shared accounts.

### Decision

Do not implement Sign in with Apple or a custom account system for the MVP.

### Consequence

The MVP can remain local-first and avoid unnecessary onboarding friction and backend infrastructure.

---

## D003 — SwiftData local-first

### Context

Recipe data should work without network access and should not depend on a custom service.

### Decision

Use SwiftData as the initial persistence layer.

CloudKit / iCloud sync may be considered after local behavior is stable.

### Consequence

The first implementation remains simpler and matches the personal archive use case.

---

## D004 — Natural-language ingredient entry with structured parsing

### Context

Rigid ingredient forms provide cleaner data but make recipe entry slow and unnatural.

Recipe text commonly contains expressions such as:

- 양파 반 개
- 계란 2~3개
- 후추 약간
- 소금 취향껏

### Decision

Users enter ingredients using natural language.

The app attempts to parse input into structured fields such as name, amount, and unit.

### Consequence

Input remains fast while future structured features remain possible.

---

## D005 — Preserve ingredient raw text

### Context

Automatic parsing can be wrong or incomplete.

### Decision

Always preserve the original ingredient input as `rawText`.

Parsed data is assistive and editable.

### Consequence

Parser errors cannot destroy the user's original recipe information.

---

## D006 — Multi-line ingredient paste is part of the MVP

### Context

YouTube descriptions and blog recipes commonly present ingredients as one item per line.

Entering these items manually one by one would create unnecessary friction.

### Decision

Allow users to paste multiple ingredient lines at once.

Each non-empty line becomes an ingredient candidate, is parsed, and can be reviewed before confirmation.

### Consequence

The app better supports the real-world workflow of archiving recipes from external content.

---

## D007 — Do not use a fixed ingredient dictionary

### Context

A fixed selector would require the app to maintain a large ingredient catalog and would fail on specific or unusual ingredient names.

### Decision

Ingredient names remain free text.

### Consequence

The app does not force users to adapt their recipes to an application-defined vocabulary.

---

## D008 — Do not implement linear serving multiplication in the MVP

### Context

Doubling a one-serving recipe does not always produce a correct two-serving recipe.

Seasoning, water, heating, pan size, evaporation, and cooking time may not scale linearly.

### Decision

Store serving information as recipe metadata, but do not automatically multiply ingredients in the MVP.

### Consequence

The app avoids presenting mathematically neat but potentially misleading cooking guidance.

---

## D009 — Personal notes are separate from canonical cooking steps

### Context

A user may repeatedly adjust a recipe based on personal equipment and taste.

Example:

- original instruction: 중불에서 5분 볶기
- personal note: 우리 집 인덕션에서는 4단계로 4분이 적당함

### Decision

Store personal notes separately from the cooking instructions.

### Consequence

The recipe can evolve into a personal version without losing the distinction between recipe instructions and user experience.

---

## D010 — Export is a product feature, not decorative sharing

### Context

The product exists partly to prevent recipes from disappearing with external platforms or applications.

### Decision

Support self-contained image and PDF export.

### Consequence

Users can retain recipes outside Recipe Archive and maintain greater ownership of their data.

---

## D011 — AI and OCR assistance are deferred and must remain assistive

### Context

Automatic extraction from YouTube, webpages, images, or screenshots may be
useful, especially for reducing recipe entry friction. It also introduces
complexity, accuracy concerns, API costs, device compatibility constraints, and
copyright considerations.

RecipeUm should remain a personal recipe archive, not an AI recipe generator.
AI and OCR features may be valuable for the product and for demonstrating
modern iOS engineering in a portfolio, but they should not become required for
the core archive workflow.

### Decision

Do not make AI or OCR extraction a dependency of the MVP.

Build a reliable manual + paste workflow first.

If added later, AI and OCR features should be assistive:

- OCR may extract text from recipe photos, books, notes, or screenshots.
- Apple Foundation Models may help turn pasted or OCR text into a recipe draft.
- AI may suggest ingredient groups, cooking step cleanup, and a one-line summary.
- AI output must remain a draft that the user reviews and edits before saving.
- The original user-provided text should be preserved whenever practical.
- Core recipe creation, editing, searching, and exporting must continue to work
  without AI.

### Consequence

Future AI or OCR assistance can feed into the same reviewable structured recipe
model instead of defining the initial architecture.

Using Apple Intelligence technologies, such as Vision OCR and Foundation Models,
is preferable when it supports privacy, local-first behavior, and graceful
device compatibility handling. Unsupported devices should hide or disable those
optional assists rather than blocking the app.

---

## D012 — Keep project documents at the repository root initially

### Context

The project is starting with a small set of stable planning documents.

Creating a deeper documentation folder structure now would add navigation overhead before the app code exists.

### Decision

Keep `SPEC.md`, `ROADMAP.md`, `DECISIONS.md`, `AGENTS.md`, `GIT_WORKFLOW.md`, and `AI_WORKFLOW.md` at the repository root during the initial setup phase.

### Consequence

The repository stays easy to scan while the product and app structure are still forming.

The documents may be moved into a dedicated folder later if the number of supporting documents grows.

---

## D013 — Do not add an open-source license yet

### Context

RecipeUm is intended as a real app/service, but the public distribution and reuse policy has not been decided yet.

### Decision

Do not add a `LICENSE` file during initial setup.

State in `README.md` that no open-source license has been selected.

### Consequence

The project remains visible in GitHub while avoiding accidental permission for external reuse before the product direction is settled.

An explicit license can be added later when the distribution strategy is clear.

---

## D014 — Keep the generated Xcode project in a top-level app folder

### Context

The repository is dedicated to the iOS app.

Xcode generated the app project inside a top-level `RecipeUm/` folder within the repository.

### Decision

Keep the generated structure:

- `RecipeUm/RecipeUm.xcodeproj`
- `RecipeUm/RecipeUm`
- `RecipeUm/RecipeUmTests`
- `RecipeUm/RecipeUmUITests`

### Consequence

Repository-level planning documents remain easy to scan at the root, while generated app files stay grouped together.

If additional packages, tooling, or platform targets are introduced later, the repository layout can be revisited with a recorded decision.

---

## D015 — Use iOS 17.0 as the initial deployment target

### Context

RecipeUm uses SwiftData for local persistence.

SwiftData requires iOS 17 or later, while the generated Xcode project initially used the current SDK version as the deployment target.

### Decision

Set `IPHONEOS_DEPLOYMENT_TARGET` to `17.0` for the initial app and test targets.

### Consequence

The app keeps SwiftData support while avoiding an unnecessarily narrow device support window.

---

## D016 — Build Phase 2 library features before a dedicated UI polish phase

### Context

After Phase 1, RecipeUm has a usable local archive: recipe CRUD, ingredient
input, parsing, cooking steps, notes, and source metadata.

There are visible UI refinements to make, but search, favorites, and category
browsing will change how the main list and detail screens should behave.

### Decision

Move directly from Phase 1 into Phase 2 library features.

Defer a dedicated UI refinement phase until the app has search, favorites, and
basic category or collection workflows.

### Consequence

UI work can be based on more realistic usage patterns instead of polishing the
initial CRUD screens too early.

---

## D017 — Keep Phase 2 categories lightweight

### Context

RecipeUm needs a simple way to browse a personal recipe archive, but the MVP
does not yet have enough real usage data to justify a full collection system.

Categories and collections can overlap:

- cuisine or style: 한식, 양식, 일식, 중식, 디저트
- personal grouping: 자취 요리, 엄마 레시피, 손님용, 자주 만드는 요리
- dish type: 밥, 면, 국/찌개, 반찬

Adding all of these as separate structured systems now would make recipe entry
and browsing heavier before the product has proven which grouping users need.

### Decision

Use a lightweight single category field for Phase 2.

Default category options should stay small and broad. Existing custom category
values remain preserved and selectable when editing saved recipes.

Do not add a separate collection model in Phase 2.

### Consequence

The library can support basic category browsing without over-designing taxonomy.

Collections can be revisited later after real recipes reveal whether categories
alone are not enough.

---

## D018 — Defer collections but keep category code extensible

### Context

After Phase 2, RecipeUm supports search, favorites, category browsing, and
detail-level category editing.

Categories and collections are related but solve different problems:

- category: one lightweight primary classification for a recipe
- collection: user-defined multi-membership grouping for a purpose or situation

Examples of future collections include 자주 만드는 요리, 손님상, 도시락, 엄마
레시피, and 다이어트.

### Decision

Do not add a separate collection model for the current MVP.

Continue using one category field as the basic browsing mechanism. Keep category
filtering, category option generation, and category display logic separated from
View-only code so that future collection behavior can be added without rewriting
the recipe model or list filtering from scratch.

### Consequence

The current app stays simpler and easier to use while the recipe count is small.

If real usage shows that one category is not enough, collections can be added as
a separate feature with their own model and many-to-many recipe membership.

---

## D019 — Defer PDF export until usage validates the need

### Context

RecipeUm needs export because saved recipes should remain useful outside the
app. The original MVP scope included both image and PDF export, but the likely
near-term sharing and saving flow is an image recipe card.

PDF export adds extra layout concerns such as pagination, printable formatting,
and long-recipe overflow handling. Those concerns are valuable only if users
actually need document-style recipe artifacts.

### Decision

Phase 3 will focus on image export first.

Support receipt-style, memo-style, and recipe-card-style image cards with a
preview/selection flow.
Defer PDF export until real usage or user requests show that printable artifacts
are worth adding.

### Consequence

The export phase stays smaller and closer to the most likely user workflow.

If PDF export is added later, it should reuse the same export snapshot used by
image export so that export data rules remain consistent.

## D020 — Default export options protect useful personal context and source privacy

### Context

Image export should remain useful without turning RecipeUm into a publishing
workflow. Some saved fields are personal and useful in an exported recipe, while
source metadata can be long, noisy, or less appropriate for every shared image.

### Decision

Include personal notes by default when they exist, because they often preserve
the user's cooking context. Exclude source metadata by default, but let users
opt in from the export preview before saving or sharing.

### Consequence

The default exported image keeps the recipe useful and compact. Users can still
create a more traceable export when source metadata matters.
