# Asset provenance and redistribution audit

Reviewed 2026-11-08 for [E01-02](backlog/issues/E01-02.md). This is an inventory and action list, not a release clearance or legal opinion. The reviewed source baseline is Git commit `d9935cfa5176b29307acc73ba07f0cee04e19a0f`, with a clean working tree before this document and its links were added. No exported build was reviewed. The inventory covers tracked repository files at that commit, including unused source assets; ignored `.godot/` and `*.import` files, external tools, engine binaries and export templates are outside this inventory and require review for an actual distribution.

**Release and source redistribution remain unresolved.** Being present in Git does not establish ownership or permission. “Documented” below means evidence was found, not that the file's identity or the licensor's authority was independently proven. Direct references indicate source-level use, not proof of what an export includes; files with no direct reference may still be imported or packaged. Do not delete them merely on that basis.

## Code, project data and bundled tooling

| Scope | Evidence and permitted use | Action / limitation |
|---|---|---|
| Original game GDScript, including tests, `src/**/*.gd` | [README](../README.md) explicitly applies the project's [MIT license](../LICENSE), copyright Steven Rey Sequeira. MIT permits use, modification and redistribution subject to retaining its notice. | Verify authorship and any incorporated third-party snippets before release. The README does not extend this grant to other file types. |
| `addons/godot_mcp/` code, `icon.png`, metadata and `.uid` files | Bundled [MIT license](../addons/godot_mcp/LICENSE), copyright Johnny D. MIT permits use, modification and redistribution with notice. | Preserve the notice; verify addon version, upstream provenance and whether non-code icon is covered. Review its inclusion in an actual export. |
| `src/**/*.tscn`, `src/**/*.tres`, `src/**/*.gdshader`, `ressources/default_bus_layout.tres`, `project.godot`, project metadata and documentation | Project files at baseline; no explicit rights grant for these categories was found. Scenes and resources reference separately licensed or unresolved assets. | Confirm authorship and choose/document appropriate licenses, including shader and generated scene visuals. Do not infer MIT coverage from the code license. |
| Godot engine and export templates | External dependencies; no engine binary or template included in the tracked baseline. | Record the actual engine and template versions and applicable notices for each distributed build. |

## Images

