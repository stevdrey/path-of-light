extends Control

const Rewards := preload("res://src/scenes/scripts/campaign_rewards.gd")
const Registry := preload("res://src/scenes/scripts/campaign_registry.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const MAIN_MENU := "res://src/ui/front_end.tscn"

var level_buttons: Dictionary = {}
var route_labels: Array[Label] = []
var back_button: Button
var notice: Label
var frame: PanelContainer
var transitioning := false
var routes_column: VBoxContainer
var records_column: VBoxContainer
var records_button: Button
var records_notice: Label

func _ready() -> void:
	Progress.ensure_campaign_loaded()
	Progress.retry_failed_save()
	get_node("/root/BackgroundMusic").play_menu()
	theme = preload("res://src/ui/menu_theme.tres")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := ColorRect.new()
	background.color = Color("102e30")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	frame = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("123f3d")
	style.border_color = Color("f1c66d")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	frame.add_theme_stylebox_override("panel", style)
	center.add_child(frame)
	var column := VBoxContainer.new()
	routes_column = column
	column.add_theme_constant_override("separation", 12)
	frame.add_child(column)
	_add_label(column, "MAPA DE NIVELES", 28)
	var hint := _add_label(column, "Cada visita comienza con corazones completos y sin objetos.", 16)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var entries := Registry.levels()
	for index in entries.size():
		var entry: Dictionary = entries[index]
		var button := Button.new()
		button.custom_minimum_size.y = 72
		button.add_theme_font_size_override("font_size", 19)
		button.pressed.connect(select_level.bind(entry.id))
		column.add_child(button)
		level_buttons[entry.id] = button
		if index < entries.size() - 1:
			route_labels.append(_add_label(column, "", 16))
	notice = _add_label(column, "", 14)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	records_button = Button.new()
	records_button.text = "DESCUBRIMIENTOS Y RECOMPENSAS"
	records_button.custom_minimum_size.y = 40
	records_button.pressed.connect(_open_records)
	column.add_child(records_button)
	_build_records()
	back_button = Button.new()
	back_button.text = "VOLVER AL INICIO"
	back_button.custom_minimum_size.y = 40
	back_button.pressed.connect(_return_to_menu)
	column.add_child(back_button)
	resized.connect(_fit_width)
	_fit_width()
	refresh()
	for entry in entries:
		if Registry.is_open(entry.id, Progress.completed_levels) and not Progress.completed_levels.get(entry.id, false):
			level_buttons[entry.id].grab_focus()
			return
	level_buttons[entries[0].id].grab_focus()

func _add_label(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f4e9cf"))
	parent.add_child(label)
	return label

func _fit_width() -> void:
	frame.custom_minimum_size.x = minf(600, maxf(0, size.x - 32))

func refresh() -> void:
	var entries := Registry.LEVELS
	for index in entries.size():
		var entry: Dictionary = entries[index]
		var open := Registry.is_open(entry.id, Progress.completed_levels)
		var done: bool = Progress.completed_levels.get(entry.id, false)
		var state := "✓ Completado · Volver a jugar" if done else ("▶ Abierto" if open else "× Bloqueado")
		var button: Button = level_buttons[entry.id]
		button.text = "%d · %s\n%s" % [entry.id, entry.title, state]
		button.disabled = transitioning or not open
		if index > 0:
			route_labels[index - 1].text = "↓ Ruta abierta" if open else "⋮ Completa el nivel anterior"
	notice.text = Progress.campaign_notice()
	notice.visible = not notice.text.is_empty()
	records_notice.text = notice.text
	records_notice.visible = notice.visible
	back_button.disabled = transitioning
	records_button.disabled = transitioning

func _build_records() -> void:
	records_column = VBoxContainer.new()
	records_column.add_theme_constant_override("separation", 12)
	frame.add_child(records_column)
	_add_label(records_column, "DESCUBRIMIENTOS", 24)
	for discovery in Rewards.DISCOVERIES:
		var found := Progress.recorded_discoveries.has(discovery.id)
		_add_label(records_column, "%s %s\n%s" % ["✓" if found else "?", discovery.title if found else "Por descubrir", discovery.category], 18)
	_add_label(records_column, "RECOMPENSAS", 24)
	# Only authored metadata may supply a display title; unknown retained IDs
	# never create content, routes, or selectable characters.
	for world in Rewards.WORLDS:
		_add_label(records_column, "✓ " + world.title if Progress.world_rewards.has(world.id) else "× Recompensa bloqueada", 18)
	if Rewards.WORLDS.is_empty():
		_add_label(records_column, "Recompensas de mundo: aún no disponibles.", 16)
	if Progress.character_unlocks.has("prototype"):
		_add_label(records_column, "✓ Personaje prototipo: desbloqueado.\nLa selección de personaje aún no está disponible.", 16)
	else:
		_add_label(records_column, "Personaje prototipo: bloqueado.\nRequiere una campaña con final propio.", 16)
	records_notice = _add_label(records_column, "", 14)
	records_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var back := Button.new()
	back.text = "VOLVER AL MAPA"
	back.custom_minimum_size.y = 40
	back.pressed.connect(_close_records)
	records_column.add_child(back)
	records_column.hide()

func _open_records() -> void:
	if transitioning:
		return
	routes_column.hide()
	records_column.show()
	records_column.get_child(-1).grab_focus()

func _close_records() -> void:
	records_column.hide()
	routes_column.show()
	records_button.grab_focus()

func select_level(level_id: int) -> void:
	if transitioning or not Registry.is_open(level_id, Progress.completed_levels):
		return
	transitioning = true
	refresh()
	# Button/input callbacks must finish before their scene is removed.
	call_deferred("_finish_selection", level_id)

func _request_level_scene(path: String) -> Error:
	return get_tree().change_scene_to_file(path)

func _finish_selection(level_id: int) -> void:
	var music: Node = get_node("/root/BackgroundMusic")
	var error := _request_level_scene(Registry.level(level_id).scene_path)
	if error == OK:
		# Replacement _ready() runs later and consumes the request. Mark it only
		# after acceptance, so a failed request leaves the live inventory untouched.
		Progress.request_fresh_attempt()
		music.play_game()
		return
	transitioning = false
	refresh()
	notice.text = "No se pudo abrir el nivel. Reintenta o vuelve al inicio."
	notice.show()
	level_buttons[level_id].grab_focus()

func _return_to_menu() -> void:
	if transitioning:
		return
	transitioning = true
	refresh()
	call_deferred("_finish_return")

func _finish_return() -> void:
	get_tree().root.set_meta("skip_intro_splash", true)
	get_tree().root.set_meta("focus_level_map", true)
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().root.remove_meta("skip_intro_splash")
		get_tree().root.remove_meta("focus_level_map")
		transitioning = false
		refresh()
		notice.text = "No se pudo volver al inicio. Reintenta."
		notice.show()
		back_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if records_column.visible:
			_close_records()
		else:
			_return_to_menu()
