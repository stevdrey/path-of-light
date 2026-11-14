extends RefCounted
## Data-only campaign storage. Never instantiate objects from a save file.
## One local writer; temporary files are never considered committed saves.

const VERSION := 1
const MAX_BYTES := 1048576
const MAX_RECORDS := 4096
const MAX_LEVEL_ID := 1000000
const FIELDS := ["schema_version", "completed_levels", "recorded_secrets"]

var path: String
var writable := false

func _init(save_path: String = "") -> void:
	path = save_path if not save_path.is_empty() else default_path()

# `--script` test harnesses run with a scripted main loop. They must never touch
# the player's campaign on any OS, so they get a separate default file.
## Static stores may be built while a test script is still loading, before its
## main loop exists, so the command line is checked too.
static func default_path() -> String:
	var loop := Engine.get_main_loop()
	var args := OS.get_cmdline_args()
	var harness := (loop != null and loop.get_script() != null) or args.has("--script") or args.has("-s")
	return "user://test-campaign.json" if harness else "user://campaign.json"

func empty_data() -> Dictionary:
	return {"schema_version": VERSION, "completed_levels": [], "recorded_secrets": []}

func load_campaign() -> Dictionary:
	writable = false
	var primary := _read(path)
	if primary.status in ["loaded", "migrated"]:
		writable = true
		return primary
	# A newer schema must never be replaced by an older backup or empty save.
	if primary.status == "unsupported":
		return primary
	var backup := _read(path + ".bak")
	if backup.status in ["loaded", "migrated"]:
		writable = true
		return {"status": "recovered", "data": backup.data, "error": OK}
	if backup.status == "unsupported":
		return backup
	if primary.status == "missing" and backup.status == "missing":
		writable = true
		return {"status": "new", "data": empty_data(), "error": OK}
	var error: int = primary.error if primary.status != "missing" else backup.error
	return {"status": "corrupt" if error == ERR_FILE_CORRUPT else "io_error", "data": empty_data(), "error": error}

func save_campaign(data: Dictionary) -> Error:
	if not writable:
		return ERR_UNAUTHORIZED
	var decoded := _decode(data)
	if decoded.status != "loaded":
		return ERR_INVALID_DATA
	# Recheck disk before replacing anything. Preserve unreadable or newer files.
	var primary := _read(path)
	var backup := _read(path + ".bak")
	if primary.status == "unsupported" or backup.status == "unsupported":
		writable = false
		return ERR_UNAVAILABLE
	if primary.status == "io_error" or backup.status == "io_error":
		return ERR_FILE_CANT_READ
	var has_primary: bool = primary.status in ["loaded", "migrated"]
	var has_backup: bool = backup.status in ["loaded", "migrated"]
	if not has_primary and not has_backup and (primary.status != "missing" or backup.status != "missing"):
		writable = false
		return ERR_FILE_CORRUPT
	# Either input can be the migration source. Preserve it before publishing a
	# primary or rotating a backup, including v0 backups beside a v1 primary.
	var migration_source := path if primary.status == "migrated" else path + ".bak" if backup.status == "migrated" else ""
	if not migration_source.is_empty():
		var copy_error := _preserve_v0(migration_source)
		if copy_error != OK:
			return copy_error
	var error := _stage(path + ".tmp", decoded.data)
	if error != OK:
		return error
	# Copy, do not move, the last valid primary. It remains available if backup
	# staging/promotion fails. Never rotate a corrupt primary over good recovery.
	if has_primary or not has_backup:
		var previous: Dictionary = primary.data if has_primary else decoded.data
		error = _stage(path + ".bak.tmp", previous)
		if error != OK:
			return error
		error = _promote(path + ".bak.tmp", path + ".bak")
		if error != OK:
			return error
	return _promote(path + ".tmp", path)

