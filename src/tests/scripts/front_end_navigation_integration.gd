extends SceneTree

const Wait := preload("res://src/tests/scripts/scene_test_wait.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const Registry := preload("res://src/scenes/scripts/campaign_registry.gd")
const MapNavigation := preload("res://src/ui/scripts/map_navigation.gd")

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func menu_scene(failures: int = 0) -> Control:
	root.set_meta("skip_intro_splash", true)
	var menu: Control = load("res://src/ui/front_end.tscn").instantiate()
	# Load after autoload initialization; do not statically inherit a UI script
	# that references those autoload globals during SceneTree compilation.
	menu.set_script(load("res://src/tests/scripts/front_end_navigation_probe.gd"))
	menu.failures_left = failures
	root.add_child(menu)
	current_scene = menu
	return menu

func select(menu: Control, map: bool) -> void:
	# Emitting signals also exercises handler guards even on disabled buttons.
	(menu.map_button if map else menu.play_button).pressed.emit()

func run() -> void:
	Progress.reset()
	for order in [[true, false], [false, true], [true, true], [false, false]]:
		var menu := menu_scene()
		var requests: Array = menu.requests
		select(menu, order[0])
		select(menu, order[1])
		var target: String = MapNavigation.SCENE if order[0] else Registry.first_level_path()
		var scene: Node = await Wait.for_scene(self, target)
		if not check(scene != null and requests == [target], "same-frame competing/duplicate menu actions accept exactly the first request: %s" % str(order)):
			return
		scene.free()
		current_scene = null
	print("PASS: MAPA/JUGAR in both orders and duplicate actions make one scene request")
	for map in [true, false]:
		Progress.campaign_status = "unsupported"
		Progress.score = 77
		Progress.hearts = 1
		var menu := menu_scene(1)
		var requests: Array = menu.requests
		select(menu, map)
		select(menu, not map)
		for i in 3:
			await process_frame
		var button: Button = menu.map_button if map else menu.play_button
		if not check(current_scene == menu and requests.size() == 1 and menu.pending_scene.is_empty() and not menu.map_button.disabled and not menu.play_button.disabled and button.has_focus(), "failed menu request restores both actions and initiating focus"):
			return
		if not check(Progress.score == 77 and Progress.hearts == 1 and menu.save_notice.text.contains(Progress.campaign_notice()) and menu.save_notice.text.contains("Reintenta"), "failed menu request retains inventory and campaign warning alongside visible retry"):
			return
		select(menu, map)
		var target: String = MapNavigation.SCENE if map else Registry.first_level_path()
		var scene: Node = await Wait.for_scene(self, target)
		if not check(scene != null and requests == [target, target], "retry after either menu request failure reaches its selected destination"):
			return
		scene.free()
		current_scene = null
	print("PASS: both failed destinations preserve state, warning and retry focus")
	# An external scene switch/removal can supersede a queued callback. A
	# detached but not freed old menu must not issue any scene request.
	for map in [true, false]:
		var menu := menu_scene()
		var requests: Array = menu.requests
		select(menu, map)
		root.remove_child(menu)
		current_scene = null
		for i in 3:
			await process_frame
		if not check(requests.is_empty() and current_scene == null, "detached menu ignores a pending MAPA/JUGAR callback"):
			return
		menu.free()
	print("PASS: detached menus issue no deferred scene request")
	quit(0)
