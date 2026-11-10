extends SceneTree

const Progress = preload("res://src/scenes/scripts/game_progress.gd")

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
	var settings: Node = root.get_node("GameSettings")
	root.size = Vector2i(1152, 648)
	root.set_meta("skip_intro_splash", true)
	var menu: Control = load("res://src/ui/front_end.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu._open_options()
	for i in 3:
		await process_frame
	if not check(root.get_visible_rect().encloses(menu.options_panel.get_global_rect()), "Options fits the 1152x648 viewport"):
		return
	menu.assists_button.pressed.emit()
	root.size = Vector2i(640, 480)
	for i in 3:
		await process_frame
	if not check(root.get_visible_rect().encloses(menu.assists_panel.get_global_rect()), "assist controls fit a 640x480 viewport"):
		return
	await process_frame
	if not check(menu.assists_panel.visible and not menu.options_panel.visible and menu.assists_panel.toggles.extra_hearts.has_focus(), "Options exposes focused assist controls"):
		return
	menu.assists_panel.toggles.extra_hearts.button_pressed = true
	if not check(settings.get_max_hearts() == 5 and not settings.is_assist_enabled("no_fall_damage"), "menu checkbox changes only selected assist"):
		return
	menu.assists_panel.back_button.pressed.emit()
	if not check(menu.assists_button.has_focus() and menu.options_panel.visible and not menu.assists_panel.visible, "Volver restores Options focus"):
		return
	root.size = Vector2i(1152, 648)
	menu._play()
	await frames(5)
	var level: Node2D = current_scene
	var body: CharacterBody2D = level.get_node("Character")
	var health: Node2D = level.player_health
	if not check(health.hearts == 5, "JUGAR starts with configured hearts"):
		return
	health.take_damage(body.global_position)
	var pause_menu: CanvasLayer = level.get_node("PauseMenu")
	pause_menu.pause()
	pause_menu.assists_button.pressed.emit()
	var position_before := body.global_position
	pause_menu.assists_panel.toggles.extra_hearts.button_pressed = false
	if not check(paused and health.hearts == 2 and health.max_hearts == 3 and Progress.hearts == 2, "live disabling preserves missing hearts while paused"):
		return
	pause_menu.assists_panel.toggles.extra_hearts.button_pressed = true
	pause_menu.assists_panel.toggles.frequent_checkpoints.button_pressed = true
	pause_menu.assists_panel.toggles.no_fall_damage.button_pressed = true
	await create_timer(0.1, true).timeout
	if not check(body.global_position == position_before and health.hearts == 4 and level.checkpoint_index == 0, "live options work during pause without moving player or granting unvisited checkpoint"):
		return
	pause_menu.assists_panel.back_button.pressed.emit()
	if not check(pause_menu.assists_button.has_focus() and pause_menu.menu_column.visible, "assist back restores Pause focus"):
		return
	# Esc inside AYUDAS goes back one step instead of resuming gameplay.
	pause_menu._open_assists()
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	Input.parse_input_event(cancel)
	for i in 2:
		await process_frame
	if not check(paused and not pause_menu.assists_panel.visible and pause_menu.menu_column.visible and pause_menu.assists_button.has_focus(), "Esc in pause AYUDAS returns to the pause list"):
		return
	pause_menu.resume()
	await frames(25)
	# A visited assist point survives changing frequency and backtracking.
	body.global_position = level.assist_checkpoints[1]
	body.velocity = Vector2.ZERO
	await frames(10)
	var point: Vector2 = level.checkpoint
	settings.set_assist("frequent_checkpoints", false)
	body.global_position = Vector2(100, 548)
	body.velocity = Vector2.ZERO
	await frames(10)
	settings.set_assist("frequent_checkpoints", true)
	if not check(level.checkpoint == point and point == level.assist_checkpoints[1], "frequency changes and backtracking retain visited safe point"):
		return
	# Switching caps at one heart cannot defeat or revive the character.
	health.hearts = 1
	settings.set_assist("extra_hearts", false)
	if not check(health.hearts == 1 and not health.dead, "disabling at low health cannot cause defeat"):
		return
	# Hidden missing hearts are remembered, so toggling the cap never heals.
	settings.set_assist("extra_hearts", true)
	if not check(health.hearts == 1 and health.max_hearts == 5, "re-enabling after a clamped disable does not heal (1/5)"):
		return
	health.hearts = 2
	settings.set_assist("extra_hearts", false)
	settings.set_assist("extra_hearts", true)
	if not check(health.hearts == 2 and health.max_hearts == 5, "off/on round trip from 2/5 does not heal"):
		return
	health.hearts = 1
	settings.set_assist("extra_hearts", false)
	health.invulnerability_left = 0.0
	health.take_damage(body.global_position)
	pause_menu.pause()
	settings.set_assist("extra_hearts", true)
	if not check(health.dead and health.hearts == 0 and health.max_hearts == 5, "changing assists during defeat cannot revive"):
		return
	pause_menu.resume()
	await frames(100)
	level = current_scene
	if not check(level.player_health.hearts == 5 and level.checkpoint_index == 0, "defeat retries with active cap and no visited checkpoint"):
		return
	# No content penalty: real secret transition, reward and ordinary doors
	# remain available with all assists, including carrying health into level 2.
	level._use_portal(level.get_node("BonusEntrance"))
	await frames(60)
	body = level.get_node("Character")
	level.get_node("Collectibles/SecretGem2")._on_body_entered(body)
	if not check(level.in_secret and Progress.recorded_secrets.get(1, false) and Progress.score > 0, "assists retain secret access, record and reward"):
		return
	level._use_portal(level.get_node("BonusExit"))
	await frames(60)
	level.get_node("Collectibles/BlueKey")._on_body_entered(body)
	var score_before := Progress.score
	# Hidden missing hearts survive the real exit: 1/5 -> 1/3 -> door -> 1/5.
	level.player_health.hearts = 1
	level.player_health.health_changed.emit(1, 5)
	settings.set_assist("extra_hearts", false)
	level._open_door()
	await frames(190)
	level = current_scene
	settings.set_assist("extra_hearts", true)
	if not check(level.level_number == 2 and level.player_health.hearts == 1 and level.player_health.max_hearts == 5 and Progress.score == score_before and Progress.completed_levels.get(1, false), "assists retain rewards, hidden missing hearts and completion across the real exit"):
		return
	level.player_health.heal(3)
	if not check(level.player_health.hearts == 4 and Progress.hearts == 4, "level two heals normally after the transition"):
		return
	# A synchronous setting change must not overwrite a pending retry's full
	# health with the old scene's remaining hearts before deferred replacement.
	level._restart_attempt()
	settings.set_assist("extra_hearts", false)
	settings.set_assist("extra_hearts", true)
	await frames(5)
	level = current_scene
	if not check(level.player_health.hearts == 5 and Progress.hearts == 5 and Progress.score == score_before, "pending retry retains full configured health after live cap changes"):
		return
	level._on_collected(level.door.required_key, 0)
	level._open_door()
	await frames(160)
	if not check(level.completed and Progress.completed_levels.get(2, false) and level.has_node("Completion"), "assisted final completion has no content penalty"):
		return
	print("PASS: menu/pause assists, live cap and checkpoint changes, defeat, secret rewards and both exits")
	current_scene.free()
	current_scene = null
	await frames(2)
	quit(0)