func _preserve_v0(source: String) -> Error:
	var destination := path + ".v0.bak"
	var retained := _read(destination)
	if retained.status == "migrated":
		return OK  # Retain the first valid original; never rotate this archive.
	if retained.status != "missing":
		return ERR_FILE_CORRUPT if retained.error == OK else retained.error as Error
	# A failed copy must not leave a partial archive that a later save mistakes
	# for successful preservation. Only promote a validated, byte-identical copy.
	var temporary := destination + ".tmp"
	var error := DirAccess.copy_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(temporary))
	if error != OK:
		return error
	if _read(temporary).status != "migrated" or FileAccess.get_file_as_bytes(source) != FileAccess.get_file_as_bytes(temporary):
		return ERR_FILE_CORRUPT
	return _promote(temporary, destination)

func _stage(destination: String, data: Dictionary) -> Error:
	var file := FileAccess.open(destination, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var text := JSON.stringify(data, "\t") + "\n"
	file.store_string(text)
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	# Byte comparison is enough: `data` was already validated by _decode.
	if FileAccess.get_file_as_string(destination) != text:
		return ERR_FILE_CORRUPT
	return OK

func _promote(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(destination))

func _read(source: String) -> Dictionary:
	if not FileAccess.file_exists(source):
		# A directory at this name is an I/O failure, not a new campaign.
		return _failure("io_error", ERR_FILE_CANT_READ) if DirAccess.dir_exists_absolute(source) else _failure("missing", ERR_FILE_NOT_FOUND)
	var file := FileAccess.open(source, FileAccess.READ)
	if file == null:
		return _failure("io_error", FileAccess.get_open_error())
	if file.get_length() > MAX_BYTES:
		file.close()
		return _failure("corrupt", ERR_FILE_CORRUPT)
	var contents := file.get_as_text()
	var error := file.get_error()
	file.close()
	if error != OK:
		return _failure("io_error", error)
	var json := JSON.new()
	if json.parse(contents) != OK:
		return _failure("corrupt", ERR_FILE_CORRUPT)
	return _decode(json.data)

func _failure(status: String, error: int) -> Dictionary:
	return {"status": status, "data": empty_data(), "error": error}

func _decode(value: Variant) -> Dictionary:
	# Any integral version above ours is newer, however large; never treat it as corrupt.
	if not value is Dictionary or not _is_integer(value.get("schema_version"), 0, INF):
		return _failure("corrupt", ERR_FILE_CORRUPT)
	if value.schema_version > VERSION:
		return _failure("unsupported", ERR_UNAVAILABLE)
	var version := int(value.schema_version)
	if value.size() != FIELDS.size():
		return _failure("corrupt", ERR_FILE_CORRUPT)
	var result := empty_data()
	for field in ["completed_levels", "recorded_secrets"]:
		if not value.has(field):
			return _failure("corrupt", ERR_FILE_CORRUPT)
		var records: Variant = value[field]
		# Version 0 is an explicitly defined migration fixture, never a shipped
		# legacy format: Boolean dictionaries with canonical numeric string keys.
		if version == 0:
			if not records is Dictionary or records.size() > MAX_RECORDS:
				return _failure("corrupt", ERR_FILE_CORRUPT)
			var migrated: Array = []
			for key in records:
				if not key is String or not key.is_valid_int() or str(int(key)) != key or not records[key] is bool or not records[key]:
					return _failure("corrupt", ERR_FILE_CORRUPT)
				migrated.append(int(key))
			records = migrated
		if not records is Array or records.size() > MAX_RECORDS:
			return _failure("corrupt", ERR_FILE_CORRUPT)
		var seen := {}
		for id in records:
			if not _is_integer(id, 1, MAX_LEVEL_ID) or seen.has(int(id)):
				return _failure("corrupt", ERR_FILE_CORRUPT)
			seen[int(id)] = true
		result[field] = seen.keys()
		result[field].sort()
	return {"status": "migrated" if version == 0 else "loaded", "data": result, "error": OK}

func _is_integer(value: Variant, minimum: int, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= minimum and value <= maximum and float(value) == floor(float(value))
