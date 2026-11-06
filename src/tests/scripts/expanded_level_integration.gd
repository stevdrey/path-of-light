extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func fail(message: String) -> void:
	push_error(message)
	quit(1)
func run() -> void:
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var health = player.get_node("HealthComponent")
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	if level.get_node("BeetleEnemy2") == null or level.get_node("BeetleEnemy3") == null:
		fail("additional enemies missing"); return
	print("PASS: additional beetles and hazards present")
	var bonus = level.get_node("Collectibles/Bonus4")
	bonus._on_body_entered(player)
	var score_before: int = progress.score
	# Drop through the first ordinary gap and check health and progress.
	player.global_position = Vector2(2080,548)
	player.velocity = Vector2.ZERO
	await frames(90)
	if health.hearts != 2 or player.global_position.y > 600 or progress.score < score_before or is_instance_valid(bonus):
		fail("fall did not restore position while preserving score and collected items"); return
	print("PASS: ordinary fall costs one heart, respawns and preserves collected score")
	# Recover from a later fall at a checkpoint even while invulnerable.
	await frames(10)
	player.global_position = Vector2(4096,548)
	player.velocity = Vector2.ZERO
	await frames(90)
	if health.hearts != 1 or player.global_position.y > 600:
		fail("later fall did not cost a heart and recover"); return
	print("PASS: later precipice costs a heart and recovers")
	print("expanded level integration complete")
	quit(0)
