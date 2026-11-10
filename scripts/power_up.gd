class_name PowerUp
extends Area3D
## Pickup dropped by robots. Walking over it gives the player a timed effect.

enum Type { REGEN, POWER, SPEED, SHIELD }

## Label, color and duration (seconds) of each effect. The effects themselves
## are applied in player.gd.
const INFO := {
	Type.REGEN: {"label": "RÉGÉNÉRATION", "color": Color(0.2, 1.0, 0.4), "duration": 8.0},
	Type.POWER: {"label": "PUISSANCE", "color": Color(1.0, 0.5, 0.1), "duration": 10.0},
	Type.SPEED: {"label": "VITESSE", "color": Color(1.0, 0.9, 0.2), "duration": 10.0},
	Type.SHIELD: {"label": "BOUCLIER", "color": Color(0.3, 0.6, 1.0), "duration": 10.0},
}
const LIFETIME := 15.0
const HOVER_HEIGHT := 0.9

var type := Type.REGEN

var _age := 0.0

@onready var _mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	add_to_group("transient")
	add_to_group("power_ups")
	var color: Color = INFO[type].color
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.0
	_mesh.material_override = material
	# Stand the cube on one corner.
	_mesh.rotation = Vector3(PI / 4.0, 0.0, atan(1.0 / sqrt(2.0)))
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	_mesh.rotate_y(delta * 2.0)
	_mesh.position.y = HOVER_HEIGHT + sin(_age * 3.0) * 0.12
	# Blink during the last seconds.
	_mesh.visible = _age < LIFETIME - 3.0 or fmod(_age, 0.3) < 0.2


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.apply_power_up(type)
		queue_free()
