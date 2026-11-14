extends RefCounted
## Ordered prototype routes. IDs are the published save IDs, never array indices.
## Adding content requires the playable-slice scope gate and explicit metadata.

const LEVELS := [
	{"id": 1, "title": "Sendero de descubrimiento", "scene_path": "res://src/scenes/adventure_level_1.tscn"},
	{"id": 2, "title": "Sendero de piedra", "scene_path": "res://src/scenes/adventure_level_2.tscn"},
]

static func levels() -> Array:
	return LEVELS.duplicate(true)

static func level(level_id: int) -> Dictionary:
	for entry in LEVELS:
		if entry.id == level_id:
			return entry.duplicate(true)
	return {}

static func next_level_path(level_id: int) -> String:
	for index in LEVELS.size() - 1:
		if LEVELS[index].id == level_id:
			return LEVELS[index + 1].scene_path
	return ""

static func is_open(level_id: int, completions: Dictionary) -> bool:
	if level(level_id).is_empty():
		return false
	# Preserve revisiting even for a legacy/direct-entry completion without
	# earlier records. Unknown saved IDs never unlock registered routes.
	if completions.get(level_id, false):
		return true
	for entry in LEVELS:
		if entry.id == level_id:
			return true
		if not completions.get(entry.id, false):
			return false
	return false
