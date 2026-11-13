class_name Fighter
extends Node3D
## A fighter of the fight mode: a hero (or the Titan, the arcade's boss) moving
## on one line, left and right, jumping and crouching, seen from the side.
## This node sits at the fighter's feet; `x` is along the line, `height` above
## the ground. It reads one input per physics step (see FightInput):
## {"x": -1/0/1, "up", "down": held, "punch", "kick", "weapon", "super":
## pressed this step}. Holding away from the opponent guards.
##
## Moves (`MOVES`): punch, kick, the hero's melee weapon, and specials: down +
## punch an uppercut, down + weapon a shot (crouch or jump to dodge one),
## forward + kick a dash kick, punch or kick in the air a jump kick. The
## super (the hero's ultimate, see FightSupers) needs a full meter, filled by
## hitting and being hit.
##
## Fight runs the match: it calls step(), checks the hits, and draws nothing
## of the fighter but the HUD. `visual` names what the model shows, so that a
## networked copy (set from the host's snapshots) looks the same.

signal super_used(fighter: Fighter)
signal shot_fired(fighter: Fighter)

enum State { IDLE, WALK, JUMP, CROUCH, ATTACK, HITSTUN, BLOCKSTUN, KNOCKDOWN, KO, VICTORY, FROZEN, SUPER }

const WALK_SPEED := 3.2
const JUMP_SPEED := 8.6
const GRAVITY := 24.0
const HEIGHT := 1.75
const CROUCH_HEIGHT := 0.95
## Half the width of a body: two fighters never get closer than twice this.
const BODY := 0.38
const METER_MAX := 100.0
const SHOT_COOLDOWN := 1.4
const KNOCKDOWN_TIME := 0.9
## Invulnerable for this long after getting up.
const WAKE_UP_GUARD := 0.5

## startup / active / recovery in seconds; reach in meters in front of the
## body; stun: how long the one hit can do nothing; push: knockback in m/s.
const MOVES := {
	"punch": {"startup": 0.07, "active": 0.08, "recovery": 0.14, "damage": 5, "reach": 0.75, "stun": 0.3, "push": 2.0, "look": "punch"},
	"kick": {"startup": 0.13, "active": 0.1, "recovery": 0.24, "damage": 8, "reach": 1.0, "stun": 0.36, "push": 3.0, "look": "kick"},
	"weapon": {"startup": 0.18, "active": 0.12, "recovery": 0.32, "damage": 10, "reach": 1.2, "stun": 0.42, "push": 3.5, "look": "weapon"},
	"uppercut": {"startup": 0.08, "active": 0.14, "recovery": 0.42, "damage": 9, "reach": 0.8, "stun": 0.5, "push": 2.0, "look": "uppercut", "launch": true, "air_reach": 1.6},
	"dashkick": {"startup": 0.1, "active": 0.25, "recovery": 0.3, "damage": 10, "reach": 0.9, "stun": 0.5, "push": 5.0, "look": "kick", "dash": 9.0, "knockdown": true},
	"airkick": {"startup": 0.05, "active": 0.35, "recovery": 0.0, "damage": 7, "reach": 0.9, "stun": 0.36, "push": 2.5, "look": "kick", "air": true},
	"shot": {"startup": 0.2, "active": 0.0, "recovery": 0.3, "damage": 0, "reach": 0.0, "stun": 0.0, "push": 0.0, "look": "shoot", "shot": true},
	# Supers that move the fighter itself (see FightSupers).
	"whirl": {"startup": 0.1, "active": 0.8, "recovery": 0.25, "damage": 4, "reach": 0.9, "stun": 0.3, "push": 1.0, "look": "whirl", "dash": 7.0, "multi": 0.14},
	"charge": {"startup": 0.15, "active": 0.4, "recovery": 0.3, "damage": 20, "reach": 1.0, "stun": 0.6, "push": 7.0, "look": "weapon", "dash": 10.0, "knockdown": true},
}
## Bone turns (PoseLayer) for what the animations lack.
const POSES := {
	"kick": {"UpperLeg.R": Vector3(-95, 0, 0), "LowerLeg.R": Vector3(-5, 0, 0), "Torso": Vector3(12, 0, 0), "UpperArm.L": Vector3(-30, 0, 30)},
	"uppercut": {"UpperArm.R": Vector3(-170, 0, -10), "LowerArm.R": Vector3(-20, 0, 0), "Torso": Vector3(-12, 0, 0), "UpperLeg.L": Vector3(-30, 0, 0)},
	"crouch": {"UpperLeg.L": Vector3(-75, 0, 0), "UpperLeg.R": Vector3(-75, 0, 0), "LowerLeg.L": Vector3(115, 0, 0),
			"LowerLeg.R": Vector3(115, 0, 0), "Torso": Vector3(25, 0, 0)},
	"block": {"UpperArm.L": Vector3(-100, 0, -25), "UpperArm.R": Vector3(-100, 0, 25), "LowerArm.L": Vector3(-110, 0, 0),
			"LowerArm.R": Vector3(-110, 0, 0), "Torso": Vector3(10, 0, 0)},
	"crouch_block": {"UpperLeg.L": Vector3(-75, 0, 0), "UpperLeg.R": Vector3(-75, 0, 0), "LowerLeg.L": Vector3(115, 0, 0),
			"LowerLeg.R": Vector3(115, 0, 0), "Torso": Vector3(30, 0, 0), "UpperArm.L": Vector3(-100, 0, -25),
			"UpperArm.R": Vector3(-100, 0, 25), "LowerArm.L": Vector3(-110, 0, 0), "LowerArm.R": Vector3(-110, 0, 0)},
	"hit": {"Torso": Vector3(-25, 0, 0), "Head": Vector3(-20, 0, 0), "UpperArm.L": Vector3(20, 0, 40), "UpperArm.R": Vector3(20, 0, -40)},
	"jump": Dances.JUMP,
}
## The melee weapon each hero fights with (a Loadout.MELEE id).
const BLADES := {
	"soldier": "knife", "cowboy": "machete", "soldier_female": "karambit", "ninja": "katana", "pirate": "machete",
	"knight": "mace", "kimono": "katana", "viking": "axe", "elf": "spear", "cowgirl": "knife", "witch": "spear",
	"wizard": "spear", "golden_knight": "mace", "kunoichi": "kunai", "captain": "machete", "ronin": "katana",
	"paladin": "mace", "godfather": "butterfly", "sand_ghost": "kunai", "directeur": "butterfly",
	"createur": "ctrl_alt_del", "commander": "karambit", "programme": "katana",
}
## The arcade's last opponent.
const TITAN := {"id": "titan", "name": "Titan Mk II", "ulti": &"airstrike", "boss": true, "boost": 1.4}

