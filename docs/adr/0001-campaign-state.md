# ADR 0001: Campaign state and saves

Status: Proposed · 2026-11-10. Implemented for E03-01's two-level solo prototype; wider campaign, web and target-device validation remain open.

## Context

GDD sections 6, 9 and 13 distinguish retained discoveries/completions from items reset on depletion. ADR 0004 introduced process-session records. Settings already persist separately in `user://settings.cfg`. The map/registry (#19), rewards/unlocks/album (#20), co-op and the four-level slice remain separate work.

## Prototype decision

`GameProgress` loads durable facts once at menu startup or direct level entry. Persist only `completed_levels` and `recorded_secrets`: positive integer level IDs corresponding to the existing prototype's `level_number`. Do not renumber published IDs; future registry work must explicitly map/migrate them. Secret records currently mean a portal visit per level, not individual reward collection or an album. These existing facts establish a persistence seam without inventing unlocks or declaring the two experimental levels a finished campaign.

Hearts, hidden missing hearts, score, diamond counts, keys, entry inventory, safe points, position, crate/enemy state and transitions remain attempt state. Nothing resumes an interrupted attempt after application restart. Current in-process level transitions still carry inventory/health under ADR 0004. **JUGAR** and final-screen replay start at level one and retain campaign facts; this is not a continue/map feature. Settings and assists remain independent and confer no save/reward penalty. `GameProgress.reset()` is an in-memory reset for existing callers/tests; it does not delete disk data. A future destructive fresh-campaign UI needs a separately reviewed persistent reset transaction, including backup policy. This supersedes ADR 0004's suggestion to use that API alone for a future fresh campaign.

### Format and migration

Use data-only UTF-8 JSON at `user://campaign.json`, schema version 1:

```json
{"schema_version":1,"completed_levels":[1,2],"recorded_secrets":[1]}
```

Arrays contain unique integral IDs from 1 to 1,000,000 and are canonicalized in sorted order. Each collection is limited to 4,096 records and the document to 1 MiB. Reject wrong types (including Booleans as integers), fractional/negative/duplicate IDs, missing/extra fields and invalid JSON. No object deserialization, scene paths, personal identifiers or telemetry are stored. This is format validation, not tamper protection or a rights claim.

Version 0 is a **defined migration fixture, never a previously shipped save format**. It has the same three fields, but record collections are dictionaries such as `{"1":true}` with canonical numeric string keys and strictly true Boolean values. Loading converts these to version 1 arrays in memory; the next successful save writes version 1. Reopening an upgraded save is idempotent. Before replacing a migrated primary or rotating a migrated backup, preserve the first valid v0 source byte-for-byte as `campaign.json.v0.bak`. The original source may be the primary or the recovered `.bak`; a later v1 primary must not prevent preserving a still-v0 backup. Stage and validate that archive before promoting it, check every copy/promotion error, and leave both committed inputs untouched if preservation fails. Retain an existing valid v0 archive without rotating it; an unusable existing archive blocks the save rather than being silently overwritten. There was no campaign file before this issue, and no progress can be recovered from a previously terminated process's memory. Unknown newer versions are read-only and are never downgraded to an older backup.

### Commit and recovery

Autosave synchronously after the real secret-portal entry and exit completion/celebration events. Save only facts, so retries and scene resets cannot serialize transient inventory. Validate the document, write/flush/close/re-read `campaign.json.tmp`, stage a validated copy of the previous valid primary in `.bak.tmp`, replace `.bak`, then replace the primary using a same-directory rename. On the first save, initialize the backup with the new document. Every open/write/flush/validation/rename result is checked. Never rotate an invalid primary over a valid backup. Temporary files are uncommitted and ignored by loading. A failed promotion leaves the last valid primary or backup available.

Load the primary if valid; otherwise recover a valid `.bak`. Missing both means a new empty campaign. If neither is usable, continue with empty in-memory records, preserve the files and disable writes. If either protected newer format would be overwritten, reject saving. An I/O error also prevents overwriting an unreadable file. In-memory discoveries/completions remain available after a failed save; another event or `save_campaign()` may retry a transient write failure. Corrupt/unsupported storage requires explicit external repair or a compatible version before reload; no silent destructive reset is offered. Menu and gameplay show Spanish recovery/error notices without blocking the solo route.

## Alternatives and tradeoffs

Serializing scene trees would mix attempt state with durable facts and couple saves to node paths. A bare overwrite risks losing the only committed copy on interruption. The backup protocol costs a small synchronous write per durable event and may recover one event behind; repeated events may bring the backup up to date. The store assumes one local writer; concurrent game processes, cloud sync, encryption, multi-slot profiles and arbitrary manual edits are outside this contract. File flush plus rename is not a guarantee against power loss or every filesystem/browser failure; directory fsync and real fault-injected power-loss testing are absent. No checksum detects syntactically valid edits. Newer schema data is preserved rather than guessed at.

## Evidence and boundaries

See [campaign save evidence](../campaign-save-evidence.md) for exact source identity, reproducible isolated process checks, failure injection and remaining limitations. Local Linux headless evidence does not establish browser persistence, exported builds, all target filesystems, controller/visual/audio usability, co-op or release readiness. The playable-slice gate remains in effect.
