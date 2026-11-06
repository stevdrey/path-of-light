extends Node2D

signal health_changed(current: int, maximum: int)
signal depleted
@export_range(1, 3, 1) var max_hearts := 3
@export_range(0.5, 5.0, 0.1) var invulnerability_duration := 2.0
@export var hurt_duration := 0.3
@export var defeat_duration := 1.3
@onready var body: CharacterBody2D = get_parent()
@onready var movement: MovementComponent = body.get_node("MovementComponent")
@onready var original: AnimatedSprite2D = body.get_node("AnimatedSprite2D")
@onready var reaction: AnimatedSprite2D = $Reaction
@onready var sound: AudioStreamPlayer = $Sound
const HURT_SOUND := preload("res://assets/sounds/sfx/hurt.wav")
const DEFEAT_SOUND := preload("res://assets/sounds/sfx/defeat.wav")
var hearts := 3
var invulnerability_left := 0.0
var hurt_left := 0.0
var dead := false
var flash_time := 0.0

func _ready() -> void:
	hearts = max_hearts
	sound.bus = &"SFX"
	reaction.visible = false

func _physics_process(delta: float) -> void:
	if dead:
		return
	invulnerability_left = maxf(0.0, invulnerability_left - delta)
	hurt_left = maxf(0.0, hurt_left - delta)
	movement.damage_locked = hurt_left > 0.0

func _process(delta: float) -> void:
	flash_time += delta
	var reacting := dead or hurt_left > 0.0
	original.visible = not reacting
	reaction.visible = reacting
	if reacting:
		var animation := &"defeat" if dead else &"hurt"
		if reaction.animation != animation or (not dead and not reaction.is_playing()):
			reaction.play(animation)
	var alpha := 0.35 if not dead and invulnerability_left > 0.0 and fmod(flash_time, 0.24) < 0.12 else 1.0
	original.modulate.a = alpha
	reaction.modulate.a = alpha

func heal(amount: int = 1) -> bool:
	if dead or amount <= 0 or hearts >= max_hearts:
		return false
	hearts = mini(max_hearts, hearts + amount)
	health_changed.emit(hearts, max_hearts)
	return true

func take_damage(source: Vector2) -> bool:
	if dead or invulnerability_left > 0.0 or movement.input_locked:
		return false
	hearts -= 1
	invulnerability_left = invulnerability_duration
	hurt_left = hurt_duration
	movement.damage_locked = true
	movement.climbing = false
	body.set_collision_mask_value(2, true)
	movement.jump_buffer_left = 0.0
	var direction := signf(body.global_position.x - source.x)
	if is_zero_approx(direction):
		direction = -1.0
	body.velocity = Vector2(direction * 180.0, -210.0)
	health_changed.emit(hearts, max_hearts)
	if hearts <= 0:
		dead = true
		movement.damage_locked = true
		sound.stream = DEFEAT_SOUND
		sound.play()
		await get_tree().create_timer(defeat_duration).timeout
		depleted.emit()
	else:
		sound.stream = HURT_SOUND
		sound.play()
	return true
