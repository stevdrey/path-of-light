extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
func press_up() -> void:
	var press := InputEventKey.new()
	press.keycode = KEY_UP
	press.physical_keycode = KEY_UP
	press.pressed = true
	Input.parse_input_event(press)
	await physics_frame
	var release := InputEventKey.new()
	release.keycode = KEY_UP
	release.physical_keycode = KEY_UP
	release.pressed = false
	Input.parse_input_event(release)
func run() -> void:
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var health = player.get_node("HealthComponent")
	var entrance: Area2D = level.get_node("BonusEntrance")
	var exit: Area2D = level.get_node("BonusExit")
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	if level.get_node("PortalTrail").get_child_count() < 6:
		fail("missing repeated portal markers"); return
	player.global_position = Vector2(2944,358)
	player.velocity = Vector2.ZERO
	await frames(10)
	if not entrance.overlaps_body(player) or not entrance.player_nearby:
		fail("entrance or proximity not detectable"); return
	if entrance.z_index >= player.z_index or entrance.has_node("Prompt"):
		fail("portal must be behind player with no text prompt"); return
	if entrance.get_node("Glow").modulate.a <= 0.1:
		fail("portal glow did not respond to player"); return
	var hearts_before: int = health.hearts
	await press_up()
	await frames(5)
	if not level.vortex_overlay.visible or level.vortex_material.get_shader_parameter("intensity") <= 0.0:
		fail("vortex effect did not start"); return
	var sound_playing := false
	for child in root.get_children():
		if child is AudioStreamPlayer and child.stream != null and child.stream.resource_path.ends_with("portal_whoosh_sfx_engine.wav") and child.playing and child.bus == &"SFX" and is_equal_approx(child.volume_db, -8.0):
			sound_playing = true
	if not sound_playing:
		fail("portal sound did not play"); return
	await frames(50)
	if not level.in_secret or player.global_position.y < 900 or health.hearts != hearts_before or level.portal_transitioning:
		fail("entrance did not transport to bonus safely"); return
	print("PASS: proximity glow, depth, vortex and sound; entrance reaches bonus")
	var prior_score: int = progress.score
	level.get_node("Collectibles/SecretGem2")._on_body_entered(player)
	if progress.score != prior_score + 10:
		fail("bonus reward not credited"); return
	player.global_position = Vector2(3820,1188)
	player.velocity = Vector2.ZERO
	await frames(10)
	if not exit.overlaps_body(player):
		fail("exit portal not reachable"); return
	await press_up()
	await frames(50)
	if level.in_secret or player.global_position.distance_to(exit.destination) > 40 or level.portal_transitioning:
		fail("exit did not return to path"); return
	if progress.score != prior_score + 10 or health.hearts != hearts_before:
		fail("exit changed score or hearts"); return
	print("PASS: up at exit returns with bonus and hearts preserved")
	player.global_position = Vector2(250,548)
	player.velocity = Vector2.ZERO
	await frames(10)
	await press_up()
	await frames(5)
	if player.velocity.y >= 0:
		fail("up no longer jumps away from portals"); return
	print("PASS: up still jumps when no portal is nearby")
	quit(0)
