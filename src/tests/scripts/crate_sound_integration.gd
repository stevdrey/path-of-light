extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var world := Node2D.new()
	root.add_child(world)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	world.add_child(player)
	var box = load("res://src/collectibles/breakable_crate.tscn").instantiate()
	world.add_child(box)
	box.hit_from_below(player)
	box.hit_from_below(player)
	await process_frame
	await process_frame
	var count := 0
	for node in root.get_children():
		if node is AudioStreamPlayer and node.stream != null and node.stream.resource_path.ends_with("crate_break_sfx_engine.wav"):
			if not node.playing or node.bus != &"SFX" or not is_equal_approx(node.volume_db,-4.0):
				printerr("FAIL: crate sound playback or volume"); quit(1); return
			count += 1
	if count != 1:
		printerr("FAIL: expected exactly one crate sound, got ",count); quit(1); return
	print("PASS: repeated hits produce one correctly routed crate sound")
	await create_timer(1.3).timeout
	for node in root.get_children():
		if node is AudioStreamPlayer and node.stream != null and node.stream.resource_path.ends_with("crate_break_sfx_engine.wav"):
			printerr("FAIL: sound player was not freed"); quit(1); return
	print("PASS: one-shot sound finishes and cleans up")
	world.queue_free()
	await process_frame
	quit(0)
