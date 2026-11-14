class_name SurvivalWorld
extends Node3D
## The survival mode's world: an island 800 m across, its relief and biomes
## drawn from noise with the world's seed (the same seed, the same world).
## Only the chunks around the player exist: they are built as the player
## walks (one per frame, so the game does not stutter) and freed behind.
##
## A chunk is CHUNK m square: a mesh colored by biome, a height-map collision,
## water where the ground dips under the sea level, and what grows there
## (SurvivalNode), placed the same way every time from the seed. What was
## harvested is remembered (see `harvested`) until it grows back.

signal chunk_built(coords: Vector2i)

const SIZE := 800.0
const CHUNK := 64.0
## Grid step of the relief, in meters.
const STEP := 2.0
const CHUNKS := 13
## Chunks within this many chunks of the player's are kept.
const LOAD_RADIUS := 2
const WATER_LEVEL := 0.0
const NODES_PER_CHUNK := 46
## Far objects are not drawn (the fog hides them anyway).
const VIEW_RANGE := 150.0

enum Biome { BEACH, FOREST, JUNGLE, DESERT, MARSH, MOUNTAIN, SNOW }
const BIOME_NAMES := {Biome.BEACH: "Plage", Biome.FOREST: "Forêt", Biome.JUNGLE: "Jungle", Biome.DESERT: "Désert",
		Biome.MARSH: "Marais", Biome.MOUNTAIN: "Montagne", Biome.SNOW: "Sommets enneigés"}
const BIOME_COLORS := {Biome.BEACH: Color(0.78, 0.72, 0.5), Biome.FOREST: Color(0.34, 0.56, 0.26),
		Biome.JUNGLE: Color(0.18, 0.48, 0.2), Biome.DESERT: Color(0.78, 0.63, 0.4), Biome.MARSH: Color(0.36, 0.42, 0.27),
		Biome.MOUNTAIN: Color(0.5, 0.48, 0.47), Biome.SNOW: Color(0.8, 0.84, 0.9)}
## What grows in each biome: [node kind, weight].
const FLORA := {
	Biome.BEACH: [["palm", 4], ["rock", 2], ["crate", 1]],
	Biome.FOREST: [["tree", 10], ["rock", 3], ["bush", 4], ["mushroom", 2], ["metal", 1], ["crate", 0.4]],
	Biome.JUNGLE: [["palm", 7], ["tree", 3], ["bush", 6], ["metal", 1], ["crate", 0.4]],
	Biome.DESERT: [["cactus", 6], ["rock", 4], ["crystal", 1], ["crate", 1.2]],
	Biome.MARSH: [["tree", 5], ["mushroom", 5], ["bush", 3], ["rock", 1]],
	Biome.MOUNTAIN: [["rock", 8], ["metal", 4], ["crystal", 2], ["tree", 1]],
	Biome.SNOW: [["rock", 5], ["crystal", 3], ["metal", 2]],
}

var seed_value := 1
## Node ids harvested -> the day they grow back.
var harvested := {}
## Read by the nodes: the current day (see SurvivalGame).
var day := 1

var _elevation := FastNoiseLite.new()
var _ridges := FastNoiseLite.new()
var _mountains := FastNoiseLite.new()
var _river := FastNoiseLite.new()
var _heat := FastNoiseLite.new()
var _wet := FastNoiseLite.new()
var _chunks := {}
var _queue: Array[Vector2i] = []
var _material := StandardMaterial3D.new()
var _water_material := StandardMaterial3D.new()
var _scenes := {}
var _immediate := false
var _focus := Vector3.ZERO
## Nodes waiting to be placed: [chunk, node], a few each frame (see _process).
var _pending: Array = []
const NODES_PER_FRAME := 12


func setup(world_seed: int) -> void:
	seed_value = world_seed
	for entry: Array in [[_elevation, 0.004, 4], [_ridges, 0.007, 3], [_mountains, 0.0022, 2], [_river, 0.0018, 1],
			[_heat, 0.0016, 2], [_wet, 0.0019, 2]]:
		var noise: FastNoiseLite = entry[0]
		noise.seed = world_seed + _noise_index(noise)
		noise.frequency = entry[1]
		noise.fractal_octaves = entry[2]
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_material.vertex_color_use_as_albedo = true
	_material.vertex_color_is_srgb = true
	_material.roughness = 0.95
	_water_material.albedo_color = Color(0.15, 0.45, 0.7, 0.72)
	_water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_water_material.roughness = 0.1
	_water_material.metallic = 0.3


func _noise_index(noise: FastNoiseLite) -> int:
	return [_elevation, _ridges, _mountains, _river, _heat, _wet].find(noise) * 1013


# --- Relief and biomes ---------------------------------------------------------------

