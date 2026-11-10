class_name Loadout
## Catalog of character skins and weapons, and the player's saved selection.
## Items unlock through the battle pass (see BattlePass); ids are unique
## across all the lists.

const CHARACTER_DIR := "res://assets/models/quaternius/characters/"

const CHARACTERS := [
	{"id": "soldier", "name": "Soldat", "model": "Soldier_Male.fbx"},
	{"id": "cowboy", "name": "Cow-boy", "model": "Cowboy_Male.fbx"},
	{"id": "soldier_female", "name": "Soldate", "model": "Soldier_Female.fbx"},
	{"id": "ninja", "name": "Ninja", "model": "Ninja_Male.fbx"},
	{"id": "pirate", "name": "Pirate", "model": "Pirate_Male.fbx"},
	{"id": "knight", "name": "Chevalier", "model": "Knight_Male.fbx"},
	{"id": "kimono", "name": "Samouraï", "model": "Kimono_Male.fbx"},
	{"id": "viking", "name": "Viking", "model": "Viking_Male.fbx"},
	{"id": "elf", "name": "Elfe", "model": "Elf.fbx"},
	{"id": "cowgirl", "name": "Cow-girl", "model": "Cowboy_Female.fbx"},
	{"id": "witch", "name": "Sorcière", "model": "Witch.fbx"},
	{"id": "wizard", "name": "Magicien", "model": "Wizard.fbx"},
	{"id": "golden_knight", "name": "Chevalier d'or", "model": "Knight_Golden_Male.fbx"},
]

## Weapon skins apply to every gun: "tint" colors the model, "shot" colors the
## tracer, the impact and the muzzle flash.
const SKINS := [
	{"id": "skin_standard", "name": "Standard", "tint": Color(1, 1, 1), "shot": Color(0.0, 0.9, 1.0)},
	{"id": "skin_neon", "name": "Néon", "tint": Color(0.3, 1.0, 0.9), "shot": Color(0.2, 1.0, 0.6)},
	{"id": "skin_ice", "name": "Glace", "tint": Color(0.6, 0.85, 1.0), "shot": Color(0.65, 0.9, 1.0)},
	{"id": "skin_lava", "name": "Lave", "tint": Color(1.0, 0.45, 0.2), "shot": Color(1.0, 0.4, 0.1)},
	{"id": "skin_camo", "name": "Camouflage", "tint": Color(0.45, 0.55, 0.3), "shot": Color(0.7, 0.9, 0.3)},
	{"id": "skin_toxic", "name": "Toxique", "tint": Color(0.6, 1.0, 0.2), "shot": Color(0.6, 1.0, 0.1)},
	{"id": "skin_royal", "name": "Royal", "tint": Color(0.65, 0.4, 1.0), "shot": Color(0.7, 0.4, 1.0)},
	{"id": "skin_carbon", "name": "Carbone", "tint": Color(0.25, 0.25, 0.3), "shot": Color(1, 1, 1)},
	{"id": "skin_sakura", "name": "Sakura", "tint": Color(1.0, 0.6, 0.8), "shot": Color(1.0, 0.5, 0.8)},
	{"id": "skin_ocean", "name": "Océan", "tint": Color(0.2, 0.5, 1.0), "shot": Color(0.2, 0.6, 1.0)},
	{"id": "skin_solar", "name": "Solaire", "tint": Color(1.0, 0.85, 0.3), "shot": Color(1.0, 0.9, 0.3)},
	{"id": "skin_gold", "name": "Or", "tint": Color(1.0, 0.78, 0.25), "shot": Color(1.0, 0.85, 0.3)},
]

## "scale" and "offset" place the model in the hand; "muzzle" is where shots
## leave the gun. All are in the Weapon node's space (forward is -Z).
const WEAPONS := [
	{
		"id": "blaster", "name": "Blaster",
		"model": "res://assets/models/characters/weapon-shooter.glb",
		"scale": 2.1, "offset": Vector3.ZERO, "muzzle": Vector3(0, 0.25, -0.5),
		"fire_rate": 8.0, "damage": 1, "magazine": 24, "reload_time": 1.4, "zoom_fov": 40.0,
	},
	{
		"id": "heavy", "name": "Fusil lourd",
		"model": "res://assets/models/blasters/blaster-d.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.15), "muzzle": Vector3(0, 0.17, -0.6),
		"fire_rate": 2.0, "damage": 5, "magazine": 8, "reload_time": 1.8, "zoom_fov": 40.0,
	},
	{
		"id": "sniper", "name": "Sniper",
		"model": "res://assets/models/blasters/blaster-e.glb",
		"scale": 0.75, "offset": Vector3(0, 0.1, 0), "muzzle": Vector3(0, 0.1, -1.05),
		"fire_rate": 1.0, "damage": 8, "magazine": 5, "reload_time": 2.0, "zoom_fov": 20.0,
	},
	{
		"id": "smg", "name": "Mitraillette",
		"model": "res://assets/models/blasters/blaster-n.glb",
		"scale": 0.9, "offset": Vector3(0, 0.12, -0.1), "muzzle": Vector3(0, 0.15, -0.42),
		"fire_rate": 14.0, "damage": 1, "magazine": 40, "reload_time": 1.6, "zoom_fov": 40.0,
	},
	{
		# Fires a rocket: "damage" is dealt to every robot within "blast_radius".
		"id": "bazooka", "name": "Bazooka",
		"model": "res://assets/models/blasters/blaster-f.glb",
		"scale": 0.8, "offset": Vector3(0, 0.15, -0.2), "muzzle": Vector3(0, 0.15, -0.75),
		"fire_rate": 0.8, "damage": 10, "magazine": 1, "reload_time": 2.0, "zoom_fov": 40.0,
		"blast_radius": 4.0,
	},
]

