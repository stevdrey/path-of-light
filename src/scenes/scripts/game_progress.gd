class_name GameProgress
extends RefCounted

static var hearts := 3
static var score := 0
static var diamonds := 0
static var diamond_counts: Array[int] = [0, 0, 0, 0]
static var keys: Dictionary = {}
# GameProgress owns process-session records, including menu -> JUGAR and replay.
# JUGAR starts another attempt, not a destructive new campaign. No current UI
# offers a full reset; reset() is the explicit API for a future fresh campaign.
# Disk saves and migration remain E03-01.
static var recorded_secrets: Dictionary = {}
static var completed_levels: Dictionary = {}

static func reset() -> void:
	reset_attempt()
	recorded_secrets.clear()
	completed_levels.clear()

static func reset_attempt() -> void:
	hearts = 3
	score = 0
	diamonds = 0
	diamond_counts = [0, 0, 0, 0]
	keys.clear()

static func snapshot_inventory() -> Dictionary:
	return {"score": score, "diamonds": diamonds, "counts": diamond_counts.duplicate(), "keys": keys.duplicate(true)}

static func restore_inventory(snapshot: Dictionary) -> void:
	hearts = 3
	score = snapshot.score
	diamonds = snapshot.diamonds
	diamond_counts.assign(snapshot.counts)
	keys = snapshot.keys.duplicate(true)
