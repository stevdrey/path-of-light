extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var health = player.get_node("HealthComponent")
	for i in range(3):
		player.global_position = Vector2(2080, 830)
		player.velocity = Vector2.ZERO
		await physics_frame
		await physics_frame
		if health.hearts != 2 - i:
			printerr("FAIL: fall damage ", i, " hearts=",health.hearts)
			quit(1)
			return
	for i in range(110): await physics_frame
	if current_scene == level or not current_scene.scene_file_path.ends_with("adventure_level_1.tscn"):
		printerr("FAIL: final fall did not restart the expanded level")
		quit(1)
		return
	print("PASS: three falls consume hearts and restart expanded level")
	quit()
