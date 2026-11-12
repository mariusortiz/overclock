class_name CaptureBot
extends Enemy
## A fighter of the capture mode, on either side (see Enemy.team). It fights
## the closest foe it can see; with nobody around, it heads for a zone its
## team does not hold yet, or guards one.

const ENGAGE_RANGE := 20.0
const REPLAN_TIME := 3.0
const MARKER_HEIGHT := 2.35

## The mode's zones (CaptureZone).
var zones: Array = []

var _goal := Vector3.INF
var _replan_left := 0.0


func _ready() -> void:
	super()
	# A diamond over the head in the team's color.
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = CaptureZone.ALLY_COLOR if team == &"ally" else CaptureZone.ENEMY_COLOR
	material.no_depth_test = team == &"ally"
	var diamond := PrismMesh.new()
	diamond.size = Vector3(0.28, -0.3, 0.06)
	diamond.material = material
	var marker := MeshInstance3D.new()
	marker.mesh = diamond
	marker.position.y = MARKER_HEIGHT
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(marker)


func _pick_target() -> Node3D:
	var foes: Array[Node] = []
	if team == &"ally":
		foes = get_tree().get_nodes_in_group("targets")
	else:
		foes = get_tree().get_nodes_in_group("allies")
		if _player and _player.health > 0:
			foes.append(_player)
	var best: Node3D = null
	var best_distance := ENGAGE_RANGE
	for foe: Node3D in foes:
		var distance := global_position.distance_to(foe.global_position)
		if distance < best_distance and _can_see(foe):
			best = foe
			best_distance = distance
	return best


func _idle_goal() -> Vector3:
	_replan_left -= get_physics_process_delta_time()
	if _replan_left <= 0.0 or _goal == Vector3.INF:
		_replan_left = REPLAN_TIME
		_goal = _choose_goal()
	return _goal


## The closest zone the team does not hold; if it holds them all, one of them.
func _choose_goal() -> Vector3:
	var best: CaptureZone = null
	var best_distance := INF
	for zone: CaptureZone in zones:
		if zone.holder == team:
			continue
		var distance := global_position.distance_to(zone.global_position)
		if distance < best_distance:
			best = zone
			best_distance = distance
	if best == null and not zones.is_empty():
		best = zones.pick_random()
	if best == null:
		return Vector3.INF
	# Spread out inside the zone rather than all on its center.
	var offset := Vector2.from_angle(randf() * TAU) * randf() * CaptureZone.RADIUS * 0.6
	return best.global_position + Vector3(offset.x, 0, offset.y)


func _can_see(foe: Node3D) -> bool:
	var from := global_position + Vector3.UP * EYE_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, foe.get_aim_position(), WORLD_MASK)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
