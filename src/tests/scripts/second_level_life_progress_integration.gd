extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	progress.reset()
	progress.score = 23
	progress.diamond_counts.assign([2,1,0,1])
	progress.diamonds = 4
	progress.hearts = 2
	var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	var health = body.get_node("HealthComponent")
	level.get_node("Collectibles/Green1")._on_body_entered(body)
	if progress.score != 28 or health.hearts != 2:
		printerr("FAIL: initial inventory not preserved"); quit(1); return
	for i in range(2):
		body.global_position = Vector2(800,830)
		body.velocity = Vector2.ZERO
		await physics_frame
		await physics_frame
	for i in range(110): await physics_frame
	if current_scene == level or not current_scene.scene_file_path.ends_with("adventure_level_2.tscn") or progress.score != 23 or progress.hearts != 3 or progress.diamonds != 4:
		printerr("FAIL: level two restart did not restore entry progress"); quit(1); return
	print("PASS: level two retries preserve entry inventory and restore hearts")
	quit(0)
