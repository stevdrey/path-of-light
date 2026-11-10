extends SceneTree

const Progress = preload("res://src/scenes/scripts/game_progress.gd")
const PATHS := ["res://src/scenes/adventure_level_1.tscn", "res://src/scenes/adventure_level_2.tscn"]

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
	for number in [1, 2]:
		Progress.reset()
		Progress.completed_levels[7] = true
		Progress.recorded_secrets[7] = true
		if number == 2:
			Progress.score = 23
			Progress.diamonds = 4
			Progress.diamond_counts.assign([2, 1, 0, 1])
			Progress.hearts = 2
		var level: Node2D = load(PATHS[number - 1]).instantiate()
		root.add_child(level)
		current_scene = level
		var body: CharacterBody2D = level.get_node("Character")
		var health: Node2D = level.player_health
		var movement: MovementComponent = level.movement
		var start := body.global_position
		var baseline := Progress.snapshot_inventory()
		await frames(2)
		if not check(Progress.completed_levels.has(7) and Progress.recorded_secrets.has(7), "level entry preserves session records"):
			return
		# Use real pickups and a real key crate on level two.
		var gem_name := "Bonus4" if number == 1 else "Green1"
		level.get_node("Collectibles/" + gem_name)._on_body_entered(body)
		if number == 1:
			level.get_node("Collectibles/BlueKey")._on_body_entered(body)
		else:
			level.get_node("KeyCrate").hit_from_below(body)
			await frames(2)
			for item in level.get_node("Collectibles").get_children():
				if item is CollectibleItem and item.kind == level.door.required_key:
					item._on_body_entered(body)
		await frames(2)
		var collected := Progress.snapshot_inventory()
		if not check(collected.score > baseline.score and Progress.keys.get(level.door.required_key, false), "attempt contains diamond and required key"):
			return
		# Reach a checkpoint on actual terrain, then fall during hit immunity.
		body.global_position = level.safe_checkpoints[0]
		body.velocity = Vector2.ZERO
		await frames(8)
		if not check(level.checkpoint_index == 1, "grounded safe point activates"):
			return
		health.hearts = 3
		health.health_changed.emit(3, health.max_hearts)
		health.invulnerability_left = 0.0
		health.take_damage(body.global_position)
		await frames(2)
		if not check(health.hearts == 2 and health.invulnerability_left > 0.0, "hit costs one heart"):
			return
		health.take_damage(body.global_position)
		if not check(health.hearts == 2, "repeated hit respects immunity"):
			return
		body.global_position = Vector2(800, 900)
		body.velocity = Vector2.ZERO
		movement.climbing = true
		movement.coyote_left = 0.1
		movement.jump_buffer_left = 0.12
		await frames(2)
		if not check(health.hearts == 1 and body.global_position.distance_to(level.checkpoint) < 5.0, "fall bypasses immunity and returns to last safe point"):
			return
		if not check(Progress.snapshot_inventory() == collected and not movement.climbing and movement.jump_buffer_left == 0.0 and body.get_collision_mask_value(2), "fall preserves inventory and clears stale movement state"):
			return
		# Full-health pickups stay available; healing cannot exceed the maximum.
		var heart: CollectibleItem = load("res://src/collectibles/collectible.tscn").instantiate()
		heart.kind = CollectibleItem.Kind.HEART
		heart.points = 0
		level.get_node("Collectibles").add_child(heart)
		heart.collected.connect(level._on_collected)
		heart._on_body_entered(body)
		if not check(health.hearts == 2 and Progress.hearts == 2, "heart pickup heals and updates session health"):
			return
		health.heal(10)
		if not check(health.hearts == 3 and not health.heal(), "healing is capped"):
			return
		# Deplete by falls on level one and contact damage on level two.
		health.hearts = 1
		if number == 1:
			body.global_position = Vector2(800, 900)
			body.velocity = Vector2.ZERO
		else:
			health.invulnerability_left = 0.0
			health.take_damage(body.global_position)
		await frames(3)
		if not check(health.dead and health.hearts == 0 and not health.heal(), "zero hearts enters defeat once and cannot heal"):
			return
		var before_dead_pickup := Progress.snapshot_inventory()
		level._on_collected(0, 100)
		health.take_damage(body.global_position)
		if not check(Progress.snapshot_inventory() == before_dead_pickup and health.hearts == 0, "defeat rejects additional inventory and damage"):
			return
		if number == 2:
			level.get_node("PauseMenu").pause()
			await create_timer(1.5, true).timeout
			if not check(paused and current_scene == level and health.dead, "pause freezes the defeat countdown"):
				return
			level.get_node("PauseMenu").resume()
		await frames(100)
		if not check(is_instance_valid(current_scene) and current_scene != level and current_scene.scene_file_path == PATHS[number - 1], "depletion reloads the current level"):
			return
		level = current_scene
		body = level.get_node("Character")
		if not check(body.global_position.distance_to(start) < 8.0 and level.checkpoint_index == 0 and not level.in_secret, "retry starts at beginning with no checkpoint or secret-room state"):
			return
		if not check(Progress.snapshot_inventory() == baseline and Progress.hearts == 3 and level.player_health.hearts == 3, "retry restores entry totals and full health, discarding attempt key"):
			return
		if not check(level.get_node("Collectibles").has_node(gem_name) and (level.has_node("KeyCrate") if number == 2 else level.has_node("Collectibles/BlueKey")), "retry restores pickups and crates"):
			return
		if not check(Progress.completed_levels.has(7) and Progress.recorded_secrets.has(7), "retry retains previously recorded progress"):
			return
		# Manual restart uses the same contract, including on level two.
		level._on_collected(level.door.required_key, 0)
		level._on_collected(0, 1)
		var restart := InputEventAction.new()
		restart.action = &"restart_demo"
		restart.pressed = true
		level._input(restart)
		level._input(restart)
		await frames(5)
		if not check(current_scene != level and current_scene.scene_file_path == PATHS[number - 1] and Progress.snapshot_inventory() == baseline and Progress.completed_levels.has(7) and Progress.recorded_secrets.has(7), "manual restart is idempotent and keeps current level and records"):
			return
		print("PASS: level ", number, " fall, damage, healing, depletion, inventory, records and manual restart")
		current_scene.free()
		current_scene = null
		await frames(2)
	quit(0)
