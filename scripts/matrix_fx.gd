extends Node3D
## What moves in the Matrice arena, high above the floor (nothing to bump
## into): blocks of code that hang in the air, flicker and jump from place
## to place like a glitch, and green bits falling like rain.

const BLOCKS := 16
const GREEN := Color(0.2, 1.0, 0.45)

var _blocks: Array[MeshInstance3D] = []
var _homes: Array[Vector3] = []
var _jump_left: Array[float] = []


func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 11
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.01, 0.04, 0.02)
	dark.emission_enabled = true
	dark.emission = GREEN
	dark.emission_energy_multiplier = 0.4
	var bright := StandardMaterial3D.new()
	bright.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bright.albedo_color = GREEN
	for i in BLOCKS:
		var block := MeshInstance3D.new()
		var box := BoxMesh.new()
		var side := random.randf_range(0.6, 2.4)
		box.size = Vector3(side, side * random.randf_range(0.4, 1.6), side)
		block.mesh = box
		block.material_override = bright if i % 4 == 0 else dark
		block.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var home := Vector3(random.randf_range(-26, 26), random.randf_range(8.0, 15.0), random.randf_range(-26, 26))
		block.position = home
		add_child(block)
		_blocks.append(block)
		_homes.append(home)
		_jump_left.append(random.randf_range(0.5, 4.0))
	var bits := CPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.08, 0.22)
	quad.material = bright
	bits.mesh = quad
	bits.amount = 220
	bits.lifetime = 5.0
	bits.preprocess = 5.0
	bits.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	bits.emission_box_extents = Vector3(28, 0.5, 28)
	bits.position = Vector3(0, 16, 0)
	bits.direction = Vector3.DOWN
	bits.spread = 0.0
	bits.gravity = Vector3.ZERO
	bits.initial_velocity_min = 2.5
	bits.initial_velocity_max = 4.5
	bits.particle_flag_align_y = true
	add_child(bits)


func _process(delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for i in _blocks.size():
		var block := _blocks[i]
		_jump_left[i] -= delta
		if _jump_left[i] <= 0.0:
			# A glitch: the block skips somewhere near, or back home.
			_jump_left[i] = randf_range(1.5, 5.0)
			block.position = _homes[i] + Vector3(randf_range(-3, 3), randf_range(-1, 1), randf_range(-3, 3))
		block.visible = fmod(time * (2.0 + i * 0.3), 7.0) > 0.25
		block.rotation.y += delta * (0.2 + 0.05 * i)
		block.position.y += sin(time * 0.8 + i) * delta * 0.3
