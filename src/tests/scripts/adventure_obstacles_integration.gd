extends SceneTree
func _initialize(): call_deferred("run")
func frames(n):
	for i in n: await physics_frame
func fail(message):
	printerr("FAIL: ",message); quit(1)
func run():
	var a = load("res://src/scenes/adventure_level_1.tscn").instantiate()
	root.add_child(a)
	var body: CharacterBody2D = a.get_node("Character")
	body.global_position = a.get_node("PortalLadder").global_position + Vector2(0, -2)
	body.velocity = Vector2.ZERO
	await frames(10)
	Input.action_press("interact_up")
	await frames(95)
	Input.action_release("interact_up")
	if body.global_position.y > 375:
		fail("portal ladder does not reach upper platform " + str(body.global_position)); return
	body.global_position = Vector2(2944,358)
	body.velocity = Vector2.ZERO
	await frames(10)
	if not a.get_node("BonusEntrance").can_activate(body):
		fail("portal inaccessible at platform"); return
	print("PASS: ladder reaches portal and portal is accessible")
	a.queue_free()
	await process_frame
	var b = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(b)
	body = b.get_node("Character")
	var saw = b.get_node("VerticalSaw")
	var initial: Vector2 = saw.position
	await frames(30)
	if absf(saw.position.x - initial.x) > 0.01 or absf(saw.position.y-initial.y) < 10:
		fail("vertical saw did not move vertically"); return
	print("PASS: vertical saw patrols selected axis")
	var bridge = b.get_node("MovingBridge")
	bridge.elapsed = 8.0
	body.global_position = Vector2(6040,548)
	body.velocity = Vector2.ZERO
	await frames(8)
	Input.action_press("move_right")
	var ridden := false
	for i in range(60):
		await physics_frame
		if body.is_on_floor() and body.get_platform_velocity().length() > 1:
			ridden = true
		if ridden and body.global_position.x >= bridge.position.x - 12: break
	Input.action_release("move_right")
	for i in range(180):
		await physics_frame
		if bridge.position.x > 6280: break
	print("ride player=",body.global_position," bridge=",bridge.position)
	if not ridden or body.global_position.y > 570 or bridge.position.x <= 6280:
		fail("moving platform ride failed"); return
	Input.action_press("move_right")
	await frames(35)
	Input.action_release("move_right")
	print("exit player=",body.global_position," bridge=",bridge.position)
	if body.global_position.x <= 6336 or body.global_position.y > 570:
		fail("moving bridge crossing failed"); return
	print("PASS: player can ride the moving bridge across wide gap")
	quit(0)
