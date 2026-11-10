# Attempt recovery evidence — E02-02 / issue #16

Updated 2026-11-10 for [issue #16](https://github.com/stevdrey/path-of-light/issues/16) and [PR #46](https://github.com/stevdrey/path-of-light/pull/46). These are automated checks of the two-level solo prototype, not a human playthrough or release validation.

## Candidate and environment

PR base: `57b2771e0d2188140d54246e758d575544040987`. This verification covers the review follow-up based on `79c920f33fc664de0450b3b2f01969cf7992e715`, identified by the source manifest below. The final publication commit/tree and independent verdict are recorded in the PR description; older reviews of `0878ca1` do not establish verification of this candidate. The source manifest excludes this self-referential note. See [ADR 0004](adr/0004-attempt-recovery.md) for decisions and [architecture/state](wiki/Architecture-and-state.md) for ownership.

Godot `4.8.beta3.official.c51ff06e8`, Linux x86-64, Compatibility project configuration, headless execution using the existing imported asset cache. Executable: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Each script used separate temporary XDG data/configuration directories. No player settings were changed.

## Current checks

The full serial run of all **32 integration scripts** in `src/tests/scripts/*.gd` exited 0, with no assertion failures, `FAIL:` messages, parse errors or script errors. Fourteen logs reported resources still in use at exit and 30 mentioned ObjectDB warnings; unavailable GameMode D-Bus diagnostics also occurred. The lifecycle fault-injection test deliberately emitted three restart-failure warnings for its three rejected scene requests. These are not diagnostic-free runs. `git diff --check` passed.

| Recovery script | Exercised behavior |
| --- | --- |
| `attempt_recovery_integration` | Both real levels: diamond/key pickups and key crate, hit immunity versus fall damage, safe-point recovery, movement-state cleanup, healing/cap, lethal fall/contact, rejection after defeat, paused defeat, current-level retry, restored pickups/crates, prior totals/records, duplicate restart, pickup accounting while exiting and while restarting. |
| `safe_point_recovery_integration` | All 15 authored points: grounded activation and sampled supported recovery, no airborne activation, forward-window activation versus landing beyond it, and no checkpoint regression on backtracking. |
| `recovery_records_integration` | Secret portal and exit transitions, secret-room falls and depletion, discovery retention versus attempt reward reset, completion without a secret, earlier completion retention after level-two depletion, and replay input on the final screen starting level one with both completion records retained. Both exit paths use the shared completion-recording helper. |
| `restart_lifecycle_integration` | Injected reload failures during a live attempt and after depletion, inventory/health rollback, visible error, available pause/retry, later successful restart, failed final-screen replay and later successful replay, returning from both levels to the menu and pressing JUGAR, and the explicit full-reset API. |

The existing health, fall, inventory, portal, door, pause, crate, obstacle, beetle, jump-assist and two-level transition checks were included. Scripts often position actors or invoke handlers directly; they do not establish unaided discovery, checkpoint feel or a full human-operated route.

## Record lifetime and failed requests

`GameProgress` owns secrets/completions for the running process. Returning to the menu and choosing **JUGAR** starts another attempt from level one and retains these records. It is not a destructive new campaign, and the current UI has no such action. A future explicitly named fresh campaign must use `GameProgress.reset()`. Closing the game currently loses these records; disk persistence remains E03-01. No album or unlock behavior is asserted.

If a deferred reload is rejected, the still-live scene recovers its pre-request inventory and actual health, clears pending restart/input locks, reports the problem and permits retry or pause/menu. A defeated character remains defeated until retry succeeds. A rejected final-screen replay retains the completion screen and its replay input. Tests inject `ERR_CANT_CREATE` at the scene-request boundary; they do not corrupt/remove real scene files.

## Portal timing investigation

The previous five-physics-frame check could run before its parsed key event was dispatched. A controlled `--fixed-fps 1` run reproduced the old failure **3/3 on the original PR base** (`57b2771`) and **3/3 on the pre-fix PR head** (`79c920f`). The baseline was populated with `git archive`, with the same existing imported cache and asset import metadata copied into an isolated directory. This is a source comparison using the same cache, not a clean-import claim. No baseline process timed out.

A diagnostic trace sampled the failure condition while `portal_transitioning=false`, `jump_pressed=false` and vertical velocity was zero; no process frame had advanced between dispatch and the five sampled physics steps. At a higher controlled frame rate, the trace observed the buffered input arriving on a later process frame and the jump starting afterward. The old error text incorrectly called both an activated portal and a jump that had not started a portal activation.

The test now calls `Input.flush_buffered_events()` after parsing the press, confirms that jump input arrived, and then bounds the movement response in physics steps. It distinguishes unexpected portal activation from a missing jump, prints position/velocity, floor, input, locks, control mode, portal eligibility and process/physics counters on failure, and releases the key after success. Production portal/input behavior is unchanged by this fix.

The corrected test passed **41/41 additional runs**: four repeats at each fixed FPS of 1, 5, 10, 15, 30, 60 and 120 (28 runs), five normal serial repeats, and eight normal repeats with four concurrent processes. The full 32-script serial run also passed this test. This establishes the sampled timing conditions; it does not prove universal determinism. The original intermittent failure was not traced when it happened, so identity with that earlier event is not proven, but the five-physics-frame assumption is demonstrably unsound and directly corrected.

## Reproduce

Use an imported checkout and the engine above. Inspect diagnostics as well as exit codes. Example commands:

```sh
XDG_DATA_HOME=/tmp/path-of-light-16-check/lifecycle-data \
XDG_CONFIG_HOME=/tmp/path-of-light-16-check/lifecycle-config \
timeout 90 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/restart_lifecycle_integration.gd

XDG_DATA_HOME=/tmp/path-of-light-16-check/portal-data \
XDG_CONFIG_HOME=/tmp/path-of-light-16-check/portal-config \
timeout 90 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --fixed-fps 1 \
  --script res://src/tests/scripts/portal_nearby_collectible_integration.gd
```

Run every `.gd` in `src/tests/scripts/` serially with separate XDG directories for the full suite. Repeat the portal command with FPS 1, 5, 10, 15, 30, 60 and 120; omit `--fixed-fps` for normal serial/concurrent repeats. The old test at the PR base or `79c920f` reproduces the failure with FPS 1; the corrected test at the current candidate passes it.

Temporary logs and machine-readable outcomes are under `/tmp/path-of-light-16-followup/`: `suite/results.json`, `portal-baseline-comparison.json`, `portal-fixed-comparison.json`, `portal-normal-comparison.json`, and their per-run logs/trace files. These local artifacts are not hosted attachments or guaranteed to persist. Independent verification is reported separately in the PR description against the final candidate; the checks in this note are implementation checks.

## Historical checks and remaining limitations

The first candidate (`0878ca1`) passed 31 scripts and an independent review. The subsequent `79c920f` follow-up passed a 31-script serial run but recorded an unexplained portal-test failure during an earlier run; that uncertainty prompted the investigation above. Its previous independent PASS did not cover the later changes. The unsupported first-level safe point at `(5500, 548)` was corrected to `(5540, 548)` after a terrain test failed. Initial fixture mistakes in earlier safe-point and pickup tests were corrected before their reported passing runs.

The MCP editor bridge reported disconnected, with port 9080 already in use. No editor-driven visual or input session was performed. Human checkpoint traversal/feel, visual/audio/controller/accessibility/child/co-op playtesting, a full unaided route, clean import, export, second OS/device and web storage testing remain unperformed. Automated placement checks cannot replace these. No new assets or telemetry were added, and asset release clearance remains open. Versioned campaign saves, assist configuration and co-op recovery remain separate work.

Source manifest SHA-256 (all tracked/untracked non-ignored files except this note): `23d750cf17c9d3c841f65cfbcb7c4b2632c67e5192d5e4ffcb735173155268cf`.
