# Import and integration-test baseline

Evidence for [E01-03](backlog/issues/E01-03.md), recorded 2026-11-08. This is a local development baseline, not a release or cross-platform reproducibility claim.

## Build and environment

The source was the clean tracked tree at commit `16e35e773aff51df61a13bf5723efd171f3bf358`. Two independent directories were populated with `git archive HEAD`; neither contained `.godot/` or ignored `.import` files. This reproduces tracked source, not untracked local changes or a network clone. The host was Linux `7.2.15-300.fc45.x86_64`, x86-64; Godot was `4.8.beta2.official.cafc17a19`, executable SHA-256 `34d0599a1f17acc76583610969878065d1b1701615af77271e32201351b9c564`. Both imports used the same binary and machine. No export templates or exported build were tested.

## Reproduce

Use a clean checkout at the desired commit, a Godot 4.8 beta 2 executable, Git, Python 3 and `timeout`. Set `GODOT` to its executable path. Use a new temporary directory: these commands write generated files there, not in the checkout. Inspect the logs as well as exit codes; Godot can report errors and still exit zero.

```sh
GODOT=/path/to/Godot_v4.8-beta2_linux.x86_64
BASE=$(mktemp -d)
mkdir -p "$BASE/a" "$BASE/b"
git rev-parse HEAD
git status --short
"$GODOT" --version
git archive HEAD | tar -x -C "$BASE/a"
git archive HEAD | tar -x -C "$BASE/b"
for copy in a b; do
  XDG_DATA_HOME="$BASE/data/$copy" XDG_CONFIG_HOME="$BASE/config/$copy" \
    "$GODOT" --headless --path "$BASE/$copy" --editor --import > "$BASE/import-$copy.log" 2>&1
  echo "$copy import exit: $?"
done
BASE="$BASE" python3 - <<'PY'
import os
from pathlib import Path
base = Path(os.environ['BASE'])
def metadata(copy):
    root = base / copy
    return {str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*.import')}
a, b = metadata('a'), metadata('b')
print('counts:', len(a), len(b))
print('different paths:', sorted(a.keys() ^ b.keys()))
print('different contents:', sorted(k for k in a.keys() & b.keys() if a[k] != b[k]))
PY
for test in health_integration fall_depletion_integration bonus_route_integration two_levels_integration pause_menu_integration; do
  XDG_DATA_HOME="$BASE/data/test-$test" XDG_CONFIG_HOME="$BASE/config/test-$test" \
    timeout 120 "$GODOT" --headless --path "$BASE/a" --script "res://src/tests/scripts/$test.gd" > "$BASE/test-$test.log" 2>&1
  echo "$test exit: $?"
done
echo "Logs and copies: $BASE"
```

Each test gets separate user-data and configuration directories to avoid affecting real settings. The scripts exercise selected scenarios, often by positioning actors or invoking handlers; they are not full human-operated playthroughs. A timeout is a failure to obtain a result, not a pass.

## Observations

Both initial imports exited 0 and generated 29 `.import` files with identical paths and byte contents. Both logs nevertheless reported music preload/autoload parse errors before import, a failed `godot_mcp` connection, and headless socket/image errors. A second import of copy A exited 0 and no longer reported the music preload/autoload errors, but the socket/image and MCP connection errors remained. Exit 0 alone is therefore insufficient to label the first import error-free. The editor bridge was disconnected.

| Integration script | Result on imported copy A |
| --- | --- |
| `health_integration` | Exit 0; hearts, damage, defeat and restart assertions passed. |
| `fall_depletion_integration` | Exit 0; three falls and restart assertion passed. |
| `bonus_route_integration` | Exit 0; scripted ascending bonus-route jumps passed. |
| `two_levels_integration` | Exit 0; portal-edge input, level transition, ladder and key assertions passed. |
| `pause_menu_integration` | Exit 0; pause, resume and return-to-menu assertions passed. |

All five logs reported a GameMode D-Bus connection error and ObjectDB leak warnings at exit; `two_levels_integration` also reported one resource still in use. Their causes were not established. A previous baseline recorded an intermittent initial failure of `two_levels_integration` under different conditions; see [level measurements](level-measurement-baseline.md). One pass here does not establish reliability.

## Metadata investigation and limitations

The two fresh imports were identical on this machine with this engine. Against the 29 ignored metadata files present in the existing local checkout, four differed in `uid`: `assets/images/enemy_beetle_spritesheet.png`, `assets/sounds/sfx/wings.ogg`, `assets/sounds/music/menu_theme.wav`, and `assets/sounds/music/background_sfx_engine.wav`. Their `[params]` sections matched; the provenance of the old local metadata is unknown. The two music files are preloaded by path; a text search found no direct scene, resource or script references to the other two assets. This is not proof that every indirect reference resolves or that runtime output is equivalent. UID differences and the absence of versioned import settings remain risks. This comparison is not a comparison against an authoritative original configuration.

The current ignore policy remains in place; [ADR 0003](adr/0003-import-metadata.md) is still proposed. Its acceptance evidence requires settings and exported-output comparisons across multiple environments, which were not performed. No CI, second machine or OS, visual or audio review, controller test, accessibility evaluation, co-op test, full playthrough, or export validation was performed here. Assets and redistribution permissions remain subject to the [provenance audit](asset-provenance-audit.md).
