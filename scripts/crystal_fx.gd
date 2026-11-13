extends Node3D
## What moves on the crystal planet, above everyone's heads: shards of crystal
## that float and turn slowly, and sparks of light drifting up.

const SHARDS := 14
const COLORS: Array[Color] = [Color(0.45, 0.85, 1.0), Color(0.95, 0.45, 1.0)]

var _shards: Array[MeshInstance3D] = []


func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 21
	for i in SHARDS:
		var material := StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(COLORS[i % 2], 0.6)
		material.emission_enabled = true
		material.emission = COLORS[i % 2]
		material.emission_energy_multiplier = 1.2
		var shard := MeshInstance3D.new()
		var prism := PrismMesh.new()
		var size := random.randf_range(0.5, 1.6)
		prism.size = Vector3(size * 0.5, size * 1.8, size * 0.5)
		shard.mesh = prism
		shard.material_override = material
		shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shard.position = Vector3(random.randf_range(-26, 26), random.randf_range(8.0, 14.0), random.randf_range(-26, 26))
		shard.rotation = Vector3(random.randf_range(-0.5, 0.5), random.randf() * TAU, random.randf_range(-0.5, 0.5))
		add_child(shard)
		_shards.append(shard)
	var sparks := CPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.09, 0.09)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	glow.albedo_color = Color(0.7, 0.9, 1.0)
	quad.material = glow
	sparks.mesh = quad
	sparks.amount = 160
	sparks.lifetime = 7.0
	sparks.preprocess = 7.0
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	sparks.emission_box_extents = Vector3(28, 0.5, 28)
	sparks.position = Vector3(0, 0.5, 0)
	sparks.direction = Vector3.UP
	sparks.spread = 15.0
	sparks.gravity = Vector3.ZERO
	sparks.initial_velocity_min = 0.6
	sparks.initial_velocity_max = 1.4
	add_child(sparks)


func _process(delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for i in _shards.size():
		var shard := _shards[i]
		shard.rotation.y += delta * (0.25 + 0.04 * i)
		shard.position.y += sin(time * 0.7 + i) * delta * 0.4
