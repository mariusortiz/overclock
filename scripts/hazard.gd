extends Area3D
## Damaging zone (lava): hurts the player at regular intervals while inside.

@export var damage := 6
@export var interval := 0.5

var _cooldown := 0.0


func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	for body in get_overlapping_bodies():
		if body is Player:
			body.take_damage(damage)
			_cooldown = interval
