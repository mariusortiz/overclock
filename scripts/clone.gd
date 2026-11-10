class_name Clone
extends Node3D
## Glowing copy of the player's character (the ninja's ultimate). It stays at
## the player's side and shoots the nearest enemy, then vanishes.

const LIFETIME := 12.0
const FIRE_INTERVAL := 0.35
const RANGE := 25.0
const DAMAGE := 1
const FOLLOW_SPEED := 4.0
const COLOR := Color(0.35, 0.9, 1.0)

var player: Player
## Where it stands, relative to the player.
var offset := Vector3.ZERO

var _age := 0.0
var _cooldown := 0.0
var _model: CharacterModel


func _ready() -> void:
	add_to_group("transient")
	_model = Loadout.instantiate_character(Loadout.selected_character())
	add_child(_model)
	_model.tint(COLOR, 0.8)
	_puff()


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME or player.health <= 0:
		_puff()
		queue_free()
		return

	var goal := player.global_position + player.global_basis * offset
	var step := global_position.lerp(goal, minf(FOLLOW_SPEED * delta, 1.0)) - global_position
	global_position += step
	if step.length() > 0.02:
		_model.play(&"walk", false, Player.WALK_ANIMATION_SPEED)
	else:
		_model.play(&"aim")

	var target := _nearest_enemy()
	if target == null:
		rotation.y = player.rotation.y
		return
	var to_target := target.global_position - global_position
	rotation.y = atan2(-to_target.x, -to_target.z)
	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = FIRE_INTERVAL
		var aim: Vector3 = target.get_aim_position()
		Effects.tracer(get_tree().current_scene, global_position + Vector3.UP * 1.2, aim, COLOR)
		player.weapon.tag_kill(target)
		target.take_damage(DAMAGE)


func _nearest_enemy() -> Node3D:
	var nearest: Node3D = null
	var best := RANGE
	for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
		var distance := global_position.distance_to(enemy.global_position)
		if distance < best:
			best = distance
			nearest = enemy
	return nearest


func _puff() -> void:
	Effects.burst(get_tree().current_scene, global_position + Vector3.UP, COLOR, 20)
