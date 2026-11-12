class_name RaceShip
extends Node3D
## One ship of the race, flown by the player or by the computer. It moves
## along the track (`distance`, laps included) and across it (`offset`),
## never freely: the track's frame places it (RaceTrack.frame_at).

const BASE_SPEED := 52.0
const BOOST_SPEED := 30.0
const STUN_SPEED := 22.0
const ACCELERATION := 18.0
const STEER_SPEED := 14.0
const SHIELD := 3
const BOOST_TIME := 2.2
const STUN_TIME := 0.8
const RESPAWN_TIME := 1.6
const LENGTH := 3.2
## Where custom ship models go (the first .glb, .gltf or .fbx found is used,
## nose toward -Z); without one, a ship is built from simple shapes.
const MODEL_DIR := "res://assets/models/ships/"

var color := Color.WHITE
var display_name := ""
var is_player := false
## Network play: the peer that flies this ship (0 for a computer pilot, flown
## by the host). A ship flown elsewhere is only placed (see follow_state).
var peer_id := 0
var remote := false
var distance := 0.0
var offset := Vector2.ZERO
var speed := 0.0
## Fraction of the computer's top speed (difficulty).
var skill := 1.0
var shield := SHIELD
## The ship's own attributes and special (Loadout.SHIPS), see configure().
var ship_id := ""
var max_shield := SHIELD
var velocity := 1.0
var handling := 1.0
var fire_rate := 1.0
var special := &"surboost"
## Special effects running: untouchable, invisible.
var shielded_left := 0.0
var cloak_left := 0.0
var boost_left := 0.0
var stun_left := 0.0
var respawn_left := 0.0
var finished := false
var finish_time := 0.0
## Charge of the boost the pilot triggers, 0 to 1 (gates fill it).
var boost_charge := 0.0

## Which built-in hull (0 dart, 1 delta, 2 twin boom); -1 picks one from the
## color, so each pilot keeps the same ship.
var design := -1

var _body := Node3D.new()
var _flames: Array[MeshInstance3D] = []
## Where the engines are, in the ship's frame (the flames come out of them).
var _engines: Array[Vector3] = []


func _ready() -> void:
	add_child(_body)
	var model := _load_model()
	if model:
		_body.add_child(model)
	else:
		_build_model()
	if _engines.is_empty():
		_engines.append(Vector3(0, 0, LENGTH * 0.5))
	var flame_material := StandardMaterial3D.new()
	flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_material.albedo_color = color.lerp(Color.WHITE, 0.4)
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.22 if _engines.size() > 1 else 0.3
	cone.height = 1.5
	cone.material = flame_material
	for engine in _engines:
		var flame := MeshInstance3D.new()
		flame.mesh = cone
		# The cone's tip (+Y) trails behind (+Z).
		flame.rotation.x = PI / 2.0
		flame.position = engine + Vector3(0, 0, 0.75)
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_body.add_child(flame)
		_flames.append(flame)


## Takes a ship of Loadout.SHIPS: its hull, color, attributes and special.
## Call before the ship enters the tree.
func configure(item: Dictionary) -> void:
	ship_id = item.id
	design = item.design
	color = item.color
	velocity = item.velocity
	handling = item.handling
	max_shield = item.shield
	shield = max_shield
	fire_rate = item.fire
	special = item.special


## Laser hits pass through it (rampart, cloak).
func is_untouchable() -> bool:
	return shielded_left > 0.0 or cloak_left > 0.0


func is_flying() -> bool:
	return respawn_left <= 0.0


## The fastest it may go right now.
func top_speed() -> float:
	if stun_left > 0.0:
		return STUN_SPEED
	return BASE_SPEED * skill * velocity + (BOOST_SPEED if boost_left > 0.0 else 0.0)


