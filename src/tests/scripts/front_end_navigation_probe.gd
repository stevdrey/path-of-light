extends "res://src/ui/scripts/front_end.gd"
## Runtime-loaded fixture: count real scene requests and inject checked errors.

var requests: Array[String] = []
var failures_left := 0

func _request_menu_scene(path: String) -> Error:
	requests.append(path)
	if failures_left > 0:
		failures_left -= 1
		return ERR_CANT_CREATE
	return super._request_menu_scene(path)
