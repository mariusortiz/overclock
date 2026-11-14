class_name BattlePass
## Free, permanent progression tracks. Every game gives XP from the score; each
## tier reached unlocks one item of the Loadout catalog. Items that are not
## listed here are available from the start.
##
## Two seasons, each with its own tiers (REWARDS, REWARDS_2). Every XP counts
## for both: the second season starts from zero when it comes, and nothing
## of the first is lost. Season 2 also pays gems ("gems:n"), credits
## ("credits:n") and boosters ("booster:kind") between its items, given
## as soon as the tier is reached.

const XP_PER_SCORE_POINT := 0.1
const FIRST_TIER_COST := 260
const COST_INCREASE := 60
## Tiers up to this one cost more and more; later ones cost LATE_TIER_COST.
const RISING_TIERS := 30
const LATE_TIER_COST := 1000
const XP_KEY := "xp"
const XP_2_KEY := "xp_season2"
const SEASON_NAMES: Array[String] = ["SAISON 1", "SAISON 2 · MATRICE"]

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


## Season 2: the Matrice. Its last tier is a hero, Programme.
const REWARDS_2: Array[String] = [
	"credits:560", "skin_data", "gems:52", "booster:standard", "credits:800",
	"gems:64", "booster:rare", "dance_glitch", "credits:1040", "gems:80",
	"booster:standard", "credits:1220", "gems:92", "skin_firewall", "booster:rare",
	"pet_pug", "gems:108", "booster:standard", "credits:1640", "gems:120",
	"ship_firewall", "booster:rare", "credits:1880", "gems:136", "booster:standard",
	"credits:2060", "gems:148", "skin_corruption", "booster:rare", "credits:2300",
	"gems:164", "booster:standard", "pet_eagle", "gems:176", "booster:rare",
	"skin_binary", "credits:2720", "gems:192", "booster:standard", "acc_cowboy",
	"gems:204", "booster:rare", "credits:3080", "gems:216", "dance_reboot",
	"booster:standard", "credits:3320", "gems:232", "booster:rare", "credits:3500",
	"gems:244", "skin_kernel", "booster:standard", "credits:3740", "gems:260",
	"booster:rare", "pet_titan", "gems:272", "booster:standard", "booster:legend",
	"credits:4160", "gems:288", "booster:rare", "credits:4340", "gems:300",
	"booster:standard", "credits:4520", "gems:312", "booster:rare", "programme",
]


static func rewards(season: int) -> Array[String]:
	return REWARDS if season == 0 else REWARDS_2


static func xp_for_score(score: int) -> int:
	return roundi(score * XP_PER_SCORE_POINT)


## XP needed to go from tier - 1 to `tier` (1-based).
static func tier_cost(tier: int) -> int:
	if tier > RISING_TIERS:
		return LATE_TIER_COST
	return FIRST_TIER_COST + COST_INCREASE * (tier - 1)


static func total_xp(season := 0) -> int:
	return SaveData.load_progress(XP_KEY if season == 0 else XP_2_KEY, 0)


## Where the player stands: {"tier": tiers reached, "xp": XP into the next
## tier, "needed": cost of the next tier (0 when the pass is complete)}.
static func progress(season := 0) -> Dictionary:
	var list := rewards(season)
	var xp := total_xp(season)
	var tier := 0
	while tier < list.size() and xp >= tier_cost(tier + 1):
		xp -= tier_cost(tier + 1)
		tier += 1
	var complete := tier == list.size()
	return {"tier": tier, "xp": 0 if complete else xp, "needed": 0 if complete else tier_cost(tier + 1)}


## Adds XP to both seasons, pays season 2's gems, credits and boosters, and
## returns the ids of the items unlocked by the tiers just reached (those
## of the Loadout: guns, heroes, skins, ships).
static func add_xp(amount: int, season := -1) -> Array[String]:
	var unlocked: Array[String] = []
	for index in SEASON_NAMES.size():
		if season != -1 and index != season:
			continue
		var before: int = progress(index).tier
		SaveData.save_progress(XP_KEY if index == 0 else XP_2_KEY, total_xp(index) + amount)
		for reward in rewards(index).slice(before, progress(index).tier):
			if not _pay(reward) and not Loadout.find(reward).is_empty():
				unlocked.append(reward)
	return unlocked


## Gives a currency or booster reward. Returns false for an item.
static func _pay(reward: String) -> bool:
	var parts := reward.split(":")
	if parts.size() != 2:
		return false
	match parts[0]:
		"gems":
			Wallet.add_gems(parts[1].to_int())
		"credits":
			Wallet.add_credits(parts[1].to_int())
		"booster":
			Cards.give_booster(parts[1])
		_:
			return false
	return true


## What a reward is, for the pass screen: [name, kind].
static func describe(reward: String) -> Array:
	var parts := reward.split(":")
	if parts.size() == 2:
		match parts[0]:
			"gems":
				return ["%s gemmes" % parts[1], "Gemmes"]
			"credits":
				return ["%s crédits" % parts[1], "Crédits"]
			"booster":
				return [{"standard": "Booster", "rare": "Booster rare", "legend": "Booster légendaire"}[parts[1]], "Cartes"]
	var dance := Dances.find(reward)
	if not dance.is_empty():
		return [str(dance.name).capitalize(), "Danse"]
	var found := Loadout.find(reward)
	return [found.item.name, found.kind] if not found.is_empty() else [reward, ""]


## Tier that unlocks an item, or 0 when it is available from the start.
static func required_tier(id: String) -> int:
	return REWARDS.find(id) + 1 if id in REWARDS else REWARDS_2.find(id) + 1


## The season whose pass unlocks the item (0 or 1), or -1.
static func season_of(id: String) -> int:
	return 0 if id in REWARDS else (1 if id in REWARDS_2 else -1)


static func is_unlocked(id: String) -> bool:
	var season := season_of(id)
	return season == -1 or required_tier(id) <= progress(season).tier
