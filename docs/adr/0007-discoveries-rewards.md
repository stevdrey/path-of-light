# ADR 0007: Durable discoveries and reward records

Status: Accepted for issue #20's persistence boundary · 2026-11-14. Authored world/campaign content and player evaluation remain future work.

## Context and scope decision

Issue #20 requires retained secrets, discoveries, world rewards and the campaign-completion prototype unlock. The current registry contains two experimental routes, not the proposed four-level world or completed campaign. The user explicitly chose to keep campaign rewards locked until an explicitly authored world/campaign finale exists, implementing and testing persistence now. Finishing the experimental routes must not masquerade as finishing the campaign.

## Decision

Extend the data-only save to schema 2 with three independent collections: `recorded_discoveries`, `world_rewards` and `character_unlocks`. All are sorted, unique arrays of stable string IDs containing only lowercase ASCII letters, digits, `_` and `-`, with 1–96 characters per ID. Numeric `completed_levels` and `recorded_secrets` retain their existing identity and validation. Each collection remains bounded to 4,096 entries and the entire serialized document to 1 MiB, including on write. Unknown well-formed IDs survive round trips but never supply scene paths, titles, selectable characters or rewards.

`campaign_rewards.gd` owns authored discovery metadata and a pure completion policy. World definitions carry a stable `id` plus a required authored `title`; stable IDs are never shown to players. World rewards require all explicitly listed world levels including its declared finale. The prototype unlock requires all explicitly listed campaign levels including its declared finale. Empty definitions and a finale missing from its level set grant nothing. Secrets, diamonds and assist settings never participate in these conditions. Production world/campaign definitions are deliberately empty; synthetic test definitions are not production content. Future authored content must connect real finales, display metadata and character selection with their own evidence.

The existing level-one secret portal records `secret-chamber-1` at the same event as its numeric secret record. Only that entry declares the explicit `legacy_secret_level: 1` mapping; other discoveries in the same level are never implied by the numeric secret. There is no public discovery or reward grant API: records derive only from authored mappings and completion policy. This entry describes the existing chamber and uses the fictional **El mundo de las luces** category; it adds no invented story or factual curiosity. Loading older portal records reconciles that authored discovery in memory, without inventing discoveries for unknown level IDs. No post-ending discovery path, illustration, character artwork, real-world fact or development anecdote is added. The map offers **DESCUBRIMIENTOS Y RECOMPENSAS**, showing found/undiscovered status, world rewards by authored title when defined, and the prototype character as locked or, when its unlock record exists, unlocked with character selection not yet available. The log's save notice follows the map's live notice and is hidden when empty. Cancel returns to the map with focus restored.

`GameProgress` restores all collections at startup, autosaves new discovery/completion events together, skips unchanged events unless a failed save needs retry, and retains facts through attempt reset, depletion, map selection and replay. Attempt inventory remains excluded. `reset()` still clears only memory and disables persistence; there is no destructive campaign-reset UI. Save errors preserve session records and use existing notices/retry behavior.

## Migration and recovery

Schema 0 remains an explicitly defined migration fixture, never a shipped format. Schema 1 is the previously implemented three-field numeric-array format. Both decode to schema 2 with empty string-ID collections in the storage layer; gameplay reconciles only authored legacy portal discoveries. The next successful write emits schema 2. Before replacing either legacy input, preserve the first valid original for that source version byte-for-byte in `.v0.bak` or `.v1.bak`. Both primary and backup are checked, including a legacy backup next to an upgraded primary. Archive-copy or promotion failure leaves committed inputs untouched. Existing archives are retained; unusable archives block writes. Primary/backup commit, newer-version protection, corrupt-file preservation and one-local-writer limitations remain governed by ADR 0001.

Deriving all reward state solely from completions would not retain independent discoveries or explicit grant identities. Inventing rewards for the two experimental levels would bypass the agreed scope boundary. Storing arbitrary scene/node objects would mix content and attempt state into durable data. The chosen records provide the persistence contract while leaving content approval explicit.

## Evidence and limits

See [reward persistence evidence](../campaign-rewards-evidence.md). Synthetic reward fixtures establish persistence/reload behavior, not availability of an authored campaign, playable character selector or complete discovery album. No child, human visual/audio/controller, co-op, export, browser or native Windows/macOS result is claimed. The playable-slice evaluation gate and asset-clearance requirements remain open.
