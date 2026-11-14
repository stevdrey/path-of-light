# Independent verification: PR #48 review follow-up

Verdict: **PASS** for the exact source candidate below. No actionable candidate findings remain from this verification. This verdict covers the supplied follow-up acceptance criteria and the local two-level Issue #18 persistence scope; it is not release, co-op, target-platform or human-playtest approval. Final evidence integration and any later source changes require their own revalidation.

## Candidate and independence

- Repository: `/home/stevdrey/Projects/Godot/Experiment 2D Platform/experiment-2d-platform`.
- HEAD/base: `b0f70c358c5c4d9c16ed2b96f273cd7e0f24a564` plus the frozen current working tree, including the four untracked helper/integration source and UID files.
- Independently recomputed source identity: 430 files, SHA-256 `cb91f1f1d3e0932dd678b97f0a15b74bb77eb660895449c367f934fdaf00e3b3`. Exact equality with `docs/verification/issue-18/review-followup/candidate.json`; no changed/missing/extra source entries. The independently executed runner records the same identity.
- Source identity uses tracked and nonignored untracked files, sorted/deduplicated, hashes each existing file, and hashes the compact sorted JSON dictionary. Generated `docs/verification/issue-18/` artifacts are excluded under the supplied policy; this does not imply verification of subsequently integrated evidence documents.
- This verifier read `AGENTS.md`, the independent-verification skill and Godot getting-started/expert/playtest skills, GDD, roadmap, local E03-01 backlog, ADR 0001, current evidence documentation, changed source/tests, GameProgress, menu/level save call sites, and the b0f70c3 hardening commit. It independently ran checks against the shared frozen source and created supplemental harnesses/reports only in this `/tmp` directory. No candidate source edits, commits, pushes, remote comments or publications were made.
- The supplied review context was PR review `5900441198` against b0f70c3, covering recovered v0 backup archival and scene-readiness races. Historical independent PASS results against 487e8f7 were not treated as proof for this candidate.

## Environment and commands

Native Linux `Linux-7.3.3-300.fc45.x86_64-x86_64-with-glibc2.44`; engine `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, version `4.8.beta3.official.c51ff06e8`, binary SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`.

From the repository root:

```sh
python3 src/tests/run_campaign_checks.py --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 --output /tmp/path-of-light-48-review-followup-independent/full-run
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s src/tests -p test_campaign_runner.py -v
git diff --check
```

Each supplemental command used the native engine, `--headless --path . --script /tmp/path-of-light-48-review-followup-independent/<harness>.gd`, and explicit `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, and `XDG_CACHE_HOME` below this review directory. Harnesses were `archive_challenges.gd` (storage prefix `supplemental-user`), `scene_challenges.gd` (`scene-user`), and `progress_challenges.gd` (`progress-user`). Their source files and stdout/stderr are retained. Full-run results record every exact engine command, XDG environment, log hash, engine identity, and source-file identity in `full-run/results.json`.

Godot MCP server info independently reported server version 2026.11.04 and a disconnected bridge at `ws://localhost:9080`; no live editor inspection/input was claimed. The installed binary enabled the required headless checks safely without changing bridge/editor configuration.

## Acceptance mapping

