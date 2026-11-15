# Independent acceptance verification — issue #19

Verdict: **FAIL — one P2 transition defect requires correction and fresh verification.** This is an independent source/runtime review by a separate verifier; no candidate source was edited and no remote write was performed.

Issue: https://github.com/stevdrey/path-of-light/issues/19. Base: `a63b7984ee68b17e3bfd4c6dbfd256dc6561c5ca`. Exact candidate: tracked and untracked files excluding `docs/verification/`, **417 files**, manifest SHA-256 `a2b4fa1f1888b0f02fa91de7c7cc410f970597bc941d20f27100eb92c6bc0483`. Independent before/after recomputation matched the supplied per-file manifest with no changed/added/missing source files (`identity-before.json`, `identity-after.json`). Any source change invalidates this verdict.

## Acceptance mapping

| Criterion | Verdict | Evidence |
| --- | --- | --- |
| Define level metadata, sequential unlocks and revisiting | PASS | Registry owns the two actual scene paths and published IDs 1/2, returns copied metadata, derives opening from completion facts, rejects unknown IDs and permits completed legacy/direct-entry revisits. Reviewed callers and independently reran map, storage, and cold-process tests. Secrets/diamonds/assists do not gate availability. |
| Display open/completed routes and test transition behavior | FAIL | State labels, route labels, focus, locked handler guard, clean map entry, direct-exit carry-over, ordinary pause/completion/menu transitions, map launch failure/retry and cold reopen pass. Independent repeated UI acceptance reproduces an unguarded deferred navigation defect in both pause and completion callers; see P2 below. |
| Record evidence, exact build, remaining limits; update documentation | PASS | ADR 0006, evidence report, README, wiki, GDD addendum and local backlog describe the two-level prototype and open human/platform limits. Source/engine identities and commands are recorded. This is a source candidate, not an exported build. This independent report supersedes a blanket passing interpretation of implementation tests. |

## P2 — Guard each deferred return-to-map request before enqueueing it

Locations: `src/ui/scripts/pause_menu.gd:133–141` and `src/scenes/scripts/level.gd:206–214`.

Both map entry points leave their focused button active and allow multiple callbacks to queue before the first deferred scene change runs. Two `ui_accept` press/release pairs delivered before deferred callbacks flush queue two requests. The first request detaches the old scene; the second callback then calls `get_tree()` on that detached node and invokes `change_scene_to_file` on null. This produces `SCRIPT ERROR: Cannot call method 'change_scene_to_file' on a null value` at pause line 141 and completion line 214. The map does load and pause clears in the reproduction; this is a runtime script error, not evidence of a full process crash or lost save.

Reproduction: `reviewer_navigation.gd` instantiates a real level, focuses the real pause map button (or creates the real completion UI through `_show_completion()`), sends real synthesized `InputEventAction` accept press/release pairs twice, then awaits the actual map scene. Both processes exit zero but emit the script errors. Read `navigation-pause.stderr.log`, `navigation-completion.stderr.log` and `navigation-result.json`; a zero process exit does not make these checks pass. `reviewer_boundaries.gd` additionally reproduces the pause defect through duplicate pressed signals.

Corrective direction: add a navigation-pending guard synchronously in each input callback before deferring, disable the initiating control or relevant controls, and clear/restore that guard/control state on request failure. Preserve paused-attempt state on failed pause navigation. Add regression coverage for duplicate acceptance at these two entry points; existing map tests only guard duplicate selection inside the map itself.

## Commands, environment and results

- `python3 -B src/tests/run_campaign_checks.py --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 --output /tmp/path-light-19-independent/reproduction --include-map`: **24/24 cases passed**, no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostics in those cases. Exact commands, separate temporary XDG roots, logs and source/engine identities are in `reproduction/results.json`.
- `python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py`: **4/4 passed**. These are Python isolation/host-guard tests, not native-platform Godot evidence.
- `git diff --check`: passed.
- `/opt/Godot/Godot_v4.8-beta3_linux.x86_64 --headless --path <candidate> --script /tmp/path-light-19-independent/reviewer_navigation.gd -- pause` and the same command with `completion`: **FAIL due to runtime script errors**, despite zero exits and successful first navigation. Each process used a newly allocated temporary XDG data/config/cache root; see `navigation-result.json`.
- Supplemental protected-save layout check (`reviewer_layout.gd`): passed bounds at a physical root size of 640×480. The project's scaling yields a logical viewport of 1152×864; this is a bounds assertion, not rendered visual inspection. See `layout.stdout.log` and `layout-result.json`.

Engine: `4.8.beta3.official.c51ff06e8`, SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`, Linux host. All gameplay engine processes used fresh isolated `XDG_DATA_HOME`, `XDG_CONFIG_HOME` and `XDG_CACHE_HOME`; deliberate cold-process pairs in the runner shared only their allocated fixture storage. No real player data was used. The runner's `--version` query does not launch the game or load user data.

The Godot MCP health check reported bridge disconnected, version `2026.11.04` and address-in-use bind failure. CLI verification followed the existing project convention. Routine logs include GameMode D-Bus failures and ObjectDB/resource cleanup warnings; intentional storage/restart failure cases retain expected diagnostics. Those do not excuse the newly reproduced GDScript errors.

## Scope and limitations

Reviewed AGENTS.md, GDD, roadmap, issue/backlog, ADRs, changed source, callers and tests. Stable save IDs and schema remain intact; source adds no external asset or telemetry, expands no campaign content, preserves optional secrets/assists and leaves the playable-slice gate open. Existing automated checks protect the solo route and recovery/persistence boundaries.

No editor-driven live playtest, rendered screenshot inspection, listening session, physical controller, child/accessibility evaluation, co-op, native Windows/macOS, web/export persistence, exported executable or second machine was tested. Scripted collection/exit calls and synthesized UI events are not human gameplay evidence. Pause/completion missing-map load failures were inspected statically rather than independently fault-injected; the normal map launch failure was exercised by the candidate's injected-error test. These remain limits rather than invented pass claims.
