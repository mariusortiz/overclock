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
	# Sold in the shop (see Shop): their ultimate is boosted ("boost" scales its
	# counts, damage, radius and duration; see Ultimate).
	{"id": "kunoichi", "ulti": &"clones", "name": "Kunoichi", "model": "Ninja_Female.fbx", "shop": true, "boost": 1.6},
	{"id": "captain", "ulti": &"broadside", "name": "Capitaine", "model": "Pirate_Female.fbx", "shop": true, "boost": 1.75},
	{"id": "ronin", "ulti": &"whirlwind", "name": "Ronin", "model": "Kimono_Female.fbx", "shop": true, "boost": 1.6},
	{"id": "paladin", "ulti": &"blessing", "name": "Paladine d'or", "model": "Knight_Golden_Female.fbx", "shop": true, "boost": 1.5},
	{"id": "godfather", "ulti": &"deadeye", "name": "Le Parrain", "model": "OldClassy_Male.fbx", "shop": true, "boost": 2.0},
	{"id": "sand_ghost", "ulti": &"timestop", "name": "Ombre des sables", "model": "Ninja_Sand_Female.fbx", "shop": true, "boost": 1.6},
	# Overpowered ("op"): far above the rest, sold dear. "fair" is what they
	# become in multiplayer, so that a purchase does not decide the match.
	{"id": "directeur", "ulti": &"timestop", "name": "Le Directeur", "model": "Suit_Male.fbx", "shop": true, "op": true, "boost": 3.0, "fair": {"boost": 1.6}},
	# Season 2 of the battle pass: a program of the Matrice, glowing green ("glow").
	{"id": "programme", "ulti": &"clones", "name": "Programme", "model": "Ninja_Male.fbx", "glow": Color(0.2, 1.0, 0.45), "boost": 1.4},
	# Le Créateur: the game's maker, the strongest of all, only with a code
	# ("code"), everywhere at full power. "health" and "speed" raise the
	# player's (see Player).
	{"id": "createur", "ulti": &"root", "name": "Le Créateur", "model": "Cow.fbx", "code": true, "boost": 3.0, "health": 300, "speed": 1.3},
	{"id": "commander", "ulti": &"airstrike", "name": "Commandant", "model": "BlueSoldier_Male.fbx", "shop": true, "op": true, "boost": 3.0, "fair": {"boost": 1.6}},
]

