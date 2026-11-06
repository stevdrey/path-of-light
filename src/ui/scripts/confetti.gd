extends Node2D

@export_range(0.5, 15.0, 0.5) var celebration_duration := 4.5
const COLORS := [Color("f8c94d"), Color("58c9ef"), Color("77df9c"), Color("fb8765")]
var emitters: Array[CPUParticles2D] = []

func _ready() -> void:
	var texture := GradientTexture2D.new()
	texture.width = 8
	texture.height = 5
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color.WHITE)
	texture.gradient = gradient
	for confetti_color in COLORS:
		var emitter := CPUParticles2D.new()
		emitter.name = "Confetti%d" % emitters.size()
		emitter.texture = texture
		emitter.amount = 25
		emitter.lifetime = 4.0
		emitter.explosiveness = 0.0
		emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		emitter.direction = Vector2.DOWN
		emitter.spread = 28.0
		emitter.gravity = Vector2(0, 80)
		emitter.initial_velocity_min = 45.0
		emitter.initial_velocity_max = 90.0
		emitter.angular_velocity_min = -180.0
		emitter.angular_velocity_max = 180.0
		emitter.scale_amount_min = 0.65
		emitter.scale_amount_max = 1.2
		emitter.color = confetti_color
		emitter.local_coords = false
		add_child(emitter)
		emitters.append(emitter)
	_sync_viewport()
	get_viewport().size_changed.connect(_sync_viewport)
	await get_tree().create_timer(celebration_duration).timeout
	for emitter in emitters:
		if is_instance_valid(emitter):
			emitter.emitting = false

func _sync_viewport() -> void:
	var width := get_viewport_rect().size.x
	for emitter in emitters:
		emitter.position = Vector2(width / 2.0, -10)
		emitter.emission_rect_extents = Vector2(width / 2.0, 1)
