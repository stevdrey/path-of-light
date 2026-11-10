extends Node2D

const PAUSE_MENU := preload("res://src/ui/scripts/pause_menu.gd")
const Progress = preload("res://src/scenes/scripts/game_progress.gd")
const DOOR_SCENE := preload("res://src/scenes/level_door.tscn")
const ITEM_SCENE := preload("res://src/collectibles/collectible.tscn")
const HEALTH_SCENE := preload("res://src/character/components/player_health.tscn")
const HUD_SCENE := preload("res://src/ui/collection_hud.tscn")
const COMPLETION_SCENE := preload("res://src/ui/completion.tscn")
const SOUND_EFFECTS := preload("res://src/audio/scripts/sound_effects.gd")
const DOOR_OPEN_SOUND := preload("res://assets/sounds/sfx/door_open_sfx_engine.wav")
const TILE_TEXTURE := preload("res://assets/images/platformPack_tilesheet.png")

@onready var movement: MovementComponent = $Character/MovementComponent
@onready var status: Label = $CanvasLayer/Instructions/Status
var control_label := "Automático"
var door: Area2D
var transitioning := false
var completed := false
var fade: ColorRect
@export var level_number := 1
var gem_sound: AudioStreamPlayer
var key_sound: AudioStreamPlayer
var collection_hud: CanvasLayer
var present_colors: Array[bool] = [false, false, false, false]
var entry_progress: Dictionary
var player_health: Node2D

func _ready() -> void:
	var pause_menu := CanvasLayer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.set_script(PAUSE_MENU)
	add_child(pause_menu)
	if level_number == 1:
		Progress.reset_attempt()
	else:
		movement.use_player_control()
		control_label = "Jugador"
	entry_progress = Progress.snapshot_inventory()
	$Character.add_to_group("player")
	gem_sound = AudioStreamPlayer.new()
	gem_sound.bus = &"SFX"
	gem_sound.name = "GemSound"
	gem_sound.stream = preload("res://assets/sounds/sfx/collect_gem.wav")
	gem_sound.volume_db = 8.0
	add_child(gem_sound)
	key_sound = AudioStreamPlayer.new()
	key_sound.bus = &"SFX"
	key_sound.name = "KeySound"
	key_sound.stream = preload("res://assets/sounds/sfx/collect_key.mp3")
	add_child(key_sound)
	player_health = HEALTH_SCENE.instantiate()
	$Character.add_child(player_health)
	player_health.hearts = clampi(Progress.hearts, 1, player_health.max_hearts)
	player_health.health_changed.connect(_on_health_changed)
	player_health.depleted.connect(_on_health_depleted)
	for item in $Collectibles.get_children():
		if item.kind >= 0 and item.kind <= CollectibleItem.Kind.ORANGE_DIAMOND:
			present_colors[item.kind] = true
		item.collected.connect(_on_collected)
	for box in find_children("*", "StaticBody2D", true, false):
		if box.is_in_group("breakable_boxes"):
			box.item_released.connect(_on_box_item_released)
			if box.content_kind >= 0 and box.content_kind <= CollectibleItem.Kind.ORANGE_DIAMOND:
				present_colors[box.content_kind] = true
	collection_hud = get_node_or_null("CollectionHUD")
	if collection_hud == null:
		collection_hud = HUD_SCENE.instantiate()
		add_child(collection_hud)
	collection_hud.set_health(player_health.hearts, player_health.max_hearts)
	if level_number == 1:
		_setup_exit()
	else:
		door = get_node_or_null("LevelDoor")
	if level_number == 3:
		var guard = get_node_or_null("BeetleEnemy")
		if guard != null:
			guard.defeated.connect(_on_guard_defeated.bind(guard))
	$CanvasLayer/Instructions/Title.text = "Nivel %d" % level_number
	$CanvasLayer/Instructions/Help.text = "Esc: pausa  •  Cambia los controles en Opciones desde el menú inicial."
	movement.control_changed.connect(_on_control_changed)
	_create_fade()
	_update_status()

func _setup_exit() -> void:
	# Compatibility with the earlier scene; the new level contains both nodes.
	$DecorationTiles.erase_cell(Vector2i(34,-2))
	$DecorationTiles.erase_cell(Vector2i(34,-1))
	door = get_node_or_null("LevelDoor")
	if door == null:
		door = DOOR_SCENE.instantiate()
		door.position = Vector2(2208,550)
		add_child(door)
	if not $Collectibles.has_node("BlueKey"):
		var key = ITEM_SCENE.instantiate()
		key.name = "BlueKey"
		key.kind = CollectibleItem.Kind.BLUE_KEY
		key.points = 0
		key.position = Vector2(1504,382)
		$Collectibles.add_child(key)
		key.collected.connect(_on_collected)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_demo") and not event.is_echo() and (not transitioning or completed):
		get_viewport().set_input_as_handled()
		_restart_attempt()
		return
	if transitioning or player_health.dead or movement.input_locked or movement.damage_locked:
		return
	var up_pressed := event.is_action_pressed("interact_up") and not event.is_echo()
	if door != null and door.player_nearby and movement.control == movement.player_control and up_pressed:
		get_viewport().set_input_as_handled()
		if event.is_action_pressed("jump"):
			movement.suppress_jump_once = true
		if Progress.keys.get(door.required_key, false):
			_open_door()

