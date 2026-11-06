extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var world := Node2D.new()
	var container := Node2D.new()
	container.name="Collectibles"
	world.add_child(container)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	world.add_child(player)
	root.add_child(world)
	for kind in range(-1,9):
		var box=load("res://src/collectibles/breakable_crate.tscn").instantiate()
		box.content_kind=kind
		world.add_child(box)
		box.hit_from_below(player)
		box.hit_from_below(player)
		await process_frame
		await process_frame
		var items := []
		for item in container.get_children():
			if item is CollectibleItem: items.append(item)
		if items.size() != (0 if kind == -1 else 1):
			printerr("FAIL: content count for ",kind); quit(1); return
		if kind >= 0:
			if items[0].kind != kind or (kind >= 4 and items[0].points != 0):
				printerr("FAIL: invalid content ",kind); quit(1); return
			items[0].queue_free()
		await process_frame
	print("PASS: empty, four diamond colors, four key colors and heart release once")
	world.queue_free()
	await process_frame
	quit(0)
