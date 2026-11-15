# Issue #20 / PR #50 review follow-up — independent verification

Date: 2026-11-15. Verifier: separate verification agent, with no implementation edits or publication authority. Review followed `.agents/skills/independent-implementation-verification/SKILL.md`, the root agent instructions, GDD, roadmap, E03-03, ADRs 0001/0006/0007 and applicable Godot skills.

## Exact candidate and scope

Published comparison base and checkout HEAD: `2c8944d9e2b7cf6b30e129be9945408e027df0aa`. Candidate: the working tree, including the two untracked reward-script UID sidecars. Independently computed source manifest: `4a2b3a288e2bda09fa464d96291e57fe7868daaaef46d1b88e23d74bf37e3b11`, covering 431 files. The full per-file hashes are in [results.json](results.json); [manifest-after.json](manifest-after.json) records the final comparison. The manifest hashes the sorted JSON mapping of Git tracked/untracked nonignored file paths to SHA-256 values, excluding `docs/verification/`. Generated reports are evidence, not part of that source identity. This verdict applies only to those source bytes; subsequent source edits require revalidation.

The review covered the entire source/documentation delta from the base: `campaign_rewards.gd`, `campaign_save.gd`, `game_progress.gd`, `level_map.gd`, the three altered storage/failure/reward integration scripts, both UID files, ADR 0007 and the reward evidence document. It also inspected the real portal and completion call sites, registry/map/navigation and attempt state boundaries. Historical evidence changes were not treated as independent proof of current behavior.

## Verdict and acceptance criteria

**PASS for the explicitly scoped persistence and review-follow-up candidate. No actionable correctness defect was found in the reviewed delta.** This does not approve release, authored campaign content, character selection or human usability.

| Criterion | Status | Independent evidence |
| --- | --- | --- |
| Review finding 1: show locked versus restored prototype unlock, preserving selector unavailability; test both states | PASS | `level_map.gd` tests the exact `prototype` identity in `character_unlocks`. The reward cold-restore process verifies the unlocked text and explicit selector-unavailable message. The checks process verifies locked text with only an unrelated character ID. The separate [independent-extra.gd](independent-extra.gd) repeats both states and confirms the records log contains only its return button. |
| Review finding 2: numeric secret 1 grants only its explicitly mapped discovery; negative same-level regression | PASS | The production reconciliation calls `Rewards.discoveries_for_secrets`, which requires `legacy_secret_level`; chamber metadata alone maps secret 1. The altered regression includes an unmapped same-level discovery and another same-level discovery mapped to secret 2. Neither is granted by secret 1; empty secrets grant nothing. The independent extra check separately exercises the helper and real v1 `GameProgress.load_campaign()` → save path, preserving exactly `secret-chamber-1` despite unknown numeric secret 99. |
| Retain secrets/discoveries, world rewards and prototype unlock | PASS within accepted persistence boundary | The actual portal autosaves its numeric and discovery records. Schema 2 retains independent collections and unknown well-formed IDs. Synthetic authored completion fixtures grant and durably restore world/prototype IDs. Empty production finale definitions grant nothing for the experimental routes, including after legacy load. |
| Reload and replay | PASS | Separate fresh write/restore processes cover real portal/exit saves and all reward collections. Cold menu startup, map replay, real level retry, repeated-event no-rewrite behavior, depletion, assist combinations and clean attempt inventory all pass. Attempts are not restored across application restarts. |
| Exact build, evidence and limits | PASS | Before/after source manifest, engine hash, full commands, isolated environment paths, raw stdout/stderr and outcomes are retained in this directory. Current evidence/documentation distinguishes synthetic policy tests from production content and human/platform results. |

## Source review of the additional local draft delta

