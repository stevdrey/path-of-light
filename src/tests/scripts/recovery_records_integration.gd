extends SceneTree

const Progress = preload("res://src/scenes/scripts/game_progress.gd")

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
	Progress.reset()
	var level: Node2D = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	# Exercise the real portal transition and recording event.
	level._use_portal(level.get_node("BonusEntrance"))
	await frames(60)
	if not check(level.in_secret and not level.portal_transitioning and Progress.recorded_secrets.get(1, false) and level.player_health.hearts == 3, "portal records secret without treating the lower room as a fall"):
		return
	level.get_node("Collectibles/SecretGem2")._on_body_entered(body)
	var secret_inventory := Progress.snapshot_inventory()
	body.global_position = Vector2(3500, 1550)
	body.velocity = Vector2.ZERO
	await frames(2)
	if not check(not level.in_secret and level.player_health.hearts == 2 and body.global_position.distance_to(level.checkpoint) < 5.0 and Progress.snapshot_inventory() == secret_inventory, "fall below secret room returns to main safe point and keeps attempt items"):
		return
	# Depletion inside the secret room must clear room state, not the record.
	level._use_portal(level.get_node("BonusEntrance"))
	await frames(60)
	level.player_health.hearts = 1
	body.global_position = Vector2(3500, 1550)
	body.velocity = Vector2.ZERO
	await frames(105)
	if not check(current_scene != level and not current_scene.in_secret and Progress.recorded_secrets.get(1, false) and Progress.score == 0, "secret depletion resets attempt rewards but retains discovery"):
		return
	level = current_scene
	body = level.get_node("Character")
	# Main route completion does not require a secret record.
	Progress.recorded_secrets.clear()
	level.get_node("Collectibles/BlueKey")._on_body_entered(body)
	level._open_door()
	await frames(190)
	if not check(current_scene != level and current_scene.level_number == 2 and Progress.completed_levels.get(1, false) and Progress.recorded_secrets.is_empty(), "ordinary exit records completion without an optional secret"):
		return
	level = current_scene
	body = level.get_node("Character")
	var entry := Progress.snapshot_inventory()
	level.player_health.hearts = 1
	level.player_health.invulnerability_left = 0.0
	level.player_health.take_damage(body.global_position)
	await frames(105)
	if not check(current_scene != level and current_scene.level_number == 2 and Progress.completed_levels.get(1, false) and Progress.snapshot_inventory() == entry, "level-two defeat retains earlier completion"):
		return
	# Final prototype exit records level two only after its celebration starts.
	level = current_scene
	level._on_collected(level.door.required_key, 0)
	level._open_door()
	await frames(160)
	if not check(level.completed and Progress.completed_levels.get(2, false), "final exit records completion"):
		return
	level._restart_attempt()
	await frames(5)
	if not check(current_scene != level and current_scene.level_number == 2 and Progress.completed_levels.get(1, false) and Progress.completed_levels.get(2, false), "retry after completion retains both records"):
		return
	print("PASS: real secret and exit records, bonus falls, optional secret, depletion and retry retention")
	current_scene.free()
	current_scene = null
	await frames(2)
	quit(0)
