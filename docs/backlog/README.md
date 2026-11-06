# Backlog

See the [published GitHub issue index](GITHUB.md) for epic and child issue links.

This is a proposed, GDD-derived backlog. IDs are stable local planning IDs; GitHub issues are the execution record when published. Acceptance criteria must be refined against the implementation before work begins. Dependencies and the slice gate are in the [roadmap](../ROADMAP.md).

## [E01 — Foundation and production evidence](epics/E01.md)

**Goal:** Establish a repeatable baseline and decide what can be safely reused.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E01-01: Measure the existing levels.](issues/E01-01.md)** Measure smooth runs and observed first attempts, including time, deaths, secrets and reuse decisions; record build and participants.
- **[E01-02: Audit asset provenance and redistribution.](issues/E01-02.md)** Inventory code, art, music, fonts and effects with sources, licenses, permitted uses and unresolved items; identify replacement or clearance actions.
- **[E01-03: Establish reproducible import and test baseline.](issues/E01-03.md)** Document and run clean Godot import and representative integration tests; investigate import metadata consistency and record limitations.
- **[E01-04: Define the playtest and device plan.](issues/E01-04.md)** Define participant groups, consent, measures, test builds, target devices and quantitative thresholds before formal testing.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E02 — Solo controls, recovery and assists](epics/E02.md)

**Goal:** Make the solo experience readable, fair, and faithful to the GDD.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E02-01: Calibrate movement and contextual interaction.](issues/E02-01.md)** Verify jump assists, movement and interaction prompts; resolve accidental action conflicts and record playtest observations.
- **[E02-02: Implement attempt recovery and depletion rules.](issues/E02-02.md)** Verify falls, safe points, health depletion and attempt inventory reset while retaining previously recorded progress; cover edge cases in tests.
- **[E02-03: Add configurable accessibility assists.](issues/E02-03.md)** Provide extra hearts, checkpoint frequency and no fall damage with no content penalty; test normal and assisted recovery.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E03 — Campaign progression and persistence](epics/E03.md)

**Goal:** Support durable progress, level selection and replay.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E03-01: Design and implement versioned campaign saves.](issues/E03-01.md)** Define durable versus attempt state; save and reload progress safely with versioning and corruption handling; test restart and migration paths.
- **[E03-02: Create campaign registry and level map.](issues/E03-02.md)** Define level metadata, sequential unlocks and revisiting; display open and completed routes and test transition behavior.
- **[E03-03: Persist secrets, rewards and character unlocks.](issues/E03-03.md)** Record secrets and discoveries, world rewards and the campaign-completion prototype unlock; verify reload and replay behavior.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E04 — Local cooperative play](epics/E04.md)

**Goal:** Make the complete main route playable by one or two people.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E04-01: Implement player input and character assignment.](issues/E04-01.md)** Support distinct device ownership, safe join and leave, equal abilities and no player collision; exercise keyboard plus controller and two controllers.
- **[E04-02: Implement shared camera and safe relocation.](issues/E04-02.md)** Keep both players readable; cue and safely relocate a distant player without penalty, including obstructed terrain cases.
- **[E04-03: Implement cooperative health, revival and shared exits.](issues/E04-03.md)** Implement separate hearts, partner respawn, both-out restart, shared key and exit rules; test deadlocks, falls and join/leave transitions.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E05 — Representative playable slice](epics/E05.md)

**Goal:** Build a four-level world that tests the core experience before scaling.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E05-01: Design and validate protagonist presentation.](issues/E05-01.md)** Develop Lila and Sol reference sheets and readable in-game silhouettes and animations; test at game size and in grayscale.
- **[E05-02: Build four distinct slice levels and finale.](issues/E05-02.md)** Create introduction, combination, exploration and finale levels with readable routes, one optional secret each and a restored light; test solo and co-op.
- **[E05-03: Prototype a discovery path and album.](issues/E05-03.md)** Build one optional post-ending path with category, reward and persistent album record; make it replayable solo and co-op.
- **[E05-04: Add slice narrative and audiovisual feedback.](issues/E05-04.md)** Implement a skippable visual introduction, clear interaction and hazard cues and celebration; validate readability without relying on text or audio alone.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E06 — Playtest and scope decision](epics/E06.md)

