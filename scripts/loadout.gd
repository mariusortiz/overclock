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

## Weapon skins apply to every gun and keep its shape: "scope" and "silencer"
## mount accessories, "tint" colors the gun and "shot" colors the tracer, the
## impact and the muzzle flash.
const SKINS := [
	{"id": "skin_standard", "name": "Standard", "scope": false, "silencer": false, "tint": Color(1, 1, 1), "shot": Color(0.0, 0.9, 1.0)},
	{"id": "skin_neon", "name": "Néon", "scope": false, "silencer": false, "tint": Color(0.3, 1.0, 0.9), "shot": Color(0.2, 1.0, 0.6)},
	{"id": "skin_ice", "name": "Glace", "scope": true, "silencer": false, "tint": Color(0.6, 0.85, 1.0), "shot": Color(0.65, 0.9, 1.0)},
	{"id": "skin_lava", "name": "Lave", "scope": false, "silencer": false, "tint": Color(1.0, 0.45, 0.2), "shot": Color(1.0, 0.4, 0.1)},
	{"id": "skin_camo", "name": "Camouflage", "scope": false, "silencer": true, "tint": Color(0.45, 0.55, 0.3), "shot": Color(0.7, 0.9, 0.3)},
	{"id": "skin_toxic", "name": "Toxique", "scope": true, "silencer": false, "tint": Color(0.6, 1.0, 0.2), "shot": Color(0.6, 1.0, 0.1)},
	{"id": "skin_royal", "name": "Royal", "scope": true, "silencer": false, "tint": Color(0.65, 0.4, 1.0), "shot": Color(0.7, 0.4, 1.0)},
	{"id": "skin_carbon", "name": "Carbone", "scope": true, "silencer": true, "tint": Color(0.25, 0.25, 0.3), "shot": Color(1, 1, 1)},
	{"id": "skin_sakura", "name": "Sakura", "scope": false, "silencer": false, "tint": Color(1.0, 0.6, 0.8), "shot": Color(1.0, 0.5, 0.8)},
	{"id": "skin_ocean", "name": "Océan", "scope": false, "silencer": true, "tint": Color(0.2, 0.5, 1.0), "shot": Color(0.2, 0.6, 1.0)},
	{"id": "skin_solar", "name": "Solaire", "scope": false, "silencer": true, "tint": Color(1.0, 0.85, 0.3), "shot": Color(1.0, 0.9, 0.3)},
	{"id": "skin_gold", "name": "Or", "scope": true, "silencer": true, "tint": Color(1.0, 0.78, 0.25), "shot": Color(1.0, 0.85, 0.3)},
]

## "model" is shown "length" meters long. Its placement in the hand is
## computed from WeaponModels; see weapon_layout().
const WEAPONS := [
	{
		"id": "blaster", "name": "Blaster", "model": "weapon-shooter", "length": 0.46,
		"fire_rate": 8.0, "damage": 1, "magazine": 24, "reload_time": 1.4, "zoom_fov": 40.0,
	},
	{
		"id": "heavy", "name": "Fusil lourd", "model": "blaster-d", "length": 0.85,
		"fire_rate": 2.0, "damage": 5, "magazine": 8, "reload_time": 1.8, "zoom_fov": 40.0,
	},
	{
		"id": "sniper", "name": "Sniper", "model": "blaster-e", "length": 1.25,
		"fire_rate": 1.0, "damage": 8, "magazine": 5, "reload_time": 2.0, "zoom_fov": 20.0,
	},
	{
		"id": "smg", "name": "Mitraillette", "model": "blaster-n", "length": 0.6,
		"fire_rate": 14.0, "damage": 1, "magazine": 40, "reload_time": 1.6, "zoom_fov": 40.0,
	},
	{
		# Fires a rocket: "damage" is dealt to every enemy within "blast_radius".
		"id": "bazooka", "name": "Bazooka", "model": "blaster-f", "length": 1.05,
		"fire_rate": 0.8, "damage": 10, "magazine": 1, "reload_time": 2.0, "zoom_fov": 40.0,
		"blast_radius": 4.0,
	},
]

const BLASTER_DIR := "res://assets/models/blasters/"
## The basic blaster comes from another pack: it points toward +Z, with its
## grip at the origin, and needs its own values.
const SHOOTER_PATH := "res://assets/models/characters/weapon-shooter.glb"
const SHOOTER_SCALE := 2.1
## Where the hand holds a kit gun, along its length (from the back) and height (from the bottom).
const GRIP_FROM_BACK := 0.3
const GRIP_FROM_BOTTOM := 0.35
const SILENCER_LENGTH := 0.244  # in model units