## Weapon skins are finishes: they keep the gun's shape. A skin with a pattern
## (assets/textures/skins/<id>.png, see tools/make_skin_textures.py) repaints
## the gun's body; "glow" makes it emit light; "scope" and "silencer" mount
## accessories; "shot" colors the tracer, the impact and the muzzle flash;
## "kill" is the way enemies die when shot with it, one per skin (see
## Enemy._play_death).
const SKINS := [
	{"id": "skin_standard", "kill": &"knockback", "name": "Standard", "pattern": false, "glow": 0.0, "scope": false, "silencer": false, "shot": Color(1.0, 0.85, 0.4)},
	{"id": "skin_neon", "kill": &"vanish", "name": "Néon", "pattern": true, "glow": 0.5, "scope": false, "silencer": false, "shot": Color(0.0, 0.9, 1.0)},
	{"id": "skin_ice", "kill": &"shatter", "name": "Glace", "pattern": true, "glow": 0.15, "scope": true, "silencer": false, "shot": Color(0.65, 0.9, 1.0)},
	{"id": "skin_lava", "kill": &"burn", "name": "Lave", "pattern": true, "glow": 0.5, "scope": false, "silencer": false, "shot": Color(1.0, 0.4, 0.1)},
	{"id": "skin_camo", "kill": &"leaves", "name": "Camouflage", "pattern": true, "glow": 0.0, "scope": false, "silencer": true, "shot": Color(0.7, 0.9, 0.3)},
	{"id": "skin_toxic", "kill": &"melt", "name": "Toxique", "pattern": true, "glow": 0.4, "scope": true, "silencer": false, "shot": Color(0.6, 1.0, 0.1)},
	{"id": "skin_royal", "kill": &"ascend", "name": "Royal", "pattern": true, "glow": 0.1, "scope": true, "silencer": false, "shot": Color(0.7, 0.4, 1.0)},
	{"id": "skin_carbon", "kill": &"pixelate", "name": "Carbone", "pattern": true, "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1, 1, 1)},
	{"id": "skin_sakura", "kill": &"petals", "name": "Sakura", "pattern": true, "glow": 0.1, "scope": false, "silencer": false, "shot": Color(1.0, 0.5, 0.8)},
	{"id": "skin_ocean", "kill": &"splash", "name": "Océan", "pattern": true, "glow": 0.15, "scope": false, "silencer": true, "shot": Color(0.2, 0.6, 1.0)},
	{"id": "skin_solar", "kill": &"flare", "name": "Solaire", "pattern": true, "glow": 0.3, "scope": false, "silencer": true, "shot": Color(1.0, 0.9, 0.3)},
	{"id": "skin_gold", "kill": &"statue", "name": "Or", "pattern": true, "glow": 0.2, "scope": true, "silencer": true, "shot": Color(1.0, 0.85, 0.3)},
	# Not in the battle pass: earned by beating the final boss.
	{"id": "skin_champion", "kill": &"confetti", "name": "Champion", "pattern": true, "glow": 0.6, "scope": true, "silencer": true, "shot": Color(1.0, 0.3, 0.9)},
	# Sold in the shop: animated finishes (shaders/skin_fx.gdshader, "fx" is
	# its mode) instead of a printed pattern.
	{"id": "skin_holo", "kill": &"vanish", "name": "Hologramme", "pattern": true, "fx": 0, "colors": [Color(0.0, 0.9, 1.0), Color(0.05, 0.15, 0.35)], "glow": 0.0, "scope": true, "silencer": false, "shot": Color(0.3, 1.0, 1.0), "shop": true},
	{"id": "skin_galaxy", "kill": &"ascend", "name": "Galaxie", "pattern": true, "fx": 1, "colors": [Color(1.0, 0.95, 1.0), Color(0.12, 0.03, 0.25)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.75, 0.5, 1.0), "shop": true},
	{"id": "skin_plasma", "kill": &"burn", "name": "Plasma", "pattern": true, "fx": 2, "colors": [Color(1.0, 0.45, 0.05), Color(0.9, 0.05, 0.6)], "glow": 0.0, "scope": false, "silencer": false, "shot": Color(1.0, 0.35, 0.6), "shop": true},
	{"id": "skin_glitch", "kill": &"pixelate", "name": "Glitch", "pattern": true, "fx": 3, "colors": [Color(0.1, 1.0, 0.4), Color(1.0, 0.1, 0.5)], "glow": 0.0, "scope": false, "silencer": true, "shot": Color(0.3, 1.0, 0.5), "shop": true},
	{"id": "skin_prism", "kill": &"confetti", "name": "Prisme", "pattern": true, "fx": 4, "colors": [Color.WHITE, Color.WHITE], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1.0, 1.0, 1.0), "shop": true},
	{"id": "skin_storm", "kill": &"vanish", "name": "Foudre", "pattern": true, "fx": 5, "colors": [Color(0.75, 0.9, 1.0), Color(0.03, 0.04, 0.12)], "glow": 0.0, "scope": true, "silencer": false, "shot": Color(0.7, 0.9, 1.0), "shop": true, "op": true},
	{"id": "skin_matrix", "kill": &"pixelate", "name": "Matrice", "pattern": true, "fx": 7, "colors": [Color(0.2, 1.0, 0.45), Color(0.0, 0.03, 0.01)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.3, 1.0, 0.5), "code": true},
	{"id": "skin_void", "kill": &"ascend", "name": "Trou noir", "pattern": true, "fx": 6, "colors": [Color(1.0, 0.45, 0.1), Color(0.0, 0.0, 0.0)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1.0, 0.5, 0.15), "shop": true, "op": true},
	# Sold during the Christmas event only ("event", see Events): kept after it.
	{"id": "skin_candy", "kill": &"candy", "name": "Sucre d'orge", "pattern": true, "fx": 8, "colors": [Color(0.95, 0.1, 0.15), Color(1.0, 1.0, 1.0)], "glow": 0.0, "scope": false, "silencer": true, "shot": Color(1.0, 0.4, 0.45), "shop": true, "event": "christmas"},
	{"id": "skin_flake", "kill": &"snow", "name": "Flocon", "pattern": true, "fx": 9, "colors": [Color(0.85, 0.95, 1.0), Color(0.15, 0.3, 0.55)], "glow": 0.0, "scope": true, "silencer": false, "shot": Color(0.8, 0.95, 1.0), "shop": true, "event": "christmas"},
	{"id": "skin_garland", "kill": &"lights", "name": "Guirlande", "pattern": true, "fx": 10, "colors": [Color(1.0, 0.85, 0.3), Color(0.05, 0.2, 0.08)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1.0, 0.85, 0.3), "shop": true, "event": "christmas"},
	# Season 2 of the battle pass (BattlePass.REWARDS_2).
	{"id": "skin_data", "kill": &"pixelate", "name": "Données", "pattern": true, "fx": 7, "colors": [Color(0.35, 0.75, 1.0), Color(0.0, 0.02, 0.07)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.4, 0.8, 1.0)},
	{"id": "skin_firewall", "kill": &"burn", "name": "Pare-feu", "pattern": true, "fx": 2, "colors": [Color(1.0, 0.3, 0.1), Color(0.5, 0.0, 0.05)], "glow": 0.0, "scope": false, "silencer": false, "shot": Color(1.0, 0.4, 0.15)},
	{"id": "skin_corruption", "kill": &"melt", "name": "Corruption", "pattern": true, "fx": 3, "colors": [Color(0.2, 1.0, 0.45), Color(0.02, 0.05, 0.03)], "glow": 0.0, "scope": true, "silencer": false, "shot": Color(0.3, 1.0, 0.5)},
	{"id": "skin_binary", "kill": &"vanish", "name": "Binaire", "pattern": true, "fx": 0, "colors": [Color(0.85, 1.0, 0.9), Color(0.02, 0.12, 0.06)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.8, 1.0, 0.85)},
	{"id": "skin_kernel", "kill": &"ascend", "name": "Noyau", "pattern": true, "fx": 6, "colors": [Color(0.2, 1.0, 0.45), Color(0.0, 0.0, 0.0)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.3, 1.0, 0.5)},
	# Not sold: the fiftieth achievement, Platine (see Achievements).
	{"id": "skin_platinum", "kill": &"flare", "name": "Platine", "pattern": true, "fx": 1, "colors": [Color(0.95, 0.97, 1.0), Color(0.35, 0.38, 0.45)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(0.9, 0.95, 1.0)},
	# Not sold: earned by completing the card album (see Cards).
	{"id": "skin_collector", "kill": &"ascend", "name": "Collectionneur", "pattern": true, "fx": 1, "colors": [Color(1.0, 0.85, 0.35), Color(0.2, 0.08, 0.02)], "glow": 0.0, "scope": true, "silencer": true, "shot": Color(1.0, 0.85, 0.35)},
]
## How each skin's elimination looks, for the armory.
const KILL_NAMES := {
	&"knockback": "projeté dans un nuage de fumée", &"vanish": "rayon de lumière", &"shatter": "gel puis éclats",
	&"burn": "braises", &"leaves": "feuilles", &"melt": "flaque toxique", &"ascend": "envol royal",
	&"pixelate": "pixels noirs", &"petals": "pétales", &"splash": "gerbe d'eau", &"flare": "flash solaire",
	&"statue": "statue d'or", &"confetti": "confettis",
}
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
	# Exotic guns, sold in the shop. "beam": a thick continuous ray; "pierce":
	# the shot goes through every enemy in line; "range": shorter reach;
	# "ignite": sets the enemies hit on fire (that many seconds' worth).
	{"id": "laser", "name": "Laser", "model": "Blaster_Laser", "length": 0.62, "fire_rate": 15.0, "damage": 1, "magazine": 80, "reload_time": 1.8, "zoom_fov": 40.0, "beam": true, "shop": true},
	{"id": "railgun", "name": "Fusil à rail", "model": "Blaster_Rail", "length": 1.05, "fire_rate": 1.1, "damage": 9, "magazine": 4, "reload_time": 2.0, "zoom_fov": 22.0, "pierce": true, "beam": true, "shop": true},
	{"id": "plasma", "name": "Canon plasma", "model": "Blaster_Plasma", "length": 0.68, "fire_rate": 2.2, "damage": 5, "magazine": 8, "reload_time": 1.8, "zoom_fov": 40.0, "blast_radius": 3.0, "shop": true},
	{"id": "flamer", "name": "Lance-flammes", "model": "Blaster_Flame", "length": 0.6, "fire_rate": 8.0, "damage": 1, "magazine": 60, "reload_time": 2.0, "zoom_fov": 40.0, "pellets": 2, "spread": 9.0, "range": 11.0, "ignite": 1, "shop": true},
	{"id": "flechette", "name": "Lance-fléchettes", "model": "Blaster_Flechette", "length": 0.7, "fire_rate": 3.0, "damage": 2, "magazine": 10, "reload_time": 1.6, "zoom_fov": 36.0, "pellets": 5, "spread": 2.5, "pierce": true, "shop": true},
	{"id": "minigun", "name": "Minigun", "model": "Blaster_Minigun", "length": 1.0, "fire_rate": 24.0, "damage": 1, "magazine": 150, "reload_time": 3.2, "zoom_fov": 44.0, "shop": true},
	{"id": "source_code", "name": "Code source", "model": "Blaster_Rail", "length": 0.8, "fire_rate": 8.0, "damage": 40, "magazine": 200, "reload_time": 0.5, "zoom_fov": 24.0, "pierce": true, "beam": true, "code": true, "finish": "skin_matrix"},
	{"id": "annihilator", "name": "Annihilateur", "model": "Blaster_Plasma", "length": 0.8, "fire_rate": 5.0, "damage": 12, "magazine": 30, "reload_time": 1.0, "zoom_fov": 36.0, "blast_radius": 5.0, "shop": true, "op": true, "finish": "skin_plasma",
		"fair": {"fire_rate": 2.2, "damage": 5, "magazine": 8, "reload_time": 1.8, "blast_radius": 3.0}},
	{"id": "golden_gun", "name": "Pistolet d'or", "model": "Pistol_6", "length": 0.49, "fire_rate": 2.5, "damage": 99, "magazine": 6, "reload_time": 0.8, "zoom_fov": 30.0, "pierce": true, "shop": true, "op": true, "finish": "skin_gold",
		"fair": {"fire_rate": 2.0, "damage": 6, "pierce": false}},
]

