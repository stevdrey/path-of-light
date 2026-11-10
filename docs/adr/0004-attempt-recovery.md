# ADR 0004: Solo attempt recovery and session records

Status: Accepted for the scope of E02-02 · 2026-11-09

## Context

GDD section 6 requires nonlethal falls to retain attempt items, depletion to restart the current level and reset its items, and previously recorded secrets and completions to survive. The prototype restored level-two entry inventory but unconditionally cleared all progress on level-one entry. Its restart action always selected level one, and secret-room falls were ignored. Campaign persistence and co-op ownership are separate backlog work.

## Decision

Keep `GameProgress` in memory. Explicit attempt reset and inventory snapshot/restore methods exclude session secret/completion records. Record the existing secret chamber on portal entry, keyed by level number; record level completion when the exit transition finishes or the final celebration starts. These records are session facts, not campaign disk saves or a finished secret album. Explicit `GameProgress.reset()` clears everything for a full reset; gameplay retries use the attempt-only operations.

`GameProgress` owns these records for the running process. Returning to the menu and choosing **JUGAR** starts another level-one attempt within that session and retains discoveries/completions. The current menu does not offer a destructive new-campaign action. A future explicitly named fresh campaign must call `GameProgress.reset()`; the album/save implementation must preserve this distinction. Closing the application currently ends the record lifetime. These session records do not establish campaign unlock behavior. Both exit paths use `_record_level_completion()` as their single recording point.

Retry restores a deep copy of entry score, diamond totals/counts and keys, restores three hearts, and reloads the same scene. Level-one entry still clears attempt inventory; level two carries in earlier totals. Keys obtained during the failed attempt disappear, and scene reload recreates the key or its crate. Depletion and manual restart share one guarded, deferred reload path. Once a restart is pending, pickups cannot change the restored inventory; pickups during a door exit still count. On the final completion screen the restart action starts a new playthrough from level one, matching its on-screen prompt, and session records are retained. Pausing freezes the defeat countdown.

Check the deferred scene-change return code. If a retry cannot load, keep the live scene, restore its pre-request inventory and actual health, clear restart/input locks, display an error and allow another restart or the pause menu. A defeated player remains defeated until a successful retry; this avoids inventing a partial scene reset. If a final-screen replay cannot load, retain the completion screen and its replay input. Fault-injection tests cover both failure paths and a later successful request.

Activate an authored safe point when the player is grounded at its height (within 32 pixels) and horizontally from 32 pixels behind to 220 pixels ahead of it. The forward reach is wider than one jump (about 189 pixels), so jumping past a point still lands inside its window. Recovery always returns to the authored, supported point. Do not infer contact merely from horizontal progress. Keep the furthest visited point during backtracking. Move the unsupported first-level point at `(5500, 548)` to `(5540, 548)`. Main-route falls below y=820 and secret-room falls below y=1500 cost a heart, bypass hit immunity and recover at the last main-route safe point. Clear stale jump/climb state and reset camera smoothing on recovery. Portal/exit transitions remain protected from fall processing.

## Alternatives and tradeoffs

Serializing campaign progress here would overlap E03-01's versioning, corruption and migration decisions. Treating secret discoveries as attempt inventory would violate retention. Keeping the old horizontal checkpoint selection could choose a point the player never visited. A window limited to 32 pixels either side was rejected because ordinary jumps cleared it. The forward window can still be missed by landing beyond it, such as across a wide gap or on a platform at another height; checkpoint balance and presentation still require playtesting. The secret fall threshold is specific to the existing lower chamber and must be revisited if its layout changes.

## Evidence and boundaries

See [attempt recovery evidence](../attempt-recovery-evidence.md). This decision covers the two-level solo prototype. ADRs 0001 and 0002 remain proposed; no disk-save format, co-op recovery, assists, expanded campaign, telemetry or release approval is established here.
