class_name SurvivalNode
extends StaticBody3D
## Something to harvest in the survival world (see SurvivalData.NODES): a
## tree, a rock, a vein of metal or crystal, a bush, mushrooms, a cactus, a
## crate. Each blow takes the tool's power off its hit points (the hands do 1;
## veins need a pick); at zero it gives its items and goes, to grow back two
## days later (SurvivalWorld.mark_harvested).

const NATURE := "res://assets/models/nature/"
const CRATE := "res://assets/models/melee/box-large.glb"
const MODELS := {
	"tree": ["tree_oak", "tree_default", "tree_detailed", "tree_tall", "tree_fat"],
	"palm": ["tree_palmTall", "tree_palmBend", "tree_palmDetailedTall"],
	"rock": ["rock_largeA", "rock_largeB", "rock_largeC", "rock_largeD", "rock_tallA", "rock_tallC"],
	"metal": ["rock_largeE", "rock_largeF"],
	"crystal": ["rock_tallB"],
	"bush": ["plant_bushLarge", "plant_bushDetailed"],
	"mushroom": ["mushroom_redGroup", "mushroom_tanGroup"],
	"cactus": ["cactus_tall", "cactus_short"],
}
## Height of each kind's model, in meters.
const HEIGHTS := {"tree": 6.0, "palm": 7.0, "rock": 1.8, "metal": 1.6, "crystal": 2.2, "bush": 1.2, "mushroom": 0.6,
		"cactus": 2.4, "crate": 1.0}
## Trunk-sized collision, or none for the small things one walks through.
const SOLID := ["tree", "palm", "rock", "metal", "crystal", "cactus", "crate"]

var node_id := ""
var kind := "tree"
var world: SurvivalWorld
var hp := 1

var _model: Node3D


func _ready() -> void:
	add_to_group("survival_nodes")
	hp = SurvivalData.NODES[kind].hp
	var path := CRATE if kind == "crate" else NATURE + str(MODELS[kind][absi(hash(node_id)) % MODELS[kind].size()]) + ".glb"
	_model = world.scene(path).instantiate()
	add_child(_model)
	var bounds := _bounds(_model)
	var factor := float(HEIGHTS[kind]) / maxf(bounds.size.y, 0.01)
	_model.scale = Vector3.ONE * factor
	_model.position.y = -bounds.position.y * factor
	for mesh: GeometryInstance3D in _model.find_children("*", "GeometryInstance3D", true, false):
		mesh.visibility_range_end = SurvivalWorld.VIEW_RANGE
		if kind in ["bush", "mushroom"]:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if kind == "metal":
		_dress(Color(0.42, 0.36, 0.34), Color(1.0, 0.55, 0.2), 0.6)
	elif kind == "crystal":
		_dress(Color(0.5, 0.45, 0.6), Color(0.45, 0.85, 1.0), 1.5)
	if kind in SOLID:
		var shape := CylinderShape3D.new()
		var wide: float = 0.45 if kind in ["tree", "palm", "cactus"] else 0.9
		shape.radius = wide * minf(bounds.size.x, bounds.size.z) * factor * 0.5 if kind in ["rock", "metal", "crystal", "crate"] else wide
		shape.height = float(HEIGHTS[kind])
		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.position.y = shape.height * 0.5
		add_child(collision)
	else:
		collision_layer = 0


## A vein: the rock darker, with glowing studs of its ore.
func _dress(rock: Color, ore: Color, glow: float) -> void:
	var stone := StandardMaterial3D.new()
	stone.albedo_color = rock
	for mesh: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = stone
	var shine := StandardMaterial3D.new()
	shine.albedo_color = ore
	shine.emission_enabled = true
	shine.emission = ore
	shine.emission_energy_multiplier = glow
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(node_id)
	for i in 6:
		var stud := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3.ONE * rng.randf_range(0.18, 0.35)
		box.material = shine
		stud.mesh = box
		stud.position = Vector3(rng.randf_range(-0.6, 0.6), rng.randf_range(0.3, float(HEIGHTS[kind]) * 0.9), rng.randf_range(-0.6, 0.6))
		stud.rotation = Vector3(rng.randf(), rng.randf(), rng.randf())
		add_child(stud)


static func _bounds(root: Node3D) -> AABB:
	var bounds := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var box := mesh.transform * mesh.get_aabb()
		var parent := mesh.get_parent()
		while parent != root and parent is Node3D:
			box = (parent as Node3D).transform * box
			parent = parent.get_parent()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds


## A blow with `tool` (an item of SurvivalData.ITEMS, or {} for the hands).
## Returns what it gave ({item: count}), empty until it breaks; "needs" a
## pick says nothing happens with anything else.
func hit(tool: Dictionary) -> Dictionary:
	var info: Dictionary = SurvivalData.NODES[kind]
	var tool_kind: String = tool.get("tool", "")
	if info.has("needs") and tool_kind != info.needs:
		return {"_needs": info.needs}
	var power := 1
	if tool_kind == info.tool and info.tool != "":
		power = int(tool.get("power", 1))
	elif info.tool == "":
		power = 3
	hp -= power
	# A shake, chips flying.
	var tween := create_tween()
	tween.tween_property(_model, "rotation:z", 0.06, 0.05)
	tween.tween_property(_model, "rotation:z", 0.0, 0.08)
	var chip: Color = {"tree": Color(0.6, 0.42, 0.25), "palm": Color(0.6, 0.42, 0.25), "metal": Color(1.0, 0.55, 0.2),
			"crystal": Color(0.45, 0.85, 1.0), "bush": Color(0.3, 0.7, 0.3)}.get(kind, Color(0.7, 0.7, 0.72))
	Effects.burst(get_tree().current_scene, global_position + Vector3.UP * 1.0, chip, 10)
	if hp > 0:
		return {}
	var given := {}
	for entry: Array in info.gives:
		given[entry[0]] = int(given.get(entry[0], 0)) + int(entry[1])
	if world:
		world.mark_harvested(node_id)
	var fall := create_tween()
	fall.tween_property(self, "scale", Vector3.ONE * 0.05, 0.25)
	fall.tween_callback(queue_free)
	collision_layer = 0
	return given
