class_name Loadout
## Catalog of character skins and weapons, and the player's saved selection.
## Items unlock through the battle pass (see BattlePass); ids are unique
## across all the lists.

const CHARACTER_DIR := "res://assets/models/quaternius/characters/"

const CHARACTERS := [
	{"id": "soldier", "ulti": &"airstrike", "name": "Soldat", "model": "Soldier_Male.fbx"},
	{"id": "cowboy", "ulti": &"deadeye", "name": "Cow-boy", "model": "Cowboy_Male.fbx"},
	{"id": "soldier_female", "ulti": &"overdrive", "name": "Soldate", "model": "Soldier_Female.fbx"},
	{"id": "ninja", "ulti": &"clones", "name": "Ninja", "model": "Ninja_Male.fbx"},
	{"id": "pirate", "ulti": &"broadside", "name": "Pirate", "model": "Pirate_Male.fbx"},
	{"id": "knight", "ulti": &"rampart", "name": "Chevalier", "model": "Knight_Male.fbx"},
	{"id": "kimono", "ulti": &"whirlwind", "name": "Samouraï", "model": "Kimono_Male.fbx"},
	{"id": "viking", "ulti": &"rage", "name": "Viking", "model": "Viking_Male.fbx"},
	{"id": "elf", "ulti": &"arrows", "name": "Elfe", "model": "Elf.fbx"},
	{"id": "cowgirl", "ulti": &"dynamite", "name": "Cow-girl", "model": "Cowboy_Female.fbx"},
	{"id": "witch", "ulti": &"curse", "name": "Sorcière", "model": "Witch.fbx"},
	{"id": "wizard", "ulti": &"timestop", "name": "Magicien", "model": "Wizard.fbx"},
	{"id": "golden_knight", "ulti": &"blessing", "name": "Chevalier d'or", "model": "Knight_Golden_Male.fbx"},
]

