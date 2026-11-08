extends SceneTree

var world: Node2D
var player: CharacterBody2D
var movement: MovementComponent
var floor_body: StaticBody2D

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)

func setup() -> void:
	world = Node2D.new()
	root.add_child(world)
	current_scene = world
	floor_body = StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(500, 20)
	shape.shape = rectangle
	floor_body.add_child(shape)
	floor_body.position = Vector2(0, 10)
	world.add_child(floor_body)
	player = load("res://src/character/character.tscn").instantiate()
	player.position = Vector2(0, -5)
	world.add_child(player)
	movement = player.get_node("MovementComponent")
	movement.use_player_control()
	await frames(12)

func teardown() -> void:
	Input.action_release("jump")
	world.queue_free()
	await process_frame

func tap_jump() -> void:
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(2)

func coyote_case(wait_frames: int, should_jump: bool) -> bool:
	await setup()
	if not player.is_on_floor():
		return false
	floor_body.queue_free()
	await frames(wait_frames)
	await tap_jump()
	var jumped := player.velocity.y < 0.0
	await teardown()
	return jumped == should_jump

func buffer_case(height: float, should_jump: bool) -> bool:
	await setup()
	player.global_position = Vector2(0, -height)
	player.velocity = Vector2(0, 300)
	# Clear the previous grounded state and coyote time before pressing jump.
	await frames(8)
	await tap_jump()
	var jumped := false
	for i in range(40):
		await physics_frame
		if player.velocity.y < -100.0:
			jumped = true
			break
		if player.is_on_floor() and movement.jump_buffer_left <= 0.0:
			break
	await teardown()
	return jumped == should_jump

func corner_case(limit: int, ceiling_x: float, should_shift: bool) -> bool:
	await setup()
	var ceiling := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(40, 20)
	shape.shape = rectangle
	ceiling.add_child(shape)
	ceiling.position = Vector2(ceiling_x, -75)
	world.add_child(ceiling)
	movement.corner_correction_pixels = limit
	await frames(2)
	await tap_jump()
	var shifted := player.global_position.x < -1.0
	await teardown()
	return shifted == should_shift

func run() -> void:
	if not await coyote_case(3, true):
		fail("jump within coyote window"); return
	if not await coyote_case(12, false):
		fail("jump after coyote window"); return
	if not await buffer_case(100.0, true):
		fail("jump buffered shortly before landing"); return
	if not await buffer_case(260.0, false):
		fail("expired buffer must not jump after landing"); return
	if not await corner_case(20, 40.0, true):
		fail("corner correction did not clear a shallow ceiling edge"); return
	if not await corner_case(20, 20.0, false):
		fail("corner correction exceeded its limit"); return
	if not await corner_case(0, 40.0, false):
		fail("disabled corner correction shifted the player"); return
	print("PASS: coyote, jump buffer and ceiling-corner correction")
	quit(0)
