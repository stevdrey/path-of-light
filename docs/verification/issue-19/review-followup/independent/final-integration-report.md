# Independent verification: Issue #19 / PR #49 review follow-up

**Verdict: PASS for the exact two-level solo source candidate below. No actionable regression or acceptance-criterion failure found.** This is an independent local verification result, not GitHub approval, merge authorization, release approval or a human playtest.

## Identity and review scope

- PR: https://github.com/stevdrey/path-of-light/pull/49, `[Issue-19] Add campaign registry and level map`.
- Actual issue and review were independently retrieved read-only through the GitHub connector. The current issue #19 has three criteria: metadata/sequential unlocks/revisiting; open/completed routes and transitions; applicable evidence/exact build/limitations/documentation. The full review and inline thread match `review-request.md`.
- Inline request: https://github.com/stevdrey/path-of-light/pull/49#discussion_r4577070881; review: https://github.com/stevdrey/path-of-light/pull/49#pullrequestreview-5909156349.
- PR base: `a63b7984ee68b17e3bfd4c6dbfd256dc6561c5ca`.
- Comment's reviewed head: `31fbf6ee32ac5b80a78b2c5174f39f276e99c10e`.
- Independently verified local source commit: `232048253c73f9f752ce7f80b8afc810c777a68f`.
- Source commit tree: `7a0781f4ab3cf5a2f3ff06bdf52aedc37a58b15b`.
- Full source manifest: **425 files**, SHA-256 `5579900907d166220b8f011f753c27d3999235af24d5f344291adc51c15c9a2f`.
- `identity-before.json` and `identity-after.json` independently recompute the manifest from tracked and nonignored untracked files, excluding `docs/verification/`. Both match every file in the frozen implementation manifest, the expected digest, commit and tree. The reviewed source was unchanged at completion. All original files in the temporary test copy also remain byte-identical; only reviewer fixtures and Godot import/cache outputs were added there.

I read AGENTS.md, the project independent-verification skill, relevant Godot skills, GDD (especially progression/interface/scope boundaries), ROADMAP, E03 and E03-02, ADR 0006 and the actual production/test callers. I inspected the full base-to-candidate source/documentation diff outside historical verification artifacts, and the narrower comment-head-to-candidate changes. The previous PASS for `4583ed9` was not used as verification of this candidate.

## Criterion results

| Criterion / follow-up | Result | Fresh evidence |
| --- | --- | --- |
| Stable metadata, sequential unlocks and revisiting | PASS | Reviewed registry/scene callers; reviewer-authored unlock matrix for empty, unknown-only, direct level-two, predecessor and completed facts; metadata-copy mutation and endpoint tests. Independently ran current `level_map_integration` and `two_levels_integration`. Unknown IDs do not create/unlock routes; direct completed route remains revisit-able. |
| Display open/completed routes; test solo transitions | PASS | Independently executed current map integration: blocked/open/completed text and route labels, focus, locked/unknown handler guards, selected levels, ordinary exit with carried score/hearts and consumed key, completed revisits, pause/completion/menu links and 640x480 / 1152x648 bounds. Reviewer probe additionally tested pause failure/retry and clean abandonment/reselection. |
| Main-menu competing transitions in both orders | PASS | Reviewer-authored probe activates MAPA/JUGAR and JUGAR/MAPA, repeated conflicting/duplicate signals, mismatched pending callback, and real deferred replacements; exactly one request is accepted. Both actions share `pending_scene`; buttons disable before deferral. Independently executed current author regression as supplemental evidence. |
| Detached callbacks and failure/retry | PASS | Reviewer probe removes a pending menu before deferral, calls both entry points while detached, and performs an external scene replacement before the old callback; no old-menu request or script error. Two consecutive injected checked failures per destination preserve inventory, durable facts, warning, controls and initiating focus. Selecting the opposite destination after failures works. Source checks tree membership and pending path before tree access. |
| Completion Space versus Enter/R | PASS | Reviewer synthesizes physical-key events: Space leaves completion visible and queues nothing; Enter then R reaches map; R then Enter reaches level one. Current author navigation test independently rerun also verifies injected map-load failure/retry and repeated Enter. No script/parse/FAIL diagnostics in final runtime checks. |
| Pause-to-map semantics | PASS | Reviewer injects failed request: live attempt remains paused, inventory intact, focused enabled retry restored; duplicate retry reaches unpaused map. Source retains pause through accepted replacement until `_exit_tree()`. Current navigation/map integrations independently rerun supplement this. |
| Clean selected attempt and ordinary-exit carry-over | PASS | Reviewer checks abandoned inventory/key/damage/hidden-heart state and checkpoint index do not survive map selection. Current map integration independently rerun checks configured five hearts and empty level-two entry snapshot; ordinary door exit carries score/hearts, records level one and consumes exit key. Current two-level integration independently rerun exercises actual interaction/door transition. |
| Exact evidence, documentation and limitations | PASS for prepared payload | Before/after source identities match. Independently audited final implementation 26-process logs against their recorded SHA-256 values, exits, diagnostics, PASS lines, XDG environments and source manifest. Four runner isolation unit tests independently passed. Current evidence docs distinguish historical candidate, implementation checks, independent checks and deferred human/platform work. This report and companion artifacts complete the independent evidence payload; no publication was performed. |

