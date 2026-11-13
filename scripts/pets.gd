class_name Pets
## The pets: a companion that follows the hero, in the games and on the home
## screen, with one light help each ("perk"). The perks play in the waves,
## the co-op and the zone capture against bots; in the fight mode and in a
## capture against other players the pet is only there to be seen (fair play).
##
## Getting one: four are sold in the shop, three are tiers of the season 2
## battle pass (BattlePass.REWARDS_2), the others hatch from eggs. An egg comes
## with each boss beaten in the waves (EGG_MAX at most waiting) and with the
## three daily challenges done; the first egg hatches after HATCH_WAVES waves
## cleared, into a pet drawn by rarity. A pet hatched twice gives gems.
##
## Each pet: "model" (a 3D model, from Loadout.CHARACTER_DIR's sibling folders)
## or "build" (made by Pet: "drone", "shard"), its height, "fly" for the ones
## that hover, "turn" to face forward, "colors" (by material name: some of
## the pack's models lost theirs on export), "rarity" (Cards.Rarity), the "perk",
## and how it is had: "shop", "egg", or a pass tier (BattlePass).

const KEY := "pet"
const EGGS_KEY := "pet_eggs"
const EGG_WAVES_KEY := "pet_egg_waves"
const HATCH_WAVES := 10
const EGG_MAX := 3
## Gems for a pet hatched again.
const DUPLICATE_GEMS := 100
## Chances of each rarity out of an egg (common, rare, epic, legendary).
const EGG_WEIGHTS := [60.0, 28.0, 10.0, 2.0]
const ANIMALS := "res://assets/models/quaternius/animals/"
const MONSTERS := "res://assets/models/quaternius/monsters/"

const NONE := {"id": "pet_none", "name": "Aucun", "perk": &"", "rarity": 0}

const LIST := [
	NONE,
	{"id": "pet_dog", "name": "Chien", "model": ANIMALS + "Dog.fbx", "turn": PI / 2.0, "height": 0.55,
		"colors": {"Dog": Color(0.62, 0.45, 0.3)}, "rarity": 0, "perk": &"magnet", "egg": true},
	{"id": "pet_cat", "name": "Chat", "model": ANIMALS + "Cat.fbx", "turn": PI / 2.0, "height": 0.55,
		"colors": {"Grey": Color(0.25, 0.25, 0.28), "White": Color(0.95, 0.95, 0.95), "Pink": Color(1.0, 0.6, 0.8)}, "rarity": 0, "perk": &"luck", "egg": true},
	{"id": "pet_chick", "name": "Poussin", "model": ANIMALS + "Chick.fbx", "turn": PI / 2.0, "height": 0.35,
		"colors": {"Material.001": Color(1.0, 0.85, 0.3), "Material.002": Color(1.0, 0.55, 0.15)}, "rarity": 0, "perk": &"xp", "egg": true},
	{"id": "pet_sheep", "name": "Mouton", "model": ANIMALS + "Sheep.fbx", "height": 0.6, "rarity": 0, "perk": &"wool", "egg": true},
	{"id": "pet_fox", "name": "Renard", "model": ANIMALS + "RedFox.fbx", "height": 0.5,
		"colors": {"Material.001": Color(0.9, 0.42, 0.15), "Material.002": Color(0.97, 0.95, 0.9)}, "rarity": 1, "perk": &"swift", "egg": true},
	{"id": "pet_bat", "name": "Mini chauve-souris", "model": MONSTERS + "Bat.fbx", "height": 0.45, "fly": true, "rarity": 1, "perk": &"echo", "egg": true},
	{"id": "pet_pig", "name": "Cochon", "model": ANIMALS + "Pig.fbx", "height": 0.5, "rarity": 1, "perk": &"piggy", "shop": true},
	{"id": "pet_llama", "name": "Lama", "model": ANIMALS + "Llama.fbx", "height": 0.85, "rarity": 1, "perk": &"spit", "shop": true},
	{"id": "pet_pug", "name": "Carlin", "model": ANIMALS + "Pug.fbx", "height": 0.4, "rarity": 1, "perk": &"cuddle"},
	{"id": "pet_wolf", "name": "Loup", "model": ANIMALS + "Wolf.fbx", "turn": PI / 2.0, "height": 0.55,
		"colors": {"Wolf": Color(0.62, 0.64, 0.7)}, "rarity": 2, "perk": &"bite", "egg": true},
	{"id": "pet_slime", "name": "Mini slime", "model": MONSTERS + "Slime.fbx", "turn": PI, "height": 0.45, "rarity": 2, "perk": &"jelly", "shop": true},
	{"id": "pet_eagle", "name": "Aigle", "model": ANIMALS + "Eagle.fbx", "height": 0.22,
		"colors": {"Wings": Color(0.32, 0.18, 0.1), "Beak": Color(0.98, 0.75, 0.2), "Head": Color(0.97, 0.97, 0.95), "Claws": Color(0.98, 0.75, 0.2)}, "fly": true, "rarity": 2, "perk": &"dive"},
	{"id": "pet_drone", "name": "Drone", "build": "drone", "height": 0.4, "fly": true, "rarity": 2, "perk": &"turret", "shop": true},
	{"id": "pet_dragon", "name": "Dragonnet", "model": MONSTERS + "Dragon.fbx", "height": 0.6, "fly": true, "rarity": 3, "perk": &"breath", "egg": true},
	{"id": "pet_titan", "name": "Mini-Titan", "model": "res://assets/models/quaternius/mechs/George.fbx", "height": 0.8, "rarity": 3, "perk": &"shield"},
	{"id": "pet_calf", "name": "Veau", "model": ANIMALS + "Calf.fbx", "height": 0.6, "rarity": 3, "perk": &"ulti", "egg": true},
	# Le Créateur's: only through his code (PromoCodes), full power everywhere.
	{"id": "pet_capybara", "name": "Capybara", "build": "capybara", "height": 0.6, "rarity": 4, "perk": &"capy", "code": true},
	{"id": "pet_shard", "name": "Éclat de cristal", "build": "shard", "height": 0.5, "fly": true, "rarity": 3, "perk": &"song", "egg": true},
]

