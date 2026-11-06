@tool
extends StaticBody2D

signal item_released(item: CollectibleItem)

@export_enum("Vacía:-1", "Diamante azul:0", "Diamante amarillo:1", "Diamante verde:2", "Diamante naranja:3", "Llave azul:4", "Llave amarilla:5", "Llave verde:6", "Llave naranja:7", "Corazón:8") var content_kind: int = CollectibleItem.Kind.BLUE_DIAMOND:
	set(value):
		content_kind = value
		_update_hint()
@export_range(-1, 1000, 1) var diamond_points := -1
@export_range(-40.0, 0.0, 1.0) var break_sound_volume_db := -4.0
@export var show_key_hint := false:
	set(value):
		show_key_hint = value
		_update_hint()

const ITEM_SCENE := preload("res://src/collectibles/collectible.tscn")
const FRAGMENTS_SCENE := preload("res://src/collectibles/crate_fragments.tscn")
const SOUND_EFFECTS := preload("res://src/audio/scripts/sound_effects.gd")
const BREAK_SOUND := preload("res://assets/sounds/sfx/crate_break_sfx_engine.wav")
var broken := false

func _ready() -> void:
	_update_hint()

func _update_hint() -> void:
	var hint := get_node_or_null("KeyHint") as Sprite2D
	if hint == null:
		return
	hint.visible = show_key_hint and content_kind >= CollectibleItem.Kind.BLUE_KEY and content_kind <= CollectibleItem.Kind.ORANGE_KEY
	if hint.visible:
		hint.region_rect = Rect2(456 + (content_kind - CollectibleItem.Kind.BLUE_KEY) * 64, 272, 48, 32)

func hit_from_below(body: CharacterBody2D) -> void:
	if Engine.is_editor_hint() or broken or not body.is_in_group("player"):
		return
	broken = true
	call_deferred("_release_contents")

func _release_contents() -> void:
	if not is_inside_tree():
		return
	SOUND_EFFECTS.play_one_shot(get_tree(), BREAK_SOUND, break_sound_volume_db)
	var parent := get_parent()
	var fragments := FRAGMENTS_SCENE.instantiate()
	fragments.position = parent.to_local(global_position)
	parent.add_child(fragments)
	if content_kind >= 0:
		var item: CollectibleItem = ITEM_SCENE.instantiate()
		item.kind = content_kind
		if content_kind >= CollectibleItem.Kind.BLUE_KEY:
			item.points = 0
		elif diamond_points >= 0:
			item.points = diamond_points
		var container: Node = null
		var ancestor: Node = parent
		while ancestor != null and container == null:
			container = ancestor.get_node_or_null("Collectibles")
			ancestor = ancestor.get_parent()
		if container == null:
			container = parent
		item.position = container.to_local(global_position)
		container.add_child(item)
		item_released.emit(item)
	queue_free()
