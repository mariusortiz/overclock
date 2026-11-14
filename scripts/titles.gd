class_name Titles
## Profile titles and banners. A title shows under the hero's name (home,
## lobby, above the other players online); the banner is its background.
## Chosen in the profile (TITRE & BANNIÈRE).
##
## How each is earned: "ach" (an achievement), "pass" ([season, tier], -1 for
## the whole pass), "gems" (bought in the profile), "count" (that many
## achievements), "gift" (given by something else, see Weekly), or nothing
## (free).

const TITLE_KEY := "title"
const BANNER_KEY := "banner"

const NO_TITLE := {"id": "title_none", "name": "Sans titre"}
const TITLES: Array[Dictionary] = [
	NO_TITLE,
	{"id": "title_legend", "name": "Légende vivante", "ach": "kills_4"},
	{"id": "title_hawk", "name": "Œil de faucon", "ach": "head_3"},
	{"id": "title_blade", "name": "Lame affûtée", "ach": "melee_2"},
	{"id": "title_giant", "name": "Tueur de géants", "ach": "boss_3"},
	{"id": "title_elite", "name": "Chasseur d'élites", "ach": "elite_2"},
	{"id": "title_rock", "name": "Inébranlable", "ach": "waves_3"},
	{"id": "title_overload", "name": "Surchargé", "ach": "ulti_2"},
	{"id": "title_addict", "name": "Accro", "ach": "games_3"},
	{"id": "title_endless", "name": "Sans fin", "ach": "wave_40"},
	{"id": "title_archivist", "name": "Archiviste", "ach": "cards_3"},
	{"id": "title_storyteller", "name": "Conteur", "ach": "stars_3"},
	{"id": "title_champion", "name": "Champion", "ach": "champion"},
	{"id": "title_antivirus", "name": "Antivirus", "ach": "virus"},
	{"id": "title_elf", "name": "Lutin en chef", "ach": "christmas"},
	{"id": "title_arcade", "name": "Roi de l'arcade", "ach": "arcade"},
	{"id": "title_ruthless", "name": "Sans pitié", "ach": "fight_hard"},
	{"id": "title_pilot", "name": "Pilote", "ach": "race"},
	{"id": "title_conqueror", "name": "Conquérant", "ach": "capture"},
	{"id": "title_breeder", "name": "Éleveur", "ach": "breeder"},
	{"id": "title_platinum", "name": "Platine", "ach": "platinum"},
	{"id": "title_recruit", "name": "Recrue", "pass": [0, 10]},
	{"id": "title_veteran", "name": "Vétéran", "pass": [0, -1]},
	{"id": "title_admin", "name": "Administrateur", "pass": [1, 35]},
	{"id": "title_programmed", "name": "Programmé", "pass": [1, -1]},
	{"id": "title_sunday", "name": "Pro du dimanche", "gems": 150},
	{"id": "title_sore", "name": "Mauvais perdant", "gems": 150},
	{"id": "title_bug", "name": "Bug ambulant", "gems": 250},
	{"id": "title_capyfan", "name": "Fan de capybara", "gems": 300},
	{"id": "title_boss", "name": "Le Boss", "gems": 500},
	{"id": "title_vip", "name": "VIP", "gems": 800},
]