## Advances the ship by `delta` seconds, steering by `steer` (-1 to 1 on
## each axis), then places it on `track`.
func fly(delta: float, steer: Vector2, track: RaceTrack) -> void:
	boost_left = maxf(boost_left - delta, 0.0)
	stun_left = maxf(stun_left - delta, 0.0)
	_update_specials(delta)
	if respawn_left > 0.0:
		respawn_left -= delta
		_body.visible = int(respawn_left * 10.0) % 2 == 0
		if respawn_left <= 0.0:
			_body.visible = true
			shield = max_shield
		speed = STUN_SPEED
	speed = move_toward(speed, top_speed(), ACCELERATION * delta)
	distance += speed * delta
	offset = RaceTrack.clamp_offset(offset + steer * STEER_SPEED * handling * delta)
	var frame := track.frame_at(distance, offset)
	# Bank into the turn a little.
	frame.basis = frame.basis * Basis(Vector3.FORWARD, -steer.x * 0.35) * Basis(Vector3.RIGHT, steer.y * 0.15)
	transform = frame
	for flame in _flames:
		flame.scale = Vector3.ONE * (1.6 if boost_left > 0.0 else 1.0) * randf_range(0.85, 1.15)


## A ship flown on another device: it carries on at its last known speed,
## pulled toward the last position received.
func follow_state(delta: float, track: RaceTrack) -> void:
	boost_left = maxf(boost_left - delta, 0.0)
	_update_specials(delta)
	if respawn_left > 0.0:
		respawn_left -= delta
		_body.visible = int(respawn_left * 10.0) % 2 == 0
	else:
		_body.visible = true
	distance += speed * delta
	transform = track.frame_at(distance, offset)
	for flame in _flames:
		flame.scale = Vector3.ONE * (1.6 if boost_left > 0.0 else 1.0) * randf_range(0.85, 1.15)


## Applies a state received from the device that flies this ship.
func apply_state(state: Array) -> void:
	var received: float = state[0]
	# Small gaps are closed smoothly, big ones (a respawn) at once.
	distance = received if absf(received - distance) > 15.0 else lerpf(distance, received, 0.3)
	offset = state[1]
	speed = state[2]
	shield = state[3]
	boost_left = state[4]
	respawn_left = state[5]
	finished = state[6]
	finish_time = state[7]
	shielded_left = state[8]
	cloak_left = state[9]


func get_state() -> Array:
	return [distance, offset, speed, shield, boost_left, respawn_left, finished, finish_time, shielded_left, cloak_left]


## The rampart's glow and the cloak's fading, while they last.
func _update_specials(delta: float) -> void:
	var was_cloaked := cloak_left > 0.0
	shielded_left = maxf(shielded_left - delta, 0.0)
	cloak_left = maxf(cloak_left - delta, 0.0)
	if was_cloaked != (cloak_left > 0.0) or cloak_left > 0.0:
		for mesh: MeshInstance3D in _body.find_children("*", "MeshInstance3D", true, false):
			mesh.transparency = 0.8 if cloak_left > 0.0 else 0.0
	if _bubble:
		_bubble.visible = shielded_left > 0.0


var _bubble: MeshInstance3D


## Rampart: a golden bubble around the ship for `seconds`.
func raise_shield(seconds: float) -> void:
	shielded_left = seconds
	if _bubble == null:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(1.0, 0.8, 0.25, 0.3)
		var sphere := SphereMesh.new()
		sphere.radius = LENGTH * 0.75
		sphere.height = LENGTH * 1.2
		sphere.material = material
		_bubble = MeshInstance3D.new()
		_bubble.mesh = sphere
		add_child(_bubble)


func boost(seconds := BOOST_TIME) -> void:
	boost_left = maxf(boost_left, seconds)


## Hit by a laser: slowed down, and destroyed when its shield runs out.
func hit() -> void:
	if not is_flying() or is_untouchable():
		return
	stun_left = STUN_TIME
	shield -= 1
	Effects.burst(get_tree().current_scene, global_position, color, 20)
	if shield <= 0:
		Effects.burst(get_tree().current_scene, global_position, Color(1.0, 0.6, 0.2), 60)
		Effects.flash(get_tree().current_scene, global_position, Color(1.0, 0.6, 0.2), 10.0, 0.4)
		respawn_left = RESPAWN_TIME
		boost_left = 0.0


