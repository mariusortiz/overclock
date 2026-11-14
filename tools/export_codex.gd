extends Node
## Writes the game's codex for the website (site/codex.html), as JSON: the
## heroes, guns, blades, skins, ships, bosses and arenas, with their real
## numbers and how to get them, and the card art of each when it has one.
## Run by the build at each publication, so the site is always up to date:
##   godot --headless res://scenes/tools/export_codex.tscn -- --out=codex.json

const ARENAS := ["station", "desert", "jungle", "volcano", "matrix", "crystal", "city", "ruins", "snow", "abyss", "island", "garden", "mirror"]
const ARENA_TEXTS := {
	"station": "Tour de contrôle à deux étages, passerelles, quai de chargement.",
	"desert": "Temple à gradins, plateau rocheux relié par un pont de pierre, oasis.",
	"jungle": "Cabanes dans les arbres reliées par des ponts de corde, rivière, ruines.",
	"volcano": "Rivière de lave franchie par deux ponts, plateaux de basalte, cratère.",
	"matrix": "À l'intérieur du code : noyau surélevé, ponts de données, pluie de code, pare-feu.",
	"crystal": "Une mesa, deux plateaux reliés par des ponts de pierre, des cristaux qui chantent.",
	"city": "Carrefour sous un pont routier, immeubles au toit accessible, voitures.",
	"ruins": "Une arche de portail, une allée de colonnes, deux salles hautes. Hors des Vagues.",
	"snow": "Chalets, lac gelé, pont de glace et grand sapin. Seulement à Noël.",
	"abyss": "La fosse du Léviathan, quatre plateformes reliées par des passerelles. Le raid.",
	"garden": "Fontaine, haies, arches de roses et kiosque. Seulement à la Saint-Valentin.",
	"mirror": "La ville, à l'envers : le monde-miroir de la saison 4. Histoire et capture.",
	"island": "140 m de côté : une ville, des ruines, des cristaux, des huttes, des docks. Le battle royale.",
}
## What a skin does to the enemy it kills (Enemy._play_death).
const KILLS := {
	&"knockback": "projeté en arrière, en fumée", &"vanish": "s'étire en rayon de lumière", &"shatter": "gèle et éclate",
	&"burn": "se consume en braises", &"leaves": "tombe en feuilles", &"melt": "fond en flaque",
	&"ascend": "s'élève puis se dissipe", &"pixelate": "se défait en cubes", &"petals": "éclate en pétales",
	&"splash": "éclate en gerbe d'eau", &"flare": "flash aveuglant", &"statue": "statue d'or qui s'effondre",
	&"confetti": "pluie de confettis", &"candy": "éclate en bonbons", &"snow": "gèle puis tombe en neige",
	&"lights": "s'allume puis éclate en ampoules",
}


