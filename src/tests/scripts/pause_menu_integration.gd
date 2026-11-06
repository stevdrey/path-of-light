extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func press_escape() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)

func run() -> void:
	for path in ["res://src/scenes/adventure_level_1.tscn", "res://src/scenes/adventure_level_2.tscn"]:
		var scene: Node = load(path).instantiate()
		root.add_child(scene)
		current_scene = scene
		await process_frame
		var pause_menu: CanvasLayer = scene.get_node("PauseMenu")
		var player: CharacterBody2D = scene.get_node("Character")
		press_escape()
		await process_frame
		assert(paused and pause_menu.overlay.visible)
		assert(pause_menu.resume_button.has_focus())
		var position_before := player.global_position
		await create_timer(0.12, true).timeout
		assert(player.global_position == position_before)
		pause_menu.resume_button.pressed.emit()
		assert(not paused and not pause_menu.overlay.visible)
		press_escape()
		await process_frame
		assert(paused)
		press_escape()
		await process_frame
		assert(not paused and not pause_menu.overlay.visible)
		scene.queue_free()
		await process_frame
	var scene: Node = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var pause_menu: CanvasLayer = scene.get_node("PauseMenu")
	press_escape()
	await process_frame
	pause_menu._return_to_menu()
	await process_frame
	await process_frame
	assert(not paused and current_scene.scene_file_path == "res://src/ui/front_end.tscn")
	assert(current_scene.main_panel.visible)
	assert(not root.has_meta("skip_intro_splash"))
	assert(root.get_node("BackgroundMusic").playing)
	print("PASS: pause, frozen gameplay, resume, Escape and return to menu")
	quit()
