class_name SurvivalSave
## The survival world on the device (SaveData, key SAVE_KEY): the seed and
## the difficulty, the day and the clock, the hero (where, hunger, thirst,
## life, inventory, bar), the bed, what was built (chests with their
## content, the backpack), what was harvested, and the stats. One world at a
## time: a new world replaces it.

const SAVE_KEY := "survival_world"
const SKIN_ID := "skin_survivor"
const SKIN_DAYS := 10

## Set by the menu before the scene: start a new world with these.
static var fresh := false
static var new_seed := 1
static var new_difficulty := 1
## Where the hero was, read by SurvivalGame when it starts.
static var player_at := Vector3.INF
## The days already paid for (rewards are for the days survived since).
const PAID_KEY := "survival_paid_day"


static func exists() -> bool:
	return not SaveData.load_progress(SAVE_KEY, {}).is_empty()


static func summary() -> String:
	var save: Dictionary = SaveData.load_progress(SAVE_KEY, {})
	if save.is_empty():
		return ""
	return "Jour %d · %s · graine %d" % [int(save.get("day", 1)), SurvivalGame.DIFFICULTIES[int(save.get("difficulty", 1))], int(save.get("seed", 0))]


static func load_world() -> Dictionary:
	player_at = Vector3.INF
	return SaveData.load_progress(SAVE_KEY, {})


static func start_new(world_seed: int, difficulty: int) -> void:
	fresh = true
	new_seed = world_seed
	new_difficulty = difficulty
	SaveData.save_progress(SAVE_KEY, {})
	SaveData.save_progress(PAID_KEY, 0)


static func _vector(values: Variant) -> Vector3:
	if values is Array and (values as Array).size() == 3:
		return Vector3(values[0], values[1], values[2])
	return Vector3.INF


static func _array(at: Vector3) -> Array:
	return [] if at == Vector3.INF else [at.x, at.y, at.z]


## Puts a saved world into the game, before it builds the world.
static func apply(game: SurvivalGame, save: Dictionary) -> void:
	game.world_seed = int(save.get("seed", 1))
	game.difficulty = int(save.get("difficulty", 1))
	game.day = int(save.get("day", 1))
	game.clock = float(save.get("clock", 90.0))
	game.food = float(save.get("food", 100.0))
	game.water = float(save.get("water", 100.0))
	game.inventory = save.get("inventory", {})
	for item: String in game.inventory.keys():
		game.inventory[item] = int(game.inventory[item])
	game.hotbar = save.get("hotbar", ["", "", "", "", "", ""])
	game.selected = int(save.get("selected", 0))
	game.spawn_point = _vector(save.get("spawn", []))
	game.bed_point = _vector(save.get("bed", []))
	game.stats.merge(save.get("stats", {}), true)
	game.world.harvested = save.get("harvested", {})
	player_at = _vector(save.get("player", []))
	if save.has("health"):
		game.set_meta("health", int(save.health))


## Builds the saved pieces again (after the world, so they stand on it).
static func restore_pieces(game: SurvivalGame, save: Dictionary) -> void:
	for data: Dictionary in save.get("pieces", []):
		var type: String = data.get("type", "floor")
		var backpack := type == "backpack"
		var piece := game.spawn_piece("chest" if backpack else type, data.get("material", "wood"),
				Vector3(data.x, data.y, data.z), float(data.get("r", 0.0)))
		piece.hp = int(data.get("hp", piece.max_hp))
		var content: Dictionary = data.get("content", {})
		for item: String in content:
			piece.content[item] = int(content[item])
		if backpack:
			piece.type = "backpack"
	if game.has_meta("health"):
		game.player.health = clampi(int(game.get_meta("health")), 1, game.player.max_health)


static func save_world(game: SurvivalGame) -> void:
	var pieces := []
	for piece: SurvivalPiece in game.get_tree().get_nodes_in_group("survival_pieces"):
		if is_instance_valid(piece) and not piece.is_queued_for_deletion():
			pieces.append(piece.to_dict())
	SaveData.save_progress(SAVE_KEY, {
		"seed": game.world_seed, "difficulty": game.difficulty, "day": game.day, "clock": game.clock,
		"food": game.food, "water": game.water, "health": game.player.health,
		"inventory": game.inventory, "hotbar": game.hotbar, "selected": game.selected,
		"spawn": _array(game.spawn_point), "bed": _array(game.bed_point),
		"player": _array(game.player.global_position if game.player.health > 0 else game.spawn_point),
		"pieces": pieces, "harvested": game.world.harvested, "stats": game.stats,
	})


## Leaving: the rewards for the days survived since the last time (XP,
## credits, gems), the creatures, and the Survivant skin at SKIN_DAYS.
static func pay_session(game: SurvivalGame) -> Dictionary:
	var paid: int = SaveData.load_progress(PAID_KEY, 0)
	var new_days := maxi(game.day - 1 - paid, 0)
	SaveData.save_progress(PAID_KEY, maxi(game.day - 1, paid))
	var kills_paid: int = int(game.stats.get("kills_paid", 0))
	var new_kills := maxi(int(game.stats.kills) - kills_paid, 0)
	game.stats["kills_paid"] = int(game.stats.kills)
	var xp := new_days * 500 + new_kills * 40 + 100
	var credits := new_days * 300 + new_kills * 20
	var gems := new_days * 8
	var unlocked := []
	for id in BattlePass.add_xp(xp):
		unlocked.append(Loadout.find(id).item.name)
	Wallet.add_credits(credits)
	Wallet.add_gems(gems)
	if game.day > SKIN_DAYS and Wallet.give(SKIN_ID):
		unlocked.append("skin Survivant")
	var career := GameStats.load_career()
	career["survival_days"] = maxi(int(career.get("survival_days", 0)), game.day - 1)
	career["survival_best_built"] = maxi(int(career.get("survival_best_built", 0)), int(game.stats.built))
	career["kills"] = int(career.get("kills", 0)) + new_kills
	SaveData.save_progress(GameStats.CAREER_KEY, career)
	Weekly.record({"kills": new_kills, "survival_days": new_days, "crafted": int(game.stats.crafted)})
	for achievement in Achievements.check():
		unlocked.append("succès %s" % achievement.name)
	return {"xp": xp, "credits": credits, "gems": gems, "unlocked": unlocked}
