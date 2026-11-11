# Campaign save implementation and evidence — E03-01 / issue #18

## Implemented boundary

The two-level solo prototype now loads and autosaves existing level-completion and secret-portal visit records across application launches. The [save ADR](adr/0001-campaign-state.md) defines version 1 JSON, the attempt/durable boundary, commit/recovery policy and a version 0 migration fixture. Version 0 was never shipped; this tests an explicit migration path rather than claiming compatibility with an existing legacy file.

Hearts, hidden missing hearts, score, diamonds, keys, safe points, scene objects and entry snapshots are never serialized. Retry/depletion preserve durable facts; **JUGAR** and final-screen replay still begin level one. Settings/assists remain separate. Map/registry, granular secrets/rewards/unlocks/album, co-op, multiple save slots and a destructive new-campaign UI remain future work. No assets, input mappings or telemetry were added.

## Candidate and environment

Base: `f7d2d6b` (merged issue #17). The implementation report records the exact SHA-256 of every candidate source file outside this issue's generated evidence directory, a canonical source-manifest digest, engine identity, commands and per-process results. These hashes identify the uncommitted candidate more precisely than the base commit alone. Recompute the manifest against the checkout before comparing results. See the [evidence artifact index](verification/issue-18/README.md).

Linux x86-64, Godot `4.8.beta3.official.c51ff06e8`, executable `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, using the current imported asset cache and Compatibility project settings. All checks use temporary isolated XDG data/config/cache directories. Only deliberate write/restart and migration sequences share storage. The player's real campaign/preferences are not read or changed. This is local headless evidence, not an export or CI result.

The MCP health check reported a disconnected editor bridge and an existing listener preventing binding to `127.0.0.1:9080`. Editor inspection/input was unavailable; checks ran through the installed engine directly.

## Verification

The reproducible runner covers 18 invocations:

- Storage validation/recovery checks: empty install, ordinary replacement, truncated primary, missing primary, both corrupt, malformed schemas/types/IDs, size/count limits, newer primary/backup protection, v0-to-v1 migration and ignored uncommitted temporary files. It injects truncated staging writes and failed backup/primary promotions; a separate store instance must still load the last committed data. It also exercises real invalid-path/open failures.
- Real portal and both level-exit save triggers, then a **second engine process** loading through the actual front menu. Assert durable records return while damaged health, score, diamonds and keys do not; **JUGAR** remains playable from level one.
- Migration fixture creation, loading/upgrading in a second process, and a third process reading the upgraded schema.
- Playable failure paths for newer versions, unrecoverable corruption, backup recovery and injected write failure. Assert menu/gameplay notices, preserved protected files, continued secret entry and in-memory recording, and successful retry after a transient failure.
- Existing attempt-recovery, secret/completion records, restart lifecycle, fall-depletion, assisted recovery/UI, pause/menu and two-level checks.

The [implementation results](verification/issue-18/implementation/results.json) record **18/18 invocations passed**, with no script, parse or assertion diagnostics; adjacent raw stdout/stderr logs and their hashes are retained. The runtime/test files remained unchanged after this run; its manifest differs from the initial review manifest only by a removed trailing blank line in README.md. Final evidence integration changes documentation only, as verified against the retained manifests. Initial development runs found a malformed v0 Boolean-type comparison error and two test-harness issues (numeric JSON comparison and indentation); these were corrected before the recorded candidate run. A passing exit alone is not enough: the runner also rejects script, parse and assertion diagnostics.

A separate verifier independently reviewed the exact initial candidate, reproduced **18/18 invocations**, and passed **3/3 supplemental invocations** (8 assertions) for native staging-path obstructions, an unreadable primary file, and cold direct level-two startup with the five-heart assist. No actionable implementation findings were returned. See the [independent report](verification/issue-18/independent/report.md), [reproduction results](verification/issue-18/independent/reproduction/results.json) and [supplemental results](verification/issue-18/independent/supplemental-results.json). The [final integration report](verification/issue-18/independent/final-integration-report.md) revalidates the resulting documentation/evidence candidate; initial implementation verification and final integration review are distinct steps.

## Reproduce

From an imported checkout, run:

```bash
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output /tmp/path-of-light-18-evidence
```

The runner creates fresh isolated user directories on every invocation, retains exact commands and raw logs, and exits nonzero for failures/timeouts/script diagnostics. It does not import the project or modify editor/plugin settings. Inspect the recorded engine/source hashes before relying on a reproduction.

## Remaining limitations

Headless fault injection does not simulate actual power loss, filesystem caches, low disk space, all file-permission configurations, simultaneous writers or a process killed at every instruction. The same-directory rename/flush protocol is checked on this Linux host only; a valid backup may be one event behind. There is no tamper detection for otherwise valid JSON. Unrecoverable/newer files require explicit repair or a compatible build; there is no destructive automatic recovery/reset flow.

Windows/macOS, exported desktop builds, web/browser storage and eviction, private browsing, target devices and clean-import behavior were not tested. No human visual/audio/controller, accessibility or child/co-op playtest occurred. Spanish error/recovery notices have automated text/visibility assertions only; visual readability remains unverified. Host GameMode D-Bus errors, exit ObjectDB leak warnings, some resource-still-in-use exit errors and expected injected restart-failure warnings are retained in raw logs and do not establish an error-free runtime. No release clearance or completion of the four-level playable slice is implied.