## Ships of the race. "design" is the hull (RaceShip._build_model);
## "velocity" scales the top speed, "handling" the steering, "fire" the rate
## of fire; "shield" is the hits it takes before exploding. "special" is the
## ability the gauge triggers (see Race._apply_special). The Dart is there from
## the start, the others come with the battle pass.
const SHIPS := [
	{"id": "ship_dart", "name": "Dard", "design": 0, "color": Color(0.16, 0.9, 1.0), "velocity": 1.0, "handling": 1.0, "shield": 3, "fire": 1.0, "special": &"surboost"},
	# Season 2 of the battle pass.
	{"id": "ship_firewall", "name": "Pare-feu", "design": 5, "color": Color(1.0, 0.3, 0.1), "hull": Color(0.12, 0.03, 0.02), "velocity": 1.1, "handling": 1.15, "shield": 4, "fire": 1.2, "special": &"emp"},
	{"id": "ship_falcon", "name": "Faucon", "design": 1, "color": Color(1.0, 0.3, 0.2), "velocity": 1.06, "handling": 1.1, "shield": 2, "fire": 1.0, "special": &"salvo"},
	{"id": "ship_ram", "name": "Bélier", "design": 3, "color": Color(1.0, 0.65, 0.1), "velocity": 0.95, "handling": 0.8, "shield": 5, "fire": 0.8, "special": &"rampart"},
	{"id": "ship_specter", "name": "Spectre", "design": 4, "color": Color(0.7, 0.45, 1.0), "velocity": 1.0, "handling": 1.3, "shield": 2, "fire": 1.0, "special": &"cloak"},
	{"id": "ship_comet", "name": "Comète", "design": 5, "color": Color(1.0, 0.85, 0.3), "velocity": 1.04, "handling": 0.9, "shield": 3, "fire": 0.9, "special": &"warp"},
	{"id": "ship_hornet", "name": "Frelon", "design": 6, "color": Color(0.5, 1.0, 0.3), "velocity": 1.0, "handling": 1.1, "shield": 3, "fire": 1.6, "special": &"missile"},
	{"id": "ship_storm", "name": "Tempête", "design": 2, "color": Color(0.3, 0.6, 1.0), "velocity": 0.98, "handling": 1.0, "shield": 4, "fire": 1.0, "special": &"emp"},
	{"id": "ship_nova", "name": "Nova", "design": 7, "color": Color(1.0, 0.35, 0.75), "velocity": 1.02, "handling": 1.0, "shield": 3, "fire": 1.1, "special": &"mines"},
	# Sold in the shop, overpowered; "hull" darkens or tints the body.
	{"id": "ship_omega", "name": "Oméga", "design": 7, "color": Color(1.0, 0.8, 0.25), "hull": Color(0.1, 0.1, 0.12), "velocity": 1.22, "handling": 1.35, "shield": 6, "fire": 1.8, "special": &"hyperdrive", "shop": true, "op": true,
		"fair": {"velocity": 1.04, "handling": 1.1, "shield": 3, "fire": 1.1, "special": &"surboost"}},
	{"id": "ship_reaper", "name": "Faucheuse", "design": 1, "color": Color(1.0, 0.1, 0.15), "hull": Color(0.18, 0.05, 0.07), "velocity": 1.18, "handling": 1.2, "shield": 4, "fire": 2.2, "special": &"blackhole", "shop": true, "op": true,
		"fair": {"velocity": 1.04, "handling": 1.1, "shield": 3, "fire": 1.1, "special": &"salvo"}},
	# Le Créateur's ship, only with a code: the fastest and toughest.
	{"id": "ship_mainframe", "name": "Mainframe", "design": 7, "color": Color(0.2, 1.0, 0.45), "hull": Color(0.03, 0.05, 0.04), "velocity": 1.4, "handling": 1.7, "shield": 10, "fire": 3.0, "special": &"admin", "code": true},
	# Earned by finishing the story mode's season 1 (see Story): Vipère's ship.
	{"id": "ship_scarlet", "name": "Écarlate", "design": 1, "color": Color(1.0, 0.2, 0.15), "hull": Color(0.55, 0.08, 0.1), "velocity": 1.08, "handling": 1.15, "shield": 3, "fire": 1.2, "special": &"salvo", "story": true},
	{"id": "ship_aurora", "name": "Aurore", "design": 4, "color": Color(0.3, 1.0, 0.85), "hull": Color(0.95, 0.97, 1.0), "velocity": 1.2, "handling": 1.5, "shield": 5, "fire": 1.5, "special": &"chronos", "shop": true, "op": true,
		"fair": {"velocity": 1.04, "handling": 1.1, "shield": 3, "fire": 1.1, "special": &"emp"}},
]
## What each special does, for the armory and the race.
const SHIP_SPECIALS := {
	&"surboost": ["SURBOOST", "4 s de vitesse maximale"],
	&"salvo": ["RAFALE", "Touche tous les vaisseaux devant toi"],
	&"rampart": ["REMPART", "Intouchable 4 s, renverse ceux qu'il percute"],
	&"cloak": ["CAMOUFLAGE", "Invisible et intouchable 4 s"],
	&"warp": ["HYPERPROPULSION", "Bond de 70 m en avant"],
	&"missile": ["MISSILE GUIDÉ", "Ne rate jamais le vaisseau devant toi"],
	&"emp": ["ONDE EMP", "Ralentit tous les vaisseaux proches"],
	&"mines": ["MINES", "Sème 3 mines derrière toi"],
	&"hyperdrive": ["HYPERDRIVE", "6 s de vitesse maximale, intouchable"],
	&"blackhole": ["TROU NOIR", "Touche deux fois tous les vaisseaux devant toi"],
	&"chronos": ["CHRONOS", "Ralentit tous les autres vaisseaux 3 s"],
	&"admin": ["ACCÈS ADMIN", "Touche deux fois et ralentit tous les autres, puis 5 s de vitesse max intouchable"],
}

