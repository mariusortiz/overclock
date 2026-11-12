class_name Cards
## Collectible cards: one per hero, enemy, boss, ship, weapon, arena and
## anime episode, in five rarities. They come in boosters (end of a game,
## shop, every fifth battle pass tier, all the day's challenges done).
## Duplicates are recycled into dust, which crafts the missing ones; a
## completed series pays credits and gems, the whole album a skin.
## Card art: assets/cards/<id>.jpg (see tools/make_card_art.gd).

enum Rarity { COMMON, RARE, EPIC, LEGENDARY, MYTHIC }

const RARITY := {
	Rarity.COMMON: {"name": "Commune", "color": Color(0.75, 0.78, 0.85), "weight": 60.0, "dust": 5, "craft": 40},
	Rarity.RARE: {"name": "Rare", "color": Color(0.25, 0.6, 1.0), "weight": 25.0, "dust": 20, "craft": 160},
	Rarity.EPIC: {"name": "Épique", "color": Color(0.75, 0.35, 1.0), "weight": 10.0, "dust": 50, "craft": 400},
	Rarity.LEGENDARY: {"name": "Légendaire", "color": Color(1.0, 0.75, 0.2), "weight": 4.0, "dust": 150, "craft": 1200},
	Rarity.MYTHIC: {"name": "Mythique", "color": Color(1.0, 0.25, 0.6), "weight": 1.0, "dust": 500, "craft": 4000},
}
const ART_DIR := "res://assets/cards/"
const CARDS_PER_BOOSTER := 3
## A score worth a second booster.
const BIG_SCORE := 8000

## Series, in album order: [name, reward credits, reward gems].
const SERIES := [
	["Héros", 3000, 100], ["Ennemis", 1500, 50], ["Boss", 2000, 80], ["Vaisseaux", 2000, 80],
	["Armes", 2000, 80], ["Mêlée", 1200, 40], ["Arènes", 1200, 40], ["Anime", 2500, 100], ["Mythiques", 5000, 250],
]

