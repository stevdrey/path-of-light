extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var level = load("res://src/scenes/adventure_level_2.tscn").instantiate()
	root.add_child(level)
	var saw = level.get_node("Saw2")
	var initial: float = saw.position.x
	for i in range(35): await physics_frame
	if saw.position.x < initial + 20 or saw.position.x > initial + saw.patrol_distance + 0.1:
		printerr("FAIL: saw did not patrol within configured distance"); quit(1); return
	print("PASS: saw moves within its configured patrol")
	quit(0)
