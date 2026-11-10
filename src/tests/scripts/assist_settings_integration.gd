extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func run() -> void:
	var settings: Node = root.get_node("GameSettings")
	if "--verify-persisted" in OS.get_cmdline_user_args():
		if not check(settings.get_max_hearts() == 5 and settings.is_assist_enabled("frequent_checkpoints") and settings.is_assist_enabled("no_fall_damage") and is_equal_approx(settings.get_volume("Music"), 0.37), "new process restores saved assists and audio"):
			return
		var key: InputEventKey = InputMap.action_get_events("jump")[0]
		if not check(key.physical_keycode == KEY_J, "new process restores saved key binding"):
			return
		print("PASS: assists, audio and controls survive process restart")
		quit(0)
		return
	for key in settings.ASSISTS:
		if not check(not settings.is_assist_enabled(key), "new install uses standard rules"):
			return
	var config := ConfigFile.new()
	config.set_value("audio", "Music", 0.5)
	settings.load_assists(config)
	if not check(settings.get_max_hearts() == 3, "old audio/control files default to standard recovery"):
		return
	config.set_value("assists", "extra_hearts", "false")
	config.set_value("assists", "frequent_checkpoints", 42)
	config.set_value("assists", "no_fall_damage", [])
	settings.load_assists(config)
	for key in settings.ASSISTS:
		if not check(not settings.is_assist_enabled(key), "malformed assist type defaults off"):
			return
	settings.set_assist("unknown_setting", true)
	if not check(settings.assists.size() == 3, "unknown setting cannot create new rules"):
		return
	settings.bind_key("jump", KEY_J)
	settings.set_volume("Music", 0.37)
	for key in settings.ASSISTS:
		settings.set_assist(key, true)
	settings.restore_controls()
	if not check(settings.get_max_hearts() == 5, "restoring controls does not reset assists"):
		return
	settings.bind_key("jump", KEY_J)
	var saved := ConfigFile.new()
	if not check(saved.load(settings.FILE) == OK and saved.get_value("assists", "extra_hearts") == true and saved.get_value("controls", "jump") == KEY_J, "assist saves retain control settings"):
		return
	print("PASS: defaults, old/malformed settings, independent options and persistence write")
	quit(0)
