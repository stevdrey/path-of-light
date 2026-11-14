# Issue #18 verification artifacts

- `implementation/results.json`: source manifest and digest, base commit, engine/platform identity, isolated environments, exact commands, process outcomes, pass lines and raw-log SHA-256 values.
- `implementation/*.stdout.log` / `*.stderr.log`: complete local command output, including host errors/warnings.
- `candidate-initial.json`: exact initial source manifest, independently reviewed with PASS.
- `candidate-final.json`: source manifest after documentation/evidence integration.
- `independent/report.md`: initial criterion-by-criterion PASS, 18/18 independently reproduced invocations and 3/3 supplemental invocations.
- `independent/reproduction/`: exact independent runner commands/results, source manifest and raw logs.
- `independent/supplemental-results.json`, supplemental source/orchestrator and raw logs: 8 additional assertions on real filesystem failures and direct startup. `supplemental.gd.txt` is retained as text to avoid importing evidence as a game script; restore its `.gd` filename in a temporary directory before reproducing the recorded supplemental command.
- `independent/final-integration-report.md`: final source/evidence identity check and documentation revalidation.

Source identity excludes this generated evidence directory to avoid self-referential hashes. The manifest includes all tracked/untracked, nonignored files elsewhere in the candidate. Its digest is SHA-256 of Python `json.dumps(manifest, sort_keys=True, separators=(',', ':')).encode()`; each entry is the file's raw-byte SHA-256. A reviewer can compare the current source to that manifest without relying on a mutable branch label. Historical issue #17 evidence is unchanged.

Reproduce with `src/tests/run_campaign_checks.py` as described in [campaign save evidence](../../campaign-save-evidence.md). Use a different output directory to preserve this recorded run. XDG sandbox paths in reports describe local execution; raw logs here are the retained evidence, not those temporary directories. The checks assume an imported checkout and do not touch actual player storage.

The implementation runner manifest and initial review manifest differ only in a removed trailing blank line in `README.md`. Final integration changes only `docs/campaign-save-evidence.md` and this artifact index, plus generated files under this directory; runtime scripts, tests and game configuration remain byte-identical. The final verifier checks the integrated source manifest and evidence/log hashes.

## PR publication candidate

After the final integration review, Godot generated four `.gd.uid` sidecars for the new save script and campaign test scripts. `candidate-publication.json` binds that publication source tree; `independent/publication-report.md` revalidates the metadata additions and retained evidence. Runtime/test source, scenes, settings, assets and previously reviewed documentation are unchanged. Earlier manifests and reports are historical snapshots and are retained intact.

## Storage-isolation review correction

The high-depth P2 review identified unsafe XDG-only fixture isolation on Windows/macOS. The runner now refuses non-Linux hosts before starting any engine process or creating output/storage directories. New guard tests and re-executed campaign checks, source manifests and independent review are indexed in [storage-isolation/README.md](storage-isolation/README.md). Existing artifacts above are retained as historical evidence rather than overwritten.

## Subsequent review follow-up

The later `b0f70c3` hardening and two follow-up findings require fresh exact-candidate evidence. [review-followup/README.md](review-followup/README.md) indexes the new archive-preservation/scene-readiness checks, complete suite and independent review. All earlier files above remain historical snapshots; their verdicts are not attributed to the revised behavior.
