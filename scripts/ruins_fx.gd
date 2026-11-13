extends Node3D
## What moves in the star ruins, high up: stone fragments that float and turn
## around the portal, and the portal's gold light, breathing.

const FRAGMENTS := 18
## The portal's arch (see tools/make_arena.py, ruins).
const PORTAL := Vector3(0, 4.5, -26)

var _fragments: Array[MeshInstance3D] = []
var _angles: Array[float] = []
var _radii: Array[float] = []
var _heights: Array[float] = []
var _light: OmniLight3D


func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 33
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.64, 0.62, 0.74)
	stone.albedo_texture = load("res://assets/textures/panel_light.png")
	for i in FRAGMENTS:
		var fragment := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(random.randf_range(0.6, 2.2), random.randf_range(0.4, 1.4), random.randf_range(0.6, 2.0))
		fragment.mesh = box
		fragment.material_override = stone
		add_child(fragment)
		_fragments.append(fragment)
		_angles.append(random.randf() * TAU)
		_radii.append(random.randf_range(10.0, 24.0))
		_heights.append(random.randf_range(9.0, 15.0))
	_light = OmniLight3D.new()
	_light.light_color = Color(1.0, 0.75, 0.35)
	_light.omni_range = 14.0
	_light.position = PORTAL
	add_child(_light)


func _process(delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for i in _fragments.size():
		_angles[i] += delta * 0.04 * (1.0 if i % 2 else -1.0)
		var fragment := _fragments[i]
		fragment.position = Vector3(cos(_angles[i]) * _radii[i], _heights[i] + sin(time * 0.5 + i) * 0.6, sin(_angles[i]) * _radii[i] - 4.0)
		fragment.rotation.y += delta * 0.2
		fragment.rotation.x = sin(time * 0.3 + i) * 0.4
	_light.light_energy = 2.0 + sin(time * 1.4) * 0.8
