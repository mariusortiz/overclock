class_name Pet
extends Node3D
## A pet of Pets.LIST, following `owner_node` (the player, a fighter, a hero
## on a menu stage) a little to its right. It walks (or hops, or flies) when
## its owner moves, jumps for joy at a kill, dances along, and plays its perk
## while Pets.enabled. With no owner it stays on the spot (showcases).

const SIDE := Vector3(1.1, 0, -0.2)
const SPEED := 9.0
## Farther than this from its place, it jumps there at once.
const TELEPORT := 14.0
const FLY_HEIGHT := 1.5
const HOP_HEIGHT := 0.18
## Seconds between two uses of each perk that acts by itself.
const PERIODS := {&"echo": 3.0, &"spit": 5.0, &"bite": 3.0, &"jelly": 3.0, &"dive": 6.0, &"turret": 1.5,
		&"breath": 5.0, &"song": 8.0, &"magnet": 0.2, &"capy": 0.5}
const RANGES := {&"echo": 16.0, &"spit": 14.0, &"bite": 4.0, &"dive": 20.0, &"turret": 18.0, &"breath": 12.0, &"song": 6.0, &"capy": 25.0}
const MAGNET_RANGE := 10.0
const MAGNET_SPEED := 8.0

var pet: Dictionary
var owner_node: Node3D
## Where it stands, in its owner's frame (the fight mode puts it behind).
var offset := SIDE

var _body := Node3D.new()
var _player: AnimationPlayer
var _idle := ""
var _move := ""
var _moving := false
var _time := 0.0
var _hop_left := 0.0
var _perk_left := 1.0
var _flying := false
var _capy_beats := 0
## The capybara's god mode (see _capy_god).
const CAPY_AURA := 10.0
const CAPY_BOSS_SHARE := 0.015
const CAPY_HEAL := 5
var _accessory: Dictionary


## Call before adding it to the scene. `accessory` defaults to the one the
## player chose (Pets.selected_accessory).
func configure(item: Dictionary, follow: Node3D = null, accessory: Dictionary = {}) -> void:
	pet = item
	owner_node = follow
	_flying = item.get("fly", false)
	_accessory = accessory if not accessory.is_empty() else Pets.selected_accessory()


func _ready() -> void:
	add_child(_body)
	if pet.is_empty() or pet.id == Pets.NONE.id:
		return
	var model := build_model(pet, _accessory)
	_body.add_child(model)
	_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _player:
		for name in _player.get_animation_list():
			var lower := name.to_lower()
			if _idle == "" and "idle" in lower:
				_idle = name
			if _move == "" and ("walk" in lower or "run" in lower or "fly" in lower):
				_move = name
			_player.get_animation(name).loop_mode = Animation.LOOP_LINEAR
		if _idle == "":
			_idle = _player.get_animation_list()[0]
		_player.play(_idle)
	if owner_node:
		global_position = _place()
	_perk_left = PERIODS.get(pet.perk, 1.0)


