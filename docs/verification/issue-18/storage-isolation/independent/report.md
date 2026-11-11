# Independent verification: PR #48 storage-isolation correction

Verdict: **PASS** for the frozen correction candidate. No actionable findings. This is a separate verifier's source, regression and Linux runtime review; final PR evidence integration is a later review.

## Exact candidate

- Checkout: `/home/stevdrey/Projects/Godot/Experiment 2D Platform/experiment-2d-platform`.
- Base/current HEAD: `ffd8ceaa51b98ef083836263616a220f533f4bdc`.
- Candidate: full working tree, including untracked `src/tests/test_campaign_runner.py`.
- Canonical source manifest: `docs/verification/issue-18/storage-isolation/candidate.json`; 426 files; SHA-256 `00383c26b2d796b16de83c2a8891a65a4936631caf78fe6a899f8802b82dec37`.
- Tracked correction patch: `/tmp/path-of-light-48-isolation-candidate.patch`; SHA-256 `30cb82b79706c9110abcfb8d5c6c4215f9dd0cc0ee2b8f2a200ebf2aff5650ad`.
- Source hashes/file inventory matched before checks and after completion; the final actual `git diff` matched the supplied patch byte for byte. Generated `docs/verification/issue-18/` content is excluded under the existing evidence policy. Review output and supplemental sources were written under this report's temporary directory; the runner created its own fresh temporary storage sandbox as designed.

Read `AGENTS.md`, independent implementation verification skill, Godot getting-started/playtest guidance, the relevant GDD/roadmap/backlog context, ADR 0001, runner/tests, storage implementation, campaign state and restart/failure fixture callers. No candidate source edits or remote publication were performed.

## Findings and criterion mapping

| Criterion | Verdict | Evidence and reasoning |
| --- | --- | --- |
| Unsupported hosts refuse before engine/destructive fixture launch | PASS | `platform.system() != "Linux"` calls `parser.error` before output `mkdir`, sandbox creation, engine resolution/hash/version, Git or fixture subprocesses. Windows, Darwin, FreeBSD and unknown names are covered by project tests; independent probes additionally cover OpenBSD, empty, lowercase `linux`, and `None`. Help exits without child/storage effects. |
| Supported Linux runs retain fresh per-case storage | PASS | All 18 real engine invocations passed using XDG data/config/cache paths under one freshly created `/tmp/path-of-light-18-x982xvu_` sandbox. Its 15 distinct storage groups match the intended one group for write/restore, one for three migration processes, and individual groups for all other cases. Inherited storage variables are replaced in all fixture child environments. |
| Guard regression tests prove refusal has no child/storage effects | PASS | 4/4 project unittest methods pass. Independent probes trap `Popen`, `run`, `check_output`, `Path.mkdir` and `mkdtemp`; unsupported-host calls exit 2 and preserve an existing campaign sentinel/output directory. Module import also has no child/directory/sandbox effects. These are mocked host checks, not native non-Linux runs. |
| Durable versus attempt state remains defined | PASS | ADR/save/game-progress behavior is unchanged by this correction. Real process restart restores completion/portal records without health, score, diamonds or keys; JUGAR remains playable from level one. Attempt, record, restart, fall, assist, menu and two-level cases all pass. |
| Versioned safe saves and corruption handling remain satisfied | PASS | Real storage suite and future/corrupt/recovered/write-failure gameplay paths pass. Source review confirms protected newer/unreadable files, staged validation/backup promotion, bounded data-only schema validation and the unchanged attempt/durable boundary. |
| Restart and migration remain tested | PASS | Real write/restore use separate engine processes with deliberate storage sharing; migration seed, upgrade and second restart pass in three separate processes. |
| Evidence identifies exact build and limitations honestly | PASS | Runner report matches the frozen source digest and exact engine hash; all 36 raw output log hashes were verified. Local/mocked/native-platform distinctions are explicit. Historical evidence is not treated as verification of changed source. Final integrated evidence/publication review remains separate. |

No gameplay, scene, input, save-format, co-op, asset or telemetry changes are introduced by the correction. The solo route, optional secrets/assists and wider slice scope remain as before. No test here is represented as a human playtest.

## Commands and results

Executed from the checkout:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s src/tests -p test_campaign_runner.py -v
PYTHONDONTWRITEBYTECODE=1 python3 src/tests/run_campaign_checks.py --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 --output /tmp/path-of-light-48-isolation-independent/reproduction
PYTHONDONTWRITEBYTECODE=1 python3 /tmp/path-of-light-48-isolation-independent/supplemental_guards.py
git diff --check
```

- Project guard tests: **4/4 methods**, exit 0, retained `guard.stdout.log`/`guard.stderr.log`.
- Independent supplemental probes: **10/10**, exit 0, retained source, logs and `supplemental-results.json`. In addition to import/refusal probes, injected timeouts and zero-exit `SCRIPT ERROR` diagnostics both force failed 18-case aggregates and nonzero runner results. Engine/subprocesses are mocked in these probes.
- Independent real Linux reproduction: **18/18**, runner exit 0, no script/parse/assertion diagnostics. Retained exact commands/environments, pass lines, source/engine identities and raw logs under `reproduction/`.
- `git diff --check`: exit 0.
- Independent source and evidence identity/hash checks: PASS; details in `identity-initial.json` and `review-result.json`.

Runtime environment: `Linux-7.2.15-300.fc45.x86_64-x86_64-with-glibc2.44`; native installed Godot `4.8.beta3.official.c51ff06e8`; engine SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`. Godot MCP server info returned version `2026.11.04`, disconnected bridge, no active scene; direct installed-engine execution was used. No editor settings were changed.

## Limits

Non-Linux guard behavior was simulated by replacing the platform API. No native Windows/macOS engine execution or native platform isolation is claimed; those hosts are intentionally unsupported by this runner. The Linux command assumes a native Linux Godot executable as documented.

These are local headless checks using the existing imported cache. No export/browser/target-device, clean-import, visual/audio/controller, accessibility, child or co-op playtest was performed. Actual power loss, low disk space, arbitrary filesystem permissions and concurrent writers were not simulated. Host GameMode/D-Bus, ObjectDB leak/resource shutdown warnings and injected restart errors remain in retained logs; passing assertions do not establish an error-free runtime or release clearance.
