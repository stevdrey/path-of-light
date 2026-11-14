# PR #48 storage-isolation correction evidence

The P2 finding concerns destructive campaign fixtures launched with XDG-only isolation on non-XDG hosts. The runner is now Linux-only and refuses other hosts before engine/Git subprocesses, output directories or sandboxes are created. Existing player campaign/backup/settings sentinels are preserved in refusal tests. No campaign gameplay/save schema or scene changes are included.

- `implementation/guard-results.json`, `guard.stdout.log`, `guard.stderr.log`: exact Python regression command, environment, result and log hashes. Four test methods include simulated Windows/Darwin/FreeBSD/unknown-host refusal, Linux subprocess isolation/sharing, fixture failure propagation and `--help`. These are mocked guard/orchestration checks, not native cross-platform engine results.
- `implementation/results.json` and adjacent campaign stdout/stderr logs: new real Linux 18-invocation campaign/recovery run using the corrected runner; all commands, engine/platform/source identity and raw-log hashes are retained.
- `candidate.json`: source manifest for the corrected candidate, excluding the entire generated issue-18 evidence directory as before.
- `independent/report.md` and retained independent artifacts: separate review of the correction against its P2 acceptance boundary and original issue criteria, including safely repeated checks.
- `independent/final-integration-report.md`: revalidation of the final evidence integration.

Reproduce from the repository root on Linux:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s src/tests -p test_campaign_runner.py -v
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output /tmp/path-of-light-18-storage-isolation
```

The runner refuses Windows/macOS/other host names; it does not implement native cross-platform isolation. Tests use temporary directories and mocked host/subprocess APIs to verify refusal without executing destructive fixtures on unsupported platforms. Runtime tests remain local Linux headless checks with the imported cache; no new export/browser, native target-device or human visual/audio/controller/co-op playtest is claimed. Original engine shutdown/host diagnostics remain disclosed in the raw logs. No historical report is represented as a fresh review of changed source.

## Recorded correction results

The implementing agent's four Python regression methods passed, and all 18 real Linux engine invocations exited 0 with no script/parse/assertion diagnostics. The separate verifier repeated four guard methods and all 18 real engine invocations, and passed 10 additional mocked safety probes (import side effects, further rejected host values, timeout handling and exit-zero script-error propagation). No actionable findings were returned. All runs use source digest `00383c26b2d796b16de83c2a8891a65a4936631caf78fe6a899f8802b82dec37` for the 426-file corrected source manifest.

The [independent report](independent/report.md), [structured verdict](independent/review-result.json), [independent runtime report](independent/reproduction/results.json) and [supplemental results](independent/supplemental-results.json) retain the exact scope and commands. The [final integration report](independent/final-integration-report.md) audits the copied evidence and result claims before publication. Native Windows/macOS execution is not claimed: refusal was tested with simulated host APIs and no engine/fixture launch. Production save/playback compatibility and broader gameplay remain unchanged.

The fresh implementation/independent runs each retain 36 raw runtime logs and their hashes; guard logs and the supplemental verifier's source/output are separate. Earlier issue-18 evidence remains intact. Final integration adds generated evidence only, with no further runtime, runner, guard-test or source-document changes.