var hero: Dictionary
var opponent: Fighter
var color := Color(0.16, 0.9, 1.0)
var x := 0.0
var height := 0.0
var facing := 1
var velocity := Vector2.ZERO
var state := State.IDLE
var health := 100.0
var max_health := 100.0
var meter := 0.0
## What the model shows (see the top of this file).
var visual := "idle"
## The current move (an entry of MOVES, with its "name"), and how far into it.
var move := {}
var move_time := 0.0
var move_hit := false
var state_left := 0.0
var invulnerable_left := 0.0
var shot_left := 0.0
var frozen_left := 0.0
var rage_left := 0.0
var curse_left := 0.0
var rounds_won := 0
## Set on a networked copy: positions and states come from the host.
var puppet := false

var model: CharacterModel
var _model_pivot := Node3D.new()
var _blade_holder := Node3D.new()
## Over the whole model: frozen, enraged or cursed.
var _overlay := StandardMaterial3D.new()
var _shown := ""
var _speed := 1.0
var _damage := 1.0
var _blade_damage := 10.0
var _blade_reach := 1.2


## `item` is a Loadout hero (or TITAN).
func setup(item: Dictionary, tint: Color) -> void:
	hero = item
	color = tint
	_speed = float(item.get("speed", 1.0))
	max_health = 100.0 * clampf(float(item.get("health", 100)) / 100.0, 1.0, 1.8)
	if item.get("boss", false):
		max_health = 260.0
		_speed = 0.8
	health = max_health
	var blade_item: Dictionary = Loadout.find(BLADES.get(item.id, "knife")).item
	_blade_damage = clampf(5.0 + float(blade_item.get("damage", 5)), 8.0, 20.0)
	_blade_reach = clampf(float(blade_item.get("range", 2.0)) * 0.55, 1.0, 2.0)
	add_child(_model_pivot)
	var scene: PackedScene
	if item.get("boss", false):
		scene = load(Boss.MODEL_DIR + str(Boss.INFO[Boss.Kind.TITAN].model))
	else:
		scene = load(Loadout.CHARACTER_DIR + str(item.model))
	var instance: Node3D = scene.instantiate()
	instance.set_script(CharacterModel)
	model = instance as CharacterModel
	model.target_height = 3.2 if item.get("boss", false) else HEIGHT
	_model_pivot.add_child(model)
	if item.has("glow"):
		Loadout.glow(model, item.glow)
	model.pose.space = model
	if item.get("boss", false):
		var material := StandardMaterial3D.new()
		material.albedo_texture = load(Boss.TITAN_TEXTURE)
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = material
	else:
		_model_pivot.add_child(_blade_holder)
		var blade := Loadout.instantiate_melee(blade_item)
		_blade_holder.add_child(blade)
	_overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_overlay.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_overlay.albedo_color = Color(0, 0, 0, 0)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = _overlay