**Goal:** Gather evidence and decide the feasible campaign scope.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E06-01: Observe slice playtests and record findings.](issues/E06-01.md)** Observe players including ages 5–7 with appropriate adult consent and varied experience; record comprehension, retries, assistance, enjoyment and times.
- **[E06-02: Decide campaign scope from slice evidence.](issues/E06-02.md)** Review test results, resource constraints and risks; document the decision on level count, co-op, discovery paths and next milestones without assuming approval.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E07 — Campaign production](epics/E07.md)

**Goal:** Complete the approved campaign and its ending after the slice gate.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E07-01: Plan and produce worlds 2–4.](issues/E07-01.md)** After the scope decision, prepare level briefs and build approved world content, finales and secrets; verify every mandatory route solo and co-op.
- **[E07-02: Plan and produce worlds 5–6.](issues/E07-02.md)** After the scope decision, prototype wind and creature behaviors safely and produce approved levels and finales with readable cues.
- **[E07-03: Plan and produce worlds 7–8 and ending.](issues/E07-03.md)** Produce approved late-game combinations, final Wind encounter and visual ending; verify progression and accessibility without secrets.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E08 — Replayability and discovery](epics/E08.md)

**Goal:** Deliver rewarding optional exploration without blocking the ending.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E08-01: Implement exploration and reward presentation.](issues/E08-01.md)** Expose completed level selection, secret log, illustrations and prototype character after their defined unlocks; persist and test them.
- **[E08-02: Expand discovery paths based on prototype results.](issues/E08-02.md)** Decide quantity after evaluation; author approved paths with distinct categories, source real facts, label fiction and verify development stories.
- **[E08-03: Evaluate optional mastery challenges.](issues/E08-03.md)** Prototype and evaluate optional challenges including the proposed world restart rule; document decision and keep the standard campaign unaffected.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E09 — Quality, accessibility and release](epics/E09.md)

**Goal:** Validate a distributable game on selected platforms.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E09-01: Implement Spanish-first localization and accessible interface.](issues/E09-01.md)** Prepare translation-ready text, Spanish initial UI, visual prompts and accessible options; test readability, remapping and no color-only information.
- **[E09-02: Validate desktop and browser builds.](issues/E09-02.md)** Define supported versions and test real Linux, macOS, Windows and browser builds for input, saving, audio, performance and web hosting.
- **[E09-03: Complete release audit and regression pass.](issues/E09-03.md)** Resolve distribution rights, run automated and human regressions, document known issues and release criteria; verify no unresolved blocking rights.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.

## [E10 — Optional playtest telemetry](epics/E10.md)

**Goal:** Provide voluntary, privacy-conscious evidence for balancing if approved.

**Existing context:** GDD v0.6 describes the intended behavior; the current prototype and any unverified assumptions must be inspected before implementation.

**Completion criteria:** All child work meets its acceptance criteria, relevant automated checks pass, and human playtest or review evidence is recorded where applicable.

**Child issues:**

- **[E10-01: Define telemetry policy and event schema.](issues/E10-01.md)** Specify consent, retention, ownership, event versions, denominators and local identifiers before real collection; prohibit automatic transmission.
- **[E10-02: Implement opt-in local collection and controls.](issues/E10-02.md)** Default off; provide local review, deletion and export; exclude pauses, avoid personal data and test with synthetic sessions on desktop and web.
- **[E10-03: Analyze synthetic telemetry and validate interpretation.](issues/E10-03.md)** Validate heatmap cells, attempt denominators and performance; document limits of interpreting exits and retention before collecting real sessions.

**Boundary:** Preserve solo completion, accessible play, and the evaluation gate; do not treat proposed features or quantities as already delivered.
