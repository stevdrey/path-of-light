extends RefCounted
## Wait on process frames, which drive deferred scene changes, rather than
## assuming that a number of physics steps implies a ready replacement scene.

const TIMEOUT_MSEC := 5000

static func for_scene(tree: SceneTree, expected_path: String, timeout_msec: int = TIMEOUT_MSEC) -> Node:
	var deadline := Time.get_ticks_msec() + maxi(0, timeout_msec)
	while true:
		var scene: Node = tree.current_scene
		if is_instance_valid(scene) and scene.scene_file_path == expected_path and scene.is_node_ready():
			return scene
		if Time.get_ticks_msec() >= deadline:
			return null
		await tree.process_frame
	return null
