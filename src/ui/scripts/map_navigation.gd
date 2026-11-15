extends RefCounted
## Shared level-map navigation used by the menu, pause and completion screens.

const SCENE := "res://src/ui/level_map.tscn"
const RETRY_TEXT := "No se pudo abrir el mapa · Reintentar"

static func open(tree: SceneTree) -> Error:
	return tree.change_scene_to_file(SCENE)

static func show_retry(button: Button) -> void:
	button.disabled = false
	button.text = RETRY_TEXT
	button.grab_focus()