## Ground height at (x, z): hills, mountain ranges, a winding river, and the
## sea all around the island.
func height_at(x: float, z: float) -> float:
	var distance := Vector2(x, z).length() / (SIZE * 0.5)
	var coast := smoothstep(0.8, 1.05, distance)
	var hills := _elevation.get_noise_2d(x, z)
	var ridge := 1.0 - absf(_ridges.get_noise_2d(x, z))
	var range_mask := smoothstep(0.12, 0.5, _mountains.get_noise_2d(x, z))
	var height := 6.5 + hills * 5.5 + range_mask * ridge * ridge * 46.0 - coast * 30.0
	# The river: a band carved down under the water, not through mountains.
	var bend := absf(_river.get_noise_2d(x, z))
	var carve := smoothstep(0.11, 0.0, bend) * (1.0 - range_mask) * (1.0 - coast)
	return lerpf(height, WATER_LEVEL - 1.6, carve * carve * (3.0 - 2.0 * carve))


func biome_at(x: float, z: float) -> Biome:
	var height := height_at(x, z)
	if height < WATER_LEVEL + 1.2:
		return Biome.BEACH
	if height > 30.0:
		return Biome.SNOW
	if height > 15.0 and _mountains.get_noise_2d(x, z) > 0.2:
		return Biome.MOUNTAIN
	var heat := _heat.get_noise_2d(x, z)
	var wet := _wet.get_noise_2d(x, z)
	if heat > 0.2 and wet < 0.0:
		return Biome.DESERT
	if heat > -0.08 and wet > 0.0:
		return Biome.JUNGLE
	if wet > 0.22 and height < 8.0:
		return Biome.MARSH
	return Biome.FOREST


func biome_color(x: float, z: float) -> Color:
	var color: Color = BIOME_COLORS[biome_at(x, z)]
	# A little variety, so the ground is not flat paint.
	var grain := _elevation.get_noise_2d(x * 9.0, z * 9.0) * 0.06
	return color.lightened(grain) if grain > 0.0 else color.darkened(-grain)


## A dry spot near (x, z) in a gentle biome, to start (or start again) at.
func find_spawn(near := Vector2.ZERO) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for attempt in 400:
		var radius := 10.0 + attempt * 0.8
		var point := near + Vector2.from_angle(rng.randf() * TAU) * radius
		var height := height_at(point.x, point.y)
		var flat := absf(height_at(point.x + 3.0, point.y) - height) < 1.2 and absf(height_at(point.x, point.y + 3.0) - height) < 1.2
		if height > WATER_LEVEL + 3.0 and flat and biome_at(point.x, point.y) in [Biome.FOREST, Biome.JUNGLE] and height < 12.0:
			return Vector3(point.x, height + 1.0, point.y)
	return Vector3(near.x, height_at(near.x, near.y) + 2.0, near.y)


# --- Chunks ----------------------------------------------------------------------------

func chunk_of(at: Vector3) -> Vector2i:
	var half := CHUNKS * CHUNK * 0.5
	return Vector2i(floori((at.x + half) / CHUNK), floori((at.z + half) / CHUNK))


## Keeps the chunks around `at` built, the far ones freed.
func update_focus(at: Vector3) -> void:
	_focus = at
	var center := chunk_of(at)
	for coords: Vector2i in _chunks.keys():
		if absi(coords.x - center.x) > LOAD_RADIUS + 1 or absi(coords.y - center.y) > LOAD_RADIUS + 1:
			_chunks[coords].queue_free()
			_chunks.erase(coords)
	for dx in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		for dz in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			var coords := center + Vector2i(dx, dz)
			if coords.x < 0 or coords.y < 0 or coords.x >= CHUNKS or coords.y >= CHUNKS:
				continue
			if not _chunks.has(coords) and not coords in _queue:
				_queue.append(coords)
	# Nearest first.
	_queue.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return (a - center).length_squared() < (b - center).length_squared())


## Builds every chunk around `at` now (the start, a respawn).
func build_around(at: Vector3) -> void:
	update_focus(at)
	_immediate = true
	while not _queue.is_empty():
		_build(_queue.pop_front())
	for entry: Array in _pending:
		if is_instance_valid(entry[0]):
			(entry[0] as Node).add_child(entry[1])
	_pending.clear()
	_immediate = false


func is_ready_at(at: Vector3) -> bool:
	return _chunks.has(chunk_of(at))


func _process(_delta: float) -> void:
	var placed := 0
	while not _pending.is_empty() and placed < NODES_PER_FRAME:
		var entry: Array = _pending.pop_front()
		var chunk: Node3D = entry[0]
		if is_instance_valid(chunk) and not chunk.is_queued_for_deletion():
			chunk.add_child(entry[1])
			placed += 1
		else:
			(entry[1] as Node).free()
	if not _queue.is_empty() and _pending.size() < NODES_PER_CHUNK:
		var coords: Vector2i = _queue.pop_front()
		var center := chunk_of(_focus)
		if absi(coords.x - center.x) <= LOAD_RADIUS + 1 and absi(coords.y - center.y) <= LOAD_RADIUS + 1:
			_build(coords)


