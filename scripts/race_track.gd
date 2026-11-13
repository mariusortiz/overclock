class_name RaceTrack
extends Node3D
## The race circuit: a closed loop through space. Each circuit of CIRCUITS
## has its own shape (from its seed), colors and scenery. Ships fly inside a
## tube around its center line (see frame_at): glowing gates mark it, boost
## pads and item boxes lie along it, rocks and a planet (or a sun) float
## around it.

## Half-width and half-height of the tube the ships fly in.
const HALF_WIDTH := 9.0
const HALF_HEIGHT := 5.0
const GATE_SPACING := 60.0
const PAD_SPACING := 170.0
const LIGHT_SPACING := 9.0
const CYAN := Color(0.16, 0.9, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)
const BOX_SPACING := 320.0
## Seconds before a box taken comes back.
const BOX_RESPAWN := 3.0

## The circuits: name, shape (seed, points, radius range, height), sky,
## planet or sun, rocks, colors of the lights and gates.
const CIRCUITS := [
	{"name": "Anneau d'Orion", "seed": 11, "points": 14, "radius": [170.0, 260.0], "height": 45.0,
		"sky": Color(0.02, 0.01, 0.06), "planet": Color(0.55, 0.25, 0.75), "planet_at": Vector3(-500, 160, -650), "planet_size": 220.0,
		"rocks": 160, "rock_color": Color(0.45, 0.4, 0.5), "rock_spread": [20.0, 70.0], "lights": MAGENTA, "gates": CYAN},
	{"name": "Nébuleuse", "seed": 23, "points": 18, "radius": [150.0, 280.0], "height": 70.0,
		"sky": Color(0.1, 0.02, 0.1), "planet": Color(0.1, 0.7, 0.65), "planet_at": Vector3(650, -150, 500), "planet_size": 300.0,
		"rocks": 90, "rock_color": Color(0.8, 0.4, 0.7), "rock_spread": [25.0, 80.0], "lights": CYAN, "gates": MAGENTA, "fog": Color(0.55, 0.15, 0.5)},
	{"name": "Ceinture d'astéroïdes", "seed": 37, "points": 12, "radius": [200.0, 240.0], "height": 25.0,
		"sky": Color(0.03, 0.02, 0.01), "planet": Color(0.9, 0.5, 0.2), "planet_at": Vector3(-300, 260, 450), "planet_size": 120.0,
		"rocks": 650, "rock_color": Color(0.5, 0.38, 0.28), "rock_spread": [13.0, 45.0], "lights": GOLD, "gates": GOLD},
	{"name": "Soleil rouge", "seed": 51, "points": 10, "radius": [260.0, 340.0], "height": 30.0,
		"sky": Color(0.07, 0.01, 0.0), "planet": Color(1.0, 0.3, 0.1), "planet_at": Vector3(0, 140, -950), "planet_size": 380.0, "sun": true,
		"rocks": 110, "rock_color": Color(0.25, 0.2, 0.2), "rock_spread": [20.0, 70.0], "lights": Color(1.0, 0.5, 0.15), "gates": Color(1.0, 0.35, 0.2)},
	{"name": "Labyrinthe de glace", "seed": 67, "points": 20, "radius": [120.0, 260.0], "height": 60.0,
		"sky": Color(0.0, 0.03, 0.08), "planet": Color(0.7, 0.85, 1.0), "planet_at": Vector3(-600, 200, 300), "planet_size": 260.0,
		"rocks": 240, "rock_color": Color(0.7, 0.85, 1.0), "rock_spread": [16.0, 55.0], "lights": CYAN, "gates": Color(0.6, 0.9, 1.0)},
]

var curve := Curve3D.new()
var length := 0.0
## Boost pads: [distance along the track, lateral offset (Vector2)].
var pads: Array[Array] = []
## Distances of the gates along the track.
var gates: Array[float] = []
## Item boxes: [distance along the track, lateral offset (Vector2)].
var boxes: Array[Array] = []
## The circuit built (an entry of CIRCUITS).
var circuit: Dictionary = CIRCUITS[0]
var _box_nodes: Array[Node3D] = []
## Seconds before each box is back (0: there).
var _box_away: Array[float] = []


