extends SceneTree

const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Wait := preload("res://src/tests/scripts/scene_test_wait.gd")
const MAP := "res://src/ui/level_map.tscn"

class FailingPause extends "res://src/ui/scripts/pause_menu.gd":
	var fail_once := true
	func _request_map_scene() -> Error:
		if fail_once:
			fail_once = false
			return ERR_CANT_CREATE
		return super._request_map_scene()

class FailingLevel extends "res://src/scenes/scripts/second_level.gd":
	var fail_once := true
	func _request_map_scene() -> Error:
		if fail_once:
			fail_once = false
			return ERR_CANT_CREATE
		return super._request_map_scene()

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func accept_twice() -> void:
	for i in 2:
		for pressed in [true, false]:
			var event := InputEventAction.new()
			event.action = "ui_accept"
			event.pressed = pressed
			Input.parse_input_event(event)
	Input.flush_buffered_events()

func run() -> void:
	Progress.reset()
	var level: Node = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	level.get_node("PauseMenu").free()
	var pause_menu := FailingPause.new()
	pause_menu.name = "PauseMenu"
	level.add_child(pause_menu)
	pause_menu.pause()
	pause_menu.map_button.grab_focus()
	await process_frame
	accept_twice()
	for i in 3:
		await process_frame
	if not check(current_scene == level and paused and not pause_menu.map_return_requested and not pause_menu.map_button.disabled and pause_menu.map_button.has_focus() and pause_menu.map_button.text.contains("Reintentar"), "failed pause navigation restores focused retry and keeps the attempt paused"):
		return
	accept_twice()
	var map: Node = await Wait.for_scene(self, MAP)
	if not check(map != null and not paused, "duplicate pause confirm reaches one unpaused map"):
		return
	map.free()
	level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	level.set_script(FailingLevel)
	root.add_child(level)
	current_scene = level
	level.transitioning = true
	level._show_completion()
	var content: Node = level.get_node("Completion/Panel/Margin/Content")
	var button: Button = content.get_child(content.get_child_count() - 1)
	await process_frame
	accept_twice()
	for i in 3:
		await process_frame
	if not check(current_scene == level and level.completed and not level.map_return_requested and not button.disabled and button.has_focus() and button.text.contains("Reintentar"), "failed completion navigation retains completion and restores focused retry"):
		return
	accept_twice()
	# A conflicting replay key in the same frame must not enqueue another scene.
	var restart := InputEventAction.new()
	restart.action = "restart_demo"
	restart.pressed = true
	level._input(restart)
	map = await Wait.for_scene(self, MAP)
	if not check(map != null and not paused, "duplicate completion confirm and replay cannot enqueue conflicting replacements"):
		return
	map.free()
	current_scene = null
	await process_frame
	print("PASS: repeated UI confirm and retry after pause/completion navigation failure")
	quit(0)
