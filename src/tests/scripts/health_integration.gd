extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func check(ok: bool, msg: String):
	if not ok:
		printerr("FAIL: ",msg)
		quit(1)
		return
	print("PASS: ",msg)
func run():
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	progress.reset()
	progress.score = 14
	progress.diamonds = 2
	progress.diamond_counts.assign([2,0,0,0])
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	var health = body.get_node("HealthComponent")
	var movement = body.get_node("MovementComponent")
	var hud = level.get_node("CollectionHUD")
	await frames(30)
	check(health.hearts == 3 and hud.hearts_row.get_child_count() == 3,"three hearts")
	var hazard = level.get_node("Spikes")
	hazard._entered(body)
	await frames(4)
	check(health.hearts == 2 and health.hurt_left > 0 and movement.damage_locked,"damage pose and brief control lock")
	check(health.reaction.visible and health.reaction.animation == "hurt", "damage reaction shown")
	check((hud.hearts_row.get_child(2).texture as AtlasTexture).region.position.y == 128, "HUD removes a heart")
	for i in 30:
		hazard._entered(body)
		await physics_frame
	check(health.hearts == 2 and not movement.damage_locked and health.invulnerability_left > 0, "invulnerability prevents repeated damage while allowing escape")
	await frames(105)
	hazard._entered(body)
	await frames(3)
	check(health.hearts == 1 and not health.dead, "second hit after cooldown")
	await frames(130)
	progress.score = 99
	progress.diamonds = 9
	hazard._entered(body)
	await frames(5)
	check(health.hearts == 0 and health.dead and health.reaction.animation == "defeat", "last hit triggers defeat")
	await frames(90)
	check(current_scene != level and current_scene.scene_file_path.ends_with("adventure_level_1.tscn"), "same level restarts after defeat")
	check(progress.score == 0 and progress.diamonds == 0, "new run starts with empty inventory")
	check(current_scene.get_node("Character/HealthComponent").hearts == 3, "hearts restored on restart")
	print("Health checks complete")
	quit(0)
