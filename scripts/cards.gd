class_name Cards
## Collectible cards: one per hero, enemy, boss, ship, weapon, arena and
## anime episode, in five rarities. They come in boosters (end of a game,
## shop, every fifth battle pass tier, all the day's challenges done).
## Duplicates are recycled into dust, which crafts the missing ones; a
## completed series pays credits and gems, the whole album a skin.
## Card art: assets/cards/<id>.jpg (see tools/make_card_art.gd).

## HACKER is above everything, and only for the cards of HACKER_CARDS.
enum Rarity { COMMON, RARE, EPIC, LEGENDARY, MYTHIC, HACKER }

const RARITY := {
	Rarity.COMMON: {"name": "Commune", "color": Color(0.75, 0.78, 0.85), "weight": 60.0, "dust": 5, "craft": 40},
	Rarity.RARE: {"name": "Rare", "color": Color(0.25, 0.6, 1.0), "weight": 25.0, "dust": 20, "craft": 160},
	Rarity.EPIC: {"name": "Épique", "color": Color(0.75, 0.35, 1.0), "weight": 10.0, "dust": 50, "craft": 400},
	Rarity.LEGENDARY: {"name": "Légendaire", "color": Color(1.0, 0.75, 0.2), "weight": 1.5, "dust": 150, "craft": 1200},
	Rarity.MYTHIC: {"name": "Mythique", "color": Color(1.0, 0.25, 0.6), "weight": 0.3, "dust": 500, "craft": 4000},
	# Never drawn, recycled or crafted: only with a code.
	Rarity.HACKER: {"name": "Hacker", "color": Color(0.2, 1.0, 0.45), "weight": 0.0, "dust": 0, "craft": 0},
}
const ART_DIR := "res://assets/cards/"
## Cards in each kind of booster.
const CARDS_PER_BOOSTER := {"standard": 3, "rare": 5, "legend": 7}
## A score worth a second booster.
const BIG_SCORE := 8000

