# Independent acceptance verification — issue #19, corrected candidate

Verdict: **PASS for the scoped two-level solo prototype. No actionable findings remain from this independent review.** The initial P2 repeated-confirm navigation defect is corrected and independently reverified. Human usability and platform validation remain open as described below. This verdict applies only to the source candidate identified here; it is not release approval.

Issue: https://github.com/stevdrey/path-of-light/issues/19. Base: `a63b7984ee68b17e3bfd4c6dbfd256dc6561c5ca`. Exact candidate: tracked and untracked source excluding `docs/verification/`, **419 files**, manifest SHA-256 **`464ba9d377044d849b3ec2ac7f1ffce467840bda26091d6d8e22ed79e420c41c`**. Independent before/after enumeration and hashing matched the candidate manifest and each other, with no changed, added or missing source files (`identity-before.json`, `identity-after.json`). The base-to-candidate source diff, untracked additions, call sites and tests were examined. No candidate source, Git state, remote issue or publication was changed by this reviewer. All authored reviewer artifacts are in this directory.

## Acceptance mapping

| Criterion | Verdict | Evidence |
| --- | --- | --- |
| Define level metadata, sequential unlocks and revisiting | PASS | Registry contains the actual two scene paths and published save IDs 1/2, returns deep metadata copies, opens the first route immediately, derives sequential availability from predecessor completion, rejects unknown selections and supports completed direct-entry/legacy revisits without inventing predecessor facts. Neither secrets, diamonds nor assists gate routes. Reviewed registry, save model and callers; original independent map/cold-process evidence remains relevant, and current 25-case implementation evidence passes. |
| Display open/completed routes and test transition behavior in the solo prototype | PASS | Map buttons and connection labels distinguish blocked/open/completed states using text and symbols. Existing evidence covers locked handler guards, focus, ordinary exit carry-over, clean map entry, configured hearts, menu/pause/completion access and cold reopen. Independently reran the original repeated-accept reproduction in pause and completion, the corrected failure/retry regression and an additional boundary harness; all current processes exit zero without script/parse/failure diagnostics. Repeated failure, request counting, inventory preservation, competing menu action and replay-after-failure are covered below. |
| Record applicable evidence, exact candidate and limitations; update documentation | PASS | ADR 0006, campaign-map evidence, README, wiki, GDD addendum and local backlog explain the two-level prototype, source identity, reset/carry-over contracts and open validation. Completed implementation evidence is 25/25 for this exact source identity. Reviewer audited all 25 stdout/stderr hashes and independently scanned them for `SCRIPT ERROR`, `Parse Error` and `FAIL:`; none occur. Commands, engine and isolated environments are retained. This identifies a local source candidate, not an exported executable. |

## Corrected P2 and independent runtime checks

The correction sets each pause/completion map-request guard synchronously before deferring, disables the requesting button, ignores callbacks on detached scenes and restores a focused, enabled retry control after failure. Pause failure keeps the attempt paused. Completion guards conflicting replay input in both request orders. Source inspection and runtime evidence agree.

`reviewer_navigation.gd` is an unchanged copy of the first review's reproduction. It sends two actual synthesized `ui_accept` press/release pairs to the focused real pause or completion map button. **Both original reproductions now pass without the previously observed null-tree script error.** This is automated UI-event evidence, not physical input or human playtest evidence.

`res://src/tests/scripts/map_navigation_integration.gd` was run independently on the corrected source. It injects a scene-request failure at each caller, verifies focused retry and paused/completed state, then sends duplicate acceptance again and checks a successful real map replacement. It additionally checks replay input after a map request. **PASS.**

`reviewer_final_boundaries.gd` adds seven passing assertions: two consecutive injected failures at each caller cause exactly one scene request per duplicate selection; pause failures preserve inventory, hearts and recorded secrets while remaining paused; completion failures preserve inventory, hearts and completion; a competing real pause-to-menu action safely supersedes a queued map callback; replay requested before map suppresses the map request; replay after failed map navigation succeeds and retains completion. **PASS, no script errors.** This closes the initial review's untested pause/completion failure branches with independent fault injection. The injection returns the real error contract from an override; it does not establish every filesystem or loader failure mode.

Retained current-process commands and isolated environments are in `focused-with-boundaries-results.json`, produced by:

```sh
python3 -B /tmp/path-light-19-independent-final/run_boundaries.py
```

Its four processes use `/opt/Godot/Godot_v4.8-beta3_linux.x86_64 --headless --path <candidate> --script <script>`, with `-- pause` or `-- completion` for the original reproduction. **4/4 current focused scenarios pass.** Earlier direct reruns of the same three navigation scenarios also passed; they add no separate behavioral coverage.

Other checks observed in this review:

```sh
python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py
git diff --check
```

**4/4 Python runner tests passed; diff whitespace check passed.** These Python platform/subprocess mocks establish isolation/host-guard behavior, not native Windows/macOS Godot results.

## Evidence reuse and current full suite

The first independent review independently ran 24/24 baseline/map processes. Its source identity was `a2b4fa1f1888b0f02fa91de7c7cc410f970597bc941d20f27100eb92c6bc0483`; that overall verdict was FAIL due to the separately found P2. Comparison with this corrected source changes only `level.gd`, `pause_menu.gd`, the runner's new regression registration, the new regression script/UID and campaign-map evidence prose. Registry, map implementation, persistence implementation, actual scenes, original integration scripts and runner isolation are unchanged. All 48 original log hashes were rechecked successfully. This evidence remains regression context; it is not represented as an independent full-suite rerun of this corrected candidate. See `evidence-reuse.json`.

The implementation coordinator's completed corrected run, independently audited here, is **25/25, all_passed=true**, exact digest above. Its command is:

```sh
python3 -B src/tests/run_campaign_checks.py --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 --output docs/verification/issue-19/implementation --include-map
```

`implementation-results.snapshot.json` retains the completed machine report. `implementation-evidence-audit.json` records independent validation of all current log hashes, successful exits, empty script-error diagnostics and isolated `/tmp` XDG environments. The interrupted corrected run was not substituted for this completed evidence.

## Environment, preserved boundaries and limits

Engine: `4.8.beta3.official.c51ff06e8`; binary SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`; Linux. Every reviewer gameplay process used newly allocated `/tmp` `XDG_DATA_HOME`, `XDG_CONFIG_HOME` and `XDG_CACHE_HOME`; no real player storage was accessed. The Godot MCP server reports version `2026.11.04`, contract 1, disconnected bridge. CLI scene verification follows existing project conventions. Logs retain sandbox GameMode D-Bus errors and ObjectDB/resource cleanup warnings; passing tests are not a resource-leak-free or error-free editor claim. Intentional storage/restart injection diagnostics in the broader suite remain documented separately from GDScript failures.

Reviewed current AGENTS.md, GDD, roadmap, backlog E03-02, ADRs 0001/0004/0006 and source/tests. Published save IDs/schema remain intact; unknown saved IDs remain preserved without becoming routes. Solo entry and ordinary exit semantics are preserved. Optional secrets/assists, co-op requirements and the playable-slice scope gate remain intact. No expanded campaign content, external assets, telemetry or release claim was added by this feature.

No rendered screenshot inspection, listening session, physical controller test, child/accessibility evaluation, editor-driven live playtest, co-op, native Windows/macOS, web/export storage, exported executable or second machine was tested. Prior geometry assertions at physical root sizes 640×480 and 1152×648 remain bounds checks, not visual clarity or accessibility evidence. The four-level slice, expanded campaign, asset clearance and human/platform validation remain open. Any source change invalidates this exact-candidate verdict and requires appropriate reverification.
