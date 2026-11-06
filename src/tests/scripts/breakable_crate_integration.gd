extends SceneTree
func _initialize(): call_deferred("run")
func frames(n: int):
	for i in n: await physics_frame
func fail(msg: String):
	printerr("FAIL: ",msg); quit(1)
func jump():
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
func run():
	var progress = load("res://src/scenes/scripts/game_progress.gd")
	var level = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	var body: CharacterBody2D = level.get_node("Character")
	var crate = level.get_node("DiamondCrate")
	var crate_x: float = crate.global_position.x
	var old_score: int = progress.score
	body.global_position = Vector2(crate_x,548)
	body.velocity = Vector2.ZERO
	await frames(10)
	await jump()
	await frames(18)
	if is_instance_valid(crate):
		fail("diamond crate did not break when jumped into from below"); return
	var released: CollectibleItem
	for child in level.get_node("Collectibles").get_children():
		if child is CollectibleItem and child.kind == CollectibleItem.Kind.GREEN_DIAMOND and absf(child.global_position.x - crate_x) < 1:
			released = child
	if released == null:
		fail("green diamond not released"); return
	var fragments = level.get_node_or_null("CrateFragments")
	if fragments == null or not fragments.get_node("Fragments").emitting:
		fail("crate fragments not emitted"); return
	if fragments.get_node("Fragments").amount != 4 or fragments.get_node("Fragments").gravity.y > 200:
		fail("crate explosion count or gravity is incorrect"); return
	released._on_body_entered(body)
	if progress.score != old_score + 5:
		fail("released diamond not credited"); return
	print("PASS: underside jump breaks crate, emits fragments and diamond scores")
	await frames(80)
	if is_instance_valid(fragments):
		fail("crate fragments did not clean up"); return
	var health = body.get_node("HealthComponent")
	var heart_crate = level.get_node("HeartCrate")
	body.global_position = Vector2(heart_crate.global_position.x,548)
	body.velocity = Vector2.ZERO
	await frames(10)
	await jump()
	await frames(22)
	if is_instance_valid(heart_crate):
		fail("heart crate did not break"); return
	var heart: CollectibleItem
	for child in level.get_node("Collectibles").get_children():
		if child is CollectibleItem and child.kind == CollectibleItem.Kind.HEART:
			heart = child
	if heart == null:
		fail("heart not released"); return
	heart._on_body_entered(body)
	if heart.taken or health.hearts != 3:
		fail("heart consumed at full health"); return
	health.hearts = 2
	health.health_changed.emit(2,health.max_hearts)
	heart._on_body_entered(body)
	if health.hearts != 3 or progress.hearts != 3:
		fail("heart did not restore health or HUD progress"); return
	print("PASS: heart waits at full health, restores one heart when needed")
	level.queue_free()
	await process_frame
	progress.reset()
	level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	body = level.get_node("Character")
	var key_crate = level.get_node("KeyCrate")
	body.global_position = Vector2(1888,358)
	body.velocity = Vector2.ZERO
	await frames(10)
	await jump()
	await frames(8)
	if is_instance_valid(key_crate):
		fail("key crate did not break from platform"); return
	var key: CollectibleItem
	for child in level.get_node("Collectibles").get_children():
		if child is CollectibleItem and child.kind == CollectibleItem.Kind.YELLOW_KEY:
			key = child
	if key == null:
		fail("yellow key not released"); return
	await frames(45)
	body.global_position.x = 1888
	body.velocity = Vector2.ZERO
	await frames(5)
	await jump()
	await frames(12)
	if not progress.keys.get(5,false):
		fail("released key not registered"); return
	print("PASS: yellow key crate breaks and released key is registered")
	quit(0)
