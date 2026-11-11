extends SceneTree

const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Store := preload("res://src/scenes/scripts/campaign_save.gd")

class FailingStore extends "res://src/scenes/scripts/campaign_save.gd":
	var failing := true
	func _stage(destination: String, data: Dictionary) -> Error:
		return ERR_FILE_CANT_WRITE if failing else super._stage(destination, data)

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

func put(path: String, contents: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(contents)
	file.close()

func run() -> void:
	var mode := OS.get_cmdline_user_args()[0]
	match mode:
		"--future":
			put("user://campaign.json", '{"schema_version":2,"future_data":"preserve"}')
		"--corrupt":
			put("user://campaign.json", "broken primary")
			put("user://campaign.json.bak", "broken backup")
		"--recovered":
			put("user://campaign.json", "broken primary")
			put("user://campaign.json.bak", '{"schema_version":1,"completed_levels":[1],"recorded_secrets":[]}')
		"--write-failure":
			Progress.campaign_store = FailingStore.new()
	var before := FileAccess.get_file_as_string("user://campaign.json") if FileAccess.file_exists("user://campaign.json") else ""
	root.set_meta("skip_intro_splash", true)
	var menu: Control = load("res://src/ui/front_end.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	if mode != "--write-failure":
		var notice: Label = menu.main_panel.get_child(5)
		if not check(notice.visible and not notice.text.is_empty(), "startup displays recovery/version/corruption notice"):
			return
	menu._play()
	await frames(5)
	var level: Node2D = current_scene
	level._use_portal(level.get_node("BonusEntrance"))
	await frames(60)
	if not check(level.in_secret and not level.movement.input_locked and Progress.recorded_secrets.has(1), "save problems do not lock play or lose in-memory discovery"):
		return
	level._record_level_completion()
	if not check(Progress.completed_levels.has(1), "completion still recorded in memory"):
		return
	if mode in ["--future", "--corrupt"]:
		if not check(FileAccess.get_file_as_string("user://campaign.json") == before and Progress.campaign_error != OK and not Progress.campaign_notice().is_empty() and level.status.text.contains(Progress.campaign_notice()), "protected files unchanged and gameplay reports unsaved state"):
			return
	elif mode == "--write-failure":
		if not check(Progress.campaign_error != OK and level.status.text.contains("No se pudo guardar"), "I/O failure is visible during play"):
			return
		Progress.campaign_store.failing = false
		if not check(Progress.save_campaign() == OK and Progress.campaign_notice().is_empty() and Store.new().load_campaign().data.recorded_secrets == [1], "later retry saves retained memory progress and clears failure"):
			return
	else:
		if not check(Progress.campaign_error == OK and Store.new().load_campaign().data.recorded_secrets == [1], "recovered data can be saved with new progress"):
			return
	print("PASS: playable campaign failure/recovery path ", mode)
	current_scene.free()
	current_scene = null
	await frames(2)
	quit(0)