The save refactor serializes the normalized `_decode` result once for the new primary, enforces the same complete-document byte limit, and passes serialized strings to `_stage`. Previous-primary backup text still originates from a successful validated `_read`. All `_stage` overrides/call sites use the new signature. Staging still flushes, checks errors, closes and compares exact reread text before promotion. Reusing the initial validated primary/backup reads for archive decisions preserves the documented one-local-writer model; archive copying still validates the copied legacy format and exact original bytes before promotion. The full storage checks exercise failed primary/backup staging and promotion, v0/v1 archives, corrupt/future protection and retry.

`CampaignSave.REWARD_FIELDS` is consistently reused for load/save iteration; `_collection` covers all three fields. Iterating the policy output reaches only its two authored reward collections. Removal of the unused `record_discovery` API leaves no callers; discovery grants now follow explicit authored mappings. World labels use authored `title` metadata rather than exposing saved IDs; production world definitions remain empty, so no hypothetical world UI content was represented as tested. Both added UID strings occur only in their respective sidecars.

The records notice is initialized before `refresh`, follows the current save notice/error state on refresh and disappears when empty. The independent extra test covers failure → recovery → clear refresh in both unlock states. Existing reward verification also checks cancel/focus restoration and log geometry at 640×480 and 1152×648. No scene, input-map, physics, asset or co-op behavior was authored by this delta.

## Executed checks and environment

Engine: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, `4.8.beta3.official.c51ff06e8`, SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Host: Linux `7.3.3-300.fc45.x86_64`, glibc 2.44. Every engine test used newly allocated XDG data/config/cache directories under `/tmp`; restart pairs deliberately reused only their own fixture storage. No player storage was used.

Commands independently executed from the repository root:

```sh
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output docs/verification/issue-20/review-followup/independent
python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py
git diff --check
```

The extra GDScript was run with the same engine using `--headless --path <repository> --script /tmp/issue20-independent-extra.gd`; exact arguments and XDG paths are retained in [independent-extra.json](independent-extra.json), and its executed script bytes are retained as [independent-extra.gd](independent-extra.gd). It passed 15 assertions. The Python isolation suite passed all 4 tests; `git diff --check` passed with no output. The Python tests use mocks and do not establish native non-Linux isolation.

The independent runner passed **29/29 processes**, each with exit code 0 and no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostics. Exact per-process commands, environments, assertions and log hashes are in [results.json](results.json). Reward modes reported: PASS: rewards --checks 39 assertions; PASS: rewards --write 3 assertions; PASS: rewards --verify 11 assertions.

| Executed group | Outcome |
| --- | --- |
| Storage and failure injection | 1/1 PASS |
| Cold campaign/legacy restart | 5/5 PASS |
| Protected/recovered/save-failure gameplay | 4/4 PASS |
| Recovery, assists and scene regression | 9/9 PASS |
| Map/reload/navigation | 7/7 PASS |
| Reward policy/storage/real-write/cold-restore | 3/3 PASS |


## Boundaries and remaining validation

The MCP health/server-info calls reported bridge disconnection and a port-9080 bind conflict. No editor-driven runtime inspection or editor parse scan was possible. CLI runs loaded and exercised the affected scripts/scenes without script, parse or assertion diagnostics. Logs still contain GameMode D-Bus connection errors, ObjectDB/resource cleanup warnings, and deliberately injected file/navigation failures. This is not a claim of warning-free execution or resource-lifetime correctness; raw logs retain those diagnostics.

Production world/campaign finales, post-ending paths and playable character selection are deliberately absent under the user's scope decision. Synthetic fixtures establish policy and persistence, not a finished campaign or selectable character. Secrets and assists remain optional and do not gate completion rewards. Unknown saved IDs survive storage without creating content. Only one local writer is supported; concurrent writers, power-loss/fsync guarantees, cloud sync and destructive campaign reset remain outside the save contract.

No screenshot/render inspection, listening session, physical controller, human/child/accessibility playtest, co-op, native Windows/macOS, browser storage/export, exported executable or second-machine test was performed. Those results are unverified, and the playable-slice and asset-clearance gates remain open. No new assets, external facts or real telemetry were introduced. No source was changed, pushed or merged, and no external comments/messages were published by this verifier.
