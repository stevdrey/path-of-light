# Final independent integration revalidation — issue #18

Verdict: **PASS** for final source-manifest SHA-256 `5165695cb82c83c87a040d1320f93347c9e068cf7428cceaa087e193fa116807`, based on base/HEAD `f7d2d6bd35f469551bc1d78ca9bc7031e0fb0051`. No actionable findings. This report revalidates documentation/evidence integration after the [initial independent implementation verification](report.md); it does not claim new runtime executions.

## Exact candidate and source delta

Recomputed the current tracked and untracked, nonignored source file hashes with `git ls-files -c -o --exclude-standard -z`, excluding only `docs/verification/issue-18/`. Each file is hashed as raw bytes; the aggregate is SHA-256 of `json.dumps(manifest, sort_keys=True, separators=(',', ':')).encode()`. Every current file hash and the aggregate matched [candidate-final.json](../candidate-final.json).

Recomputed and validated the retained [initial manifest](../candidate-initial.json), digest `11cd000c476cfb0a2329b4264b5bed08b847d03a8b38e289d9922434fb178e7a`. Its only source-file difference from the final candidate is `docs/campaign-save-evidence.md`. All runtime scripts, tests, settings/configuration, scenes, assets and other source documents are byte-identical to the independently tested initial candidate. The artifact index and generated evidence additions are within the explicitly excluded directory. Consequently, runtime reruns were unnecessary for this documentation-only delta.

## Evidence audit

Performed read-only Python SHA-256/JSON audits of both retained runner reports, their complete stdout/stderr files, and the copied independent artifacts; inspected the integrated evidence document and artifact index; ran `git diff --check` successfully.

- [Implementation results](../implementation/results.json): aggregate source-manifest digest `be844b4b04a6a1fbcc9a0e5b44c13f835dd5bd256a883200c271d1af9b479b48` recomputes correctly; 18/18 invocations, all exit 0 with no script/parse/assertion diagnostics. All 36 raw-log SHA-256 values match their retained files. The only manifest difference from the initial review candidate is README.md; independently verified that the implementation README hash equals the initial/current README bytes plus one trailing newline, confirming the documented removal of a trailing blank line.
- [Independent reproduction results](reproduction/results.json): manifest recomputes to the exact initial candidate; 18/18 invocations, all exit 0 with no script/parse/assertion diagnostics. All 36 retained raw-log hashes match. Reconstructed each result's PASS lines from the actual logs and confirmed exact agreement with report metadata.
- [Supplemental results](supplemental-results.json): three invocations, all exit 0 without script/parse/assertion diagnostics; the retained stdout contains eight PASS assertions. They cover real staging-directory obstructions and retries, unreadable-primary preservation/recovery, and direct level-two startup with five-heart assist and clean attempt inventory.
- All 49 retained independent files present at audit time match the verifier's original files under `/tmp/path-of-light-18-independent/` byte-for-byte. This includes the initial report, runner results/logs, supplemental results/logs/source/orchestrator and candidate confirmations. `supplemental.gd.txt` matches the original `supplemental.gd` exactly; the artifact index explains the extension change and temporary restoration needed for reproduction. No supplemental sandbox directory was copied into the repository.
- Integrated relative documentation links resolve; the final-report link targets this authorized output. The evidence document accurately distinguishes initial verification from final integration and preserves the migration fixture's nonhistorical status and slice boundaries.

Both 18-invocation runs use Godot `4.8.beta3.official.c51ff06e8`, executable SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`, on the documented Linux host. Source identity and exact per-process commands, isolated XDG environments, outcomes, PASS lines and log hashes remain available in each results JSON. The implementation and independent runs are distinct executions.

## Diagnostic and claim consistency

The retained implementation logs contain 18 GameMode D-Bus errors, 18 ObjectDB leak warnings, six resource-in-use exit errors and three expected injected restart-load warnings. Independent reproduction logs contain 18 GameMode errors, 18 ObjectDB leak warnings, six resource-in-use exit errors and three expected injected restart-load warnings. Object/resource counts differ across processes, as preserved in the raw output. Neither run contains a `SCRIPT ERROR`, `Parse Error` or `FAIL:` line. The integrated documentation now names all these diagnostic classes and correctly avoids claiming a globally error-free runtime. Counts refer to diagnostic lines, not affected runtime features or established regressions.

The initial four-criterion PASS remains applicable to the final candidate because behavior and tests are unchanged and the revised documentation accurately reports retained evidence. No map, rewards/unlocks/album, co-op, approved campaign expansion, telemetry collection, asset clearance or release readiness is asserted.

## Limits and scope of this revalidation

This pass checked source identity, documentation, recorded results, file integrity and claim consistency. No runtime test was rerun during final integration review. The original local imported-cache headless execution limits remain: no clean import/export, Windows/macOS/browser persistence, real target-device/controller/audio/visual accessibility testing, child/co-op playtest, actual power-loss/disk-full schedule, directory-fsync guarantee or simultaneous-writer verification. UI notices have automated text/visibility checks rather than human readability evidence. Backup recovery may be one event behind; no tamper detection is claimed. The disconnected MCP bridge remained a recorded execution limitation, not a successful editor test.

The verifier wrote only this requested report during final revalidation and performed no remote publication. This generated report is excluded from source identity to avoid self-reference. Any later change outside the excluded evidence directory requires a new identity comparison and appropriate revalidation; changes to retained evidence must preserve provenance and remain reviewable.
