extends SceneTree

const Store := preload("res://src/scenes/scripts/campaign_save.gd")
const DATA := {"schema_version": 1, "completed_levels": [1], "recorded_secrets": [2]}
const NEXT := {"schema_version": 1, "completed_levels": [1, 2], "recorded_secrets": [2]}
var checks := 0

class FaultStore extends "res://src/scenes/scripts/campaign_save.gd":
	var fail_stage := ""
	var fail_promote := ""
	func _stage(destination: String, data: Dictionary) -> Error:
		if destination.ends_with(fail_stage) and not fail_stage.is_empty():
			var partial := FileAccess.open(destination, FileAccess.WRITE)
			partial.store_string("{\"schema_version\":")
			partial.close()
			return ERR_FILE_CANT_WRITE
		return super._stage(destination, data)
	func _promote(source: String, destination: String) -> Error:
		if destination.ends_with(fail_promote) and not fail_promote.is_empty():
			return ERR_FILE_CANT_WRITE
		return super._promote(source, destination)

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	checks += 1
	if not condition:
		printerr("FAIL: ", message)
		quit(1)
	return condition

func put(path: String, value: Variant, raw := false) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value if raw else JSON.stringify(value))
	file.close()

func fresh(name: String) -> RefCounted:
	return Store.new("user://storage-tests/" + name + ".json")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("user://storage-tests")
	var store := fresh("roundtrip")
	if not check(store.load_campaign().status == "new" and store.save_campaign(DATA) == OK and store.load_campaign().data == DATA, "first save and reload"):
		return
	if not check(store.save_campaign(NEXT) == OK and fresh("roundtrip").load_campaign().data == NEXT, "replace existing primary atomically"):
		return
	put(store.path, "{broken", true)
	if not check(store.load_campaign().status == "recovered" and store.load_campaign().data == DATA and store.save_campaign(NEXT) == OK, "corrupt primary recovers previous commit and remains writable"):
		return
	put(store.path, "{broken again", true)
	if not check(store.load_campaign().data == DATA, "repair never rotates corrupt primary over good backup"):
		return
	DirAccess.remove_absolute(store.path)
	if not check(store.load_campaign().status == "recovered" and store.load_campaign().data == DATA, "missing primary recovers backup"):
		return
	var invalids: Array = [null, [], {}, {"schema_version": true}, {"schema_version": 1.5},
		{"schema_version": 1, "completed_levels": [true], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [1.5], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [-1], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [0], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [1000001], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [1, 1], "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": "1", "recorded_secrets": []},
		{"schema_version": 1, "completed_levels": [], "recorded_secrets": [], "keys": [4]},
		{"schema_version": 0, "completed_levels": {"01": true}, "recorded_secrets": {}},
		{"schema_version": 0, "completed_levels": {"1": 1}, "recorded_secrets": {}},
		{"schema_version": 0, "completed_levels": {"1": false}, "recorded_secrets": {}}]
	for i in invalids.size():
		store = fresh("invalid%d" % i)
		put(store.path, invalids[i])
		var before := FileAccess.get_file_as_string(store.path)
		if not check(store.load_campaign().status == "corrupt" and store.save_campaign(DATA) != OK and FileAccess.get_file_as_string(store.path) == before, "invalid data is rejected and preserved: %d" % i):
			return
	store = fresh("oversize")
	put(store.path, " ".repeat(Store.MAX_BYTES + 1), true)
	if not check(store.load_campaign().status == "corrupt", "bounded save size"):
		return
	store = fresh("too-many")
	var many := DATA.duplicate(true)
	many.completed_levels = range(1, Store.MAX_RECORDS + 2)
	put(store.path, many)
	if not check(store.load_campaign().status == "corrupt", "bounded record count"):
		return
	store = fresh("both-corrupt")
	put(store.path, "{primary", true)
	put(store.path + ".bak", "{backup", true)
	if not check(store.load_campaign().status == "corrupt" and store.save_campaign(DATA) != OK and FileAccess.get_file_as_string(store.path + ".bak") == "{backup", "both corrupt files preserved; play may use empty memory records"):
		return
	store = fresh("future")
	var future := {"schema_version": 2, "new_field": {"do_not_drop": true}}
	put(store.path, future)
	put(store.path + ".bak", DATA)
	if not check(store.load_campaign().status == "unsupported" and store.save_campaign(DATA) != OK and FileAccess.get_file_as_string(store.path) == JSON.stringify(future), "newer primary never downgrades to backup or gets overwritten"):
		return
	store = fresh("future-backup")
	put(store.path + ".bak", future)
	if not check(store.load_campaign().status == "unsupported" and store.save_campaign(DATA) != OK, "newer recovery data also protected"):
		return
	store = fresh("future-arrives")
	store.load_campaign()
	store.save_campaign(DATA)
	put(store.path + ".bak", future)
	var committed := FileAccess.get_file_as_string(store.path)
	if not check(store.save_campaign(NEXT) != OK and FileAccess.get_file_as_string(store.path) == committed, "recheck disk before rotating backup"):
		return
	store = fresh("migration")
	put(store.path, {"schema_version": 0, "completed_levels": {"2": true, "1": true}, "recorded_secrets": {"2": true}})
	if not check(store.load_campaign().status == "migrated" and store.load_campaign().data == NEXT and store.save_campaign(store.load_campaign().data) == OK and store.load_campaign().status == "loaded", "defined v0 fixture migrates deterministically and upgrades on write"):
		return
	for phase in ["stage-primary", "stage-backup", "promote-backup", "promote-primary"]:
		var fault := FaultStore.new("user://storage-tests/" + phase + ".json")
		fault.load_campaign()
		fault.save_campaign(DATA)
		if phase.begins_with("stage"):
			fault.fail_stage = ".bak.tmp" if phase.ends_with("backup") else ".tmp"
		else:
			fault.fail_promote = ".bak" if phase.ends_with("backup") else ".json"
		if not check(fault.save_campaign(NEXT) != OK and Store.new(fault.path).load_campaign().data == DATA, "write failure keeps prior committed save: " + phase):
			return
	store = fresh("uncommitted")
	put(store.path + ".tmp", NEXT)
	put(store.path + ".bak.tmp", NEXT)
	if not check(store.load_campaign().status == "new" and store.load_campaign().data == store.empty_data(), "orphan temporary files are never treated as committed saves"):
		return
	store = Store.new("user://missing-directory/campaign.json")
	store.load_campaign()
	if not check(store.save_campaign(DATA) != OK, "real open failure returns an error"):
		return
	store = fresh("directory")
	DirAccess.make_dir_absolute(store.path)
	if not check(store.load_campaign().status == "io_error" and store.save_campaign(DATA) != OK, "directory collision is not treated as an empty install"):
		return
	print("PASS: campaign storage ", checks, " assertions (validation, migration, recovery, version protection and write failures)")
	quit(0)
