class_name BrBot
extends CaptureBot
## A fighter of the battle royale: everyone for themselves. It fights the
## closest foe it can see (another bot or the player); with nobody around, it
## walks to a point inside the safe zone.

const REPLAN := 6.0
## Closer than the capture bots: the island is wide open.
const SIGHT := 15.0
## The first seconds, everyone lands and looks for a weapon: no fighting.
const CALM_TIME := 25.0

## The battle royale's zone (StormZone).
var storm: StormZone

var _wander := Vector3.INF
var _wander_left := 0.0
var _calm_left := CALM_TIME


func _ready() -> void:
	free_for_all = true
	super()
	add_to_group("br_fighters")


func _pick_target() -> Node3D:
	_calm_left -= get_physics_process_delta_time()
	if _calm_left > 0.0:
		return null
	var best: Node3D = null
	var best_distance := SIGHT
	var foes: Array = get_tree().get_nodes_in_group("br_fighters")
	if _player and _player.health > 0:
		foes.append(_player)
	for foe: Node3D in foes:
		if foe == self or (foe is Enemy and (foe as Enemy)._dead):
			continue
		var distance := global_position.distance_to(foe.global_position)
		if distance < best_distance and _can_see(foe):
			best = foe
			best_distance = distance
	return best


func _idle_goal() -> Vector3:
	_wander_left -= get_physics_process_delta_time()
	var outside := storm != null and not storm.contains(global_position)
	if _wander_left <= 0.0 or _wander == Vector3.INF or (outside and not storm.contains(_wander)):
		_wander_left = REPLAN
		_wander = _next_spot(outside)
	return _wander


## Somewhere near, inside the zone; deeper inside when caught outside.
func _next_spot(outside: bool) -> Vector3:
	if storm == null:
		return global_position
	if outside:
		return storm.random_point(0.5)
	for attempt in 8:
		var offset := Vector2.from_angle(randf() * TAU) * randf_range(6.0, 16.0)
		var spot := global_position + Vector3(offset.x, 0, offset.y)
		if storm.contains(spot):
			return spot
	return storm.random_point(0.6)
