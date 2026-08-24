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
