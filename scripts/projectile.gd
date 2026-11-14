class_name Projectile
extends Area3D
## Slow, visible enemy bolt: flies straight, damages what it hits, then disappears.

@export var speed := 14.0
@export var damage := 8
@export var lifetime := 3.0

var direction := Vector3.FORWARD
## Who fired it, if it can hit its own side (battle royale): never them.
var shooter: Node3D


func _ready() -> void:
	add_to_group("transient")
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body == shooter:
		return
	if body is Player:
		body.take_damage(damage, global_position - direction * 4.0)
	elif body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