const GUN_DIR := "res://assets/models/guns/"
const SKIN_DIR := "res://assets/textures/skins/"
const SCOPE_MODEL := "Scope_2"
const SILENCER_MODEL := "Silencer_Short"
const SILENCER_LENGTH := 0.78  # in model units
## The scope and the silencer are drawn for the Quaternius guns. On an exotic
## gun (another kit, at another scale) they get the size they have on an
## assault rifle, a little smaller on a short gun.
## Scopes and silencers: smaller than the gun's own scale (ACCESSORY_SHRINK),
## and for the exotic guns, whose models are drawn bigger, a fixed size.
const ACCESSORY_SCALE := 0.13
const ACCESSORY_SHRINK := 0.65
const RIFLE_LENGTH := 0.95
## Parts of a gun that a skin leaves alone (material names of the models).
const UNPAINTED_PARTS: Array[String] = ["Black", "Black2", "Glass", "DarkMetal"]
const PATTERN_SCALE := 0.6
const SKIN_FX_SHADER := preload("res://shaders/skin_fx.gdshader")
## The animated finishes' cells are this many times smaller than a pattern's.
const SKIN_FX_SCALE := 4.0

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
	# Le Créateur's blade, only with a code.
	{"id": "ctrl_alt_del", "name": "Ctrl+Alt+Suppr", "model": "sword", "code": true,
		"damage": 99, "range": 4.0, "cooldown": 0.35, "sweep": true, "cone": 120.0, "knockback": 6.0},
]

