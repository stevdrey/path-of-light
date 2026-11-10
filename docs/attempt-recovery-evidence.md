# Attempt recovery evidence — E02-02 / issue #16

Recorded 2026-11-09 for [issue #16](https://github.com/stevdrey/path-of-light/issues/16). This is automated evidence for the two-level solo prototype, not a human playthrough or release validation.

## Candidate and environment

Base commit: `57b2771e0d2188140d54246e758d575544040987`. The candidate is the working-tree diff and new files on `16-e02-02-implement-attempt-recovery-and-depletion-rules`; no commit or PR was created. The source-manifest identity below excludes this self-referential evidence note. Changes and their rationale are in [ADR 0004](adr/0004-attempt-recovery.md).

Godot `4.8.beta3.official.c51ff06e8`, Linux `7.2.15-300.fc45.x86_64`, x86-64, Compatibility project configuration, headless execution using the existing imported asset cache. Executable: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Each script used separate temporary XDG data/configuration directories. No player settings were changed.

## Checks

All 31 integration scripts in `src/tests/scripts/*.gd` exited 0. Their logs contained no assertion failures, `FAIL:` messages, parse errors or script errors. They include the 28 existing scripts and the three additions below. Eleven logs reported resources still in use at exit; ObjectDB leak warnings and an unavailable GameMode D-Bus were also reported. These are not error-free runs. Similar cleanup diagnostics exist in the prior baseline; their causes were not resolved by this issue.

| New script | Exercised behavior |
| --- | --- |
| `attempt_recovery_integration` | Both real level scenes: diamond/key pickups (including level-two key crate), hit immunity, fall damage during immunity, last-safe-point recovery, inventory retention, movement-state cleanup, heart pickup/cap, lethal fall/contact, rejection of damage/healing/inventory after defeat, paused defeat timer, current-level retry, restored pickups/crates, full health, prior totals/records and duplicate manual restart. |
| `safe_point_recovery_integration` | All 15 authored points: grounded contact, actual terrain support and sampled damage-free landing/recovery, no airborne or skipped-point activation, and no checkpoint regression on backtracking. |
| `recovery_records_integration` | Real secret portal and exit transitions, normal lower-room entry, nonlethal and lethal falls below the secret room, retained discovery after retry, attempt reward reset, main-route completion without a secret, level-one completion retained after level-two depletion, and both completion records retained after replaying the final level. |

The existing health, fall, level-two inventory, portal, door, pause, crate, obstacle, beetle, jump-assist and two-level transition checks were included in the full run. Scripts often position actors or invoke handlers directly; they do not prove unaided discovery or a complete human-operated route.

The first safe-point test failed at `(5500, 548)` in level one: the character did not settle on a floor there. A terrain inspection found nearby supported ground at `(5540, 548)`. After that correction, all 15 points and the complete suite passed their assertions. The first new inventory test also encountered a test-harness error when treating a pickup-effect node as an item; it was corrected to filter `CollectibleItem` nodes before the passing full run.

## Reproduce

Use an imported checkout with the engine above. Inspect the logs as well as exit codes. For an individual script:

```sh
XDG_DATA_HOME=/tmp/path-of-light-16-check/data \
XDG_CONFIG_HOME=/tmp/path-of-light-16-check/config \
timeout 90 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/attempt_recovery_integration.gd
```

Run every `.gd` in `src/tests/scripts/` with the same command and a separate XDG directory per script. The recorded full run used four processes with isolated user data. Temporary logs and JSON outcomes are in `/tmp/path-of-light-16/suite/`; these are local artifacts, not versioned or guaranteed to persist.

## Remaining limitations

The MCP editor bridge reported disconnected, with port 9080 already in use. Command-line tests were used; no editor-driven visual or input session was possible. No human visual/audio review, physical controller test, accessibility evaluation, child playtest, co-op test, clean import, export, second OS/device or web storage test was performed. Checkpoint placement and feel need human evaluation. No new assets or telemetry were added. Asset release clearance remains outstanding.

Secret visits and completed levels survive in-process retries and scene changes only. Closing and reopening the game still loses them; versioned disk saves remain E03-01 and ADR 0001 stays proposed. Co-op depletion/revival and assist configuration are not implemented by this change. Independent verification is reported separately against the final candidate; the automated implementation checks above are not independent review.

Source manifest SHA-256 (all tracked and untracked non-ignored files except this note): `c52d2c6df373fe17c022616716e4baeeee29b96520be716d48d82fb509251955`.