func _ready() -> void:
	var out := "codex.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			out = argument.get_slice("=", 1)
	var art := _card_art()
	var codex := {"heroes": [], "guns": [], "blades": [], "skins": [], "ships": [], "pets": [], "accessories": [], "bosses": [], "arenas": []}
	for item: Dictionary in Loadout.CHARACTERS:
		var ulti: Dictionary = Ultimate.INFO[item.ulti]
		codex.heroes.append(_entry(item, art, {"ulti": ulti.name, "text": ulti.text, "boost": item.get("boost", 1.0),
				"special": FightSupers.SIGNATURES.get(item.id, {}).get("name", "")}))
	for item: Dictionary in Loadout.WEAPONS:
		codex.guns.append(_entry(item, art, {"fire_rate": item.fire_rate, "damage": item.damage, "magazine": item.magazine,
				"reload": item.reload_time}))
	for item: Dictionary in Loadout.MELEE:
		codex.blades.append(_entry(item, art, {"damage": item.damage, "range": item.range, "sweep": item.get("sweep", false)}))
	for pet: Dictionary in Pets.LIST.slice(1):
		var perk: Array = Pets.PERKS[pet.perk]
		codex.pets.append({"id": pet.id, "name": pet.name, "rarity": Pets.RARITY_NAMES[pet.rarity], "perk": perk[0],
				"text": perk[1], "how": Pets.unlock_text(pet), "image": _image(_pet_card(pet.id))})
	for accessory: Dictionary in Pets.ACCESSORIES.slice(1):
		codex.accessories.append({"id": accessory.id, "name": accessory.name, "how": Pets.accessory_text(accessory),
				"image": _image("card_" + accessory.id)})
	for item: Dictionary in Loadout.SKINS:
		codex.skins.append(_entry(item, art, {"kill": KILLS.get(item.get("kill", &""), ""), "animated": item.has("fx")}))
	for item: Dictionary in Loadout.SHIPS:
		var special: Array = Loadout.SHIP_SPECIALS.get(item.get("special", &""), ["", ""])
		codex.ships.append(_entry(item, art, {"speed": item.get("velocity", 1.0), "handling": item.get("handling", 1.0),
				"shield": item.get("shield", 3), "special": special[0], "text": special[1]}))
	var boss_cards := {Boss.Kind.COLOSSUS: "card_dragon", Boss.Kind.BRUTE: "card_skeleton", Boss.Kind.ARTILLERY: "card_giant_bat",
			Boss.Kind.SUMMONER: "card_slime", Boss.Kind.VIRUS: "card_virus", Boss.Kind.TITAN: "card_titan", Boss.Kind.FROST: "card_frost",
			Boss.Kind.GUARDIAN: "card_guardian"}
	boss_cards[Boss.Kind.LEVIATHAN] = "card_leviathan"
	boss_cards[Boss.Kind.REFLECT] = "card_reflect"
	boss_cards[Boss.Kind.CUPID] = "card_cupid"
	for kind: Boss.Kind in Boss.ORDER + [Boss.Kind.FROST, Boss.Kind.CUPID, Boss.Kind.LEVIATHAN, Boss.Kind.REFLECT]:
		var info: Dictionary = Boss.INFO[kind]
		var arena_name: String = {Boss.Kind.FROST: "Village enneigé", Boss.Kind.LEVIATHAN: "Abysse", Boss.Kind.CUPID: "Jardin des cœurs",
				Boss.Kind.REFLECT: "Monde-miroir"}.get(kind, "")
		if arena_name == "":
			arena_name = str(FightSetup.ARENA_NAMES[Boss.ORDER.find(kind)])
		var wave := 5 * (Boss.ORDER.find(kind) + 1)
		if kind in [Boss.Kind.FROST, Boss.Kind.CUPID, Boss.Kind.REFLECT]:
			wave = 0
		elif kind == Boss.Kind.LEVIATHAN:
			wave = -1
		codex.bosses.append({"name": info.name, "health": info.health, "arena": arena_name, "wave": wave,
				"text": Cards.FLAVOR.get(boss_cards[kind], "Le boss du raid : quatre cœurs, des renforts, un laser au ras du sol."),
				"image": _image(boss_cards[kind]) if boss_cards[kind] != "" else ""})
	for id: String in ARENAS:
		var arena: Arena = load("res://scenes/arenas/%s.tscn" % id).instantiate()
		codex.arenas.append({"name": arena.display_name, "text": ARENA_TEXTS[id], "weapon": arena.enemy_weapon,
				"image": _image("card_" + {"matrix": "matrix_arena", "snow": "snow_village", "crystal": "crystal_arena", "ruins": "ruins_arena"}.get(id, id))})
		arena.free()
	var file := FileAccess.open(out, FileAccess.WRITE)
	file.store_string(JSON.stringify(codex))
	file.close()
	print("CODEX written to %s" % out)
	get_tree().quit()


func _entry(item: Dictionary, art: Dictionary, extra: Dictionary) -> Dictionary:
	var entry := {"id": item.id, "name": item.name, "how": "Dès le départ" if Loadout.is_unlocked(item) and not item.get("shop", false) \
			and not item.get("code", false) and BattlePass.season_of(item.id) == -1 else Loadout.unlock_text(item),
			"image": art.get(item.id, "")}
	if item.get("op", false):
		entry.how += " · ultra"
	entry.merge(extra)
	return entry


## Item id -> its card's picture, from the cards' art references.
func _card_art() -> Dictionary:
	var art := {}
	for card: Dictionary in Cards.all_cards():
		var reference: String = card.art[1]
		match card.art[0]:
			"hero", "melee", "ship":
				art[reference] = _image(card.id)
			"gun":
				art[reference.split(":")[0]] = _image(card.id)
			"gun_skin":
				var parts := reference.split(":")
				if parts.size() > 1:
					art[parts[1]] = _image(card.id)
	return art


func _image(card_id: String) -> String:
	return "img/cards/%s.jpg" % card_id if FileAccess.file_exists("res://assets/cards/%s.jpg" % card_id) else ""


## The card that shows the pet (series Compagnons, or Hacker for the capybara).
func _pet_card(pet_id: String) -> String:
	for card: Dictionary in Cards.all_cards():
		if card.art == ["pet", pet_id]:
			return card.id
	return ""
