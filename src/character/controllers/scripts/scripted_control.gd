class_name ScriptedControl
extends ControlStrategy

signal finished

@export var duration := 1.2
@export_range(-1.0, 1.0) var direction := 1.0
var elapsed := 0.0
var running := false

func activate() -> void:
	elapsed = 0.0
	running = true

func deactivate() -> void:
	running = false

func _physics_process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	if elapsed >= duration:
		running = false
		finished.emit()

func horizontal() -> float:
	return direction if running else 0.0
