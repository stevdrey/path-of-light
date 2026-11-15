# Discovery and reward persistence evidence

Issue [#20](https://github.com/stevdrey/path-of-light/issues/20), local Linux development candidate, 2026-11-14. The user's scope decision keeps rewards locked until real authored finales exist. [ADR 0007](adr/0007-discoveries-rewards.md) defines the contract; this is persistence infrastructure plus the existing chamber's record log, not a completed campaign or playable character selector.

## Candidate and reproduction

Base: `e8fb999` (merged issue #19). The exact candidate is identified by the full tracked/untracked per-file source SHA-256 manifest in [implementation/results.json](verification/issue-20/implementation/results.json). Generated `docs/verification/` evidence is excluded from that digest. The report records engine version/hash, host, commands, temporary XDG directories, process results and raw-log hashes. No exported game build was produced.

```sh
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output docs/verification/issue-20/implementation
python3 -B -m unittest discover -s src/tests -p test_campaign_runner.py
git diff --check
```

The Linux-only runner uses a fresh temporary data/config/cache root per case except deliberate cold-process pairs. Player storage is not used. The expected default suite is 29 processes: the existing 26 campaign/map/navigation checks plus reward policy/storage, real portal write, and cold reward restore/replay. Consult the recorded results for actual outcomes; a zero exit with script/parse/failure diagnostics fails the runner. Four Python checks exercise the runner's isolation/refusal boundary with mocks, not other native operating systems.

## Acceptance mapping

| Criterion | Implementation and checks |
| --- | --- |
| Record secrets and discoveries | The actual portal event retains numeric secret 1 and authored `secret-chamber-1`. Cold menu startup restores it; the map log shows it. Legacy portal records reconcile to the same discovery. Unknown IDs are retained without creating content. |
| Record world rewards and campaign prototype unlock | Schema 2 persists independent world/character ID sets. Pure policy requires all authored levels and an explicit finale; synthetic definitions test direct-finale rejection, no-secret completion and grants. Production definitions are empty by the user's decision, so both experimental completions grant nothing. Synthetic reward records survive an actual second process, map replay and level retry. No production finale, illustration or new playable character is claimed. |
| Verify reload and replay | Separate write/restore processes exercise real portal autosave and all three retained collections. Repeated events do not rewrite unchanged records. Map selection and a real level retry retain reward facts and clear attempt inventory. Existing checks cover depletion, assists, scene transitions, menu/replay, protected storage and navigation failures. |
| Record exact candidate, evidence and limitations | This document, ADR 0007, GDD status, README, architecture wiki and local backlog record the final behavior. Independent verification is recorded under [independent-final/final-integration-report.md](verification/issue-20/independent-final/final-integration-report.md) and applies only to its stated manifest. |

Storage checks cover malformed/duplicate/oversized string IDs, combined byte limits, unknown IDs, v0/v1 migration, byte-exact legacy archives, failed archive copies, recovered legacy backup, backup rotation, corrupt/newer preservation and transient write retry. Headless diagnostics include the environment's GameMode D-Bus failure and ObjectDB/resource cleanup warnings. Fault-injection cases deliberately cause file errors. These are retained in raw logs; they are not an error-free editor or resource-lifetime claim.

## Remaining validation

The Godot MCP bridge was disconnected and reported a port-9080 bind conflict. Verification uses installed Godot `4.8.beta3.official.c51ff06e8` and the project's CLI scene-integration conventions. No editor-driven live playtest, render/screenshot inspection, listening session, physical controller, child/accessibility evaluation, co-op, native Windows/macOS, browser storage/export, exported executable or second-machine test was run. UI state/focus/geometry assertions do not establish human readability or discoverability. No new external assets or telemetry were added. Existing provenance and playable-slice gates remain open.
