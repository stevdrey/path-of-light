class_name GameProgress
extends RefCounted

static var hearts := 3
static var score := 0
static var diamonds := 0
static var diamond_counts: Array[int] = [0, 0, 0, 0]
static var keys: Dictionary = {}

static func reset() -> void:
	hearts = 3
	score = 0
	diamonds = 0
	diamond_counts = [0, 0, 0, 0]
	keys.clear()
