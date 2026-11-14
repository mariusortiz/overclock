class_name SurvivalPiece
extends StaticBody3D
## A piece built in the survival world (see SurvivalData.PIECES), on a 2 m
## grid: floor, wall, door, stairs, roof, palisade, spike trap, turret, and
## the stations (campfire, workbench, forge), the chest and the bed. Walls and
## the like sit on a cell's edge. Creatures hit what stands in their way; at
## zero hit points the piece breaks. A door lets the player through, not the
## creatures (its own collision layer, see SurvivalCreature).

signal broken(piece: SurvivalPiece)

const CELL := 2.0
const WALL_HEIGHT := 2.6
## Collision layer of doors: only creatures collide with it.
const DOOR_LAYER := 8
const SPIKE_DAMAGE := 4
const TURRET_RANGE := 18.0
const TURRET_INTERVAL := 0.8
const TURRET_DAMAGE := 2

var type := "floor"
var material_id := "wood"
var hp := 60
var max_hp := 60
## A chest's content: {item: count}.
var content := {}

var _turret_left := 0.0
var _spike_left := 0.0
var _ghost := false


## Call before adding it. `ghost`: a see-through preview, without collision.
func configure(piece_type: String, piece_material: String, ghost := false) -> void:
	type = piece_type
	material_id = piece_material
	_ghost = ghost
	var info: Dictionary = SurvivalData.PIECES[type]
	max_hp = int(SurvivalData.MATERIALS.get(material_id, SurvivalData.MATERIALS.wood).hp)
	if info.get("station", false) or type == "turret":
		max_hp = 200
	hp = max_hp


