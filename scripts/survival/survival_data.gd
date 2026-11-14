class_name SurvivalData
## The survival mode's data: items, what each harvestable thing gives, the
## recipes (some only near a station), and the pieces one can build.

## Item id -> {"name", "kind" ("material", "food", "drink", "tool", "gun",
## "heal", "ammo", "station"), ...}. Food and drink restore "food" / "water"
## (out of 100); tools have "tool" ("axe", "pick", "blade"), a "power" against
## what they harvest and a "damage" against creatures; guns are Loadout.WEAPONS
## ids ("gun").
const ITEMS := {
	"wood": {"name": "Bois", "kind": "material"},
	"stone": {"name": "Pierre", "kind": "material"},
	"fiber": {"name": "Fibre", "kind": "material"},
	"metal_ore": {"name": "Minerai de métal", "kind": "material"},
	"metal": {"name": "Lingot de métal", "kind": "material"},
	"crystal": {"name": "Cristal", "kind": "material"},
	"scrap": {"name": "Ferraille", "kind": "material"},
	"leather": {"name": "Cuir", "kind": "material"},
	"berries": {"name": "Baies", "kind": "food", "food": 12, "water": 4},
	"mushroom": {"name": "Champignon", "kind": "food", "food": 8},
	"raw_meat": {"name": "Viande crue", "kind": "food", "food": 10, "hurt": 5},
	"cooked_meat": {"name": "Viande cuite", "kind": "food", "food": 40},
	"cactus_pulp": {"name": "Pulpe de cactus", "kind": "drink", "water": 15},
	"flask": {"name": "Gourde vide", "kind": "material"},
	"water_flask": {"name": "Gourde pleine", "kind": "drink", "water": 45, "leaves": "flask"},
	"bandage": {"name": "Bandage", "kind": "heal", "heal": 25},
	"medkit": {"name": "Trousse de soin", "kind": "heal", "heal": 70},
	"ammo": {"name": "Munitions", "kind": "ammo"},
	"stone_axe": {"name": "Hache en pierre", "kind": "tool", "tool": "axe", "power": 2, "damage": 3, "model": "axe"},
	"stone_pick": {"name": "Pioche en pierre", "kind": "tool", "tool": "pick", "power": 2, "damage": 3, "model": "mace"},
	"spear": {"name": "Lance", "kind": "tool", "tool": "blade", "power": 1, "damage": 5, "model": "spear"},
	"metal_axe": {"name": "Hache en métal", "kind": "tool", "tool": "axe", "power": 4, "damage": 5, "model": "axe"},
	"metal_pick": {"name": "Pioche en métal", "kind": "tool", "tool": "pick", "power": 4, "damage": 5, "model": "mace"},
	"sword": {"name": "Épée", "kind": "tool", "tool": "blade", "power": 1, "damage": 9, "model": "katana"},
	"pistol": {"name": "Pistolet", "kind": "gun", "gun": "blaster"},
	"rifle": {"name": "Fusil", "kind": "gun", "gun": "heavy"},
	"laser": {"name": "Fusil laser", "kind": "gun", "gun": "laser"},
}

## What can be harvested: kind -> {"hp", "tool" (what works best, "" for
## the hands), "gives": [[item, count]], "model" choices, "size"}.
const NODES := {
	"tree": {"hp": 8, "tool": "axe", "gives": [["wood", 4], ["fiber", 1]]},
	"palm": {"hp": 7, "tool": "axe", "gives": [["wood", 3], ["fiber", 2]]},
	"rock": {"hp": 10, "tool": "pick", "gives": [["stone", 5]]},
	"metal": {"hp": 14, "tool": "pick", "gives": [["metal_ore", 3], ["stone", 1]], "needs": "pick"},
	"crystal": {"hp": 16, "tool": "pick", "gives": [["crystal", 2]], "needs": "pick"},
	"bush": {"hp": 2, "tool": "", "gives": [["berries", 2], ["fiber", 2]]},
	"mushroom": {"hp": 1, "tool": "", "gives": [["mushroom", 2]]},
	"cactus": {"hp": 4, "tool": "", "gives": [["cactus_pulp", 2], ["fiber", 1]]},
	"crate": {"hp": 3, "tool": "", "gives": [["scrap", 3], ["ammo", 12], ["bandage", 1]]},
}