const MELEE_DIR := "res://assets/models/melee/"
const MELEE_TEXTURE_DIR := "res://assets/textures/melee/"
## Look of each part of a melee weapon, by the material name it has in the
## model: [texture or "", color, metallic, roughness].
const MELEE_MATERIALS := {
	"Blade": ["steel", Color(0.95, 0.97, 1.0), 0.45, 0.35],
	"Edge": ["", Color(1.0, 1.0, 1.0), 0.3, 0.25],
	"Wood": ["wood", Color.WHITE, 0.0, 0.7],
	"Grip": ["grip", Color.WHITE, 0.0, 0.85],
	"Wrap": ["wrap", Color.WHITE, 0.0, 0.8],
	"Guard": ["steel", Color(0.36, 0.36, 0.42), 0.5, 0.4],
	"Brass": ["", Color(0.9, 0.68, 0.28), 0.5, 0.35],
	"Accent": ["", Color(0.75, 0.12, 0.12), 0.3, 0.5],
}
## Parts of a melee weapon that a skin repaints.
const MELEE_PAINTED_PARTS: Array[String] = ["Blade", "Accent"]
const MELEE_TEXTURE_SCALE := 9.0
## A blade is small: the skin's pattern is drawn finer on it than on a gun.
const MELEE_PATTERN_SCALE := 4.0
## Length above the hand, in meters, from which a weapon counts as long.
const MELEE_LONG := 0.78

