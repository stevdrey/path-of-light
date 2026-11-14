extends CanvasLayer

const MENU_THEME: Theme = preload("res://src/ui/menu_theme.tres")
const MAIN_MENU := "res://src/ui/front_end.tscn"
const LEVEL_MAP := "res://src/ui/level_map.tscn"
const ASSIST_OPTIONS := preload("res://src/ui/scripts/assist_options.gd")

var overlay: Control
var resume_button: Button
var owns_pause := false
var menu_column: VBoxContainer
var assists_panel: VBoxContainer
var assists_button: Button
var map_button: Button
var map_return_requested := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build_menu()

func _build_menu() -> void:
	overlay = Control.new()
	overlay.name = "Overlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.theme = MENU_THEME
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.09, 0.08, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 360
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.16, 0.15, 0.96)
	style.border_color = Color("f1c66d")
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var column := VBoxContainer.new()
	menu_column = column
	column.add_theme_constant_override("separation", 12)
	var holder := VBoxContainer.new()
	panel.add_child(holder)
	holder.add_child(column)
	var title := Label.new()
	title.text = "PAUSA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	column.add_child(title)
	var hint := Label.new()
	hint.text = "Esc para reanudar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	column.add_child(hint)
	resume_button = _button(column, "REANUDAR", resume)
	assists_button = _button(column, "AYUDAS", _open_assists)
	map_button = _button(column, "MAPA · DEJAR ESTE INTENTO", _return_to_map)
	_button(column, "VOLVER AL INICIO", _return_to_menu)
	_button(column, "SALIR DEL JUEGO", _quit_game)
	assists_panel = VBoxContainer.new()
	assists_panel.set_script(ASSIST_OPTIONS)
	holder.add_child(assists_panel)
	assists_panel.closed.connect(_close_assists)
	assists_panel.hide()
	overlay.hide()

func _open_assists() -> void:
	menu_column.hide()
	assists_panel.open()

func _close_assists() -> void:
	assists_panel.hide()
	menu_column.show()
	assists_button.grab_focus()

func _button(parent: Control, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 42
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return
	if owns_pause and assists_panel.visible:
		_close_assists()
	elif owns_pause:
		resume()
	elif not get_tree().paused:
		pause()
	else:
		return
	get_viewport().set_input_as_handled()

func pause() -> void:
	if owns_pause or get_tree().paused:
		return
	owns_pause = true
	get_tree().paused = true
	assists_panel.hide()
	menu_column.show()
	overlay.show()
	resume_button.grab_focus()

func resume() -> void:
	if not owns_pause:
		return
	owns_pause = false
	overlay.hide()
	get_tree().paused = false

func _return_to_menu() -> void:
	resume()
	get_tree().root.set_meta("skip_intro_splash", true)
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().root.remove_meta("skip_intro_splash")
		push_error("No se pudo volver al menú: %s" % error)

func _quit_game() -> void:
	get_tree().quit()

func _return_to_map() -> void:
	# Keep the scene paused until a request is accepted; failure is retryable.
	if not owns_pause or map_return_requested:
		return
	map_return_requested = true
	map_button.disabled = true
	call_deferred("_finish_return_to_map")

func _request_map_scene() -> Error:
	return get_tree().change_scene_to_file(LEVEL_MAP)

func _finish_return_to_map() -> void:
	# Another menu action may already have detached this scene.
	if not is_inside_tree():
		return
	var tree := get_tree()
	var error := _request_map_scene()
	if error == OK:
		owns_pause = false
		tree.paused = false
	else:
		map_return_requested = false
		map_button.disabled = false
		map_button.text = "No se pudo abrir el mapa · Reintentar"
		map_button.grab_focus()

func _exit_tree() -> void:
	if owns_pause:
		get_tree().paused = false
		owns_pause = false