## Every card: id, name, series, rarity, and what its art shows ("art": a
## kind of subject and a reference, read by tools/make_card_art.gd).
const C := Rarity.COMMON
const R := Rarity.RARE
const E := Rarity.EPIC
const L := Rarity.LEGENDARY
const M := Rarity.MYTHIC
const CATALOG := [
	# Heroes.
	{"id": "card_soldier", "name": "Soldat", "series": "Héros", "rarity": C, "art": ["hero", "soldier"]},
	{"id": "card_cowboy", "name": "Cow-boy", "series": "Héros", "rarity": C, "art": ["hero", "cowboy"]},
	{"id": "card_soldier_female", "name": "Soldate", "series": "Héros", "rarity": C, "art": ["hero", "soldier_female"]},
	{"id": "card_ninja", "name": "Ninja", "series": "Héros", "rarity": R, "art": ["hero", "ninja"]},
	{"id": "card_pirate", "name": "Pirate", "series": "Héros", "rarity": R, "art": ["hero", "pirate"]},
	{"id": "card_knight", "name": "Chevalier", "series": "Héros", "rarity": R, "art": ["hero", "knight"]},
	{"id": "card_kimono", "name": "Samouraï", "series": "Héros", "rarity": R, "art": ["hero", "kimono"]},
	{"id": "card_viking", "name": "Viking", "series": "Héros", "rarity": R, "art": ["hero", "viking"]},
	{"id": "card_cowgirl", "name": "Cow-girl", "series": "Héros", "rarity": R, "art": ["hero", "cowgirl"]},
	{"id": "card_elf", "name": "Elfe", "series": "Héros", "rarity": E, "art": ["hero", "elf"]},
	{"id": "card_witch", "name": "Sorcière", "series": "Héros", "rarity": E, "art": ["hero", "witch"]},
	{"id": "card_wizard", "name": "Magicien", "series": "Héros", "rarity": E, "art": ["hero", "wizard"]},
	{"id": "card_kunoichi", "name": "Kunoichi", "series": "Héros", "rarity": E, "art": ["hero", "kunoichi"]},
	{"id": "card_captain", "name": "Capitaine", "series": "Héros", "rarity": E, "art": ["hero", "captain"]},
	{"id": "card_ronin", "name": "Ronin", "series": "Héros", "rarity": E, "art": ["hero", "ronin"]},
	{"id": "card_golden_knight", "name": "Chevalier d'or", "series": "Héros", "rarity": L, "art": ["hero", "golden_knight"]},
	{"id": "card_paladin", "name": "Paladine d'or", "series": "Héros", "rarity": L, "art": ["hero", "paladin"]},
	{"id": "card_godfather", "name": "Le Parrain", "series": "Héros", "rarity": L, "art": ["hero", "godfather"]},
	{"id": "card_vipere", "name": "Vipère", "series": "Héros", "rarity": L, "art": ["hero", "sand_ghost"]},
	# Enemies.
	{"id": "card_guard", "name": "Garde", "series": "Ennemis", "rarity": C, "art": ["enemy", "BlueSoldier_Male.fbx"]},
	{"id": "card_sand", "name": "Assassin des sables", "series": "Ennemis", "rarity": C, "art": ["enemy", "Ninja_Sand.fbx"]},
	{"id": "card_goblin", "name": "Gobelin", "series": "Ennemis", "rarity": C, "art": ["enemy", "Goblin_Male.fbx"]},
	{"id": "card_zombie", "name": "Zombie", "series": "Ennemis", "rarity": C, "art": ["enemy", "Zombie_Male.fbx"]},
	{"id": "card_suit", "name": "Homme en costume", "series": "Ennemis", "rarity": C, "art": ["enemy", "Suit_Male.fbx"]},
	{"id": "card_bat", "name": "Chauve-souris", "series": "Ennemis", "rarity": R, "art": ["boss", "monsters/Bat.fbx"]},
	{"id": "card_elite", "name": "Garde d'élite", "series": "Ennemis", "rarity": R, "art": ["elite", "BlueSoldier_Male.fbx"]},
	# Bosses.
	{"id": "card_dragon", "name": "Dragon", "series": "Boss", "rarity": E, "art": ["boss", "monsters/Dragon.fbx"]},
	{"id": "card_skeleton", "name": "Squelette géant", "series": "Boss", "rarity": E, "art": ["boss", "monsters/Skeleton.fbx"]},
	{"id": "card_giant_bat", "name": "Chauve-souris géante", "series": "Boss", "rarity": E, "art": ["boss", "monsters/Bat.fbx"]},
	{"id": "card_slime", "name": "Slime royal", "series": "Boss", "rarity": E, "art": ["boss", "monsters/Slime.fbx"]},
	{"id": "card_titan", "name": "Titan", "series": "Boss", "rarity": L, "art": ["titan", "white"]},
	{"id": "card_titan_mk2", "name": "Titan Mk II", "series": "Boss", "rarity": M, "art": ["titan", "red"]},
	# Ships.
	{"id": "card_ship_dart", "name": "Dard", "series": "Vaisseaux", "rarity": C, "art": ["ship", "ship_dart"]},
	{"id": "card_ship_falcon", "name": "Faucon", "series": "Vaisseaux", "rarity": R, "art": ["ship", "ship_falcon"]},
	{"id": "card_ship_ram", "name": "Bélier", "series": "Vaisseaux", "rarity": R, "art": ["ship", "ship_ram"]},
	{"id": "card_ship_comet", "name": "Comète", "series": "Vaisseaux", "rarity": R, "art": ["ship", "ship_comet"]},
	{"id": "card_ship_hornet", "name": "Frelon", "series": "Vaisseaux", "rarity": R, "art": ["ship", "ship_hornet"]},
	{"id": "card_ship_specter", "name": "Spectre", "series": "Vaisseaux", "rarity": E, "art": ["ship", "ship_specter"]},
	{"id": "card_ship_storm", "name": "Tempête", "series": "Vaisseaux", "rarity": E, "art": ["ship", "ship_storm"]},
	{"id": "card_ship_nova", "name": "Nova", "series": "Vaisseaux", "rarity": L, "art": ["ship", "ship_nova"]},
	# Guns.
	{"id": "card_pistol", "name": "Pistolet", "series": "Armes", "rarity": C, "art": ["gun", "blaster"]},
	{"id": "card_rifle", "name": "Fusil d'assaut", "series": "Armes", "rarity": C, "art": ["gun", "heavy"]},
	{"id": "card_smg", "name": "PM", "series": "Armes", "rarity": C, "art": ["gun", "smg"]},
	{"id": "card_sniper", "name": "Fusil de précision", "series": "Armes", "rarity": R, "art": ["gun", "sniper"]},
	{"id": "card_bazooka", "name": "Lance-roquettes", "series": "Armes", "rarity": R, "art": ["gun", "bazooka"]},
	{"id": "card_shotgun", "name": "Fusil à pompe", "series": "Armes", "rarity": R, "art": ["gun", "shotgun_1"]},
	{"id": "card_revolver", "name": "Revolver", "series": "Armes", "rarity": R, "art": ["gun", "revolver_1"]},
	{"id": "card_laser", "name": "Laser", "series": "Armes", "rarity": E, "art": ["gun", "laser"]},
	{"id": "card_railgun", "name": "Fusil à rail", "series": "Armes", "rarity": E, "art": ["gun", "railgun"]},
	{"id": "card_plasma", "name": "Canon plasma", "series": "Armes", "rarity": E, "art": ["gun", "plasma"]},
	{"id": "card_flamer", "name": "Lance-flammes", "series": "Armes", "rarity": E, "art": ["gun", "flamer"]},
	{"id": "card_flechette", "name": "Lance-fléchettes", "series": "Armes", "rarity": E, "art": ["gun", "flechette"]},
	{"id": "card_minigun", "name": "Minigun", "series": "Armes", "rarity": L, "art": ["gun", "minigun"]},
	# Melee.
	{"id": "card_knife", "name": "Couteau", "series": "Mêlée", "rarity": C, "art": ["melee", "knife"]},
	{"id": "card_axe", "name": "Hache", "series": "Mêlée", "rarity": R, "art": ["melee", "axe"]},
	{"id": "card_katana", "name": "Katana", "series": "Mêlée", "rarity": R, "art": ["melee", "katana"]},
	{"id": "card_karambit", "name": "Karambit", "series": "Mêlée", "rarity": E, "art": ["melee", "karambit"]},
	{"id": "card_butterfly", "name": "Couteau papillon", "series": "Mêlée", "rarity": E, "art": ["melee", "butterfly"]},
	# Arenas.
	{"id": "card_station", "name": "Station", "series": "Arènes", "rarity": R, "art": ["image", "station"]},
	{"id": "card_desert", "name": "Désert", "series": "Arènes", "rarity": R, "art": ["image", "desert"]},
	{"id": "card_jungle", "name": "Jungle", "series": "Arènes", "rarity": R, "art": ["image", "jungle"]},
	{"id": "card_volcano", "name": "Volcan", "series": "Arènes", "rarity": E, "art": ["image", "volcano"]},
	{"id": "card_city", "name": "Ville", "series": "Arènes", "rarity": E, "art": ["image", "city"]},
	# Anime episodes.
	{"id": "card_ep01", "name": "L'escouade", "series": "Anime", "rarity": E, "art": ["image", "ep01"]},
	{"id": "card_ep02", "name": "Le défi", "series": "Anime", "rarity": E, "art": ["image", "ep02"]},
	{"id": "card_ep03", "name": "La course", "series": "Anime", "rarity": E, "art": ["image", "ep03"]},
	{"id": "card_ep04", "name": "L'Escouade Écarlate", "series": "Anime", "rarity": E, "art": ["image", "ep04"]},
	{"id": "card_ep05", "name": "Le désert des secrets", "series": "Anime", "rarity": E, "art": ["image", "ep05"]},
	{"id": "card_ep06", "name": "Duel dans la jungle", "series": "Anime", "rarity": E, "art": ["image", "ep06"]},
	{"id": "card_ep07", "name": "Alliance", "series": "Anime", "rarity": E, "art": ["image", "ep07"]},
	{"id": "card_ep08", "name": "Le volcan", "series": "Anime", "rarity": E, "art": ["image", "ep08"]},
	{"id": "card_ep09", "name": "Titan Mk II", "series": "Anime", "rarity": L, "art": ["image", "ep09"]},
	{"id": "card_ep10", "name": "Overclock", "series": "Anime", "rarity": L, "art": ["image", "ep10"]},
	# Mythics.
	{"id": "card_squad", "name": "L'escouade au complet", "series": "Mythiques", "rarity": M, "art": ["image", "squad"]},
	{"id": "card_rivals", "name": "Soldat & Vipère", "series": "Mythiques", "rarity": M, "art": ["image", "rivals"]},
	{"id": "card_directeur", "name": "Le Directeur", "series": "Mythiques", "rarity": M, "art": ["enemy", "Suit_Male.fbx"]},
	{"id": "card_trophy", "name": "Le trophée", "series": "Mythiques", "rarity": M, "art": ["trophy", ""]},
	{"id": "card_champion", "name": "Skin Champion", "series": "Mythiques", "rarity": M, "art": ["gun_skin", "heavy:skin_champion"]},
]

