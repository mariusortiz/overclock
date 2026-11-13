class_name FightDummy
extends RefCounted
## The training's dummy: stands still, guards everything, jumps again and
## again, or attacks now and then (to practise guarding).

const MODES := ["idle", "guard", "jump", "attack"]
const NAMES := {"idle": "IMMOBILE", "guard": "GARDE", "jump": "SAUTE", "attack": "ATTAQUE"}

var me: Fighter
var mode := "idle"
var _left := 0.0


func _init(fighter: Fighter) -> void:
	me = fighter


func next_mode() -> void:
	mode = MODES[(MODES.find(mode) + 1) % MODES.size()]


func read(delta: float) -> Dictionary:
	var input := {"x": 0, "up": false, "down": false, "punch": false, "kick": false, "weapon": false, "super": false}
	var toward := 1 if me.opponent.x >= me.x else -1
	_left -= delta
	match mode:
		"guard":
			input.x = -toward
		"jump":
			input.up = me.on_ground()
		"attack":
			if _left <= 0.0:
				_left = 1.4
				if absf(me.opponent.x - me.x) > 2.0:
					input.down = true
					input.weapon = true
				else:
					input.punch = true
	return input
