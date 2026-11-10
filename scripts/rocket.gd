class_name Rocket
extends Area3D
## Bazooka shell: flies straight and reports where it blew up. The weapon
## that fired it applies the damage.

signal exploded(at: Vector3)

@export var speed := 30.0
@export var lifetime := 4.0

var direction := Vector3.FORWARD

var _age := 0.0


func _ready() -> void:
	add_to_group("transient")
	body_entered.connect(func(_body: Node3D) -> void: _explode())


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_age += delta
	if _age >= lifetime:
		_explode()


func _explode() -> void:
	exploded.emit(global_position)
	queue_free()
