extends Node2D

func _ready() -> void:
	$Fragments.emitting = true
	await get_tree().create_timer(1.2).timeout
	queue_free()
