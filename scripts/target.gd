class_name Target
extends StaticBody3D
## Practice target: takes a few hits, disappears, then comes back.

@export var max_health := 3
@export var respawn_delay := 2.0

var _health := 0
var _tween: Tween

@onready var _mesh: MeshInstance3D = $Mesh
@onready var _shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	add_to_group("targets")
	_health = max_health


func take_damage(amount: int) -> void:
	if _health <= 0:
		return
	_health -= amount
	if _health <= 0:
		_die()
	else:
		_mesh.scale = Vector3.ONE * 1.3
		_scale_mesh_to(Vector3.ONE, 0.12)


func _die() -> void:
	_shape.set_deferred("disabled", true)
	_scale_mesh_to(Vector3.ZERO, 0.15)
	await get_tree().create_timer(respawn_delay).timeout
	_health = max_health
	_shape.disabled = false
	_scale_mesh_to(Vector3.ONE, 0.25)


func _scale_mesh_to(target_scale: Vector3, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_mesh, "scale", target_scale, duration)