func is_boss() -> bool:
	return hero.get("boss", false)


func body_height() -> float:
	if state == State.CROUCH or visual == "crouch_block":
		return CROUCH_HEIGHT
	return 3.0 if is_boss() else HEIGHT


func body_width() -> float:
	return BODY * (1.8 if is_boss() else 1.0)


func is_free() -> bool:
	return state in [State.IDLE, State.WALK, State.CROUCH]


func on_ground() -> bool:
	return height <= 0.001 and velocity.y <= 0.0


## Holding away from the opponent, on the ground and free: hits are guarded.
func is_guarding(input: Dictionary) -> bool:
	return on_ground() and (is_free() or state == State.BLOCKSTUN) and int(input.get("x", 0)) == -facing


var last_input := {}


## One physics step.
func step(input: Dictionary, delta: float) -> void:
	last_input = input
	invulnerable_left = maxf(invulnerable_left - delta, 0.0)
	shot_left = maxf(shot_left - delta, 0.0)
	rage_left = maxf(rage_left - delta, 0.0)
	if curse_left > 0.0:
		curse_left = maxf(curse_left - delta, 0.0)
		health = maxf(health - 2.0 * delta, 1.0)
	var speed := WALK_SPEED * _speed * (1.3 if rage_left > 0.0 else 1.0) * (0.6 if curse_left > 0.0 else 1.0)
	if state == State.FROZEN:
		frozen_left -= delta
		if frozen_left <= 0.0:
			state = State.IDLE
		_set_visual("frozen")
		return
	if state in [State.KO, State.VICTORY]:
		_gravity(delta)
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		x += velocity.x * delta
		return
	if state in [State.HITSTUN, State.BLOCKSTUN, State.KNOCKDOWN]:
		state_left -= delta
		_gravity(delta)
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		x += velocity.x * delta
		_set_visual({State.HITSTUN: "hit", State.BLOCKSTUN: _guard_look(input), State.KNOCKDOWN: "down"}[state])
		if state_left <= 0.0 and on_ground():
			if state == State.KNOCKDOWN:
				invulnerable_left = WAKE_UP_GUARD
			state = State.IDLE
			_set_visual("idle")
		return
	if state == State.ATTACK:
		_run_move(delta)
		return
	if state == State.SUPER:
		state_left -= delta
		if state_left <= 0.0:
			state = State.IDLE
		_set_visual("super")
		return
	# Free (or in the air).
	_face_opponent()
	var forward := int(input.get("x", 0)) == facing
	if input.get("super", false) and meter >= METER_MAX and on_ground():
		meter = 0.0
		state = State.SUPER
		state_left = 0.6
		velocity.x = 0.0
		_set_visual("super")
		super_used.emit(self)
		return
	if not on_ground():
		if (input.get("punch", false) or input.get("kick", false)) and move.is_empty():
			_start("airkick")
		_gravity(delta)
		x += velocity.x * delta
		_set_visual("jump")
		return
	move = {}
	if input.get("down", false) and input.get("punch", false):
		_start("uppercut")
	elif input.get("down", false) and input.get("weapon", false) and shot_left <= 0.0:
		_start("shot")
	elif forward and input.get("kick", false):
		_start("dashkick")
	elif input.get("punch", false):
		_start("punch")
	elif input.get("kick", false):
		_start("kick")
	elif input.get("weapon", false):
		_start("weapon")
	elif input.get("up", false):
		velocity = Vector2(float(input.get("x", 0)) * speed * 1.1, JUMP_SPEED)
		height = 0.001
		state = State.JUMP
		_set_visual("jump")
	elif input.get("down", false):
		state = State.CROUCH
		velocity.x = 0.0
		_set_visual("crouch_block" if is_guarding(input) else "crouch")
	else:
		velocity.x = float(input.get("x", 0)) * speed * (0.75 if int(input.get("x", 0)) == -facing else 1.0)
		x += velocity.x * delta
		state = State.WALK if velocity.x != 0.0 else State.IDLE
		_set_visual("block" if is_guarding(input) and _opponent_threatens() else ("walk" if velocity.x != 0.0 else "idle"))