## Close-range secondary attack. "sweep" hits every enemy in front instead of
## one; "grip" is how far up the handle the hand holds it, in model units.
const MELEE := [
	{
		"id": "knife", "grip": 0.0, "name": "Couteau",
		"model": "res://assets/models/characters/weapon-sword.glb", "scale": 1.3,
		"damage": 4, "range": 2.2, "cooldown": 0.5, "sweep": false, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Long thrust that pierces every enemy lined up in front.
		"id": "spear", "grip": 0.22, "name": "Lance",
		"model": "res://assets/models/characters/weapon-spear.glb", "scale": 3.6,
		"damage": 6, "range": 4.5, "cooldown": 0.8, "sweep": true, "cone": 18.0, "knockback": 0.0,
	},
	{
		"id": "axe", "grip": 0.04, "name": "Hache",
		"model": "res://assets/models/melee/tool-axe-upgraded.glb", "scale": 3.2,
		"damage": 10, "range": 2.6, "cooldown": 1.1, "sweep": true, "cone": 70.0, "knockback": 0.0,
	},
	{
		# Sends the enemy flying backward.
		"id": "mace", "grip": 0.03, "name": "Masse",
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


## Where a gun's model goes once held, for a given skin: {"path", "basis",
## "offset" (model origin), "muzzle" and "scope" (points in the weapon's
## space, forward being -Z), "accessory_scale"}.
static func weapon_layout(item: Dictionary, skin: Dictionary) -> Dictionary:
	var model_name: String = item.model
	var layout := {}
	if model_name == "weapon-shooter":
		var s := SHOOTER_SCALE
		# Turned around, since this model points toward +Z.
		layout = {"path": SHOOTER_PATH, "basis": Basis.from_scale(Vector3(-s, s, -s)), "offset": Vector3.ZERO,
			"muzzle": Vector3(0, 0.25, -0.5), "scope": Vector3(0, 0.38, -0.12), "accessory_scale": 1.0}
	else:
		var data: Dictionary = WeaponModels.DATA[model_name]
		var low: Vector3 = data.min
		var high: Vector3 = data.max
		var s: float = item.length / (high.z - low.z)
		# Kit guns point toward -Z: the back is at max z.
		var grip := Vector3(0, low.y + GRIP_FROM_BOTTOM * (high.y - low.y), high.z - GRIP_FROM_BACK * (high.z - low.z))
		var offset := -grip * s
		layout = {"path": BLASTER_DIR + model_name + ".glb", "basis": Basis.from_scale(Vector3.ONE * s), "offset": offset,
			"muzzle": Vector3(0, data.barrel_y, low.z) * s + offset,
			"scope": Vector3(0, data.top_y, (low.z + high.z) / 2.0) * s + offset, "accessory_scale": s}
	if skin.silencer:
		layout.silencer = layout.muzzle
		layout.muzzle += Vector3(0, 0, -SILENCER_LENGTH * layout.accessory_scale)
	return layout


## Creates a gun as held in the hand: grip at the origin, pointing toward -Z,
## with the skin's accessories and color. `skin` defaults to the
## equipped one.
static func instantiate_weapon(item: Dictionary, skin := {}) -> Node3D:
	if skin.is_empty():
		skin = selected_skin()
	var layout := weapon_layout(item, skin)
	var gun := Node3D.new()
	var model: Node3D = load(layout.path).instantiate()
	model.transform = Transform3D(layout.basis, layout.offset)
	gun.add_child(model)
	if skin.scope:
		_add_accessory(gun, "scope-small.glb", layout.scope, layout.accessory_scale)
	if skin.silencer:
		_add_accessory(gun, "silencer-small.glb", layout.silencer, layout.accessory_scale)
	_apply_skin(gun, skin)
	return gun


static func _add_accessory(gun: Node3D, file: String, at: Vector3, size: float) -> void:
	var accessory: Node3D = load(BLASTER_DIR + file).instantiate()
	accessory.transform = Transform3D(Basis.from_scale(Vector3.ONE * size), at)
	gun.add_child(accessory)


## Creates a melee weapon as held in the hand: its handle along +Y, gripped
## "grip" model units above its lower end.
static func instantiate_melee(item: Dictionary) -> Node3D:
	var model: Node3D = load(item.model).instantiate()
	var size: float = item.scale
	model.transform = Transform3D(Basis.from_scale(Vector3.ONE * size), Vector3(0, -item.grip * size, 0))
	var held := Node3D.new()
	held.add_child(model)
	return held


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
