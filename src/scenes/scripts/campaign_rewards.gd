extends RefCounted
## Published content IDs must never be renamed or reused.
## No world/campaign finale exists yet. Empty definitions intentionally grant
## nothing for finishing the two experimental routes.
const WORLDS := []
const CAMPAIGN_LEVELS := []
const CAMPAIGN_FINALE := 0
const DISCOVERIES := [
	{"id": "secret-chamber-1", "level_id": 1, "title": "La cámara secreta", "category": "El mundo de las luces"},
]

# Pure policy seam: tests supply synthetic definitions, never production content.
# World definitions: {id: String, levels: Array[int], finale: int}.
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
