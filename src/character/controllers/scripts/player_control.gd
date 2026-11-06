class_name PlayerControl
extends ControlStrategy

func horizontal() -> float:
	return Input.get_axis("move_left", "move_right")

func wants_jump() -> bool:
	return Input.is_action_just_pressed("jump")

func wants_crouch() -> bool:
	return Input.is_action_pressed("crouch")

func climb_axis() -> float:
	var up := Input.is_action_pressed("interact_up")
	var down := Input.is_action_pressed("crouch")
	return float(down) - float(up)
