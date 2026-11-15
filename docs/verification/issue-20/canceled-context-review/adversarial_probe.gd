extends SceneTree
const Store := preload("res://src/scenes/scripts/campaign_save.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func verify(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		printerr("FAIL: independent probe: " + message)
		quit(1)
	return ok

func put(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func run() -> void:
	var original := "{\r\n  \"schema_version\": 1, \"completed_levels\": [999, 2, 1],\r\n  \"recorded_secrets\": [999, 1]\r\n}\r\n"
	put(Store.default_path(), original)
	Progress.load_campaign()
	if not verify(Progress.campaign_status == "migrated" and Progress.recorded_discoveries == {"secret-chamber-1": true} and Progress.world_rewards.is_empty() and Progress.character_unlocks.is_empty(), "v1 legacy portal inferred only for authored discovery, no campaign grants"):
		return
	if not verify(Progress.save_campaign() == OK and FileAccess.get_file_as_string(Store.default_path() + ".v1.bak") == original, "gameplay-level upgrade preserves exact v1 bytes"):
		return
	var upgraded := Store.new().load_campaign()
	if not verify(upgraded.status == "loaded" and upgraded.data.completed_levels == [1, 2, 999] and upgraded.data.recorded_secrets == [1, 999] and upgraded.data.recorded_discoveries == ["secret-chamber-1"], "upgraded document has canonical retained records"):
		return
	var committed := FileAccess.get_file_as_string(Store.default_path())
	Progress.reset()
	if not verify(Progress.recorded_discoveries.is_empty() and Progress.world_rewards.is_empty() and Progress.character_unlocks.is_empty() and Progress.save_campaign() == ERR_UNAUTHORIZED and FileAccess.get_file_as_string(Store.default_path()) == committed, "test reset cannot overwrite persistent reward facts"):
		return
	Progress.load_campaign()
	for field in Store.REWARD_FIELDS:
		for value in [["a", "a"], ["A"], ["path/to/scene.tscn"], [false], [5], ["x".repeat(97)]]:
			var data := Store.new().empty_data()
			data[field] = value
			var invalid_path := "user://invalid-reward.json"
			put(invalid_path, JSON.stringify(data))
			var invalid := Store.new(invalid_path)
			var prior := FileAccess.get_file_as_string(invalid_path)
			if not verify(invalid.load_campaign().status == "corrupt" and invalid.save_campaign(upgraded.data) == ERR_UNAUTHORIZED and FileAccess.get_file_as_string(invalid_path) == prior, "malformed reward load preserved: " + field):
				return
	# A protected newer backup must remain untouched even beside a valid v2 primary.
	var future := "{\"schema_version\": 3, \"future_reward\": \"retained\"}"
	put(Store.default_path() + ".bak", future)
	if not verify(Progress.record_discovery("secret-chamber-1") == OK and Progress.save_campaign() == ERR_UNAVAILABLE and FileAccess.get_file_as_string(Store.default_path()) == committed and FileAccess.get_file_as_string(Store.default_path() + ".bak") == future, "future backup blocks writes without dropping memory records"):
		return
	print("PASS: independent adversarial probe ", checks, " assertions")
	quit(0)
