class_name Achievements
## Fifty achievements: forty-nine goals, measured on what the game already
## keeps (career stats, battle pass tiers, cards, story stars) and on a few
## feats ("flag"), each paying gems once; the fiftieth, Platine, for all the
## others, gives the Platine skin. check() is called on the home screen and at
## the end of a game: it pays what was just reached and returns it.
##
## "kind": "stat" (a career count of GameStats), "pass" (tiers of a season),
## "cards" (cards of the album), "expansion" (cards of Saison 2), "stars"
## (story stars), "flag" (a feat, see set_flag), "owned" (shop items owned),
## "all" (every other achievement).

const SAVE_KEY := "achievements_done"
const FLAGS_KEY := "achievement_flags"
const PLATINUM_SKIN := "skin_platinum"

const LIST: Array[Dictionary] = [
	{"id": "kills_1", "name": "Premier sang", "text": "Abats 100 ennemis", "kind": "stat", "stat": "kills", "goal": 100, "gems": 25},
	{"id": "kills_2", "name": "Nettoyeur", "text": "Abats 1 000 ennemis", "kind": "stat", "stat": "kills", "goal": 1000, "gems": 75},
	{"id": "kills_3", "name": "Fléau", "text": "Abats 5 000 ennemis", "kind": "stat", "stat": "kills", "goal": 5000, "gems": 150},
	{"id": "kills_4", "name": "Légende vivante", "text": "Abats 20 000 ennemis", "kind": "stat", "stat": "kills", "goal": 20000, "gems": 300},
	{"id": "head_1", "name": "Viseur", "text": "Touche 50 fois à la tête", "kind": "stat", "stat": "headshots", "goal": 50, "gems": 25},
	{"id": "head_2", "name": "Tireur d'élite", "text": "Touche 500 fois à la tête", "kind": "stat", "stat": "headshots", "goal": 500, "gems": 75},
	{"id": "head_3", "name": "Œil de faucon", "text": "Touche 2 000 fois à la tête", "kind": "stat", "stat": "headshots", "goal": 2000, "gems": 150},
	{"id": "melee_1", "name": "Au contact", "text": "Frappe 50 fois au corps à corps", "kind": "stat", "stat": "melee_hits", "goal": 50, "gems": 25},
	{"id": "melee_2", "name": "Lame affûtée", "text": "Frappe 500 fois au corps à corps", "kind": "stat", "stat": "melee_hits", "goal": 500, "gems": 75},
	{"id": "boss_1", "name": "Tueur de géants", "text": "Bats un boss", "kind": "stat", "stat": "bosses", "goal": 1, "gems": 25},
	{"id": "boss_2", "name": "Chasseur de boss", "text": "Bats 10 boss", "kind": "stat", "stat": "bosses", "goal": 10, "gems": 75},
	{"id": "boss_3", "name": "Plus grand qu'eux", "text": "Bats 50 boss", "kind": "stat", "stat": "bosses", "goal": 50, "gems": 150},
	{"id": "elite_1", "name": "Ça brille", "text": "Abats 10 ennemis d'élite", "kind": "stat", "stat": "elites", "goal": 10, "gems": 25},
	{"id": "elite_2", "name": "Collection dorée", "text": "Abats 100 ennemis d'élite", "kind": "stat", "stat": "elites", "goal": 100, "gems": 75},
	{"id": "waves_1", "name": "Ça tient", "text": "Termine 25 vagues", "kind": "stat", "stat": "waves", "goal": 25, "gems": 25},
	{"id": "waves_2", "name": "Marée humaine", "text": "Termine 250 vagues", "kind": "stat", "stat": "waves", "goal": 250, "gems": 75},
	{"id": "waves_3", "name": "Inébranlable", "text": "Termine 1 000 vagues", "kind": "stat", "stat": "waves", "goal": 1000, "gems": 150},
	{"id": "ulti_1", "name": "Ultime", "text": "Lance 10 ultis", "kind": "stat", "stat": "ultimates", "goal": 10, "gems": 25},
	{"id": "ulti_2", "name": "Surcharge", "text": "Lance 100 ultis", "kind": "stat", "stat": "ultimates", "goal": 100, "gems": 75},
	{"id": "games_1", "name": "Bienvenue", "text": "Joue ta première partie", "kind": "stat", "stat": "games", "goal": 1, "gems": 25},
	{"id": "games_2", "name": "Habitué", "text": "Joue 25 parties", "kind": "stat", "stat": "games", "goal": 25, "gems": 50},
	{"id": "games_3", "name": "Accro", "text": "Joue 100 parties", "kind": "stat", "stat": "games", "goal": 100, "gems": 150},
	{"id": "wave_10", "name": "Deux arènes", "text": "Atteins la vague 10", "kind": "stat", "stat": "best_wave", "goal": 10, "gems": 25},
	{"id": "wave_20", "name": "À mi-chemin", "text": "Atteins la vague 20", "kind": "stat", "stat": "best_wave", "goal": 20, "gems": 75},
	{"id": "wave_30", "name": "Devant le Titan", "text": "Atteins la vague 30", "kind": "stat", "stat": "best_wave", "goal": 30, "gems": 150},
	{"id": "wave_40", "name": "Sans fin", "text": "Atteins la vague 40", "kind": "stat", "stat": "best_wave", "goal": 40, "gems": 300},
	{"id": "crates_1", "name": "Livraison", "text": "Ramasse 10 caisses d'armes", "kind": "stat", "stat": "crates", "goal": 10, "gems": 25},
	{"id": "pass_1", "name": "En route", "text": "Atteins le palier 10 du passe saison 1", "kind": "pass", "season": 0, "goal": 10, "gems": 25},
	{"id": "pass_2", "name": "Vétéran", "text": "Atteins le palier 40 du passe saison 1", "kind": "pass", "season": 0, "goal": 40, "gems": 75},
	{"id": "pass_3", "name": "Passe complet", "text": "Termine le passe saison 1", "kind": "pass", "season": 0, "goal": -1, "gems": 300},
	{"id": "pass2_1", "name": "Accès", "text": "Atteins le palier 10 du passe saison 2", "kind": "pass", "season": 1, "goal": 10, "gems": 25},
	{"id": "pass2_2", "name": "Administrateur", "text": "Atteins le palier 35 du passe saison 2", "kind": "pass", "season": 1, "goal": 35, "gems": 75},
	{"id": "pass2_3", "name": "Programmé", "text": "Termine le passe saison 2", "kind": "pass", "season": 1, "goal": -1, "gems": 300},
	{"id": "cards_1", "name": "Collectionneur", "text": "Possède 25 cartes de l'album", "kind": "cards", "goal": 25, "gems": 25},
	{"id": "cards_2", "name": "Classeur bien rempli", "text": "Possède 50 cartes de l'album", "kind": "cards", "goal": 50, "gems": 75},
	{"id": "cards_3", "name": "Album complet", "text": "Possède les 99 cartes de l'album", "kind": "cards", "goal": 99, "gems": 300},
	{"id": "exp_1", "name": "Nouvelle saison", "text": "Possède 15 cartes de l'extension Saison 2", "kind": "expansion", "goal": 15, "gems": 50},
	{"id": "exp_2", "name": "Extension complète", "text": "Possède toutes les cartes de l'extension", "kind": "expansion", "goal": -1, "gems": 300},
	{"id": "stars_1", "name": "Lecteur", "text": "Gagne 15 étoiles en mode histoire", "kind": "stars", "goal": 15, "gems": 25},
	{"id": "stars_2", "name": "Fan de l'anime", "text": "Gagne 30 étoiles en mode histoire", "kind": "stars", "goal": 30, "gems": 75},
	{"id": "stars_3", "name": "Toutes les étoiles", "text": "Gagne les 60 étoiles du mode histoire", "kind": "stars", "goal": 60, "gems": 300},
	{"id": "champion", "name": "Champion", "text": "Bats le Titan au bout de la ville", "kind": "flag", "flag": "champion", "gems": 150},
	{"id": "virus", "name": "Antivirus", "text": "Bats le Virus sans perdre un point de vie", "kind": "flag", "flag": "virus_nodamage", "gems": 300},
	{"id": "christmas", "name": "Joyeux Noël", "text": "Termine les vagues de Noël", "kind": "flag", "flag": "christmas", "gems": 100},
	{"id": "arcade", "name": "Roi de l'arcade", "text": "Termine l'arcade du mode combat", "kind": "flag", "flag": "arcade", "gems": 150},
	{"id": "fight_hard", "name": "Sans pitié", "text": "Gagne un combat contre l'IA difficile", "kind": "flag", "flag": "fight_hard", "gems": 75},
	{"id": "race", "name": "Pilote", "text": "Gagne une course de vaisseaux", "kind": "flag", "flag": "race_win", "gems": 50},
	{"id": "capture", "name": "Territoire", "text": "Gagne une partie de capture de zone", "kind": "flag", "flag": "capture_win", "gems": 50},
	{"id": "shopper", "name": "Client fidèle", "text": "Achète 5 objets à la boutique", "kind": "owned", "goal": 5, "gems": 50},
	{"id": "platinum", "name": "Platine", "text": "Débloque les 49 autres succès", "kind": "all", "gems": 1000},
]


