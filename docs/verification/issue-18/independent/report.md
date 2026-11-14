# Independent implementation verification: issue #18 / E03-01

Verdict: PASS for the exact initial candidate below, within the two-level local Linux solo prototype. No blocking or actionable implementation findings were identified. This is a separate verifier's source/call-site/test review and independent execution, not an implementation self-review. Final evidence/document integration still requires revalidation against its resulting candidate identity.

## Exact candidate and constraints

- Issue: https://github.com/stevdrey/path-of-light/issues/18; parent: https://github.com/stevdrey/path-of-light/issues/3 (both read from the connected GitHub service).
- Base/HEAD: `f7d2d6bd35f469551bc1d78ca9bc7031e0fb0051`.
- Candidate: current tracked and untracked, nonignored checkout sources, excluding only generated `docs/verification/issue-18/` artifacts.
- Source-manifest SHA-256: `11cd000c476cfb0a2329b4264b5bed08b847d03a8b38e289d9922434fb178e7a`. Recomputed before and after verification; all candidate file hashes matched `/tmp/path-of-light-18-candidate.json` and the independent runner's manifest. Exact file manifest is retained in `reproduction/results.json`.
- Tracked candidate patch supplied at `/tmp/path-of-light-18-candidate.patch`; untracked runtime/test/docs source was inspected directly and bound by the manifest.
- No candidate source was edited by the verifier. Supplemental tests, logs and this report are confined to `/tmp/path-of-light-18-independent/`.

Read AGENTS.md, the independent-verification skill, relevant Godot expert/getting-started/playtest guidance, GDD.md, docs/ROADMAP.md, E03-01 and E03 backlog context, ADR 0001, ADR 0004 and implementation/evidence docs. Reviewed campaign_save.gd, GameProgress, real secret and both exit call sites, menu initialization, attempt retry/replay boundaries, settings/assists and all new tests/runner. The map, rewards/album/unlocks, co-op and expansion beyond the slice remain separate work; no new telemetry or asset-rights assertions were introduced.

## Acceptance mapping

| Criterion | Result | Evidence |
| --- | --- | --- |
| Define durable versus attempt state | PASS | ADR 0001 explicitly persists completed-level and portal-visit records only. GameProgress serializes exactly three schema fields; health, hidden missing hearts, score, diamonds/counts, keys, position/checkpoints and scene state remain outside the document. Existing retry/replay/assist checks pass. |
| Save/reload safely with versioning and corruption handling | PASS | Data-only JSON validation, limits/canonicalization, v1 format, v0 fixture conversion, staged re-read and backup/promotion protocol inspected. Storage check passes 35 assertions; playable corrupt/future/recovered/write-failure checks pass. Additional native filesystem staging obstruction and unreadable-primary tests preserve committed data and reject unsafe writes. |
| Test restart and migration paths | PASS | Actual portal and both exits autosave, followed by a separate engine process cold-loading through the front menu. Seed-v0, load/upgrade and another process reading v1 all pass. Direct level-two startup additionally restores facts with configured five-heart assist and clean inventory. |
| Evidence, exact build, limitations and relevant documentation | PASS for initial candidate | Source-bound implementation evidence and independent source-bound reproduction include exact engine, commands/environments/results/log hashes. GDD, README, docs index, backlog, wiki and save ADR describe the implemented scope and remaining gaps. Initial docs accurately say independent verification is pending; integrating this report and final logs will need a new candidate revalidation. |

## Execution and results

Environment: Linux-7.2.15-300.fc45.x86_64-x86_64-with-glibc2.44; Godot `4.8.beta3.official.c51ff06e8`; executable `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`; executable SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. The imported asset cache already present in the checkout was used. Project uses Compatibility rendering.

Independent reproduction command, from the repository root:

```bash
python3 src/tests/run_campaign_checks.py --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 --output /tmp/path-of-light-18-independent/reproduction
```

Result: **18/18 engine invocations passed**, each exit 0, no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostic. Invocations: storage; campaign-write/restore; migration-seed/restore/second-restart; failure-future/corrupt/recovered/write-failure; attempt_recovery; recovery_records; restart_lifecycle; fall_depletion; assist_recovery; assist_ui; pause_menu; two_levels. This counts invocations, not independent human playtests. Storage invocation reports 35 assertions.

Supplemental command:

```bash
python3 /tmp/path-of-light-18-independent/run_supplemental.py
```

Result: **3/3 additional invocations passed**, exit 0 and no script/parse/assertion diagnostic; 8 PASS assertions in total. Script `supplemental.gd`, orchestrator, exact commands/environments and result metadata are retained alongside this report:

- Real directories obstruct `.tmp` and `.bak.tmp`: saving fails, the prior primary bytes and restored commit remain unchanged, and removing the obstruction permits successful save/reload.
- Primary file with mode 000 plus valid backup: load recovers the backup, overwrite is refused, primary hash remains unchanged after restoring permission.
- Cold direct level-two entry: loads existing campaign facts and configured five-heart assist without restoring attempt inventory.

All invocations used fresh isolated XDG data/config/cache storage. Only intended process-restart/migration sequences shared storage. Supplemental unreadable-file test used its own isolated absolute path. Real player saves/preferences were not accessed. `git diff --check` passed.

Godot MCP health/server-info were independently checked: server `2026.11.04`, bridge disconnected, existing listener prevented binding to `127.0.0.1:9080`. No live editor verification was possible; no scene/editor mutations were attempted.

## Limits and non-blocking diagnostics

Raw logs retain host GameMode D-Bus connection errors, ObjectDB leak warnings, `resources still in use at exit` errors on some invocations, and expected injected restart-load failure warnings. These runs establish the stated assertions and exit/diagnostic policy, not a globally error-free engine runtime. No baseline attribution or leak fix is claimed.

This is local imported-cache headless evidence. No fresh import, exported desktop build, Windows/macOS, browser/web storage/eviction/private-mode test, real target-device/controller/audio/visual accessibility review, child playtest or co-op test was run. UI notices were checked by automated visibility/text assertions, not visual readability. No actual power cut, disk-full fault, fsync/directory durability audit, exhaustive process-kill schedule or simultaneous-writer test was performed. Backup recovery can be one event behind; single local writer and no tamper detection are documented. Version 0 is explicitly an invented migration fixture, not a historical shipped format. The broader campaign, unlocks and release readiness are not verified.

Any source/document change outside the excluded generated-evidence directory changes this candidate identity and requires revalidation. No publication, issue/PR comment, merge or other external write was performed.
