# Existing levels: measurement baseline

Status: **owner-accepted exploratory baseline** for [E01-01](backlog/issues/E01-01.md), with the evidence limitations below. On 2026-11-08 the project owner requested closure with the data available: no other participant is currently available, and these levels are experimental test levels, not planned story or GDD level designs. The level 2 first play is self-reported and build provenance has limitations. These observations do not establish difficulty or accessibility for the intended audience.

## Build and static inventory

The inspected source is commit `73b526cfa3a05ef4bd3078cd570a22821ce310c6`, with a clean tracked and untracked working tree before this documentation was added. The user confirmed that the reported sessions used this local project with no game changes between sessions. At the time of confirmation, HEAD was that commit and the only working-tree changes were this baseline and the documentation index. On 2026-11-08 the user confirmed that the sessions used Godot 4.8 beta 2 on the same Linux development machine. This identifies the reported engine version and source, but does not independently establish the engine binary's exact build identifier, historical import cache or any external build artifacts. Godot `4.8.beta2.official.cafc17a19` was used for the checks below; the session binary's identifier was not confirmed. Future measurements must record the actual commit, local changes, engine/export version and device used.

| Level | Source evidence | Questions for observation and reuse |
| --- | --- | --- |
| 1 | `src/scenes/adventure_level_1.tscn` contains a key, door, hazards, enemies, crates, a portal entrance and exit, and secret-area collectibles. `first_level.gd` directs the door to level 2. | Can the main route be completed without entering the portal? Is the secret noticed and entered? Measure both the main route and voluntary exploration before deciding whether to retain, adapt or split it. |
| 2 | `src/scenes/adventure_level_2.tscn` contains a key crate, door, ladder, hazards, enemies, moving platforms and collectibles. | Is the key and exit understandable? Measure the route and difficulty before deciding whether to retain, adapt or split it. A secret for this level is not established by this inventory. |

These are source observations, not evidence of accessibility, successful completion, optionality, asset rights or suitable level length. Reuse of assets also depends on the separate provenance audit. The GDD's 2–4 minute smooth-run range is a provisional design target, not a measured result or approval to expand the campaign.

## Observation protocol

Use a human-operated build and a separate observer with a stopwatch and notes; no telemetry is added by this task. Record first attempts before giving route advice or showing a smooth run. Use a participant unfamiliar with the relevant level for each first attempt, and disclose prior experience. For a smooth run, use someone familiar with the route after practice; record practice and route used. Do not call a restarted run a first attempt. A first attempt can end in completion, abandonment, or a session limit; record the outcome rather than excluding failures.

For each level start timing when the player gains control and stop on the transition out of that level, or at the documented stopping point. Record wall-clock total and paused time separately; active time is total minus paused time. Include retries and full level restarts within the first-attempt session, and record each separately. Count each loss of all hearts as a death/full restart; count falls and other damage separately so a lost heart is not confused with a death. If a count or pause duration was missed, mark it unknown rather than zero. Record secret entrance, return, and items actually observed, distinguishing not found from not applicable or unknown. Record whether optional exploration was included and any help or interruptions.

Use anonymous participant codes, broad experience and age group only, never names, contact details, exact ages, audio or device identifiers. Participation is voluntary; obtain appropriate responsible-adult consent and accompaniment for minors. Before recording real observations, agree who holds the notes, retention period, and how participants can request deletion. Keep identifiable or raw notes outside the repository; publish only consented, non-identifying summaries. Do not infer frustration or enjoyment solely from retries or an exit. Formal sample sizes and targets remain part of E01-04.

### Session record template

Copy one record per participant, level and run type into an appropriately controlled location. Avoid revealing a secret before first attempts.

```text
Session date and anonymous participant code:
Age group / platforming experience / familiarity with this level:
Observer code; consent and retention arrangement confirmed (yes/no):
Commit and local changes; engine/export version; OS/device and controls:
Level and run type (first attempt / practiced smooth run):
Solo/co-op; assists or settings; practice and route used:
Start/end event; outcome (completed / stopped / abandoned):
Total time; paused time; active time (or unknown):
Full restarts/deaths; falls; other damage; retries (or unknown):
Secret discovered / entered / returned; rewards observed (or unknown/not applicable):
Help requested or given; interruptions; relevant observations:
Evidence reference and limitations:
```

## Results and reuse decisions

The owner accepted an exploratory baseline and closure with the available evidence. No additional tester is currently available. The level 2 first attempt was self-reported rather than separately observed; timing and historical build provenance have limitations. Individual session details are excluded from this publication.

The owner clarified that the two levels are experimental test levels, not planned story or GDD level designs. An earlier proposal to retain and adjust them was superseded. Reuse of individual mechanics or assets remains undecided, subject to further testing and the separate rights audit.

## Technical checks on the inspected commit

On Linux with Godot 4.8 beta 2, `--headless --path . --script` was used with:

| Script under `res://src/tests/scripts/` | Observed result |
| --- | --- |
| `bonus_route_integration.gd` | PASS: the three scripted ascending bonus-route jumps reached their target heights. |
| `fall_depletion_integration.gd` | PASS: three scripted falls consumed hearts and restarted an expanded level. |
| `two_levels_integration.gd` | Initial run failed its portal-edge jump assertion while Godot could not write its user logs. A repeat, followed by five consecutive further runs with `XDG_DATA_HOME=/tmp/path-light-test-data` and `XDG_CONFIG_HOME=/tmp/path-light-test-config`, passed its portal-edge, transition, ladder and key assertions (exit 0 each). This does not establish the cause of the initial failure or rule out intermittency. |

The checks emitted GameMode D-Bus permission errors and ObjectDB leak warnings; the repeated two-level test also reported resources still in use at exit. The Godot editor MCP bridge was disconnected. Headless scripted checks do not measure human time, validate complete routes, establish first-attempt experience or verify visual quality, audio, controller input or co-op. The available reports provide limited first-attempt evidence, not a full assessment of those areas. Independent verification identified the level 2 self-report and historical build identity as acceptance-evidence limitations; it did not conduct a playtest. The user subsequently confirmed the engine version and machine as described above.