static func done() -> Array:
	return SaveData.load_progress(SAVE_KEY, [])


static func is_done(id: String) -> bool:
	return id in done()


static func done_count() -> int:
	return done().size()


## A feat happened (see LIST, kind "flag").
static func set_flag(name: String) -> void:
	var flags: Dictionary = SaveData.load_progress(FLAGS_KEY, {})
	flags[name] = true
	SaveData.save_progress(FLAGS_KEY, flags)


## [progress, goal] of an achievement.
static func progress(achievement: Dictionary) -> Array:
	var goal: int = achievement.get("goal", 1)
	match achievement.kind:
		"stat":
			return [int(GameStats.load_career().get(achievement.stat, 0)), goal]
		"pass":
			var size := BattlePass.rewards(achievement.season).size()
			return [BattlePass.progress(achievement.season).tier, size if goal < 0 else goal]
		"cards":
			return [Cards.owned_total(), goal]
		"expansion":
			return [Cards.expansion_owned(), Cards.EXPANSION.size() if goal < 0 else goal]
		"stars":
			return [Story.total_stars(), goal]
		"owned":
			return [Wallet.owned_count(), goal]
		"flag":
			return [1 if _flag(achievement.flag) else 0, 1]
		"all":
			return [done().filter(func(id: String) -> bool: return id != achievement.id).size(), LIST.size() - 1]
	return [0, 1]


static func _flag(name: String) -> bool:
	match name:
		"champion":
			return SaveData.load_progress(Loadout.CHAMPION_KEY, false)
		"christmas":
			return SaveData.load_progress(Events.CLEARED_KEY, "") != ""
		"arcade":
			return SaveData.load_progress(FightSetup.ARCADE_KEY, false)
	return SaveData.load_progress(FLAGS_KEY, {}).get(name, false)


## Pays the achievements just reached and returns them (the Platine last).
static func check() -> Array[Dictionary]:
	var list := done()
	var reached: Array[Dictionary] = []
	for achievement in LIST:
		if achievement.id in list:
			continue
		var state := progress(achievement)
		if state[0] >= state[1]:
			list.append(achievement.id)
			SaveData.save_progress(SAVE_KEY, list)
			Wallet.add_gems(achievement.gems)
			reached.append(achievement)
	return reached