## Series, in album order: [name, reward credits, reward gems].
const SERIES := [
	["Héros", 3000, 100], ["Ennemis", 1500, 50], ["Boss", 2000, 80], ["Vaisseaux", 2000, 80],
	["Armes", 2000, 80], ["Mêlée", 1200, 40], ["Skins", 1500, 60], ["Arènes", 1200, 40], ["Anime", 2500, 100],
	["Mythiques", 5000, 250],
	# The "Saison 2" expansion (EXPANSION): its own numbers, outside the 99.
	["Matrice", 1500, 60], ["Anime S2", 2500, 100], ["Combat", 1500, 60], ["Boutique", 1800, 70], ["Noël", 1500, 80], ["Passe S2", 2000, 90],
	# Le Créateur's: only through his code, outside the album's count.
	["Hacker", 10000, 500],
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
	{"id": "card_sniper_enemy", "name": "Tireur d'élite", "series": "Ennemis", "rarity": R, "art": ["glow", "BlueSoldier_Male.fbx:29d4ff"]},
	{"id": "card_kamikaze", "name": "Kamikaze", "series": "Ennemis", "rarity": R, "art": ["glow", "Zombie_Male.fbx:ff401a"]},
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
	{"id": "card_pistol_6", "name": "Pistolet VI", "series": "Armes", "rarity": R, "art": ["gun", "pistol_6"]},
	{"id": "card_bullpup", "name": "Bullpup", "series": "Armes", "rarity": R, "art": ["gun", "bullpup_1"]},
	{"id": "card_sawed_off", "name": "Canon scié", "series": "Armes", "rarity": R, "art": ["gun", "shotgun_5"]},
	{"id": "card_revolver_5", "name": "Revolver V", "series": "Armes", "rarity": E, "art": ["gun", "revolver_5"]},
	{"id": "card_sniper_6", "name": "Précision VI", "series": "Armes", "rarity": E, "art": ["gun", "sniper_6"]},
	{"id": "card_laser", "name": "Laser", "series": "Armes", "rarity": E, "art": ["gun", "laser"]},
	{"id": "card_railgun", "name": "Fusil à rail", "series": "Armes", "rarity": E, "art": ["gun", "railgun"]},
	{"id": "card_plasma", "name": "Canon plasma", "series": "Armes", "rarity": E, "art": ["gun", "plasma"]},
	{"id": "card_flamer", "name": "Lance-flammes", "series": "Armes", "rarity": E, "art": ["gun", "flamer"]},
	{"id": "card_flechette", "name": "Lance-fléchettes", "series": "Armes", "rarity": E, "art": ["gun", "flechette"]},
	{"id": "card_minigun", "name": "Minigun", "series": "Armes", "rarity": L, "art": ["gun", "minigun"]},
	# Melee.
	{"id": "card_knife", "name": "Couteau", "series": "Mêlée", "rarity": C, "art": ["melee", "knife"]},
	{"id": "card_kunai", "name": "Kunaï", "series": "Mêlée", "rarity": C, "art": ["melee", "kunai"]},
	{"id": "card_spear", "name": "Lance", "series": "Mêlée", "rarity": C, "art": ["melee", "spear"]},
	{"id": "card_mace", "name": "Masse", "series": "Mêlée", "rarity": R, "art": ["melee", "mace"]},
	{"id": "card_machete", "name": "Machette", "series": "Mêlée", "rarity": R, "art": ["melee", "machete"]},
	{"id": "card_axe", "name": "Hache", "series": "Mêlée", "rarity": R, "art": ["melee", "axe"]},
	{"id": "card_katana", "name": "Katana", "series": "Mêlée", "rarity": R, "art": ["melee", "katana"]},
	{"id": "card_karambit", "name": "Karambit", "series": "Mêlée", "rarity": E, "art": ["melee", "karambit"]},
	{"id": "card_butterfly", "name": "Couteau papillon", "series": "Mêlée", "rarity": E, "art": ["melee", "butterfly"]},
	# Skins, shown on the assault rifle.
	{"id": "card_skin_neon", "name": "Skin Néon", "series": "Skins", "rarity": R, "art": ["gun_skin", "heavy:skin_neon"]},
	{"id": "card_skin_ice", "name": "Skin Glace", "series": "Skins", "rarity": R, "art": ["gun_skin", "heavy:skin_ice"]},
	{"id": "card_skin_lava", "name": "Skin Lave", "series": "Skins", "rarity": R, "art": ["gun_skin", "heavy:skin_lava"]},
	{"id": "card_skin_sakura", "name": "Skin Sakura", "series": "Skins", "rarity": E, "art": ["gun_skin", "heavy:skin_sakura"]},
	{"id": "card_skin_galaxy", "name": "Skin Galaxie", "series": "Skins", "rarity": E, "art": ["gun_skin", "heavy:skin_galaxy"]},
	{"id": "card_skin_glitch", "name": "Skin Glitch", "series": "Skins", "rarity": E, "art": ["gun_skin", "heavy:skin_glitch"]},
	{"id": "card_skin_gold", "name": "Skin Or", "series": "Skins", "rarity": L, "art": ["gun_skin", "heavy:skin_gold"]},
	{"id": "card_skin_prism", "name": "Skin Prisme", "series": "Skins", "rarity": L, "art": ["gun_skin", "heavy:skin_prism"]},
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
	{"id": "card_fleet", "name": "La flotte", "series": "Mythiques", "rarity": M, "art": ["image", "fleet"]},
	{"id": "card_titan_city", "name": "Le Titan sur la ville", "series": "Mythiques", "rarity": M, "art": ["image", "titan_city"]},
]