All paths below are relative to `assets/images/`, except `icon.svg`. On 2026-11-08 the project owner identified [Kenney's Simplified Platformer Pack](https://kenney.nl/assets/simplified-platformer-pack) as the source of the image assets. The pack's page lists CC0, which permits copying, modifying and redistributing, including commercially, subject to rights outside its scope. The owner did not provide a file-by-file mapping or transformation history, and the pack archive could not be downloaded in this environment; the exact relationship of each image, particularly apparent derivatives, to the pack is not yet verified. The icon is separately unresolved. Do not assume that the pack's license automatically covers every input or subsequent asset.

| File | Source-level role / references | Action |
|---|---|---|
| `platformPack_tilesheet.png` | Terrain, objects and HUD; referenced by level scenes, resources and scripts. Owner identifies Kenney pack as source; pack is CC0. | Compare with the identified pack, record version and modifications, and retain provenance evidence. |
| `platformPack_tilesheet@2.png` | No direct source-text reference found. Owner identifies Kenney pack as source; pack is CC0. | Compare with the pack and record modifications, or remove from the distribution after dependency review. |
| `platformerPack_character@2.png` | `src/character/character.tscn`. Owner identifies Kenney pack as source; pack is CC0. | Compare with the pack and record version and modifications. |
| `player_damage_defeat.png` | `src/character/components/ressources/player_reactions.tres`. | Establish source, inputs and rights or replace. |
| `decor_nature_atlas.png` | `src/scenes/ressources/nature_decor_tileset.tres`. | Establish creation and source inputs, rights and transformations or replace. |
| `decor_nature_generated.png` | No direct source-text reference found. | Establish generation/source inputs and applicable terms or remove/replace after dependency review. |
| `enemy_beetle_concept.png`, `enemy_beetle_spritesheet.png` | No direct source-text reference found. | Establish source, inputs and rights or remove/replace after dependency review. |
| `enemy_beetle_walk_v2.png`, `enemy_beetle_wings_v2.png` | `src/enemies/ressources/beetle_frames.tres`. | Establish source, inputs and rights or replace both animation sheets. |
| `ui/menu_background.png`, `ui/splash_art.png` | `src/ui/scripts/front_end.gd`. | Establish authorship, any generation terms and input rights or replace. |
| `icon.svg` | Project icon in `project.godot`; visually resembles the Godot icon, but exact origin and license were not established. | Verify exact source, license and applicable branding rules or replace with cleared project icon. |

## Font

| File | Evidence and permitted use | Action / limitation |
|---|---|---|
| `assets/fonts/fredoka/Fredoka.ttf` | [OFL.txt](../assets/fonts/fredoka/OFL.txt) identifies the Fredoka Project Authors and SIL OFL 1.1. The license permits embedding, modification and redistribution subject to its conditions, including retaining notices, not selling the font by itself, and reserved-name rules where applicable. Used by `src/ui/menu_theme.tres`. | Confirm the exact font file/version matches the licensed upstream and retain the license and copyright notice in distribution. |

## Sound and music

The [sound credits](../assets/sounds/CREDITS.md) record sources and transformations. CC0 permits copying, modification and redistribution, including commercial use, subject to rights outside its scope ([Creative Commons](https://creativecommons.org/publicdomain/zero/1.0/)). Source-page license checks below do not establish byte identity with the repository files.

| File(s), under `assets/sounds/` | Source / license / observed use | Action / limitation |
|---|---|---|
| `sfx/jump.wav`, `sfx/hurt.wav`, `sfx/defeat.wav` | Credits identify Juhani Junkala / SubspaceAudio's [512 Sound Effects](https://opengameart.org/content/512-sound-effects-8-bit-style), CC0; renamed. Used in movement and health. | Source page returned HTTP 403 during this review; independently verify listing and file identity before release. |
| `sfx/collect_gem.wav` | Credits identify Bobjt's [Gem collect SFX](https://opengameart.org/content/gem-collect-sfx), CC0; renamed. Source listing and CC0 checked; used in level script. | Compare file to the source and retain credits. |
| `sfx/collect_key.mp3` | Credits identify Musheran's [Item Pickup / Key](https://opengameart.org/content/item-pickup-key), CC0; renamed. Source listing and CC0 checked; used in level script. | Compare file to the source and retain credits. |
| `sfx/wings.ogg`, `sfx/wings_attack.wav` | Credits identify Joseph Sardin's [Solitary Bees or Flies](https://bigsoundbank.com/solitary-bees-or-flies-s0101.html), CC0; `wings_attack.wav` is a processed excerpt. Source page and CC0 checked; excerpt used by beetle. | Verify source identity and transformation; retain credits. Original has no direct source-text reference. |
| `sfx/wings_flap_large.ogg` | Credits identify AntumDeluge's [Large Wings Flap](https://opengameart.org/content/large-wings-flap), CC0. Source page checked; it describes an underlying chop sound. No direct source-text reference found. | Verify identity and underlying source rights; retain credits, or remove from distribution after dependency review. |
| `sfx/door_open_sfx_engine.wav`, `sfx/beetle_defeat_sfx_engine.wav`, `sfx/portal_whoosh_sfx_engine.wav`, `sfx/crate_break_sfx_engine.wav` | Credits identify SFX Engine generation IDs. All four have direct script references. The current [service terms](https://sfxengine.com/terms-of-service), sections 5–5.2, describe use in games but prohibit standalone redistribution and sublicensing of effects. | Determine generation date, account-specific terms and whether repository source distribution and downstream reuse are permitted; obtain written clearance or replace with appropriately licensed effects. Current terms alone do not establish historical terms or a transferable open license. |
| `music/background_sfx_engine.wav` | Credits identify SFX Engine generation and removal of an invalid outer WAV header. Used by `background_music.gd`. | Confirm applicable music-specific and historical terms, account rights, game packaging and source redistribution; obtain clearance or replace. Do not assume the effect terms settle music rights. |
| `music/menu_theme.wav` | Used by `background_music.gd`. On 2026-11-08 the project owner stated it was created with SFX Engine. `PROMPT_GEMINI.md` is a separate proposed prompt and does not establish this file's origin. | Record generation date, account and applicable music-specific terms, inputs and permissions for packaging and source redistribution; obtain clearance or replace. The generation record and historical terms have not been checked. |

## Review evidence and follow-up

- Enumerated tracked files with `git ls-files`, inspected repository licenses, credits, README, GDD, roadmap, backlog and source references using `rg`. `file` identified image and music formats. Exact baseline above excludes this documentation-only change; no game or asset file was changed.
- On 2026-11-08 checked Kenney's pack page and its CC0 designation, the linked CC0 listings for large wings, gem, key and BigSoundBank, the CC0 deed, and the current SFX Engine terms. The 512 Sound Effects page returned 403. The Kenney archive could not be fetched (network DNS unavailable); no original image or sound files were downloaded or compared and no source-page authorship was independently verified. The owner supplied the image source and menu music generator separately, as noted above.
- This audit does not prove that an export contains only these files, nor verify distribution terms for assets outside the tracked baseline, exact source-file identity, historical service agreements, or rights in generated inputs. No engine, import, export, human visual/audio, controller or playtest check was run: this change only documents existing files and does not change gameplay. Those checks remain necessary for relevant future asset replacements and release builds.
- Before any release or further source redistribution, resolve each unknown above, preserve evidence and notices, and review the exact distributable and its dependencies. Prioritize SFX Engine standalone files and active images/music; replacement must include appropriate functional and human audiovisual verification. No asset has been cleared merely by this inventory.
