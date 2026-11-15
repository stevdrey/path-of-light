https://github.com/stevdrey/path-of-light/pull/49#discussion_r4577070881

**[Medium — competing menu transitions]** The deferred MAPA callback has no detached-scene guard. `_open_map()` sets `map_requested` and schedules this call, but `_play()` can still call `change_scene_to_file()` immediately if JUGAR is activated before the deferred callback. That can leave this callback calling `MapNavigation.open(get_tree())` on a detached menu (`get_tree()` may be null). Please serialize/guard both actions and check `is_inside_tree()` before accessing the tree. Add a same-frame MAPA→JUGAR regression and verify that no extra scene request or script error occurs.

https://github.com/stevdrey/path-of-light/pull/49#pullrequestreview-5909156349

## Code review — follow-up required before merge approval (E03-02)

Reviewed the current head `31fbf6e` against issue #19, ADR 0006, registry/unlock rules, map/menu/pause/completion navigation, reset/carry-over behavior, integration tests, prior review feedback and committed verification artifacts. The implementation addresses the ten author-reported fixes, and the existing test suite exercises the core two-level map functionality. However, **approval is pending**:

1. **[Medium — navigation lifecycle]** `front_end.gd` guards repeated MAPA requests but does not coordinate them with `JUGAR`. If the menu receives an Open Map action and a Play action before the deferred map callback runs, `_play()` can detach the menu while `_finish_open_map()` subsequently calls `MapNavigation.open(get_tree())` without an `is_inside_tree()`/request-state guard. Please make these menu transitions mutually exclusive and test conflicting actions in the same frame, including safe detachment and retry. This is a **source-level risk**, not a runtime-reproduced failure in this review.
2. **[Medium — exact-candidate verification]** The independent PASS, source manifest (`464ba9d…`) and 25/25 retained runtime logs refer to the **pre-fix** candidate `4583ed9`. Current head `31fbf6e` changes 13 files, including production navigation, attempt resets, input handling, and the default test runner. The author's fresh 25/25 run is reported in discussion, but has no committed logs or independent verification bound to this exact revision. Please publish a final source/tree manifest and independent focused verification of this head, including Space on completion, pause-to-map and main-menu action conflicts; distinguish implementation runs from independent checks.

No GitHub Actions checks are attached to this head; I did **not** run Godot here. Human/controller/accessibility/export/browser/platform checks may remain clearly documented as future work for this scoped two-level prototype, not release validation.

**Verdict: not approved yet; no merge performed.**
