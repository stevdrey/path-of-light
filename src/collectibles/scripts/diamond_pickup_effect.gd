extends Node2D

var glow_color := Color.WHITE

func _ready() -> void:
	z_index = 2
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.24, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 0.8),
		Color(glow_color.r, glow_color.g, glow_color.b, 0.6),
		Color(glow_color.r, glow_color.g, glow_color.b, 0.0)
	])
	var texture := GradientTexture2D.new()
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.gradient = gradient
	var halo := Sprite2D.new()
	halo.texture = texture
	halo.scale = Vector2(0.22, 0.22)
	var blend := CanvasItemMaterial.new()
	blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = blend
	add_child(halo)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(halo, "scale", Vector2(0.65, 0.65), 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(halo, "modulate:a", 0.0, 0.38)
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		var sparkle := Polygon2D.new()
		sparkle.polygon = PackedVector2Array([Vector2(0, -3), Vector2(2, 0), Vector2(0, 3), Vector2(-2, 0)])
		sparkle.color = glow_color.lerp(Color.WHITE, 0.5)
		add_child(sparkle)
		tween.tween_property(sparkle, "position", direction * 24.0, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(sparkle, "modulate:a", 0.0, 0.34)
	tween.chain().tween_callback(queue_free)
