extends "res://src/scenes/scripts/first_level.gd"

func _ready() -> void:
	level_number = 2
	safe_checkpoints.assign([Vector2(960, 548), Vector2(2160, 548), Vector2(3440, 548), Vector2(4200, 548), Vector2(5900, 548), Vector2(8100, 548), Vector2(10800, 548), Vector2(12600, 548)])
	super._ready()
	$CanvasLayer/Instructions/Title.text = "Nivel 2 · Sendero de piedra"
	$CanvasLayer/Instructions/Help.text = "Esc: pausa  •  Cambia los controles en Opciones desde el menú inicial."
