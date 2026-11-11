# Accessibility assist evidence — E02-03 / issue #17

Updated 2026-11-10 for [issue #17](https://github.com/stevdrey/path-of-light/issues/17) and [PR #47](https://github.com/stevdrey/path-of-light/pull/47). This records automated verification of the two experimental solo levels, not human accessibility evaluation or release approval.

## Current candidate and identity

PR base: `b16210a935a374398c7e9ea57d56794efb60e304`. The runtime and test candidate independently executed for this follow-up is **`1745eaa29410540b3876b711f3ba1fb0f160e944`**, Git tree **`2ef79f6878bc6462bd44755e0eab86162bee4c15`**. This includes the five post-review fixes; the earlier `7a6a7cb` review does not verify it.

The committed [candidate manifest](verification/issue-17/candidate-1745eaa.json) identifies every file in that historical commit: **391 files**, canonical path-to-SHA-256 dictionary digest **`243ba046eb32fc04a70b2a745689b1d7a7c76d4dbcddd99a2e4a4199ee565858`**. The **390 source files excluding this evidence note** have digest **`9f994cf226ffa29712865dc31890a0d39ce73861ff997e383331c7a4e94137fc`**. Both identities were independently reproduced before and after the focused executions.

This publication changes only this note and files under `docs/verification/issue-17/`; runtime scripts, tests, scenes, settings and assets remain byte-identical to `1745eaa`. The PR description records the final publication commit/tree and complete candidate digest after documentation integration is independently revalidated. This avoids embedding a commit hash in a document that belongs to that same commit. See the [artifact index](verification/issue-17/README.md) for verification and reproduction instructions.

## Environment

Godot `4.8.beta3.official.c51ff06e8`, Linux x86-64, headless with the existing imported asset cache and Compatibility project configuration. Executable `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Every script uses fresh XDG data/config/cache directories; only the deliberate settings write/restore pair shares them. The player's real preferences were not used or modified. These are local runs, not GitHub Actions, clean-import or export results.

## Fresh checks and their provenance

| Producer | Actually executed against `1745eaa` | Result and durable evidence |
| --- | --- | --- |
| Implementing/coordinating agent | All 35 integration scripts serially, then a second-process settings restore | **36/36 process invocations exited 0**, including **35/35 integration scripts**. No failure, script, parse or assertion diagnostics. [Implementation run report](verification/issue-17/implementation-results.json) records commands, results, pass lines, log hashes and diagnostics; its full raw logs remain temporary local files. |
| Fresh independent verifier | Settings write/restore, assist recovery, assist UI, restart lifecycle, standard fall depletion, attempt recovery, recovery records, plus an independently authored supplemental script | **9/9 process invocations exited 0**, with no confirmed functional findings. The supplement passed **58 assertions**. [Independent runtime review](verification/issue-17/independent/review-report.json), its 18 stdout/stderr logs and the supplemental source are committed. This verifier did **not** independently execute the full 35-script suite. |

The independent runtime report preserves its preliminary status: implementation PASS, durable evidence integration still pending when that report was written. The separate final integration verdict linked from the artifact index supersedes that pending status after reviewing these published files and the new exact candidate. Independent execution, inspection of another agent's run records and final documentation revalidation are distinct activities.

Diagnostics remain visible. The 35-script implementation suite has GameMode D-Bus messages in 35 logs, ObjectDB exit warnings in 33 and resources-in-use diagnostics in 15; lifecycle fault injection deliberately emits three rejected reload/replay warnings. Its second-process restore also reports GameMode and ObjectDB diagnostics. The nine independent runs have GameMode messages in nine logs, ObjectDB warnings in eight, a resources-in-use diagnostic in one, and three deliberate restart warnings. These are not diagnostic-free runs. `git diff --check` passed for the runtime candidate and is checked again for the documentation publication.

## Acceptance mapping

| Requirement | Verified behavior |
| --- | --- |
| Independent configurable assists | Three default-off Boolean switches from initial-menu **OPCIONES → AYUDAS** and **Esc → AYUDAS**. Five hearts instead of three, seven/eight additional authored points, and falls without heart loss. Options apply during an attempt and persist with local audio/keyboard preferences. |
| No content penalty | Source/call-site review and executed secret/door transitions retain diamond rewards, keys, score, discoveries and completion eligibility. Contact damage can still deplete hearts and restart the level. |
| Normal and assisted recovery | All eight assist combinations on both actual levels; all 15 extra points checked for airborne rejection, grounded activation and return; main/secret falls, inventory/records, contact depletion and full-health same-level retry. |
| Post-review health and retry changes | Repeated heart-cap toggles do not heal at low health; hidden missing hearts survive the real exit and are cleared on retry. Reset/restore APIs use the configured cap. The independent supplement checks every living heart state, repeated toggles, healing/reset boundaries and suppressed fall-feedback state. |
| Input and HUD follow-up | Shared Volver/Escape handling, pause retention, focus restoration and cached HUD textures. The independent supplement injects physical-key Escape events in initial-menu and paused assist panels; these are synthetic inputs, not hardware or human observations. Geometry checks cover Options at 1152×648 and the assist panel at 640×480. |
| Preference compatibility | Fresh-install defaults, old/malformed assist fields, unknown keys, restoring controls without resetting assists, audio/key coexistence and restoration in a second process. |

See [ADR 0005](adr/0005-configurable-assists.md) for prototype rules and provisional balance decisions. Settings persistence does not persist inventory, visited checkpoints or session secret/completion records as campaign saves.

## Reproduce

Use the engine above in an imported checkout; run the historical commit for an exact runtime comparison, or confirm that a later publication changes only the evidence paths listed above. Commands and environment entries for each independent invocation are retained in its report. Use **new** XDG directories for a rerun; only the deliberate persistence pair should share them. For example:

```sh
verification_root="$(mktemp -d /tmp/pol17-verification.XXXXXX)"
XDG_DATA_HOME="$verification_root/recovery/data" \
XDG_CONFIG_HOME="$verification_root/recovery/config" \
XDG_CACHE_HOME="$verification_root/recovery/cache" \
timeout 150 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/assist_recovery_integration.gd
```

Run the settings script twice with one fresh settings directory, adding `-- --verify-persisted` to the second invocation. Run each other integration script with its own fresh directories. The artifact index explains how to reproduce the supplemental assertions and canonical manifest digests. Current local full-suite logs are under `/tmp/path-of-light-17-followup/implementation/`; only the independent logs are committed, and temporary paths are not hosted evidence.

## Historical checks and corrected failures

The `7a6a7cb` candidate previously passed an implementation 35-script run and separate focused verification. Its source digest `a2020c71e4371fe3633852cb7faf6a047bc1b6990add98cbc00566e176e17f53` and whole-candidate digest `2e2c6be1dd51174f4ec9a72f237e0e1527040f78b9e0d19cc844bce795c5db4d` are **historical only**. They are superseded by the current identities and fresh checks above.

The `1745eaa` follow-up records five changes: hidden missing hearts prevent off/on healing and survive exits; `GameProgress` owns configured reset/retry health; Escape returns from assists to the pause list; the shared panel owns Volver/back handling; and the HUD caches full/empty heart textures. The current runs execute those extended tests rather than reusing the earlier verdict.

During initial implementation, checks rejected a point near a saw, ground-height points inside raised platforms and a gap placement. Earlier runs also exposed early-autoload compilation and an old lifecycle assertion that used physics frames before deferred menu replacement finished. These were corrected before the original final suite. No baseline reproduction of that timing failure is claimed. No new failure was observed in the fresh follow-up runs recorded here.

## Remaining limitations

The MCP bridge remains offline with port 9080 already occupied. Neither this follow-up nor the independent reviewer performed an editor-driven session, rendered screenshot/readability review, audible playback check or human playthrough. The earlier graphical launch could not access X11 or Wayland. Automated placement, handlers, geometry and synthetic keys do not demonstrate an unaided route, human navigation or hardware input.

Checkpoint feel and balance, visual/audio quality, controller navigation, child accessibility, co-op, another OS/device, clean import, exports and web storage remain unverified. The three/five-heart balance and point placement await human evaluation. A full human playtest is not represented as completed or required by this scoped verification follow-up.

No runtime, asset or telemetry changes are made by this evidence update. Campaign saving, co-op recovery, the playable-slice scope gate and existing asset release-clearance gaps remain separate work. The independent technical verdict is not a GitHub approval or permission to merge/release.
