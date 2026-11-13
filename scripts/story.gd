class_name Story
## The story mode: season 1 of the anime, one chapter per episode. A chapter
## is a short scene played by the engine (scripts/story/chNN.gd), then a
## mission in one of the game's modes with the episode's hero. A mission
## gives 1 to 3 stars; the first win pays the chapter's rewards, the last
## chapter the Écarlate ship as well.

const SCREEN := "res://scenes/story.tscn"
const CUTSCENE := "res://scenes/story_cutscene.tscn"
const SCENES := {"waves": "res://scenes/main.tscn", "race": "res://scenes/race.tscn", "capture": "res://scenes/capture.tscn"}
const STARS_KEY := "story_stars"
const FINAL_SHIP := "ship_scarlet"
const FINAL_GEMS := 500

## Each chapter: title, hero (Loadout id), mode, arena or circuit, what to
## do, and the line that closes it. A race is won in the first `place`.
const CHAPTERS := [
	{"title": "L'escouade", "hero": "soldier", "mode": "waves", "arena": 0,
		"goal": "Tiens la station : 5 vagues de gardes, puis leur boss.",
		"outro": "« Je travaille seul. » « Plus maintenant. » L'escouade est née."},
	{"title": "Le défi", "hero": "soldier", "mode": "race", "circuit": 0, "place": 3,
		"goal": "Vipère te met au défi. Termine la course dans les 3 premiers.",
		"outro": "« Pas mal, pour un fantassin. Demain, à l'aube : la vraie course. »"},
	{"title": "La course", "hero": "soldier", "mode": "race", "circuit": 2, "place": 2,
		"goal": "La vraie course, dans les astéroïdes. Termine 2e ou mieux.",
		"outro": "Vipère gagne d'un nez. « La prochaine fois, je ne te laisse pas d'avance. »"},
	{"title": "L'Escouade Écarlate", "hero": "kunoichi", "mode": "capture", "arena": 0,
		"goal": "Escouade contre escouade : prends les zones de la station.",
		"outro": "Sur un garde, la Kunoichi trouve un badge. Vipère pâlit : « Le Directeur. »"},
	{"title": "Le désert des secrets", "hero": "cowgirl", "mode": "waves", "arena": 1,
		"goal": "Calamity connaît le chemin du temple. Traverse le désert et abats son gardien.",
		"outro": "Dans le temple, un hologramme du Directeur… et les plans d'un second Titan."},
	{"title": "Duel dans la jungle", "hero": "ronin", "mode": "waves", "arena": 2,
		"goal": "Les monstres du Directeur encerclent la jungle. Survis jusqu'au boss.",
		"outro": "Dos à dos avec le Ronin, Vipère a choisi son camp."},
	{"title": "Alliance", "hero": "godfather", "mode": "capture", "arena": 4,
		"goal": "Entraînement commun : l'escouade et l'Écarlate côte à côte. Tiens les zones de la ville.",
		"outro": "La Paladine d'or et le Parrain sont de la partie. Cap sur le volcan."},
	{"title": "Le volcan", "hero": "soldier", "mode": "waves", "arena": 3,
		"goal": "Infiltre la base du volcan : ses gardes, puis son dragon.",
		"outro": "Trop tard : le Titan Mk II sort de la lave."},
	{"title": "Titan Mk II", "hero": "soldier", "mode": "race", "circuit": 3, "place": 3,
		"goal": "La flotte attaque le Titan depuis le ciel. Termine dans les 3 premiers.",
		"outro": "Le bouclier du Titan tient bon. Il faudra tout le monde."},
	{"title": "Overclock", "hero": "soldier", "mode": "waves", "arena": 4,
		"goal": "La ville, le Titan Mk II, tous les héros : c'est la fin.",
		"outro": "Le Titan tombe. Le Directeur est arrêté. Fin de la saison 1."},
]

## The chapter being played (-1: none), and the result of the last mission
## for the story screen: {"chapter", "won", "stars", "rewards"}.
static var chapter := -1
static var last_result := {}


static func is_active() -> bool:
	return chapter >= 0


static func mission() -> Dictionary:
	return CHAPTERS[chapter] if is_active() else {}


static func stars() -> Dictionary:
	return SaveData.load_progress(STARS_KEY, {})


static func stars_of(index: int) -> int:
	return int(stars().get(str(index), 0))


static func total_stars() -> int:
	var total := 0
	for index in CHAPTERS.size():
		total += stars_of(index)
	return total


static func is_open(index: int) -> bool:
	return index == 0 or stars_of(index - 1) > 0


static func season_done() -> bool:
	return stars_of(CHAPTERS.size() - 1) > 0


## Starts chapter `index`: its scene, then its mission with its hero.
static func begin(index: int) -> void:
	chapter = index
	last_result = {}
	var info: Dictionary = CHAPTERS[index]
	Loadout.story_hero = info.hero
	Loadout.story_weapon = AnimeDirector.GUNS.get(info.hero, "heavy")
	Loadout.story_ship = "ship_dart"


## The game's own loadout again (the story screen and the menu call it).
static func leave() -> void:
	chapter = -1
	Loadout.story_hero = ""
	Loadout.story_weapon = ""
	Loadout.story_ship = ""


static func mission_scene() -> String:
	return SCENES[mission().mode]


## The mission is over: keeps the best stars, pays a first win, and leaves
## the result for the story screen.
static func finish(won: bool, earned_stars: int) -> void:
	var rewards: Array[String] = []
	if won:
		var all := stars()
		var key := str(chapter)
		var first := int(all.get(key, 0)) == 0
		all[key] = maxi(int(all.get(key, 0)), clampi(earned_stars, 1, 3))
		SaveData.save_progress(STARS_KEY, all)
		if first:
			rewards = _pay(chapter)
	last_result = {"chapter": chapter, "won": won, "stars": clampi(earned_stars, 1, 3) if won else 0, "rewards": rewards}


## A chapter's first win: gems, a rare booster and the episode's card; the
## last one, the Écarlate ship too.
static func _pay(index: int) -> Array[String]:
	var gems := 100 + 20 * index
	Wallet.add_gems(gems)
	Cards.give_booster("rare")
	var card_id := "card_ep%02d" % (index + 1)
	Cards.add(card_id)
	var given: Array[String] = ["%d gemmes" % gems, "1 booster rare", "la carte %s" % Cards.find(card_id).name]
	if index == CHAPTERS.size() - 1:
		Wallet.add_gems(FINAL_GEMS)
		given.append("%d gemmes de plus" % FINAL_GEMS)
		given.append("le vaisseau Écarlate")
	return given


## Stars for a wave mission: health left when the boss falls.
static func stars_for_health(ratio: float) -> int:
	return 3 if ratio >= 0.8 else (2 if ratio >= 0.5 else 1)


## Stars for a race: 3 for a win, 2 for second, 1 otherwise.
static func stars_for_place(place: int) -> int:
	return 3 if place == 0 else (2 if place == 1 else 1)


## Stars for a capture: the fewer points the other side scored, the better.
static func stars_for_capture(enemy_points: int, win_score: int) -> int:
	var share := float(enemy_points) / float(win_score)
	return 3 if share < 0.4 else (2 if share < 0.7 else 1)
