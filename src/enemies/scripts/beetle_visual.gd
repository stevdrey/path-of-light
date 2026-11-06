extends Node2D

@onready var beetle: BeetleEnemy = get_parent()
@onready var sprite: AnimatedSprite2D = $Sprite2D

var alert_time := 0.0

func _process(delta: float) -> void:
	if beetle.state == BeetleEnemy.State.DEFEATED:
		return
	alert_time += delta
	var target_color := Color.WHITE
	if beetle.state == BeetleEnemy.State.WINDUP:
		var pulse := 0.7 + 0.3 * sin(alert_time * 16.0)
		target_color = Color(1.0 + 0.65 * pulse, 1.0 + 0.35 * pulse, 1.0, 1.0)
	elif beetle.state == BeetleEnemy.State.ATTACK:
		target_color = Color(1.65, 1.3, 1.0, 1.0)
	modulate = modulate.lerp(target_color, clampf(delta * 14.0, 0.0, 1.0))
	sprite.flip_h = beetle.facing < 0.0
	var animation: StringName
	match beetle.state:
		BeetleEnemy.State.PATROL:
			animation = &"walk" if absf(beetle.velocity.x) > 1.0 else &"idle"
		BeetleEnemy.State.WINDUP:
			animation = &"windup"
		BeetleEnemy.State.ATTACK:
			animation = &"attack"
		_:
			animation = &"idle"
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)
