extends "res://src/scenes/scripts/level.gd"

const FALL_Y := 820.0
# The existing bonus room is below the main route (floor around y=1220).
const SECRET_FALL_Y := 1500.0
const CHECKPOINT_RADIUS := 32.0
const PORTAL_VORTEX := preload("res://src/scenes/shaders/portal_vortex.gdshader")
const PORTAL_SOUND := preload("res://assets/sounds/sfx/portal_whoosh_sfx_engine.wav")
@export_range(-40.0, 0.0, 1.0) var portal_sound_volume_db := -8.0
var in_secret := false
var portal_transitioning := false
var vortex_overlay: ColorRect
var vortex_material: ShaderMaterial
var checkpoint := Vector2(100, 548)
var checkpoint_index := 0
@export var safe_checkpoints: Array[Vector2] = [Vector2(2190, 548), Vector2(3210, 548), Vector2(4352, 548), Vector2(5540, 548), Vector2(8500, 548), Vector2(11000, 548), Vector2(13000, 548)]

func _ready() -> void:
	super._ready()
	movement.use_player_control()
	control_label = "Jugador"
	if level_number == 1 and door != null:
		door.next_level = "res://src/scenes/adventure_level_2.tscn"
	$CanvasLayer/Instructions/Title.text = "Sendero de descubrimiento"
	$CanvasLayer/Instructions/Help.text = "Esc: pausa  •  Cambia los controles en Opciones desde el menú inicial."
	_create_vortex_overlay()
	_update_status()

func _create_vortex_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	vortex_overlay = ColorRect.new()
	vortex_overlay.name = "PortalVortex"
	vortex_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vortex_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vortex_material = ShaderMaterial.new()
	vortex_material.shader = PORTAL_VORTEX
	vortex_overlay.material = vortex_material
	vortex_overlay.visible = false
	layer.add_child(vortex_overlay)

func _screen_focus(world_position: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_position := get_viewport().get_canvas_transform() * world_position
	return screen_position / viewport_size

func _input(event: InputEvent) -> void:
	if portal_transitioning:
		return
	if not transitioning and not player_health.dead and not movement.input_locked and not movement.damage_locked and movement.control == movement.player_control and event.is_action_pressed("interact_up") and not event.is_echo():
		var portal: Area2D = get_node_or_null("BonusExit" if in_secret else "BonusEntrance")
		if portal != null and portal.can_activate($Character):
			get_viewport().set_input_as_handled()
			if event.is_action_pressed("jump"):
				movement.suppress_jump_once = true
			_use_portal(portal)
			return
	super._input(event)

func _use_portal(portal: Area2D) -> void:
	portal_transitioning = true
	movement.input_locked = true
	$Character.velocity = Vector2.ZERO
	SOUND_EFFECTS.play_one_shot(get_tree(), PORTAL_SOUND, portal_sound_volume_db)
	vortex_material.set_shader_parameter("focus", _screen_focus(portal.global_position))
	vortex_material.set_shader_parameter("intensity", 0.0)
	vortex_overlay.visible = true
	var transition := create_tween()
	transition.tween_property(vortex_material, "shader_parameter/intensity", 1.0, 0.32)
	transition.parallel().tween_property(fade, "modulate:a", 1.0, 0.18).set_delay(0.20)
	await transition.finished
	in_secret = portal.enters_bonus
	if in_secret:
		Progress.recorded_secrets[level_number] = true
	$Character.global_position = portal.destination
	$Character.velocity = Vector2.ZERO
	$Character/LevelCamera.reset_smoothing()
	await get_tree().physics_frame
	vortex_material.set_shader_parameter("focus", _screen_focus($Character.global_position + Vector2(0, -32)))
	transition = create_tween()
	transition.tween_property(fade, "modulate:a", 0.0, 0.24)
	transition.parallel().tween_property(vortex_material, "shader_parameter/intensity", 0.0, 0.36)
	await transition.finished
	vortex_overlay.visible = false
	movement.input_locked = false
	portal_transitioning = false

func _physics_process(_delta: float) -> void:
	var player: CharacterBody2D = $Character
	if player_health.dead or transitioning or portal_transitioning or movement.input_locked:
		return
	if player.global_position.y > (SECRET_FALL_Y if in_secret else FALL_Y):
		# A fall always costs a heart, even if the player was already flashing.
		player_health.take_fall_damage()
		in_secret = false
		player.global_position = checkpoint
		player.velocity = Vector2.ZERO
		movement.reset_after_relocation()
		$Character/LevelCamera.reset_smoothing()
		return
	if not in_secret and player.is_on_floor():
		for i in range(safe_checkpoints.size()):
			if i >= checkpoint_index and player.global_position.distance_to(safe_checkpoints[i]) <= CHECKPOINT_RADIUS:
				checkpoint = safe_checkpoints[i]
				checkpoint_index = i + 1