## The "Saison 2" expansion: what came after the 99 (the Matrice and its
## Virus, the anime's season 2, the fight mode, the shop's latest). Drawn from
## the same boosters, recycled and crafted like the others, numbered apart
## (S01/S31); the album of 99 does not need them.
const EXPANSION := [
	# The Matrice.
	{"id": "card_matrix_arena", "name": "La Matrice", "series": "Matrice", "rarity": E, "art": ["image", "matrix_arena"]},
	{"id": "card_program", "name": "Programme corrompu", "series": "Matrice", "rarity": C, "art": ["glow", "Ninja_Male.fbx:33ff73"]},
	{"id": "card_firewall", "name": "Pare-feu", "series": "Matrice", "rarity": C, "art": ["image", "firewall"]},
	{"id": "card_code_rain", "name": "Pluie de code", "series": "Matrice", "rarity": R, "art": ["image", "code_rain"]},
	{"id": "card_virus", "name": "Le Virus", "series": "Matrice", "rarity": L, "art": ["virus", ""]},
	{"id": "card_virus_unleashed", "name": "Le Virus déchaîné", "series": "Matrice", "rarity": M, "art": ["image", "virus_unleashed"]},
	# The anime's season 2.
	{"id": "card_ep11", "name": "Le glitch", "series": "Anime S2", "rarity": E, "art": ["image", "ep11"]},
	{"id": "card_ep12", "name": "Le message", "series": "Anime S2", "rarity": E, "art": ["image", "ep12"]},
	{"id": "card_ep13", "name": "La course corrompue", "series": "Anime S2", "rarity": E, "art": ["image", "ep13"]},
	{"id": "card_ep14", "name": "Le Virus", "series": "Anime S2", "rarity": E, "art": ["image", "ep14"]},
	{"id": "card_ep15", "name": "Le Créateur", "series": "Anime S2", "rarity": E, "art": ["image", "ep15"]},
	{"id": "card_ep16", "name": "Code source", "series": "Anime S2", "rarity": E, "art": ["image", "ep16"]},
	{"id": "card_ep17", "name": "Mise à jour", "series": "Anime S2", "rarity": E, "art": ["image", "ep17"]},
	{"id": "card_ep18", "name": "Écran noir", "series": "Anime S2", "rarity": E, "art": ["image", "ep18"]},
	{"id": "card_ep19", "name": "Ctrl+Z", "series": "Anime S2", "rarity": L, "art": ["image", "ep19"]},
	{"id": "card_ep20", "name": "Redémarrage", "series": "Anime S2", "rarity": L, "art": ["image", "ep20"]},
	# The fight mode.
	{"id": "card_fight", "name": "Un contre un", "series": "Combat", "rarity": R, "art": ["image", "fight"]},
	{"id": "card_fight_uppercut", "name": "Uppercut", "series": "Combat", "rarity": C, "art": ["image", "fight_uppercut"]},
	{"id": "card_fight_kick", "name": "Coup de pied sauté", "series": "Combat", "rarity": C, "art": ["image", "fight_kick"]},
	{"id": "card_fight_guard", "name": "Garde", "series": "Combat", "rarity": C, "art": ["image", "fight_guard"]},
	{"id": "card_fight_clones", "name": "Super : Clones", "series": "Combat", "rarity": R, "art": ["image", "fight_clones"]},
	{"id": "card_fight_timestop", "name": "Super : Arrêt du temps", "series": "Combat", "rarity": E, "art": ["image", "fight_timestop"]},
	{"id": "card_fight_titan", "name": "Le Titan d'arcade", "series": "Combat", "rarity": L, "art": ["image", "fight_titan"]},
	# The shop's latest.
	{"id": "card_dance_loser", "name": "Danse Loser", "series": "Boutique", "rarity": C, "art": ["dance", "dance_loser:soldier"]},
	{"id": "card_dance_easy", "name": "Danse Tout doux", "series": "Boutique", "rarity": C, "art": ["dance", "dance_easy:cowgirl"]},
	{"id": "card_dance_dab", "name": "Danse Dab", "series": "Boutique", "rarity": R, "art": ["dance", "dance_dab:ninja"]},
	{"id": "card_dance_chicken", "name": "Danse Poulet", "series": "Boutique", "rarity": R, "art": ["dance", "dance_chicken:viking"]},
	{"id": "card_dance_windmill", "name": "Danse Moulinet", "series": "Boutique", "rarity": E, "art": ["dance", "dance_windmill:kunoichi"]},
	{"id": "card_dance_spin", "name": "Danse Toupie", "series": "Boutique", "rarity": E, "art": ["dance", "dance_spin:paladin"]},
	{"id": "card_annihilator", "name": "Annihilateur", "series": "Boutique", "rarity": E, "art": ["gun", "annihilator"]},
	{"id": "card_golden_gun", "name": "Pistolet d'or", "series": "Boutique", "rarity": L, "art": ["gun", "golden_gun"]},
	# Season 2 of the battle pass, and the Platine skin of the achievements.
	{"id": "card_skin_data", "name": "Skin Données", "series": "Passe S2", "rarity": C, "art": ["gun_skin", "heavy:skin_data"]},
	{"id": "card_skin_firewall", "name": "Skin Pare-feu", "series": "Passe S2", "rarity": C, "art": ["gun_skin", "heavy:skin_firewall"]},
	{"id": "card_skin_corruption", "name": "Skin Corruption", "series": "Passe S2", "rarity": R, "art": ["gun_skin", "heavy:skin_corruption"]},
	{"id": "card_skin_binary", "name": "Skin Binaire", "series": "Passe S2", "rarity": R, "art": ["gun_skin", "heavy:skin_binary"]},
	{"id": "card_skin_kernel", "name": "Skin Noyau", "series": "Passe S2", "rarity": E, "art": ["gun_skin", "heavy:skin_kernel"]},
	{"id": "card_dance_glitch", "name": "Danse Glitch", "series": "Passe S2", "rarity": R, "art": ["dance", "dance_glitch:programme"]},
	{"id": "card_dance_reboot", "name": "Danse Redémarrage", "series": "Passe S2", "rarity": E, "art": ["dance", "dance_reboot:soldier_female"]},
	{"id": "card_ship_firewall", "name": "Pare-feu", "series": "Passe S2", "rarity": E, "art": ["ship", "ship_firewall"]},
	{"id": "card_programme", "name": "Programme", "series": "Passe S2", "rarity": L, "art": ["hero", "programme"]},
	{"id": "card_skin_platinum", "name": "Skin Platine", "series": "Passe S2", "rarity": M, "art": ["gun_skin", "heavy:skin_platinum"]},
	# Christmas: drawn during the event only ("event"), crafted all year.
	{"id": "card_snow_village", "name": "Village enneigé", "series": "Noël", "rarity": E, "art": ["image", "snow_village"], "event": "christmas"},
	{"id": "card_elf_enemy", "name": "Lutin", "series": "Noël", "rarity": C, "art": ["enemy", "Elf.fbx"], "event": "christmas"},
	{"id": "card_frost", "name": "Père Glaçon", "series": "Noël", "rarity": L, "art": ["frost", ""], "event": "christmas"},
	{"id": "card_skin_candy", "name": "Skin Sucre d'orge", "series": "Noël", "rarity": R, "art": ["gun_skin", "heavy:skin_candy"], "event": "christmas"},
	{"id": "card_skin_garland", "name": "Skin Guirlande", "series": "Noël", "rarity": E, "art": ["gun_skin", "heavy:skin_garland"], "event": "christmas"},
	{"id": "card_dance_snowman", "name": "Danse Bonhomme de neige", "series": "Noël", "rarity": R, "art": ["dance", "dance_snowman:soldier"], "event": "christmas"},
]

