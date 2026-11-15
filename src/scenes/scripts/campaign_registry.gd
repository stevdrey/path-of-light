extends RefCounted
## Ordered prototype routes. IDs are the published save IDs, never array indices.
## Adding content requires the playable-slice scope gate and explicit metadata.

const LEVELS := [
	{"id": 1, "title": "Sendero de descubrimiento", "scene_path": "res://src/scenes/adventure_level_1.tscn"},
	{"id": 2, "title": "Sendero de piedra", "scene_path": "res://src/scenes/adventure_level_2.tscn"},
]

static func levels() -> Array:
	return LEVELS.duplicate(true)

static func _index(level_id: int) -> int:
	for index in LEVELS.size():
		if LEVELS[index].id == level_id:
			return index
	return -1

static func level(level_id: int) -> Dictionary:
	var index := _index(level_id)
	return LEVELS[index].duplicate(true) if index >= 0 else {}

static func first_level_path() -> String:
	return LEVELS[0].scene_path

static func is_first(level_id: int) -> bool:
	return _index(level_id) == 0

static func next_level_path(level_id: int) -> String:
	var index := _index(level_id)
	return LEVELS[index + 1].scene_path if index >= 0 and index < LEVELS.size() - 1 else ""

static func is_open(level_id: int, completions: Dictionary) -> bool:
	var target := _index(level_id)
	if target < 0:
		return false
	# Preserve revisiting even for a legacy/direct-entry completion without
	# earlier records. Unknown saved IDs never unlock registered routes.
	if completions.get(level_id, false):
		return true
	for index in target:
		if not completions.get(LEVELS[index].id, false):
			return false
	return true
