class_name Loadout
## Catalog of character skins and weapons, and the player's saved selection.
## Items unlock when the best score reaches their "unlock" value.

const CHARACTER_DIR := "res://assets/models/quaternius/characters/"

const CHARACTERS := [
	{"id": "soldier", "name": "Soldat", "model": "Soldier_Male.fbx", "unlock": 0},
	{"id": "cowboy", "name": "Cow-boy", "model": "Cowboy_Male.fbx", "unlock": 1000},
	{"id": "pirate", "name": "Pirate", "model": "Pirate_Male.fbx", "unlock": 2500},
	{"id": "viking", "name": "Viking", "model": "Viking_Male.fbx", "unlock": 5000},
	{"id": "golden_knight", "name": "Chevalier d'or", "model": "Knight_Golden_Male.fbx", "unlock": 8000},
]

## "scale" and "offset" place the model in the hand; "muzzle" is where shots
## leave the gun. All are in the Weapon node's space (forward is -Z).
const WEAPONS := [
	{
		"id": "blaster", "name": "Blaster", "unlock": 0,
		"model": "res://assets/models/characters/weapon-shooter.glb",
		"scale": 2.1, "offset": Vector3.ZERO, "muzzle": Vector3(0, 0.25, -0.5),
		"fire_rate": 8.0, "damage": 1, "magazine": 24, "reload_time": 1.4, "zoom_fov": 40.0,
	},
	{
		"id": "heavy", "name": "Fusil lourd", "unlock": 1500,
		"model": "res://assets/models/blasters/blaster-d.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.15), "muzzle": Vector3(0, 0.17, -0.6),
		"fire_rate": 2.0, "damage": 5, "magazine": 8, "reload_time": 1.8, "zoom_fov": 40.0,
	},
	{
		"id": "sniper", "name": "Sniper", "unlock": 2500,
		"model": "res://assets/models/blasters/blaster-e.glb",
		"scale": 0.75, "offset": Vector3(0, 0.1, 0), "muzzle": Vector3(0, 0.1, -1.05),
		"fire_rate": 1.0, "damage": 8, "magazine": 5, "reload_time": 2.0, "zoom_fov": 20.0,
	},
	{
		"id": "smg", "name": "Mitraillette", "unlock": 4000,
		"model": "res://assets/models/blasters/blaster-n.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.1), "muzzle": Vector3(0, 0.15, -0.42),
		"fire_rate": 14.0, "damage": 1, "magazine": 40, "reload_time": 1.6, "zoom_fov": 40.0,
	},
	{
		# Fires a rocket: "damage" is dealt to every robot within "blast_radius".
		"id": "bazooka", "name": "Bazooka", "unlock": 6000,
		"model": "res://assets/models/blasters/blaster-f.glb",
		"scale": 0.8, "offset": Vector3(0, 0.15, -0.2), "muzzle": Vector3(0, 0.15, -0.75),
		"fire_rate": 0.8, "damage": 10, "magazine": 1, "reload_time": 2.0, "zoom_fov": 40.0,
		"blast_radius": 4.0,
	},
]

## Close-range secondary attack. "sweep" hits every robot in front instead of one.
const MELEE := [
	{
		"id": "knife", "name": "Couteau", "unlock": 0,
		"model": "res://assets/models/characters/weapon-sword.glb", "scale": 1.3,
		"damage": 4, "range": 2.2, "cooldown": 0.5, "sweep": false, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Long thrust that pierces every enemy lined up in front.
		"id": "spear", "name": "Lance", "unlock": 2000,
		"model": "res://assets/models/characters/weapon-spear.glb", "scale": 3.6,
		"damage": 6, "range": 4.5, "cooldown": 0.8, "sweep": true, "cone": 18.0, "knockback": 0.0,
	},
	{
		"id": "axe", "name": "Hache", "unlock": 3000,
		"model": "res://assets/models/melee/tool-axe-upgraded.glb", "scale": 3.2,
		"damage": 10, "range": 2.6, "cooldown": 1.1, "sweep": true, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Sends the enemy flying backward.
		"id": "mace", "name": "Masse", "unlock": 4500,
		"model": "res://assets/models/melee/tool-hammer-upgraded.glb", "scale": 5.0,
		"damage": 8, "range": 2.4, "cooldown": 1.0, "sweep": false, "cone": 70.0, "knockback": 12.0,
	},
]

const CHARACTER_KEY := "character"
const WEAPON_KEY := "weapon"
const MELEE_KEY := "melee"


static func is_unlocked(item: Dictionary) -> bool:
	return SaveData.load_high_score() >= item.unlock


static func selected_character() -> Dictionary:
	return _selected(CHARACTERS, CHARACTER_KEY)


static func selected_weapon() -> Dictionary:
	return _selected(WEAPONS, WEAPON_KEY)


static func selected_melee() -> Dictionary:
	return _selected(MELEE, MELEE_KEY)


static func select(key: String, item: Dictionary) -> void:
	SaveData.save_value(key, item.id)


## Creates the animated model of a character skin.
static func instantiate_character(item: Dictionary) -> CharacterModel:
	var model: Node3D = load(CHARACTER_DIR + item.model).instantiate()
	model.set_script(CharacterModel)
	return model as CharacterModel


static func instantiate_weapon(item: Dictionary) -> Node3D:
	return load(item.model).instantiate()


static func _selected(items: Array, key: String) -> Dictionary:
	var id: String = SaveData.load_value(key, items[0].id)
	for item: Dictionary in items:
		if item.id == id and is_unlocked(item):
			return item
	return items[0]
