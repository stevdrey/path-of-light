class_name GameProgress
extends RefCounted

static var hearts := 3
# Missing hearts hidden by the one-heart minimum after lowering the assist cap.
static var hidden_missing := 0
static var score := 0
static var diamonds := 0
static var diamond_counts: Array[int] = [0, 0, 0, 0]
static var keys: Dictionary = {}
const CampaignSave := preload("res://src/scenes/scripts/campaign_save.gd")
# Durable facts, separate from inventory and scene state. JUGAR and replay
# begin new attempts without erasing the campaign. No destructive reset UI.
static var recorded_secrets: Dictionary = {}
static var completed_levels: Dictionary = {}
static var campaign_store := CampaignSave.new()
static var campaign_loaded := false
static var campaign_status := "new"
static var campaign_error: int = OK
# False after reset(): the cleared records must never be autosaved over disk.
static var campaign_persistent := true

# In-memory reset for callers/tests. Disables autosave until load_campaign(), so
# it never deletes or replaces disk saves. A future fresh-campaign UI needs its
# own explicit persistent reset transaction.
static func reset() -> void:
	campaign_loaded = true
	campaign_persistent = false
	reset_attempt()
	recorded_secrets.clear()
	completed_levels.clear()
	campaign_status = "new"
	campaign_error = OK

static func ensure_campaign_loaded() -> void:
	if not campaign_loaded:
		load_campaign()

static func load_campaign() -> void:
	var result := campaign_store.load_campaign()
	campaign_loaded = true
	campaign_persistent = true
	campaign_status = result.status
	campaign_error = result.error
	completed_levels.clear()
	recorded_secrets.clear()
	for id in result.data.completed_levels:
		completed_levels[id] = true
	for id in result.data.recorded_secrets:
		recorded_secrets[id] = true
	# Application restart never resumes an attempt or restores its key/health.
	reset_attempt()

static func save_campaign() -> Error:
	ensure_campaign_loaded()
	if not campaign_persistent:
		return ERR_UNAUTHORIZED
	campaign_error = campaign_store.save_campaign({"schema_version": CampaignSave.VERSION,
		"completed_levels": completed_levels.keys(), "recorded_secrets": recorded_secrets.keys()})
	if campaign_error == OK:
		campaign_status = "loaded"
	return campaign_error as Error

# Retries a failed write at menu/level boundaries. Never writes protected
# (corrupt or newer) files, because the store stays non-writable for them.
static func retry_failed_save() -> void:
	if campaign_loaded and campaign_persistent and campaign_error != OK and campaign_store.writable:
		save_campaign()

static func record_secret(level_id: int) -> Error:
	ensure_campaign_loaded()
	# Skip unchanged records unless the previous save still needs a retry.
	if recorded_secrets.has(level_id) and campaign_error == OK:
		return OK
	recorded_secrets[level_id] = true
	return save_campaign()

static func record_completion(level_id: int) -> Error:
	ensure_campaign_loaded()
	if completed_levels.has(level_id) and campaign_error == OK:
		return OK
	completed_levels[level_id] = true
	return save_campaign()

static func campaign_notice() -> String:
	if campaign_status == "unsupported":
		return "Partida de una versión más reciente. Puedes jugar sin guardarla."
	if campaign_error != OK:
		return "No se pudo guardar o recuperar la partida. El progreso de esta sesión podría perderse."
	if campaign_status == "recovered":
		return "Partida recuperada desde la copia de seguridad."
	return ""

# Runtime lookup avoids a compile-time dependency on the GameSettings autoload.
static func configured_max_hearts() -> int:
	var tree := Engine.get_main_loop() as SceneTree
	var settings: Node = tree.root.get_node_or_null("GameSettings") if tree != null else null
	return settings.get_max_hearts() if settings != null else 3

static func reset_attempt() -> void:
	hearts = configured_max_hearts()
	hidden_missing = 0
	score = 0
	diamonds = 0
	diamond_counts = [0, 0, 0, 0]
	keys.clear()

static func snapshot_inventory() -> Dictionary:
	return {"score": score, "diamonds": diamonds, "counts": diamond_counts.duplicate(), "keys": keys.duplicate(true)}

static func restore_inventory(snapshot: Dictionary) -> void:
	hearts = configured_max_hearts()
	hidden_missing = 0
	score = snapshot.score
	diamonds = snapshot.diamonds
	diamond_counts.assign(snapshot.counts)
	keys = snapshot.keys.duplicate(true)
