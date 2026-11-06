@tool
class_name CollectibleItem
extends Area2D

signal collected(item_kind: int, points: int)

const PICKUP_EFFECT := preload("res://src/collectibles/scripts/diamond_pickup_effect.gd")
const DIAMOND_COLORS := [Color("48b8ff"), Color("ffcf35"), Color("42e78a"), Color("ff9c3e")]

enum Kind { BLUE_DIAMOND, YELLOW_DIAMOND, GREEN_DIAMOND, ORANGE_DIAMOND, BLUE_KEY, YELLOW_KEY, GREEN_KEY, ORANGE_KEY, HEART }
@export var kind: Kind = Kind.BLUE_DIAMOND:
	set(value):
		kind = value
		if value >= Kind.BLUE_DIAMOND and value <= Kind.ORANGE_DIAMOND:
			points = [1, 3, 5, 10][value]
		_update_appearance()
@export_range(0, 1000, 1) var points := 1
@export var float_animation := true
@export_range(0.0, 16.0, 0.5) var float_distance := 4.0
@export_range(0.0, 10.0, 0.1) var float_speed := 3.0
@export var collector_group := &"player"
var taken := false
var elapsed := 0.0

func _ready() -> void:
	_update_appearance()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	elapsed += delta
	$Visual.position.y = sin(elapsed * float_speed) * float_distance if float_animation else 0.0

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint() and kind == Kind.HEART and not taken:
		for body in get_overlapping_bodies():
			_on_body_entered(body)

func _update_appearance() -> void:
	var sprite := get_node_or_null("Visual") as Sprite2D
	if sprite == null:
		return
	var coordinates: Array[Vector2i] = [Vector2i(7,2),Vector2i(8,2),Vector2i(9,2),Vector2i(10,2),Vector2i(7,4),Vector2i(8,4),Vector2i(9,4),Vector2i(10,4),Vector2i(11,4)]
	var cell := coordinates[clampi(int(kind), 0, coordinates.size() - 1)]
	# Keep transparent padding around the item without sampling adjacent tiles.
	var inset := Rect2(16, 16, 32, 32)
	if kind >= Kind.BLUE_KEY and kind <= Kind.ORANGE_KEY:
		inset = Rect2(8, 16, 48, 32)
	sprite.region_rect = Rect2(Vector2(cell * 64) + inset.position, inset.size)
	sprite.region_filter_clip_enabled = true

func _on_body_entered(body: Node2D) -> void:
	if taken or not body.is_in_group(collector_group):
		return
	if kind == Kind.HEART:
		var health = body.get_node_or_null("HealthComponent")
		if health == null or health.dead or health.hearts >= health.max_hearts:
			return
	taken = true
	if kind >= Kind.BLUE_DIAMOND and kind <= Kind.ORANGE_DIAMOND:
		var effect := PICKUP_EFFECT.new()
		effect.glow_color = DIAMOND_COLORS[int(kind)]
		get_parent().add_child(effect)
		effect.global_position = $Visual.global_position
	collected.emit(kind, points)
	queue_free()