func _load_model() -> Node3D:
	var directory := DirAccess.open(MODEL_DIR)
	if directory == null:
		return null
	for file in directory.get_files():
		if file.get_extension().to_lower() in ["glb", "gltf", "fbx"]:
			var scene: PackedScene = load(MODEL_DIR + file)
			var model := scene.instantiate() as Node3D
			# Scaled to LENGTH, whatever size it was made at.
			var bounds := AABB()
			for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
				bounds = bounds.merge(mesh.transform * mesh.get_aabb()) if bounds.has_volume() else mesh.transform * mesh.get_aabb()
			if bounds.has_volume():
				model.scale = Vector3.ONE * LENGTH / maxf(bounds.size.z, bounds.size.x)
			return model
	return null


## A ship made of simple shapes, nose toward -Z: a light hull, dark
## details, stripes and fins in the pilot's color, a glass cockpit and
## glowing engines. Three silhouettes.
func _build_model() -> void:
	if design < 0:
		design = int(absf(color.h * 7.0 + color.s * 3.0)) % 3
	var hull := _material(Color(0.86, 0.88, 0.93), 0.5, 0.3)
	var dark := _material(Color(0.12, 0.13, 0.18), 0.6, 0.4)
	var accent := _material(color, 0.2, 0.4, 1.0)
	var glass := _material(Color(0.25, 0.75, 1.0), 0.1, 0.05, 0.6)
	var glow := _material(color.lerp(Color.WHITE, 0.5), 0.0, 0.5, 3.0)
	match design:
		0:  # Dart: long nose, swept wings, twin fins.
			_part(_prism(Vector3(0.9, LENGTH * 0.62, 0.5)), Vector3(0, 0, -LENGTH * 0.19), Vector3(-90, 0, 0), hull)
			_part(_box(Vector3(0.9, 0.5, LENGTH * 0.42)), Vector3(0, 0, LENGTH * 0.3), Vector3.ZERO, hull)
			for side: float in [-1.0, 1.0]:
				_part(_box(Vector3(1.6, 0.08, 1.0)), Vector3(side * 1.1, -0.05, 0.75), Vector3(0, side * -28.0, 0), accent)
				_part(_box(Vector3(0.08, 0.6, 0.7)), Vector3(side * 0.42, 0.45, 1.25), Vector3(0, 0, side * -12.0), accent)
			_part(_box(Vector3(0.95, 0.06, 0.25)), Vector3(0, 0.27, -0.2), Vector3.ZERO, accent)
			_part(_sphere(0.28, 0.6), Vector3(0, 0.3, -0.05), Vector3.ZERO, glass)
			_engine(Vector3(0, 0, LENGTH * 0.5), 0.28, dark, glow)
		1:  # Delta: one wide triangular wing around a short body.
			_part(_prism(Vector3(3.4, LENGTH * 0.9, 0.22)), Vector3(0, -0.02, 0.2), Vector3(-90, 0, 0), hull)
			_part(_box(Vector3(0.8, 0.45, LENGTH * 0.75)), Vector3(0, 0.1, 0.1), Vector3.ZERO, dark)
			_part(_prism(Vector3(0.8, 0.9, 0.45)), Vector3(0, 0.1, -LENGTH * 0.42), Vector3(-90, 0, 0), dark)
			for side: float in [-1.0, 1.0]:
				_part(_box(Vector3(0.12, 0.5, 0.8)), Vector3(side * 1.55, 0.2, 1.05), Vector3.ZERO, accent)
				_part(_box(Vector3(1.0, 0.04, 0.12)), Vector3(side * 0.9, 0.11, 0.5), Vector3(0, side * 20.0, 0), accent)
			_part(_sphere(0.3, 0.55), Vector3(0, 0.38, -0.3), Vector3.ZERO, glass)
			_engine(Vector3(-0.25, 0.1, LENGTH * 0.48), 0.2, dark, glow)
			_engine(Vector3(0.25, 0.1, LENGTH * 0.48), 0.2, dark, glow)
		3:  # Ram: a heavy armoured wedge with plates.
			_part(_prism(Vector3(1.8, LENGTH * 0.9, 0.9)), Vector3(0, 0.1, -0.1), Vector3(-90, 0, 0), dark)
			_part(_box(Vector3(2.0, 0.7, 1.2)), Vector3(0, 0.15, 1.0), Vector3.ZERO, hull)
			for side: float in [-1.0, 1.0]:
				_part(_box(Vector3(0.25, 0.8, 2.2)), Vector3(side * 1.05, 0.1, 0.4), Vector3(0, side * 8.0, 0), accent)
			_part(_box(Vector3(1.9, 0.12, 0.3)), Vector3(0, 0.55, -0.2), Vector3.ZERO, accent)
			_part(_sphere(0.32, 0.5), Vector3(0, 0.6, 0.6), Vector3.ZERO, glass)
			_engine(Vector3(-0.55, 0.15, LENGTH * 0.5 + 0.1), 0.3, dark, glow)
			_engine(Vector3(0.55, 0.15, LENGTH * 0.5 + 0.1), 0.3, dark, glow)
		4:  # Specter: a thin flying wing, swept back, almost flat.
			for side: float in [-1.0, 1.0]:
				_part(_box(Vector3(2.4, 0.06, 0.9)), Vector3(side * 1.0, 0, 0.5), Vector3(0, side * -35.0, 0), dark)
				_part(_box(Vector3(2.2, 0.08, 0.12)), Vector3(side * 1.0, 0.04, 0.05), Vector3(0, side * -35.0, 0), accent)
			_part(_prism(Vector3(0.7, LENGTH * 0.8, 0.3)), Vector3(0, 0.05, -0.4), Vector3(-90, 0, 0), hull)
			_part(_sphere(0.24, 0.5), Vector3(0, 0.2, -0.5), Vector3.ZERO, glass)
			_engine(Vector3(0, 0.05, LENGTH * 0.42), 0.18, dark, glow)
		5:  # Comet: a capsule inside a glowing ring.
			_part(_capsule(0.45, LENGTH * 0.85), Vector3(0, 0, 0), Vector3(-90, 0, 0), hull)
			var ring := TorusMesh.new()
			ring.inner_radius = 1.0
			ring.outer_radius = 1.2
			_part(ring, Vector3(0, 0, 0.5), Vector3(90, 0, 0), accent)
			for angle in [0.0, 120.0, 240.0]:
				_part(_box(Vector3(0.08, 1.0, 0.2)), Vector3(cos(deg_to_rad(angle + 90.0)) * 0.6, sin(deg_to_rad(angle + 90.0)) * 0.6, 0.5), Vector3(0, 0, angle), dark)
			_part(_sphere(0.3, 0.6), Vector3(0, 0.25, -0.6), Vector3.ZERO, glass)
			_engine(Vector3(0, 0, LENGTH * 0.5), 0.32, dark, glow)
		6:  # Hornet: a striped body with four small wings and two stingers.
			_part(_capsule(0.38, LENGTH * 0.75), Vector3(0, 0.05, 0.1), Vector3(-90, 0, 0), accent)
			for z in [-0.2, 0.4, 1.0]:
				_part(_box(Vector3(0.8, 0.8, 0.12)), Vector3(0, 0.05, z), Vector3.ZERO, dark)
			for side: float in [-1.0, 1.0]:
				for z: float in [-0.3, 0.5]:
					_part(_box(Vector3(1.3, 0.04, 0.5)), Vector3(side * 0.85, 0.25, z), Vector3(0, side * -20.0, side * 12.0), glass)
				_part(_box(Vector3(0.08, 0.08, 1.0)), Vector3(side * 0.25, -0.15, -1.6), Vector3.ZERO, dark)
			_part(_sphere(0.28, 0.7), Vector3(0, 0.25, -0.7), Vector3.ZERO, glass)
			_engine(Vector3(0, 0.05, LENGTH * 0.48), 0.22, dark, glow)
		7:  # Nova: a saucer with three fins and a dome.
			var disc := CylinderMesh.new()
			disc.top_radius = 1.1
			disc.bottom_radius = 1.4
			disc.height = 0.35
			_part(disc, Vector3(0, 0, 0), Vector3.ZERO, hull)
			var rim := TorusMesh.new()
			rim.inner_radius = 1.3
			rim.outer_radius = 1.45
			_part(rim, Vector3(0, 0, 0), Vector3.ZERO, accent)
			_part(_sphere(0.5, 0.7), Vector3(0, 0.3, -0.1), Vector3.ZERO, glass)
			for side: float in [-1.0, 0.0, 1.0]:
				_part(_box(Vector3(0.08, 0.5, 0.7)), Vector3(side * 0.6, 0.3, 1.0), Vector3(0, 0, side * -25.0), accent)
			_engine(Vector3(-0.5, 0, 1.3), 0.18, dark, glow)
			_engine(Vector3(0.5, 0, 1.3), 0.18, dark, glow)
		_:  # Twin boom: a pod between two engine booms.
			_part(_capsule(0.4, LENGTH * 0.7), Vector3(0, 0.1, -0.2), Vector3(-90, 0, 0), hull)
			_part(_box(Vector3(2.6, 0.08, 0.9)), Vector3(0, 0, 0.35), Vector3.ZERO, accent)
			for side: float in [-1.0, 1.0]:
				_part(_capsule(0.26, LENGTH * 0.8), Vector3(side * 1.25, 0, 0.3), Vector3(-90, 0, 0), dark)
				_part(_box(Vector3(0.06, 0.55, 0.5)), Vector3(side * 1.25, 0.35, 1.2), Vector3.ZERO, accent)
				_engine(Vector3(side * 1.25, 0, LENGTH * 0.5 + 0.2), 0.22, dark, glow)
			_part(_sphere(0.3, 0.55), Vector3(0, 0.38, -0.5), Vector3.ZERO, glass)


