extends SceneTree

const Progress = preload("res://src/scenes/scripts/game_progress.gd")
const FIRST := "res://src/scenes/adventure_level_1.tscn"
const SECOND := "res://src/scenes/adventure_level_2.tscn"

class FailingLevel extends "res://src/scenes/scripts/first_level.gd":
	var fail_next_request := true
	func _request_restart_scene(replay: bool) -> Error:
		if fail_next_request:
			fail_next_request = false
			return ERR_CANT_CREATE
		return super._request_restart_scene(replay)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func press_restart(level: Node2D) -> void:
	var event := InputEventAction.new()
	event.action = &"restart_demo"
	event.pressed = true
	level._input(event)

func run() -> void:
	Progress.reset()
	Progress.recorded_secrets[1] = true
	Progress.completed_levels[1] = true
	var level: Node2D = load(FIRST).instantiate()
	level.set_script(FailingLevel)
	root.add_child(level)
	current_scene = level
	await frames(2)
	level._on_collected(0, 5)
	level._on_collected(level.door.required_key, 0)
	level.player_health.hearts = 2
	level.player_health.health_changed.emit(2, 3)
	var before := Progress.snapshot_inventory()
	press_restart(level)
	await frames(3)
	if not check(current_scene == level and not level.restarting and not level.transitioning and not level.movement.input_locked and Progress.snapshot_inventory() == before and Progress.hearts == 2, "failed reload unlocks the live attempt and rolls back inventory/health"):
		return
	if not check(level.status.text.contains("No se pudo reiniciar"), "failed reload reports a visible retry/menu path"):
		return
	level.get_node("PauseMenu").pause()
	if not check(paused, "pause remains available after failed reload"):
		return
	level.get_node("PauseMenu").resume()
	level.fail_next_request = true
	level.player_health.hearts = 1
	level.player_health.invulnerability_left = 0.0
	level.player_health.take_damage(level.get_node("Character").global_position)
	await frames(100)
	if not check(current_scene == level and level.player_health.dead and not level.transitioning and not level.restarting and Progress.snapshot_inventory() == before and Progress.hearts == 0, "failed depletion reload preserves inventory and enables another restart"):
		return
	press_restart(level)
	await frames(5)
	if not check(current_scene != level and current_scene.level_number == 1 and Progress.score == 0 and Progress.hearts == 3 and Progress.recorded_secrets.has(1), "restart after a failed depletion reload succeeds without losing records"):
		return
	current_scene.free()
	current_scene = null
	# The completed screen must also remain replayable after a failed request.
	level = load(SECOND).instantiate()
	level.set_script(FailingLevel)
	level.level_number = 2
	root.add_child(level)
	current_scene = level
	level.transitioning = true
	level.movement.input_locked = true
	level._show_completion()
	press_restart(level)
	await frames(3)
	if not check(current_scene == level and level.completed and not level.restarting and Progress.completed_levels.has(2), "failed replay keeps the completion screen and replay input available"):
		return
	press_restart(level)
	await frames(5)
	if not check(current_scene != level and current_scene.level_number == 1 and Progress.completed_levels.has(2), "replay after failure starts level one and retains records"):
		return
	current_scene.free()
	current_scene = null
	# JUGAR is another playthrough in this session, not a destructive new game.
	for path in [FIRST, SECOND]:
		level = load(path).instantiate()
		root.add_child(level)
		current_scene = level
		level._on_collected(0, 5)
		level.get_node("PauseMenu").pause()
		level.get_node("PauseMenu")._return_to_menu()
		# Scene replacement finishes at the end of a process frame. Several
		# physics steps may run before that frame, with current_scene still null.
		await process_frame
		await process_frame
		await frames(5)
		if not check(current_scene.scene_file_path == "res://src/ui/front_end.tscn" and Progress.recorded_secrets.has(1) and Progress.completed_levels.has(2) and not paused, "returning to menu keeps session records"):
			return
		current_scene.main_panel.get_child(2).pressed.emit()
		await frames(5)
		if not check(current_scene.level_number == 1 and Progress.score == 0 and Progress.hearts == 3 and Progress.recorded_secrets.has(1) and Progress.completed_levels.has(2), "menu JUGAR resets attempt inventory but retains session records"):
			return
		current_scene.free()
		current_scene = null
	Progress.reset()
	if not check(Progress.recorded_secrets.is_empty() and Progress.completed_levels.is_empty() and Progress.score == 0, "explicit full-reset API clears session records"):
		return
	var store_path: String = Progress.campaign_store.path
	var disk_before := FileAccess.get_file_as_string(store_path) if FileAccess.file_exists(store_path) else ""
	if not check(Progress.record_secret(3) != OK and Progress.campaign_notice().is_empty() and (FileAccess.get_file_as_string(store_path) if FileAccess.file_exists(store_path) else "") == disk_before, "in-memory reset never autosaves cleared records over disk"):
		return
	print("PASS: failed reload/replay recovery, menu playthrough lifetime and explicit reset")
	await frames(2)
	quit(0)
