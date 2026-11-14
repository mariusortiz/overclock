class_name SurvivalCreature
extends Enemy
## An enemy of the survival world. The world is too big for a navigation
## mesh: it walks straight at its goal, jumps over low steps, and hits what
## the player built when it stands in the way.
##
## "kind": "shadow" (a night creature: it burns at dawn), "wild" (an enemy of
## the game, met in its biome), "raider" (a survivor who comes by day to rob
## the player's chests, and fights back).

const JUMP_SPEED := 6.5
const PIECE_HIT := 6
const PIECE_HIT_INTERVAL := 1.0
const RAIDER_SIGHT := 16.0
const STEAL_SHARE := 0.35

## Robbed a chest: what it carries away ({item: count}), dropped on death.
signal robbed(raider: SurvivalCreature, loot: Dictionary)

var kind := "shadow"
## The raider's loot, given back when it dies.
var loot := {}

var _piece_left := 0.0
var _fleeing := false
var _flee_goal := Vector3.INF


func _ready() -> void:
	super()
	# Doors stop creatures (not the player).
	collision_mask |= SurvivalPiece.DOOR_LAYER


func _chase_direction(_delta: float, goal: Vector3) -> Vector3:
	var direction := goal - global_position
	direction.y = 0.0
	if direction.length() < 0.6:
		return Vector3.ZERO
	return direction.normalized()


func _pick_target() -> Node3D:
	if kind == "raider":
		if _fleeing or _player == null or _player.health <= 0:
			return null
		var close := global_position.distance_to(_player.global_position) <= RAIDER_SIGHT
		return _player if close else null
	return super()


func _idle_goal() -> Vector3:
	if kind != "raider":
		return Vector3.INF
	if _fleeing:
		return _flee_goal
	var best: SurvivalPiece = null
	for piece: SurvivalPiece in get_tree().get_nodes_in_group("survival_pieces"):
		if piece.type == "chest" and not piece.content.is_empty():
			if best == null or piece.global_position.distance_to(global_position) < best.global_position.distance_to(global_position):
				best = piece
	if best == null:
		_start_fleeing()
		return _flee_goal
	if best.global_position.distance_to(global_position) < 2.2:
		_rob(best)
	return best.global_position


func _rob(chest: SurvivalPiece) -> void:
	for item: String in chest.content.keys():
		var taken := ceili(int(chest.content[item]) * STEAL_SHARE)
		if taken <= 0:
			continue
		chest.content[item] = int(chest.content[item]) - taken
		if int(chest.content[item]) <= 0:
			chest.content.erase(item)
		loot[item] = int(loot.get(item, 0)) + taken
	Effects.burst(get_tree().current_scene, chest.global_position + Vector3.UP, Color(1.0, 0.85, 0.3), 20)
	robbed.emit(self, loot)
	_start_fleeing()


func _start_fleeing() -> void:
	if _fleeing:
		return
	_fleeing = true
	var away := Vector3(global_position.x, 0, global_position.z).normalized()
	if away == Vector3.ZERO:
		away = Vector3.FORWARD
	_flee_goal = global_position + away * 120.0


func _physics_process(delta: float) -> void:
	super(delta)
	if _dead:
		return
	if _fleeing and _flee_goal != Vector3.INF and global_position.distance_to(_flee_goal) < 6.0:
		# Gone with the loot.
		queue_free()
		return
	if not is_on_wall():
		return
	var blocker: Object = null
	for index in get_slide_collision_count():
		var other := get_slide_collision(index).get_collider()
		if other is SurvivalPiece or (other is Node and (other as Node).get_parent() is SurvivalPiece):
			blocker = other if other is SurvivalPiece else (other as Node).get_parent()
			break
	if blocker:
		_piece_left -= delta
		if _piece_left <= 0.0:
			_piece_left = PIECE_HIT_INTERVAL
			_model.play(&"melee", true)
			_shoot_animation_left = 0.5
			(blocker as SurvivalPiece).take_damage(PIECE_HIT)
	elif is_on_floor():
		velocity.y = JUMP_SPEED


## Dawn: the night creatures burn away.
func burn_away() -> void:
	if _dead:
		return
	set_kill_effect(&"burn", Color(1.0, 0.6, 0.2))
	take_damage(9999)