## The pet's model, scaled to its height, standing on its origin and facing
## -Z like the heroes. Used by the menus, the cards and the anime too.
static func build_model(item: Dictionary, accessory: Dictionary = {}) -> Node3D:
	var holder := Node3D.new()
	var model: Node3D
	match item.get("build", ""):
		"drone":
			model = _drone()
		"shard":
			model = _shard()
		"capybara":
			model = _capybara()
		_:
			model = (load(item.model) as PackedScene).instantiate()
	holder.add_child(model)
	var colors: Dictionary = item.get("colors", {})
	if not colors.is_empty():
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var original := mesh.mesh.surface_get_material(surface)
				if original and colors.has(original.resource_name):
					var painted := StandardMaterial3D.new()
					painted.albedo_color = colors[original.resource_name]
					mesh.set_surface_override_material(surface, painted)
	if item.id == "pet_titan":
		var metal := StandardMaterial3D.new()
		metal.albedo_texture = load(Boss.TITAN_TEXTURE)
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = metal
	# Scale from the skeleton's rest pose (skinned meshes' own bounds do not
	# follow their bones), or from the meshes when there is none.
	var bounds := _bones_bounds(model)
	if bounds.size.y <= 0.0:
		bounds = _bounds(model)
	var height: float = maxf(bounds.size.y, 0.001)
	var scale_factor: float = float(item.height) / height
	model.scale *= scale_factor
	model.position = Vector3(-bounds.get_center().x, -bounds.position.y, -bounds.get_center().z) * scale_factor
	# Turned on a node of its own: the model's root may carry a rotation of its
	# own (the file's axes). Like the heroes (CharacterModel), a skeleton whose
	# left side is at +X faces +Z, so it is turned around.
	var turn := Node3D.new()
	holder.remove_child(model)
	turn.add_child(model)
	holder.add_child(turn)
	turn.rotation.y = float(item.get("turn", 0.0)) + (PI if _left_side_x(model) > 0.0 else 0.0)
	if not accessory.is_empty() and accessory.id != Pets.ACCESSORY_NONE.id:
		holder.add_child(wear(item, accessory))
	return holder


## The accessory on the pet's head (or round its neck), sized to the pet.
## Its "head" (top of the head and its width, in the model's frame facing
## -Z) is set by eye for each pet in Pets.LIST.
static func wear(item: Dictionary, accessory: Dictionary) -> Node3D:
	# "head": [height, forward, width], in units of the pet's height.
	var shape: Array = item.get("head", [1.0, -0.45, 0.45])
	var unit: float = item.height
	var size: float = shape[2] * unit
	var head := Vector3(0, shape[0] * unit, shape[1] * unit)
	var worn := PetAccessory.build(accessory.id)
	worn.scale = Vector3.ONE * size
	worn.position = head
	if accessory.get("neck", false):
		worn.position += Vector3(0, -size * 0.75, size * 0.35)
	return worn


## Starts the model's idle animation (a model from build_model shown alone).
static func play_idle(model: Node) -> void:
	var player := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null or player.get_animation_list().is_empty():
		return
	var idle: String = player.get_animation_list()[0]
	for name in player.get_animation_list():
		if "idle" in name.to_lower():
			idle = name
			break
	player.get_animation(idle).loop_mode = Animation.LOOP_LINEAR
	player.play(idle)


static func _left_side_x(root: Node3D) -> float:
	for skeleton: Skeleton3D in root.find_children("*", "Skeleton3D", true, false):
		for bone in skeleton.get_bone_count():
			var bone_name := skeleton.get_bone_name(bone)
			if bone_name.ends_with(".L") or bone_name.begins_with("L."):
				return (skeleton.transform * skeleton.get_bone_global_rest(bone).origin).x
	return 0.0