func _guard_look(input: Dictionary) -> String:
	return "crouch_block" if input.get("down", false) else "block"


## The opponent is attacking (or a shot is coming): guarding shows.
func _opponent_threatens() -> bool:
	return opponent != null and (opponent.state in [State.ATTACK, State.SUPER])


func _start(name: String) -> void:
	move = MOVES[name].duplicate()
	move["name"] = name
	if name == "weapon":
		move.damage = _blade_damage
		move.reach = _blade_reach
	if is_boss() and name in ["punch", "kick", "weapon"]:
		move.reach = float(move.reach) + 0.9
		move.damage = float(move.damage) * 1.3
	move_time = 0.0
	move_hit = false
	if not move.get("air", false):
		state = State.ATTACK
		velocity.x = 0.0
	_set_visual(str(move.look))


## A move started by FightSupers (whirl, charge), with its own damage.
func start_super_move(name: String, damage: float) -> void:
	_start(name)
	move.damage = damage


func _run_move(delta: float) -> void:
	move_time += delta
	var startup: float = move.startup
	var active: float = move.active
	var total := startup + active + float(move.recovery)
	if move.has("dash") and move_time >= startup and move_time < startup + active:
		x += float(move.dash) * facing * delta
	if move.get("launch", false) and move_time >= startup and move_time < startup + active:
		height += 3.0 * delta
	if move.has("multi") and move_time >= startup and fmod(move_time - startup, float(move.multi)) < delta:
		move_hit = false
	if move.get("shot", false) and move_time >= startup and not move_hit:
		move_hit = true
		shot_left = SHOT_COOLDOWN
		shot_fired.emit(self)
	_gravity(delta)
	if move_time >= total:
		move = {}
		state = State.IDLE if on_ground() else State.JUMP
	_set_visual(str(move.get("look", "idle")) if not move.is_empty() else "idle")


func _gravity(delta: float) -> void:
	if height > 0.0 or velocity.y > 0.0:
		velocity.y -= GRAVITY * delta
		height += velocity.y * delta
		if height <= 0.0:
			height = 0.0
			velocity.y = 0.0
			if not move.is_empty() and move.get("air", false):
				move = {}
			if state == State.JUMP:
				state = State.IDLE


func _face_opponent() -> void:
	if opponent and on_ground():
		facing = 1 if opponent.x >= x else -1


## Is the current move's blow out now (and has not landed yet)?
func is_hitting() -> bool:
	if move.is_empty() or move_hit or move.get("shot", false):
		return false
	return move_time >= float(move.startup) and move_time < float(move.startup) + float(move.active)


## Damage dealt by this fighter, with its buffs.
func damage_scale() -> float:
	return (1.6 if rage_left > 0.0 else 1.0)


## Takes a blow: `damage`, `stun` seconds, pushed at `push` m/s away from
## `from_x`; `knockdown` drops it; `launch` throws it up. Returns false if
## guarded (chip damage only).
func take_hit(damage: float, stun: float, push: float, from_x: float, knockdown := false, launch := false, guardable := true) -> bool:
	var away := 1.0 if x >= from_x else -1.0
	if guardable and is_guarding(last_input):
		health = maxf(health - damage * 0.1, 1.0)
		state = State.BLOCKSTUN
		state_left = stun * 0.6
		velocity.x = away * push * 0.8
		meter = minf(meter + 4.0, METER_MAX)
		move = {}
		return false
	health = maxf(health - damage, 0.0)
	meter = minf(meter + damage * 0.6, METER_MAX)
	move = {}
	velocity.x = away * push
	if state == State.FROZEN:
		frozen_left = maxf(frozen_left, 0.2)
		if health <= 0.0:
			state = State.KO
		return true
	if health <= 0.0:
		state = State.KO
		velocity = Vector2(away * 4.0, 5.0)
		height = maxf(height, 0.01)
		_set_visual("ko")
		return true
	if knockdown or launch or not on_ground():
		state = State.KNOCKDOWN
		state_left = KNOCKDOWN_TIME
		velocity.y = 6.0 if launch else 3.5
		height = maxf(height, 0.01)
	else:
		state = State.HITSTUN
		state_left = stun
	return true


