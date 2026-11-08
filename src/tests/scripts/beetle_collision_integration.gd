extends SceneTree
func _initialize(): call_deferred("run")
func frames(n: int):
	for i in n: await physics_frame
func make_world() -> Node2D:
	var world := Node2D.new()
	var ground := StaticBody2D.new()
	ground.position = Vector2(500,566)
	var ground_shape := RectangleShape2D.new()
	ground_shape.size = Vector2(1000,32)
	var collider := CollisionShape2D.new()
	collider.shape = ground_shape
	ground.add_child(collider)
	world.add_child(ground)
	var player = load("res://src/character/character.tscn").instantiate()
	player.name = "Player"
	player.position = Vector2(200,548)
	player.add_to_group("player")
	var health = load("res://src/character/components/player_health.tscn").instantiate()
	player.add_child(health)
	world.add_child(player)
	var beetle = load("res://src/enemies/beetle.tscn").instantiate()
	beetle.name = "Enemy"
	beetle.position = Vector2(500,550)
	beetle.patrol_speed = 0.0
	beetle.detection_range = 0.0
	world.add_child(beetle)
	root.add_child(world)
	player.get_node("MovementComponent").use_player_control()
	return world
func run():
	var world = make_world()
	var player: CharacterBody2D = world.get_node("Player")
	var enemy = world.get_node("Enemy")
	var health = player.get_node("HealthComponent")
	await frames(8)
	player.global_position = enemy.global_position + Vector2(0,-85)
	player.velocity = Vector2(0,200)
	var bounced := false
	for i in range(35):
		await physics_frame
		if enemy.state == enemy.State.DEFEATED and player.velocity.y < 0:
			bounced = true
			break
	if not bounced or health.hearts != 3:
		printerr("FAIL: top contact should defeat beetle and bounce, state=",enemy.state," hearts=",health.hearts," pos=",player.global_position); quit(1); return
	print("PASS: physical stomp defeats resized beetle and bounces player")
	world.queue_free()
	await process_frame
	world = make_world()
	player = world.get_node("Player")
	enemy = world.get_node("Enemy")
	health = player.get_node("HealthComponent")
	await frames(8)
	player.global_position = enemy.global_position + Vector2(0,-120)
	player.velocity = Vector2(0,1200)
	bounced = false
	for i in range(35):
		await physics_frame
		if enemy.state == enemy.State.DEFEATED and player.velocity.y < 0:
			bounced = true
			break
	if not bounced or health.hearts != 3:
		printerr("FAIL: fast falling top contact must stomp rather than damage"); quit(1); return
	print("PASS: fast falling top contact defeats beetle")
	world.queue_free()
	await process_frame
	world = make_world()
	player = world.get_node("Player")
	enemy = world.get_node("Enemy")
	health = player.get_node("HealthComponent")
	enemy.patrol_speed = 65.0
	enemy.detection_range = 0.0
	await frames(8)
	player.global_position = enemy.global_position + Vector2(0,-120)
	player.velocity = Vector2(0,1200)
	bounced = false
	for i in range(35):
		await physics_frame
		if enemy.state == enemy.State.DEFEATED and player.velocity.y < 0:
			bounced = true
			break
	if not bounced or health.hearts != 3:
		printerr("FAIL: fast falling top contact on moving beetle"); quit(1); return
	print("PASS: fast falling top contact defeats moving beetle")
	world.queue_free()
	await process_frame
	world = make_world()
	player = world.get_node("Player")
	enemy = world.get_node("Enemy")
	health = player.get_node("HealthComponent")
	await frames(8)
	player.global_position = enemy.global_position + Vector2(50,-2)
	player.velocity = Vector2.ZERO
	await frames(8)
	if health.hearts != 2 or enemy.state == enemy.State.DEFEATED:
		printerr("FAIL: side collision should damage player, hearts=",health.hearts); quit(1); return
	print("PASS: physical side contact damages player")
	world.queue_free()
	await process_frame
	world = make_world()
	player = world.get_node("Player")
	enemy = world.get_node("Enemy")
	health = player.get_node("HealthComponent")
	await frames(8)
	player.global_position = enemy.global_position + Vector2(50,-15)
	player.velocity = Vector2(0,200)
	await frames(8)
	if health.hearts != 2 or enemy.state == enemy.State.DEFEATED:
		printerr("FAIL: falling side contact should damage player"); quit(1); return
	print("PASS: falling side contact damages player")
	world.queue_free()
	await process_frame
	quit(0)
