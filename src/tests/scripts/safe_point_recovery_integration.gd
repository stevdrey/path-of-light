extends SceneTree

# Beyond the old 32 px contact radius, on supported ground in both levels.
const FORWARD_LANDING_OFFSET := 80.0

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
	for path in ["res://src/scenes/adventure_level_1.tscn", "res://src/scenes/adventure_level_2.tscn"]:
		var level: Node2D = load(path).instantiate()
		root.add_child(level)
		current_scene = level
		var body: CharacterBody2D = level.get_node("Character")
		# Landing far beyond a point does not retroactively activate it.
		body.global_position = level.safe_checkpoints.back() + Vector2(level.CHECKPOINT_AHEAD + 192.0, 0)
		body.velocity = Vector2.ZERO
		await frames(10)
		if not check(body.is_on_floor() and level.checkpoint_index == 0, "skipped checkpoints remain inactive on supported ground"):
			return
		for index in range(level.safe_checkpoints.size()):
			var point: Vector2 = level.safe_checkpoints[index]
			# Crossing a point in midair must not activate it.
			body.global_position = point + Vector2(0, -140)
			body.velocity = Vector2.ZERO
			await frames(2)
			if not check(level.checkpoint_index == index, "airborne checkpoint must not activate: " + str(point)):
				return
			body.global_position = point
			body.velocity = Vector2.ZERO
			await frames(10)
			if not check(body.is_on_floor() and body.global_position.distance_to(point) < 8.0 and level.checkpoint_index == index + 1 and level.player_health.hearts == 3, "authored safe point must be grounded, reachable and damage-free: " + path + str(point)):
				return
			# Falling returns to this point even while already invulnerable.
			body.global_position = Vector2(800, 900)
			body.velocity = Vector2.ZERO
			await frames(2)
			if not check(body.global_position.distance_to(point) < 8.0 and level.player_health.hearts == 2, "fall recovers at activated point"):
				return
			level.player_health.heal()
		# Backtracking must not replace the latest safe point.
		body.global_position = Vector2(100, 548)
		body.velocity = Vector2.ZERO
		await frames(10)
		if not check(level.checkpoint == level.safe_checkpoints.back(), "backtracking retains latest checkpoint"):
			return
		# Landing just past a point falls inside its forward window.
		level.checkpoint_index = 0
		body.global_position = level.safe_checkpoints[0] + Vector2(FORWARD_LANDING_OFFSET, 0)
		body.velocity = Vector2.ZERO
		await frames(10)
		if not check(body.is_on_floor() and level.checkpoint_index == 1 and level.checkpoint == level.safe_checkpoints[0], "landing just past a point activates it"):
			return
		print("PASS: all safe points and falls on ", path)
		level.free()
		current_scene = null
		await frames(2)
	quit(0)
