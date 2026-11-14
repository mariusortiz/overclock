class_name Story
## The story mode: the anime's seasons, one chapter per episode (season 1:
## chapters 1 to 10, season 2: 11 to 20, season 3: 21 to 30, season 4: 31 to
## 40, the anime's episodes 32 to 41). A chapter is a short scene played
## by the engine (scripts/story/chNN.gd), then a mission in one of the game's
## modes with the episode's hero. A mission gives 1 to 3 stars; the first win
## pays the chapter's rewards, the last chapter of a season a bigger prize.
## Each season opens at its first chapter. In season 2 the enemies are
## corrupted by the Virus ("virus"). A wave mission starts as if the player
## had come through `level` arenas (by default its own arena's place), and
## `boss` picks its boss (by default the arena's).

const SCREEN := "res://scenes/story.tscn"
const CUTSCENE := "res://scenes/story_cutscene.tscn"
const SCENES := {"waves": "res://scenes/main.tscn", "race": "res://scenes/race.tscn", "capture": "res://scenes/capture.tscn"}
const STARS_KEY := "story_stars"
const FINAL_SHIP := "ship_scarlet"
const FINAL_GEMS := 500
const SEASON_SIZE := 10
const SEASON_2_FINAL_GEMS := 1000
const SEASON_3_FINAL_GEMS := 1500
const SEASON_4_FINAL_GEMS := 2000

