extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func run():
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	var body: CharacterBody2D = level.get_node("Character")
	body.global_position = Vector2(2979,358)
	body.velocity = Vector2.ZERO
	var item = load("res://src/collectibles/collectible.tscn").instantiate()
	item.position = Vector2(2979,320)
	level.get_node("Collectibles").add_child(item)
	item.collected.connect(level._on_collected)
	await frames(8)
	var portal = level.get_node("BonusEntrance")
	if is_instance_valid(item) or not portal.overlaps_body(body) or portal.can_activate(body):
		printerr("FAIL: collectible or edge detection"); quit(1); return
	var e := InputEventKey.new()
	e.keycode = KEY_UP
	e.physical_keycode = KEY_UP
	e.pressed = true
	Input.parse_input_event(e)
	await frames(5)
	if level.portal_transitioning or body.velocity.y >= 0:
		printerr("FAIL: portal activated when player should jump"); quit(1); return
	print("PASS: nearby item collected and up jumps without triggering portal")
	quit(0)
