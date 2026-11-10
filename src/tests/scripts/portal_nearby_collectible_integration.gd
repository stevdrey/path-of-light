extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func fail(message: String, level: Node2D, body: CharacterBody2D) -> void:
	var portal: Area2D = level.get_node("BonusEntrance")
	printerr("FAIL: ", message, " context=", {
		"physics_frame": Engine.get_physics_frames(),
		"process_frame": Engine.get_process_frames(),
		"position": body.global_position, "velocity": body.velocity,
		"floor": body.is_on_floor(), "jump_pressed": Input.is_action_pressed("jump"),
		"jump_just_pressed": Input.is_action_just_pressed("jump"),
		"input_locked": level.movement.input_locked,
		"damage_locked": level.movement.damage_locked,
		"portal_transitioning": level.portal_transitioning,
		"portal_can_activate": portal.can_activate(body),
		"control_is_player": level.movement.control == level.movement.player_control
	})
	quit(1)

func send_up(pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_UP
	event.physical_keycode = KEY_UP
	event.pressed = pressed
	Input.parse_input_event(event)
	# A render frame may contain many physics steps. Deliver the buffered event
	# explicitly before bounding the response in physics steps.
	Input.flush_buffered_events()

func run() -> void:
	var level: Node2D = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	body.global_position = Vector2(2979, 358)
	body.velocity = Vector2.ZERO
	var item: CollectibleItem = load("res://src/collectibles/collectible.tscn").instantiate()
	item.position = Vector2(2979, 320)
	level.get_node("Collectibles").add_child(item)
	item.collected.connect(level._on_collected)
	await frames(8)
	var portal: Area2D = level.get_node("BonusEntrance")
	if is_instance_valid(item) or not portal.overlaps_body(body) or portal.can_activate(body) or not body.is_on_floor():
		fail("collectible, edge detection or grounded fixture", level, body)
		return
	send_up(true)
	if not Input.is_action_pressed("jump") or level.portal_transitioning:
		fail("flushed edge input must reach jump without activating portal", level, body)
		return
	var jumped := false
	for i in range(8):
		await physics_frame
		if level.portal_transitioning:
			fail("edge input activated portal", level, body)
			return
		if body.velocity.y < 0.0:
			jumped = true
			break
	if not jumped:
		fail("jump did not start after confirmed input delivery", level, body)
		return
	send_up(false)
	print("PASS: nearby item collected and flushed up input jumps without triggering portal")
	current_scene.free()
	current_scene = null
	await process_frame
	quit(0)
