extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func run():
	for group in [["res://src/scenes/adventure_level_1.tscn", [[6239.0,6400.0],[8927.0,9088.0],[11743.0,11840.0]]],["res://src/scenes/adventure_level_2.tscn", [[9247.0,9408.0],[11807.0,11904.0]]]]:
		for spec in group[1]:
			var level=load(group[0]).instantiate()
			root.add_child(level)
			var body: CharacterBody2D=level.get_node("Character")
			body.global_position=Vector2(spec[0],548)
			body.velocity=Vector2.ZERO
			await frames(10)
			Input.action_press("move_right")
			await frames(3)
			Input.action_press("jump")
			await physics_frame
			Input.action_release("jump")
			await frames(47)
			Input.action_release("move_right")
			if body.global_position.x<=spec[1] or body.global_position.y>=570:
				printerr("FAIL: gap ",spec," at ",body.global_position)
				quit(1); return
			print("PASS: crossed ",spec)
			level.queue_free()
			await process_frame
	quit(0)
