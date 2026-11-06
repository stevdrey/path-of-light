extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func run():
	var level=load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	var body: CharacterBody2D=level.get_node("Character")
	var crate=level.get_node("DiamondCrate")
	body.global_position = crate.global_position + Vector2(0,-45)
	body.velocity = Vector2(0,150)
	await frames(30)
	if not is_instance_valid(crate) or crate.broken:
		printerr("FAIL: falling onto top broke crate"); quit(1); return
	print("PASS: landing on crate does not break it")
	body.global_position = crate.global_position + Vector2(-95, 18)
	body.velocity = Vector2.ZERO
	await frames(2)
	Input.action_press("move_right")
	await frames(18)
	Input.action_release("move_right")
	if not is_instance_valid(crate) or crate.broken:
		printerr("FAIL: side contact broke crate"); quit(1); return
	print("PASS: side contact does not break crate")
	quit(0)
