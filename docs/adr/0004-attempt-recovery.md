# ADR 0004: Solo attempt recovery and session records

Status: Accepted for the scope of E02-02 · 2026-11-09

## Context

GDD section 6 requires nonlethal falls to retain attempt items, depletion to restart the current level and reset its items, and previously recorded secrets and completions to survive. The prototype restored level-two entry inventory but unconditionally cleared all progress on level-one entry. Its restart action always selected level one, and secret-room falls were ignored. Campaign persistence and co-op ownership are separate backlog work.

## Decision

Keep `GameProgress` in memory. Explicit attempt reset and inventory snapshot/restore methods exclude session secret/completion records. Record the existing secret chamber on portal entry, keyed by level number; record level completion when the exit transition finishes or the final celebration starts. These records are session facts, not campaign disk saves or a finished secret album. Explicit `GameProgress.reset()` clears everything for a full reset; gameplay retries use the attempt-only operations.

Retry restores a deep copy of entry score, diamond totals/counts and keys, restores three hearts, and reloads the same scene. Level-one entry still clears attempt inventory; level two carries in earlier totals. Keys obtained during the failed attempt disappear, and scene reload recreates the key or its crate. Depletion and manual restart share one guarded, deferred reload path. Pausing freezes the defeat countdown.

Activate authored safe points only on grounded contact within 32 pixels; do not infer contact merely from horizontal progress. Keep the furthest visited point during backtracking. Move the unsupported first-level point at `(5500, 548)` to `(5540, 548)`. Main-route falls below y=820 and secret-room falls below y=1500 cost a heart, bypass hit immunity and recover at the last main-route safe point. Clear stale jump/climb state and reset camera smoothing on recovery. Portal/exit transitions remain protected from fall processing.

## Alternatives and tradeoffs

Serializing campaign progress here would overlap E03-01's versioning, corruption and migration decisions. Treating secret discoveries as attempt inventory would violate retention. Keeping the old horizontal checkpoint selection could choose a point the player never visited. Grounded proximity can skip a checkpoint jumped over; checkpoint balance and presentation still require playtesting. The secret fall threshold is specific to the existing lower chamber and must be revisited if its layout changes.

## Evidence and boundaries

See [attempt recovery evidence](../attempt-recovery-evidence.md). This decision covers the two-level solo prototype. ADRs 0001 and 0002 remain proposed; no disk-save format, co-op recovery, assists, expanded campaign, telemetry or release approval is established here.
