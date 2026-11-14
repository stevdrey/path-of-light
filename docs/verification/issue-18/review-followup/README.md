# PR #48 recovered-migration and scene-readiness follow-up

The review of base `b0f70c358c5c4d9c16ed2b96f273cd7e0f24a564` identified (1) loss of an original v0 document recovered from the backup after two saves and (2) fixed physics-step assumptions before deferred scene replacement. The revised candidate retains either migration source with checked staged archival, and uses bounded process-frame waits for the expected, ready scene.

- `candidate.json`: exact revised source manifest, including current hardening and new test helpers; generated issue-18 evidence is excluded to avoid self-reference.
- `implementation/guard-results.json` and guard logs: four Python runner-boundary tests, with orchestration assertions updated for 19 cases. Host/engine APIs are mocked in these unit tests, not native non-Linux execution.
- `implementation/results.json` and all adjacent runtime logs: full current Linux headless suite, including 46 storage assertions and the dedicated absent/wrong/delayed-scene regression.
- `independent/REPORT.md` and retained artifacts: fresh independent source/call-site review and applicable executions against this exact candidate.
- `independent/final-integration-report.md`: final integrated-evidence identity and claim audit.

Reproduce from an imported checkout on Linux with a native Linux engine:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s src/tests -p test_campaign_runner.py -v
python3 src/tests/run_campaign_checks.py \
  --godot /opt/Godot/Godot_v4.8-beta3_linux.x86_64 \
  --output /tmp/path-of-light-18-review-followup
```

Storage cases use fresh XDG directories. Missing/corrupt primaries recover a deliberately noncanonical v0 backup, verify a real archive-copy obstruction preserves both inputs, then perform two saves and compare the permanent archive bytes with the original. The scene waiter uses a 5,000 ms deadline and process-frame readiness/path checks; regression tests also use short deadlines for missing/wrong scenes and delay three real menu launches across multiple process frames. Test scripts default to `test-campaign.json`, while the ordinary game uses `campaign.json` as established by the prior hardening.

The native directory-obstruction cases intentionally log archive-copy errors; host GameMode D-Bus, ObjectDB/resource shutdown diagnostics and injected restart warnings are retained as well. Passing checks do not establish an entirely error-free runtime. The earlier author-reported `failure-recovered` timing failure remains recorded in the PR; this evidence does not claim it never happened. No native Windows/macOS, exported build/browser persistence, fresh-import, target-device, power-loss, human visual/audio/controller/accessibility/child or co-op validation is implied. Earlier reports and logs remain unchanged historical artifacts.

## Recorded current-candidate results

Implementation: four Python guard methods passed and all 19 real Linux engine invocations passed, with no script/parse/assertion diagnostics. Storage reports 46 assertions. The separate verifier independently repeated four guard methods and all 19 real invocations, then passed 104 archive assertions across 32 primary/fault combinations, six bounded scene/readiness assertions and seven GameProgress hardening assertions. No actionable candidate findings were returned.

The exact 430-file source identity for both real runner reports is `cb91f1f1d3e0932dd678b97f0a15b74bb77eb660895449c367f934fdaf00e3b3`. The [independent report](independent/REPORT.md), [identity check](independent/identity.json), [full independent run](independent/full-run/results.json) and [artifact manifest](independent/artifact-manifest.json) retain scope, commands, results and hashes. Both runs preserve all 38 stdout/stderr runtime files. The [final integration report](independent/final-integration-report.md) audits the generated evidence and result claims separately; no further source changes occur during integration.

Supplemental GDScript harnesses are retained as `.gd.txt` rather than `.gd` so Godot does not import verification evidence as game scripts. Their bytes match the original `.gd` artifacts and manifest entries; restore the original suffix in a temporary directory when reproducing the recorded commands. Only report/source/output files and `full-run/` were copied; no supplemental user-storage directories were published.

The independent supplemental harness initially had a type-inference error and a scene-reattachment mistake; its initial failing development outputs are retained and explained in the report. These were verifier-harness errors, not candidate-source edits or final-run failures. Final supplemental outputs pass 104 + 6 + 7 assertions. Earlier implementation/independent reports and logs remain immutable historical snapshots.
