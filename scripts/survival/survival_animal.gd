class_name SurvivalAnimal
extends CharacterBody3D
## A wild animal of the survival world (the pets' models): it grazes and
## wanders, runs off when hurt, and gives meat and leather when hunted.

signal died(animal: SurvivalAnimal)

const KINDS := ["pet_sheep", "pet_pig", "pet_chick", "pet_calf", "pet_llama"]
const SPEED := 2.0
const FLEE_SPEED := 6.0

var pet_id := "pet_sheep"
var health := 6

var _model: Node3D
var _goal := Vector3.INF
var _wander_left := 0.0
var _flee_left := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	add_to_group("targets")
	add_to_group("survival_animals")
	collision_layer = 4
	collision_mask = 1
	var pet := Pets.find(pet_id)
	_model = Pet.build_model(pet)
	_model.scale *= 1.4
	add_child(_model)
	Pet.play_idle(_model)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.0
	shape.shape = capsule
	shape.position.y = 0.5
	add_child(shape)


func get_aim_position() -> Vector3:
	return global_position + Vector3.UP * 0.6


func take_damage(amount: int, from := Vector3.INF) -> void:
	if health <= 0:
		return
	health -= amount
	Effects.damage_number(get_tree().current_scene, get_aim_position() + Vector3.UP * 0.4, amount, Effects.DAMAGE_COLOR, false)
	_flee_left = 6.0
	var player: Node3D = get_tree().get_first_node_in_group("player")
	var threat := from if from != Vector3.INF else (player.global_position if player else global_position)
	_goal = global_position + (global_position - threat).normalized() * 25.0
	if health <= 0:
		Effects.burst(get_tree().current_scene, get_aim_position(), Color(0.9, 0.3, 0.3), 20)
		died.emit(self)
		queue_free()


## The shots tag what they hit for a kill effect; animals just fall.
func set_kill_effect(_style: StringName, _color: Color) -> void:
	pass


func mark_headshot() -> void:
	pass


func ignite(_level: int) -> void:
	pass


func chill(_level: int) -> void:
	pass


func knockback(direction: Vector3, strength: float) -> void:
	velocity += direction * strength


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	_flee_left -= delta
	_wander_left -= delta
	if _wander_left <= 0.0 and _flee_left <= 0.0:
		_wander_left = randf_range(3.0, 7.0)
		_goal = global_position + Vector3(randf_range(-8, 8), 0, randf_range(-8, 8)) if randf() < 0.6 else Vector3.INF
	var wanted := Vector3.ZERO
	if _goal != Vector3.INF:
		var to_goal := _goal - global_position
		to_goal.y = 0.0
		if to_goal.length() > 0.8:
			wanted = to_goal.normalized() * (FLEE_SPEED if _flee_left > 0.0 else SPEED)
			rotation.y = lerp_angle(rotation.y, atan2(-wanted.x, -wanted.z), minf(delta * 6.0, 1.0))
		else:
			_goal = Vector3.INF
	velocity.x = move_toward(velocity.x, wanted.x, 20.0 * delta)
	velocity.z = move_toward(velocity.z, wanted.z, 20.0 * delta)
	move_and_slide()
	if is_on_wall() and is_on_floor():
		velocity.y = 5.0
