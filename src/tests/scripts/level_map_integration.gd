extends SceneTree

const Registry := preload("res://src/scenes/scripts/campaign_registry.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Wait := preload("res://src/tests/scripts/scene_test_wait.gd")
const MAP := "res://src/ui/level_map.tscn"
const MENU := "res://src/ui/front_end.tscn"

class FailingMap extends "res://src/ui/scripts/level_map.gd":
	var fail_once := true
	func _request_level_scene(path: String) -> Error:
		if fail_once:
			fail_once = false
			return ERR_CANT_CREATE
		return super._request_level_scene(path)

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func cancel() -> void:
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	Input.parse_input_event(event)

func run() -> void:
	root.size = Vector2i(1152, 648)
	root.set_meta("skip_intro_splash", true)
	var menu: Control = load(MENU).instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.map_button.pressed.emit()
	var map: Control = await Wait.for_scene(self, MAP)
	if not check(map != null, "menu opens a ready map"):
		return
	var restore := "--verify" in OS.get_cmdline_user_args()
	if restore:
		if not check(Progress.completed_levels == {1: true, 2: true} and Progress.recorded_secrets.is_empty(), "cold process restores completions without requiring secrets"):
			return
		if not check(not map.level_buttons[2].disabled and map.level_buttons[2].text.contains("Completado"), "restored map allows revisiting level two"):
			return
		Progress.score = 999
		Progress.keys[4] = true
		map.level_buttons[2].pressed.emit()
		var restored_level: Node = await Wait.for_scene(self, Registry.level(2).scene_path)
		if not check(restored_level != null and restored_level.level_number == 2 and Progress.score == 0 and Progress.keys.is_empty() and restored_level.player_health.hearts == 3, "cold map selection starts a clean level two and retains completed records"):
			return
		print("PASS: cold-process map restore and clean revisit")
		current_scene.free()
		current_scene = null
		quit(0)
		return
	if not check(Registry.levels().size() == 2 and Registry.level(0).is_empty() and not Registry.is_open(999, {999: true}) and not Registry.is_open(2, {999: true}) and Registry.is_open(2, {2: true}), "registry retains published IDs, rejects unknown IDs and preserves legacy revisits"):
		return
	var metadata := Registry.level(1)
	metadata.scene_path = "invalid"
	if not check(ResourceLoader.exists(Registry.level(1).scene_path) and Registry.next_level_path(1) == Registry.level(2).scene_path and Registry.next_level_path(2).is_empty(), "metadata copies cannot change the registered route"):
		return
	if not check(Progress.completed_levels.is_empty() and map.level_buttons[2].disabled and map.level_buttons[2].text.contains("Bloqueado") and map.level_buttons[1].has_focus(), "new map shows only level one open with focus"):
		return
	map.select_level(2)
	map.select_level(999)
	await process_frame
	if not check(current_scene == map and not map.transitioning, "locked and unknown selection cannot bypass unlocks"):
		return
	# Inject a failed scene request into the real map script; preserve all state.
	map.free()
	map = load(MAP).instantiate()
	map.set_script(FailingMap)
	root.add_child(map)
	current_scene = map
	Progress.score = 321
	Progress.hearts = 1
	Progress.keys[4] = true
	map.level_buttons[1].pressed.emit()
	await process_frame
	await process_frame
	if not check(current_scene == map and not map.transitioning and map.level_buttons[1].has_focus() and map.notice.text.contains("No se pudo") and Progress.score == 321 and Progress.hearts == 1 and Progress.keys.has(4), "failed map launch keeps inventory, visible error, focus and retry"):
		return
	map.level_buttons[1].pressed.emit()
	map.select_level(2) # Duplicate input during replacement must be ignored.
	var level: Node2D = await Wait.for_scene(self, Registry.level(1).scene_path)
	if not check(level != null and level.level_number == 1 and Progress.score == 0 and Progress.hearts == 3 and Progress.keys.is_empty(), "map launch resets transient inventory after acceptance"):
		return
	level._on_collected(0, 10)
	level._on_collected(level.door.required_key, 0)
	level.player_health.hearts = 2
	level.player_health.health_changed.emit(2, 3)
	level._open_door()
	level = await Wait.for_scene(self, Registry.level(2).scene_path)
	if not check(level != null and Progress.completed_levels == {1: true} and Progress.recorded_secrets.is_empty() and Progress.score == 10 and level.player_health.hearts == 2, "ordinary exit unlocks level two without secrets while carrying inventory and hearts"):
		return
	level.get_node("PauseMenu").pause()
	level.get_node("PauseMenu").map_button.pressed.emit()
	map = await Wait.for_scene(self, MAP)
	if not check(map != null and not paused and map.level_buttons[2].has_focus() and not map.level_buttons[2].disabled and map.level_buttons[1].text.contains("Completado") and map.route_labels[0].text.contains("abierta"), "pause map releases pause, shows completed/open routes and focuses next level"):
		return
	var settings: Node = root.get_node("GameSettings")
	settings.set_assist("extra_hearts", true)
	map.level_buttons[2].pressed.emit()
	level = await Wait.for_scene(self, Registry.level(2).scene_path)
	if not check(level != null and level.level_number == 2 and Progress.score == 0 and level.entry_progress.keys.is_empty() and Progress.keys.is_empty() and level.player_health.hearts == 5 and Progress.completed_levels == {1: true}, "direct level-two selection starts empty with configured hearts and retains records"):
		return
	level._on_collected(level.door.required_key, 0)
	level._open_door()
	await frames(170)
	if not check(level.completed and Progress.completed_levels == {1: true, 2: true}, "final exit completes the registered route"):
		return
	var content: VBoxContainer = level.get_node("Completion/Panel/Margin/Content")
	(content.get_child(content.get_child_count() - 1) as Button).pressed.emit()
	map = await Wait.for_scene(self, MAP)
	if not check(map != null and map.level_buttons[1].text.contains("Completado") and map.level_buttons[2].text.contains("Completado"), "final screen returns to a completed map"):
		return
	for viewport in [Vector2i(640, 480), Vector2i(1152, 648)]:
		root.size = viewport
		for i in 4:
			await process_frame
		if not check(root.get_visible_rect().encloses(map.frame.get_global_rect()) and root.get_visible_rect().encloses(map.back_button.get_global_rect()), "map and controls fit viewport %s" % viewport):
			return
	map.level_buttons[1].pressed.emit()
	level = await Wait.for_scene(self, Registry.level(1).scene_path)
	if not check(level != null and Progress.completed_levels == {1: true, 2: true} and Progress.recorded_secrets.is_empty() and Progress.score == 0, "completed level is replayable without erasing records"):
		return
	level.get_node("PauseMenu").pause()
	level.get_node("PauseMenu").map_button.pressed.emit()
	map = await Wait.for_scene(self, MAP)
	cancel()
	menu = await Wait.for_scene(self, MENU)
	if not check(menu != null and menu.map_button.has_focus() and not paused, "map cancel returns to focused menu without leaving pause active"):
		return
	# Cold verification expects ordinary hearts. Preferences are separate from saves.
	settings.set_assist("extra_hearts", false)
	menu._play()
	level = await Wait.for_scene(self, Registry.level(1).scene_path)
	if not check(level != null and level.player_health.hearts == 3 and Progress.completed_levels == {1: true, 2: true}, "JUGAR still starts level one and preserves the completed campaign"):
		return
	print("PASS: registry, unlock guards, map failure/retry, both exits, pause, clean selection, assists, completion replay, menu focus and viewport bounds")
	current_scene.free()
	current_scene = null
	await frames(2)
	quit(0)
