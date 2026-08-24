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

## D011 — AI extraction is deferred

### Context

Automatic extraction from YouTube, webpages, or images may be useful but introduces complexity, accuracy concerns, API costs, and copyright considerations.

### Decision

Do not make AI extraction a dependency of the MVP.

Build a reliable manual + paste workflow first.

### Consequence

Future AI extraction can feed into the same reviewable structured recipe model instead of defining the initial architecture.

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
