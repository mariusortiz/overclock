class_name RaidAlly
extends CaptureBot
## A bot fighting on the player's side in a solo raid: it keeps near the
## player and fires at the nearest enemy (the cores first, as they matter).

const FOLLOW_DISTANCE := 5.0

## Where it stands next to the player.
var side := 1.0


func _pick_target() -> Node3D:
	var cores := get_tree().get_nodes_in_group("raid_cores").filter(func(core: Node) -> bool:
		return not core._dead and _can_see(core))
	if not cores.is_empty():
		cores.sort_custom(func(a: Node3D, b: Node3D) -> bool:
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
		return cores[0]
	return super()


func _idle_goal() -> Vector3:
	if _player == null:
		return Vector3.INF
	var goal := _player.global_position + _player.global_basis.x * side * FOLLOW_DISTANCE
	return Vector3.INF if global_position.distance_to(goal) < 2.0 else goal