## Each chapter: title, hero (Loadout id), mode, arena or circuit, what to
## do, and the line that closes it. A race is won in the first `place`;
## `ship` is the ship flown (the Dard by default).
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
	{"title": "Alliance", "hero": "godfather", "mode": "capture", "arena": 6,
		"goal": "Entraînement commun : l'escouade et l'Écarlate côte à côte. Tiens les zones de la ville.",
		"outro": "La Paladine d'or et le Parrain sont de la partie. Cap sur le volcan."},
	{"title": "Le volcan", "hero": "soldier", "mode": "waves", "arena": 3,
		"goal": "Infiltre la base du volcan : ses gardes, puis son dragon.",
		"outro": "Trop tard : le Titan Mk II sort de la lave."},
	{"title": "Titan Mk II", "hero": "soldier", "mode": "race", "circuit": 3, "place": 3,
		"goal": "La flotte attaque le Titan depuis le ciel. Termine dans les 3 premiers.",
		"outro": "Le bouclier du Titan tient bon. Il faudra tout le monde."},
	{"title": "Overclock", "hero": "soldier", "mode": "waves", "arena": 6,
		"goal": "La ville, le Titan Mk II, tous les héros : c'est la fin.",
		"outro": "Le Titan tombe. Le Directeur est arrêté. Fin de la saison 1."},
	# Season 2: Le Créateur.
	{"title": "Le glitch", "hero": "soldier", "mode": "waves", "arena": 6, "virus": true,
		"goal": "La ville se déchire. Les ennemis reviennent, corrompus : tiens jusqu'à leur boss.",
		"outro": "Sur un toit, un homme à tête de vache regarde… et disparaît dans un grésillement."},
	{"title": "Le message", "hero": "kunoichi", "mode": "waves", "arena": 0, "virus": true,
		"goal": "Les écrans de la station se remplissent de code. Repousse les gardes corrompus.",
		"outro": "Sur l'écran, un message : « Ne le laissez pas grandir. — C. »"},
	{"title": "La course corrompue", "hero": "soldier", "mode": "race", "circuit": 2, "place": 3, "ship": "ship_scarlet",
		"goal": "Le circuit se déchire, des vaisseaux noirs attaquent. Termine dans les 3 premiers.",
		"outro": "Un vaisseau vert que personne ne connaît t'a ouvert la voie, puis s'est effacé."},
	{"title": "Le Virus", "hero": "cowgirl", "mode": "waves", "arena": 1, "virus": true,
		"goal": "Le Virus prend corps dans le désert. Tiens bon jusqu'à son gardien.",
		"outro": "Sur une dune, Le Créateur : « Vous ne pouvez pas le battre. Pas encore. »"},
	{"title": "Le Créateur", "hero": "captain", "mode": "capture", "arena": 0,
		"goal": "Le Créateur veut voir l'escouade à l'œuvre. Tiens les zones de la station.",
		"outro": "« J'ai écrit ce monde. Trois fragments du code source peuvent le réparer. »"},
	{"title": "Code source", "hero": "ronin", "mode": "waves", "arena": 2, "virus": true,
		"goal": "Le premier fragment est dans la jungle, gardé par des monstres corrompus.",
		"outro": "Premier fragment. Le Créateur montre ce que veut dire « accès root »."},
	{"title": "Mise à jour", "hero": "paladin", "mode": "waves", "arena": 3, "virus": true,
		"goal": "Le Directeur est revenu, pris par le Virus. Traverse le volcan jusqu'à son dragon.",
		"outro": "Le Créateur libère le Directeur. Deuxième fragment."},
	{"title": "Écran noir", "hero": "sand_ghost", "mode": "waves", "arena": 0, "virus": true,
		"goal": "Le dernier fragment, à la station. Le Virus frappe : survis, seul s'il le faut.",
		"outro": "Les héros s'effacent un à un. Le Créateur tombe. Il ne reste que le Soldat et Vipère."},
	{"title": "Ctrl+Z", "hero": "soldier", "mode": "race", "circuit": 4, "place": 2, "ship": "ship_scarlet",
		"goal": "La flotte se rassemble au-dessus de la ville. Termine 2e ou mieux.",
		"outro": "Le Créateur n'était pas effacé, seulement dispersé. Il annule, une fois. L'escouade revient."},
	{"title": "Redémarrage", "hero": "soldier", "mode": "waves", "arena": 6, "virus": true,
		"goal": "La dernière bataille : la ville, le Virus, tous les héros, les trois fragments.",
		"outro": "Le Virus est effacé, le monde redémarre. Le Créateur dit au revoir. Fin de la saison 2."},
	# Season 3: Le Portail.
	{"title": "Le Portail", "hero": "soldier", "mode": "capture", "arena": 0,
		"goal": "Un anneau de lumière s'ouvre sur la station, des créatures en sortent. Tiens les zones.",
		"outro": "L'anneau aspire l'escouade. Le Créateur saute derrière eux. Trois lunes dans le ciel."},
	{"title": "Terre inconnue", "hero": "cowgirl", "mode": "waves", "arena": 5, "level": 2, "boss": Boss.Kind.SUMMONER,
		"goal": "La planète de cristal. Les sentinelles se lèvent : tiens jusqu'à leur reine.",
		"outro": "Ici, Le Créateur n'est qu'une vache. Et les cristaux chantent."},
	{"title": "Le Chant des cristaux", "hero": "ronin", "mode": "capture", "arena": 5,
		"goal": "Trois cristaux, trois notes. Tiens les zones A, B et C pour jouer la mélodie.",
		"outro": "La mélodie juste. Une carte des étoiles s'allume : des ruines, au-delà d'une ceinture."},
	{"title": "La Ceinture", "hero": "sand_ghost", "mode": "race", "circuit": 2, "place": 2, "ship": "ship_scarlet",
		"goal": "Des drones de cristal dans la ceinture. Termine 2e ou mieux.",
		"outro": "Vipère fait demi-tour en pleine ceinture. Les drones tombent. Les ruines approchent."},
	{"title": "Les Ruines stellaires", "hero": "kunoichi", "mode": "waves", "arena": 7, "level": 3, "boss": Boss.Kind.BRUTE,
		"goal": "Des pillards fouillent les ruines. Repousse-les jusqu'au golem qui s'éveille.",
		"outro": "Sur l'arche, une statue d'or : une tête de vache. « Le Premier Codeur. »"},
	{"title": "L'Archive", "hero": "paladin", "mode": "waves", "arena": 7, "level": 4, "boss": Boss.Kind.BRUTE,
		"goal": "Les gardiens de l'archive se réveillent. Tiens jusqu'au dernier golem.",
		"outro": "Version 0. Le Créateur est une copie. « Copie ou pas, t'es notre vache. »"},
	{"title": "La Lune qui boucle", "hero": "sand_ghost", "mode": "waves", "arena": 1, "level": 3, "boss": Boss.Kind.ARTILLERY,
		"goal": "Les météores tombent en boucle. Survis jusqu'à briser la boucle.",
		"outro": "Un seul tir, et la boucle se brise. Trois silhouettes reprennent vie : l'Écarlate."},
	{"title": "Écarlate", "hero": "witch", "mode": "capture", "arena": 1,
		"goal": "Les deux escouades ensemble, pour la première fois. Tiens les zones.",
		"outro": "Hex avait la clé. Un rayon d'or montre le cœur de la galaxie. « Venez. »"},
	{"title": "Le Gardien", "hero": "soldier", "mode": "waves", "arena": 5,
		"goal": "Le cœur de la galaxie. Traverse la planète de cristal jusqu'au Gardien.",
		"outro": "Le Gardien pose un genou à terre. « Qui a créé le Créateur ? »"},
	{"title": "Retour", "hero": "sand_ghost", "mode": "race", "circuit": 0, "place": 1, "ship": "ship_scarlet",
		"goal": "Rentrés à la station, Vipère réclame sa revanche promise. Gagne la course.",
		"outro": "Personne ne crée seul. Le code est revenu, la revanche est gagnée. Fin de la saison 3."},
	# Season 4: Les Miroirs. "mirror": the enemies glow violet, come from the
	# mirror world.
	{"title": "Le Reflet", "hero": "soldier", "mode": "capture", "arena": 0,
		"goal": "Des doubles sortent d'un miroir, à la station. Tiens les zones.",
		"outro": "Le reflet du Soldat sort du verre et s'enfuit. « Celui-là avait une ombre. »"},
	{"title": "Les Doubles", "hero": "kunoichi", "mode": "waves", "arena": 1, "level": 2, "boss": Boss.Kind.BRUTE, "mirror": true,
		"goal": "Les doubles sabotent le temple du désert. Repousse-les jusqu'à leur colosse.",
		"outro": "Les doubles se brisent comme du verre. Dans un éclat, une ville à l'envers."},
	{"title": "Sans double", "hero": "sand_ghost", "mode": "race", "circuit": 1, "place": 2, "ship": "ship_scarlet",
		"goal": "Le capybara a filé à travers le miroir. Rattrape-le : termine 2e ou mieux.",
		"outro": "Il revient avec une deuxième mandarine. Ce que Le Créateur n'a pas écrit passe sans changer."},
	{"title": "De l'autre côté", "hero": "ronin", "mode": "waves", "arena": 11, "level": 3, "boss": Boss.Kind.SUMMONER, "mirror": true,
		"goal": "Le monde-miroir. Ses gardiens ne veulent pas de visiteurs : tiens jusqu'à leur reine.",
		"outro": "La même ville, à l'envers. Ici, personne n'a jamais écrit de jeu."},
	{"title": "Le monde sans code", "hero": "captain", "mode": "capture", "arena": 8,
		"goal": "Protège le Créateur d'en face pendant qu'il parle. Tiens les zones de la ville-miroir.",
		"outro": "Un Créateur qui fait pousser des fleurs. « Le Reflet veut votre monde. »"},
	{"title": "Échange", "hero": "witch", "mode": "capture", "arena": 8,
		"goal": "Les doubles de l'Écarlate sont de votre côté. Reprenez les rues au Reflet.",
		"outro": "Les ennemis deviennent des alliés. Le Reflet est dans la tour."},
	{"title": "Le Reflet", "hero": "soldier", "mode": "waves", "arena": 11, "level": 4, "boss": Boss.Kind.REFLECT, "mirror": true,
		"goal": "Le sommet de la tour. Le Reflet copie ton arme : bats-le avec la tienne.",
		"outro": "Il copie ce qu'il voit. Il faudra lui montrer tout le monde à la fois."},
	{"title": "Le Miroir-Titan", "hero": "paladin", "mode": "race", "circuit": 3, "place": 2,
		"goal": "Le Reflet devient Titan. La flotte attaque ensemble : termine 2e ou mieux.",
		"outro": "Sept attaques à la fois. Le Miroir-Titan éclate, et les deux mondes se touchent."},
	{"title": "Fusion", "hero": "cowgirl", "mode": "waves", "arena": 6, "level": 5, "boss": Boss.Kind.TITAN, "mirror": true,
		"goal": "La ville est à moitié à l'envers. Tiens jusqu'au Titan des deux mondes.",
		"outro": "L'autre Créateur traverse. « Ensemble, ils seraient complets. »"},
	{"title": "Les Miroirs", "hero": "soldier", "mode": "waves", "arena": 11, "level": 6, "boss": Boss.Kind.REFLECT, "mirror": true,
		"goal": "Le dernier combat, héros et doubles côte à côte. Bats le Reflet pour de bon.",
		"outro": "Le Reflet vole en éclats, les mondes fusionnent. Fin de la saison 4."},
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


