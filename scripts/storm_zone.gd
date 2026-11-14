class_name StormZone
extends Node3D
## The battle royale's safe zone: a circle that shrinks in steps. Outside it,
## the storm hurts everyone a little every second. A glowing wall shows its
## edge; the minimap draws it too.

signal step_started(index: int)

## [radius, seconds it waits, seconds it takes to shrink to it].
const STEPS := [[70.0, 40.0, 0.0], [48.0, 30.0, 20.0], [32.0, 25.0, 18.0], [18.0, 20.0, 15.0], [8.0, 20.0, 12.0], [3.0, 15.0, 10.0]]
const DAMAGE := 4
const COLOR := Color(0.6, 0.25, 1.0)
const WALL_HEIGHT := 40.0

var radius := 70.0
var step := 0

var _from := 70.0
var _to := 70.0
var _wait := 0.0
var _shrink := 0.0
var _shrink_time := 0.0
var _hurt_left := 1.0
var _wall: MeshInstance3D


func _ready() -> void:
	add_to_group("storm_zone")
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(COLOR, 0.28)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = WALL_HEIGHT
	mesh.cap_top = false
	mesh.cap_bottom = false
	mesh.radial_segments = 64
	mesh.material = material
	_wall = MeshInstance3D.new()
	_wall.mesh = mesh
	_wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_wall.position.y = WALL_HEIGHT / 2.0 - 2.0
	add_child(_wall)
	_begin(0)


func contains(at: Vector3) -> bool:
	return Vector2(at.x - global_position.x, at.z - global_position.z).length() <= radius


## A random point inside the zone, within `share` of its radius.
func random_point(share: float) -> Vector3:
	var offset := Vector2.from_angle(randf() * TAU) * sqrt(randf()) * radius * share
	return global_position + Vector3(offset.x, 0.2, offset.y)


func _begin(index: int) -> void:
	step = index
	_from = radius
	_to = STEPS[index][0]
	_wait = STEPS[index][1]
	_shrink_time = STEPS[index][2]
	_shrink = 0.0
	step_started.emit(index)


func _physics_process(delta: float) -> void:
	if _shrink < _shrink_time:
		_shrink += delta
		radius = lerpf(_from, _to, clampf(_shrink / _shrink_time, 0.0, 1.0))
	else:
		radius = _to
		_wait -= delta
		if _wait <= 0.0 and step < STEPS.size() - 1:
			_begin(step + 1)
	_wall.scale = Vector3(radius, 1.0, radius)
	_hurt_left -= delta
	if _hurt_left <= 0.0:
		_hurt_left = 1.0
		var fighters: Array = get_tree().get_nodes_in_group("br_fighters") + get_tree().get_nodes_in_group("player")
		for fighter: Node3D in fighters:
			if fighter is Enemy and (fighter as Enemy)._dead:
				continue
			if fighter is Player and (fighter as Player).health <= 0:
				continue
			if not contains(fighter.global_position):
				fighter.take_damage(DAMAGE)
