class_name Melee
extends Node3D
## Close-range secondary attack (knife, axe, spear, mace). Stats come from a
## Loadout.MELEE entry.

signal swung
signal hit_confirmed

## How long the weapon stays in the striking hand; matches the punch animation.
const SWING_TIME := 0.4


var damage := 4
var attack_range := 2.2
var cooldown := 0.5
## True: hits every robot in front. False: only the closest one.
var sweep := false
## Half-angle of the area hit, in degrees. Narrow for a thrusting weapon.
var cone_deg := 70.0
## Above 0, pushes the targets away with this speed.
var knockback := 0.0
## When set, the weapon is held in this character's left hand.
var holder: CharacterModel
## The gun's visual, hidden while the melee weapon takes its place for a swing.
var gun_visual: Node3D
var damage_multiplier := 1

var _cooldown_left := 0.0
var _swing_left := 0.0
var _tip_up := true

@onready var _model_pivot: Node3D = $ModelPivot
@onready var _hit_sound: AudioStreamPlayer = $HitSound


func setup(data: Dictionary) -> void:
	damage = data.damage
	attack_range = data.range
	cooldown = data.cooldown
	sweep = data.sweep
	cone_deg = data.cone
	knockback = data.knockback
	_tip_up = Loadout.is_carried_tip_up(data)
	_model_pivot.add_child(Loadout.instantiate_melee(data, Loadout.selected_melee_skin()))


func _process(_delta: float) -> void:
	# The weapon follows the forearm, so the character's swing carries it. It
	# rests in the left hand and moves to the striking (right) hand for a swing.
	var swinging := _swing_left > 0.0
	if holder:
		# In a swing it points where the arm strikes; at rest, see Loadout.is_carried_tip_up.
		holder.place_in_hand(_model_pivot, "R" if swinging else "L", true, _tip_up and not swinging)
	if gun_visual:
		gun_visual.visible = not swinging


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	_swing_left = maxf(_swing_left - delta, 0.0)
	if Input.is_action_just_pressed("melee") and _cooldown_left == 0.0:
		_swing()


func _swing() -> void:
	_cooldown_left = cooldown
	_swing_left = SWING_TIME
	swung.emit()

	var targets := _targets_in_reach()
	if targets.is_empty():
		return
	if not sweep:
		targets = [targets[0]]
	for target: Node3D in targets:
		target.take_damage(damage * damage_multiplier)
		if knockback > 0.0:
			var away := target.global_position - global_position
			away.y = 0.0
			target.knockback(away.normalized(), knockback)
	_hit_sound.play()
	hit_confirmed.emit()


## Robots within range and in front of the player, closest first.
func _targets_in_reach() -> Array:
	var origin := global_position
	var forward := -global_basis.z
	var found := []
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		var to_target: Vector3 = target.get_aim_position() - origin
		to_target.y = 0.0
		if to_target.length() <= attack_range and forward.angle_to(to_target) <= deg_to_rad(cone_deg):
			found.append(target)
	found.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))
	return found