## Materials already built, by melee part name or by skin and scale. Kept for the
## whole session: a weapon must never outlive the material it is drawn with.
static var _materials := {}

const CHARACTER_KEY := "character"
const WEAPON_KEY := "weapon"
const MELEE_KEY := "melee"
const SKIN_KEY := "skin"
const MELEE_SKIN_KEY := "melee_skin"
const SHIP_KEY := "ship"


static func is_unlocked(item: Dictionary) -> bool:
	if Pets.is_pet(item):
		return Pets.is_owned(item)
	if item.id == Cards.COLLECTOR_SKIN_ID:
		return Cards.album_complete()
	if item.id == Achievements.PLATINUM_SKIN:
		return Achievements.is_done("platinum")
	if item.get("shop", false):
		return Wallet.owns(item.id)
	if item.id == CHAMPION_SKIN_ID:
		return SaveData.load_progress(CHAMPION_KEY, false)
	if item.get("story", false):
		return Story.season_done()
	if item.get("code", false):
		return Wallet.owns(item.id)
	return BattlePass.is_unlocked(item.id)


static func selected_character() -> Dictionary:
	if story_hero != "":
		return find(story_hero).item
	return fair(_selected(CHARACTERS, CHARACTER_KEY))


static func selected_weapon() -> Dictionary:
	if story_weapon != "":
		return find(story_weapon).item
	return fair(_selected(WEAPONS, WEAPON_KEY))


