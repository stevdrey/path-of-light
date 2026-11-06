extends CanvasLayer

@onready var rows: Array[HBoxContainer] = [$Panel/Margin/Column/Inventory/Diamonds/Blue, $Panel/Margin/Column/Inventory/Diamonds/Yellow, $Panel/Margin/Column/Inventory/Diamonds/Green, $Panel/Margin/Column/Inventory/Diamonds/Orange]
@onready var counts: Array[Label] = [$Panel/Margin/Column/Inventory/Diamonds/Blue/Count, $Panel/Margin/Column/Inventory/Diamonds/Yellow/Count, $Panel/Margin/Column/Inventory/Diamonds/Green/Count, $Panel/Margin/Column/Inventory/Diamonds/Orange/Count]
@onready var key_row: HBoxContainer = $Panel/Margin/Column/Inventory/Key
@onready var key_label: Label = $Panel/Margin/Column/Inventory/Key/State
@onready var key_icon: TextureRect = $Panel/Margin/Column/Inventory/Key/Icon
@onready var hearts_row: HBoxContainer = $Panel/Margin/Column/Hearts
@onready var score_label: Label = $Panel/Margin/Column/Score

func _ready() -> void:
	key_icon.texture = key_icon.texture.duplicate()

func set_inventory(diamonds: Array[int], has_key: bool, key_kind: int, present: Array[bool], score: int, show_key: bool) -> void:
	var atlas := key_icon.texture as AtlasTexture
	atlas.region = Rect2(448 + clampi(key_kind - 4, 0, 3) * 64, 256, 64, 64)
	for i in range(4):
		rows[i].visible = present[i]
		counts[i].text = "× %d" % diamonds[i]
	key_row.visible = show_key
	key_label.text = "Lista" if has_key else "Sin llave"
	key_icon.modulate = Color.WHITE if has_key else Color(0.5, 0.5, 0.5, 0.6)
	score_label.text = "PUNTOS   %d" % score

func set_health(current: int, maximum: int) -> void:
	var atlas_source: Texture2D = preload("res://assets/images/platformPack_tilesheet.png")
	for i in range(hearts_row.get_child_count()):
		var icon := hearts_row.get_child(i) as TextureRect
		icon.visible = i < maximum
		var heart := AtlasTexture.new()
		heart.atlas = atlas_source
		heart.region = Rect2(704, 256 if i < current else 128, 64, 64)
		icon.texture = heart
