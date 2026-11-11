# GDD — The Path of Lights

**Game Design Document · version 0.6 · November 6, 2026**  
**Status:** Initial proposal for review and testing. The title, names, figures, and scope are subject to validation.

## 1. Vision

*The Path of Lights* is a side-scrolling 2D platformer for one or two players in local co-op. Two young explorers travel through landscapes full of paths, secrets, and curious creatures to bring light back to a disconnected world.

The aim is to create a short, cheerful, memorable family adventure with the clear controls, variety, and charm of SNES-era platform games. Every level should offer something new, be fun on its own, and contain at least one reason to return. The quality target is comparable to a successful indie game: this is a design aspiration, not a commercial guarantee.

The project is also an experiment in the capabilities of a 2D game development agent: designing, implementing, testing, and improving a complete game with human direction and evaluation. The experiment's success depends both on the quality of the experience and on the ability to document decisions and correct problems.

### Pillars

1. **Easy to start, interesting to master:** moving, jumping, and interacting are enough to understand the game; combinations add depth.
2. **An adventure to share:** the whole story works both solo and with two people on the same screen.
3. **Curiosity rewarded:** alternate routes, secrets, and small surprises invite exploration without blocking progress.
4. **Fair, progressive challenges:** the game teaches before it demands, but completing each level requires practice, attention, and effort. Assists are configurable.
5. **Short and replayable:** short levels, a compact campaign, and rewards that give players new reasons to return.

## 2. Audience and intended experience

- **Audience:** families and players approximately five years old and up, including newcomers and people who enjoy mastering platformers.
- **Experience:** feel curious, discover solutions, celebrate small achievements, and share the adventure. Optional challenges offer greater difficulty.
- **Accessibility target:** clear visual information, little reliance on reading, simple controls, and optional assists. A five-year-old being able to complete the adventure is a design goal to be tested with children of different abilities and, where appropriate, adult accompaniment; it is not assumed to have been achieved.
- **Initial platforms:** PCs running Linux, macOS, and Windows, and web browsers through an HTML5 export. Keyboard and controllers; specific compatibility remains to be tested.
- **Distribution:** free and open source. The code license, art asset licenses, and publishing platform are yet to be chosen; third-party assets must be reviewed to ensure they permit the intended use and distribution.
- **Consoles:** a future port will be considered if the game gains popularity. Official Godot distributions do not include templates for common consoles; a port may require a third-party provider or a custom port with authorized access to the platform's tools ([Godot documentation](https://docs.godotengine.org/en/4.2/tutorials/platform/consoles.html)).
- **Initial language:** Spanish, with an interface prepared for additional languages.

## 3. Duration and scope reference

