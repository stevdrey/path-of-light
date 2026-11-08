extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)

func run() -> void:
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var portal: Area2D = level.get_node("BonusEntrance")
	player.global_position = Vector2(2944, 358)
	player.velocity = Vector2.ZERO
	await frames(10)
	await process_frame
	var glow := portal.get_node("DiscoveryGlow") as Sprite2D
	if not portal.can_activate(player) or glow == null or not glow.texture is GradientTexture2D or glow.modulate.a <= 0.35:
		fail("portal glow did not respond to proximity"); return
	var radial := glow.texture as GradientTexture2D
	if radial.fill != GradientTexture2D.FILL_RADIAL or radial.gradient.sample(0.0).a <= radial.gradient.sample(1.0).a:
		fail("portal halo is not a fading radial glow"); return
	if level.status.text.contains("portal") or level.status.text.contains("puerta"):
		fail("interaction instruction is still shown in the status"); return
	var settings = root.get_node("GameSettings")
	settings.bind_key("interact_up", KEY_E, false)
	var event := InputEventKey.new()
	event.physical_keycode = KEY_E
	event.pressed = true
	level.movement.input_locked = true
	level._input(event)
	await process_frame
	if level.portal_transitioning:
		fail("locked input activated the portal"); return
	level.movement.input_locked = false
	player.global_position = Vector2(2979, 358)
	player.velocity = Vector2.ZERO
	await frames(8)
	await process_frame
	if portal.can_activate(player):
		fail("portal activated outside its tolerance"); return
	print("PASS: portal proximity glow, activation tolerance and locked input")
	quit(0)
