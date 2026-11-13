class_name FightAI
extends RefCounted
## The computer's fighter: every `reaction` seconds it looks at the distance
## and what the opponent does, and picks what to do until the next look:
## come closer or back off, jump in, shoot from afar, attack when in reach,
## guard an attack (more often when harder), uppercut a jump, use the super
## when the meter is full.

## Easy, normal, hard.
const LEVELS := [
	{"reaction": 0.55, "guard": 0.15, "aggression": 0.35, "anti_air": 0.1},
	{"reaction": 0.32, "guard": 0.45, "aggression": 0.55, "anti_air": 0.4},
	{"reaction": 0.16, "guard": 0.75, "aggression": 0.75, "anti_air": 0.75},
]

var me: Fighter
var level: Dictionary
var _think_left := 0.0
## What it holds until the next look.
var _x := 0
var _down := false
var _press := ""
var _jump := false


func _init(fighter: Fighter, difficulty: int) -> void:
	me = fighter
	level = LEVELS[clampi(difficulty, 0, LEVELS.size() - 1)]


func read(delta: float) -> Dictionary:
	_think_left -= delta
	var enemy := me.opponent
	var distance := absf(enemy.x - me.x)
	var toward := 1 if enemy.x >= me.x else -1
	# Guarding is a reflex, not a plan: checked every step.
	var threatened := enemy.state == Fighter.State.ATTACK and distance < 2.6
	if threatened and randf() < level.guard * delta * 12.0:
		_x = -toward
		_press = ""
		_jump = false
	if _think_left <= 0.0:
		_think_left = level.reaction * randf_range(0.7, 1.3)
		_plan(enemy, distance, toward)
	var input := {"x": _x, "up": _jump, "down": _down, "punch": false, "kick": false, "weapon": false, "super": false}
	# In the air near the opponent: the jump kick.
	if not me.on_ground() and me.move.is_empty() and distance < 1.7 and randf() < level.aggression * delta * 20.0:
		input.kick = true
	if _press != "":
		input[_press] = true
		_press = ""
		_jump = false
	return input


func _plan(enemy: Fighter, distance: float, toward: int) -> void:
	_down = false
	_jump = false
	_press = ""
	if me.meter >= Fighter.METER_MAX and distance < 6.0 and randf() < 0.6:
		_press = "super"
		return
	# A jump coming in: uppercut it.
	if not enemy.on_ground() and distance < 1.8 and randf() < level.anti_air:
		_down = true
		_press = "punch"
		return
	var reach := 1.0 + me.body_width() * 2.0
	if distance <= reach:
		if randf() < level.aggression:
			_x = 0
			_press = ["punch", "punch", "kick", "weapon"].pick_random()
		else:
			_x = -toward
		return
	if distance > 4.5 and me.shot_left <= 0.0 and randf() < 0.35:
		_down = true
		_press = "weapon"
		_x = 0
		return
	if distance < 4.0 and randf() < 0.15:
		# Jump in with a kick.
		_x = toward
		_jump = true
		return
	if distance < 3.0 and randf() < 0.2 * level.aggression:
		_x = toward
		_press = "kick"
		return
	_x = toward if randf() < 0.85 else -toward
