class_name FightSetup
## What the next fight is: set by the fight menu (or the Wi-Fi lobby) before
## opening scenes/fight.tscn, and kept between the fights of the arcade.
##
## Modes: "ai" (one fight against the computer), "versus" (two players on
## one device), "arcade" (a run of fights against the computer, the Titan
## last), "online" (two devices on the Wi-Fi, see Net).

const SCENE := "res://scenes/fight.tscn"
const MENU := "res://scenes/fight_menu.tscn"
const ARENA_NAMES := ["Station", "Désert", "Jungle", "Volcan", "Ville"]
## Heroes met in the arcade before the Titan.
const ARCADE_FIGHTS := 5
const ARCADE_KEY := "fight_arcade_cleared"
const ARCADE_GEMS := 300
const WIN_CREDITS := [20, 40, 70]

static var mode := "ai"
## Loadout hero ids of the two fighters (player 1 on the left).
static var heroes: Array[String] = ["soldier", "ninja"]
## Arena index, or -1 for one at random.
static var arena := -1
## 0 easy, 1 normal, 2 hard.
static var difficulty := 1
## The arcade run: its opponents (hero ids, then "titan") and how far it is.
static var arcade_opponents: Array[String] = []
static var arcade_stage := 0


static func is_arcade() -> bool:
	return mode == "arcade"


## The heroes the computer can play: every hero but Le Créateur.
static func computer_heroes() -> Array[String]:
	var ids: Array[String] = []
	for item: Dictionary in Loadout.CHARACTERS:
		if not item.get("code", false):
			ids.append(item.id)
	return ids


## A new arcade run for `hero`: five other heroes at random, then the Titan.
static func start_arcade(hero: String) -> void:
	mode = "arcade"
	var pool := computer_heroes().filter(func(id: String) -> bool: return id != hero)
	pool.shuffle()
	arcade_opponents.assign(pool.slice(0, ARCADE_FIGHTS))
	arcade_opponents.append("titan")
	arcade_stage = 0
	heroes = [hero, arcade_opponents[0]]
	difficulty = 1


## The next arcade fight after a win; false when the run is over.
static func next_arcade_fight() -> bool:
	arcade_stage += 1
	if arcade_stage >= arcade_opponents.size():
		return false
	heroes[1] = arcade_opponents[arcade_stage]
	# Harder as it goes: normal, then hard for the last two and the Titan.
	difficulty = 2 if arcade_stage >= arcade_opponents.size() - 3 else 1
	return true


static func arcade_arena() -> int:
	# The Titan waits in the city.
	if arcade_opponents[arcade_stage] == "titan":
		return 4
	return arcade_stage % ARENA_NAMES.size()


static func hero_item(id: String) -> Dictionary:
	if id == "titan":
		return Fighter.TITAN
	var item: Dictionary = Loadout.find(id).item
	return Loadout.fair(item) if mode == "online" else item


## Pays a win: credits against the computer, and the first full arcade run
## gems and a rare booster. Returns what was given, to show.
static func reward(won: bool, run_over := false) -> String:
	if not won or mode in ["versus", "online"]:
		return ""
	if is_arcade() and run_over:
		if not SaveData.load_progress(ARCADE_KEY, false):
			SaveData.save_progress(ARCADE_KEY, true)
			Wallet.add_gems(ARCADE_GEMS)
			Cards.give_booster("rare")
			return "%d gemmes et un booster rare" % ARCADE_GEMS
		Wallet.add_credits(150)
		return "150 crédits"
	var credits: int = WIN_CREDITS[difficulty]
	Wallet.add_credits(credits)
	return "%d crédits" % credits
