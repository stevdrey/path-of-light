# ADR 0006: Prototype campaign registry and level map

Status: Proposed · 2026-11-13. Implemented for the existing two-level solo prototype for evaluation; expanded campaign and human usability approval remain open.

## Context

[Issue #19](https://github.com/stevdrey/path-of-light/issues/19), GDD sections 9–10 and the roadmap require sequential routes and revisiting. ADR 0001 already persists positive numeric completion/secret IDs. The current scenes are experimental levels, not the proposed four-level first world. Registry work must preserve their published IDs and the slice scope gate.

## Prototype decision

`campaign_registry.gd` owns the ordered metadata: stable save ID, Spanish display title and scene path. Only IDs 1 and 2 are registered. Returned metadata are copies. Menu play/replay, map selection and the existing levels' next-door destinations use this registry. No save schema change is needed: availability is derived from completion facts, never persisted separately. Unknown saved IDs remain preserved by the save layer but cannot create or unlock routes. IDs must not be renumbered or reused; removing published content or changing its identity requires an explicit mapping/migration decision.

The first route is available immediately. An uncompleted route opens when all its predecessors are completed. A registered completed route is always replayable, including a direct-entry/legacy completion lacking earlier facts; it does not imply completion of those predecessors. Neither secrets, diamonds nor assists gate availability. Completion facts retained in memory after a save failure can open routes for that session; the existing save notice explains possible loss on restart. Future/corrupt storage remains protected under ADR 0001.

**MAPA DE NIVELES** is available from the main menu, pause and final completion screen. Map nodes show a level number/title plus a symbol and status for open, completed or blocked states. Connecting labels identify available/blocked routes without relying on color. Focus starts on the first open uncompleted route, falling back to the first route; disabled routes cannot be launched through the selection handler. Returning to the main menu restores map-button focus. The map uses normal UI focus/accept/cancel navigation; this does not establish physical-controller compatibility.

Selecting any open route starts a new attempt with full configured hearts and empty score, diamonds and keys, at the scene's initial position and checkpoints. It retains durable completions/secrets and settings. In contrast, the real level-one exit continues directly to level two with the existing inventory/health carry-over. Depletion and manual retry retain the selected level's entry inventory under ADR 0004. **JUGAR** and final-screen **R** still begin level one. Pause explicitly labels map navigation as leaving the current attempt. There is no destructive campaign reset or mid-attempt resume.

Map launches are deferred out of input callbacks, guarded against repeated selection and checked for load failure. Inventory resets only after the scene request succeeds, before the replacement scene is ready. Failure keeps the map interactive, preserves inventory and offers a visible retry. Pause-to-map failure keeps the live attempt paused; successful navigation releases pause. Final-screen failure leaves replay/map controls usable.

## Alternatives and tradeoffs

Persisting unlock flags would duplicate completion facts and require migration/reconciliation. Filling the registry with 32 planned levels would advertise unavailable content and bypass the scope gate. Reusing carried inventory for map entry would let an abandoned attempt grant keys/score or damaged health to an unrelated revisit. A separate graphical world atlas, world-light celebrations, reward album, unlockable characters and post-ending paths require later content and usability work; this change provides a small connected selection map for existing routes.

## Evidence and limits

See [map evidence](../campaign-map-evidence.md). Automated scene/input/state checks do not establish visual clarity for children, controller hardware behavior, audio balance, co-op or exported-platform persistence. The four-level slice and campaign expansion gate remain open.
