extends SceneTree

const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Store := preload("res://src/scenes/scripts/campaign_save.gd")
const Wait := preload("res://src/tests/scripts/scene_test_wait.gd")
const Registry := preload("res://src/scenes/scripts/campaign_registry.gd")
const MAP := "res://src/ui/level_map.tscn"

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func put(path: String, contents: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(contents)
	file.close()

func run() -> void:
	var mode := OS.get_cmdline_user_args()[0]
	var protected := mode != "--recovered"
	var original := '{"schema_version":2,"future_data":"preserve"}' if mode == "--future" else "broken primary"
	put(Store.default_path(), original)
	if mode == "--recovered":
		put(Store.default_path() + ".bak", '{"schema_version":1,"completed_levels":[1],"recorded_secrets":[]}')
	elif mode == "--corrupt":
		put(Store.default_path() + ".bak", "broken backup")
	var map: Control = load(MAP).instantiate()
	root.add_child(map)
	current_scene = map
	if not check(map.notice.visible and not map.notice.text.is_empty() and map.level_buttons[2].disabled == protected, "map reports protected/recovered storage and derives available routes"):
		return
	map.level_buttons[1].pressed.emit()
	var level: Node = await Wait.for_scene(self, Registry.level(1).scene_path)
	if not check(level != null, "storage problems do not block selecting level one"):
		return
	level._record_level_completion()
	level.get_node("PauseMenu").pause()
	level.get_node("PauseMenu").map_button.pressed.emit()
	map = await Wait.for_scene(self, MAP)
	if not check(map != null and not map.level_buttons[2].disabled and Progress.completed_levels.has(1), "in-memory completion opens next route after map navigation"):
		return
	if protected:
		if not check(map.notice.visible and FileAccess.get_file_as_string(Store.default_path()) == original, "protected bytes and unsaved progress notice survive map selection/completion"):
			return
		if mode == "--corrupt" and not check(FileAccess.get_file_as_string(Store.default_path() + ".bak") == "broken backup", "map cannot overwrite protected backup"):
			return
	else:
		if not check(Progress.campaign_status == "recovered" and map.notice.visible and Store.new().load_campaign().data.completed_levels == [1], "map retains recovered completion and visible recovery notice"):
			return
	print("PASS: map storage boundary ", mode)
	current_scene.free()
	current_scene = null
	quit(0)