## "mode" is the pattern of shaders/banner.gdshader, "colors" its two colors.
const BANNERS: Array[Dictionary] = [
	{"id": "banner_neon", "name": "Néon", "mode": 0, "colors": [Color(0.16, 0.83, 1.0), Color(1.0, 0.24, 0.95)]},
	{"id": "banner_grid", "name": "Grille", "mode": 1, "colors": [Color(0.16, 0.83, 1.0), Color(0.03, 0.05, 0.15)], "count": 5},
	{"id": "banner_stars", "name": "Étoiles", "mode": 2, "colors": [Color(1.0, 1.0, 1.0), Color(0.05, 0.02, 0.15)], "count": 15},
	{"id": "banner_waves", "name": "Vagues", "mode": 3, "colors": [Color(0.3, 0.75, 1.0), Color(0.02, 0.15, 0.35)], "count": 25},
	{"id": "banner_fire", "name": "Brasier", "mode": 4, "colors": [Color(1.0, 0.75, 0.1), Color(0.6, 0.05, 0.02)], "count": 35},
	{"id": "banner_code", "name": "Code", "mode": 5, "colors": [Color(0.2, 1.0, 0.45), Color(0.0, 0.04, 0.01)], "pass": [1, 35]},
	{"id": "banner_stripes", "name": "Rayures", "mode": 6, "colors": [Color(1.0, 0.85, 0.3), Color(0.1, 0.1, 0.12)], "gems": 120},
	{"id": "banner_aurora", "name": "Aurore", "mode": 7, "colors": [Color(0.3, 1.0, 0.7), Color(0.55, 0.2, 1.0)], "gift": "Coffre des missions de la semaine"},
	{"id": "banner_hex", "name": "Hexagones", "mode": 8, "colors": [Color(1.0, 0.3, 0.6), Color(0.12, 0.02, 0.1)], "gems": 120},
	{"id": "banner_gold", "name": "Or", "mode": 9, "colors": [Color(1.0, 0.85, 0.35), Color(0.4, 0.25, 0.05)], "ach": "platinum"},
	{"id": "banner_ice", "name": "Glace", "mode": 10, "colors": [Color(0.85, 0.97, 1.0), Color(0.2, 0.45, 0.7)], "ach": "christmas"},
	{"id": "banner_sunset", "name": "Couchant", "mode": 11, "colors": [Color(1.0, 0.55, 0.2), Color(0.45, 0.1, 0.45)], "gems": 200},
]
const BANNER_SHADER := preload("res://shaders/banner.gdshader")


static func is_unlocked(item: Dictionary) -> bool:
	if item.has("ach"):
		return Achievements.is_done(item.ach)
	if item.has("pass"):
		var season: int = item.pass[0]
		var tier: int = item.pass[1]
		if tier < 0:
			tier = BattlePass.rewards(season).size()
		return BattlePass.progress(season).tier >= tier
	if item.has("count"):
		return Achievements.done_count() >= item.count
	if item.has("gems") or item.has("gift"):
		return Wallet.owns(item.id)
	return true


static func unlock_text(item: Dictionary) -> String:
	if item.has("ach"):
		for achievement: Dictionary in Achievements.LIST:
			if achievement.id == item.ach:
				return "Succès « %s » : %s" % [achievement.name, achievement.text]
	if item.has("pass"):
		var season: int = item.pass[0]
		if item.pass[1] < 0:
			return "Termine le passe saison %d" % (season + 1)
		return "Palier %d du passe saison %d" % [item.pass[1], season + 1]
	if item.has("count"):
		return "Débloque %d succès" % item.count
	if item.has("gems"):
		return "%d gemmes" % item.gems
	if item.has("gift"):
		return item.gift
	return "Offert"


static func selected_title() -> Dictionary:
	return _selected(TITLES, TITLE_KEY)


static func selected_banner() -> Dictionary:
	return _selected(BANNERS, BANNER_KEY)


static func select(key: String, item: Dictionary) -> void:
	SaveData.save_value(key, item.id)


## The title as shown ("" without one).
static func title_text() -> String:
	var title := selected_title()
	return "" if title.id == NO_TITLE.id else str(title.name)


static func find_banner(id: String) -> Dictionary:
	for banner: Dictionary in BANNERS:
		if banner.id == id:
			return banner
	return BANNERS[0]


## A rectangle painted with the banner.
static func banner_rect(banner: Dictionary) -> ColorRect:
	var rect := ColorRect.new()
	var material := ShaderMaterial.new()
	material.shader = BANNER_SHADER
	material.set_shader_parameter("mode", banner.mode)
	material.set_shader_parameter("color_a", banner.colors[0])
	material.set_shader_parameter("color_b", banner.colors[1])
	rect.material = material
	return rect


static func _selected(items: Array[Dictionary], key: String) -> Dictionary:
	var id: String = SaveData.load_value(key, items[0].id)
	for item in items:
		if item.id == id and is_unlocked(item):
			return item
	return items[0]
