# Issue #17 verification artifacts

These files preserve fresh checks of runtime/test commit `1745eaa29410540b3876b711f3ba1fb0f160e944`, tree `2ef79f6878bc6462bd44755e0eab86162bee4c15`. They address the exact-candidate verification feedback on PR #47. Read the [evidence note](../../accessibility-assists-evidence.md) for scope and remaining limitations.

| Artifact | Meaning |
| --- | --- |
| [candidate-1745eaa.json](candidate-1745eaa.json) | SHA-256 of all 391 committed files at the exact runtime candidate, plus its canonical aggregate digest. Includes the historical evidence note as it existed at that commit. |
| [implementation-results.json](implementation-results.json) | Fresh coordinating-agent run of all 35 integration scripts and the second-process settings restore. Commands, pass lines, diagnostics and raw-log hashes are recorded; its raw logs remain local, not committed. |
| [independent/review-report.json](independent/review-report.json) | Unchanged independently produced runtime review: before/after identity, acceptance mapping, nine fresh executions, diagnostics, commands and limitations. Its preliminary pending-evidence status is historical and is superseded by the final integration report. |
| `independent/*.stdout.log`, `independent/*.stderr.log` | All 18 raw output files named and hashed in the independent runtime report; these are inspectable in GitHub. |
| [independent/reviewer_boundaries.gd.txt](independent/reviewer_boundaries.gd.txt) | Independently authored 58-assertion supplement. Stored as text so publishing evidence does not add a Godot-imported script. |
| [independent/final-integration-report.json](independent/final-integration-report.json) | Final independent acceptance and evidence-integration verdict, produced after reviewing the documentation-only candidate. Runtime executions remain bound to `1745eaa`; this is not another full-suite execution. |

The final publication commit, Git tree and whole-candidate manifest digest are recorded in the PR description after committing these artifacts. A documentation-only follow-up may change `docs/accessibility-assists-evidence.md` and this directory; all other candidate files must retain the hashes in `candidate-1745eaa.json`. The canonical aggregate over its 390 entries excluding the historical evidence note is `9f994cf226ffa29712865dc31890a0d39ce73861ff997e383331c7a4e94137fc`.

## Verify identity

From the repository root, compare the manifest with Git objects rather than assuming that the current checkout is the historical candidate:

```sh
python - <<'PY'
import hashlib, json, pathlib, subprocess
m = json.loads(pathlib.Path('docs/verification/issue-17/candidate-1745eaa.json').read_text())
assert subprocess.check_output(['git', 'rev-parse', m['commit'] + '^{tree}'], text=True).strip() == m['git_tree']
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', '-z', m['commit']]).decode().split('\0')
entries = {p: hashlib.sha256(subprocess.check_output(['git', 'show', m['commit'] + ':' + p])).hexdigest() for p in paths if p}
assert entries == m['files']
assert hashlib.sha256(json.dumps(entries, sort_keys=True, separators=(',', ':')).encode()).hexdigest() == m['files_sha256']
print('Exact runtime manifest verified:', len(entries), 'files')
PY
```

For a later publication, `git diff --name-only 1745eaa29410540b3876b711f3ba1fb0f160e944 HEAD` must contain only the evidence note and this directory. The independent report's `raw_log_files` dictionary supplies hashes for verifying that the published raw outputs were preserved unchanged.

## Reproduce executions

The evidence note gives the engine, import boundary and environment-isolation policy. Use a new temporary root for every rerun; do not reuse the historical `/tmp` paths literally. The command arrays in the independent report record the actual original invocations. Replace their checkout and XDG directory paths for another machine. Existing integration scripts are under `src/tests/scripts/`.

To run the supplemental assertions from the project root, copy its preserved source to a temporary `.gd` path and use fresh data/config/cache directories:

```sh
verification_root="$(mktemp -d /tmp/pol17-boundaries.XXXXXX)"
cp docs/verification/issue-17/independent/reviewer_boundaries.gd.txt "$verification_root/reviewer_boundaries.gd"
XDG_DATA_HOME="$verification_root/data" \
XDG_CONFIG_HOME="$verification_root/config" \
XDG_CACHE_HOME="$verification_root/cache" \
timeout 30 /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --headless --path . --script "$verification_root/reviewer_boundaries.gd"
```

This is headless, agent-produced evidence. Synthetic physical-key events and assertions about sound-player state are not human input, controller testing, rendered UI observation or confirmation of audibility. Existing GameMode, ObjectDB and resource-exit diagnostics are retained in the logs.
