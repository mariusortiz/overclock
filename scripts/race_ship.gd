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
var distance := 0.0
var offset := Vector2.ZERO
var speed := 0.0
## Fraction of the computer's top speed (difficulty).
var skill := 1.0
var shield := SHIELD
var boost_left := 0.0
var stun_left := 0.0
var respawn_left := 0.0
var finished := false
var finish_time := 0.0
## Charge of the boost the pilot triggers, 0 to 1 (gates fill it).
var boost_charge := 0.0

var _body := Node3D.new()
var _flame: MeshInstance3D


func _ready() -> void:
	add_child(_body)
	var model := _load_model()
	if model:
		_body.add_child(model)
	else:
		_build_model()
	_flame = MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.28
	cone.height = 1.6
	var flame_material := StandardMaterial3D.new()
	flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_material.albedo_color = color.lerp(Color.WHITE, 0.4)
	cone.material = flame_material
	_flame.mesh = cone
	_flame.rotation.x = -PI / 2.0
	_flame.position.z = LENGTH * 0.5 + 0.8
	_flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_body.add_child(_flame)


func is_flying() -> bool:
	return respawn_left <= 0.0


## The fastest it may go right now.
func top_speed() -> float:
	if stun_left > 0.0:
		return STUN_SPEED
	return BASE_SPEED * skill + (BOOST_SPEED if boost_left > 0.0 else 0.0)


## Advances the ship by `delta` seconds, steering by `steer` (-1 to 1 on
## each axis), then places it on `track`.
func fly(delta: float, steer: Vector2, track: RaceTrack) -> void:
	boost_left = maxf(boost_left - delta, 0.0)
	stun_left = maxf(stun_left - delta, 0.0)
	if respawn_left > 0.0:
		respawn_left -= delta
		_body.visible = int(respawn_left * 10.0) % 2 == 0
		if respawn_left <= 0.0:
			_body.visible = true
			shield = SHIELD
		speed = STUN_SPEED
	speed = move_toward(speed, top_speed(), ACCELERATION * delta)
	distance += speed * delta
	offset = RaceTrack.clamp_offset(offset + steer * STEER_SPEED * delta)
	var frame := track.frame_at(distance, offset)
	# Bank into the turn a little.
	frame.basis = frame.basis * Basis(Vector3.FORWARD, -steer.x * 0.35) * Basis(Vector3.RIGHT, steer.y * 0.15)
	transform = frame
	_flame.scale = Vector3.ONE * (1.6 if boost_left > 0.0 else 1.0) * randf_range(0.85, 1.15)


func boost(seconds := BOOST_TIME) -> void:
	boost_left = maxf(boost_left, seconds)


## Hit by a laser: slowed down, and destroyed when its shield runs out.
func hit() -> void:
	if not is_flying():
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


## A dart-shaped ship: hull, wings, fin and a glowing cockpit in its color.
func _build_model() -> void:
	var hull_material := StandardMaterial3D.new()
	hull_material.albedo_color = Color(0.85, 0.87, 0.92)
	hull_material.metallic = 0.5
	hull_material.roughness = 0.35
	var accent := StandardMaterial3D.new()
	accent.albedo_color = color
	accent.emission_enabled = true
	accent.emission = color
	accent.emission_energy_multiplier = 1.2
	var parts := [
		# [mesh size, position, material, mesh kind]
		[Vector3(0.9, 0.5, LENGTH), Vector3.ZERO, hull_material, "prism_nose"],
		[Vector3(3.2, 0.12, 1.3), Vector3(0, -0.05, 0.6), accent, "box"],
		[Vector3(0.12, 0.7, 0.9), Vector3(0, 0.45, 1.0), accent, "box"],
		[Vector3(0.5, 0.3, 0.9), Vector3(0, 0.3, -0.3), accent, "box"],
	]
	for part: Array in parts:
		var mesh_instance := MeshInstance3D.new()
		var mesh: PrimitiveMesh
		if part[3] == "prism_nose":
			var prism := PrismMesh.new()
			prism.size = Vector3(part[0].x, part[0].z, part[0].y)
			mesh = prism
			# The prism's apex is +Y: turn it to point forward (-Z).
			mesh_instance.rotation.x = -PI / 2.0
		else:
			var box := BoxMesh.new()
			box.size = part[0]
			mesh = box
		mesh.material = part[2]
		mesh_instance.mesh = mesh
		mesh_instance.position = part[1]
		_body.add_child(mesh_instance)
