extends SceneTree
func _initialize(): call_deferred("run")
func run():
	if ProjectSettings.get_setting("layer_names/2d_physics/layer_1") != "Mundo y jugador" or ProjectSettings.get_setting("layer_names/2d_physics/layer_2") != "Plataformas escalables" or ProjectSettings.get_setting("layer_names/2d_physics/layer_3") != "Enemigos":
		printerr("FAIL: layer names"); quit(1); return
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	var player = level.get_node("Character")
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	var gem = level.get_node("Collectibles/Bonus4")
	var expected = gem.points
	gem._on_body_entered(player)
	gem._on_body_entered(player)
	if progress.score != expected:
		printerr("FAIL: gem collected more than once"); quit(1); return
	var effects := []
	for child in level.get_node("Collectibles").get_children():
		if child.get_script() != null and child.get_script().resource_path.ends_with("diamond_pickup_effect.gd"):
			effects.append(child)
	if effects.size() != 1 or effects[0].glow_color != Color("ff9c3e"):
		printerr("FAIL: wrong glow count or color"); quit(1); return
	print("PASS: named layers, single collection, matching diamond glow")
	await create_timer(0.6).timeout
	if is_instance_valid(effects[0]):
		printerr("FAIL: glow was not freed"); quit(1); return
	var count: int = level.get_node("Collectibles").get_child_count()
	level.get_node("Collectibles/BlueKey")._on_body_entered(player)
	await process_frame
	if level.get_node("Collectibles").get_child_count() != count - 1:
		printerr("FAIL: key created a diamond effect"); quit(1); return
	print("PASS: glow cleans itself up and keys stay unchanged")
	quit(0)