## Every card there is: the album, the expansion, Le Créateur's.
static func all_cards() -> Array:
	return CATALOG + EXPANSION + HACKER_CARDS


static func is_expansion(card: Dictionary) -> bool:
	return card in EXPANSION


## The expansion's cards owned.
static func expansion_owned() -> int:
	var cards := owned()
	return EXPANSION.filter(func(card: Dictionary) -> bool: return int(cards.get(card.id, 0)) > 0).size()


## Cards above the album: not in CATALOG (they are not counted, numbered,
## drawn or needed to complete it), only given by a code (see PromoCodes).
## "item": what of Le Créateur's the card stands for; owning it gives the card
## (see sync_hacker).
const HACKER_CARDS := [
	{"id": "card_createur", "name": "Le Créateur", "series": "Hacker", "rarity": Rarity.HACKER, "art": ["hero", "createur"], "item": "createur"},
	{"id": "card_source_code", "name": "Code source", "series": "Hacker", "rarity": Rarity.HACKER, "art": ["gun_skin", "source_code:skin_matrix"], "item": "source_code"},
	{"id": "card_ctrl_alt_del", "name": "Ctrl+Alt+Suppr", "series": "Hacker", "rarity": Rarity.HACKER, "art": ["melee", "ctrl_alt_del"], "item": "ctrl_alt_del"},
	{"id": "card_matrix", "name": "Skin Matrice", "series": "Hacker", "rarity": Rarity.HACKER, "art": ["gun_skin", "heavy:skin_matrix"], "item": "skin_matrix"},
	{"id": "card_mainframe", "name": "Mainframe", "series": "Hacker", "rarity": Rarity.HACKER, "art": ["ship", "ship_mainframe"], "item": "ship_mainframe"},
]

