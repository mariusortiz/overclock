class_name Player
extends CharacterBody3D
## Third-person shooter character: always faces the camera direction.
## Yaw rotates the whole body, pitch only tilts the camera arm.

signal health_changed(current: int, maximum: int)
signal damaged
signal died
signal perks_changed

const WALK_ANIMATION_SPEED := 1.8
## Landing: squash of the model and dust, harder after a long fall.
const LAND_SQUASH := 0.18
const HARD_LANDING_SPEED := 9.0
const DUST_COLORS: Array[Color] = [Color(0.75, 0.72, 0.68), Color(0.55, 0.53, 0.5)]
## How fast the jump and run poses blend in and out.
const POSE_BLEND_SPEED := 10.0
## Seconds for the camera to swing round to the front when a dance starts.
const DANCE_CAMERA_SPEED := 4.0
## Any of these, or moving, or being hit, stops a dance.
const DANCE_BREAKERS: Array[StringName] = [&"fire", &"aim", &"melee", &"jump", &"reload", &"ultimate", &"inspect"]

## Camera shake: how hard a hit shakes the view, and how fast it settles.
const HIT_SHAKE := 0.12
const SHAKE_DECAY := 3.5

@export var max_health := 100
@export var regen_per_second := 5.0
@export var speed_boost := 1.4
@export var power_damage_multiplier := 2
@export var move_speed := 6.0
@export var acceleration := 40.0
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0025
@export var touch_sensitivity := 0.006
@export var min_pitch_deg := -60.0
@export var max_pitch_deg := 35.0
@export var default_fov := 70.0
@export var zoom_speed := 12.0

var health := 0
## Set once the game is won: nothing can hurt the player anymore.
var invulnerable := false
## Perk.Type -> level. Shared with the weapon.
var perks := {}

var _effects := {}  # PowerUp.Type -> seconds left
var _regen_buffer := 0.0
var _action_animation_left := 0.0
var _shake := 0.0
## Index in Dances.LIST of the dance being danced, or -1.
var _dance := -1
var _dance_time := 0.0
var _was_on_floor := true
var _pivot_tween: Tween
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var weapon: Weapon = $Weapon
@onready var melee: Melee = $Melee
var ultimate := Ultimate.new()
var inspection := Inspection.new()
var _model: CharacterModel

@onready var _model_pivot: Node3D = $ModelPivot
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D


func _ready() -> void:
	add_to_group("player")
	health = max_health
	var character := Loadout.selected_character()
	_model = Loadout.instantiate_character(character)
	ultimate.setup(self, character.ulti)
	add_child(ultimate)
	_model_pivot.add_child(_model)
	weapon.setup(Loadout.selected_weapon(), perks)
	melee.setup(Loadout.selected_melee())
	weapon.holder = _model
	melee.holder = _model
	melee.gun_visual = weapon.get_node("ModelPivot")
	melee.swung.connect(_on_melee_swung)
	_camera.add_child(inspection)
	_spring_arm.add_excluded_object(get_rid())
	_spring_arm.rotation.x = deg_to_rad(-15.0)
	weapon.rotation.x = _spring_arm.rotation.x


## Point enemies aim at.
func get_aim_position() -> Vector3:
	return global_position + Vector3.UP * 1.0


func apply_power_up(type: PowerUp.Type) -> void:
	_effects[type] = PowerUp.INFO[type].duration
	_pickup_sound.play()


func has_effect(type: PowerUp.Type) -> bool:
	return _effects.has(type)


## Active effects: PowerUp.Type -> seconds left.
func get_effects() -> Dictionary:
	return _effects


func add_perk(type: Perk.Type) -> void:
	perks[type] = perks.get(type, 0) + 1
	if type == Perk.Type.VITALITY:
		max_health += Perk.VITALITY_HEALTH
		heal(Perk.VITALITY_HEALTH)
	weapon.on_perks_changed()
	perks_changed.emit()


## Call when one of the player's shots or effects destroys a robot.
func on_enemy_killed() -> void:
	heal(Perk.LIFESTEAL_HEAL * perks.get(Perk.Type.LIFESTEAL, 0))
	ultimate.add_charge(Ultimate.KILL_CHARGE)


func take_damage(amount: int) -> void:
	if health <= 0 or invulnerable or ultimate.shielded:
		return
	if has_effect(PowerUp.Type.SHIELD):
		amount = ceili(amount / 2.0)
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	damaged.emit()
	shake(HIT_SHAKE)
	stop_dance()
	if health == 0:
		_die()


func heal(amount: int) -> void:
	if health <= 0:
		return
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)


## Starts one of Dances.LIST; the camera swings round to show the hero.
func dance(index: int) -> void:
	if health <= 0:
		return
	_dance = index
	_dance_time = 0.0
	var info: Dictionary = Dances.LIST[index]
	if info.has("animation"):
		_model.set_looping(info.animation)
		_model.play(info.animation, true)
	else:
		_model.play(&"idle")
	weapon.visible = false
	melee.visible = false
	inspection.cancel()


func stop_dance() -> void:
	if _dance == -1:
		return
	_dance = -1
	weapon.visible = true
	melee.visible = true
	_model_pivot.position = Vector3.ZERO
	_model_pivot.rotation.y = 0.0


func is_dancing() -> bool:
	return _dance != -1


## Shakes the view for a moment; `strength` is in meters of camera offset.
func shake(strength: float) -> void:
	if Settings.camera_shake:
		_shake = maxf(_shake, strength)