static func seasons() -> int:
	return CHAPTERS.size() / SEASON_SIZE


## The season of chapter `index`, from 0.
static func season_of(index: int) -> int:
	return index / SEASON_SIZE


## The stars of a season, out of SEASON_SIZE * 3.
static func season_stars(season: int) -> int:
	var total := 0
	for index in range(season * SEASON_SIZE, (season + 1) * SEASON_SIZE):
		total += stars_of(index)
	return total


static func total_stars() -> int:
	var total := 0
	for index in CHAPTERS.size():
		total += stars_of(index)
	return total


## A season's first chapter is always open; the others once the one before is won.
static func is_open(index: int) -> bool:
	return index % SEASON_SIZE == 0 or stars_of(index - 1) > 0


## Is the last chapter of `season` won? (Season 1 gives the Écarlate ship.)
static func season_done(season := 0) -> bool:
	return stars_of((season + 1) * SEASON_SIZE - 1) > 0


static func is_final(index: int) -> bool:
	return index % SEASON_SIZE == SEASON_SIZE - 1


## Starts chapter `index`: its scene, then its mission with its hero.
static func begin(index: int) -> void:
	chapter = index
	last_result = {}
	var info: Dictionary = CHAPTERS[index]
	Loadout.story_hero = info.hero
	Loadout.story_weapon = AnimeDirector.GUNS.get(info.hero, "heavy")
	Loadout.story_ship = info.get("ship", "ship_dart")


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