## Weapon skins are finishes: they keep the gun's shape. A skin with a pattern
## (assets/textures/skins/<id>.png, see tools/make_skin_textures.py) repaints
## the gun's body; "glow" makes it emit light; "scope" and "silencer" mount
## accessories; "shot" colors the tracer, the impact and the muzzle flash;
## "kill" is the way enemies die when shot with it (see Enemy._die).
const SKINS := [
	{"id": "skin_standard", "kill": &"", "name": "Standard", "pattern": false, "glow": 0.0, "scope": false, "silencer": false, "shot": Color(1.0, 0.85, 0.4)},
	{"id": "skin_neon", "kill": &"vanish", "name": "Néon", "pattern": true, "glow": 0.5, "scope": false, "silencer": false, "shot": Color(0.0, 0.9, 1.0)},
	{"id": "skin_ice", "kill": &"shatter", "name": "Glace", "pattern": true, "glow": 0.15, "scope": true, "silencer": false, "shot": Color(0.65, 0.9, 1.0)},
	{"id": "skin_lava", "kill": &"burn", "name": "Lave", "pattern": true, "glow": 0.5, "scope": false, "silencer": false, "shot": Color(1.0, 0.4, 0.1)},
	{"id": "skin_camo", "kill": &"", "name": "Camouflage", "pattern": true, "glow": 0.0, "scope": false, "silencer": true, "shot": Color(0.7, 0.9, 0.3)},
	{"id": "skin_toxic", "kill": &"melt", "name": "Toxique", "pattern": true, "glow": 0.4, "scope": true, "silencer": false, "shot": Color(0.6, 1.0, 0.1)},
	{"id": "skin_royal", "kill": &"vanish", "name": "Royal", "pattern": true, "glow": 0.1, "scope": true, "silencer": false, "shot": Color(0.7, 0.4, 1.0)},
	{"id": "skin_carbon", "kill": &"", "name": "Carbone", "pattern": true, "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1, 1, 1)},
	{"id": "skin_sakura", "kill": &"burst", "name": "Sakura", "pattern": true, "glow": 0.1, "scope": false, "silencer": false, "shot": Color(1.0, 0.5, 0.8)},
	{"id": "skin_ocean", "kill": &"melt", "name": "Océan", "pattern": true, "glow": 0.15, "scope": false, "silencer": true, "shot": Color(0.2, 0.6, 1.0)},
	{"id": "skin_solar", "kill": &"burn", "name": "Solaire", "pattern": true, "glow": 0.3, "scope": false, "silencer": true, "shot": Color(1.0, 0.9, 0.3)},
	{"id": "skin_gold", "kill": &"shatter", "name": "Or", "pattern": true, "glow": 0.2, "scope": true, "silencer": true, "shot": Color(1.0, 0.85, 0.3)},
	# Not in the battle pass: earned by beating the final boss.
	{"id": "skin_champion", "kill": &"burst", "name": "Champion", "pattern": true, "glow": 0.6, "scope": true, "silencer": true, "shot": Color(1.0, 0.3, 0.9)},
]
const CHAMPION_SKIN_ID := "skin_champion"
const CHAMPION_KEY := "champion"

## "model" (a .obj of assets/models/guns) is shown "length" meters long. Its
## placement in the hand is computed from WeaponModels; see weapon_layout().
const WEAPONS := [
	{
		"id": "blaster", "name": "Pistolet", "model": "Pistol_1", "length": 0.42,
		"fire_rate": 4.0, "damage": 2, "magazine": 12, "reload_time": 1.2, "zoom_fov": 40.0,
	},
	{
		"id": "heavy", "name": "Fusil d'assaut", "model": "AssaultRifle2_1", "length": 0.95,
		"fire_rate": 10.0, "damage": 1, "magazine": 30, "reload_time": 1.6, "zoom_fov": 40.0,
	},
	{
		"id": "sniper", "name": "Fusil de précision", "model": "SniperRifle_1", "length": 1.3, "has_scope": true,
		"fire_rate": 1.0, "damage": 8, "magazine": 5, "reload_time": 2.0, "zoom_fov": 20.0,
	},
	{
		"id": "smg", "name": "PM", "model": "SubmachineGun_1", "length": 0.62,
		"fire_rate": 14.0, "damage": 1, "magazine": 40, "reload_time": 1.6, "zoom_fov": 40.0,
	},
	{
		# Fires a rocket: "damage" is dealt to every enemy within "blast_radius".
		"id": "bazooka", "name": "Lance-roquettes", "model": "Bullpup_3", "length": 1.0,
		"fire_rate": 0.8, "damage": 10, "magazine": 1, "reload_time": 2.0, "zoom_fov": 40.0,
		"blast_radius": 4.0,
	},
	# The rest of the gun pack. A shotgun fires "pellets" shots at once, spread
	# over "spread" degrees.
	{"id": "pistol_2", "name": "Pistolet II", "model": "Pistol_2", "length": 0.36, "fire_rate": 5.0, "damage": 2, "magazine": 10, "reload_time": 1.2, "zoom_fov": 40.0},
	{"id": "pistol_3", "name": "Pistolet III", "model": "Pistol_3", "length": 0.37, "fire_rate": 3.5, "damage": 3, "magazine": 9, "reload_time": 1.2, "zoom_fov": 40.0},
	{"id": "pistol_4", "name": "Pistolet IV", "model": "Pistol_4", "length": 0.4, "fire_rate": 6.0, "damage": 2, "magazine": 8, "reload_time": 1.2, "zoom_fov": 40.0},
	{"id": "pistol_5", "name": "Pistolet V", "model": "Pistol_5", "length": 0.36, "fire_rate": 4.5, "damage": 2, "magazine": 15, "reload_time": 1.2, "zoom_fov": 40.0},
	{"id": "pistol_6", "name": "Pistolet VI", "model": "Pistol_6", "length": 0.49, "fire_rate": 3.0, "damage": 3, "magazine": 12, "reload_time": 1.2, "zoom_fov": 40.0},
	{"id": "revolver_1", "name": "Revolver I", "model": "Revolver_1", "length": 0.4, "fire_rate": 2.0, "damage": 5, "magazine": 6, "reload_time": 1.8, "zoom_fov": 40.0},
	{"id": "revolver_2", "name": "Revolver II", "model": "Revolver_2", "length": 0.4, "fire_rate": 2.4, "damage": 4, "magazine": 6, "reload_time": 1.8, "zoom_fov": 40.0},
	{"id": "revolver_3", "name": "Revolver III", "model": "Revolver_3", "length": 0.4, "fire_rate": 1.6, "damage": 6, "magazine": 6, "reload_time": 1.8, "zoom_fov": 40.0},
	{"id": "revolver_4", "name": "Revolver IV", "model": "Revolver_4", "length": 0.29, "fire_rate": 2.2, "damage": 5, "magazine": 6, "reload_time": 1.8, "zoom_fov": 40.0},
	{"id": "revolver_5", "name": "Revolver V", "model": "Revolver_5", "length": 0.38, "fire_rate": 1.3, "damage": 7, "magazine": 6, "reload_time": 1.8, "zoom_fov": 40.0},
	{"id": "rifle_2", "name": "Fusil d'assaut II", "model": "AssaultRifle2_2", "length": 0.97, "fire_rate": 11.0, "damage": 1, "magazine": 28, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_3", "name": "Fusil d'assaut III", "model": "AssaultRifle2_3", "length": 0.75, "fire_rate": 6.0, "damage": 2, "magazine": 24, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_4", "name": "Fusil d'assaut IV", "model": "AssaultRifle2_4", "length": 0.59, "fire_rate": 9.0, "damage": 1, "magazine": 36, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_5", "name": "Fusil d'assaut V", "model": "AssaultRifle_1", "length": 0.62, "fire_rate": 12.0, "damage": 1, "magazine": 25, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_6", "name": "Fusil d'assaut VI", "model": "AssaultRifle_2", "length": 1.08, "fire_rate": 5.5, "damage": 2, "magazine": 30, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_7", "name": "Fusil d'assaut VII", "model": "AssaultRifle_3", "length": 0.69, "fire_rate": 10.0, "damage": 1, "magazine": 34, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_8", "name": "Fusil d'assaut VIII", "model": "AssaultRifle_4", "length": 1.1, "fire_rate": 8.0, "damage": 1, "magazine": 45, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "rifle_9", "name": "Fusil d'assaut IX", "model": "AssaultRifle_5", "length": 1.08, "fire_rate": 7.0, "damage": 2, "magazine": 20, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "bullpup_1", "name": "Bullpup I", "model": "Bullpup_1", "length": 1.05, "fire_rate": 9.0, "damage": 1, "magazine": 32, "reload_time": 1.4, "zoom_fov": 40.0},
	{"id": "bullpup_2", "name": "Bullpup II", "model": "Bullpup_2", "length": 0.75, "fire_rate": 5.0, "damage": 2, "magazine": 26, "reload_time": 1.4, "zoom_fov": 40.0},
	{"id": "shotgun_1", "name": "Fusil à pompe I", "model": "Shotgun_1", "length": 1.04, "fire_rate": 1.3, "damage": 1, "magazine": 6, "reload_time": 1.8, "pellets": 6, "spread": 6.0, "zoom_fov": 40.0},
	{"id": "shotgun_2", "name": "Fusil à pompe II", "model": "Shotgun_2", "length": 1.16, "fire_rate": 1.1, "damage": 1, "magazine": 5, "reload_time": 1.8, "pellets": 8, "spread": 5.0, "zoom_fov": 40.0},
	{"id": "shotgun_3", "name": "Fusil à pompe III", "model": "Shotgun_3", "length": 1.16, "fire_rate": 1.6, "damage": 1, "magazine": 4, "reload_time": 1.8, "pellets": 6, "spread": 7.0, "zoom_fov": 40.0},
	{"id": "shotgun_4", "name": "Fusil à pompe IV", "model": "Shotgun_4", "length": 1.09, "fire_rate": 1.0, "damage": 1, "magazine": 8, "reload_time": 1.8, "pellets": 7, "spread": 5.0, "zoom_fov": 40.0},
	{"id": "shotgun_5", "name": "Canon scié", "model": "Shotgun_SawedOff", "length": 0.74, "fire_rate": 2.0, "damage": 1, "magazine": 2, "reload_time": 1.8, "pellets": 9, "spread": 11.0, "zoom_fov": 40.0},
	{"id": "shotgun_6", "name": "Pompe court", "model": "Shotgun_ShortStock", "length": 0.89, "fire_rate": 1.5, "damage": 1, "magazine": 5, "reload_time": 1.8, "pellets": 6, "spread": 8.0, "zoom_fov": 40.0},
	{"id": "smg_2", "name": "PM II", "model": "SubmachineGun_2", "length": 0.81, "fire_rate": 16.0, "damage": 1, "magazine": 32, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "smg_3", "name": "PM III", "model": "SubmachineGun_3", "length": 0.8, "fire_rate": 12.0, "damage": 1, "magazine": 50, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "smg_4", "name": "PM IV", "model": "SubmachineGun_4", "length": 0.51, "fire_rate": 13.0, "damage": 1, "magazine": 44, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "smg_5", "name": "PM V", "model": "SubmachineGun_5", "length": 1.01, "fire_rate": 15.0, "damage": 1, "magazine": 36, "reload_time": 1.6, "zoom_fov": 40.0},
	{"id": "sniper_2", "name": "Précision II", "model": "SniperRifle_2", "length": 1.48, "fire_rate": 1.2, "damage": 7, "magazine": 6, "reload_time": 2.0, "zoom_fov": 20.0, "has_scope": true},
	{"id": "sniper_3", "name": "Précision III", "model": "SniperRifle_3", "length": 1.45, "fire_rate": 0.8, "damage": 10, "magazine": 4, "reload_time": 2.0, "zoom_fov": 20.0, "has_scope": true},
	{"id": "sniper_4", "name": "Précision IV", "model": "SniperRifle_4", "length": 1.27, "fire_rate": 1.5, "damage": 6, "magazine": 8, "reload_time": 2.0, "zoom_fov": 20.0, "has_scope": true},
	{"id": "sniper_5", "name": "Précision V", "model": "SniperRifle_5", "length": 1.27, "fire_rate": 0.7, "damage": 12, "magazine": 3, "reload_time": 2.0, "zoom_fov": 20.0, "has_scope": true},
	{"id": "sniper_6", "name": "Précision VI", "model": "SniperRifle_6", "length": 1.44, "fire_rate": 1.0, "damage": 9, "magazine": 5, "reload_time": 2.0, "zoom_fov": 20.0, "has_scope": true},
]

const GUN_DIR := "res://assets/models/guns/"
const SKIN_DIR := "res://assets/textures/skins/"
const SCOPE_MODEL := "Scope_2"
const SILENCER_MODEL := "Silencer_Short"
const SILENCER_LENGTH := 0.78  # in model units
## Parts of a gun that a skin leaves alone (material names of the models).
const UNPAINTED_PARTS: Array[String] = ["Black", "Black2", "Glass", "DarkMetal"]
const PATTERN_SCALE := 0.6

## Close-range secondary attack. "sweep" hits every enemy in front instead of
## one. "model" is a .obj of assets/models/melee (see tools/make_melee_models.py):
## handle along +Y, held at the origin, already at its size in the game.
const MELEE := [
	{"id": "knife", "name": "Couteau", "model": "knife",
		"damage": 4, "range": 2.2, "cooldown": 0.5, "sweep": false, "cone": 70.0, "knockback": 0.0},
	# Long thrust that pierces every enemy lined up in front.
	{"id": "spear", "name": "Lance", "model": "spear",
		"damage": 6, "range": 4.5, "cooldown": 0.8, "sweep": true, "cone": 18.0, "knockback": 0.0},
	{"id": "axe", "name": "Hache", "model": "axe",
		"damage": 10, "range": 2.6, "cooldown": 1.1, "sweep": true, "cone": 70.0, "knockback": 0.0},
	# Sends the enemy flying backward.
	{"id": "mace", "name": "Masse", "model": "mace",
		"damage": 8, "range": 2.4, "cooldown": 1.0, "sweep": false, "cone": 70.0, "knockback": 12.0},
	{"id": "kunai", "name": "Kunaï", "model": "kunai",
		"damage": 3, "range": 2.0, "cooldown": 0.3, "sweep": false, "cone": 70.0, "knockback": 0.0},
	{"id": "butterfly", "name": "Couteau papillon", "model": "butterfly",
		"damage": 4, "range": 2.1, "cooldown": 0.4, "sweep": false, "cone": 70.0, "knockback": 0.0},
	# A short slash that catches everyone right in front.
	{"id": "karambit", "name": "Karambit", "model": "karambit",
		"damage": 5, "range": 2.0, "cooldown": 0.5, "sweep": true, "cone": 50.0, "knockback": 0.0},
	{"id": "machete", "name": "Machette", "model": "machete",
		"damage": 9, "range": 2.6, "cooldown": 0.9, "sweep": false, "cone": 70.0, "knockback": 0.0},
	{"id": "katana", "name": "Katana", "model": "katana",
		"damage": 7, "range": 3.2, "cooldown": 0.7, "sweep": true, "cone": 80.0, "knockback": 0.0},
]

const MELEE_DIR := "res://assets/models/melee/"
const MELEE_TEXTURE_DIR := "res://assets/textures/melee/"
## Look of each part of a melee weapon, by the material name it has in the
## model: [texture or "", color, metallic, roughness].
const MELEE_MATERIALS := {
	"Blade": ["steel", Color(0.82, 0.84, 0.88), 0.85, 0.3],
	"Edge": ["", Color(0.93, 0.95, 0.98), 0.9, 0.18],
	"Wood": ["wood", Color.WHITE, 0.0, 0.7],
	"Grip": ["grip", Color.WHITE, 0.0, 0.85],
	"Wrap": ["wrap", Color.WHITE, 0.0, 0.8],
	"Guard": ["steel", Color(0.28, 0.28, 0.32), 0.8, 0.4],
	"Brass": ["", Color(0.8, 0.6, 0.25), 0.9, 0.3],
	"Accent": ["", Color(0.75, 0.12, 0.12), 0.3, 0.5],
}
## Parts of a melee weapon that a skin repaints.
const MELEE_PAINTED_PARTS: Array[String] = ["Blade", "Accent"]
const MELEE_TEXTURE_SCALE := 9.0

## Materials already built, by melee part name or by skin id. Kept for the
## whole session: a weapon must never outlive the material it is drawn with.
static var _materials := {}

const CHARACTER_KEY := "character"
const WEAPON_KEY := "weapon"
const MELEE_KEY := "melee"
const SKIN_KEY := "skin"
const MELEE_SKIN_KEY := "melee_skin"


static func is_unlocked(item: Dictionary) -> bool:
	if item.id == CHAMPION_SKIN_ID:
		return SaveData.load_progress(CHAMPION_KEY, false)
	return BattlePass.is_unlocked(item.id)


static func selected_character() -> Dictionary:
	return _selected(CHARACTERS, CHARACTER_KEY)


static func selected_weapon() -> Dictionary:
	return _selected(WEAPONS, WEAPON_KEY)


static func selected_melee() -> Dictionary:
	return _selected(MELEE, MELEE_KEY)


static func selected_skin() -> Dictionary:
	return _selected(SKINS, SKIN_KEY)


static func selected_melee_skin() -> Dictionary:
	return _selected(SKINS, MELEE_SKIN_KEY)


static func select(key: String, item: Dictionary) -> void:
	SaveData.save_value(key, item.id)


## Creates the animated model of a character skin.
static func instantiate_character(item: Dictionary) -> CharacterModel:
	var model: Node3D = load(CHARACTER_DIR + item.model).instantiate()
	model.set_script(CharacterModel)
	return model as CharacterModel


## Where a gun's model goes once held, for a given skin: {"basis" (turns the
## model, which lies along +X, toward -Z and scales it), "scale", "muzzle" and
## "scope" (points in the weapon's space, forward being -Z)}.
static func weapon_layout(item: Dictionary, skin: Dictionary) -> Dictionary:
	var data: Dictionary = WeaponModels.DATA[item.model]
	var low: Vector3 = data.min
	var high: Vector3 = data.max
	var s: float = item.length / (high.x - low.x)
	var layout := {
		"basis": Basis(Vector3(0, 0, -s), Vector3(0, s, 0), Vector3(s, 0, 0)),
		"scale": s,
		"muzzle": Vector3(0, data.barrel_y, -high.x) * s,
		"scope": Vector3(0, data.top_y, -(low.x + high.x) / 2.0) * s,
	}
	if skin.silencer:
		layout.silencer = layout.muzzle
		layout.muzzle += Vector3(0, 0, -SILENCER_LENGTH * s)
	return layout


## Creates a gun as held in the hand: grip at the origin, pointing toward -Z,
## with the skin's finish and accessories. `skin` defaults to the equipped one.
static func instantiate_weapon(item: Dictionary, skin := {}) -> Node3D:
	if skin.is_empty():
		skin = selected_skin()
	var layout := weapon_layout(item, skin)
	var gun := Node3D.new()
	_add_part(gun, item.model, layout.basis, Vector3.ZERO)
	if skin.scope and not item.get("has_scope", false):
		_add_part(gun, SCOPE_MODEL, layout.basis, layout.scope)
	if skin.silencer:
		_add_part(gun, SILENCER_MODEL, layout.basis, layout.silencer)
	_apply_skin(gun, skin)
	return gun


static func _add_part(gun: Node3D, model: String, basis: Basis, at: Vector3) -> void:
	var part := MeshInstance3D.new()
	part.mesh = load(GUN_DIR + model + ".obj")
	part.transform = Transform3D(basis, at)
	gun.add_child(part)


## Creates a melee weapon as held in the hand: its handle along +Y, the hand
## at the origin. `skin` (an entry of SKINS) repaints its blade; none by default.
static func instantiate_melee(item: Dictionary, skin := {}) -> Node3D:
	var part := MeshInstance3D.new()
	part.mesh = load(MELEE_DIR + item.model + ".obj")
	var finish: StandardMaterial3D = null
	if not skin.is_empty() and skin.pattern:
		finish = _finish(skin)
	for surface in part.mesh.get_surface_count():
		var part_name := part.mesh.surface_get_material(surface).resource_name
		if finish and part_name in MELEE_PAINTED_PARTS:
			part.set_surface_override_material(surface, finish)
		else:
			part.set_surface_override_material(surface, _melee_material(part_name))
	var held := Node3D.new()
	held.add_child(part)
	return held


## Box around a melee weapon's model, to frame it when it is shown alone.
static func melee_bounds(item: Dictionary) -> AABB:
	return (load(MELEE_DIR + item.model + ".obj") as Mesh).get_aabb()


## Shared by every weapon: one material per kind of part, made once.
static func _melee_material(part_name: String) -> StandardMaterial3D:
	if _materials.has(part_name):
		return _materials[part_name]
	var look: Array = MELEE_MATERIALS.get(part_name, MELEE_MATERIALS["Guard"])
	var material := StandardMaterial3D.new()
	var texture: String = look[0]
	if texture != "":
		material.albedo_texture = load(MELEE_TEXTURE_DIR + texture + ".png")
		material.uv1_triplanar = true
		material.uv1_scale = Vector3.ONE * MELEE_TEXTURE_SCALE
	material.albedo_color = look[1]
	material.metallic = look[2]
	material.roughness = look[3]
	# The generated models do not mind which way their faces turn.
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[part_name] = material
	return material


## Why a locked item is locked, for the menus.
static func unlock_text(item: Dictionary) -> String:
	if item.id == CHAMPION_SKIN_ID:
		return "Bats le boss final de la ville"
	return "Palier %d du passe de combat" % BattlePass.required_tier(item.id)


## Finds an item of any list by its id: {"item": ..., "kind": "Arme"}.
static func find(id: String) -> Dictionary:
	for group: Array in [["Personnage", CHARACTERS], ["Arme", WEAPONS], ["Corps à corps", MELEE], ["Skin d'arme", SKINS]]:
		for item: Dictionary in group[1]:
			if item.id == id:
				return {"item": item, "kind": group[0]}
	return {}


## Repaints the gun's body with the skin's pattern. Dark metal parts and
## glass keep their own material, so the gun stays readable.
static func _apply_skin(gun: Node3D, skin: Dictionary) -> void:
	if not skin.pattern:
		return
	var finish := _finish(skin)
	for part: MeshInstance3D in gun.get_children():
		for surface in part.mesh.get_surface_count():
			var original := part.mesh.surface_get_material(surface)
			if original == null or not original.resource_name in UNPAINTED_PARTS:
				part.set_surface_override_material(surface, finish)


## The material a skin paints with: its pattern, and its glow if it has one.
static func _finish(skin: Dictionary) -> StandardMaterial3D:
	if _materials.has(skin.id):
		return _materials[skin.id]
	var finish := StandardMaterial3D.new()
	finish.albedo_texture = load(SKIN_DIR + skin.id + ".png")
	finish.uv1_triplanar = true
	finish.uv1_scale = Vector3.ONE * PATTERN_SCALE
	finish.metallic = 0.4
	finish.roughness = 0.4
	finish.cull_mode = BaseMaterial3D.CULL_DISABLED
	if skin.glow > 0.0:
		finish.emission_enabled = true
		finish.emission = skin.shot
		finish.emission_energy_multiplier = skin.glow
	_materials[skin.id] = finish
	return finish


static func _selected(items: Array, key: String) -> Dictionary:
	var id: String = SaveData.load_value(key, items[0].id)
	for item: Dictionary in items:
		if item.id == id and is_unlocked(item):
			return item
	return items[0]
