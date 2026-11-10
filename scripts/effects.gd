class_name Effects
## Small one-shot visual effects shared by several scripts.


## A burst of small colored cubes at `at`. With `rise`, they float upward
## (embers, bubbles) instead of flying out and falling.
static func burst(parent: Node, at: Vector3, color: Color, amount := 24, rise := false) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 0.14
	cube.material = material

	var particles := CPUParticles3D.new()
	particles.mesh = cube
	particles.amount = amount
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.2 if rise else 1.0
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.5
	particles.direction = Vector3.UP
	particles.spread = 25.0 if rise else 180.0
	particles.gravity = Vector3(0, 1.5, 0) if rise else Vector3(0, -9.0, 0)
	particles.initial_velocity_min = 1.0 if rise else 3.0
	particles.initial_velocity_max = 2.5 if rise else 6.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.2
	particles.position = at
	parent.add_child(particles)
	particles.emitting = true
	parent.get_tree().create_timer(2.5).timeout.connect(particles.queue_free)


## A thin unshaded line from `from` to `to`, shown for a moment.
static func tracer(parent: Node, from: Vector3, to: Vector3, color: Color) -> void:
	if from.is_equal_approx(to):
		return
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.05, from.distance_to(to))
	box.material = material
	var line := MeshInstance3D.new()
	line.mesh = box
	parent.add_child(line)
	# A vertical line cannot use the default up vector.
	var direction := from.direction_to(to)
	var up := Vector3.RIGHT if absf(direction.y) > 0.99 else Vector3.UP
	line.look_at_from_position((from + to) * 0.5, to, up)
	parent.get_tree().create_timer(0.12).timeout.connect(line.queue_free)
