class_name MovementComponent
extends Node

signal control_changed(label: String)

@export var speed := 250.0
@export var acceleration := 1800.0
@export var friction := 2200.0
@export var jump_velocity := -530.0
@export var gravity := 1400.0
@export var climb_speed := 150.0
@export_range(0.0, 24.0, 1.0) var ladder_center_tolerance := 12.0
@export var coyote_time := 0.10
@export var jump_buffer_time := 0.12
@export_range(0, 32, 1) var corner_correction_pixels := 20
@onready var body: CharacterBody2D = get_parent()
@onready var player_control: PlayerControl = $PlayerControl
@onready var scripted_control: ScriptedControl = $ScriptedControl
var control: ControlStrategy
var coyote_left := 0.0
var jump_buffer_left := 0.0
var is_crouching := false
var input_locked := false
var damage_locked := false
var jump_sound: AudioStreamPlayer
var suppress_jump_once := false
var independent_jump_pressed := false
var ladder_contacts := 0
var nearby_ladders: Array[Area2D] = []
var climbing := false

func _ready() -> void:
	jump_sound = AudioStreamPlayer.new()
	jump_sound.bus = &"SFX"
	jump_sound.stream = preload("res://assets/sounds/sfx/jump.wav")
	jump_sound.volume_db = -12.0
	add_child(jump_sound)
	scripted_control.finished.connect(use_player_control)
	use_scripted_control()

func set_control(strategy: ControlStrategy) -> void:
	if control != null:
		control.deactivate()
	control = strategy
	jump_buffer_left = 0.0
	independent_jump_pressed = false
	control.activate()
	control_changed.emit("Automático" if strategy == scripted_control else "Jugador")

func use_player_control() -> void:
	set_control(player_control)

func use_scripted_control() -> void:
	set_control(scripted_control)

func _input(event: InputEvent) -> void:
	if not event.is_echo() and event.is_action_pressed("jump") and not event.is_action_pressed("interact_up"):
		independent_jump_pressed = true

func _physics_process(delta: float) -> void:
	if control == null:
		return
	var locked := input_locked or damage_locked
	var climb_input := control.climb_axis() if not locked else 0.0
	if ladder_contacts <= 0 or locked or (climbing and not _is_centered_on_ladder()):
		climbing = false
	elif not climbing and absf(climb_input) > 0.01 and _is_centered_on_ladder():
		climbing = true
	body.set_collision_mask_value(2, not climbing)
	if climbing:
		is_crouching = false
		jump_buffer_left = 0.0
		suppress_jump_once = false
		independent_jump_pressed = false
		body.velocity = Vector2(control.horizontal() * speed, climb_input * climb_speed)
		body.move_and_slide()
		var ladder := _centered_ladder()
		if climb_input < 0.0 and ladder != null and ladder.has_method("get_top_y"):
			var top_y: float = ladder.get_top_y()
			if body.global_position.y <= top_y:
				body.global_position.y = top_y
				body.velocity.y = 0.0
				climbing = false
				body.set_collision_mask_value(2, true)
		return
	is_crouching = not locked and body.is_on_floor() and control.wants_crouch()
	var direction := 0.0 if is_crouching or locked else control.horizontal()
	var rate := acceleration if absf(direction) > 0.01 else friction
	body.velocity.x = move_toward(body.velocity.x, direction * speed, rate * delta)
	if body.is_on_floor():
		coyote_left = coyote_time
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
		body.velocity.y += gravity * delta
	jump_buffer_left = 0.0 if is_crouching else maxf(0.0, jump_buffer_left - delta)
	var wants_jump := (control.wants_jump() and not suppress_jump_once) or (control == player_control and independent_jump_pressed)
	if not is_crouching and not locked and wants_jump:
		jump_buffer_left = jump_buffer_time
	suppress_jump_once = false
	independent_jump_pressed = false
	if locked:
		jump_buffer_left = 0.0
	if jump_buffer_left > 0.0 and coyote_left > 0.0:
		body.velocity.y = jump_velocity
		jump_sound.play()
		coyote_left = 0.0
		jump_buffer_left = 0.0
	_correct_jump_corner(delta)
	var rising := body.velocity.y < 0.0
	body.move_and_slide()
	if rising:
		for i in range(body.get_slide_collision_count()):
			var collision := body.get_slide_collision(i)
			var target := collision.get_collider()
			if collision.get_normal().y > 0.7 and target != null and target.has_method("hit_from_below"):
				target.hit_from_below(body)

# Before an upward ceiling hit, look for a nearby unobstructed escape path.
func _correct_jump_corner(delta: float) -> void:
	if body.velocity.y >= 0.0 or corner_correction_pixels <= 0:
		return
	var upward_motion := Vector2(0.0, body.velocity.y * delta)
	var collision := KinematicCollision2D.new()
	if not body.test_move(body.global_transform, upward_motion, collision):
		return
	if collision.get_normal().y < 0.7:
		return
	var preferred := -1 if body.velocity.x < 0.0 else 1
	for distance in range(1, corner_correction_pixels + 1):
		for side in [preferred, -preferred]:
			var offset := Vector2(side * distance, 0.0)
			if body.test_move(body.global_transform, offset):
				continue
			var shifted := body.global_transform.translated(offset)
			var jump_motion := Vector2(body.velocity.x * delta, upward_motion.y)
			if not body.test_move(shifted, jump_motion):
				body.global_position += offset
				return

func register_ladder(ladder: Area2D) -> void:
	if not nearby_ladders.has(ladder):
		nearby_ladders.append(ladder)
	ladder_contacts = nearby_ladders.size()

func unregister_ladder(ladder: Area2D) -> void:
	nearby_ladders.erase(ladder)
	ladder_contacts = nearby_ladders.size()

func _centered_ladder() -> Area2D:
	for ladder in nearby_ladders:
		if is_instance_valid(ladder) and absf(body.global_position.x - ladder.global_position.x) <= ladder_center_tolerance:
			return ladder
	return null

func _is_centered_on_ladder() -> bool:
	return _centered_ladder() != null