## Builds circuit `index` of CIRCUITS.
func build(index: int) -> void:
	circuit = CIRCUITS[posmod(index, CIRCUITS.size())]
	var rng := RandomNumberGenerator.new()
	rng.seed = circuit.seed
	var count: int = circuit.points
	var points: Array[Vector3] = []
	for i in count:
		var angle := TAU * i / count
		var radius := rng.randf_range(circuit.radius[0], circuit.radius[1])
		var height := rng.randf_range(-circuit.height, circuit.height) * (0.4 if i % 2 else 1.0)
		points.append(Vector3(cos(angle) * radius, height, sin(angle) * radius))
	# Smooth handles (Catmull-Rom), the loop closed on its first point.
	for i in count + 1:
		var point := points[i % count]
		var tangent := (points[(i + 1) % count] - points[(i - 1 + count) % count]) / 6.0
		curve.add_point(point, -tangent, tangent)
	curve.bake_interval = 1.0
	length = curve.get_baked_length()
	_build_gates()
	_build_pads(rng)
	_build_boxes()
	_build_lights()
	_build_space(rng)


## Is box `index` there to be taken?
func box_ready(index: int) -> bool:
	return _box_away[index] <= 0.0


## Box `index` is taken: it disappears for a while.
func take_box(index: int) -> void:
	_box_away[index] = BOX_RESPAWN
	_box_nodes[index].visible = false


func _process(delta: float) -> void:
	for i in _box_nodes.size():
		if _box_away[i] > 0.0:
			_box_away[i] -= delta
			if _box_away[i] <= 0.0:
				_box_nodes[i].visible = true
		_box_nodes[i].rotate_object_local(Vector3(0.3, 1.0, 0.2).normalized(), delta * 2.0)


## Where a ship at `distance` along the track (laps included) and `offset`
## from the center line is, and its frame: -Z forward, +X right, +Y up.
func frame_at(distance: float, offset := Vector2.ZERO) -> Transform3D:
	var at := fposmod(distance, length)
	var here := curve.sample_baked(at, true)
	var ahead := curve.sample_baked(fposmod(at + 2.0, length), true)
	var forward := here.direction_to(ahead)
	var right := forward.cross(Vector3.UP).normalized()
	var up := right.cross(forward)
	var basis := Basis(right, up, -forward)
	return Transform3D(basis, here + right * offset.x + up * offset.y)


## Keeps a lateral offset inside the tube (an ellipse).
static func clamp_offset(offset: Vector2) -> Vector2:
	var scaled := Vector2(offset.x / HALF_WIDTH, offset.y / HALF_HEIGHT)
	if scaled.length() > 1.0:
		scaled = scaled.normalized()
	return Vector2(scaled.x * HALF_WIDTH, scaled.y * HALF_HEIGHT)


# --- Scenery ------------------------------------------------------------------

func _glow(color: Color, energy := 2.5) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _build_gates() -> void:
	var distance := 0.0
	var index := 0
	while distance < length - GATE_SPACING * 0.5:
		var ring := TorusMesh.new()
		ring.inner_radius = HALF_WIDTH + 0.6
		ring.outer_radius = HALF_WIDTH + 1.4
		ring.rings = 24
		ring.ring_segments = 6
		# The start line is gold; every fourth gate magenta.
		ring.material = _glow(GOLD if index == 0 else (MAGENTA if index % 4 == 0 else circuit.gates))
		var gate := MeshInstance3D.new()
		gate.mesh = ring
		gate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var frame := frame_at(distance)
		# The torus lies flat on XZ: stand it up across the track, squashed to the tube.
		gate.transform = Transform3D(frame.basis * Basis(Vector3.RIGHT, PI / 2.0), frame.origin)
		gate.scale = Vector3(1.0, 1.0, HALF_HEIGHT / HALF_WIDTH + 0.15)
		add_child(gate)
		gates.append(distance)
		distance += GATE_SPACING
		index += 1


func _build_pads(rng: RandomNumberGenerator) -> void:
	var distance := PAD_SPACING
	while distance < length - 30.0:
		var offset := Vector2(rng.randf_range(-0.6, 0.6) * HALF_WIDTH, rng.randf_range(-0.5, 0.5) * HALF_HEIGHT)
		pads.append([distance, offset])
		var chevron := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(3.2, 2.4, 0.3)
		mesh.material = _glow(CYAN, 4.0)
		chevron.mesh = mesh
		var frame := frame_at(distance, offset)
		# Pointing forward, flat on the ship's path.
		chevron.transform = Transform3D(frame.basis * Basis(Vector3.RIGHT, -PI / 2.0), frame.origin)
		add_child(chevron)
		distance += PAD_SPACING * rng.randf_range(0.8, 1.2)


