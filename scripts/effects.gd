class_name Effects
## Small one-shot visual effects shared by several scripts.

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const DAMAGE_COLOR := Color(1, 1, 1)
const HEADSHOT_COLOR := Color(1.0, 0.85, 0.2)
const DAMAGE_OVER_TIME_COLOR := Color(1.0, 0.55, 0.2)


## A number that pops up at `at`, drifts up and fades. It keeps the same size
## on screen whatever its distance.
static func damage_number(parent: Node, at: Vector3, amount: int, color: Color, big := false) -> void:
	var label := Label3D.new()
	label.text = str(amount)
	label.font = FONT
	label.font_size = 64 if big else 44
	label.outline_size = 14
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.fixed_size = true
	label.pixel_size = 0.0011
	label.no_depth_test = true
	label.render_priority = 10
	label.outline_render_priority = 9
	# A little sideways jitter so that quick hits do not stack on one spot.
	label.position = at + Vector3(randf_range(-0.3, 0.3), 0.2, randf_range(-0.3, 0.3))
	label.add_to_group("transient")
	parent.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y + 1.1, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(label, "scale", Vector3.ONE * 1.35, 0.08).from(Vector3.ONE * 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.4)
	tween.tween_callback(label.queue_free)


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


## A one-shot spray of small pieces at `at`. `colors` are picked at random,
## one per piece. `size` is a piece's size (a flat square when z is small).
## With `glow`, the pieces are unshaded and add light.
static func spray(parent: Node, at: Vector3, colors: Array, amount: int, size: Vector3, speed: Vector2,
		gravity: Vector3, spread := 180.0, lifetime := 1.2, glow := false) -> void:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if glow:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	var piece := BoxMesh.new()
	piece.size = size
	piece.material = material
	var ramp := Gradient.new()
	ramp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	for index in colors.size():
		offsets.append(float(index) / colors.size())
	ramp.offsets = offsets
	ramp.colors = PackedColorArray(colors)
	var particles := CPUParticles3D.new()
	particles.mesh = piece
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.4
	particles.direction = Vector3.UP
	particles.spread = spread
	particles.gravity = gravity
	particles.initial_velocity_min = speed.x
	particles.initial_velocity_max = speed.y
	particles.damping_min = 0.5
	particles.damping_max = 1.5
	particles.angle_max = 360.0
	particles.scale_amount_min = 0.6
	particles.scale_amount_max = 1.3
	particles.color_initial_ramp = ramp
	particles.position = at
	particles.add_to_group("transient")
	parent.add_child(particles)
	particles.emitting = true
	parent.get_tree().create_timer(lifetime + 1.5).timeout.connect(particles.queue_free)


## A short burst of light at `at`.
static func flash(parent: Node, at: Vector3, color: Color, energy := 8.0, seconds := 0.4) -> void:
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 8.0
	light.position = at
	light.add_to_group("transient")
	parent.add_child(light)
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, seconds)
	tween.tween_callback(light.queue_free)


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
