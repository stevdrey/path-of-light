class_name CharacterAnimationStateMachine
extends Node

# Transitions depend on the actual physics result, independent of the controller.
enum State { IDLE, WALK, JUMP, FALL, CROUCH, VICTORY, CLIMB }
@onready var body: CharacterBody2D = get_parent()
@onready var movement: MovementComponent = get_node("../MovementComponent")
@onready var sprite: AnimatedSprite2D = get_node("../AnimatedSprite2D")
var state: State = State.IDLE
var victory := false

func _physics_process(_delta: float) -> void:
	var next_state: State
	if victory:
		next_state = State.VICTORY
	elif movement.climbing:
		next_state = State.CLIMB
	elif not body.is_on_floor():
		next_state = State.JUMP if body.velocity.y < 0.0 else State.FALL
	elif movement.is_crouching:
		next_state = State.CROUCH
	elif absf(body.velocity.x) > 5.0:
		next_state = State.WALK
	else:
		next_state = State.IDLE
	if next_state != state or not sprite.is_playing():
		state = next_state
		match state:
			State.IDLE: sprite.play("idle")
			State.WALK: sprite.play("walk")
			State.JUMP: sprite.play("jump")
			State.FALL: sprite.play("fall")
			State.CROUCH: sprite.play("crouch")
			State.VICTORY: sprite.play("victory")
			State.CLIMB: sprite.play("climb")
	sprite.speed_scale = 0.0 if state == State.CLIMB and absf(body.velocity.y) < 1.0 else 1.0
	if state == State.CLIMB:
		sprite.flip_h = false
	elif absf(body.velocity.x) > 5.0:
		sprite.flip_h = body.velocity.x < 0.0
