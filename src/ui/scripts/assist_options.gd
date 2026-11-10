extends VBoxContainer

# Emitted by Volver or ui_cancel; the host restores its own menu and focus.
signal closed

const LABELS := {
	"extra_hearts": "Más corazones (5 en vez de 3)",
	"frequent_checkpoints": "Puntos seguros más frecuentes",
	"no_fall_damage": "Caídas sin perder corazones",
}
var toggles: Dictionary = {}
var back_button: Button
@onready var settings: Node = get_node("/root/GameSettings")

func _ready() -> void:
	add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = "AYUDAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	add_child(title)
	var hint := Label.new()
	hint.text = "Cambia las ayudas en cualquier momento.\nMismo contenido y recompensas."
	hint.add_theme_font_size_override("font_size", 16)
	add_child(hint)
	for key in settings.ASSISTS:
		var toggle := CheckButton.new()
		toggle.name = key
		toggle.text = LABELS[key]
		toggle.custom_minimum_size.y = 42
		toggle.add_theme_font_size_override("font_size", 17)
		toggle.toggled.connect(func(enabled: bool): settings.set_assist(key, enabled))
		toggles[key] = toggle
		add_child(toggle)
	var recovery := Label.new()
	recovery.text = "Sin corazones, reinicias el nivel.\nLas ayudas se guardan en este dispositivo."
	recovery.add_theme_font_size_override("font_size", 15)
	add_child(recovery)
	back_button = Button.new()
	back_button.text = "Volver"
	back_button.custom_minimum_size.y = 42
	back_button.pressed.connect(closed.emit)
	add_child(back_button)
	settings.assists_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	for key in toggles:
		toggles[key].set_pressed_no_signal(settings.is_assist_enabled(key))

func open() -> void:
	show()
	focus_first()

# Children receive unhandled input before their host, so Esc goes back one
# step instead of resuming gameplay or closing the host menu.
func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		closed.emit()

func focus_first() -> void:
	toggles[settings.ASSISTS[0]].grab_focus()
