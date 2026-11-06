extends Area2D

@export var rotation_speed := 0.0
@export_range(0.0, 300.0, 1.0) var patrol_distance := 0.0
@export_range(0.0, 300.0, 1.0) var patrol_speed := 80.0
enum PatrolAxis { HORIZONTAL, VERTICAL }
@export var patrol_axis: PatrolAxis = PatrolAxis.HORIZONTAL
var patrol_origin := Vector2.ZERO
var patrol_time := 0.0

func _ready() -> void:
	patrol_origin = position
	body_entered.connect(_entered)

func _process(delta: float) -> void:
	$Visual.rotation += rotation_speed * delta

func _physics_process(delta: float) -> void:
	if patrol_distance > 0.0:
		patrol_time += delta
		var offset := sin(patrol_time * patrol_speed / patrol_distance) * patrol_distance
		position = patrol_origin + (Vector2.RIGHT if patrol_axis == PatrolAxis.HORIZONTAL else Vector2.DOWN) * offset
	# Remaining on a hazard can hurt again after the invulnerability interval.
	for body in get_overlapping_bodies():
		_entered(body)

func _entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var health = body.get_node_or_null("HealthComponent")
	if health != null:
		health.take_damage(global_position)
