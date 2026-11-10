class_name Perk
## Permanent upgrades picked between waves. Levels stack for the whole run.
## The effects are applied in weapon.gd, player.gd and enemy.gd.

enum Type { FIRE, ICE, LIGHTNING, RAPID_FIRE, BIG_MAGAZINE, EXPLOSIVE, VITALITY, LIFESTEAL, SWIFT }

const INFO := {
	Type.FIRE: {"name": "FEU", "description": "Les ennemis touchés brûlent pendant 3 s", "color": Color(1.0, 0.45, 0.1)},
	Type.ICE: {"name": "GLACE", "description": "Les ennemis touchés sont ralentis", "color": Color(0.5, 0.85, 1.0)},
	Type.LIGHTNING: {"name": "FOUDRE", "description": "Chaque tir rebondit sur un ennemi voisin", "color": Color(1.0, 0.95, 0.3)},
	Type.RAPID_FIRE: {"name": "CADENCE", "description": "Tir 20 % plus rapide", "color": Color(0.0, 0.9, 1.0)},
	Type.BIG_MAGAZINE: {"name": "CHARGEUR", "description": "Chargeur agrandi de 50 %", "color": Color(0.0, 0.9, 1.0)},
	Type.EXPLOSIVE: {"name": "EXPLOSIF", "description": "Les impacts blessent les ennemis proches", "color": Color(1.0, 0.6, 0.2)},
	Type.VITALITY: {"name": "VITALITÉ", "description": "+25 PV maximum", "color": Color(0.2, 1.0, 0.4)},
	Type.LIFESTEAL: {"name": "VOL DE VIE", "description": "+3 PV par ennemi détruit", "color": Color(0.2, 1.0, 0.4)},
	Type.SWIFT: {"name": "AGILITÉ", "description": "Déplacement 10 % plus rapide", "color": Color(0.2, 1.0, 0.4)},
}

# Tuning, per level.
const RAPID_FIRE_BONUS := 0.2
const MAGAZINE_BONUS := 0.5
const VITALITY_HEALTH := 25
const LIFESTEAL_HEAL := 3
const SWIFT_BONUS := 0.1
const LIGHTNING_RANGE := 8.0
const EXPLOSION_RADIUS := 3.0


## Returns `count` different perks, at random.
static func pick_choices(count: int) -> Array:
	var all := Type.values()
	all.shuffle()
	return all.slice(0, count)
