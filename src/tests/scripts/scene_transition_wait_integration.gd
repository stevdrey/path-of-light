extends SceneTree

const SceneWait := preload("res://src/tests/scripts/scene_test_wait.gd")
const FIRST := "res://src/scenes/adventure_level_1.tscn"
const SECOND := "res://src/scenes/adventure_level_2.tscn"
const MENU := "res://src/ui/front_end.tscn"

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func delayed_play(menu: Control) -> void:
	# Deliberately leave current_scene as the menu for several process frames.
	for i in 4:
		await process_frame
	menu._play()

func run() -> void:
	var start := Time.get_ticks_msec()
	var absent: Node = await SceneWait.for_scene(self, FIRST, 20)
	if not check(absent == null and Time.get_ticks_msec() - start >= 20, "absent scene returns null after a bounded deadline"):
		return
	for attempt in 3:
		root.set_meta("skip_intro_splash", true)
		if not check(change_scene_to_file(MENU) == OK, "request menu for delayed-play regression"):
			return
		var menu: Control = await SceneWait.for_scene(self, MENU)
		if not check(menu != null, "menu becomes ready within the bounded wait"):
			return
		call_deferred("delayed_play", menu)
		var level: Node2D = await SceneWait.for_scene(self, FIRST)
		if not check(level != null and level.is_node_ready() and level.player_health != null and level.collection_hud != null, "delayed menu replacement returns a fully ready level: %d" % attempt):
			return
		var wrong: Node = await SceneWait.for_scene(self, SECOND, 20)
		if not check(wrong == null and current_scene == level, "wrong scene cannot satisfy the wait"):
			return
		var ready: Node = await SceneWait.for_scene(self, FIRST, 0)
		if not check(ready == level, "already-ready scene satisfies a zero-duration wait"):
			return
	print("PASS: bounded absent/wrong scene waits and three delayed real menu starts")
	current_scene.free()
	current_scene = null
	await process_frame
	quit(0)