## Close-range secondary attack. "sweep" hits every robot in front instead of one.
const MELEE := [
	{
		"id": "knife", "name": "Couteau",
		"model": "res://assets/models/characters/weapon-sword.glb", "scale": 1.3,
		"damage": 4, "range": 2.2, "cooldown": 0.5, "sweep": false, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Long thrust that pierces every enemy lined up in front.
		"id": "spear", "name": "Lance",
		"model": "res://assets/models/characters/weapon-spear.glb", "scale": 3.6,
		"damage": 6, "range": 4.5, "cooldown": 0.8, "sweep": true, "cone": 18.0, "knockback": 0.0,
	},
	{
		"id": "axe", "name": "Hache",
		"model": "res://assets/models/melee/tool-axe-upgraded.glb", "scale": 3.2,
		"damage": 10, "range": 2.6, "cooldown": 1.1, "sweep": true, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Sends the enemy flying backward.
		"id": "mace", "name": "Masse",
		"model": "res://assets/models/melee/tool-hammer-upgraded.glb", "scale": 5.0,
		"damage": 8, "range": 2.4, "cooldown": 1.0, "sweep": false, "cone": 70.0, "knockback": 12.0,
	},
]

const CHARACTER_KEY := "character"
const WEAPON_KEY := "weapon"
const MELEE_KEY := "melee"
const SKIN_KEY := "skin"


static func is_unlocked(item: Dictionary) -> bool:
	return BattlePass.is_unlocked(item.id)


static func selected_character() -> Dictionary:
	return _selected(CHARACTERS, CHARACTER_KEY)


static func selected_weapon() -> Dictionary:
	return _selected(WEAPONS, WEAPON_KEY)


static func selected_melee() -> Dictionary:
	return _selected(MELEE, MELEE_KEY)


static func selected_skin() -> Dictionary:
	return _selected(SKINS, SKIN_KEY)


static func select(key: String, item: Dictionary) -> void:
	SaveData.save_value(key, item.id)


## Creates the animated model of a character skin.
static func instantiate_character(item: Dictionary) -> CharacterModel:
	var model: Node3D = load(CHARACTER_DIR + item.model).instantiate()
	model.set_script(CharacterModel)
	return model as CharacterModel


## Creates a weapon model, scaled and turned to point toward -Z, with its
## grip at the origin.
static func instantiate_weapon(item: Dictionary, skin := {}) -> Node3D:
	var model: Node3D = load(item.model).instantiate()
	var size: float = item.scale
	# Kenney models point toward +Z: turn them around.
	model.transform = Transform3D(Basis.from_scale(Vector3(-size, size, -size)), item.offset)
	_apply_skin(model, skin if not skin.is_empty() else selected_skin())
	return model


static func instantiate_melee(item: Dictionary) -> Node3D:
	var model: Node3D = load(item.model).instantiate()
	model.scale = Vector3.ONE * item.scale
	return model


## Why a locked item is locked, for the menus.
static func unlock_text(item: Dictionary) -> String:
	return "Palier %d du passe de combat" % BattlePass.required_tier(item.id)


## Finds an item of any list by its id: {"item": ..., "kind": "Arme"}.
static func find(id: String) -> Dictionary:
	for group: Array in [["Personnage", CHARACTERS], ["Arme", WEAPONS], ["Corps à corps", MELEE], ["Skin d'arme", SKINS]]:
		for item: Dictionary in group[1]:
			if item.id == id:
				return {"item": item, "kind": group[0]}
	return {}


## Tints every surface of a weapon model with the skin's color.
static func _apply_skin(model: Node3D, skin: Dictionary) -> void:
	if skin.tint == Color(1, 1, 1):
		return
	var meshes := model.find_children("*", "MeshInstance3D", true, false)
	if model is MeshInstance3D:
		meshes.append(model)
	for mesh: MeshInstance3D in meshes:
		for surface in mesh.get_surface_override_material_count():
			var material := mesh.get_active_material(surface) as BaseMaterial3D
			if material:
				var tinted: BaseMaterial3D = material.duplicate()
				tinted.albedo_color = skin.tint
				mesh.set_surface_override_material(surface, tinted)


static func _selected(items: Array, key: String) -> Dictionary:
	var id: String = SaveData.load_value(key, items[0].id)
	for item: Dictionary in items:
		if item.id == id and is_unlocked(item):
			return item
	return items[0]