## Independently executed checks

Godot executable: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`; SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`; version `4.8.beta3.official.c51ff06e8`. Linux host as recorded by the implementation report: `Linux-7.3.3-300.fc45.x86_64-x86_64-with-glibc2.44`.

The editor MCP server independently reported bridge disconnected. I used a new source-manifest copy at `/tmp/issue19-followup-independent/project`. Every engine process, including version and editor import, received fresh temporary `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, and `XDG_CACHE_HOME`. No real player save/settings paths were used. Reviewer runtime details, commands, environments and raw-log hashes are retained in `runtime-results.json` and `run.py`.

Reviewer-authored focused scenario `reviewer_followup.gd.txt`: **31 assertions passed**, one engine process. It uses only runtime observation, real scene requests/input dispatch, plus narrow request overrides to count attempts and inject checked errors. The production source is untouched.

Four repository integration scripts were independently rerun, all exit 0 with no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostics:

- `level_map_integration.gd`
- `map_navigation_integration.gd`
- `front_end_navigation_integration.gd`
- `two_levels_integration.gd`

Reproduction of these five runtime checks in the prepared temporary copy:

```sh
python3 /tmp/issue19-followup-independent/run.py reviewer_followup level_map_integration map_navigation_integration front_end_navigation_integration two_levels_integration
```

`python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py` in the temporary copy: **4 tests passed**, retained in `runner-unit.stdout.log` / `runner-unit.stderr.log`. These use mocked engines/host names to verify storage isolation/unsupported-host rejection and are not native cross-platform results.

Original checkout `git diff --check`: passed. Manifest verification command:

```sh
python3 /tmp/issue19-followup-independent/identity.py after
```

## Implementation evidence audit

`implementation-audit.json` records a separate audit of the author's final implementation evidence at `docs/verification/issue-19/review-followup/implementation/`:

- 26/26 declared processes, all exit 0, no recorded or raw script/parse/FAIL diagnostics.
- All 52 raw stdout/stderr hashes match; all PASS-line lists match raw logs.
- All fixture process environments redirect each XDG directory under `/tmp`.
- Reported commit and all 425 source hashes exactly match this verified source candidate.

These 26 processes are **implementation runs**, not additional independent executions. The independent executions are the five runtime checks and four mocked Python tests above.

## Findings and limitations

No prioritized actionable findings remain within the scoped review request and two-level solo acceptance criteria.

The first clean-copy editor import exited 0 but emitted transient music preload parse failures while imports were unavailable. This preparation attempt is retained as a failure in `editor-import.stderr.log`; a second import had no script/parse diagnostics, and every subsequent focused runtime process parsed and passed. Both imports retain editor MCP socket/thumbnail/cache-related errors in raw logs. The runtime processes retain GameMode session-bus access errors from this environment; several repository integration scripts additionally report ObjectDB/resource cleanup warnings at exit. The reviewer-authored scenario has no ObjectDB/resource cleanup warnings. This report does not claim an error-free editor/import/cleanup environment.

These are synthetic headless Linux scene/input/state checks. Human visual clarity, audio balance, child accessibility, physical controllers, co-op, exports, browser persistence and native Windows/macOS devices were not tested. They remain explicitly open under the issue/ADR scope and are not inferred from automation. No new assets, collection of telemetry, campaign expansion, save schema change or release validation is established.

Before publishing an evidence-only commit, retain this report and its logs/fixtures/identity/audit artifacts and recheck that the complete source manifest remains identical. The source tree above identifies the source commit; a later evidence-only commit has a different full Git tree and must be recorded as such. Any source/documentation change outside the excluded evidence directory invalidates this exact-candidate verdict and requires re-verification. No external comment, review, push, approval or merge was performed by this verifier.