## What each perk does, for the armory, the shop and the cards: [name, text].
const PERKS := {
	&"magnet": ["Rapporte", "Attire vers toi les bonus à moins de 10 m."],
	&"luck": ["Porte-bonheur", "Un ennemi a 10 % de chances en plus de lâcher un bonus."],
	&"xp": ["Piou", "+10 % d'XP à la fin de la partie."],
	&"wool": ["Laine", "Les coups reçus font 10 % de dégâts en moins."],
	&"swift": ["Vif", "Tu cours 6 % plus vite."],
	&"echo": ["Écho", "Lance une onde sur l'ennemi le plus proche toutes les 3 s (2 dégâts)."],
	&"piggy": ["Tirelire", "+10 % de crédits à la fin de la partie."],
	&"spit": ["Crachat", "Crache sur l'ennemi le plus proche toutes les 5 s : il ralentit."],
	&"cuddle": ["Câlin", "Rend 1 PV à chaque ennemi éliminé."],
	&"bite": ["Morsure", "Mord l'ennemi le plus proche à moins de 4 m toutes les 3 s (3 dégâts)."],
	&"jelly": ["Gelée", "Rend 1 PV toutes les 3 s."],
	&"dive": ["Piqué", "Plonge sur un ennemi à moins de 20 m toutes les 6 s (4 dégâts)."],
	&"turret": ["Tourelle", "Tire sur l'ennemi le plus proche toutes les 1,5 s (1 dégât)."],
	&"breath": ["Souffle", "Enflamme l'ennemi le plus proche toutes les 5 s."],
	&"shield": ["Bouclier", "Annule un coup reçu toutes les 20 s."],
	&"ulti": ["Petit créateur", "La jauge d'ulti se remplit 15 % plus vite."],
	&"song": ["Chant", "Toutes les 8 s, ralentit les ennemis à moins de 6 m."],
	&"capy": ["Calme absolu", "Foudroie l'ennemi le plus proche à 25 m (8 dégâts) toutes les 1,5 s, rend 2 PV toutes les 3 s, "
			+ "dégâts reçus divisés par deux, +15 % de vitesse, ulti, XP, crédits et bonus +30 %. Partout, multijoueur compris."],
}
const RARITY_NAMES := ["Commun", "Rare", "Épique", "Légendaire", "Hacker"]
## Battle pass tiers (season 2) of the pets of the pass, for the texts.
const SHIELD_COOLDOWN := 20.0

## On while a game where the perks play is running (set by the game scenes).
static var enabled := false
## On during any game with a pet (perks or not): the capybara plays anyway.
static var in_game := false
static var _shield_ready_at := 0.0
## Test option (Main's "--pet="): this pet, owned or not.
static var forced := {}


static func find(id: String) -> Dictionary:
	for pet: Dictionary in LIST:
		if pet.id == id:
			return pet
	return {}


static func is_pet(item: Dictionary) -> bool:
	return str(item.get("id", "")).begins_with("pet_")


static func is_owned(pet: Dictionary) -> bool:
	if pet.id == NONE.id:
		return true
	if pet.get("shop", false) or pet.get("egg", false) or pet.get("code", false):
		return Wallet.owns(pet.id)
	return BattlePass.is_unlocked(pet.id)