const SAVE_KEY := "cards"
## Boosters waiting to be opened: "standard" (any rarity) and "rare" (its
## last card rare or better).
const BOOSTERS_KEY := "boosters"
const DUST_KEY := "card_dust"
const CLAIMED_KEY := "card_series_claimed"
const COLLECTOR_SKIN_ID := "skin_collector"


## End of a game: a booster, a second one for a big score, and a rare one
## for every fifth battle pass tier reached (`tier_before` -> now). Returns
## how many boosters were given.
static func reward_game(score: int, tier_before: int) -> int:
	var given := 1
	give_booster("standard")
	if score >= BIG_SCORE:
		give_booster("standard")
		given += 1
	var tier_now: int = BattlePass.progress().tier
	for tier in range(tier_before + 1, tier_now + 1):
		if tier % 5 == 0:
			give_booster("rare")
			given += 1
	return given


static func find(id: String) -> Dictionary:
	for card: Dictionary in CATALOG:
		if card.id == id:
			return card
	return {}


static func in_series(series: String) -> Array:
	return CATALOG.filter(func(card: Dictionary) -> bool: return card.series == series)


## How many of each card the player has: id -> count.
static func owned() -> Dictionary:
	return SaveData.load_progress(SAVE_KEY, {})


static func count(id: String) -> int:
	return owned().get(id, 0)