func _ready() -> void:
	if not _ghost:
		add_to_group("survival_pieces")
		if type in ["campfire", "workbench", "forge"]:
			add_to_group("survival_stations")
	var color: Color = SurvivalData.MATERIALS.get(material_id, SurvivalData.MATERIALS.wood).color
	match type:
		"floor":
			_box(Vector3(CELL, 0.25, CELL), Vector3(0, 0.125, 0), color)
		"roof":
			_box(Vector3(CELL, 0.2, CELL), Vector3(0, WALL_HEIGHT + 0.1, 0), color.darkened(0.15))
		"wall":
			_box(Vector3(CELL, WALL_HEIGHT, 0.25), Vector3(0, WALL_HEIGHT * 0.5, 0), color)
		"door":
			_box(Vector3(0.3, WALL_HEIGHT, 0.25), Vector3(-CELL * 0.5 + 0.15, WALL_HEIGHT * 0.5, 0), color)
			_box(Vector3(0.3, WALL_HEIGHT, 0.25), Vector3(CELL * 0.5 - 0.15, WALL_HEIGHT * 0.5, 0), color)
			_box(Vector3(CELL, 0.3, 0.25), Vector3(0, WALL_HEIGHT - 0.15, 0), color)
			# The door itself: the player walks through it, creatures do not.
			var leaf := _box(Vector3(CELL - 0.6, WALL_HEIGHT - 0.3, 0.12), Vector3(0, (WALL_HEIGHT - 0.3) * 0.5, 0), color.lightened(0.2), false)
			leaf.transparency = 0.15
			if not _ghost:
				var gate := StaticBody3D.new()
				gate.collision_layer = DOOR_LAYER
				gate.collision_mask = 0
				var shape := CollisionShape3D.new()
				var box := BoxShape3D.new()
				box.size = Vector3(CELL - 0.6, WALL_HEIGHT - 0.3, 0.25)
				shape.shape = box
				shape.position = leaf.position
				gate.add_child(shape)
				add_child(gate)
		"stairs":
			for step in 5:
				_box(Vector3(CELL, 0.2, CELL / 5.0), Vector3(0, 0.25 + step * 0.5, -CELL * 0.5 + CELL / 10.0 + step * CELL / 5.0), color, false)
			_ramp(color)
		"palisade":
			for i in 5:
				var x := -CELL * 0.5 + 0.2 + i * 0.4
				_box(Vector3(0.32, WALL_HEIGHT * 0.9, 0.32), Vector3(x, WALL_HEIGHT * 0.45, 0), color.darkened(0.1 * (i % 2)), false)
				_cone(Vector3(x, WALL_HEIGHT * 0.9 + 0.2, 0), 0.18, 0.4, color.darkened(0.2))
			_shape(Vector3(CELL, WALL_HEIGHT, 0.4), Vector3(0, WALL_HEIGHT * 0.5, 0))
		"spikes":
			_box(Vector3(CELL, 0.12, CELL), Vector3(0, 0.06, 0), color.darkened(0.3), false)
			for i in 9:
				_cone(Vector3(-0.6 + (i % 3) * 0.6, 0.35, -0.6 + floori(i / 3.0) * 0.6), 0.12, 0.5, Color(0.75, 0.75, 0.78))
			collision_layer = 0
		"turret":
			_box(Vector3(0.9, 1.2, 0.9), Vector3(0, 0.6, 0), Color(0.4, 0.45, 0.5))
			_box(Vector3(0.25, 0.25, 1.2), Vector3(0, 1.4, -0.3), Color(0.2, 0.22, 0.25), false)
			_glow_dot(Vector3(0, 1.4, -0.95), Color(1.0, 0.3, 0.2))
		"campfire":
			for i in 6:
				var angle := TAU * i / 6.0
				_box(Vector3(0.3, 0.25, 0.3), Vector3(cos(angle) * 0.55, 0.12, sin(angle) * 0.55), Color(0.5, 0.5, 0.52), false)
			for i in 3:
				var stick := _box(Vector3(0.15, 0.15, 0.9), Vector3(0, 0.2, 0), Color(0.45, 0.3, 0.18), false)
				stick.rotation.y = i * PI / 3.0
			_glow_dot(Vector3(0, 0.5, 0), Color(1.0, 0.55, 0.15), 0.35)
			if not _ghost:
				var light := OmniLight3D.new()
				light.light_color = Color(1.0, 0.6, 0.3)
				light.light_energy = 2.5
				light.omni_range = 9.0
				light.position.y = 1.0
				add_child(light)
			_shape(Vector3(1.4, 0.4, 1.4), Vector3(0, 0.2, 0))
		"workbench":
			_box(Vector3(1.8, 0.15, 0.9), Vector3(0, 0.9, 0), Color(0.62, 0.45, 0.28))
			for x in [-0.8, 0.8]:
				for z in [-0.35, 0.35]:
					_box(Vector3(0.12, 0.9, 0.12), Vector3(x, 0.45, z), Color(0.45, 0.32, 0.2), false)
			_box(Vector3(0.4, 0.2, 0.25), Vector3(-0.4, 1.07, 0), Color(0.55, 0.6, 0.66), false)
		"forge":
			_box(Vector3(1.6, 1.4, 1.4), Vector3(0, 0.7, 0), Color(0.45, 0.43, 0.45))
			_box(Vector3(0.7, 0.5, 0.1), Vector3(0, 0.6, -0.71), Color(0.1, 0.05, 0.02), false)
			_glow_dot(Vector3(0, 0.6, -0.72), Color(1.0, 0.45, 0.1), 0.25)
			_box(Vector3(0.4, 1.2, 0.4), Vector3(0.45, 1.9, 0.35), Color(0.4, 0.38, 0.4), false)
		"chest":
			_box(Vector3(1.1, 0.7, 0.7), Vector3(0, 0.35, 0), Color(0.55, 0.38, 0.22))
			_box(Vector3(1.14, 0.12, 0.74), Vector3(0, 0.66, 0), Color(0.75, 0.6, 0.3), false)
		"bed":
			_box(Vector3(1.1, 0.4, 2.1), Vector3(0, 0.2, 0), Color(0.5, 0.35, 0.22))
			_box(Vector3(1.0, 0.15, 1.6), Vector3(0, 0.47, 0.2), Color(0.85, 0.3, 0.3), false)
			_box(Vector3(0.9, 0.18, 0.4), Vector3(0, 0.5, -0.75), Color(0.95, 0.95, 0.95), false)
	if _ghost:
		collision_layer = 0
		for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## A box mesh, and its collision when `solid`.
