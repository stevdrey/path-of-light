# Accessibility assist evidence — E02-03 / issue #17

Updated 2026-11-10 for [issue #17](https://github.com/stevdrey/path-of-light/issues/17). This evidence covers the two experimental solo levels, not the proposed campaign or a human accessibility assessment.

## Candidate and environment

Base commit: `b16210a935a374398c7e9ea57d56794efb60e304`. Candidate: the working-tree changes on branch `17-e02-03-add-configurable-accessibility-assists`, including the new assist scripts, test scripts, their UID files and documentation. The source manifest below identifies the files under test without requiring a self-referential commit. See [ADR 0005](adr/0005-configurable-assists.md) for rules and provisional balance decisions.

Godot `4.8.beta3.official.c51ff06e8`, Linux x86-64, headless execution with the existing imported cache and Compatibility project configuration. Executable: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`; SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Tests use separate temporary XDG data/configuration directories; they do not modify the player's real settings. This is not a clean-import or export check.

Source manifest SHA-256 (all tracked/untracked non-ignored files except this note): `a2020c71e4371fe3633852cb7faf6a047bc1b6990add98cbc00566e176e17f53`.

## Final implementation checks

The final serial run of all **35 integration scripts** exited 0, with no `FAIL:`, script errors, parse errors or assertion failures. The deliberate second-process settings verification also exited 0. `git diff --check` passed. Logs and machine-readable results are in `/tmp/path-of-light-17/suite-final/`, including `results.json` and `settings-second-process.log`.

These are not diagnostic-free runs: 35 suite logs report unavailable GameMode D-Bus access, 33 report ObjectDB exit warnings and 13 report resources still in use at exit. The lifecycle test deliberately reports three rejected reload/replay warnings. The initial suite's lifecycle compile failure timed out (exit 124); its results are under `/tmp/path-of-light-17/suite/`. Only the fresh final suite covers the corrected candidate throughout.

A separate verifier reproduced the source digest and independently reran the recovery matrix, UI/live changes, settings write and second-process restore, restart lifecycle and standard fall depletion, all with exit 0. Its logs are under `/tmp/path-of-light-17/independent/`. The final acceptance verdict is reported separately against the complete candidate including this note; the source digest above deliberately excludes this self-referential document. None of these checks is a human playtest.

## Post-review fixes

A later code review of PR #47 found five issues, all corrected on this branch after the candidate above:

1. Disabling extra hearts at low health and enabling it again healed the player (1/5 → 1/3 → 3/5). Missing hearts hidden by the one-heart minimum are now remembered, carried across level transitions and cleared on retry.
2. `GameProgress.reset_attempt()`/`restore_inventory()` hardcoded three hearts; they now use the configured cap, and the per-caller overrides were removed.
3. Esc inside the pause AYUDAS panel resumed gameplay; it now returns to the pause list.
4. The menu and pause hosts each added the panel's Volver button and open/close logic; the shared panel now owns Volver, Esc-to-back and a `closed` signal.
5. The HUD allocated new heart textures on every health update; it now reuses two cached textures.

`assist_ui_integration.gd` adds the off/on round trips (1/5 and 2/5), hidden missing hearts across the real exit, and simulated Esc in pause AYUDAS; `assist_recovery_integration.gd` relies on `GameProgress.reset()` for configured hearts and checks cached HUD textures. These checks are headless; the Esc behaviour and HUD were not reviewed visually or with a controller. The source digest above refers to the pre-fix candidate.

## Acceptance evidence

| Requirement | Evidence |
| --- | --- |
| Extra hearts, checkpoint frequency and no fall damage | Three independent default-off switches, saved with existing audio/control settings. The menu and pause both expose the same panel. Extra hearts provides five instead of three; frequency adds 7/8 supported authored points; no fall damage retains relocation without heart loss. |
| No content penalty | The assisted UI integration exercises the real secret entry/exit, discovery record and diamond reward, first-level exit carrying score/hearts, and final completion. The settings do not change collectibles, key requirements, doors, score or recording conditions. The existing normal-route tests remain applicable. |
| Normal and assisted recovery | `assist_recovery_integration.gd` passes all eight option combinations on both real levels. It checks configured entry/HUD hearts, each extra checkpoint's airborne rejection, grounded activation and fall return, standard-frequency exclusion, both fall regions, inventory retention, contact depletion and full-health same-level retry with preserved records. |
| Live configuration | `assist_ui_integration.gd` checks menu/pause focus, paused gameplay, independent switches, missing-heart preservation, disabling at one heart, no revival during defeat, retained visited points after frequency changes/backtracking, and a cap change while a deferred retry is pending. It also checks Options bounds at 1152×648 and assist-panel bounds at 640×480; these are geometry assertions, not rendered visual review. |
| Local persistence and compatibility | `assist_settings_integration.gd` checks defaults, missing fields in old configurations, malformed field types defaulting off, unknown-key rejection, and coexistence with saved audio/key bindings. A second process with `--verify-persisted` restores all three assists, music volume and the chosen jump key. Restoring controls retains assists. |

## Reproduce

Use the engine above in an imported checkout. Run each script with fresh XDG directories, inspect diagnostics as well as exit codes, and retain the same directories only for the deliberate second-process persistence check.

```sh
XDG_DATA_HOME=/tmp/pol-17-recovery/data \
XDG_CONFIG_HOME=/tmp/pol-17-recovery/config \
timeout 120 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/assist_recovery_integration.gd

XDG_DATA_HOME=/tmp/pol-17-settings/data \
XDG_CONFIG_HOME=/tmp/pol-17-settings/config \
timeout 30 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/assist_settings_integration.gd

XDG_DATA_HOME=/tmp/pol-17-settings/data \
XDG_CONFIG_HOME=/tmp/pol-17-settings/config \
timeout 30 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script res://src/tests/scripts/assist_settings_integration.gd \
  -- --verify-persisted
```

Run `assist_ui_integration.gd` the same way with fresh directories. Run all `src/tests/scripts/*.gd` serially, each with its own fresh directories, for regressions. Local logs and machine-readable results are under `/tmp/path-of-light-17/`; these are temporary local artifacts, not hosted evidence or guaranteed persistent files.

To reproduce the source digest, enumerate the sorted unique paths from `git ls-files -co --exclude-standard -z`, excluding this note; compute each file's SHA-256, serialize the path-to-digest dictionary with Python `json.dumps(entries, sort_keys=True, separators=(',', ':'))`, then SHA-256 that UTF-8 JSON. The local `/tmp/path-of-light-17/source-manifest.json` records the per-file digests and base.

## Failures and limitations

Early placement checks rejected a point near a saw and points placed at ground height inside raised platforms; an additional candidate fell in a gap. The corrected candidate moves points away from hazards/gaps and places two level-two points at y=484 on their static platforms. The final checks exercise all 15 extra points; this does not establish balanced spacing, unaided discoverability or safety under every possible obstacle timing.

The first broader run exposed a compile failure when the lifecycle test's inherited level loaded before the `GameSettings` autoload identifier was available. Recovery scripts and the shared assist panel now resolve settings through `/root/GameSettings` when their nodes are ready. A subsequent lifecycle run exposed `current_scene == null` at the old test's menu assertion: five physics steps had not guaranteed completion of deferred scene replacement. The menu-return check now waits two process frames before its physics steps and assertions. The focused lifecycle rerun passes, including the deliberately rejected reload/replay requests; no baseline reproduction of the timing failure is claimed.

The MCP health check reports its bridge disconnected and port 9080 already in use. A graphical command-line launch also failed because neither X11 nor Wayland was accessible. No editor-driven input, rendered screenshot review or human playthrough was performed. Automated tests position actors and call handlers, so they do not demonstrate a complete unaided route. Human checkpoint feel, visual readability, audio, controller navigation, child accessibility, co-op, another OS/device, exports and web storage remain untested. The three/five-heart balance and checkpoint placement await human evaluation.

Settings persistence is local preference persistence only. Inventory, visited checkpoints and session secret/completion records are not disk saves. No telemetry or assets were added. Campaign saving, co-op recovery, the playable-slice scope gate and asset release clearance remain separate work.