static func unlock_text(pet: Dictionary) -> String:
	if pet.get("code", false):
		return "Uniquement avec le code du Créateur"
	if pet.get("shop", false):
		return "En vente à la boutique"
	if pet.get("egg", false):
		return "Sort d'un œuf (%s)" % RARITY_NAMES[pet.rarity].to_lower()
	return "Palier %d du passe saison 2" % BattlePass.required_tier(pet.id)


static func selected() -> Dictionary:
	if not forced.is_empty():
		return forced
	var pet := find(SaveData.load_value(KEY, NONE.id))
	return pet if not pet.is_empty() and is_owned(pet) else NONE


static func select(pet: Dictionary) -> void:
	SaveData.save_value(KEY, pet.id)


## The perk playing now: the pet's, while perks are on (the capybara's
## always, in a game: like Le Créateur, full power everywhere).
static func perk() -> StringName:
	var pet := selected()
	return pet.perk if enabled or (in_game and pet.perk == &"capy") else &""


## The capybara is Le Créateur's: whoever has him gets it too (his code
## gave it later than him).
static func sync_creator() -> void:
	if Wallet.owns("createur"):
		Wallet.give("pet_capybara")


static func perk_text(pet: Dictionary) -> String:
	if pet.perk == &"":
		return ""
	var info: Array = PERKS[pet.perk]
	return "%s : %s" % [info[0], info[1]]


# --- Perks read by the game ----------------------------------------------------

## Extra chance of a power-up from an enemy (luck).
static func drop_bonus() -> float:
	return 0.1 if perk() == &"luck" else (0.3 if perk() == &"capy" else 0.0)


## A hit on the player, after the pet: lighter (wool), or none at all
## (shield, once in a while).
static func filter_damage(amount: int) -> int:
	match perk():
		&"capy":
			return maxi(roundi(amount * 0.5), 1)
		&"wool":
			return maxi(roundi(amount * 0.9), 1)
		&"shield":
			var now := Time.get_ticks_msec() / 1000.0
			if now >= _shield_ready_at:
				_shield_ready_at = now + SHIELD_COOLDOWN
				return 0
	return amount


static func speed_factor() -> float:
	if perk() == &"capy":
		return 1.15
	return 1.06 if perk() == &"swift" else 1.0


static func charge_factor() -> float:
	if perk() == &"capy":
		return 1.3
	return 1.15 if perk() == &"ulti" else 1.0


static func xp_factor() -> float:
	if perk() == &"capy":
		return 1.3
	return 1.1 if perk() == &"xp" else 1.0


static func credits_factor() -> float:
	if perk() == &"capy":
		return 1.3
	return 1.1 if perk() == &"piggy" else 1.0


# --- Eggs ------------------------------------------------------------------------

static func eggs() -> int:
	return SaveData.load_progress(EGGS_KEY, 0)


## Waves cleared toward hatching the first egg.
static func egg_waves() -> int:
	return SaveData.load_progress(EGG_WAVES_KEY, 0)


## One more egg (up to EGG_MAX waiting). True if it was kept.
static func give_egg() -> bool:
	if eggs() >= EGG_MAX:
		return false
	SaveData.save_progress(EGGS_KEY, eggs() + 1)
	return true


## A wave cleared: the first egg warms up.
static func add_wave() -> void:
	if eggs() > 0 and egg_waves() < HATCH_WAVES:
		SaveData.save_progress(EGG_WAVES_KEY, egg_waves() + 1)


static func can_hatch() -> bool:
	return eggs() > 0 and egg_waves() >= HATCH_WAVES


## Hatches the first egg: {"pet", "new"} (a pet had already gives gems).
static func hatch(rng := RandomNumberGenerator.new()) -> Dictionary:
	if not can_hatch():
		return {}
	SaveData.save_progress(EGGS_KEY, eggs() - 1)
	SaveData.save_progress(EGG_WAVES_KEY, 0)
	var pool := LIST.filter(func(pet: Dictionary) -> bool: return pet.get("egg", false))
	var rarity := 0
	var roll := rng.randf() * 100.0
	for index in EGG_WEIGHTS.size():
		roll -= EGG_WEIGHTS[index]
		if roll < 0.0:
			rarity = index
			break
	var options := pool.filter(func(pet: Dictionary) -> bool: return pet.rarity == rarity)
	var pet: Dictionary = options[rng.randi() % options.size()]
	var fresh := Wallet.give(pet.id)
	if not fresh:
		Wallet.add_gems(DUPLICATE_GEMS)
	return {"pet": pet, "new": fresh}
