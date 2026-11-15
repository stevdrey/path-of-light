extends RefCounted
## Published content IDs must never be renamed or reused.
## No world/campaign finale exists yet. Empty definitions intentionally grant
## nothing for finishing the two experimental routes.
const WORLDS := []
const CAMPAIGN_LEVELS := []
const CAMPAIGN_FINALE := 0
# Discovery entries: {id, level_id, title, category, legacy_secret_level?}.
# Optional legacy_secret_level: a recorded numeric secret for that level implies
# this discovery. Only the existing portal chamber uses this mapping.
const DISCOVERIES := [
	{"id": "secret-chamber-1", "level_id": 1, "legacy_secret_level": 1, "title": "La cámara secreta", "category": "El mundo de las luces"},
]

# Sharing a level does not make two discoveries the same event. Legacy saves
# imply only records whose metadata explicitly maps that numeric portal visit.
static func discoveries_for_secrets(secrets: Dictionary, discoveries: Array = DISCOVERIES) -> Array:
	var discovered := []
	for discovery in discoveries:
		if discovery.has("legacy_secret_level") and secrets.get(discovery.legacy_secret_level, false):
			discovered.append(discovery.id)
	return discovered

# Pure policy seam: tests supply synthetic definitions, never production content.
# World definitions: {id: String, title: String, levels: Array[int], finale: int}.
# `title` is required authored display text; IDs are never shown to players.
# A campaign requires all its levels and an explicit finale among them.
static func earned(completions: Dictionary, worlds: Array = WORLDS, campaign_levels: Array = CAMPAIGN_LEVELS, campaign_finale: int = CAMPAIGN_FINALE) -> Dictionary:
	var rewards := []
	for world in worlds:
		if world.finale in world.levels and _all_completed(world.levels, completions):
			rewards.append(world.id)
	var characters := []
	if campaign_finale in campaign_levels and _all_completed(campaign_levels, completions):
		characters.append("prototype")
	return {"world_rewards": rewards, "character_unlocks": characters}

static func _all_completed(levels: Array, completions: Dictionary) -> bool:
	if levels.is_empty():
		return false
	for level_id in levels:
		if not completions.get(level_id, false):
			return false
	return true