## Rotates the view. `relative` is a screen-space drag in pixels.
func look(relative: Vector2, sensitivity: float) -> void:
	# Slower while zoomed in, in proportion to the zoom.
	sensitivity *= Settings.sensitivity * _camera.fov / default_fov
	rotate_y(-relative.x * sensitivity)
	var pitch := _spring_arm.rotation.x - relative.y * sensitivity
	_spring_arm.rotation.x = clampf(pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	weapon.rotation.x = _spring_arm.rotation.x


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative, mouse_sensitivity)


func _process(delta: float) -> void:
	var target_fov := weapon.zoom_fov if Input.is_action_pressed("aim") and health > 0 else default_fov
	_camera.fov = lerpf(_camera.fov, target_fov, minf(zoom_speed * delta, 1.0))
	_shake = move_toward(_shake, 0.0, SHAKE_DECAY * _shake * delta + 0.02 * delta)
	_camera.h_offset = randf_range(-_shake, _shake)
	_camera.v_offset = randf_range(-_shake, _shake)
	_update_pose(delta)


## Bone turns on top of the animation: the dance, the jump, or the lean of a
## run; and the camera's swing round to the front during a dance.
func _update_pose(delta: float) -> void:
	var pose := _model.pose
	var camera_pivot := _spring_arm.get_parent() as Node3D
	var front := 0.0
	if _dance != -1:
		_dance_time += delta
		var info: Dictionary = Dances.LIST[_dance]
		pose.targets = Dances.pose_at(info, _dance_time)
		pose.weight = move_toward(pose.weight, 1.0, POSE_BLEND_SPEED * delta)
		_model_pivot.position.y = Dances.bounce_at(info, _dance_time)
		_model_pivot.rotation.y = _dance_time * info.spin
		front = PI
	elif not is_on_floor():
		pose.targets = Dances.JUMP
		pose.weight = move_toward(pose.weight, 1.0, POSE_BLEND_SPEED * delta)
	else:
		var speed := Vector2(velocity.x, velocity.z).length() / move_speed
		pose.targets = Dances.RUN
		pose.weight = move_toward(pose.weight, clampf(speed, 0.0, 1.0), POSE_BLEND_SPEED * delta)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, front, minf(DANCE_CAMERA_SPEED * delta, 1.0))


func _dust(amount: int, speed: float) -> void:
	Effects.spray(get_tree().current_scene, global_position + Vector3.UP * 0.15, DUST_COLORS, amount,
			Vector3.ONE * 0.16, Vector2(speed * 0.4, speed), Vector3(0, -1.5, 0), 85.0, 0.6)


## Squashes the model for a moment, as if it took the shock.
func _squash(amount: float) -> void:
	if _pivot_tween:
		_pivot_tween.kill()
	_model_pivot.scale = Vector3(1.0 + amount * 0.6, 1.0 - amount, 1.0 + amount * 0.6)
	_pivot_tween = create_tween()
	_pivot_tween.tween_property(_model_pivot, "scale", Vector3.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_melee_swung() -> void:
	_model.play(&"melee", true)
	_action_animation_left = 0.4


func _physics_process(delta: float) -> void:
	_update_effects(delta)
	_action_animation_left -= delta
	_update_inspection()

	if _dance != -1:
		var moving := Input.get_vector("move_left", "move_right", "move_forward", "move_back") != Vector2.ZERO
		if moving or DANCE_BREAKERS.any(func(action: StringName) -> bool: return Input.is_action_pressed(action)):
			stop_dance()

	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		_dust(8, 2.0)
		_squash(LAND_SQUASH * 0.5)

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target := transform.basis * Vector3(input.x, 0.0, input.y) * move_speed
	target *= 1.0 + Perk.SWIFT_BONUS * perks.get(Perk.Type.SWIFT, 0)
	if has_effect(PowerUp.Type.SPEED):
		target *= speed_boost
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

	var falling_speed := -velocity.y
	move_and_slide()
	if is_on_floor() and not _was_on_floor:
		var hard := falling_speed >= HARD_LANDING_SPEED
		_squash(LAND_SQUASH * (1.6 if hard else 1.0))
		_dust(18 if hard else 10, 3.0 if hard else 2.0)
		if hard:
			shake(0.06)
	_was_on_floor = is_on_floor()
	_update_animation()


func _update_animation() -> void:
	if _action_animation_left > 0.0 or _dance != -1:
		return
	# The walk cycle is sped up to match the running speed.
	if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.5:
		_model.play(&"walk", false, WALK_ANIMATION_SPEED)
	else:
		_model.play(&"aim")


## Looking at one's weapon is for quiet moments: any fighting action ends it.
func _update_inspection() -> void:
	if Input.is_action_just_pressed("inspect"):
		inspection.start(weapon.current_data, Loadout.selected_skin(), Loadout.selected_melee(), Loadout.selected_melee_skin())
	elif inspection.is_playing():
		for action: StringName in [&"fire", &"aim", &"melee", &"reload", &"ultimate"]:
			if Input.is_action_pressed(action):
				inspection.cancel()
				break


func _die() -> void:
	inspection.cancel()
	stop_dance()
	set_physics_process(false)
	set_process_unhandled_input(false)
	weapon.set_physics_process(false)
	melee.set_physics_process(false)
	ultimate.set_physics_process(false)
	_model.play(&"die")
	died.emit()


func _update_effects(delta: float) -> void:
	for type: PowerUp.Type in _effects.keys():
		_effects[type] -= delta
		if _effects[type] <= 0.0:
			_effects.erase(type)

	weapon.damage_multiplier = power_damage_multiplier if has_effect(PowerUp.Type.POWER) else 1
	melee.damage_multiplier = weapon.damage_multiplier

	if has_effect(PowerUp.Type.REGEN):
		_regen_buffer += regen_per_second * delta
		if _regen_buffer >= 1.0:
			heal(int(_regen_buffer))
			_regen_buffer -= int(_regen_buffer)
