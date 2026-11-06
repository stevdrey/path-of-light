extends SceneTree
func _initialize(): call_deferred("run")
func jump_to(level: Node, from: Vector2, target: Vector2) -> void:
	var player: CharacterBody2D = level.get_node("Character")
	player.global_position = from
	player.velocity = Vector2.ZERO
	for i in range(5): await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for i in range(40): await physics_frame
	Input.action_release("move_right")
	print("jump ", from, " -> ", player.global_position, " target=", target)
	assert(player.global_position.x >= target.x and player.global_position.y <= target.y + 12)
func run():
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	await jump_to(level, Vector2(840,550),Vector2(900,486))
	await jump_to(level, Vector2(1000,486),Vector2(1090,422))
	await jump_to(level, Vector2(1240,422),Vector2(1345,358))
	print("PASS: all ascending bonus route steps are reachable")
	quit()
