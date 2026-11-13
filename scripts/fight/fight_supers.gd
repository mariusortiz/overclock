class_name FightSupers
## The super of each hero, from its ultimate in the game (Ultimate.INFO): a
## few kinds of blows that Fight knows how to play (see Fight._run_super):
##   "projectiles": `count` shots, `every` seconds apart;
##   "strikes": hits falling from the sky on the opponent's spot;
##   "beam": a ray across the whole stage, at once;
##   "move": a move of the fighter itself (Fighter.MOVES: whirl, charge);
##   "clones": copies of the hero that dash across;
##   "freeze": the opponent stops for `seconds`;
##   "rage": stronger and faster for `seconds`;
##   "heal": health back, and a pillar of light on the opponent;
##   "curse": a slow shot that poisons and slows.
## Damage is per hit, before the hero's boost (see Fight).

const KINDS := {
	&"airstrike": {"kind": "strikes", "count": 3, "damage": 10, "spread": 1.2, "color": Color(1.0, 0.55, 0.15)},
	&"deadeye": {"kind": "beam", "damage": 24, "color": Color(1.0, 0.85, 0.3), "delay": 0.4},
	&"overdrive": {"kind": "projectiles", "count": 8, "every": 0.09, "damage": 4, "speed": 16.0, "color": Color(1.0, 0.6, 0.2)},
	&"clones": {"kind": "clones", "count": 2, "damage": 12, "color": Color(0.6, 0.4, 1.0)},
	&"broadside": {"kind": "projectiles", "count": 3, "every": 0.25, "damage": 9, "speed": 10.0, "size": 0.3, "color": Color(0.3, 0.3, 0.35)},
	&"rampart": {"kind": "move", "move": "charge", "damage": 22, "color": Color(0.6, 0.8, 1.0)},
	&"whirlwind": {"kind": "move", "move": "whirl", "damage": 5, "color": Color(0.8, 1.0, 1.0)},
	&"rage": {"kind": "rage", "seconds": 6.0, "color": Color(1.0, 0.25, 0.15)},
	&"arrows": {"kind": "strikes", "count": 7, "damage": 4, "spread": 2.4, "color": Color(0.5, 1.0, 0.4)},
	&"dynamite": {"kind": "projectiles", "count": 1, "every": 0.0, "damage": 24, "speed": 7.0, "arc": true, "size": 0.25, "color": Color(1.0, 0.3, 0.2)},
	&"curse": {"kind": "curse", "damage": 8, "seconds": 5.0, "color": Color(0.7, 0.2, 1.0)},
	&"root": {"kind": "beam", "damage": 40, "color": Color(0.2, 1.0, 0.45), "delay": 0.6},
	&"timestop": {"kind": "freeze", "seconds": 2.5, "color": Color(0.4, 0.8, 1.0)},
	&"blessing": {"kind": "heal", "share": 0.3, "damage": 10, "color": Color(1.0, 0.9, 0.5)},
}


static func of(fighter: Fighter) -> Dictionary:
	return KINDS.get(fighter.hero.ulti, KINDS[&"airstrike"])


static func name_of(fighter: Fighter) -> String:
	if fighter.is_boss():
		return "Bombardement"
	return str(Ultimate.INFO[fighter.hero.ulti].name)


## Damage factor from the hero's boost: 1 for the free heroes, more for the
## shop's, the most for Le Créateur and the overpowered ones.
static func power(fighter: Fighter) -> float:
	return 0.8 + 0.25 * float(fighter.hero.get("boost", 1.0))
