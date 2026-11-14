# Independent publication-candidate revalidation — issue #18

Verdict: **PASS** for source-manifest SHA-256 `04e624daa995682fa1d4eacc8b93882fae00773eea92975945b6389bd22a4e41`, base/HEAD `f7d2d6bd35f469551bc1d78ca9bc7031e0fb0051`. No actionable findings. This is the exact source candidate described by [candidate-publication.json](../candidate-publication.json); a subsequent publication commit can bind its commit SHA to this source digest. This report does not assert that a commit, push or PR has already occurred.

## Source identity and UID additions

Recomputed the complete tracked/untracked, nonignored source manifest using `git ls-files -c -o --exclude-standard -z`, excluding only generated `docs/verification/issue-18/`. File hashes use raw-byte SHA-256; aggregate identity uses SHA-256 of `json.dumps(manifest, sort_keys=True, separators=(',', ':')).encode()`. Both the complete file map and aggregate match the publication manifest.

Compared every source entry with the prior [final candidate](../candidate-final.json), whose manifest independently recomputes to `5165695cb82c83c87a040d1320f93347c9e068cf7428cceaa087e193fa116807`. There are exactly four additions, no removed entries and no changed preexisting file bytes:

| Added sidecar | UID | Paired script |
| --- | --- | --- |
| `src/scenes/scripts/campaign_save.gd.uid` | `uid://bsot7lfr858vm` | `campaign_save.gd` |
| `src/tests/scripts/campaign_failure_integration.gd.uid` | `uid://dger7ib2hb3s6` | `campaign_failure_integration.gd` |
| `src/tests/scripts/campaign_restart_integration.gd.uid` | `uid://d0fc83fukwrt8` | `campaign_restart_integration.gd` |
| `src/tests/scripts/campaign_storage_integration.gd.uid` | `uid://cc2bl8hhv25i` | `campaign_storage_integration.gd` |

Each sidecar contains one syntactically valid `uid://` identifier and is adjacent to its corresponding existing `.gd` script. All four values are distinct, have no duplicate among the candidate's other UID sidecars, and have no conflicting occurrence in project resource metadata (`.tscn`, `.tres`, `.godot`, `.import`, `.uid`) outside generated evidence/cache directories. Existing save preloads refer to the same script paths as before. This is a static UID syntax/pairing/uniqueness check; no fresh import/cache-regeneration claim is made.

Runtime/test script contents, scenes, configuration, assets and previously reviewed source documentation are byte-identical to the final independently verified candidate. The evidence index's publication paragraph correctly explains the metadata additions and preserves the earlier manifests/reports as historical snapshots.

## Retained evidence and acceptance

Revalidated both runner manifest digests, all 18 result entries in each report, all 72 stdout/stderr file hashes across the two runs, and each result's PASS-line metadata against its actual logs. Both reports retain 18/18 exit-zero invocations and no `SCRIPT ERROR`, `Parse Error` or `FAIL:` diagnostic. Original known GameMode, ObjectDB/resource-in-use and intentionally injected restart-failure diagnostics remain disclosed in the earlier reports and campaign evidence document.

All 49 copied initial independent artifacts still match the verifier's originals under `/tmp/path-of-light-18-independent/` byte-for-byte, accounting for the documented `supplemental.gd` to `supplemental.gd.txt` filename change. This retains the initial criterion-by-criterion report, independent 18-invocation reproduction, and three supplemental invocations/eight assertions. The [final integration report](final-integration-report.md) remains present and consistent with the source/evidence history. Its SHA-256 at this audit is `048237e833798f1cfb7bac6ec37c397761a77f912439a480a29c9555992a97e4`. `git diff --check` passed.

Issue #18's four acceptance criteria remain **PASS within the documented two-level local Linux solo scope**: durable/attempt state is defined; versioned save/reload, corruption handling and failure preservation are implemented; real process restart and defined v0-fixture migration are tested; exact build/source identity, evidence, documentation and limitations are recorded. Metadata-only additions introduce no new behavioral concern requiring full runtime execution.

## Runtime execution and limitations

No runtime checks were rerun during this publication review. Prior results remain evidence for unchanged runtime/test bytes: Godot `4.8.beta3.official.c51ff06e8`, executable SHA-256 `746a2bc89508d07801fe9ba9bbeaad5be0c74e05f13867977b314f2457f42701`, isolated XDG storage on the documented Linux imported-cache host. This pass consists of source/metadata and evidence-integrity revalidation.

All prior limitations remain: no clean-import/export, Windows/macOS/browser/target-device persistence verification, real controller/audio/visual accessibility evaluation, child/co-op playtest, actual power-loss or disk-full schedule, simultaneous-writer verification or directory-fsync guarantee. The MCP bridge was unavailable during the original runtime verification. Backup recovery may be one event behind; no tamper detection, historical shipped-v0 compatibility, campaign/map/reward completion or release clearance is claimed.

The verifier wrote only this requested report and performed no commit, push, PR creation or other remote action. This generated report is excluded from source identity to avoid self-reference. Further source changes require an updated identity and appropriate revalidation; retained evidence must remain attributable to its recorded candidate.
