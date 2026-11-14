extends Control

const MENU_THEME: Theme = preload("res://src/ui/menu_theme.tres")
const SPLASH_ART: Texture2D = preload("res://assets/images/ui/splash_art.png")
const MENU_ART: Texture2D = preload("res://assets/images/ui/menu_background.png")
const Registry := preload("res://src/scenes/scripts/campaign_registry.gd")
const LEVEL_MAP := "res://src/ui/level_map.tscn"
const ASSIST_OPTIONS := preload("res://src/ui/scripts/assist_options.gd")
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
const ACTION_LABELS := {"move_left": "Mover a la izquierda", "move_right": "Mover a la derecha", "jump": "Saltar", "crouch": "Agacharse / bajar", "interact_up": "Subir / interactuar", "restart_demo": "Reiniciar nivel"}
var main_panel: VBoxContainer
var options_panel: VBoxContainer
var assists_panel: VBoxContainer
var assists_button: Button
var key_buttons := {}
var waiting_action := ""
var message: Label
var save_notice: Label
var map_button: Button

func _ready() -> void:
	Progress.ensure_campaign_loaded()
	Progress.retry_failed_save()
	BackgroundMusic.play_menu()
	theme = MENU_THEME
	_build_ui()
	if get_tree().root.has_meta("skip_intro_splash"):
		get_tree().root.remove_meta("skip_intro_splash")
		if get_tree().root.has_meta("focus_level_map"):
			get_tree().root.remove_meta("focus_level_map")
			map_button.grab_focus()
		else:
			main_panel.get_child(2).grab_focus()
	else:
		_show_splash()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := TextureRect.new()
	bg.texture = MENU_ART
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(470, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.16, 0.15, 0.92)
	style.border_color = Color("f1c66d")
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(24)
	frame.add_theme_stylebox_override("panel", style)
	center.add_child(frame)
	var holder := VBoxContainer.new()
	holder.add_theme_constant_override("separation", 12)
	frame.add_child(holder)
	main_panel = VBoxContainer.new()
	main_panel.add_theme_constant_override("separation", 10)
	holder.add_child(main_panel)
	var title := _label("EXPERIMENT\n2D PLATFORM", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_panel.add_child(title)
	var subtitle := _label("Una aventura por descubrir", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_panel.add_child(subtitle)
	_add_button(main_panel, "JUGAR", _play)
	_add_button(main_panel, "OPCIONES", _open_options)
	map_button = _add_button(main_panel, "MAPA DE NIVELES", _open_map)
	_add_button(main_panel, "SALIR", func(): get_tree().quit())
	save_notice = _label(Progress.campaign_notice(), 14)
	save_notice.custom_minimum_size.x = 380
	save_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_notice.visible = not save_notice.text.is_empty()
	main_panel.add_child(save_notice)
	options_panel = VBoxContainer.new()
	options_panel.add_theme_constant_override("separation", 5)
	holder.add_child(options_panel)
	options_panel.hide()
	var heading := _label("OPCIONES", 26)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	options_panel.add_child(heading)
	_add_slider("Música", "Music")
	_add_slider("Efectos", "SFX")
	assists_button = _add_button(options_panel, "AYUDAS", _open_assists)
	options_panel.add_child(_label("CONTROLES · TECLADO", 17))
	for action in GameSettings.ACTIONS:
		var row := HBoxContainer.new()
		options_panel.add_child(row)
		var label := _label(ACTION_LABELS[action], 15)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var button := Button.new()
		button.custom_minimum_size = Vector2(155, 30)
		_add_button_feedback(button)
		button.pressed.connect(_start_rebind.bind(action))
		row.add_child(button)
		key_buttons[action] = button
	message = _label("Selecciona una acción para cambiar su tecla.", 13)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	options_panel.add_child(message)
	_add_button(options_panel, "Restaurar controles", _restore)
	_add_button(options_panel, "Volver", _close_options)
	assists_panel = VBoxContainer.new()
	assists_panel.set_script(ASSIST_OPTIONS)
	holder.add_child(assists_panel)
	_add_button_feedback(assists_panel.back_button)
	assists_panel.closed.connect(_close_assists)
	assists_panel.hide()
	_refresh_keys()

func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f4e9cf"))
	return label

func _add_button(parent: Node, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 35
	_add_button_feedback(button)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

# The style handles hover/focus/pressed; the small scale change adds tactile feedback.
func _add_button_feedback(button: Button) -> void:
	button.button_down.connect(_animate_button.bind(button, Vector2(0.96, 0.96)))
	button.button_up.connect(_animate_button.bind(button, Vector2.ONE))
	button.focus_exited.connect(_animate_button.bind(button, Vector2.ONE))

func _animate_button(button: Button, target: Vector2) -> void:
	button.pivot_offset = button.size / 2.0
	if button.has_meta("feedback_tween"):
		var previous: Tween = button.get_meta("feedback_tween")
		if previous.is_valid():
			previous.kill()
	var tween := create_tween()
	button.set_meta("feedback_tween", tween)
	tween.tween_property(button, "scale", target, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _add_slider(caption: String, bus_name: String) -> void:
	var row := HBoxContainer.new()
	options_panel.add_child(row)
	var label := _label(caption, 16)
	label.custom_minimum_size.x = 100
	row.add_child(label)
	var slider := HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = GameSettings.get_volume(bus_name)
	row.add_child(slider)
	var percent := _label("%d%%" % roundi(slider.value * 100), 14)
	percent.custom_minimum_size.x = 45
	row.add_child(percent)
	slider.value_changed.connect(func(value: float):
		percent.text = "%d%%" % roundi(value * 100)
		GameSettings.set_volume(bus_name, value)
	)

func _show_splash() -> void:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var artwork := TextureRect.new()
	artwork.texture = SPLASH_ART
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(artwork)
	var splash := _label("EXPERIMENT  ·  2D PLATFORM", 26)
	splash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	splash.add_theme_color_override("font_outline_color", Color("17372e"))
	splash.add_theme_constant_override("outline_size", 7)
	splash.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	splash.anchor_left = 0.0
	splash.anchor_right = 1.0
	splash.offset_left = 0.0
	splash.offset_right = 0.0
	splash.offset_top = -65.0
	splash.offset_bottom = -20.0
	splash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(splash)
	await get_tree().create_timer(2.4).timeout
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.45)
	await tween.finished
	overlay.queue_free()
	main_panel.get_child(2).grab_focus()

func _play() -> void:
	# JUGAR starts a level-one attempt while preserving durable campaign facts.
	BackgroundMusic.play_game()
	get_tree().change_scene_to_file(Registry.level(1).scene_path)

func _open_map() -> void:
	var error := get_tree().change_scene_to_file(LEVEL_MAP)
	if error != OK:
		save_notice.text = "No se pudo abrir el mapa. Reintenta."
		save_notice.show()

func _open_options() -> void:
	main_panel.hide()
	options_panel.show()
	key_buttons["move_left"].grab_focus()

func _open_assists() -> void:
	waiting_action = ""
	options_panel.hide()
	assists_panel.open()

func _close_assists() -> void:
	assists_panel.hide()
	options_panel.show()
	assists_button.grab_focus()

func _close_options() -> void:
	waiting_action = ""
	options_panel.hide()
	main_panel.show()
	main_panel.get_child(3).grab_focus()

func _restore() -> void:
	waiting_action = ""
	GameSettings.restore_controls()
	message.text = "Controles originales restaurados."
	_refresh_keys()

func _start_rebind(action: String) -> void:
	waiting_action = action
	message.text = "Presiona una tecla para %s. Esc cancela." % ACTION_LABELS[action].to_lower()
	_refresh_keys()

func _input(event: InputEvent) -> void:
	if waiting_action.is_empty() or not event is InputEventKey or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	if event.keycode == KEY_ESCAPE:
		waiting_action = ""
		message.text = "Cambio cancelado."
		_refresh_keys()
		return
	var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if code == 0 or code in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
		message.text = "Elige una tecla sin modificadores."
		return
	for action in GameSettings.ACTIONS:
		if action == waiting_action:
			continue
		for existing in InputMap.action_get_events(action):
			if existing is InputEventKey and (existing.physical_keycode == code or existing.keycode == code):
				message.text = "Esa tecla ya se usa para %s." % ACTION_LABELS[action].to_lower()
				return
	GameSettings.bind_key(waiting_action, code)
	waiting_action = ""
	message.text = "Control actualizado."
	_refresh_keys()

func _refresh_keys() -> void:
	for action in GameSettings.ACTIONS:
		var names: PackedStringArray = []
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				names.append(event.as_text_physical_keycode())
		key_buttons[action].text = "..." if waiting_action == action else " / ".join(names)
