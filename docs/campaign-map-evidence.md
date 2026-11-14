# Campaign registry and level-map evidence

Evidence for [E03-02 / issue #19](https://github.com/stevdrey/path-of-light/issues/19), recorded 2026-11-13. This is a local Linux development candidate, not a release or human usability approval. [ADR 0006](adr/0006-campaign-registry-map.md) defines the prototype contract and remaining design boundaries.

## Candidate and reproduction

Base: `a63b798` (issue #18). The candidate is the working tree identified by the full per-file SHA-256 manifest and manifest digest in [implementation/results.json](verification/issue-19/implementation/results.json). It includes tracked and untracked source; `docs/verification/` is excluded to avoid hashing generated evidence into itself. The report records the full base commit, engine identity/hash, Linux host, exact commands and isolated data/config/cache directories for every process. This is a source candidate, not an exported game build.

```sh
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output docs/verification/issue-19/implementation --include-map
python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py
git diff --check
```

The runner is Linux-only and refuses other hosts before launching Godot or creating fixtures. It allocates new temporary XDG data/config/cache roots; only deliberate cold-process pairs share storage. It never uses the player's campaign/settings. `--include-map` adds two map lifecycle processes, three protected/recovered storage checks and a repeated-confirm/failure-retry navigation regression to the existing 19 campaign/recovery cases; default invocation retains the original 19-case suite.

## Acceptance mapping

| Criterion | Implementation and automated evidence |
| --- | --- |
| Define metadata, sequential unlocks and revisiting | `campaign_registry.gd` registers only the two actual scenes, retaining save IDs 1 and 2. Map checks reject unknown IDs/locked selection, verify metadata-copy isolation and real scene identities, derive level-two availability from real level-one completion, and revisit completed levels. No secret or assist is required. |
| Display open/completed routes and test transitions | The menu, pause and final screen reach a connected selection map with numbered nodes, status symbols/text and route labels. Integration checks real scene replacement, first-open focus, disabled nodes, return/cancel focus, pause release, duplicate-input protection, scene-load failure/retry, clean selected attempts, configured hearts, ordinary exit carry-over and final completion. Geometry assertions cover 640×480 and 1152×648. These assertions are not a visual or physical-controller review. |
| Record build, evidence and limitations; update documentation | This report, machine-readable source identity/logs, ADR 0006, README, architecture wiki, GDD status addendum and local backlog record the contract and limitations. The live issue is not automatically closed or edited. |

## Results and diagnostics

The final implementation run is recorded in [results.json](verification/issue-19/implementation/results.json), with retained stdout/stderr for each case. The intended checked set is 25 process cases: storage, save/reopen, migration/reopen, protected/recovered/I/O-failure persistence, recovery/retry/replay, assists, pause, ordinary two-level transitions, deferred-scene waiting, map lifecycle/reopen, map storage boundaries and repeated-confirm/failure-retry navigation. See the machine result for pass/fail counts and diagnostic lines. The runner also rejects a zero-exit process containing `SCRIPT ERROR`, `Parse Error` or `FAIL:`.

Four Python runner-isolation tests are recorded in [runner-unit.log](verification/issue-19/runner-unit.log); their platform/subprocess mocks verify safeguards, not native Windows/macOS behavior. Independent acceptance review is recorded separately in [independent/final-integration-report.md](verification/issue-19/independent/final-integration-report.md), including its exact candidate identity and limitations. It is valid only for that candidate.

The first independent review found that repeated confirm input could enqueue duplicate pause/completion map callbacks and produce null-tree script errors after scene detachment. That candidate and failed verdict are preserved under [initial/](verification/issue-19/initial/independent/final-integration-report.md). The corrected candidate guards requests before enqueueing, disables the requesting control, ignores detached callbacks and restores focused controls on failure. A regression sends two genuine UI accept press/release pairs, injects failures at both navigation callers and checks retry; conflicting replay input is also guarded. The final independent report applies only to the corrected candidate.

An early map failure-injection harness could not compile an inherited script's bare `BackgroundMusic` autoload reference before autoload initialization. The final map resolves the autoload through the runtime tree and captures it before scene replacement. That initial diagnostic is retained in [initial-map.stderr.log](verification/issue-19/initial-map.stderr.log); it is a failed development check, not evidence of a passing candidate.

The headless editor import completed but reported socket/listener and null-image errors, including failure to connect the MCP bridge. Engine integration runs report the sandbox's GameMode D-Bus failure and ObjectDB/resource cleanup warnings; storage and restart fault-injection cases also intentionally report file/restart failures. Raw logs are retained. These diagnostics are not an error-free editor/import or resource-lifetime claim. No GDScript parse/runtime failure is accepted as a passing check.

## Remaining validation

The editor bridge was disconnected; verification used the installed Godot `4.8.beta3.official.c51ff06e8` CLI and existing scene-test conventions. No editor-driven live playtest, screenshot/render inspection, listening session, physical controller, child/accessibility evaluation, co-op, native Windows/macOS, web storage/export, exported executable or second machine was tested. Geometry and synthesized UI events cannot establish visual clarity, input feel or discoverability. Asset clearance remains governed by the existing provenance audit; no new external assets were introduced.

The map covers two experimental levels, not an approved four-level slice or 32-level campaign. World art/story celebrations, character unlocks, reward album and post-ending discovery paths remain future work. Saved unknown IDs remain preserved without becoming selectable content. Protected/unwritable saves can open routes in memory, but only successful persistence establishes availability after another process starts. The playable-slice scope gate remains open.
