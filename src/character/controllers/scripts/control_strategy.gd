class_name ControlStrategy
extends Node

# Strategies provide intent; the movement component owns physics.
func horizontal() -> float:
	return 0.0

func wants_jump() -> bool:
	return false

func climb_axis() -> float:
	return 0.0

func wants_crouch() -> bool:
	return false

func activate() -> void:
	pass

func deactivate() -> void:
	pass
