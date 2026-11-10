class_name Enemy
extends CharacterBody3D
## Robot: chases the player along the navigation mesh, then stops and shoots
## when in range with a clear line of sight.

signal died

const REPATH_INTERVAL := 0.3
const EYE_HEIGHT := 1.2
const WORLD_MASK := 1

@export var max_health := 5
@export var move_speed := 3.5
@export var acceleration := 20.0
@export var turn_speed := 8.0
@export var attack_range := 12.0
@export var fire_interval := 1.6
@export var projectile_scene: PackedScene
@export var power_up_scene: PackedScene
@export var drop_chance := 0.25

var _health := 0
var _dead := false
var _fire_cooldown := 0.0
var _repath_left := 0.0
var _player: Player
var _tween: Tween
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _visual: Node3D = $Visual
@onready var _muzzle: Marker3D = $Visual/Muzzle
@onready var _shot_sound: AudioStreamPlayer3D = $ShotSound


func _ready() -> void:
	add_to_group("targets")
	_health = max_health
	_fire_cooldown = fire_interval
	_player = get_tree().get_first_node_in_group("player") as Player


## Point the player's shots (and aim assist) should go for.
func get_aim_position() -> Vector3:
	return global_position + Vector3.UP * 1.0


func take_damage(amount: int) -> void:
	if _dead:
		return
	_health -= amount
	if _health <= 0:
		_die()
	else:
		_visual.scale = Vector3.ONE * 1.2
		_scale_visual_to(Vector3.ONE, 0.12)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var wanted := Vector3.ZERO
	if not _dead and _player and _player.health > 0:
		var to_player := _player.global_position - global_position
		_face(to_player, delta)
		if to_player.length() <= attack_range and _has_line_of_sight():
			_fire_cooldown -= delta
			if _fire_cooldown <= 0.0:
				_shoot()
		else:
			wanted = _chase_direction(delta) * move_speed

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
	var projectile: Projectile = projectile_scene.instantiate()
	var from := _muzzle.global_position
	projectile.position = from
	projectile.direction = from.direction_to(_player.get_aim_position())
	get_tree().current_scene.add_child(projectile)
	_shot_sound.play()


func _die() -> void:
	_dead = true
	remove_from_group("targets")
	collision_layer = 0
	died.emit()
	if randf() < drop_chance:
		_drop_power_up()
	_scale_visual_to(Vector3.ZERO, 0.2)
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