func _box(size: Vector3, at: Vector3, color: Color, solid := true) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	mesh.material_override = material
	add_child(mesh)
	if solid:
		_shape(size, at)
	return mesh


func _shape(size: Vector3, at: Vector3) -> void:
	if _ghost:
		return
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	add_child(shape)


func _cone(at: Vector3, radius: float, height: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = height
	mesh.mesh = cone
	mesh.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	add_child(mesh)


func _glow_dot(at: Vector3, color: Color, radius := 0.12) -> void:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	mesh.mesh = sphere
	mesh.position = at
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	mesh.material_override = material
	add_child(mesh)


## The walkable slope of the stairs, under the steps.
func _ramp(color: Color) -> void:
	if _ghost:
		return
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var length := sqrt(CELL * CELL + WALL_HEIGHT * WALL_HEIGHT)
	box.size = Vector3(CELL, 0.2, length)
	shape.shape = box
	shape.position = Vector3(0, WALL_HEIGHT * 0.5, 0)
	shape.rotation.x = atan2(WALL_HEIGHT, CELL)
	add_child(shape)


## Tints the preview: green where it can go, red where it cannot.
func set_valid(valid: bool) -> void:
	var tint := Color(0.3, 1.0, 0.4, 0.45) if valid else Color(1.0, 0.25, 0.2, 0.45)
	var ghost := StandardMaterial3D.new()
	ghost.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ghost.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost.albedo_color = tint
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = ghost


func take_damage(amount: int, _from := Vector3.INF) -> void:
	if _ghost or hp <= 0:
		return
	hp -= amount
	var shake := create_tween()
	shake.tween_property(self, "position:x", position.x + 0.05, 0.04)
	shake.tween_property(self, "position:x", position.x, 0.04)
	if hp <= 0:
		Effects.burst(get_tree().current_scene, global_position + Vector3.UP, SurvivalData.MATERIALS.get(material_id, SurvivalData.MATERIALS.wood).color, 24)
		broken.emit(self)
		queue_free()


func _physics_process(delta: float) -> void:
	if _ghost:
		return
	match type:
		"turret":
			_turret_left -= delta
			if _turret_left > 0.0:
				return
			_turret_left = TURRET_INTERVAL
			var muzzle := global_position + Vector3.UP * 1.4
			var best: Node3D = null
			for target: Node3D in get_tree().get_nodes_in_group("targets"):
				if target is SurvivalAnimal:
					continue
				var distance := target.global_position.distance_to(global_position)
				if distance <= TURRET_RANGE and (best == null or distance < best.global_position.distance_to(global_position)):
					best = target
			if best:
				var aim: Vector3 = best.get_aim_position() if best.has_method("get_aim_position") else best.global_position
				Effects.tracer(get_tree().current_scene, muzzle, aim, Color(1.0, 0.4, 0.3))
				best.take_damage(TURRET_DAMAGE)
		"spikes":
			_spike_left -= delta
			if _spike_left > 0.0:
				return
			_spike_left = 0.6
			for target: Node3D in get_tree().get_nodes_in_group("targets"):
				var offset := target.global_position - global_position
				if absf(offset.x) < CELL * 0.5 and absf(offset.z) < CELL * 0.5 and absf(offset.y) < 1.2:
					target.take_damage(SPIKE_DAMAGE)


## For the save.
func to_dict() -> Dictionary:
	var data := {"type": type, "material": material_id, "hp": hp, "x": position.x, "y": position.y, "z": position.z, "r": rotation.y}
	if type == "chest":
		data["content"] = content
	return data
