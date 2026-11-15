extends SceneTree
const Progress := preload("res://src/scenes/scripts/game_progress.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Progress.ensure_campaign_loaded()
	var map: Control = load("res://src/ui/level_map.tscn").instantiate()
	root.add_child(map)
	current_scene = map
	map._open_records()
	for viewport_size in [Vector2i(640, 480), Vector2i(1152, 648)]:
		root.size = viewport_size
		for i in 6:
			await process_frame
		print("PROBE viewport=", viewport_size, " map=", map.get_global_rect(), " panel=", map.frame.get_global_rect(), " min=", map.frame.get_combined_minimum_size())
		for node in map.records_column.get_children():
			print("PROBE child=", node.name, " rect=", node.get_global_rect(), " min=", node.get_combined_minimum_size(), " text=", node.text)
	map.free()
	current_scene = null
	quit(0)