| Criterion | Verdict | Evidence and assessment |
| --- | --- | --- |
| Preserve v0 migration source recovered from `.bak` after two saves | PASS | `_preserve_v0()` now executes before any primary staging or backup rotation and selects migrated primary or migrated backup. Native storage tests cover both corrupt and absent primary with exact CRLF/spacing/order bytes, blocked copy, successful save and second save. Full suite storage: 46 assertions. Supplemental tests also cover a v1 primary with a still-v0 backup. |
| Preservation failures cannot overwrite committed input/archive evidence | PASS | Staged archive must decode as migrated and equal source bytes before promotion. Every copy/promotion result is returned. Existing valid v0 archive is retained; an unusable archive blocks save. Supplemental 104 assertions across 32 primary/fault combinations cover v0/v1/corrupt/missing primary; corrupt and valid-but-byte-different staged copies; failed archive promotion; corrupt/newer/v1/directory archive collisions; first-valid archive retention; successful retry and two saves after temporary failures. All checks pass; committed primary and `.bak` remained byte-identical during failures. |
| Await expected ready scene in both campaign failure/restart fixtures | PASS | Both fixtures call the shared waiter after menu `_play()`, validate non-null before access, and emit explicit failure with 5,000 ms bound. Restart fixture also checks ready level two after real exit. Helper uses `process_frame`, expected scene path, instance validity, `is_node_ready()`, and monotonic deadline. |
| Delayed transition succeeds; absent/wrong/unready scene fails boundedly | PASS | Runner's new integration test passes three delayed real menu starts, absent/wrong scenes and immediate already-ready case. Supplemental six assertions independently measure 35 ms lower bound and <1,000 ms upper bound for absent and correct-path unready scene, verify negative timeout returns immediately, and verify deferred reattachment/readiness succeeds. |
| Issue #18 durable/attempt contract and b0 runtime hardening remain correct | PASS | Source persists only completion/secret facts; menu/first level resets attempts. Full native suite passes restart/replay/depletion/record retention, real portal and both exits, failed reload/replay recovery, pause/menu, all eight assist combinations, assists UI, and two-level traversal. Supplemental seven GameProgress assertions use seeded committed data to verify reset cannot overwrite disk, explicit reload restores facts/enables persistence, unchanged facts skip writes, failed writes retain memory and visible notice, unchanged-event retry clears error, and boundary retry persists pending facts. |
| Safe version/corruption handling, application restart, migration | PASS | Full native runner: 19/19 invocations, all exit 0 with no script/parse/assertion diagnostics. Includes data validation limits, future versions, both-corrupt preservation, recovered playable paths, write failures, separate-process real campaign write/restore, v0 seed/upgrade/second restart, and orphan temporary exclusion. Store remains data-only with bounded IDs/document/record counts. |
| Harness/player storage boundary retained | PASS | Native runner uses fresh Linux XDG storage; scripted store defaults to test-campaign file. Python guards pass 4/4 methods, simulating Windows/macOS/FreeBSD/unknown refusal before engine/Git subprocesses or fixture/output creation, Linux isolation/sharing, failure exit and help. These are simulated host checks, not native non-Linux engine runs. |
| Solo/optional assists/secrets, slice gate, no real telemetry | PASS within prototype scope | Save failures remain non-blocking to real menu/solo gameplay. Real scene tests retain optional secrets, assist combinations and exits. Save format contains only three progression fields; no telemetry collection was introduced. GDD/roadmap still distinguish planned co-op/map/rewards/four-level slice from this two-level prototype and retain human scope gate. |
| Honest evidence and limitations | PASS for reviewed material | Current ADR documents source retention, first-valid archive policy, failure behavior and filesystem limits. Evidence documentation separates old-head results from this follow-up and discloses original timeout and expected injected diagnostics. This independent run supplies exact-current-source evidence. Final integration remains a subsequent check. |

## Diagnostics and limitations

All 19 engine invocations passed and Python guards passed 4/4. Full stdout/stderr is retained, including expected native copy-open errors caused by deliberate archive-stage directory obstruction and intentional failed-restart warnings. The host emits GameMode bus-access diagnostics. Shutdown ObjectDB/resource-in-use warnings remain in some logs; there is no claim of globally warning-free or leak-free runtime. No script parse/assertion error occurred in the final candidate check runs.

The supplemental verifier harness itself initially needed one explicit String annotation and one correction to reattach a node before assigning it as current scene. Those failed development harness outputs are retained as `archive-challenges.initial-parse.stderr.log` and `scene-challenges.initial-harness.*.log`; candidate source was unaffected. Corrected final supplemental runs all exited 0 and passed 104 + 6 + 7 assertions.

No human visual/audio/controller/child-accessibility playtest, native Windows/macOS/browser/export check, co-op validation, asset-rights approval, actual power-loss injection, multi-process writer behavior or directory-fsync guarantee is established. Automated scene methods activate real scenes/events but do not prove a human can understand or enjoy the levels. No real telemetry was collected. No remaining required local headless criterion was blocked.

Source manifest verification is recorded in `identity.json`; full runner report independently matches the same manifest. Any subsequent source/doc change outside the excluded generated-evidence directory invalidates this exact-source verdict.