static func owned_total() -> int:
	return owned().keys().filter(func(id: String) -> bool: return owned()[id] > 0).size()


static func add(id: String) -> void:
	var cards := owned()
	cards[id] = cards.get(id, 0) + 1
	SaveData.save_progress(SAVE_KEY, cards)


static func dust() -> int:
	return SaveData.load_progress(DUST_KEY, 0)


static func boosters() -> Dictionary:
	return SaveData.load_progress(BOOSTERS_KEY, {"standard": 0, "rare": 0})


static func give_booster(kind: String, amount := 1) -> void:
	var pending := boosters()
	pending[kind] = pending.get(kind, 0) + amount
	SaveData.save_progress(BOOSTERS_KEY, pending)


## Opens a waiting booster of `kind`: its cards are added and returned.
static func open_booster(kind: String) -> Array[Dictionary]:
	var pending := boosters()
	if pending.get(kind, 0) <= 0:
		return []
	pending[kind] -= 1
	SaveData.save_progress(BOOSTERS_KEY, pending)
	var drawn: Array[Dictionary] = []
	for slot in CARDS_PER_BOOSTER:
		var lowest := Rarity.RARE if kind == "rare" and slot == CARDS_PER_BOOSTER - 1 else Rarity.COMMON
		var card := _draw(lowest)
		add(card.id)
		drawn.append(card)
	return drawn


## A random card of rarity `lowest` or above, by the rarities' weights.
static func _draw(lowest: Rarity) -> Dictionary:
	var total := 0.0
	for rarity: Rarity in RARITY:
		if rarity >= lowest:
			total += RARITY[rarity].weight
	var roll := randf() * total
	var chosen := lowest
	for rarity: Rarity in RARITY:
		if rarity < lowest:
			continue
		roll -= RARITY[rarity].weight
		if roll <= 0.0:
			chosen = rarity
			break
	var pool := CATALOG.filter(func(card: Dictionary) -> bool: return card.rarity == chosen)
	return pool.pick_random()


## Turns every extra copy into dust. Returns the dust gained.
static func recycle_duplicates() -> int:
	var cards := owned()
	var gained := 0
	for id: String in cards:
		if cards[id] > 1:
			gained += (cards[id] - 1) * int(RARITY[find(id).rarity].dust)
			cards[id] = 1
	SaveData.save_progress(SAVE_KEY, cards)
	SaveData.save_progress(DUST_KEY, dust() + gained)
	return gained


static func craft_cost(id: String) -> int:
	return RARITY[find(id).rarity].craft


static func craft(id: String) -> bool:
	var cost := craft_cost(id)
	if dust() < cost or count(id) > 0:
		return false
	SaveData.save_progress(DUST_KEY, dust() - cost)
	add(id)
	return true


static func series_done(series: String) -> bool:
	for card: Dictionary in in_series(series):
		if count(card.id) == 0:
			return false
	return true


static func is_claimed(series: String) -> bool:
	return series in SaveData.load_progress(CLAIMED_KEY, [])


## Pays a completed series' reward once. Returns false if not yet due.
static func claim(series: String) -> bool:
	if not series_done(series) or is_claimed(series):
		return false
	for entry: Array in SERIES:
		if entry[0] == series:
			Wallet.add_credits(entry[1])
			Wallet.add_gems(entry[2])
	var claimed: Array = SaveData.load_progress(CLAIMED_KEY, [])
	claimed.append(series)
	SaveData.save_progress(CLAIMED_KEY, claimed)
	return true


static func album_complete() -> bool:
	return owned_total() >= CATALOG.size()


static func art(card: Dictionary) -> Texture2D:
	var path := ART_DIR + str(card.id) + ".jpg"
	return load(path) if ResourceLoader.exists(path) else null