The reference is the original NES *Super Mario Bros.* A collection of player times puts its main story at around **two hours**, though results vary with experience, retries, and shortcuts ([Grouvee](https://www.grouvee.com/games/105591-super-mario-bros/)). The original has eight worlds with four levels each ([GameFAQs guide](https://gamefaqs.gamespot.com/nes/525243-super-mario-bros/faqs/66598)). These figures guide the design; they are not exact for every player or a requirement to copy its difficulty or structure.

**Initial targets, subject to testing:**

| Measure | Target |
|---|---|
| First story playthrough | Around 2 hours for a player with basic platforming experience; initial design range of 1.5–3 hours without seeking every secret. |
| First playthrough by a child | No fixed limit; measure separately with players aged 5–7 and adjust assists and difficulty. |
| Standard level | 2–4 minutes in a smooth run for someone familiar with it; exploration and retries add time. No mandatory timer. |
| Target structure | 8 worlds × 4 levels = 32 short levels; the fourth in each world is a finale or special encounter. |
| Replayability | Secrets, challenges, and unlocks extend the experience without being required to see the ending. Additional duration remains to be measured. |

With 32 levels of 2–4 minutes, a smooth run totals approximately 64–128 minutes before transitions; learning, exploration, and retries add time. Both measures will therefore be tracked separately, and level count, length, or density adjusted if the target is missed. Mastery routes may shorten a replay, but should not let players accidentally skip most of the adventure.

## 4. Story and world

### Premise

The lights connecting the world's small landscapes have been scattered by a mischievous wind. Paths have gone dark and their inhabitants can no longer visit one another. Lila and Sol set out to find the eight main lights, relight the paths, and reunite their neighbors.

The story is told mostly through animation, visible changes to the map, gestures, and short skippable scenes. The tone is warm and curious, with visual humor and gentle mystery. There is no explicit violence or frightening imagery. Text complements the action and does not contain essential instructions without visual support.

### Narrative structure

- **Beginning:** a visual sequence shows the wind scattering the lights and blocking the paths. The first path teaches walking, jumping, and finding a key.
- **Development:** completing each world restores a light; the map lights up and its inhabitants reconnect. Portals hide visual glimpses of life in the world.
- **Ending:** in the final world, the explorers reach the source of the wind and help it calm down through a platforming encounter. The lights return and the inhabitants celebrate. The main ending does not require every secret.
- **After the ending:** the world remains accessible for revisiting levels and completing optional challenges.

### Characters

| Character | Role and personality | Gameplay design |
|---|---|---|
| **Lila** | Curious, observant, and patient explorer. | Selectable character with her own silhouette and expressions. |
| **Sol** | Cheerful, impulsive, and friendly explorer. | Second selectable character; same abilities as Lila. |
| **Prototype character** | Current character used to test the game and remember its origins. | Unlocked after completing the campaign for the first time; abilities equivalent to Lila and Sol. |
| **Chispa** | Small luminous guardian who accompanies the adventure and suggests the way when help is requested. | Optional hints using icons and animation; never solves a challenge automatically. |
| **The Wind** | Mischievous force that scattered the lights out of curiosity, not malice. | Narrative presence and final encounter based on visible patterns. |
| **Guardian beetles** | Inhabitants confused by the lack of light. | Obstacles with predictable behavior; jumping on them neutralizes them and they recover in a gentle manner. |

**Decision:** the current character remains a prototype for testing and becomes an unlockable playable character after the first campaign completion. The unlock will be accompanied by a development curiosity based on documented facts. Lila and Sol will be available from the start and designed for the story and co-op; their names and designs remain provisional. Creative direction is not limited to current assets: original characters, creatures, environments, and animations will be created as the game requires.

### Lila and Sol: protagonist design

**Shared concept.** Lila and Sol are two young inhabitants of the Valley of Paths, friends, and apprentice explorers. Their home is a place where lights keep communities connected. Both have simple, expressive proportions, visible hands and shoes, and shapes that read well in pixel art. Their exact ages and species remain open for visual exploration; their appearance should be friendly and approachable without relying on realism. Their silhouettes, accessories, and movements distinguish them even without color.

#### Lila

- **Appearance:** compact, rounded silhouette, short dark hair, and a recognizable curved lock. She wears a short violet cape with a light edge, a simple tunic, comfortable trousers, and sturdy boots. A small map notebook hangs from her belt; its rectangular shape should be recognizable without text. Violet and cream tones contrast with the background and with Sol; the cape must not hide her feet or character boundaries.
- **Personality:** curious, observant, and patient. She likes noticing details and drawing what she discovers. Sometimes she thinks so much before acting that she doubts herself; when things depart from her plan, she learns to improvise. She is kind, but can also get carried away and make mistakes.
- **Backstory and motivation:** before the adventure, she helped Mora record the valley's paths in her notebook. When the lights scatter and the path to Mora's garden goes dark, Lila wants to reconnect the places she has drawn and discover those still missing from her map.
- **Gestures:** when idle, she looks around or briefly checks her notebook; on discovering a secret, she widens her eyes and points; on recovering a light, she makes a small mark on her map. These expressive animations do not interrupt control.
- **Arc:** she starts by trusting what is familiar and comes to accept that exploring also means moving forward without a complete map.

#### Sol

- **Appearance:** a slightly taller silhouette, tousled brown hair forming two soft points, and a short amber scarf with visible ends. He wears a teal jacket, comfortable trousers, and boots; a small round backpack completes his profile. Accessories stay close to his body so his silhouette and feet remain clear.
- **Personality:** cheerful, expressive, and friendly. He greets inhabitants and often rushes to try an idea first. His enthusiasm sometimes makes him act too quickly; he learns to pause, listen, and find another way without losing his curiosity.
- **Backstory and motivation:** before the adventure, he helped Nimbo carry small messages between neighbors. When the paths go dark, Sol wants to reunite his friends and discover why the wind scattered the lights.
- **Gestures:** when idle, he waves or rocks energetically; on finding a secret, he gives a small jump of joy; on restoring a light, he raises his arms and looks toward the open path. Animations do not change movement or control responsiveness.
- **Arc:** he starts out thinking every problem is solved by moving quickly and learns that listening and observing are also ways to help.

#### Relationship and presence in the adventure

Lila and Sol know each other from traveling through the valley: she drew the paths and he carried messages along them. They complement each other without one always being the clever one and the other the impulsive one: both can observe, act, ask for help, and be surprised. Their friendship is conveyed through small gestures, such as sharing a map, pointing out a route, or celebrating with the inhabitants.

At the beginning, Mora notices that the path to her garden has gone dark and Nimbo cannot deliver a message to his friends. Lila and Sol see Chispa trying to gather a scattered light and decide to help. The scene establishes their motivation without requiring reading. In solo play, the player chooses Lila or Sol and completes the whole adventure with that character; the other may appear in brief map scenes or celebrations without intervening in or solving obstacles. In co-op, both participate under player control. Their differences are narrative and visual: speed, jump, health, and interactions are equivalent.

**Production guidance:** create a reference sheet for each character with front, side, and back views; idle, running, jumping, falling, damage, and celebration poses; and examples together against light and dark backgrounds. Test silhouettes at actual in-game size and in grayscale, ensuring hair, cape, scarf, and backpack do not obscure the point of contact with the ground. These designs are an initial creative direction, not assets already created; they will be adjusted after sketches and readability tests.

### Original inhabitants and creatures

| Character or creature | Role in the story | Interaction and presentation |
|---|---|---|
| **Mora, the mole gardener** | Tends the first world's paths and shows how the lights help her neighbors. | Gestures toward the first key and celebrates when the path is restored; her hints can be skipped. |
| **Nimbo, the messenger cloud** | Looks for scattered friends and appears across several worlds. | Offers optional visual hints about secret routes; reuniting with friends changes a map scene. |
| **Tilo, the tortoise inventor** | Maintains the portals and wants to reconnect the landscapes. | Introduces a portal with a brief demonstration; his inventions add humor without blocking progress. |
| **Brotín, the seed creature** | A small neighbor who has lost the way. | Follows a safe route to its garden when found in a secret; rewards an illustration, never a mandatory quest. |
| **Leafhopper** | Playful forest creature. | Jumps in a visible pattern and pauses before crossing; moves aside without explicit harm when jumped on. |
| **Armored snail** | Peaceful cavern guardian. | Patrols slowly; its shell protects its top, so players dodge it when it retracts. Defeating it is not required. |
| **Wind bubble** | Mischievous fragment of the Wind in the hills. | Inflates before releasing a short gust marked by arrows and particles; provides safe space and a pause between gusts. |
| **Lantern moth** | Nocturnal inhabitant confused by the scattered lights. | Flies along a signaled path; can be dodged or neutralized with a jump, then recovers its glow. |

Inhabitants enrich the story through brief encounters and gestures; none requires reading or turns the main route into a chain of quests. Each new creature will be prototyped separately and introduced in a safe area before being combined with other hazards. Their names and appearances are provisional; visual and audio assets will be created during production.

## 5. Goals and gameplay loop

**Main goal:** reach the end of all eight worlds and recover their lights. Each level requires reaching its exit; where there is a locked door, first obtain its key, placed on the main route and visually signaled.

**Optional goals:** collect diamonds, find one secret per level, visit portal rooms, and complete challenges. None is required for the main ending.

**Core loop:** choose a level → observe and learn a situation → advance by jumping, dodging, and exploring → find the exit → receive a celebration and save progress → choose the next level or return to an earlier one.

## 6. Mechanics

### Core actions

| Action | Function | Design principle |
|---|---|---|
| Move | Travel in either direction through the level. | Immediate response and readable terrain. |
| Jump | Clear gaps, reach platforms, and neutralize beetles from above. | Consistent heights and distances; coyote time and jump buffering. |
| Interact | Enter portals and open nearby doors. | Invite discovery with contextual visual cues such as a gentle glow; avoid accidental jumps when interacting. Test whether players recognize the interaction without explicit instructions. |
| Climb | Move up or down identifiable ladders. | Safe introduction before combining them with hazards. |
| Hit crates from below | Obtain a diamond, key, or heart, or discover an empty crate. | Shape and audiovisual feedback teach their purpose. |

Moving platforms, spikes, and saws add variety. Hazards are signaled by shape, movement, and sound, not color alone. A new mandatory action is not introduced in every world: variety comes from combining familiar elements.

### Health and recovery

In standard mode, players start with three hearts. A hit or fall costs a heart; if hearts remain, a fall returns the character to the last safe point while retaining items collected during that attempt. **When all hearts are lost, the current level restarts from the beginning**, hearts are restored, and items from that attempt, including the key, are reset. Previously recorded secrets and completed levels are retained. Heart pickups restore health. Safe points help within an attempt but do not prevent a level restart when hearts run out. Their placement and exact balance will be determined through testing.

Standard difficulty should be moderate and progressive: it encourages learning patterns, practicing jumps, and completing the level through effort, inspired by the satisfaction of classic platformers. Mistakes have clear consequences, but obstacles must be readable and offer reasonable opportunities to learn. Accessibility from age five remains a goal to validate, not a promise that everyone can succeed without help.

**Optional assist:** more hearts, more frequent checkpoints, and returning after falls without losing a heart. It can be enabled at any time without penalties or blocked content; even with assists, losing all hearts restarts the level. Existing jump assists will be calibrated for everyone; wider margins in this mode will be evaluated. The aim is to reduce frustration without removing the satisfaction of overcoming an obstacle.

### Enemies and encounters

The beetles and proposed creatures have distinct behaviors and understandable paths; side contact with beetles causes damage, while jumping on them neutralizes them. No enemies are introduced off-screen or with impossible-to-anticipate attacks. Finale encounters use short patterns with a visible preparation phase and a safe space; they do not require complex simultaneous reflexes. Assist mode extends reaction windows if testing supports it.

## 7. Local co-op

Two players can traverse the campaign simultaneously on a shared screen. Each controls Lila or Sol, or the prototype character after unlocking it; all have equivalent abilities. There is no friendly fire or physical collision between players. All mandatory paths and mechanisms can be completed by one person.

- The camera tries to keep both visible; if they separate too far, the trailing player returns to safe ground near their partner after a visual cue. There is no penalty for this relocation.
- Each player has their own hearts. If one runs out, they are temporarily out and respawn on safe ground near their partner with one heart after a short wait. If both run out of hearts at the same time, the current level restarts from the beginning and both players' hearts are restored. Assists also apply in co-op.
- The key and level progress are shared; either player can open the door. To leave, both active players must reach the exit area, with safe relocation to prevent deadlocks.
- The second player can join or leave at a safe point. Two controllers or keyboard plus controller are planned; control assignment and remapping must be tested.
- There are no mandatory puzzles requiring two people. Some optional routes may be more fun together, but must have a solo solution.

These rules are proposed design; camera, input, health, and two-player transitions require implementation and dedicated tests.

## 8. Level structure

Each world contains four levels: **safe introduction → combination → variation and exploration → finale**. A new idea is presented in a low-risk setting, then practiced and combined with known elements. Each level has a readable main route, an optional secret, and an optional challenge; shortcuts reward mastery without being necessary. The design must support pauses and short sessions.

| World | Identity and main elements | World finale |
|---|---|---|
| 1. Luminous Path | Meadows; movement, jumping, diamonds, crates, and a key. | A short route combines the learned elements and recovers the first light. |
| 2. Stone Garden | Ladders, heights, and beetles with clear paths. | Guardian encounter teaching observation and jumping. |
| 3. Portal Forest | Leafhoppers, portals, and secret rooms; routes above and below the main path. | A route combining portals and familiar platforms. |
| 4. Shimmering Stream | Slow moving platforms and jumps with generous timing. | Platform crossing with safe areas in between. |
| 5. Windy Hills | Wind bubbles and visible currents that gently alter movement; effect to be prototyped. | Crossing with telegraphed gusts and shelters. |
| 6. Crystal Caverns | Armored snails and lantern moths, clear visibility, alternate routes, and telegraphed moving hazards. | A route involving observation and safe pauses. |
| 7. Sky Gardens | Combines ladders, moving platforms, and portals without introducing a new action. | Moderate precision challenge with checkpoints. |
| 8. Wind's Path | Recap of mastered elements and approach to the source of the Wind. | Final encounter with readable patterns and restoration of the lights. |

Themes, new elements, and encounters are proposals; their difficulty and feasibility will be tested before building all 32 levels. The existing first level may serve as a reference, but its actual length must be measured and adjusted to the target.

## 9. Progression and replayability

- Completing a level opens the next; completing the fourth restores the world's light and opens the next world. The map allows players to revisit completed levels.
- Each level proposes **one main secret**, recorded when found, and optional diamonds. Diamonds contribute to a collection and may unlock visual appearances; they are not spent to open levels or permanently lost.
- Completing the campaign for the first time unlocks the prototype character and a curiosity about its role in development; the unlock is saved and the character can be selected for replays.
- Completing each world unlocks an illustration of its inhabitants. Completing the campaign opens **Exploration mode**, with level selection, a secret log, and optional mastery challenges such as reaching an alternate goal or completing a route with fewer checkpoints.
- After campaign completion, an optional harder challenge will be evaluated in which losing all hearts requires restarting the current world from its first level. Availability, exact rules, and balance await testing; it does not apply to the standard campaign.
- Rewards include new sections, curiosities, cosmetics, and voluntary challenges; they do not increase power needed to complete the story. No advanced challenge is mandatory for children or novice players.
- A replay should offer a concrete choice: seek a route seen before, discover a secret, complete a challenge, or share the level with another person. The game does not rely on randomly generated levels.

### Discovery paths after the ending

Completing the campaign for the first time opens **discovery paths** in familiar levels. A new map marker and a visible entrance within the level indicate where to explore; the player can select those levels without replaying the entire campaign. Each path is an optional handcrafted section with a small platforming challenge and a reward to discover. It works solo and in co-op, retains progressive difficulty, and does not change the main route or ending.

The initial target is one path per world, eight in total, subject to testing and production scope. On finding its reward, it is recorded in a **discovery album** accessible from the map. The album and discovered paths are saved; entering again allows the section to be replayed. The final number and locations will be decided after testing an initial section.

Each discovery belongs to one of these categories, identified by an icon, shape, and short label:

- **Our World:** real facts related to the environment, its creatures, or the game. Each fact must be verified against reliable sources before publication; its source will be kept in project materials and a reference made accessible from the album. Speculation is not presented as fact.
- **The World of Lights:** invented stories and curiosities expanding the story, inhabitants, and places. For example, an illustration could tell how Mora planted the first luminous garden; it will be clearly presented as fiction.
- **How We Made the Game:** sketches, decisions, mistakes, and development lessons, including work with the agent where relevant. Only documented and reviewed facts will be shown; anecdotes will not be invented. Content should be interesting to the player and not depend on lengthy technical explanations.

Rewards are presented through illustrations, animation, or short scenes with simple, optional text; optional narration may accompany them when possible. Category labels also help children and adults distinguish fiction from reality. No curiosity requires reading to progress or is needed to complete the campaign.

Exact quantities of diamonds, appearances, curiosities, and challenges will be determined after the prototype to avoid filler content.

## 10. Art direction, audio, and interface

**Art:** original 2D pixel art inspired by the warmth and visual richness of the SNES era, without copying third-party characters, graphics, or music. Rounded, expressive silhouettes; layered backgrounds with subtle movement; each world has its own palette and dominant shape. Players, solid platforms, and hazards must stand out from the background even in motion. Keys and important objects use shape and icon as well as color. Avoid intense flashes and visual overload.

**Animation:** clear gestures for joy, damage, and victory; warning signals before dangerous movements. The priority is for players to understand what is happening, including in co-op.

**Audio:** cheerful melodies with recognizable motifs for each world and variations for secrets and the ending. Short, distinct effects for jumping, damage, rewards, doors, and checkpoints. Music and effects have independent volume controls; no essential information is conveyed by sound alone. Verify licenses and provenance of all assets before publication.

**Interface:** clear hearts per player, discreet key and diamond indicators, and contextual visual cues that invite discovery; a map with completed levels and open routes. Visual hints without mandatory reading, brief text, and easily accessible pause and options. Avoid relying exclusively on colors or timers. Test whether the cues make interactions discoverable without displaying an action instruction.

## 11. Current project status

A file review describes a Godot 4.8 foundation with two levels and reusable scenes for the character, moving platforms, ladders, hazards, beetles, doors, crates, and portals. The README documents diamonds, keys, a secret chamber, three hearts, and return after falls. The movement code includes coyote time, jump buffering, and corner correction. Visual assets, music, and sound effects with sound credits are present.

This was a static review: no playtest was performed for this document. The story, eight worlds, level selection, persistent saves, unlocks, assist mode, and co-op described here are proposals, not verified features. The current README describes restarting the level when hearts are exhausted, consistent with this GDD's standard direction; the details and co-op behavior must be checked during implementation and testing.

Subsequent E03-01 prototype work persists the existing completion and secret-portal records with versioned local saves, backup recovery and a defined migration fixture. See [ADR 0001](docs/adr/0001-campaign-state.md) and [campaign save evidence](docs/campaign-save-evidence.md). Attempts are not resumed after closing the application; the map, rewards/unlocks, co-op and browser/export persistence remain unverified or future work.

Subsequent prototype work implements configurable solo assists in the two experimental levels: extra hearts, more frequent authored safe points and falls without heart loss. See [ADR 0005](docs/adr/0005-configurable-assists.md) and [assist evidence](docs/accessibility-assists-evidence.md) for the implemented rules, automated checks and remaining human evaluation. This does not establish accessibility, co-op assists or approval of the broader proposed scope.

## 12. Scope and production

### First milestone: representative playable slice

Build one world of four short levels with an introduction, combination, secret, and finale; prototype one post-ending discovery path with its entrance, reward, and album record; include preliminary final controls, assist mode, saving, level selection, and local co-op. Adapt reusable project elements, measure the actual length of current levels, and verify asset licenses. The milestone must demonstrate fun and clarity before expanding the campaign.

### Second milestone: complete campaign

Produce the remaining worlds with the approved structure, encounters, visual narrative, audio, and unlocks. Maintain a content list for each level and check that each has an identity and a secret without repeating obstacles solely to meet the target count.

### Third milestone: quality and release

Fix observed problems, balance assists, optimize, review accessibility and licenses, and test the distribution build on the chosen platforms. No release date or budget is defined here. Test Linux, macOS, and Windows builds and the web version in target browsers and devices. Godot 4 web export requires WebAssembly and WebGL 2.0 with the Compatibility renderer; thread configuration may impose server requirements. Validate saving, audio, controls, performance, and hosting in real browsers ([web export documentation](https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_web.html)).

**Priority:** controls and readability → a completable solo campaign → reliable co-op and saving → level variety → secrets and presentation → extras. If scope proves unviable, first review the number of levels and extras based on the playable slice, preserving a complete, short, satisfying adventure.

## 13. Validation and acceptance criteria

| What to check | Test and desired signal |
|---|---|
| Initial clarity | Observe players without prior instructions; record whether they understand movement, jumping, keys, and exits through the environment and icons. |
| Age and difficulty | Test with children aged 5–7 with appropriate accompaniment and adults of varying abilities; record comprehension, retries, full level restarts, help requested, satisfaction in overcoming challenges, frustration, and abandonment. Adjust assists and obstacles; do not extrapolate from one person. |
| Duration | Measure active and total time, retries, and exploration during the first playthrough; separate by age, experience, solo, and co-op. Compare with the approximately two-hour target for basic experience. |
| Co-op | Complete every level with one and two players; test camera separation, falls, respawning, joining/leaving, controls, and doors without deadlocks or lost progress. |
| Saving | Close and reopen the game after levels, secrets, and unlocks; check that they are restored correctly. |
| Replayability | Complete the campaign and check that the prototype unlock is saved and selectable on replay, discovery paths appear and their entrances work solo and in co-op, and the album retains discoveries after restarting the game. Observe whether players return, recognize curiosity categories, and find rewards interesting. No secret may block the ending. |
| Technical quality | Verify keyboard and controller input, readability, audio, stability, options, and operation on target devices. Record and fix defects before distribution. |
| Experiment quality | Keep decisions, tests, errors, and fixes traceable; have humans evaluate the result and the agent's contributions. |

Numerical success targets, sample size, and specific devices will be defined before formal evaluation. Classic inspiration and comparison with a successful indie game do not replace testing with real players.

### Telemetry and playtest analysis

**Proposal, not yet implemented:** instrument the playable slice to produce logs that help locate obstacles, calibrate difficulty, and study whether people want to continue playing. The data complement observation and questions to players: a pause or exit alone does not prove boredom or frustration.

| Question | Minimum log | Analysis |
|---|---|---|
| Where do players get stuck or take damage? | Level version, attempt, position in level coordinates, event type, and obstacle when identifiable: damage, fall, loss of hearts, and restart. | Cell-based heatmaps over an image of the level; compare events with the number of attempts or passes through each area to avoid confusing popularity with difficulty. |
| Which parts are hard or easy? | Level and attempt start/end, active time excluding pauses, outcome, damage and restart counts, mode, active assists, and player count. | Completion rate and distribution of time, damage, and restarts per level and attempt. Many failures followed by improvement may indicate learning; few failures alone are not enough to conclude a level is too easy. |
| Do players want to continue? | Session start/end, level progress, next-level selection, return to levels, and access to optional paths. | Share starting the next level among those who finished the previous one, and share returning in a later session when voluntary participation permits linking sessions. Compare with brief optional questions about enjoyment and desire to continue. |

Positions are grouped into cells of configurable size, with a map version identifier to avoid mixing different designs. Log events when they occur and, if measuring dwell time or paths is needed, sample positions at moderate intervals during active play; exclude pauses and document the interval. Compare solo and co-op, active assists, and level versions separately. Present counts and denominators alongside the map; do not set difficulty or interest thresholds before gathering data and observing a diverse sample. When interpreting return rates, use only sessions with consented tracking and a defined period; an exit, disconnection, or time limit alone does not mean abandonment.

**Privacy and control:** telemetry is off by default and enabled voluntarily for testing; for minors, with the knowledge and authorization of their responsible adult. Collect only gameplay events, without names, contact details, exact age, chat, audio, or device identifiers. Initially store logs on the device and allow explicit review, deletion, and export; do not send them automatically to a server. On the web, test storage and export in each browser and warn that local data may be deleted. Use a random session identifier and, only if return measurement is accepted, a revocable random local identifier; delete both with the logs. Define a retention period and the party responsible for any analysis before collecting data. Participation does not affect gameplay or unlocks.

**Instrumentation validation:** in a test level, check that positions and events appear in the correct cells, times exclude pauses, rates use correct denominators, disabling the option stops capture, and deletion works on PC and web. Test with fictitious data before collecting real sessions; check whether logging affects performance.

## 14. Open decisions

1. Review and approve the title, names, and proposed visual direction for Lila and Sol; define the prototype character's visual identity and create reference sheets.
2. Measure the two existing levels and decide whether to split or adapt them for the proposed structure.
3. Use a playable slice to validate whether 32 levels and co-op are feasible with available resources.
4. Specify the quantity and unlock conditions for cosmetics and challenges.
5. Define minimum operating system and browser versions, test devices, technical requirements, and quantitative targets; choose licenses and distribution channels.
6. After campaign completion, evaluate whether the optional restart-the-world challenge is enjoyable and what rules and rewards it should have.
7. Test the first discovery path and decide how many to produce, what mix of curiosities to include, and whether to add recorded narration.
8. Define the telemetry schema and retention, export and visualization methods, and voluntary test design before collecting data.
