# Issue #20 independent verification — initial candidate

Verdict: **FAIL — correction and exact-candidate revalidation required.** The defect is a reproducible false failure in an added viewport check, not demonstrated clipping of the records UI. A second documentation finding points to canceled evidence. No additional production correctness defect was established by this review.

## Candidate and independence

Base HEAD: `e8fb99943e505afb3932394ac47f7b304947a4e3`. The reviewed working tree includes tracked and untracked source. Its 429-file SHA-256 manifest, excluding `docs/verification/`, is `11704e48a4fc3d576c779091ea56397fc7bc399bbbe07255239fd52441d86f20`. `manifest-before.json` matched the implementation manifest; `manifest-after-initial.json` confirms no source changes during review. This separate verifier read the applicable instructions, GDD, roadmap, backlog, ADRs, production source, call sites and tests. It did not rely on the canceled prior review or implementation check claims as independent proof. It did not edit candidate source, publish, merge or contact third parties.

The reviewed scope explicitly keeps production world/campaign rewards locked until real authored finales exist. Persistence and synthetic-policy evidence can satisfy that narrowed implementation boundary; they cannot establish a completed campaign or playable character selector.

## Findings

1. **P2 — Compare the record panel with the logical viewport.** `src/tests/scripts/campaign_rewards_integration.gd:80` compares `Control.get_global_rect()` coordinates against the physical `root.size`. With the project's `canvas_items`/`expand` stretch, a physical 640×480 window has a logical 1152×864 viewport. The independent fresh-process write/restore pair exits 0/1, with `FAIL: record log fits viewport: (640, 480)`. The independent geometry probe measured the panel at `(276,261)` with size `(600,342)`: it fits the logical viewport. Existing `level_map_integration.gd` correctly checks `root.get_visible_rect().encloses(...)`. Correct the new assertion and rerun the restore case so its later cancel/focus/replay/retry assertions are actually reached. Evidence: `reward-pair-results.json`, its raw logs, and `geometry.*`.

2. **P2 — Point current evidence to the actual independent review.** The acceptance table in `docs/campaign-rewards-evidence.md` says independent verification is recorded under `verification/issue-20/independent/`. This task explicitly identifies the previous attempt as canceled and not independent evidence. Point the documentation to the accepted exact-candidate report under `independent-final/`, and clearly mark canceled artifacts so they cannot be mistaken for accepted proof.

## Executed checks

Engine: `/opt/Godot/Godot_v4.8-beta3_linux.x86_64`, `4.8.beta3.official.c51ff06e8`; SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Host: Linux 7.3.3 Fedora 45 / glibc 2.44. Every Godot fixture used newly allocated temporary XDG data/config/cache roots; deliberate cold-process pairs share only their new isolated fixture. No player storage was used.

- Launched the default campaign runner independently; 18 completed cases passed before stopping this superseded-candidate run after the reproduced finding. `suite/results.json` records exact completed cases, commands, roots and log hashes. The unfinished remaining cases are **not** claimed as passes, and this is not a completed 29-case result.
- Ran the reward write/restore pair directly with fresh isolated storage: write passed three assertions; restore failed the viewport check after restoring all durable collections, checking idempotent events and showing the discovery log. Later restore assertions were not reached.
- Ran an independently authored geometry probe at physical 640×480 and 1152×648. It exposed the coordinate mismatch and recorded the panel/children's logical geometry. This is automated geometry evidence, not visual inspection.
- Ran four Python runner isolation/refusal unit tests: passed. These mocks do not establish native Windows/macOS isolation. `git diff --check`: passed. See `focused-checks.json` and logs.
- MCP server inspection reported bridge disconnected, so no live editor playtest was attempted.

## Acceptance mapping

| Criterion | Status on initial candidate | Independent evidence and boundary |
| --- | --- | --- |
| Record secrets and discoveries | PASS for current authored chamber | Portal call site invokes `record_secret`, reconciliation adds only the authored chamber; direct independent writer test passed; cold restore reached the discovery-log check. Numeric secret and v0 migration regression cases passed. |
| Record world rewards and campaign prototype unlock | PASS for agreed persistence boundary; future production content remains unavailable | Schema 2 loads/saves the three separate string-ID arrays. Pure completion policy requires explicit finale membership and all listed levels; production definitions are empty. Independent writer/restore reached assertions proving synthetic reward IDs persisted across a real second process and experimental completions granted none. No authored finale or selectable prototype exists or is claimed. |
| Verify reload and replay | FAIL as a completed check | Generic campaign reload/recovery/retry cases passed. Reward cold restore passed its early state checks, but the false viewport assertion aborts the test before cancel/focus/map replay/level retry checks. Correct and rerun. |
| Document exact build, evidence and limits | FAIL pending evidence-pointer correction | Manifest/engine identity and limitations are recorded, but the project evidence page cites the canceled review destination. |

## Source and boundary review

`campaign_save.gd` validates data-only schema 2, bounded and unique ASCII string IDs, numeric legacy IDs, aggregate write size, newer-version preservation, backups and byte-preserved per-version archives. `GameProgress` restores/reconciles facts at startup, retains records separately from attempt resets, keeps in-memory facts on failed writes and uses boundary retry. Portal and completion call sites remain on their real gameplay events. Menu, direct entry and map startup load the campaign. The map only displays authored metadata; retained unknown IDs cannot supply scene paths or unlock routes. Secrets, diamond inventory and assist settings do not participate in reward eligibility. No changed scene/input binding, new assets or telemetry was found. Co-op is not implemented by this candidate and was not inferred from solo evidence.

Warnings/errors retained in raw logs include the sandbox's GameMode D-Bus failure and ObjectDB/resource cleanup messages; injected storage faults also produce expected diagnostics. Zero script/parse/failure diagnostics in the completed runner entries does not mean error-free engine shutdown.

No human visual/audio/controller/child/accessibility playtest, co-op, exported executable, browser storage/export, native Windows/macOS, second-machine, power-loss durability or asset-clearance validation was performed. The playable-slice and release gates remain open. Any candidate source change invalidates this verdict and requires exact-candidate revalidation.
