extends RefCounted

# The root outlives scene changes and defeated enemies, so one-shots finish.
static func play_one_shot(tree: SceneTree, sound: AudioStream, volume_db: float = 0.0) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	player.stream = sound
	player.volume_db = volume_db
	tree.root.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
