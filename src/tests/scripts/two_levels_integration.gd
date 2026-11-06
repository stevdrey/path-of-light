extends SceneTree
func _initialize(): call_deferred("run")
func frames(n: int):
	for i in n: await physics_frame
func up_key():
	var e := InputEventKey.new()
	e.keycode = KEY_UP
	e.physical_keycode = KEY_UP
	e.pressed = true
	Input.parse_input_event(e)
	await physics_frame
	e = InputEventKey.new()
	e.keycode = KEY_UP
	e.physical_keycode = KEY_UP
	e.pressed = false
	Input.parse_input_event(e)
func fail(message: String):
	printerr("FAIL: ", message)
	quit(1)
func run():
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var portal = level.get_node("BonusEntrance")
	player.global_position = Vector2(2979,358)
	player.velocity = Vector2.ZERO
	await frames(10)
	if not portal.overlaps_body(player) or portal.can_activate(player):
		fail("portal should ignore player at its edge"); return
	await up_key()
	await frames(10)
	if level.portal_transitioning or player.velocity.y >= 0:
		fail("player should jump rather than activate at edge"); return
	print("PASS: portal needs centered player; up still jumps at edge")
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	level.get_node("Collectibles/Bonus4")._on_body_entered(player)
	level.get_node("Collectibles/BlueKey")._on_body_entered(player)
	level.player_health.hearts = 2
	progress.hearts = 2
	var score_before: int = progress.score
	player.global_position = level.door.global_position + Vector2(0,-2)
	player.velocity = Vector2.ZERO
	await frames(10)
	if not level.door.player_nearby:
		fail("player not in door area"); return
	await up_key()
	await frames(190)
	level = current_scene
	if level == null or not level.scene_file_path.ends_with("adventure_level_2.tscn"):
		fail("first door did not transition to second level"); return
	if progress.score != score_before or level.player_health.hearts != 2 or progress.keys.has(4):
		fail("score/hearts/key not preserved on level transition"); return
	print("PASS: door transitions to level two preserving score and hearts")
	player = level.get_node("Character")
	player.global_position = Vector2(1792,548)
	player.velocity = Vector2.ZERO
	await frames(12)
	Input.action_press("interact_up")
	await frames(95)
	Input.action_release("interact_up")
	if player.global_position.y > 375:
		fail("ladder did not reach key platform: " + str(player.global_position)); return
	print("PASS: ladder reaches elevated yellow key platform")
	player.global_position = Vector2(1888,358)
	player.velocity = Vector2.ZERO
	await frames(12)
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await frames(45)
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	await frames(12)
	if not progress.keys.get(5,false):
		fail("yellow key not collectible on platform"); return
	if level.door.required_key != 5 or not level.door.next_level.is_empty():
		fail("second door configuration"); return
	print("PASS: yellow key collectible and matches final door")
	quit(0)
