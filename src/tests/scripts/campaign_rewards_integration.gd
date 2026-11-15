extends SceneTree

const Store := preload("res://src/scenes/scripts/campaign_save.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const SceneWait := preload("res://src/tests/scripts/scene_test_wait.gd")
const Rewards := preload("res://src/scenes/scripts/campaign_rewards.gd")
var checks := 0

class FailingStore extends "res://src/scenes/scripts/campaign_save.gd":
	var failing := true
	func _stage(destination: String, data: Dictionary) -> Error:
		return ERR_FILE_CANT_WRITE if failing else super._stage(destination, data)

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	checks += 1
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func put(path: String, value: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
	file.close()

func run() -> void:
	var mode := OS.get_cmdline_user_args()[0]
	if mode == "--write":
		Progress.ensure_campaign_loaded()
		var level: Node = load("res://src/scenes/adventure_level_1.tscn").instantiate()
		root.add_child(level)
		current_scene = level
		level._use_portal(level.get_node("BonusEntrance"))
		for i in 60:
			await physics_frame
		if not check(Progress.recorded_discoveries == {"secret-chamber-1": true}, "actual portal event records authored discovery"):
			return
		Progress.record_completion(1)
		Progress.record_completion(2)
		if not check(Progress.world_rewards.is_empty() and Progress.character_unlocks.is_empty(), "experimental routes never grant campaign rewards"):
			return
		# Synthetic authored finale policy supplies storage-only fixture records.
		# This does not add production worlds, illustrations or characters.
		var fixture: Dictionary = Store.new().load_campaign().data
		var earned := Rewards.earned({1: true, 2: true}, [{"id": "fixture-world", "levels": [1, 2], "finale": 2}], [1, 2], 2)
		fixture.world_rewards = earned.world_rewards
		fixture.character_unlocks = earned.character_unlocks
		if not check(Store.new().load_campaign().status == "loaded" and Progress.campaign_store.save_campaign(fixture) == OK, "synthetic rewards saved with portal discovery"):
			return
		level.free()
		current_scene = null
	elif mode == "--verify":
		root.set_meta("skip_intro_splash", true)
		var menu: Node = load("res://src/ui/front_end.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		if not check(Progress.recorded_discoveries == {"secret-chamber-1": true} and Progress.world_rewards == {"fixture-world": true} and Progress.character_unlocks == {"prototype": true}, "cold menu startup restores all durable reward collections"):
			return
		var before := FileAccess.get_file_as_string(Store.default_path())
		Progress.reset_attempt()
		if not check(Progress.record_secret(1) == OK and Progress.record_completion(2) == OK and Progress.record_discovery("secret-chamber-1") == OK and FileAccess.get_file_as_string(Store.default_path()) == before, "repeat events and fresh attempts retain records without rewriting unchanged saves"):
			return
		menu.free()
		current_scene = null
		var map: Control = load("res://src/ui/level_map.tscn").instantiate()
		root.add_child(map)
		current_scene = map
		map._open_records()
		await process_frame
		if not check(map.records_column.visible and not map.routes_column.visible and map.records_column.get_child(1).text.contains("La cámara secreta"), "map log shows restored discovery"):
			return
		for viewport_size in [Vector2i(640, 480), Vector2i(1152, 648)]:
			root.size = viewport_size
			for i in 4:
				await process_frame
			var bounds: Rect2 = map.frame.get_global_rect()
			if not check(root.get_visible_rect().encloses(bounds) and root.get_visible_rect().encloses(map.records_column.get_child(-1).get_global_rect()), "record log fits viewport: " + str(viewport_size)):
				return
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		map._unhandled_input(cancel)
		if not check(map.routes_column.visible and map.records_button.has_focus(), "cancel returns from log with map focus"):
			return
		map.select_level(1)
		var replay: Node = await SceneWait.for_scene(self, "res://src/scenes/adventure_level_1.tscn")
		if not check(replay != null and Progress.world_rewards.has("fixture-world") and Progress.character_unlocks.has("prototype") and Progress.recorded_discoveries.has("secret-chamber-1") and Progress.score == 0, "real map replay retains rewards and starts clean attempt"):
			return
		replay._restart_attempt()
		for i in 4:
			await physics_frame
		if not check(Progress.world_rewards.has("fixture-world") and Progress.character_unlocks.has("prototype") and Progress.recorded_discoveries.has("secret-chamber-1"), "real level retry retains reward records"):
			return
		current_scene.free()
		current_scene = null
	else:
		if not check(Rewards.earned({1: true, 2: true, 999: true}) == {"world_rewards": [], "character_unlocks": []}, "no production finales means no rewards, including unknown completion IDs"):
			return
		var worlds := [{"id": "fixture-world", "levels": [1, 2], "finale": 2}]
		if not check(Rewards.earned({2: true}, worlds, [1, 2], 2).world_rewards.is_empty() and Rewards.earned({2: true}, worlds, [1, 2], 2).character_unlocks.is_empty(), "direct finale without predecessors grants nothing"):
			return
		if not check(Rewards.earned({1: true, 2: true}, worlds, [1, 2], 2) == {"world_rewards": ["fixture-world"], "character_unlocks": ["prototype"]}, "synthetic campaign grants rewards without secrets, diamonds or assist restrictions"):
			return
		if not check(Rewards.earned({1: true, 2: true}, [], [1, 2]).character_unlocks.is_empty(), "campaign needs explicit authored finale"):
			return
		var store := Store.new("user://legacy-rewards.json")
		var v1 := {"schema_version": 1, "completed_levels": [1, 2, 999], "recorded_secrets": [1]}
		put(store.path, v1)
		var original := FileAccess.get_file_as_bytes(store.path)
		var migrated := store.load_campaign()
		if not check(migrated.status == "migrated" and migrated.data.recorded_discoveries.is_empty() and migrated.data.completed_levels == [1, 2, 999], "v1 migration retains unknown numeric IDs without inventing reward facts"):
			return
		DirAccess.make_dir_absolute(store.path + ".v1.bak.tmp")
		if not check(store.save_campaign(migrated.data) != OK and FileAccess.get_file_as_bytes(store.path) == original, "failed v1 archive preserves source"):
			return
		DirAccess.remove_absolute(store.path + ".v1.bak.tmp")
		if not check(store.save_campaign(migrated.data) == OK and FileAccess.get_file_as_bytes(store.path + ".v1.bak") == original and store.load_campaign().status == "loaded", "v1 upgrades with byte-exact archive"):
			return
		# A legacy backup next to a current primary also needs preservation.
		put(store.path + ".bak", v1)
		if not check(store.save_campaign(migrated.data) == OK and FileAccess.get_file_as_bytes(store.path + ".v1.bak") == original, "v1 backup archive is retained on rotation"):
			return
		var recovered := Store.new("user://recovered-v1.json")
		put(recovered.path, "broken")
		put(recovered.path + ".bak", v1)
		var backup_bytes := FileAccess.get_file_as_bytes(recovered.path + ".bak")
		var recovery := recovered.load_campaign()
		if not check(recovery.status == "recovered" and recovered.save_campaign(recovery.data) == OK and FileAccess.get_file_as_bytes(recovered.path + ".v1.bak") == backup_bytes, "recovered v1 backup archived before upgrade"):
			return
		var too_big := store.empty_data()
		for field in Store.REWARD_FIELDS:
			for i in Store.MAX_RECORDS:
				too_big[field].append(str(i) + "x".repeat(90))
		if not check(store.save_campaign(too_big) == ERR_INVALID_DATA, "combined reward document cannot exceed load byte limit"):
			return
		for field in Store.REWARD_FIELDS:
			for invalid in [[true], [1], [""], ["Bad ID"], ["a", "a"], ["x".repeat(97)], "record"]:
				var bad := store.empty_data()
				bad[field] = invalid
				if not check(store.save_campaign(bad) == ERR_INVALID_DATA, "invalid reward record rejected: " + field):
					return
		var retained := store.empty_data()
		retained.recorded_discoveries = ["future-discovery"]
		retained.world_rewards = ["future-world"]
		retained.character_unlocks = ["future-character"]
		if not check(store.save_campaign(retained) == OK and store.load_campaign().data == retained, "unknown well-formed IDs survive storage without creating content"):
			return
		Progress.campaign_store = FailingStore.new("user://failed-reward.json")
		Progress.load_campaign()
		if not check(Progress.record_discovery("not-authored") == ERR_INVALID_PARAMETER and Progress.recorded_discoveries.is_empty(), "unauthored discovery rejected"):
			return
		if not check(Progress.record_discovery("secret-chamber-1") != OK and Progress.recorded_discoveries.has("secret-chamber-1"), "write failure retains in-memory discovery"):
			return
		Progress.campaign_store.failing = false
		Progress.retry_failed_save()
		if not check(Progress.campaign_error == OK and Store.new(Progress.campaign_store.path).load_campaign().data.recorded_discoveries == ["secret-chamber-1"], "boundary retry persists discovery"):
			return
	print("PASS: rewards ", mode, " ", checks, " assertions")
	quit(0)
