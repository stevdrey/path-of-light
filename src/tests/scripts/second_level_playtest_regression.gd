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
	var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var player: CharacterBody2D = level.get_node("Character")
	var health = player.get_node("HealthComponent")
	var gem: Area2D = level.get_node("Collectibles/Blue3")
	var spikes: Area2D = level.get_node("Spikes2")
	if absf(gem.position.x - spikes.position.x) < 65.0:
		fail("blue diamond is too close to the spike for the player body"); return
	var first_beetle: CharacterBody2D = level.get_node("StoneBeetle1")
	first_beetle.detection_range = 0.0
	var min_x := first_beetle.global_position.x
	var max_x := min_x
	for i in range(240):
		await physics_frame
		min_x = minf(min_x, first_beetle.global_position.x)
		max_x = maxf(max_x, first_beetle.global_position.x)
	if max_x - min_x < 90.0 or first_beetle.is_on_wall():
		fail("first stone beetle cannot patrol freely"); return
	player.global_position = gem.global_position + Vector2(-32, 38)
	player.velocity = Vector2.ZERO
	await frames(10)
	var hearts: int = health.hearts
	Input.action_press("move_right")
	for i in range(30):
		await physics_frame
		if not is_instance_valid(gem):
			break
	Input.action_release("move_right")
	if is_instance_valid(gem) or health.hearts != hearts:
		fail("blue diamond was not collected safely from the left: pos=%s health=%d remaining=%s" % [player.global_position, health.hearts, is_instance_valid(gem)]); return
	var spike_a: Area2D = level.get_node("StoneSpikes1")
	var spike_b: Area2D = level.get_node("StoneSpikes2")
	if spike_b.position.x - spike_a.position.x > 52.0:
		fail("stone spike pair is too spread out"); return
	player.global_position = Vector2(7360, 548)
	player.velocity = Vector2.ZERO
	await frames(10)
	Input.action_press("move_right")
	await frames(8)
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(50)
	Input.action_release("move_right")
	if health.hearts != hearts or player.global_position.x < spike_b.position.x + 40.0 or player.global_position.y > 570.0:
		fail("stone spike pair was not crossed safely in one jump: pos=%s health=%d" % [player.global_position, health.hearts]); return
	var beetle: CharacterBody2D = level.get_node("StoneBeetle2")
	beetle.patrol_speed = 0.0
	beetle.detection_range = 0.0
	if not beetle.get_collision_exceptions().has(player):
		fail("beetle still physically collides with player"); return
	player.global_position = beetle.global_position + Vector2(0, -110)
	player.velocity = Vector2(0, 400)
	var defeated := false
	for i in range(40):
		await physics_frame
		if beetle.state == beetle.State.DEFEATED:
			defeated = true
			break
	if not defeated or health.hearts != hearts or player.velocity.y >= 0.0 or beetle.global_position.y > 558.0:
		fail("stomp on second stone beetle must bounce without sinking or damage"); return
	print("PASS: safe diamond and spike route, beetle patrol and stomp")
	quit(0)