func freeze(seconds: float) -> void:
	state = State.FROZEN
	frozen_left = seconds
	move = {}
	velocity = Vector2.ZERO


func win() -> void:
	state = State.VICTORY
	move = {}
	_set_visual("victory")


## Back to the start of a round.
func reset(at: float) -> void:
	x = at
	height = 0.0
	velocity = Vector2.ZERO
	state = State.IDLE
	move = {}
	health = max_health
	invulnerable_left = 0.0
	frozen_left = 0.0
	rage_left = 0.0
	curse_left = 0.0
	shot_left = 0.0
	_set_visual("idle")


func _set_visual(name: String) -> void:
	visual = name


# --- Drawing ------------------------------------------------------------------

## Places the model on the line and shows `visual`. `origin` is the line's
## start in the world, `axis` its direction.
func show_on(origin: Vector3, axis: Vector3) -> void:
	global_position = origin + axis * x + Vector3.UP * height
	# The model looks along -Z: turn it to the opponent along the line.
	var look := axis * facing
	_model_pivot.global_basis = Basis.looking_at(look, Vector3.UP)
	if visual != _shown:
		_shown = visual
		_show_visual()
	if visual == "whirl":
		_model_pivot.rotate_y(Time.get_ticks_msec() / 40.0)
	if not is_boss():
		model.place_in_hand(_blade_holder, "R", true)
	var glow := Color(0, 0, 0, 0)
	if state == State.FROZEN:
		glow = Color(0.4, 0.8, 1.0, 0.45)
	elif rage_left > 0.0:
		glow = Color(1.0, 0.25, 0.15, 0.35)
	elif curse_left > 0.0:
		glow = Color(0.7, 0.2, 1.0, 0.35)
	_overlay.albedo_color = glow
	visible = not (invulnerable_left > 0.0 and fmod(Time.get_ticks_msec() / 70.0, 2.0) < 0.6)


func _show_visual() -> void:
	var pose: Dictionary = POSES.get(visual, {})
	match visual:
		"idle", "block", "crouch", "crouch_block":
			model.play(&"idle")
		"walk":
			model.play(&"walk")
		"punch", "weapon", "uppercut":
			model.play(&"melee", true, 1.6)
		"kick":
			model.play(&"idle")
		"shoot", "super":
			model.play(&"shoot", true)
		"hit", "down":
			model.play(&"idle")
			if visual == "down":
				pose = POSES.hit
		"jump":
			model.play(&"idle")
		"ko":
			model.play(&"die", true)
		"victory":
			model.play(&"victory", true)
		"whirl":
			model.play(&"melee", true, 2.0)
		"frozen":
			model.freeze(&"idle", 0.3)
	# The Titan's skeleton is not a person's: no bone turns for it.
	if is_boss():
		pose = {}
	model.pose.targets = pose
	model.pose.weight = 1.0 if not pose.is_empty() else 0.0
	_model_pivot.rotation_degrees.x = 0.0
	if visual == "down":
		# Lying on the back.
		_model_pivot.rotate_object_local(Vector3.RIGHT, deg_to_rad(-80.0))


# --- Network ------------------------------------------------------------------

func snapshot() -> Array:
	return [x, height, facing, state, visual, health, meter, rage_left > 0.0, curse_left > 0.0, invulnerable_left > 0.0, rounds_won]


func apply_snapshot(data: Array) -> void:
	x = data[0]
	height = data[1]
	facing = data[2]
	state = data[3]
	visual = data[4]
	health = data[5]
	meter = data[6]
	rage_left = 1.0 if data[7] else 0.0
	curse_left = 1.0 if data[8] else 0.0
	invulnerable_left = 1.0 if data[9] else 0.0
	rounds_won = data[10]
