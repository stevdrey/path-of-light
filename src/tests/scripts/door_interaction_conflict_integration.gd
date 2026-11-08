extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func key_event(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)

func run() -> void:
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	progress.reset()
	var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	player.global_position = level.door.global_position + Vector2(0, -2)
	player.velocity = Vector2.ZERO
	await frames(15)
	if not player.is_on_floor() or not level.door.player_nearby:
		fail("player did not reach the grounded door fixture"); return
	await process_frame
	if level.door.cue_glow == null or not level.door.cue_glow.visible or not level.door.cue_glow.texture is GradientTexture2D or level.door.cue_glow.modulate.a <= 0.35:
		fail("door glow did not respond to proximity"); return
	if level.status.text.contains("puerta"):
		fail("door instruction is still shown in the status"); return
	key_event(KEY_UP, true)
	await frames(3)
	key_event(KEY_UP, false)
	await frames(2)
	if level.transitioning or player.velocity.y < -1.0 or not player.is_on_floor():
		fail("interacting with a locked door caused a jump or transition"); return
	key_event(KEY_SPACE, true)
	await frames(3)
	key_event(KEY_SPACE, false)
	if player.velocity.y >= 0:
		fail("independent jump key was suppressed at the locked door"); return
	await frames(70)
	if not player.is_on_floor() or not level.door.player_nearby:
		fail("player did not land near the door"); return
	root.get_node("GameSettings").bind_key("interact_up", KEY_E, false)
	key_event(KEY_E, true)
	key_event(KEY_SPACE, true)
	await frames(3)
	key_event(KEY_E, false)
	key_event(KEY_SPACE, false)
	if player.velocity.y >= 0:
		fail("separate simultaneous jump was suppressed after rebinding"); return
	await frames(70)
	if not player.is_on_floor() or not level.door.player_nearby:
		fail("player did not land near the door after rebinding"); return
	root.get_node("GameSettings").bind_key("interact_up", KEY_W, false)
	key_event(KEY_W, true)
	key_event(KEY_SPACE, true)
	await frames(3)
	key_event(KEY_W, false)
	key_event(KEY_SPACE, false)
	if player.velocity.y >= 0:
		fail("independent jump was lost alongside a shared interaction key"); return
	await frames(70)
	if not player.is_on_floor() or not level.door.player_nearby:
		fail("player did not land near the door after simultaneous inputs"); return
	key_event(KEY_W, true)
	await frames(3)
	key_event(KEY_SPACE, true)
	await frames(3)
	key_event(KEY_W, false)
	key_event(KEY_SPACE, false)
	if player.velocity.y >= 0:
		fail("independent jump was lost while a shared key was held"); return
	print("PASS: locked door consumes shared up without suppressing separate jump")
	quit(0)
