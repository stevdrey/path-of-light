extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var packed: PackedScene = load("res://src/scenes/adventure_level_1.tscn")
	assert(packed != null)
	var level = packed.instantiate()
	root.add_child(level)
	current_scene = level
	var player = level.get_node("Character")
	var move = player.get_node("MovementComponent")
	assert(move.control == move.player_control)
	assert(level.door != null and level.door.next_level.ends_with("adventure_level_2.tscn"))
	assert(level.get_node("Collectibles/BlueKey").kind == 4)
	var initial = player.global_position
	Input.action_press("move_right")
	for i in range(45): await physics_frame
	Input.action_release("move_right")
	assert(player.global_position.x > initial.x + 100)
	print("PASS: player starts in control in safe opening")
	player.global_position = Vector2(520, 548)
	player.velocity = Vector2.ZERO
	for i in range(8): await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for i in range(45): await physics_frame
	Input.action_release("move_right")
	print("jump position=",player.global_position)
	assert(player.global_position.x > 670)
	print("PASS: first obstacle can be jumped")
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	var before: int = progress.score
	var bonus = level.get_node("Collectibles/Bonus4")
	bonus._on_body_entered(player)
	assert(progress.score == before + 10)
	print("PASS: bonus gem awards extra score")
	level.get_node("Collectibles/BlueKey")._on_body_entered(player)
	assert(progress.keys.get(4, false))
	assert(level.collection_hud.key_label.text == "Lista")
	print("PASS: key acquisition updates inventory HUD")
	level._open_door()
	await create_timer(2.4).timeout
	assert(current_scene.scene_file_path.ends_with("adventure_level_2.tscn") and not progress.keys.has(4))
	print("PASS: door consumes key and opens second level")
	quit(0)