## The stations: a recipe that names one is only made near it.
const STATIONS := {"workbench": "Établi", "forge": "Forge", "campfire": "Feu de camp"}
## Distance to a station to use it.
const STATION_RANGE := 5.0

## [result, count, cost {item: count}, station or ""]
const RECIPES := [
	["stone_axe", 1, {"wood": 3, "stone": 3}, ""],
	["stone_pick", 1, {"wood": 3, "stone": 4}, ""],
	["spear", 1, {"wood": 4, "stone": 2, "fiber": 2}, ""],
	["bandage", 2, {"fiber": 4}, ""],
	["flask", 1, {"leather": 2, "fiber": 2}, ""],
	["piece:campfire", 1, {"wood": 8, "stone": 4}, ""],
	["piece:workbench", 1, {"wood": 20, "stone": 8}, ""],
	["piece:chest", 1, {"wood": 15}, "workbench"],
	["piece:bed", 1, {"wood": 20, "fiber": 10, "leather": 2}, "workbench"],
	["piece:forge", 1, {"stone": 30, "wood": 10}, "workbench"],
	["metal", 1, {"metal_ore": 2, "wood": 1}, "forge"],
	["metal_axe", 1, {"wood": 4, "metal": 4}, "workbench"],
	["metal_pick", 1, {"wood": 4, "metal": 5}, "workbench"],
	["sword", 1, {"metal": 6, "leather": 2}, "forge"],
	["pistol", 1, {"metal": 6, "scrap": 4}, "workbench"],
	["rifle", 1, {"metal": 12, "scrap": 8, "crystal": 2}, "forge"],
	["laser", 1, {"metal": 10, "crystal": 8, "scrap": 6}, "forge"],
	["ammo", 20, {"metal": 1, "scrap": 2}, "workbench"],
	["medkit", 1, {"bandage": 2, "mushroom": 2}, "workbench"],
	["cooked_meat", 1, {"raw_meat": 1}, "campfire"],
	["water_flask", 1, {"flask": 1, "cactus_pulp": 2}, "campfire"],
]

## Pieces to build, on a 2 m grid: "shape" says how it is built (see
## SurvivalPiece), "cost" per material; "edge" pieces sit on a cell's edge.
## Station pieces come from recipes (their cost is the recipe's).
const PIECES := {
	"floor": {"name": "Sol", "shape": "floor", "cost": 4},
	"wall": {"name": "Mur", "shape": "wall", "cost": 6, "edge": true},
	"door": {"name": "Porte", "shape": "door", "cost": 5, "edge": true},
	"stairs": {"name": "Escalier", "shape": "stairs", "cost": 6},
	"roof": {"name": "Toit", "shape": "roof", "cost": 4},
	"palisade": {"name": "Palissade", "shape": "palisade", "cost": 5, "edge": true},
	"spikes": {"name": "Piège à pointes", "shape": "spikes", "cost": 6},
	"turret": {"name": "Tourelle", "shape": "turret", "cost": 0, "extra": {"metal": 8, "scrap": 6, "crystal": 2}},
	"campfire": {"name": "Feu de camp", "shape": "campfire", "station": true},
	"workbench": {"name": "Établi", "shape": "workbench", "station": true},
	"forge": {"name": "Forge", "shape": "forge", "station": true},
	"chest": {"name": "Coffre", "shape": "chest", "station": true},
	"bed": {"name": "Lit", "shape": "bed", "station": true},
}
## Building materials: item, hit points of a piece made of it, color.
const MATERIALS := {
	"wood": {"name": "Bois", "hp": 60, "color": Color(0.62, 0.45, 0.28)},
	"stone": {"name": "Pierre", "hp": 160, "color": Color(0.62, 0.62, 0.66)},
	"metal": {"name": "Métal", "hp": 320, "color": Color(0.55, 0.62, 0.72)},
}


static func item_name(id: String) -> String:
	if id.begins_with("piece:"):
		return PIECES[id.trim_prefix("piece:")].name
	return ITEMS.get(id, {}).get("name", id)
