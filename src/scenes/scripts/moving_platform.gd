extends AnimatableBody2D

enum TravelAxis { HORIZONTAL, VERTICAL }
@export var travel_axis: TravelAxis = TravelAxis.HORIZONTAL
@export_range(0.0, 500.0, 1.0) var travel_distance := 64.0
@export_range(0.0, 300.0, 1.0) var travel_speed := 60.0
var origin := Vector2.ZERO
var elapsed := 0.0

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	if travel_distance <= 0.0:
		return
	elapsed += delta
	var offset := sin(elapsed * travel_speed / travel_distance) * travel_distance
	position = origin + (Vector2.RIGHT if travel_axis == TravelAxis.HORIZONTAL else Vector2.DOWN) * offset
