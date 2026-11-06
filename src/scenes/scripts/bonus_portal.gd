extends Area2D

@export var destination := Vector2.ZERO
@export var enters_bonus := true
@export_range(4.0, 30.0, 1.0) var activation_tolerance := 12.0
var player_nearby := false
var proximity := 0.0
var phase := 0.0

func can_activate(body: CharacterBody2D) -> bool:
	return overlaps_body(body) and absf(body.global_position.x - global_position.x) <= activation_tolerance

func _ready() -> void:
	body_entered.connect(_update_prompt)
	body_exited.connect(_update_prompt)

func _update_prompt(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = overlaps_body(body)

func _process(delta: float) -> void:
	$Visual.rotation += delta * 0.7
	phase += delta
	proximity = move_toward(proximity, 1.0 if player_nearby else 0.0, delta * 3.0)
	var pulse := sin(phase * 3.0)
	var scale_factor := 1.0 + proximity * (0.08 + 0.035 * pulse)
	$Visual.scale = Vector2.ONE * scale_factor
	$Glow.scale = Vector2.ONE * (1.18 + proximity * (0.18 + 0.05 * pulse))
	$Glow.modulate.a = 0.10 + proximity * (0.22 + 0.06 * pulse)