const SAVE_KEY := "cards"
## Boosters waiting to be opened: "standard" (any rarity), "rare" (its
## last card rare or better) and "legend" (its last card legendary or better
## one time in two, rare or better otherwise; sold dear in the shop).
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


## What the card's ability box says: [title, text].
static func ability(card: Dictionary) -> Array:
	var kind: String = card.art[0]
	var reference: String = card.art[1]
	match kind:
		"hero":
			var hero: Dictionary = Loadout.find(reference).item
			var ulti: Dictionary = Ultimate.INFO[hero.ulti]
			var text: String = ulti.text
			if hero.has("boost"):
				text += " (" + Ultimate.boost_text(hero.boost).to_lower() + ")"
			return ["ULTI · " + str(ulti.name).to_upper(), text]
		"ship":
			var ship: Dictionary = Loadout.find(reference).item
			var special: Array = Loadout.SHIP_SPECIALS[ship.special]
			return [special[0], "%s. Bouclier %d, vitesse %d %%." % [special[1], ship.shield, roundi(ship.velocity * 100)]]
		"gun_skin":
			return ["FINITION", FLAVOR.get(card.id, "Change l'allure de l'arme, pas ses stats.")]
		"gun":
			var gun: Dictionary = Loadout.find(reference.split(":")[0]).item
			return ["TIR", "Cadence %s/s · dégâts %d · chargeur %d." % [str(gun.fire_rate).trim_suffix(".0"), gun.damage, gun.magazine]]
		"melee":
			var blade: Dictionary = Loadout.find(reference).item
			return ["FRAPPE", "Dégâts %d · portée %s m." % [blade.damage, str(blade.range).trim_suffix(".0")]]
		"boss", "titan", "virus", "frost":
			return ["BOSS", FLAVOR.get(card.id, "Garde la fin d'une arène.")]
		"dance":
			var dance: Dictionary = Dances.find(reference.split(":")[0])
			return ["DANSE · " + str(dance.get("name", "")), FLAVOR.get(card.id, "Vendue en boutique, à danser en pleine partie.")]
	if str(card.id).begins_with("card_ep"):
		var episode := str(card.id).trim_prefix("card_ep").to_int()
		return ["ÉPISODE %d" % episode, "L'anime Overclock, saison %d." % (1 if episode <= 10 else 2)]
	return ["", FLAVOR.get(card.id, "")]


