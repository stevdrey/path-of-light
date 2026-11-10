# ADR 0005: Configurable solo accessibility assists

Status: Proposed · 2026-11-10. Implemented in the two-level prototype for E02-03; the numerical balance and wider-game contract await human evaluation.

## Context

GDD section 6 and issue #17 require independently configurable extra hearts, more frequent checkpoints and falls without heart loss, available at any time without content penalties. ADR 0004 establishes attempt resets and process-session records. Campaign saves and co-op ownership remain separate proposed work.

## Prototype decision

Keep three independent, default-off Boolean options in the existing `GameSettings` autoload and local `user://settings.cfg`, alongside audio and keyboard preferences. Missing or non-Boolean assist fields default off. Settings survive application restarts; this does not persist inventory, checkpoints, secrets or completions. Restoring keyboard controls leaves assists intact. Reuse one Spanish player-facing panel from initial-menu **OPCIONES → AYUDAS** and **Esc → AYUDAS** during an attempt. Pause stays active while adjusting options, and returning restores button focus.

Extra hearts changes the cap from three to five. During a live attempt, preserve missing hearts when changing the cap, with a minimum of one heart when disabling; switching the cap cannot itself defeat or revive a player. For example, 2/3 becomes 4/5 and returns to 2/3. Missing hearts hidden by the one-heart minimum are remembered, carried across level transitions and cleared on retry, so switching the cap off and on never heals: 1/5 becomes 1/3 and returns to 1/5. A defeated player remains at zero until retry. A new level-one attempt and any retry start at the configured maximum; level transitions carry remaining hearts. The HUD shows the entire configured cap.

Frequent checkpoints adds seven authored main-route points to level one's seven, and eight to level two's eight. Use the same grounded activation window as standard checkpoints; do not derive recovery from arbitrary sampled player positions or moving platforms. Merge points in traversal order. Switching frequency preserves the current visited point, including an assist point after disabling, without granting an unvisited point or regressing during backtracking. The next attempt starts at the beginning with the currently selected frequency. Exact placement remains provisional.

No fall damage suppresses heart loss and fall hurt/defeat feedback, while retaining relocation, inventory and movement/camera cleanup for both main-route and secret-room falls. Ordinary contact hazards still damage and can deplete the character. Depletion and manual restart retain ADR 0004's same-level/entry-inventory contract with the configured heart cap. An option change while a deferred retry is pending must not overwrite the retry's full-health state with the defeated player's health.

None of the three settings changes collectibles, scores, keys, secret entry, completion records or doors. There is no assist-based eligibility, reward multiplier or content restriction.

## Alternatives and tradeoffs

A single all-or-nothing mode would prevent selecting only the needed assistance. Sampling an arbitrary last-grounded position could respawn on hazards, transient geometry or an unsupported edge. Authored points fit the existing two experimental levels and permit focused support checks, but require future level authors to supply and playtest their own points. Doubling checkpoint count does not establish even spacing or an ideal difficulty curve. Three/five hearts and the placement are prototype calibration choices, not validated accessibility targets.

## Evidence and boundaries

See [assist evidence](../accessibility-assists-evidence.md). This work adds no assets or telemetry and does not establish campaign saving, co-op behavior, controller accessibility, child usability, release clearance or completion of the four-level playable slice. ADR 0004's standard-mode rules remain in effect when all assists are off.