static func selected_melee() -> Dictionary:
	return _selected(MELEE, MELEE_KEY)


static func selected_skin() -> Dictionary:
	return _selected(SKINS, SKIN_KEY)


static func selected_melee_skin() -> Dictionary:
	return _selected(SKINS, MELEE_SKIN_KEY)


static func selected_ship() -> Dictionary:
	if story_ship != "":
		return find(story_ship).item
	return _selected(SHIPS, SHIP_KEY)


## On during a multiplayer match (set by Net): overpowered items play as
## their "fair" version.
static var fair_play := false
## Set by the story mode (see Story): the hero, gun and ship the chapter
## imposes, whatever is equipped. Empty outside the story.
static var story_hero := ""
static var story_weapon := ""
static var story_ship := ""


## The item as it plays now: its "fair" version in multiplayer.
static func fair(item: Dictionary) -> Dictionary:
	if not fair_play or not item.has("fair"):
		return item
	var played := item.duplicate()
	played.merge(item.fair, true)
	return played


static func select(key: String, item: Dictionary) -> void:
	SaveData.save_value(key, item.id)


## Creates the animated model of a character skin.
static func instantiate_character(item: Dictionary) -> CharacterModel:
	var model: Node3D = load(CHARACTER_DIR + item.model).instantiate()
	model.set_script(CharacterModel)
	if item.has("glow"):
		glow(model, item.glow)
	return model as CharacterModel


## A hero's own glow (Programme): a light layer of its color over the model.
static func glow(model: Node, color: Color) -> void:
	var layer := StandardMaterial3D.new()
	layer.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	layer.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	layer.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	layer.albedo_color = Color(color, 0.3)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = layer


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
	# The exotic "Blaster" models are drawn bigger than the pack's guns.
	var exotic := str(item.model).begins_with("Blaster")
	var a := s * ACCESSORY_SHRINK if not exotic else ACCESSORY_SCALE * clampf(item.length / RIFLE_LENGTH, 0.65, 1.0)
	layout.accessory_basis = Basis(Vector3(0, 0, -a), Vector3(0, a, 0), Vector3(a, 0, 0))
	if skin.silencer:
		layout.silencer = layout.muzzle
		layout.muzzle += Vector3(0, 0, -SILENCER_LENGTH * a)
	return layout


## Creates a gun as held in the hand: grip at the origin, pointing toward -Z,
## with the skin's finish and accessories. `skin` defaults to the equipped one.
static func instantiate_weapon(item: Dictionary, skin := {}) -> Node3D:
	if skin.is_empty():
		skin = selected_skin()
	# Some guns come with their own finish, worn unless another skin is chosen.
	if item.has("finish") and skin.id == SKINS[0].id:
		skin = find(item.finish).item
	var layout := weapon_layout(item, skin)
	var gun := Node3D.new()
	_add_part(gun, item.model, layout.basis, Vector3.ZERO)
	if skin.scope and not item.get("has_scope", false):
		_add_part(gun, SCOPE_MODEL, layout.accessory_basis, layout.scope)
	if skin.silencer:
		_add_part(gun, SILENCER_MODEL, layout.accessory_basis, layout.silencer)
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
	var held := Node3D.new()
	held.add_child(melee_part(item.model, skin))
	return held