static func _bones_bounds(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for skeleton: Skeleton3D in root.find_children("*", "Skeleton3D", true, false):
		var transform := Transform3D.IDENTITY
		var node: Node = skeleton
		while node != root and node is Node3D:
			transform = (node as Node3D).transform * transform
			node = node.get_parent()
		for bone in skeleton.get_bone_count():
			var point := transform * skeleton.get_bone_global_rest(bone).origin
			if first:
				result = AABB(point, Vector3.ZERO)
				first = false
			else:
				result = result.expand(point)
	return result


static func _bounds(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var transform := Transform3D.IDENTITY
		var node: Node = mesh
		while node != root and node is Node3D:
			transform = (node as Node3D).transform * transform
			node = node.get_parent()
		var box := transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result


static func _drone() -> Node3D:
	var drone := Node3D.new()
	var shell := StandardMaterial3D.new()
	shell.albedo_color = Color(0.85, 0.88, 0.95)
	shell.metallic = 0.6
	shell.roughness = 0.3
	var eye := StandardMaterial3D.new()
	eye.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.albedo_color = Color(0.16, 0.9, 1.0)
	var body := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 0.8
	sphere.material = shell
	body.mesh = sphere
	drone.add_child(body)
	var lens := MeshInstance3D.new()
	var dot := SphereMesh.new()
	dot.radius = 0.16
	dot.height = 0.32
	dot.material = eye
	lens.mesh = dot
	lens.position = Vector3(0, 0.05, -0.45)
	drone.add_child(lens)
	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.5, 0.06, 0.12)
		box.material = shell
		arm.mesh = box
		arm.position = Vector3(side * 0.6, 0.15, 0)
		drone.add_child(arm)
		var rotor := MeshInstance3D.new()
		var disc := CylinderMesh.new()
		disc.top_radius = 0.28
		disc.bottom_radius = 0.28
		disc.height = 0.03
		disc.material = eye
		rotor.mesh = disc
		rotor.position = Vector3(side * 0.85, 0.22, 0)
		drone.add_child(rotor)
	return drone


## Le Créateur's capybara: a brown barrel on short legs, a square head with
## a blunt muzzle, small ears, a mandarin on its head, and the green glow of
## his code. Facing -Z.
static func _capybara() -> Node3D:
	var capybara := Node3D.new()
	var fur := StandardMaterial3D.new()
	fur.albedo_color = Color(0.55, 0.38, 0.24)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.28, 0.18, 0.12)
	var muzzle := StandardMaterial3D.new()
	muzzle.albedo_color = Color(0.45, 0.3, 0.19)
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.05, 0.05, 0.05)
	var orange := StandardMaterial3D.new()
	orange.albedo_color = Color(1.0, 0.55, 0.1)
	var leaf := StandardMaterial3D.new()
	leaf.albedo_color = Color(0.2, 0.6, 0.2)
	var parts := [
		# [mesh size, position, material]: body, head, muzzle, ears, eyes, nose, legs.
		[Vector3(0.7, 0.55, 1.1), Vector3(0, 0.5, 0.05), fur],
		[Vector3(0.46, 0.44, 0.62), Vector3(0, 0.74, -0.66), fur],
		[Vector3(0.42, 0.36, 0.2), Vector3(0, 0.68, -1.04), muzzle],
		[Vector3(0.1, 0.09, 0.06), Vector3(-0.18, 1.0, -0.42), dark],
		[Vector3(0.1, 0.09, 0.06), Vector3(0.18, 1.0, -0.42), dark],
		[Vector3(0.05, 0.07, 0.06), Vector3(-0.24, 0.86, -0.82), black],
		[Vector3(0.05, 0.07, 0.06), Vector3(0.24, 0.86, -0.82), black],
		[Vector3(0.16, 0.05, 0.04), Vector3(0, 0.76, -1.15), black],
	]
	for corner in [Vector3(-0.24, 0.13, -0.32), Vector3(0.24, 0.13, -0.32), Vector3(-0.24, 0.13, 0.4), Vector3(0.24, 0.13, 0.4)]:
		parts.append([Vector3(0.16, 0.26, 0.16), corner, dark])
	for part: Array in parts:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = part[0]
		box.material = part[2]
		mesh.mesh = box
		mesh.position = part[1]
		capybara.add_child(mesh)
	# The mandarin, and its leaf.
	var fruit := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.11
	sphere.height = 0.2
	sphere.material = orange
	fruit.mesh = sphere
	fruit.position = Vector3(0, 1.06, -0.62)
	capybara.add_child(fruit)
	var stem := MeshInstance3D.new()
	var blade := BoxMesh.new()
	blade.size = Vector3(0.1, 0.02, 0.05)
	blade.material = leaf
	stem.mesh = blade
	stem.position = Vector3(0.05, 1.17, -0.62)
	stem.rotation.z = 0.4
	capybara.add_child(stem)
	# A faint green glow: Le Créateur's code.
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.albedo_color = Color(0.2, 1.0, 0.45, 0.08)
	for mesh: MeshInstance3D in capybara.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = glow
	return capybara


