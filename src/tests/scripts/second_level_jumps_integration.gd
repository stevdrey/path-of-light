extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func run():
	for spec in [[735.0,896.0],[1950.0,2112.0],[3295.0,3392.0]]:
		var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
		root.add_child(level)
		var body: CharacterBody2D = level.get_node("Character")
		body.global_position = Vector2(spec[0],548)
		body.velocity = Vector2.ZERO
		await frames(10)
		Input.action_press("move_right")
		await frames(3)
		Input.action_press("jump")
		await physics_frame
		Input.action_release("jump")
		await frames(47)
		Input.action_release("move_right")
		print("jump ", spec[0], " -> ",body.global_position)
		if body.global_position.x <= spec[1] or body.global_position.y >= 570:
			printerr("FAIL: second level gap cannot be crossed")
			quit(1)
			return
		level.queue_free()
		await process_frame
	print("PASS: all second level gaps are crossable")
	quit(0)
