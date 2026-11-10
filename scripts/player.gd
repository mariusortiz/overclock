class_name Player
extends CharacterBody3D
## Third-person shooter character: always faces the camera direction.
## Yaw rotates the whole body, pitch only tilts the camera arm.

signal health_changed(current: int, maximum: int)
signal damaged
signal died
signal perks_changed

const WALK_ANIMATION_SPEED := 1.8

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
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var weapon: Weapon = $Weapon
@onready var melee: Melee = $Melee
var _model: CharacterModel

@onready var _model_pivot: Node3D = $ModelPivot
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D


func _ready() -> void:
	add_to_group("player")
	health = max_health
	_model = Loadout.instantiate_character(Loadout.selected_character())
	_model_pivot.add_child(_model)
	weapon.setup(Loadout.selected_weapon(), perks)
	melee.setup(Loadout.selected_melee())
	weapon.holder = _model
	melee.holder = _model
	melee.gun_visual = weapon.get_node("ModelPivot")
	melee.swung.connect(_on_melee_swung)
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


func take_damage(amount: int) -> void:
	if health <= 0 or invulnerable:
		return
	if has_effect(PowerUp.Type.SHIELD):
		amount = ceili(amount / 2.0)
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	damaged.emit()
	if health == 0:
		_die()


func heal(amount: int) -> void:
	if health <= 0:
		return
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)


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


func _on_melee_swung() -> void:
	_model.play(&"melee", true)
	_action_animation_left = 0.4


func _physics_process(delta: float) -> void:
	_update_effects(delta)
	_action_animation_left -= delta

	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target := transform.basis * Vector3(input.x, 0.0, input.y) * move_speed
	target *= 1.0 + Perk.SWIFT_BONUS * perks.get(Perk.Type.SWIFT, 0)
	if has_effect(PowerUp.Type.SPEED):
		target *= speed_boost
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

	move_and_slide()
	_update_animation()


func _update_animation() -> void:
	if _action_animation_left > 0.0:
		return
	# The walk cycle is sped up to match the running speed.
	if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.5:
		_model.play(&"walk", false, WALK_ANIMATION_SPEED)
	else:
		_model.play(&"aim")


func _die() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	weapon.set_physics_process(false)
	melee.set_physics_process(false)
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
