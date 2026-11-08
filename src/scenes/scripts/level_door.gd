@tool
extends Area2D

const DISCOVERY_GLOW := preload("res://src/scenes/ressources/discovery_glow.tres")

enum DoorColor { BLUE, YELLOW, GREEN, ORANGE }
@export var door_color: DoorColor = DoorColor.BLUE:
	set(value):
		door_color = value
		_update_appearance()
var required_key: int:
	get:
		return CollectibleItem.Kind.BLUE_KEY + int(door_color)
@export_file("*.tscn") var next_level := ""
var player_nearby := false
var cue_enabled := true
var cue_strength := 0.0
var cue_phase := 0.0
var cue_glow: Sprite2D

func _ready() -> void:
	_update_appearance()
	if not Engine.is_editor_hint():
		_create_cue()
		body_entered.connect(_on_entered)
		body_exited.connect(_on_exited)

func _create_cue() -> void:
	cue_glow = Sprite2D.new()
	cue_glow.name = "DiscoveryGlow"
	cue_glow.texture = DISCOVERY_GLOW
	cue_glow.position = Vector2(0, -64)
	cue_glow.scale = Vector2(0.75, 1.0)
	cue_glow.modulate = Color(1.0, 0.82, 0.38, 0.35)
	add_child(cue_glow)
	move_child(cue_glow, 0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or cue_glow == null:
		return
	cue_glow.visible = cue_enabled
	if not cue_enabled:
		return
	cue_phase += delta
	cue_strength = move_toward(cue_strength, 1.0 if player_nearby else 0.0, delta * 2.0)
	var pulse := 0.5 + 0.5 * sin(cue_phase * 2.0)
	cue_glow.modulate.a = 0.35 + cue_strength * (0.25 + 0.12 * pulse)
	cue_glow.scale = Vector2(0.75, 1.0) + Vector2(0.05, 0.06) * cue_strength * pulse

func _update_appearance() -> void:
	var sprite := get_node_or_null("Visual") as Sprite2D
	if sprite:
		sprite.region_rect = Rect2(384 + int(door_color) * 64, 320, 64, 128)

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