## Rows of three item boxes across the tube, away from the start line.
func _build_boxes() -> void:
	var box := BoxMesh.new()
	box.size = Vector3.ONE * 1.6
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.55)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = circuit.lights
	material.emission_energy_multiplier = 2.5
	box.material = material
	var distance := BOX_SPACING * 0.6
	while distance < length - 60.0:
		for column in 3:
			var offset := Vector2((column - 1) * HALF_WIDTH * 0.55, 0.0)
			boxes.append([distance, offset])
			var node := MeshInstance3D.new()
			node.mesh = box
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(node)
			node.transform = frame_at(distance, offset)
			_box_nodes.append(node)
			_box_away.append(0.0)
		distance += BOX_SPACING


## Two rows of small lights along the edges of the tube, as one MultiMesh.
func _build_lights() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.35, 0.35, 1.6)
	box.material = _glow(circuit.lights, 3.0)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = box
	var count := int(length / LIGHT_SPACING)
	multimesh.instance_count = count * 2
	for i in count:
		for side in 2:
			var offset := Vector2((HALF_WIDTH + 0.8) * (1 if side else -1), -HALF_HEIGHT * 0.6)
			multimesh.set_instance_transform(i * 2 + side, frame_at(i * LIGHT_SPACING, offset))
	var lights := MultiMeshInstance3D.new()
	lights.multimesh = multimesh
	lights.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(lights)


## Stars, floating rocks and a planet.
func _build_space(rng: RandomNumberGenerator) -> void:
	var star := BoxMesh.new()
	star.size = Vector3.ONE * 1.6
	var star_material := StandardMaterial3D.new()
	star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_material.albedo_color = Color(0.9, 0.9, 1.0)
	star.material = star_material
	var stars := MultiMesh.new()
	stars.transform_format = MultiMesh.TRANSFORM_3D
	stars.mesh = star
	stars.instance_count = 900
	for i in stars.instance_count:
		var direction := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.6, 1), rng.randf_range(-1, 1)).normalized()
		stars.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * rng.randf_range(0.5, 1.5)), direction * 900.0))
	var star_field := MultiMeshInstance3D.new()
	star_field.multimesh = stars
	star_field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(star_field)

	var rock := SphereMesh.new()
	rock.radial_segments = 7
	rock.rings = 4
	var rock_material := StandardMaterial3D.new()
	rock_material.albedo_color = circuit.rock_color
	rock.material = rock_material
	var rocks := MultiMesh.new()
	rocks.transform_format = MultiMesh.TRANSFORM_3D
	rocks.mesh = rock
	rocks.instance_count = circuit.rocks
	for i in rocks.instance_count:
		# Beside the track, never in it.
		var frame := frame_at(rng.randf() * length)
		var side := frame.basis.x * (1 if rng.randf() < 0.5 else -1) * rng.randf_range(circuit.rock_spread[0], circuit.rock_spread[1])
		var size := rng.randf_range(2.0, 9.0)
		var basis := Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)).scaled(Vector3(size, size * 0.7, size * 0.85))
		rocks.set_instance_transform(i, Transform3D(basis, frame.origin + side + frame.basis.y * rng.randf_range(-25.0, 25.0)))
	var rock_field := MultiMeshInstance3D.new()
	rock_field.multimesh = rocks
	add_child(rock_field)

	var planet := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = circuit.planet_size
	sphere.height = circuit.planet_size * 2.0
	var planet_material := StandardMaterial3D.new()
	planet_material.albedo_color = circuit.planet
	planet_material.emission_enabled = true
	# A sun glows; a planet only a little.
	planet_material.emission = circuit.planet if circuit.get("sun", false) else circuit.planet * 0.35
	planet_material.emission_energy_multiplier = 3.0 if circuit.get("sun", false) else 1.0
	sphere.material = planet_material
	planet.mesh = sphere
	planet.position = circuit.planet_at
	add_child(planet)
