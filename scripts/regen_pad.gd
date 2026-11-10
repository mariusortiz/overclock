class_name RegenPad
extends Area3D
## Healing pad: restores health while the player stands on it. Its reserve
## empties as it heals and refills slowly on its own.

const HEAL_PER_SECOND := 10.0
const CAPACITY := 50.0
const RECHARGE_TIME := 20.0
const COLOR := Color(0.2, 1.0, 0.4)

var _reserve := CAPACITY
var _heal_buffer := 0.0
var _material := StandardMaterial3D.new()

@onready var _mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	add_to_group("regen_pads")
	_material.albedo_color = COLOR
	_material.emission_enabled = true
	_material.emission = COLOR
	_mesh.material_override = _material


## False while the reserve is empty.
func is_charged() -> bool:
	return _reserve >= 1.0


func _physics_process(delta: float) -> void:
	var player := _player_inside()
	if player and _reserve > 0.0 and player.health < player.max_health:
		var amount := minf(HEAL_PER_SECOND * delta, _reserve)
		_reserve -= amount
		_heal_buffer += amount
		if _heal_buffer >= 1.0:
			player.heal(int(_heal_buffer))
			_heal_buffer -= int(_heal_buffer)
	else:
		_reserve = minf(_reserve + CAPACITY / RECHARGE_TIME * delta, CAPACITY)
	# The glow shows how much is left.
	_material.emission_energy_multiplier = 0.2 + 2.3 * _reserve / CAPACITY


func _player_inside() -> Player:
	for body in get_overlapping_bodies():
		if body is Player and body.health > 0:
			return body
	return null
