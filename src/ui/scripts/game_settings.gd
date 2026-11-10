extends Node

signal assists_changed

const FILE := "user://settings.cfg"
const ACTIONS := ["move_left", "move_right", "jump", "crouch", "interact_up", "restart_demo"]
const ASSISTS := ["extra_hearts", "frequent_checkpoints", "no_fall_damage"]
var defaults := {}
var assists := {"extra_hearts": false, "frequent_checkpoints": false, "no_fall_damage": false}

func _ready() -> void:
	# Keep independent copies so restoring defaults also restores alternate keys.
	for action in ACTIONS:
		defaults[action] = InputMap.action_get_events(action).duplicate(true)
	var config := ConfigFile.new()
	if config.load(FILE) != OK:
		return
	load_assists(config)
	for bus_name in ["Music", "SFX"]:
		set_volume(bus_name, clampf(float(config.get_value("audio", bus_name, get_volume(bus_name))), 0.0, 1.0), false)
	for action in ACTIONS:
		var code := int(config.get_value("controls", action, 0))
		if code > 0:
			bind_key(action, code, false)

func load_assists(config: ConfigFile) -> void:
	for key in ASSISTS:
		var value: Variant = config.get_value("assists", key, false)
		# Old files and malformed entries keep the standard recovery rules.
		assists[key] = value if value is bool else false
	assists_changed.emit()

func is_assist_enabled(key: String) -> bool:
	return assists.get(key, false)

func get_max_hearts() -> int:
	return 5 if is_assist_enabled("extra_hearts") else 3

func set_assist(key: String, enabled: bool) -> void:
	if not key in ASSISTS or assists[key] == enabled:
		return
	assists[key] = enabled
	assists_changed.emit()
	save_settings()

func get_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	return 0.0 if AudioServer.is_bus_mute(index) else db_to_linear(AudioServer.get_bus_volume_db(index))

func set_volume(bus_name: String, value: float, persist := true) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.001)))
	if persist:
		save_settings()

func bind_key(action: String, code: int, persist := true) -> void:
	InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.physical_keycode = code
	InputMap.action_add_event(action, event)
	if persist:
		save_settings()

func restore_controls() -> void:
	for action in ACTIONS:
		InputMap.action_erase_events(action)
		for event in defaults[action]:
			InputMap.action_add_event(action, event)
	save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	for key in ASSISTS:
		config.set_value("assists", key, assists[key])
	for bus_name in ["Music", "SFX"]:
		config.set_value("audio", bus_name, get_volume(bus_name))
	for action in ACTIONS:
		var events := InputMap.action_get_events(action)
		# Missing value means the original set of alternate keys is in use.
		if events.size() == 1 and events[0] is InputEventKey:
			config.set_value("controls", action, events[0].physical_keycode)
	var error := config.save(FILE)
	if error != OK:
		push_warning("No se pudieron guardar las opciones: %s" % error)
