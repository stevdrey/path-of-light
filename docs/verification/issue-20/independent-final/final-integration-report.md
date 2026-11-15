# Issue #20 final independent verification

Verdict: **PASS for the explicitly agreed persistence boundary.** Both initial findings are corrected. No remaining concrete defect was established in the reviewed candidate. Production world rewards and the campaign-completion prototype remain locked because no authored finales exist; this verdict does not approve future content or establish a completed campaign or selectable character.

## Exact candidate and independent method

- Base HEAD: `e8fb99943e505afb3932394ac47f7b304947a4e3`.
- Final tracked/untracked source manifest SHA-256: `a89ea2bdbba74b401f53d51de0580b78be7f06aef12791e130bb49b562af4789`; 429 files, excluding `docs/verification/`. `manifest-final-before.json` matches the implementation's per-file manifest. `manifest-final-after.json` verifies identical source after testing.
- Engine: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, `4.8.beta3.official.c51ff06e8`; SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`.
- Host: `Linux-7.3.3-300.fc45.x86_64-x86_64-with-glibc2.44`.

This separate verifier read AGENTS.md, the independent-verification and applicable Godot skills, GDD, roadmap, backlog E03-03, ADRs 0001/0006/0007, source, callers and tests. Source review covered storage validation/migration/recovery, GameProgress load/save/reconciliation, real portal/completion call sites, attempt resets, startup/retry and map/UI boundaries. The verifier did not edit candidate source, publish, merge or contact third parties. Canceled reviewer artifacts and implementation execution claims were not used as independent proof.

Compared with initial reviewed manifest `11704e48a4fc3d576c779091ea56397fc7bc399bbbe07255239fd52441d86f20`, precisely two source files changed: `src/tests/scripts/campaign_rewards_integration.gd` and `docs/campaign-rewards-evidence.md`. The verifier checked this per-file delta. The test now checks the panel **and back button** against `root.get_visible_rect()` at both physical window sizes, keeping logical coordinates consistent under stretch. The evidence page now points here; `canceled-context-review/README.md` explicitly disclaims the canceled attempt. Initial failing evidence remains in `initial-report.md` and its logs.

## Final executed evidence

All **eight independently rerun Godot processes passed**, with no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostics. Exact commands, temporary XDG roots, pass lines, return codes, durations and raw-log hashes are in [final-checks/results.json](final-checks/results.json). The reproducible selection driver is [run_final_checks.py](run_final_checks.py):

```sh
python3 docs/verification/issue-20/independent-final/run_final_checks.py
python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py
git diff --check
```

| Independently rerun check | Result and coverage |
| --- | --- |
| Campaign storage | PASS: validation, migration, backup recovery, newer-version protection and injected write failures. |
| Reward policy/storage | PASS: all required explicit finale levels, direct-finale rejection, empty production definitions, no-secret grants, v1 migration/archive/recovery, malformed/duplicate/oversized string IDs, total byte limit, unknown-ID round trip, unauthored discovery refusal and failed-write retry. |
| Reward write | PASS: real portal records the authored discovery, experimental completions grant no production rewards, synthetic rewards persist to the same save. |
| Reward cold restore | PASS: a fresh process restores all collections; unchanged events avoid rewrites; discovery log opens; panel/back button fit both logical viewports; cancel restores map focus; actual map replay and level retry retain reward records while clearing attempt inventory. |
| Level map and cold restore | PASS: real menu/map/level transitions, completion/availability guards, failure/retry, both exits, assists, retained completions and clean revisiting. |
| Map navigation | PASS: navigation failure and retry boundaries. |
| Front-end navigation | PASS: menu scene-request/focus/failure boundaries. |

Four Python runner isolation/refusal tests and `git diff --check` also passed; see [final-checks/non-engine-checks.json](final-checks/non-engine-checks.json) and adjacent logs. Those platform mocks do not establish native non-Linux behavior.

Every Godot fixture used newly allocated temporary XDG data/config/cache roots. Only deliberate write/cold-restore pairs shared their new isolated fixture; player storage was not used. The final independent check allocation is recorded under `/tmp/issue20-independent-final-*` in the machine-readable results.

The initial candidate's independently completed 18-case campaign/recovery suite remains additional regression evidence in `suite/results.json`. Its production files are byte-identical in the final candidate, so that evidence is relevant to unchanged recovery/assist/attempt behavior. The initial suite was intentionally interrupted after reproducing the failing new test; its unexecuted cases are not passes. This final report claims eight fresh selected engine processes, **not** an independent completed 29-process run. The current implementation run is a separate producer result.

## Acceptance mapping

| Issue criterion | Status | Evidence and precise scope |
| --- | --- | --- |
| Record secrets and discoveries | PASS | The real level-one portal calls `record_secret`; authored reconciliation records `secret-chamber-1`. Independent writer and cold restore prove disk retention and map display. Legacy numeric portal records reconcile only to authored discovery metadata. |
| Record world rewards and campaign-completion prototype unlock | PASS for authorized persistence boundary | Schema 2 retains independent world-reward/character-unlock ID collections. Pure policy requires every explicitly listed level and an explicit finale. Synthetic grant IDs survive a real second process and replay/retry. Production definitions remain empty by the explicit scope decision, so finishing the experimental routes grants none. No production campaign unlock or character-selection availability is claimed. |
| Verify reload and replay | PASS | Final reward write/restore pair reaches all assertions, including both viewport checks, cancel/focus, actual map replay, clean inventory and level retry retention. Final map cold restore and unchanged recovery evidence cover the associated entry/reset boundaries. |
| Record evidence, exact build and limitations; update documentation | PASS | The final manifest/engine identity and raw logs are retained here; project evidence links to this report. ADR 0007 and the GDD/README/wiki/backlog describe the narrowed boundary and deferred content. Canceled evidence is explicitly identified. |

## Findings resolved and remaining limits

The initial viewport defect was in the test's physical/logical coordinate comparison. The independent geometry probe showed a physical 640×480 window uses a logical 1152×864 viewport, with the panel inside it. The corrected candidate now passes both logical containment checks and all previously unreachable restore/replay assertions. The canceled-review documentation pointer is corrected. Neither initial finding remains open for this exact manifest.

Storage remains data-only: unknown well-formed IDs survive without supplying scene paths, metadata or playable characters. Secrets, diamonds and assists do not gate reward eligibility or the solo route. Durable facts remain separate from transient inventory and are retained through resets and failed writes. No changed scene/input binding, new asset or telemetry collection was found in this candidate. The existing one-local-writer and filesystem durability limits remain.

The MCP bridge was disconnected at independent inspection, so no editor-driven playtest was run. No human visual/audio/controller/child/accessibility evaluation, co-op test, exported executable, browser storage/export, native Windows/macOS, second-machine, fault-injected power-loss or asset-clearance result is claimed. Geometry/state/focus assertions are not proof of human readability or discoverability. Authored finales, reward presentation, the prototype selector, the larger discovery album and post-ending paths remain future content. The playable-slice and release gates remain open.

Raw logs retain the sandbox GameMode D-Bus failure, ObjectDB/resource cleanup messages and expected fault-injection file diagnostics. The stated script/parse/assertion results do not imply clean resource shutdown or an error-free editor session.

Any source change invalidates this exact-candidate verdict and requires revalidation.