func _build(coords: Vector2i) -> void:
	if _chunks.has(coords):
		return
	var chunk := Node3D.new()
	chunk.name = "Chunk_%d_%d" % [coords.x, coords.y]
	var origin := Vector2(coords.x * CHUNK - CHUNKS * CHUNK * 0.5, coords.y * CHUNK - CHUNKS * CHUNK * 0.5)
	chunk.position = Vector3(origin.x, 0, origin.y)
	add_child(chunk)
	_chunks[coords] = chunk
	var cells := int(CHUNK / STEP)
	var heights := PackedFloat32Array()
	heights.resize((cells + 1) * (cells + 1))
	var colors := PackedColorArray()
	colors.resize((cells + 1) * (cells + 1))
	var lowest := INF
	for j in cells + 1:
		for i in cells + 1:
			var height := height_at(origin.x + i * STEP, origin.y + j * STEP)
			heights[j * (cells + 1) + i] = height
			colors[j * (cells + 1) + i] = biome_color(origin.x + i * STEP, origin.y + j * STEP)
			lowest = minf(lowest, height)
	# The ground's mesh, colored by biome.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in cells:
		for i in cells:
			var corners: Array[int] = []
			for corner: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				corners.append((j + corner.y) * (cells + 1) + i + corner.x)
			for index: int in [0, 1, 2, 0, 2, 3]:
				var point := corners[index]
				surface.set_color(colors[point])
				surface.add_vertex(Vector3((point % (cells + 1)) * STEP, heights[point], (point / (cells + 1)) * STEP))
	surface.generate_normals()
	var ground := MeshInstance3D.new()
	ground.mesh = surface.commit()
	ground.material_override = _material
	# The hills are shaded by their slopes; their shadows over the coarse
	# shadow map only made big dark wedges.
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk.add_child(ground)
	# Its collision: a height map, centered on the chunk.
	var body := StaticBody3D.new()
	var shape := HeightMapShape3D.new()
	shape.map_width = cells + 1
	shape.map_depth = cells + 1
	shape.map_data = heights
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.scale = Vector3(STEP, 1.0, STEP)
	collision.position = Vector3(CHUNK * 0.5, 0, CHUNK * 0.5)
	body.add_child(collision)
	chunk.add_child(body)
	# The sea, the river and the lakes.
	if lowest < WATER_LEVEL:
		var plane := PlaneMesh.new()
		plane.size = Vector2(CHUNK, CHUNK)
		plane.material = _water_material
		var water := MeshInstance3D.new()
		water.mesh = plane
		water.position = Vector3(CHUNK * 0.5, WATER_LEVEL, CHUNK * 0.5)
		water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		chunk.add_child(water)
	_grow(chunk, coords, origin)
	chunk_built.emit(coords)


## What grows on a chunk, always the same for the same seed.
func _grow(chunk: Node3D, coords: Vector2i, origin: Vector2) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, coords.x, coords.y])
	for index in NODES_PER_CHUNK:
		var x := origin.x + rng.randf() * CHUNK
		var z := origin.y + rng.randf() * CHUNK
		var roll := rng.randf()
		var yaw := rng.randf() * TAU
		var size_factor := rng.randf_range(0.85, 1.25)
		var id := "%d:%d:%d" % [coords.x, coords.y, index]
		var height := height_at(x, z)
		if height < WATER_LEVEL + 0.3:
			continue
		var kind := _pick(FLORA[biome_at(x, z)], roll)
		if harvested.has(id) and int(harvested[id]) > day:
			continue
		harvested.erase(id)
		var node := SurvivalNode.new()
		node.node_id = id
		node.kind = kind
		node.world = self
		node.position = Vector3(x, height, z) - chunk.position
		node.rotation.y = yaw
		node.scale = Vector3.ONE * size_factor
		if _immediate:
			chunk.add_child(node)
		else:
			_pending.append([chunk, node])


func _pick(table: Array, roll: float) -> String:
	var total := 0.0
	for entry: Array in table:
		total += entry[1]
	var left := roll * total
	for entry: Array in table:
		left -= entry[1]
		if left <= 0.0:
			return entry[0]
	return table[0][0]


## A model of the nature kit, kept loaded once.
func scene(path: String) -> PackedScene:
	if not _scenes.has(path):
		_scenes[path] = load(path)
	return _scenes[path]


## A node was harvested: it comes back in two days.
func mark_harvested(node_id: String) -> void:
	harvested[node_id] = day + 2
