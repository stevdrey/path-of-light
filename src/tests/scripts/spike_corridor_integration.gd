extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func run():
	var level=load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	var body: CharacterBody2D=level.get_node("Character")
	var health=body.get_node("HealthComponent")
	body.global_position=Vector2(5840,548)
	body.velocity=Vector2.ZERO
	await frames(10)
	Input.action_press("move_right")
	await frames(3)
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await frames(48)
	Input.action_release("move_right")
	if health.hearts!=3 or body.global_position.x<6000:
		printerr("FAIL: spike row not jumpable ",body.global_position," hearts ",health.hearts); quit(1); return
	print("PASS: spike row can be jumped")
	level.get_node("ForestBeetle1").queue_free()
	body.global_position=Vector2(7150,548)
	body.velocity=Vector2.ZERO
	await frames(10)
	Input.action_press("move_right")
	await frames(110)
	Input.action_release("move_right")
	if health.hearts!=3 or body.global_position.x<7550:
		printerr("FAIL: ceiling passage not safely walkable ",body.global_position," hearts ",health.hearts); quit(1); return
	print("PASS: player can walk below ceiling spikes")
	quit(0)
