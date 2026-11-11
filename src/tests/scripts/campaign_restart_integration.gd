extends SceneTree

const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Store := preload("res://src/scenes/scripts/campaign_save.gd")

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

func run() -> void:
	var mode := OS.get_cmdline_user_args()[0]
	if mode == "--seed-migration":
		var file := FileAccess.open("user://campaign.json", FileAccess.WRITE)
		file.store_string(JSON.stringify({"schema_version": 0, "completed_levels": {"1": true, "2": true}, "recorded_secrets": {"1": true}}))
		file.close()
		print("PASS: seeded defined v0 migration fixture")
		quit(0)
		return
	if mode in ["--verify", "--verify-migration"]:
		# Cold menu startup exercises the actual application load point.
		root.set_meta("skip_intro_splash", true)
		var menu: Control = load("res://src/ui/front_end.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		if not check(Progress.completed_levels == {1: true, 2: true} and Progress.recorded_secrets == {1: true} and Progress.score == 0 and Progress.keys.is_empty() and Progress.hearts == 3 and Progress.diamonds == 0, "cold menu startup restores durable facts and no attempt state"):
			return
		if mode == "--verify-migration":
			if not check(Progress.campaign_status == "migrated" and Progress.save_campaign() == OK and Store.new().load_campaign().status == "loaded", "migration upgrades to current schema and reloads"):
				return
		menu._play()
		await frames(5)
		if not check(current_scene.level_number == 1 and Progress.completed_levels.has(2) and Progress.recorded_secrets.has(1) and Progress.score == 0, "JUGAR starts clean level one with campaign records retained"):
			return
		print("PASS: second process restores campaign without attempt inventory; menu remains playable")
	else:
		var level: Node2D = load("res://src/scenes/adventure_level_1.tscn").instantiate()
		root.add_child(level)
		current_scene = level
		level._use_portal(level.get_node("BonusEntrance"))
		await frames(60)
		if not check(Store.new().load_campaign().data.recorded_secrets == [1], "real secret portal autosaves immediately"):
			return
		level._on_collected(level.door.required_key, 0)
		level._open_door()
		await frames(190)
		level = current_scene
		if not check(level.level_number == 2 and Store.new().load_campaign().data.completed_levels == [1], "real exit autosaves before scene transition"):
			return
		level._on_collected(level.door.required_key, 0)
		level._open_door()
		await frames(160)
		if not check(level.completed and Store.new().load_campaign().data.completed_levels == [1, 2], "final celebration autosaves"):
			return
		Progress.score = 321
		Progress.keys[4] = true
		Progress.hearts = 1
		if not check(Progress.save_campaign() == OK and JSON.parse_string(FileAccess.get_file_as_string("user://campaign.json")).size() == 3, "attempt state excluded from disk document"):
			return
		print("PASS: real portal and both exits persist; attempt inventory excluded")
	current_scene.free()
	current_scene = null
	await frames(2)
	quit(0)
