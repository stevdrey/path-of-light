extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func key_up():
	var e := InputEventKey.new()
	e.keycode = KEY_UP
	e.physical_keycode = KEY_UP
	e.pressed = true
	Input.parse_input_event(e)
	await physics_frame
	e = InputEventKey.new()
	e.keycode = KEY_UP
	e.physical_keycode = KEY_UP
	e.pressed = false
	Input.parse_input_event(e)
func run():
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	progress.reset()
	var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	body.global_position = level.door.global_position + Vector2(0,-2)
	await frames(10)
	await key_up()
	await frames(10)
	if level.transitioning:
		printerr("FAIL: door opened without key"); quit(1); return
	body.global_position = Vector2(1888,358)
	body.velocity = Vector2.ZERO
	await frames(8)
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await frames(45)
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await frames(12)
	if not progress.keys.get(5,false):
		printerr("FAIL: yellow key not collected"); quit(1); return
	body.global_position = level.door.global_position + Vector2(0,-2)
	body.velocity = Vector2.ZERO
	await frames(10)
	await key_up()
	if level.door.cue_enabled:
		printerr("FAIL: door cue should stop during opening"); quit(1); return
	await frames(170)
	if not level.completed or progress.keys.has(5):
		printerr("FAIL: second door completion"); quit(1); return
	print("PASS: final door requires yellow key and completes level")
	quit(0)
