class_name Enemy
extends CharacterBody3D
## Robot: chases the player along the navigation mesh, then stops and shoots
## when in range with a clear line of sight.

signal died
signal health_changed(current: int, maximum: int)

const REPATH_INTERVAL := 0.3
const EYE_HEIGHT := 1.2
const WORLD_MASK := 1
const SHOOT_ANIMATION_TIME := 0.4
const DEATH_ANIMATION_TIME := 1.0
const BURN_DURATION := 3.0
const BURN_TICK := 0.5
const CHILL_DURATION := 2.5
const BURN_COLOR := Color(1.0, 0.45, 0.1)
const CHILL_COLOR := Color(0.5, 0.85, 1.0)

@export var max_health := 5
@export var move_speed := 3.5
@export var acceleration := 20.0
@export var turn_speed := 8.0
@export var attack_range := 12.0
@export var fire_interval := 1.6
@export var projectile_scene: PackedScene
@export var model_scene: PackedScene
## Height of the point shots are aimed at.
@export var aim_height := 1.0
@export var power_up_scene: PackedScene
@export var drop_chance := 0.25

var _health := 0
var _dead := false
var _fire_cooldown := 0.0
var _repath_left := 0.0
var _shoot_animation_left := 0.0
var _burn_left := 0.0
var _burn_tick_left := 0.0
var _burn_damage := 0
var _chill_left := 0.0
var _chill_factor := 1.0
var _status_material := StandardMaterial3D.new()
var _player: Player
var _model: CharacterModel
var _base_scale := Vector3.ONE
var _attack_animation := &"holding-right-shoot"
var _tween: Tween
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _visual: Node3D = $Visual
@onready var _model_pivot: Node3D = $Visual/ModelPivot
@onready var _muzzle: Marker3D = $Visual/Muzzle
@onready var _status_orb: MeshInstance3D = $Visual/StatusOrb
@onready var _shot_sound: AudioStreamPlayer3D = $ShotSound
@onready var _death_sound: AudioStreamPlayer3D = $DeathSound


func _ready() -> void:
	add_to_group("targets")
	_health = max_health
	_base_scale = _visual.scale
	var model: Node3D = model_scene.instantiate()
	model.set_script(CharacterModel)
	_model = model as CharacterModel
	_model_pivot.add_child(_model)
	_fire_cooldown = fire_interval
	_status_material.emission_enabled = true
	_status_material.emission_energy_multiplier = 2.0
	_status_orb.material_override = _status_material
	_status_orb.visible = false
	_player = get_tree().get_first_node_in_group("player") as Player


## Point the player's shots (and aim assist) should go for.
func get_aim_position() -> Vector3:
	return global_position + Vector3.UP * aim_height


func take_damage(amount: int) -> void:
	if _dead:
		return
	_health -= amount
	health_changed.emit(maxi(_health, 0), max_health)
	if _health <= 0:
		_die()
	else:
		_visual.scale = _base_scale * 1.2
		_scale_visual_to(_base_scale, 0.12)


## Fire perk: takes `damage_per_tick` twice a second for a few seconds.
func ignite(damage_per_tick: int) -> void:
	_burn_left = BURN_DURATION
	_burn_damage = damage_per_tick


## Ice perk: moves and shoots more slowly for a moment.
func chill(level: int) -> void:
	_chill_left = CHILL_DURATION
	_chill_factor = maxf(pow(0.6, level), 0.3)


func _update_statuses(delta: float) -> void:
	_chill_left = maxf(_chill_left - delta, 0.0)
	if _burn_left > 0.0:
		_burn_left -= delta
		_burn_tick_left -= delta
		if _burn_tick_left <= 0.0:
			_burn_tick_left = BURN_TICK
			take_damage(_burn_damage)

	_status_orb.visible = not _dead and (_burn_left > 0.0 or _chill_left > 0.0)
	var color := BURN_COLOR if _burn_left > 0.0 else CHILL_COLOR
	_status_material.albedo_color = color
	_status_material.emission = color


func _physics_process(delta: float) -> void:
	_update_statuses(delta)
	var slow := _chill_factor if _chill_left > 0.0 else 1.0

	if not is_on_floor():
		velocity.y -= _gravity * delta

	var wanted := Vector3.ZERO
	var animation := &"idle"
	if not _dead and _player and _player.health > 0:
		var to_player := _player.global_position - global_position
		_face(to_player, delta)
		if to_player.length() <= attack_range and _has_line_of_sight():
			animation = &"holding-right"
			_fire_cooldown -= delta * slow
			if _fire_cooldown <= 0.0:
				_shoot()
		else:
			wanted = _chase_direction(delta) * move_speed * slow
			if not wanted.is_zero_approx():
				animation = &"walk"

	# Let the one-shot shooting animation finish before switching back.
	_shoot_animation_left -= delta
	if not _dead and _shoot_animation_left <= 0.0:
		_model.play(animation)

	velocity.x = move_toward(velocity.x, wanted.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, wanted.z, acceleration * delta)
	move_and_slide()


func _face(to_player: Vector3, delta: float) -> void:
	var target_yaw := atan2(-to_player.x, -to_player.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, minf(turn_speed * delta, 1.0))


func _has_line_of_sight() -> bool:
	var from := global_position + Vector3.UP * EYE_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, _player.get_aim_position(), WORLD_MASK)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _chase_direction(delta: float) -> Vector3:
	# The navigation map is empty until the arena has baked and synced.
	if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
		return Vector3.ZERO
	_repath_left -= delta
	if _repath_left <= 0.0:
		_repath_left = REPATH_INTERVAL
		_agent.target_position = _player.global_position
	if _agent.is_navigation_finished():
		return Vector3.ZERO
	var direction := _agent.get_next_path_position() - global_position
	direction.y = 0.0
	return direction.normalized()


func _shoot() -> void:
	_fire_cooldown = fire_interval
	_attack()
	_shot_sound.play()
	_model.play(_attack_animation, true)
	_shoot_animation_left = SHOOT_ANIMATION_TIME


## What a shot does. Bosses override this.
func _attack() -> void:
	_spawn_projectile(_muzzle.global_position.direction_to(_player.get_aim_position()))


func _spawn_projectile(direction: Vector3) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.position = _muzzle.global_position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)


func _die() -> void:
	_dead = true
	remove_from_group("targets")
	collision_layer = 0
	died.emit()
	if randf() < drop_chance:
		_drop_power_up()
	_model.play(&"die")
	_death_sound.play()
	# Fall over, then shrink away.
	if _tween:
		_tween.kill()
	_visual.scale = _base_scale
	_tween = create_tween()
	_tween.tween_interval(DEATH_ANIMATION_TIME)
	_tween.tween_property(_visual, "scale", Vector3.ZERO, 0.2)
	_tween.tween_callback(queue_free)


func _scale_visual_to(target_scale: Vector3, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_visual, "scale", target_scale, duration)


func _drop_power_up() -> void:
	var power_up: PowerUp = power_up_scene.instantiate()
	power_up.type = PowerUp.Type.values().pick_random()
	power_up.position = global_position
	get_tree().current_scene.add_child(power_up)
