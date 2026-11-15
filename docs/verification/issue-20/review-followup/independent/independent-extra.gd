extends SceneTree
const Store = preload("res://src/scenes/scripts/campaign_save.gd")
const Progress = preload("res://src/scenes/scripts/game_progress.gd")
const Rewards = preload("res://src/scenes/scripts/campaign_rewards.gd")
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		printerr("FAIL: ", message)
		quit(1)
	return ok
func texts(node: Node) -> String:
	var result := ""
	for child in node.get_children():
		if child is Label:
			result += child.text + "\n"
	return result
func run() -> void:
	var store := Store.new("user://independent-legacy.json")
	var file := FileAccess.open(store.path, FileAccess.WRITE)
	file.store_string('{"schema_version":1,"completed_levels":[1,2],"recorded_secrets":[1,99]}')
	file.close()
	Progress.campaign_store = store
	Progress.load_campaign()
	if not check(Progress.recorded_discoveries == {"secret-chamber-1": true}, "legacy startup reconciles exactly the authored portal mapping"):
		return
	if not check(Progress.world_rewards.is_empty() and Progress.character_unlocks.is_empty(), "legacy experimental completions keep all production rewards locked"):
		return
	if not check(Progress.save_campaign() == OK and store.load_campaign().data.recorded_discoveries == ["secret-chamber-1"], "legacy-derived discovery is durable on explicit save"):
		return
	var fixtures := [{"id": "unmapped", "level_id": 1}, {"id": "mapped", "level_id": 1, "legacy_secret_level": 1}, {"id": "other-event", "level_id": 1, "legacy_secret_level": 2}]
	if not check(Rewards.discoveries_for_secrets({1: true}, fixtures) == ["mapped"], "same-level discoveries stay independent by explicit event mapping"):
		return
	for unlocked in [false, true]:
		Progress.character_unlocks = {"future-character": true}
		if unlocked:
			Progress.character_unlocks.prototype = true
		var map: Control = load("res://src/ui/level_map.tscn").instantiate()
		root.add_child(map)
		current_scene = map
		map._open_records()
		await process_frame
		var content := texts(map.records_column)
		if not check(content.contains("Personaje prototipo: desbloqueado") == unlocked and content.contains("Personaje prototipo: bloqueado") == not unlocked, "map renders exact saved prototype identity: " + str(unlocked)):
			return
		if unlocked and not check(content.contains("La selección de personaje aún no está disponible"), "unlocked log states selector remains unavailable"):
			return
		if not check(map.records_column.get_children().filter(func(n): return n is Button).size() == 1, "records log contains only its return button, no selector"):
			return
		Progress.campaign_error = ERR_FILE_CANT_WRITE
		map.refresh()
		if not check(map.records_notice.visible and map.records_notice.text == Progress.campaign_notice(), "live failed-save notice reaches records log"):
			return
		Progress.campaign_status = "recovered"
		Progress.campaign_error = OK
		map.refresh()
		if not check(map.records_notice.visible and map.records_notice.text == Progress.campaign_notice(), "live recovery notice reaches records log"):
			return
		Progress.campaign_status = "loaded"
		map.refresh()
		if not check(not map.records_notice.visible and map.records_notice.text.is_empty(), "notice clears after successful state refresh"):
			return
		map.free()
		current_scene = null
	print("PASS: independent legacy and UI boundaries ", checks, " assertions")
	quit(0)