func _engine(at: Vector3, radius: float, shell: Material, glow: Material) -> void:
	var nozzle := CylinderMesh.new()
	nozzle.top_radius = radius
	nozzle.bottom_radius = radius * 1.2
	nozzle.height = 0.5
	_part(nozzle, at, Vector3(90, 0, 0), shell)
	var disc := CylinderMesh.new()
	disc.top_radius = radius * 0.9
	disc.bottom_radius = radius * 0.9
	disc.height = 0.05
	_part(disc, at + Vector3(0, 0, 0.26), Vector3(90, 0, 0), glow)
	_engines.append(at)


func _part(mesh: PrimitiveMesh, at: Vector3, degrees: Vector3, material: Material) -> void:
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	instance.rotation_degrees = degrees
	_body.add_child(instance)


func _material(albedo: Color, metallic: float, roughness: float, glow := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.metallic = metallic
	material.roughness = roughness
	if glow > 0.0:
		material.emission_enabled = true
		material.emission = albedo
		material.emission_energy_multiplier = glow
	return material


## A prism whose apex (+Y) is turned forward by the part's rotation.
func _prism(size: Vector3) -> PrismMesh:
	var prism := PrismMesh.new()
	prism.size = size
	return prism


func _box(size: Vector3) -> BoxMesh:
	var box := BoxMesh.new()
	box.size = size
	return box


func _sphere(radius: float, squash: float) -> SphereMesh:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0 * squash
	sphere.radial_segments = 16
	sphere.rings = 8
	return sphere


func _capsule(radius: float, length: float) -> CapsuleMesh:
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = length
	return capsule
