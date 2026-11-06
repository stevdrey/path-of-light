@tool
extends Area2D

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

func _ready() -> void:
	_update_appearance()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_entered)
		body_exited.connect(_on_exited)

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
