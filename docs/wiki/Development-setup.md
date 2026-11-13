# Development setup

Use Godot 4.8 beta 2, the version identified in the repository README; import `project.godot`, wait for assets, and run the main scene. Godot regenerates the ignored `.import` files; import settings can differ. See the [README](https://github.com/stevdrey/path-of-light/blob/main/README.md) for controls, licenses and current caveats.

Integration scripts in `src/tests/scripts/` extend `SceneTree`. After importing, an individual script can be run with `godot --headless --path . --script res://src/tests/scripts/health_integration.gd` using the Godot executable available locally. Record engine version, command, result and any errors; a headless check does not establish visual quality, input feel or audio balance. There is no documented release CI baseline yet. Script runs (`--script`) save campaign data to `user://test-campaign.json`, never the player's `user://campaign.json`; other `user://` data such as settings is not redirected, so use an isolated data directory when that matters.

The [import and test baseline](https://github.com/stevdrey/path-of-light/blob/main/docs/import-test-baseline.md) contains clean-copy commands, representative results and known limitations.
