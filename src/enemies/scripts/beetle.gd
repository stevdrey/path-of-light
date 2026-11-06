class_name BeetleEnemy
extends CharacterBody2D

signal defeated

const SOUND_EFFECTS := preload("res://src/audio/scripts/sound_effects.gd")
const DEFEAT_SOUND := preload("res://assets/sounds/sfx/beetle_defeat_sfx_engine.wav")

enum State { PATROL, WINDUP, ATTACK, RECOVER, DEFEATED }
@export var patrol_distance := 135.0
@export var patrol_speed := 65.0
@export var detection_range := 200.0
@export var detection_height := 70.0
@export var windup_duration := 0.45
@export var attack_speed := 250.0
@export var attack_duration := 0.55
@export var recovery_duration := 1.0
@export var bounce_velocity := -410.0
@export var gravity := 1400.0
@onready var visual: Node2D = $Visual
@onready var contact: Area2D = $Contact
@onready var contact_shape: CollisionShape2D = $Contact/CollisionShape2D
var state: State = State.PATROL
var origin_x := 0.0
var facing := 1.0
var timer := 0.0
var target: CharacterBody2D
var restoring_player := false
var wing_sound: AudioStreamPlayer

func _ready() -> void:
	origin_x = global_position.x
	wing_sound = AudioStreamPlayer.new()
	wing_sound.bus = &"SFX"
	wing_sound.stream = preload("res://assets/sounds/sfx/wings_attack.wav")
	wing_sound.volume_db = 0.0
	add_child(wing_sound)
	contact.body_entered.connect(_on_contact)

func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		return
	for body in contact.get_overlapping_bodies():
		_on_contact(body)
	if state == State.DEFEATED:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as CharacterBody2D
	timer = maxf(0.0, timer - delta)
	match state:
		State.PATROL:
			if global_position.x >= origin_x + patrol_distance:
				facing = -1.0
			elif global_position.x <= origin_x - patrol_distance:
				facing = 1.0
			velocity.x = facing * patrol_speed
			if _target_in_range():
				facing = -1.0 if target.global_position.x < global_position.x else 1.0
				state = State.WINDUP
				timer = windup_duration
		State.WINDUP:
			velocity.x = 0.0
			if timer <= 0.0:
				state = State.ATTACK
				timer = attack_duration
				wing_sound.play()
		State.ATTACK:
			velocity.x = facing * attack_speed
			if timer <= 0.0 or (global_position.x <= origin_x - patrol_distance and facing < 0.0) or (global_position.x >= origin_x + patrol_distance and facing > 0.0):
				state = State.RECOVER
				timer = recovery_duration
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
			if timer <= 0.0:
				state = State.PATROL
	move_and_slide()

func _target_in_range() -> bool:
	if restoring_player or target == null or not is_instance_valid(target):
		return false
	var offset := target.global_position - global_position
	return absf(offset.x) <= detection_range and absf(offset.y) <= detection_height

func _on_contact(body: Node2D) -> void:
	if state == State.DEFEATED or restoring_player or not body.is_in_group("player"):
		return
	var player := body as CharacterBody2D
	if player == null:
		return
	var health = player.get_node_or_null("HealthComponent")
	if health != null and health.dead:
		return
	# Both origins are at the feet. A falling player whose feet reach the top
	# of the beetle is a stomp; all other contact is damaging.
	var shape := contact_shape.shape as RectangleShape2D
	var enemy_top := contact_shape.to_global(Vector2(0, -shape.size.y * 0.5)).y
	if player.velocity.y > 0.0 and player.global_position.y <= enemy_top + 10.0:
		_defeat(player)
	elif health == null or health.invulnerability_left <= 0.0:
		_damage_player(player)

func _defeat(player: CharacterBody2D) -> void:
	state = State.DEFEATED
	wing_sound.stop()
	SOUND_EFFECTS.play_one_shot(get_tree(), DEFEAT_SOUND)
	velocity = Vector2.ZERO
	contact.set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 0
	var movement := player.get_node_or_null("MovementComponent") as MovementComponent
	if movement:
		movement.climbing = false
		movement.ladder_contacts = 0
		movement.nearby_ladders.clear()
		movement.jump_buffer_left = 0.0
		movement.coyote_left = 0.0
		player.set_collision_mask_value(2, true)
	player.velocity.y = bounce_velocity
	defeated.emit()
	visual.modulate = Color.WHITE
	var sprite := visual.get_node("Sprite2D") as AnimatedSprite2D
	sprite.play("idle")
	sprite.pause()
	var tween := create_tween()
	# Squash toward the ground, turn over, then fade promptly.
	tween.tween_property(visual, "scale", Vector2(1.25, 0.42), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(visual, "position:y", -18.0, 0.12)
	tween.tween_property(visual, "rotation", PI * facing, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(visual, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _damage_player(player: CharacterBody2D) -> void:
	var health = player.get_node_or_null("HealthComponent")
	if health == null:
		return
	restoring_player = true
	health.take_damage(global_position)
	state = State.PATROL
	timer = 0.0
	velocity.x = 0.0
	visual.modulate = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	restoring_player = false
