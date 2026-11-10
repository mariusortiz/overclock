class_name Loadout
## Catalog of character skins and weapons, and the player's saved selection.
## Items unlock when the best score reaches their "unlock" value.

const CHARACTER_DIR := "res://assets/models/characters/"

const CHARACTERS := [
	{"id": "soldier", "name": "Soldat", "model": "character-soldier.glb", "unlock": 0},
	{"id": "worker", "name": "Ouvrier", "model": "character-worker.glb", "unlock": 1000},
	{"id": "raider", "name": "Pillard", "model": "character-raider.glb", "unlock": 2500},
	{"id": "knight", "name": "Chevalier", "model": "character-knight.glb", "unlock": 5000},
	{"id": "alien", "name": "Alien", "model": "character-alien.glb", "unlock": 8000},
]

## "scale" and "offset" place the model in the hand; "muzzle" is where shots
## leave the gun. All are in the Weapon node's space (forward is -Z).
const WEAPONS := [
	{
		"id": "blaster", "name": "Blaster", "unlock": 0,
		"model": "res://assets/models/characters/weapon-shooter.glb",
		"scale": 2.1, "offset": Vector3.ZERO, "muzzle": Vector3(0, 0.25, -0.5),
		"fire_rate": 8.0, "damage": 1, "magazine": 24, "reload_time": 1.4,
	},
	{
		"id": "heavy", "name": "Fusil lourd", "unlock": 1500,
		"model": "res://assets/models/blasters/blaster-d.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.15), "muzzle": Vector3(0, 0.17, -0.6),
		"fire_rate": 2.0, "damage": 5, "magazine": 8, "reload_time": 1.8,
	},
	{
		"id": "smg", "name": "Mitraillette", "unlock": 4000,
		"model": "res://assets/models/blasters/blaster-n.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.1), "muzzle": Vector3(0, 0.15, -0.42),
		"fire_rate": 14.0, "damage": 1, "magazine": 40, "reload_time": 1.6,
	},
]

const CHARACTER_KEY := "character"
const WEAPON_KEY := "weapon"


static func is_unlocked(item: Dictionary) -> bool:
	return SaveData.load_high_score() >= item.unlock


static func selected_character() -> Dictionary:
	return _selected(CHARACTERS, CHARACTER_KEY)


static func selected_weapon() -> Dictionary:
	return _selected(WEAPONS, WEAPON_KEY)


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