## A chapter's first win: gems and a rare booster, plus the episode's card
## when it has one. The last chapter
## of season 1 adds gems and the Écarlate ship, that of season 2 gems and a
## legendary booster.
static func _pay(index: int) -> Array[String]:
	var gems := gems_for(index)
	Wallet.add_gems(gems)
	Cards.give_booster("rare")
	var given: Array[String] = ["%d gemmes" % gems, "1 booster rare"]
	var card_id := "card_ep%02d" % episode_of(index)
	if not Cards.find(card_id).is_empty():
		Cards.add(card_id)
		given.append("la carte %s" % Cards.find(card_id).name)
	if index == SEASON_SIZE - 1:
		Wallet.add_gems(FINAL_GEMS)
		given.append("%d gemmes de plus" % FINAL_GEMS)
		given.append("le vaisseau Écarlate")
	elif index == 2 * SEASON_SIZE - 1:
		Wallet.add_gems(SEASON_2_FINAL_GEMS)
		Cards.give_booster("legend")
		given.append("%d gemmes de plus" % SEASON_2_FINAL_GEMS)
		given.append("1 booster légendaire")
	elif index == 3 * SEASON_SIZE - 1:
		Wallet.add_gems(SEASON_3_FINAL_GEMS)
		Cards.give_booster("legend")
		given.append("%d gemmes de plus" % SEASON_3_FINAL_GEMS)
		given.append("1 booster légendaire")
	elif index == 4 * SEASON_SIZE - 1:
		Wallet.add_gems(SEASON_4_FINAL_GEMS)
		Cards.give_booster("legend")
		given.append("%d gemmes de plus" % SEASON_4_FINAL_GEMS)
		given.append("1 booster légendaire")
	return given


## The anime episode of chapter `index` (the episode 31 is a special without
## a chapter: season 4's chapters are its episodes 32 to 41).
static func episode_of(index: int) -> int:
	return index + 1 if index < 3 * SEASON_SIZE else index + 2


static func gems_for(index: int) -> int:
	return 100 + 20 * (index % SEASON_SIZE) + 50 * season_of(index)


## What a first win of chapter `index` gives, for the story screen.
static func rewards_text(index: int) -> String:
	var parts := ["%d gemmes" % gems_for(index), "un booster rare"]
	if not Cards.find("card_ep%02d" % episode_of(index)).is_empty():
		parts.append("la carte de l'épisode")
	if index == SEASON_SIZE - 1:
		parts.append("le vaisseau Écarlate")
	elif index == 2 * SEASON_SIZE - 1:
		parts.append("%d gemmes de plus et un booster légendaire" % SEASON_2_FINAL_GEMS)
	elif index == 3 * SEASON_SIZE - 1:
		parts.append("%d gemmes de plus et un booster légendaire" % SEASON_3_FINAL_GEMS)
	elif index == 4 * SEASON_SIZE - 1:
		parts.append("%d gemmes de plus et un booster légendaire" % SEASON_4_FINAL_GEMS)
	return ", ".join(parts)


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
