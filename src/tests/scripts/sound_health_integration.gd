extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func check(ok: bool, label: String):
	if not ok:
		printerr("FAIL: ",label)
		quit(1)
		return
	print("PASS: ",label)
func run():
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	var body: CharacterBody2D = level.get_node("Character")
	var health = body.get_node("HealthComponent")
	var movement = body.get_node("MovementComponent")
	var enemy = level.get_node("BeetleEnemy")
	await frames(30)
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	check(movement.jump_sound.stream.resource_path.ends_with("jump.wav") and movement.jump_sound.playing, "jump sound plays")
	await frames(65)
	body.position = enemy.position + Vector2(-150,0)
	body.velocity = Vector2.ZERO
	await frames(40)
	check(enemy.state == enemy.State.ATTACK and enemy.wing_sound.playing, "wings play during charge")
	body.position = enemy.position + Vector2(20,0)
	body.velocity = Vector2.ZERO
	await frames(4)
	check(health.hearts == 2 and body.position.x > 1800, "enemy deals one heart without teleport")
	check(health.sound.stream.resource_path.ends_with("hurt.wav"), "damage sound selected")
	for i in 50:
		enemy._on_contact(body)
		await physics_frame
	check(health.hearts == 2, "enemy contact respects invulnerability")
	enemy._on_contact(body)
	body.position = enemy.position + Vector2(0,-45)
	body.velocity = Vector2(0,100)
	enemy._on_contact(body)
	check(enemy.state == enemy.State.DEFEATED and body.velocity.y < 0, "can defeat enemy while invulnerable")
	print("Sound and enemy-health checks complete")
	quit(0)