## A short line for the cards whose subject has no stats.
const FLAVOR := {
	"card_guard": "Garde la station, en rangs serrés.",
	"card_sand": "Surgit des dunes, pistolet-mitrailleur au poing.",
	"card_goblin": "Couteau entre les dents, toujours en bande.",
	"card_zombie": "Lent, mais il ne lâche jamais.",
	"card_suit": "Travaille pour le Directeur. Ne pose pas de questions.",
	"card_bat": "Plonge du ciel à partir de la vague 3.",
	"card_sniper_enemy": "Vise longtemps, laser allumé. Ne le laisse pas finir.",
	"card_kamikaze": "Fonce sur toi et explose. Abats-le de loin.",
	"card_skin_neon": "Lignes de lumière cyan sur fond sombre.",
	"card_skin_ice": "Givre bleu. Les ennemis éclatent comme du verre.",
	"card_skin_lava": "Roche fendue de braises. Les ennemis se consument.",
	"card_skin_sakura": "Pétales roses. Les ennemis s'envolent en fleurs.",
	"card_skin_galaxy": "Un ciel étoilé qui tourne sur l'arme.",
	"card_skin_glitch": "L'arme saute et se décale, comme un signal brouillé.",
	"card_skin_gold": "Or massif. Les ennemis finissent en statues.",
	"card_skin_prism": "Toutes les couleurs, qui défilent sans fin.",
	"card_fleet": "Dard, Faucon, Frelon et Nova, en formation.",
	"card_titan_city": "Quatre héros, un géant rouge, une ville entière.",
	"card_createur": "Celui qui a écrit le jeu. Personne ne l'a jamais vu perdre.",
	"card_source_code": "Chaque tir réécrit une ligne de l'ennemi.",
	"card_ctrl_alt_del": "Quand plus rien ne répond.",
	"card_matrix": "La pluie de code verte du Créateur.",
	"card_elite": "Trois fois plus solide. Laisse toujours un bonus.",
	"card_dragon": "Crache le feu sur toute la station.",
	"card_skeleton": "Charge sans prévenir. Frappe fort.",
	"card_giant_bat": "Bombarde la jungle depuis les airs.",
	"card_slime": "Se divise en petits monstres.",
	"card_titan": "Le géant de la ville. Trois phases, une onde de choc.",
	"card_titan_mk2": "Deux fois plus grand. Un bouclier que rien ne perce seul.",
	"card_station": "Hangar spatial, tour de contrôle et passerelles.",
	"card_desert": "Temple à gradins, oasis et pont de pierre.",
	"card_jungle": "Cabanes dans les arbres et ponts de cordes.",
	"card_volcano": "Rivière de lave et plateaux de basalte.",
	"card_city": "Rues, pont routier et toits accessibles.",
	"card_squad": "Soldat, Kunoichi, Capitaine, Ronin. Prochaine vague ?",
	"card_rivals": "« Alors, cette revanche ? » « Quand tu veux. »",
	"card_directeur": "A construit les Titans. Doit de l'argent au Parrain.",
	"card_trophy": "Pour qui bat le Titan.",
	"card_champion": "Le skin de la victoire, or et magenta.",
	"card_matrix_arena": "Un noyau, des ponts de données, une pluie de code.",
	"card_program": "Un garde du système, pris par le Virus.",
	"card_firewall": "Rouge, translucide. Arrête les balles, pas le Virus.",
	"card_code_rain": "Chaque colonne tombe à son rythme.",
	"card_virus": "Disparaît dans un grésillement, réapparaît dans ton dos.",
	"card_virus_unleashed": "Il a grandi au-dessus de la ville. Il fallait trois fragments.",
	"card_fight": "Deux manches gagnantes, de profil, sur les arènes du jeu.",
	"card_fight_uppercut": "Bas + POING. Le meilleur ami contre les sauts.",
	"card_fight_kick": "Avant + PIED : fait tomber l'adversaire.",
	"card_fight_guard": "Recule : un coup gardé ne fait presque rien.",
	"card_fight_clones": "Deux fantômes foncent sur l'adversaire.",
	"card_fight_timestop": "L'adversaire gèle. À toi de jouer.",
	"card_fight_titan": "Le dernier combat de l'arcade, dans la ville.",
	"card_annihilator": "Le canon plasma de la boutique, en version ultra.",
	"card_golden_gun": "99 dégâts. Six balles. Pas de seconde chance.",
	"card_skin_data": "Une pluie de données bleues sur l'arme.",
	"card_skin_firewall": "Rouge et brûlant. Les ennemis se consument.",
	"card_skin_corruption": "Des blocs verts qui sautent, comme le Virus.",
	"card_skin_binary": "Des 0 et des 1 qui défilent en lignes de lumière.",
	"card_skin_kernel": "Le cœur du système : un anneau vert qui tourne.",
	"card_skin_platinum": "Pour qui a tout débloqué. Les 50 succès.",
	"card_snow_village": "Chalets, lac gelé et le grand sapin. Seulement à Noël.",
	"card_elf_enemy": "Petit, rapide, et il ne fait pas de cadeaux.",
	"card_frost": "Un squelette géant changé en glace. Son bonnet est rouge.",
	"card_skin_candy": "Rayures rouges et blanches. Les ennemis éclatent en bonbons.",
	"card_skin_garland": "Des ampoules qui clignotent. Les ennemis s'allument puis éclatent.",
}


## The number in the corner, as in a numbered set: 12 -> "012/078".
static func number(card: Dictionary) -> String:
	if card.rarity == Rarity.HACKER:
		return "H%02d/H%02d" % [HACKER_CARDS.find(card) + 1, HACKER_CARDS.size()]
	if is_expansion(card):
		return "S%02d/S%02d" % [EXPANSION.find(card) + 1, EXPANSION.size()]
	return "%03d/%03d" % [CATALOG.find(card) + 1, CATALOG.size()]


