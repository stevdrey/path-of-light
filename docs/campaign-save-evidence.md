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

From an imported checkout on Linux with a native Linux Godot executable, run:

```bash
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output /tmp/path-of-light-18-evidence
```

The runner now explicitly supports Linux only. Other host platforms are rejected before any engine invocation (including `--version`), output directory or sandbox is created, because XDG overrides do not isolate Godot storage on Windows/macOS. `--help` remains available on all hosts. On Linux the runner creates fresh isolated user directories on every invocation, retains exact commands and raw logs, and exits nonzero for failures/timeouts/script diagnostics. It does not import the project or modify editor/plugin settings. Inspect the recorded engine/source hashes before relying on a reproduction.

Review follow-up: `--script` harnesses on any OS now default to `user://test-campaign.json`, so direct test runs cannot replace the player's campaign; the Linux XDG runner still isolates settings and cache. `GameProgress.reset()` disables autosave until the next load, failed writes are retried at menu/level boundaries, unchanged records skip writing, any integral schema version above 1 is protected as newer, and migration keeps the untouched v0 document as `campaign.json.v0.bak`. The retained evidence above predates this follow-up.

## Remaining limitations

Headless fault injection does not simulate actual power loss, filesystem caches, low disk space, all file-permission configurations, simultaneous writers or a process killed at every instruction. The same-directory rename/flush protocol is checked on this Linux host only; a valid backup may be one event behind. There is no tamper detection for otherwise valid JSON. Unrecoverable/newer files require explicit repair or a compatible build; there is no destructive automatic recovery/reset flow.

Windows/macOS, exported desktop builds, web/browser storage and eviction, private browsing, target devices and clean-import behavior were not tested. No human visual/audio/controller, accessibility or child/co-op playtest occurred. Spanish error/recovery notices have automated text/visibility assertions only; visual readability remains unverified. Host GameMode D-Bus errors, exit ObjectDB leak warnings, some resource-still-in-use exit errors and expected injected restart-failure warnings are retained in raw logs and do not establish an error-free runtime. No release clearance or completion of the four-level playable slice is implied.

## PR #48 storage-isolation P2 correction

The later high-depth review found that the original runner did not refuse unsupported hosts: its XDG-only environment could leave Windows/macOS fixtures using real player storage. The correction adds the Linux-only fail-fast gate and makes the entry point importable for regression tests. Campaign runtime, scenes, save format and gameplay are unchanged. Historical implementation/independent evidence above remains attributable to its original candidate; it does not by itself verify this correction.

Run the guard regression checks with `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s src/tests -p test_campaign_runner.py -v`. They simulate Windows, macOS (`Darwin`), FreeBSD and unknown hosts and assert zero engine/Git subprocesses, sandbox/output creation or changes to sentinel campaign/backup/preferences; they also check Linux child environments, intended restart/migration sharing, nonzero failure results and safe `--help`. Simulated host/subprocess tests are not native Windows/macOS engine runs.

See the [correction evidence index](verification/issue-18/storage-isolation/README.md) for the new implementation and independent checks, exact candidate and final integration verdict. Windows/macOS remain unsupported by the runner and untested as game targets; browser/export and human playtest limits above remain.

## Later review follow-up: recovered migration source and scene readiness

The review of `b0f70c3` requested two corrections: preserve the original v0 document when recovery begins from `.bak`, and replace fixed physics-step assumptions after deferred menu scene changes. The store now archives either migration source through a checked, validated, byte-identical staged copy before it can be replaced/rotated. Storage regressions cover missing/corrupt primary + v0 backup + blocked archive copy + two successful saves, including exact CRLF/whitespace preservation.

The two campaign fixtures use a shared process-frame scene waiter with a 5,000 ms deadline, expected scene path and `is_node_ready()` check. A failed wait produces an explicit assertion instead of dereferencing a null scene and waiting for the runner's timeout. A dedicated integration case checks bounded missing/wrong-scene results and three delayed real menu starts; the runner now has 19 engine invocations, and its Python orchestration assertions reflect the additional isolated case.

Fresh evidence and independent review for the complete revised candidate, including the changes in `b0f70c3`, are indexed in [review-followup/README.md](verification/issue-18/review-followup/README.md). Earlier independent PASS reports and logs remain bound to their historical candidates. The prior author-reported `failure-recovered` timeout is recorded in the PR discussion; it is not erased or represented as an independently confirmed diagnosis. One initial development compile found a missing explicit `Error` annotation in the new regression and was corrected before recorded checks. Deliberately obstructed archive-copy tests emit native copy errors; these expected fault-injection diagnostics are retained alongside the existing host/shutdown warnings. All platform/export/human-playtest limitations above remain.