## One model of assets/models/melee with its materials and, on its blade, the
## skin's finish. A weapon is one model; the butterfly knife also exists in
## separate parts (see Inspection).
static func melee_part(model: String, skin := {}) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = load(MELEE_DIR + model + ".obj")
	var finish: Material = null
	if not skin.is_empty() and skin.pattern:
		finish = _finish(skin, MELEE_PATTERN_SCALE)
	for surface in part.mesh.get_surface_count():
		var part_name := part.mesh.surface_get_material(surface).resource_name
		if finish and part_name in MELEE_PAINTED_PARTS:
			part.set_surface_override_material(surface, finish)
		else:
			part.set_surface_override_material(surface, _melee_material(part_name))
	return part


## How a melee weapon is carried at rest. A long one is held tip up, along
## the forearm, so that it does not drag on the ground; a short one would
## disappear behind the arm, so it points forward, out of the fist.
static func is_carried_tip_up(item: Dictionary) -> bool:
	return melee_bounds(item).end.y > MELEE_LONG


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
	if Pets.is_pet(item):
		return Pets.unlock_text(item)
	if item.id == Cards.COLLECTOR_SKIN_ID:
		return "Complète l'album de cartes"
	if item.id == Achievements.PLATINUM_SKIN:
		return "Débloque les 50 succès"
	if item.get("event", "") == "christmas":
		return "Boutique de Noël (1er décembre – 6 janvier)"
	if item.get("shop", false):
		return "En vente à la boutique"
	if item.id == CHAMPION_SKIN_ID:
		return "Bats le boss final de la ville"
	if item.get("story", false):
		return "Termine la saison 1 du mode histoire"
	if item.get("code", false):
		return "Uniquement avec un code"
	if BattlePass.season_of(item.id) == 1:
		return "Palier %d du passe saison 2" % BattlePass.required_tier(item.id)
	return "Palier %d du passe de combat" % BattlePass.required_tier(item.id)


## Finds an item of any list by its id: {"item": ..., "kind": "Arme"}.
static func find(id: String) -> Dictionary:
	for group: Array in [["Personnage", CHARACTERS], ["Arme", WEAPONS], ["Corps à corps", MELEE], ["Skin d'arme", SKINS], ["Vaisseau", SHIPS], ["Animal", Pets.LIST]]:
		for item: Dictionary in group[1]:
			if item.id == id:
				return {"item": item, "kind": group[0]}
	return {}


## Repaints the gun's body with the skin's pattern. Dark metal parts and
## glass keep their own material, so the gun stays readable.
static func _apply_skin(gun: Node3D, skin: Dictionary) -> void:
	if not skin.pattern:
		return
	var finish := _finish(skin, PATTERN_SCALE)
	for part: MeshInstance3D in gun.get_children():
		for surface in part.mesh.get_surface_count():
			var original := part.mesh.surface_get_material(surface)
			if original == null or not original.resource_name in UNPAINTED_PARTS:
				part.set_surface_override_material(surface, finish)


## The material a skin paints with: its pattern, repeated every 1 / `scale`
## meters, and its glow if it has one.
static func _finish(skin: Dictionary, scale: float) -> Material:
	var key := "%s %s" % [skin.id, scale]
	if _materials.has(key):
		return _materials[key]
	if skin.has("fx"):
		var animated := ShaderMaterial.new()
		animated.shader = SKIN_FX_SHADER
		animated.set_shader_parameter("mode", skin.fx)
		animated.set_shader_parameter("color_a", skin.colors[0])
		animated.set_shader_parameter("color_b", skin.colors[1])
		animated.set_shader_parameter("scale", scale * SKIN_FX_SCALE)
		_materials[key] = animated
		return animated
	var finish := StandardMaterial3D.new()
	finish.albedo_texture = load(SKIN_DIR + skin.id + ".png")
	finish.uv1_triplanar = true
	finish.uv1_scale = Vector3.ONE * scale
	finish.metallic = 0.4
	finish.roughness = 0.4
	finish.cull_mode = BaseMaterial3D.CULL_DISABLED
	if skin.glow > 0.0:
		finish.emission_enabled = true
		finish.emission = skin.shot
		finish.emission_energy_multiplier = skin.glow
	_materials[key] = finish
	return finish


static func _selected(items: Array, key: String) -> Dictionary:
	var id: String = SaveData.load_value(key, items[0].id)
	for item: Dictionary in items:
		if item.id == id and is_unlocked(item):
			return item
	return items[0]