static func _shard() -> Node3D:
	var shard := Node3D.new()
	var crystal := StandardMaterial3D.new()
	crystal.albedo_color = Color(0.55, 0.85, 1.0, 0.8)
	crystal.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal.emission_enabled = true
	crystal.emission = Color(0.45, 0.85, 1.0)
	crystal.emission_energy_multiplier = 0.8
	for part: Array in [[Vector3(0.3, 1.0, 0.3), Vector3.ZERO, 0.0], [Vector3(0.18, 0.55, 0.18), Vector3(0.2, -0.15, 0.05), 0.5],
			[Vector3(0.16, 0.45, 0.16), Vector3(-0.18, -0.2, -0.05), -0.45]]:
		var mesh := MeshInstance3D.new()
		var prism := PrismMesh.new()
		prism.size = part[0]
		prism.material = crystal
		mesh.mesh = prism
		mesh.position = part[1]
		mesh.rotation.z = part[2]
		shard.add_child(mesh)
	return shard


## A jump for joy (a kill nearby).
func cheer() -> void:
	_hop_left = 0.5


func _process(delta: float) -> void:
	if pet.is_empty() or pet.id == Pets.NONE.id:
		return
	_time += delta
	var dancing := owner_node is Player and (owner_node as Player)._dance >= 0
	if owner_node and is_instance_valid(owner_node):
		var goal := _place()
		var gap := goal - global_position
		if gap.length() > TELEPORT:
			global_position = goal
		else:
			var step := gap.limit_length(SPEED * delta * clampf(gap.length(), 0.3, 1.5))
			global_position += step
		_moving = Vector2(gap.x, gap.z).length() > 0.35
		var facing := owner_node.global_basis.z if not _moving else -gap
		facing.y = 0.0
		if dancing:
			rotation.y += delta * 4.0
		elif facing.length() > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(-facing.x, -facing.z) + (PI if not _moving else 0.0), minf(delta * 8.0, 1.0))
	# Bobbing: hops when it walks without a walk of its own, floats when it flies.
	var lift := 0.0
	if _flying:
		# Lower on a menu stage, where there is no one to fly over.
		lift = (FLY_HEIGHT if owner_node else 0.7) + sin(_time * 2.4) * 0.12
	elif _moving and _move == "":
		lift = absf(sin(_time * 9.0)) * HOP_HEIGHT
	if _hop_left > 0.0 or dancing:
		_hop_left = maxf(_hop_left - delta, 0.0)
		lift += absf(sin(_time * 12.0)) * 0.35
	_body.position.y = lift
	if _player:
		var wanted := _move if _moving and _move != "" else _idle
		if _player.current_animation != wanted:
			_player.play(wanted, 0.2)
	if pet.perk != &"" and Pets.perk() == pet.perk:
		_perk_left -= delta
		if _perk_left <= 0.0:
			_perk_left = PERIODS.get(pet.perk, 1.0)
			_use_perk()


## Where it wants to be: beside its owner, on the owner's level.
func _place() -> Vector3:
	return owner_node.global_position + owner_node.global_basis * offset


# --- Perks that act by themselves ---------------------------------------------------

func _use_perk() -> void:
	var player := owner_node as Player
	match pet.perk:
		&"magnet":
			if player:
				for power_up: Node3D in get_tree().get_nodes_in_group("power_ups"):
					var to_player := player.global_position - power_up.global_position
					if to_player.length() < MAGNET_RANGE:
						power_up.global_position += to_player.limit_length(MAGNET_SPEED * PERIODS.magnet)
		&"capy":
			_capy_god(player)
		&"jelly":
			if player and player.health < player.max_health:
				player.heal(1)
				Effects.burst(get_tree().current_scene, _mouth(), Color(0.4, 1.0, 0.5), 6)
		&"song":
			var hit := false
			for target in _targets(RANGES.song):
				if target.has_method("chill"):
					target.chill(2)
				hit = true
			if hit:
				_ring(Color(0.45, 0.85, 1.0))
		_:
			var target := _nearest(RANGES.get(pet.perk, 10.0))
			if target == null:
				return
			var at: Vector3 = target.get_aim_position() if target.has_method("get_aim_position") else target.global_position + Vector3.UP
			match pet.perk:
				&"echo":
					_zap(at, Color(0.75, 0.5, 1.0), 2, target)
				&"turret":
					_zap(at, Color(0.16, 0.9, 1.0), 1, target)
				&"bite":
					_hop_left = 0.3
					_zap(at, Color(1, 1, 1), 3, target)
				&"dive":
					_hop_left = 0.4
					_zap(at, Color(1.0, 0.85, 0.4), 4, target)
				&"spit":
					_zap(at, Color(0.8, 1.0, 0.85), 0, target)
					if target.has_method("chill"):
						target.chill(1)
				&"breath":
					_zap(at, Color(1.0, 0.5, 0.1), 1, target)
					if target.has_method("ignite"):
						target.ignite(1)


