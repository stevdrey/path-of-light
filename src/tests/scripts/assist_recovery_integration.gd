extends SceneTree

const Progress = preload("res://src/scenes/scripts/game_progress.gd")
const PATHS := ["res://src/scenes/adventure_level_1.tscn", "res://src/scenes/adventure_level_2.tscn"]
var settings: Node

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
	settings = root.get_node("GameSettings")
	# Standard, each independent option, and every combination.
	for mask in range(8):
		for i in range(3):
			settings.set_assist(settings.ASSISTS[i], bool(mask & (1 << i)))
		for path in PATHS:
			Progress.reset()
			Progress.hearts = settings.get_max_hearts()
			var level: Node2D = load(path).instantiate()
			root.add_child(level)
			current_scene = level
			var body: CharacterBody2D = level.get_node("Character")
			var health: Node2D = level.player_health
			var maximum: int = settings.get_max_hearts()
			await frames(2)
			if not check(health.hearts == maximum and health.max_hearts == maximum and Progress.hearts == maximum, "configured entry hearts: " + path):
				return
			var visible_hearts := 0
			for icon in level.collection_hud.hearts_row.get_children():
				if icon.visible:
					visible_hearts += 1
			if not check(visible_hearts == maximum, "HUD shows every configured heart"):
				return
			# Extra points must be supported, free of contact damage at rest and
			# inactive while airborne. Test their actual landing/fall windows.
			if settings.is_assist_enabled("frequent_checkpoints"):
				for point in level.assist_checkpoints:
					var previous: Vector2 = level.checkpoint
					body.global_position = point + Vector2(0, -140)
					body.velocity = Vector2.ZERO
					await frames(2)
					if not check(level.checkpoint == previous, "assist point does not activate in air: " + str(point)):
						return
					body.global_position = point
					body.velocity = Vector2.ZERO
					await frames(10)
					if not check(body.is_on_floor() and body.global_position.distance_to(point) < 8.0 and level.checkpoint == point and health.hearts == maximum, "assist point is supported and damage-free: %s %s actual=%s floor=%s checkpoint=%s hearts=%d" % [path, point, body.global_position, body.is_on_floor(), level.checkpoint, health.hearts]):
						return
					body.global_position = Vector2(800, 900)
					body.velocity = Vector2.ZERO
					await frames(2)
					var expected: int = maximum if settings.is_assist_enabled("no_fall_damage") else maximum - 1
					if not check(body.global_position.distance_to(point) < 8.0 and health.hearts == expected, "fall returns to assist point with configured damage"):
						return
					health.heal(10)
			else:
				body.global_position = level.assist_checkpoints[0]
				body.velocity = Vector2.ZERO
				await frames(10)
				if not check(level.checkpoint_index == 0, "standard frequency does not grant assist points"):
					return
			# Recovery from both regions preserves the same inventory/records.
			level._on_collected(0, 7)
			level._on_collected(level.door.required_key, 0)
			Progress.recorded_secrets[9] = true
			Progress.completed_levels[9] = true
			var inventory := Progress.snapshot_inventory()
			for secret in [false, true]:
				level.in_secret = secret
				var before: int = health.hearts
				body.global_position = Vector2(800, 1550 if secret else 900)
				body.velocity = Vector2.ZERO
				level.movement.climbing = true
				level.movement.jump_buffer_left = 0.12
				await frames(2)
				var expected: int = before if settings.is_assist_enabled("no_fall_damage") else before - 1
				if not check(health.hearts == expected and not level.in_secret and body.global_position.distance_to(level.checkpoint) < 8.0 and Progress.snapshot_inventory() == inventory and not level.movement.climbing and level.movement.jump_buffer_left == 0.0, "main/secret fall preserves items and clears movement state"):
					return
				health.heal(10)
			# Contact can still deplete with every assist enabled.
			health.hearts = 1
			health.invulnerability_left = 0.0
			health.take_damage(body.global_position)
			await frames(3)
			if not check(health.dead and health.hearts == 0, "contact defeat remains enabled"):
				return
			await frames(100)
			if not check(current_scene != level and current_scene.scene_file_path == path and current_scene.player_health.hearts == maximum and Progress.hearts == maximum and Progress.score == 0 and Progress.keys.is_empty() and Progress.recorded_secrets.has(9) and Progress.completed_levels.has(9), "assisted depletion restarts same level with full configured hearts, entry inventory and records"):
				return
			current_scene.free()
			current_scene = null
			await frames(2)
		print("PASS: recovery combination ", mask, " on both levels")
	quit(0)
