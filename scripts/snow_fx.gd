extends Node3D
## What moves in the Christmas village: snow falling over the whole arena,
## and the lights of the big tree, blinking in turn.

const TREE := Vector3(0, 0, -25)
const TREE_HEIGHT := 11.0
const COLORS: Array[Color] = [Color(1.0, 0.2, 0.2), Color(1.0, 0.8, 0.2), Color(0.2, 0.9, 0.4), Color(0.3, 0.6, 1.0)]

var _bulbs: Array[MeshInstance3D] = []


func _ready() -> void:
	var flake := StandardMaterial3D.new()
	flake.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flake.albedo_color = Color(1, 1, 1, 0.9)
	flake.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flake.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * 0.09
	quad.material = flake
	var snow := CPUParticles3D.new()
	snow.mesh = quad
	snow.amount = 500
	snow.lifetime = 7.0
	snow.preprocess = 7.0
	snow.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	snow.emission_box_extents = Vector3(30, 0.5, 30)
	snow.position = Vector3(0, 14, 0)
	snow.direction = Vector3.DOWN
	snow.spread = 15.0
	snow.gravity = Vector3(0.3, -0.6, 0)
	snow.initial_velocity_min = 1.0
	snow.initial_velocity_max = 1.8
	add_child(snow)
	# Bulbs in a spiral around the big tree.
	var random := RandomNumberGenerator.new()
	random.seed = 25
	for i in 36:
		var t := i / 36.0
		var height := TREE_HEIGHT * (0.3 + 0.62 * t)
		var radius := TREE_HEIGHT * 0.27 * (1.0 - t * 0.85)
		var angle := t * TAU * 4.0
		var bulb := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.16
		sphere.height = 0.32
		bulb.mesh = sphere
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = COLORS[i % COLORS.size()]
		bulb.material_override = material
		bulb.position = TREE + Vector3(cos(angle) * radius, height, sin(angle) * radius)
		add_child(bulb)
		_bulbs.append(bulb)


func _process(_delta: float) -> void:
	var step := int(Time.get_ticks_msec() / 400.0)
	for i in _bulbs.size():
		var lit := (i + step) % 3 != 0
		var material := _bulbs[i].material_override as StandardMaterial3D
		var color := COLORS[i % COLORS.size()]
		material.albedo_color = color if lit else color.darkened(0.7)
