@tool
extends Area2D

@export_range(1, 10, 1) var segments := 4:
	set(value):
		segments = value
		if is_node_ready():
			_rebuild()
const TEXTURE := preload("res://assets/images/platformPack_tilesheet.png")
var _instance_shape: RectangleShape2D

func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_entered)
		body_exited.connect(_exited)

func _rebuild() -> void:
	if not has_node("Visuals") or not has_node("CollisionShape2D"):
		return
	var holder := $Visuals
	for child in holder.get_children():
		holder.remove_child(child)
		child.queue_free()
	for i in range(segments):
		var sprite := Sprite2D.new()
		var top_inset := 14 if i == segments - 1 else 0
		sprite.name = "Section%d" % i
		sprite.texture = TEXTURE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.centered = false
		sprite.region_enabled = true
		sprite.region_rect = Rect2(64, 256 + top_inset, 64, 64 - top_inset)
		sprite.position = Vector2(-32, -64 * (i + 1) + top_inset)
		# One pixel of overlap prevents sampling seams between repeated pieces.
		sprite.scale.y = float(65 - top_inset) / float(64 - top_inset)
		holder.add_child(sprite)
	var cap := Sprite2D.new()
	cap.name = "TopCap"
	cap.texture = TEXTURE
	cap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cap.centered = false
	cap.region_enabled = true
	cap.region_rect = Rect2(0, 256, 64, 32)
	cap.position = Vector2(-32, -segments * 64 - 14)
	holder.add_child(cap)
	var col := $CollisionShape2D as CollisionShape2D
	# In the editor, scene instances can otherwise share and overwrite one shape.
	if _instance_shape == null:
		_instance_shape = (col.shape as RectangleShape2D).duplicate() as RectangleShape2D
		col.shape = _instance_shape
	var interaction_height := segments * 64 + 14
	_instance_shape.size = Vector2(46, interaction_height)
	col.position = Vector2(0, -interaction_height / 2.0)

func _entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var movement := body.get_node_or_null("MovementComponent") as MovementComponent
		if movement:
			movement.register_ladder(self)

func _exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var movement := body.get_node_or_null("MovementComponent") as MovementComponent
		if movement:
			movement.unregister_ladder(self)

func get_top_y() -> float:
	return to_global(Vector2(0, -segments * 64)).y