func _on_health_changed(current: int, maximum: int) -> void:
	Progress.hearts = current
	collection_hud.set_health(current, maximum)

func _on_health_depleted() -> void:
	_restart_attempt()

func _restart_attempt() -> void:
	if transitioning and not completed:
		return
	transitioning = true
	completed = false
	movement.input_locked = true
	Progress.restore_inventory(entry_progress)
	# Input/physics callbacks must finish before their scene is removed.
	get_tree().call_deferred("reload_current_scene")

func _on_guard_defeated(guard: Node2D) -> void:
	call_deferred("_spawn_guard_key", guard.global_position + Vector2(0, -52))

func _spawn_guard_key(at: Vector2) -> void:
	var key = ITEM_SCENE.instantiate()
	key.name = "GuardKey"
	key.kind = door.required_key
	key.points = 0
	key.position = at
	# Keep the drop visible briefly before allowing it to be collected.
	key.monitoring = false
	$Collectibles.add_child(key)
	key.collected.connect(_on_collected)
	await get_tree().create_timer(0.7).timeout
	if is_instance_valid(key):
		key.monitoring = true

func _show_completion() -> void:
	Progress.completed_levels[level_number] = true
	completed = true
	add_child(COMPLETION_SCENE.instantiate())

func _on_control_changed(label: String) -> void:
	control_label = label
	_update_status()

func _on_collected(kind: int, points: int) -> void:
	if player_health.dead or transitioning:
		return
	Progress.score += points
	if kind >= CollectibleItem.Kind.BLUE_DIAMOND and kind <= CollectibleItem.Kind.ORANGE_DIAMOND:
		gem_sound.play()
		Progress.diamonds += 1
		Progress.diamond_counts[kind] += 1
	elif kind >= CollectibleItem.Kind.BLUE_KEY and kind <= CollectibleItem.Kind.ORANGE_KEY:
		key_sound.play()
		Progress.keys[kind] = true
	elif kind == CollectibleItem.Kind.HEART:
		player_health.heal()
	_update_status()

func _on_box_item_released(item: CollectibleItem) -> void:
	item.collected.connect(_on_collected)

func _update_status() -> void:
	status.text = "Control: %s" % control_label
	var key_kind: int = door.required_key if door != null else CollectibleItem.Kind.BLUE_KEY
	collection_hud.set_inventory(Progress.diamond_counts, Progress.keys.get(key_kind, false), key_kind, present_colors, Progress.score, door != null)

func _create_fade() -> void:
	fade = ColorRect.new()
	fade.name = "Transition"
	fade.color = Color(0.03,0.06,0.11,1)
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 5
	add_child(fade_layer)
	fade_layer.add_child(fade)
	if level_number > 1:
		var tween := create_tween()
		tween.tween_property(fade, "modulate:a", 0.0, 0.45)
	else:
		fade.modulate.a = 0.0

func _open_door() -> void:
	transitioning = true
	door.cue_enabled = false
	movement.input_locked = true
	movement.jump_buffer_left = 0.0
	Progress.keys.erase(door.required_key)
	_update_status()
	var flying_key := Sprite2D.new()
	flying_key.texture = TILE_TEXTURE
	flying_key.region_enabled = true
	flying_key.region_rect = Rect2(456 + (door.required_key - CollectibleItem.Kind.BLUE_KEY) * 64,272,48,32)
	flying_key.region_filter_clip_enabled = true
	flying_key.global_position = $Character.global_position + Vector2(0,-55)
	flying_key.z_index = 5
	add_child(flying_key)
	var tween := create_tween()
	tween.tween_property(flying_key, "global_position", door.global_position + Vector2(0,-50), 0.5)
	tween.parallel().tween_property(flying_key, "scale", Vector2(0.35,0.35), 0.5)
	tween.tween_property(door.get_node("Visual"), "modulate", Color(1.7,1.7,1.7,1), 0.15)
	tween.tween_callback(flying_key.queue_free)
	tween.tween_callback(func(): SOUND_EFFECTS.play_one_shot(get_tree(), DOOR_OPEN_SOUND))
	tween.tween_property(door.get_node("Visual"), "scale:x", 0.05, 0.15)
	tween.tween_callback(func():
		door.get_node("Visual").region_rect = Rect2(320, 320, 64, 128)
		door.get_node("Visual").modulate = Color.WHITE
	)
	tween.tween_property(door.get_node("Visual"), "scale:x", 1.0, 0.15)
	tween.tween_callback(func(): $Character/AnimationStateMachine.victory = true)
	tween.tween_interval(0.7)
	if door.next_level.is_empty():
		tween.tween_callback(_show_completion)
	else:
		tween.tween_property(fade, "modulate:a", 1.0, 0.45)
		tween.tween_callback(func():
			Progress.completed_levels[level_number] = true
			get_tree().change_scene_to_file(door.next_level)
		)
