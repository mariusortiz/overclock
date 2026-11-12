class_name BattlePass
## Free, permanent progression track. Every game gives XP from the score; each
## tier reached unlocks one item of the Loadout catalog. Items that are not
## listed here are available from the start.

const XP_PER_SCORE_POINT := 0.1
const FIRST_TIER_COST := 260
const COST_INCREASE := 60
## Tiers up to this one cost more and more; later ones cost LATE_TIER_COST.
const RISING_TIERS := 30
const LATE_TIER_COST := 1000
const XP_KEY := "xp"

## Loadout item ids, in tier order: REWARDS[0] is the reward of tier 1.
const REWARDS: Array[String] = [
	"spear", "skin_neon", "cowboy", "heavy", "skin_ice",
	"soldier_female", "axe", "skin_lava", "ninja", "sniper",
	"skin_camo", "pirate", "mace", "skin_toxic", "knight",
	"smg", "skin_royal", "kimono", "skin_carbon", "viking",
	"skin_sakura", "elf", "bazooka", "skin_ocean", "cowgirl",
	"skin_solar", "witch", "wizard", "skin_gold", "golden_knight",
	# Tiers 31 and up: the rest of the gun pack.
	"pistol_2", "shotgun_1", "rifle_2", "revolver_1", "smg_2",
	"sniper_2", "bullpup_1", "pistol_3", "shotgun_2", "rifle_3",
	"revolver_2", "smg_3", "sniper_3", "bullpup_2", "pistol_4",
	"shotgun_3", "rifle_4", "revolver_3", "smg_4", "sniper_4",
	"pistol_5", "shotgun_4", "rifle_5", "revolver_4", "smg_5",
	"sniper_5", "pistol_6", "shotgun_5", "rifle_6", "revolver_5",
	"sniper_6", "shotgun_6", "rifle_7", "rifle_8", "rifle_9",
	# Tiers 66 and up: the blades.
	"kunai", "butterfly", "karambit", "machete", "katana",
	# Tiers 71 and up: the ships of the race.
	"ship_falcon", "ship_ram", "ship_specter", "ship_comet", "ship_hornet", "ship_storm", "ship_nova",
]


static func xp_for_score(score: int) -> int:
	return roundi(score * XP_PER_SCORE_POINT)


## XP needed to go from tier - 1 to `tier` (1-based).
static func tier_cost(tier: int) -> int:
	if tier > RISING_TIERS:
		return LATE_TIER_COST
	return FIRST_TIER_COST + COST_INCREASE * (tier - 1)


static func total_xp() -> int:
	return SaveData.load_progress(XP_KEY, 0)


## Where the player stands: {"tier": tiers reached, "xp": XP into the next
## tier, "needed": cost of the next tier (0 when the pass is complete)}.
static func progress() -> Dictionary:
	var xp := total_xp()
	var tier := 0
	while tier < REWARDS.size() and xp >= tier_cost(tier + 1):
		xp -= tier_cost(tier + 1)
		tier += 1
	var complete := tier == REWARDS.size()
	return {"tier": tier, "xp": 0 if complete else xp, "needed": 0 if complete else tier_cost(tier + 1)}


## Adds XP and returns the ids unlocked by the tiers just reached.
static func add_xp(amount: int) -> Array[String]:
	var before: int = progress().tier
	SaveData.save_progress(XP_KEY, total_xp() + amount)
	var after: int = progress().tier
	return REWARDS.slice(before, after)


## Tier that unlocks an item, or 0 when it is available from the start.
static func required_tier(id: String) -> int:
	return REWARDS.find(id) + 1


static func is_unlocked(id: String) -> bool:
	return required_tier(id) <= progress().tier