## Le Créateur's capybara, god mode, every half second: ordinary enemies
## within CAPY_AURA are wiped out, bosses within reach lose a share of their
## life, and every second it heals its owner and strikes three targets.
func _capy_god(player: Player) -> void:
	var green := Color(0.2, 1.0, 0.45)
	_capy_beats += 1
	for target in _targets(RANGES.capy):
		var close := target.global_position.distance_to(global_position) <= CAPY_AURA
		if target is Boss:
			var boss := target as Boss
			_zap(boss.get_aim_position(), green, maxi(ceili(boss.max_health * CAPY_BOSS_SHARE), 1), boss)
		elif target is Enemy and close:
			_zap((target as Enemy).get_aim_position(), green, (target as Enemy).max_health * 10, target)
	if _capy_beats % 2 == 1:
		return
	if player and player.health < player.max_health:
		player.heal(CAPY_HEAL)
	var struck := 0
	for target in _by_distance(_targets(RANGES.capy)):
		if struck == 3 or not is_instance_valid(target) or (target is Enemy and (target as Enemy)._dead):
			continue
		var at: Vector3 = target.get_aim_position() if target.has_method("get_aim_position") else target.global_position + Vector3.UP
		_zap(at, green, 20, target)
		struck += 1


func _by_distance(targets: Array[Node3D]) -> Array[Node3D]:
	targets.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
	return targets


## Hostile targets of the player within `radius` of the pet.
func _targets(radius: float) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for target: Node3D in get_tree().get_nodes_in_group("targets"):
		if target is Enemy and ((target as Enemy)._dead or (target as Enemy).team == &"ally"):
			continue
		if target.global_position.distance_to(global_position) <= radius:
			found.append(target)
	return found


func _nearest(radius: float) -> Node3D:
	var best: Node3D = null
	for target in _targets(radius):
		if best == null or target.global_position.distance_to(global_position) < best.global_position.distance_to(global_position):
			best = target
	return best


func _mouth() -> Vector3:
	return global_position + Vector3.UP * (_body.position.y + float(pet.height) * 0.7)


## A short line of light from the pet to `at`, and its damage.
func _zap(at: Vector3, color: Color, damage: int, target: Node3D) -> void:
	var from := _mouth()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.05, from.distance_to(at))
	box.material = material
	var beam := MeshInstance3D.new()
	beam.mesh = box
	get_tree().current_scene.add_child(beam)
	beam.look_at_from_position((from + at) * 0.5, at, Vector3.RIGHT if absf(from.direction_to(at).y) > 0.99 else Vector3.UP)
	var tween := beam.create_tween()
	tween.tween_property(beam, "scale", Vector3(0.1, 0.1, 1.0), 0.2)
	tween.tween_callback(beam.queue_free)
	Effects.burst(get_tree().current_scene, at, color, 10)
	if damage > 0:
		target.take_damage(damage, from)


func _ring(color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color, 0.7)
	var torus := TorusMesh.new()
	torus.inner_radius = 0.45
	torus.outer_radius = 0.5
	torus.material = material
	var ring := MeshInstance3D.new()
	ring.mesh = torus
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position + Vector3.UP * 0.2
	var tween := ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(12, 1, 12), 0.6)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.6)
	tween.tween_callback(ring.queue_free)