## The big number at the top: higher for rarer cards, a little different for each.
static func power(card: Dictionary) -> int:
	var base := [60, 90, 120, 160, 220, 960][card.rarity] as int
	return base + absi(hash(card.id)) % 4 * 10


static func find(id: String) -> Dictionary:
	for card: Dictionary in all_cards():
		if card.id == id:
			return card
	return {}


static func in_series(series: String) -> Array:
	return all_cards().filter(func(card: Dictionary) -> bool: return card.series == series)


## How many of each card the player has: id -> count.
static func owned() -> Dictionary:
	return SaveData.load_progress(SAVE_KEY, {})


static func count(id: String) -> int:
	return owned().get(id, 0)


## Cards of the album owned (the Hacker cards, given by a code, are apart).
static func owned_total() -> int:
	var cards := owned()
	return CATALOG.filter(func(card: Dictionary) -> bool: return int(cards.get(card.id, 0)) > 0).size()


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
	var count: int = cards_in(kind)
	for slot in count:
		var lowest := Rarity.COMMON
		var highest := Rarity.MYTHIC
		if slot == count - 1:
			if kind == "rare":
				lowest = Rarity.RARE
			elif kind == "legend":
				# One time in two legendary or better; otherwise rare or epic.
				if randf() < LEGEND_CHANCE:
					lowest = Rarity.LEGENDARY
				else:
					lowest = Rarity.RARE
					highest = Rarity.EPIC
		var card := _draw(lowest, highest)
		add(card.id)
		drawn.append(card)
	return drawn


static func cards_in(kind: String) -> int:
	return CARDS_PER_BOOSTER.get(kind, 3)


## Chance that a legendary booster's last card is legendary or better.
const LEGEND_CHANCE := 0.5


## A random card of rarity `lowest` or above, by the rarities' weights.
static func _draw(lowest: Rarity, highest := Rarity.MYTHIC) -> Dictionary:
	var total := 0.0
	for rarity: Rarity in RARITY:
		if rarity >= lowest and rarity <= highest:
			total += RARITY[rarity].weight
	var roll := randf() * total
	var chosen := lowest
	for rarity: Rarity in RARITY:
		if rarity < lowest or rarity > highest:
			continue
		roll -= RARITY[rarity].weight
		if roll <= 0.0:
			chosen = rarity
			break
	# Event cards only during their event.
	var drawable := (CATALOG + EXPANSION).filter(func(card: Dictionary) -> bool: return Events.is_on(card.get("event", "")))
	var pool := drawable.filter(func(card: Dictionary) -> bool: return card.rarity == chosen)
	if pool.is_empty():
		pool = drawable.filter(func(card: Dictionary) -> bool: return card.rarity == lowest)
	return pool.pick_random()


## Turns every extra copy into dust. Returns the dust gained.
static func recycle_duplicates() -> int:
	var cards := owned()
	var gained := 0
	for id: String in cards:
		if cards[id] > 1 and find(id).rarity != Rarity.HACKER:
			gained += (cards[id] - 1) * int(RARITY[find(id).rarity].dust)
			cards[id] = 1
	SaveData.save_progress(SAVE_KEY, cards)
	SaveData.save_progress(DUST_KEY, dust() + gained)
	return gained


static func craft_cost(id: String) -> int:
	return RARITY[find(id).rarity].craft


static func craft(id: String) -> bool:
	var cost := craft_cost(id)
	if dust() < cost or count(id) > 0 or find(id).rarity == Rarity.HACKER:
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


## The hacker cards of what the player owns of Le Créateur's (for those who
## used his code before the cards existed).
static func sync_hacker() -> void:
	for card: Dictionary in HACKER_CARDS:
		if count(card.id) == 0 and Wallet.owns(card.item):
			add(card.id)


static func album_complete() -> bool:
	return owned_total() >= CATALOG.size()


static func art(card: Dictionary) -> Texture2D:
	var path := ART_DIR + str(card.id) + ".jpg"
	return load(path) if ResourceLoader.exists(path) else null
