class_name CharacterModel
extends Node3D
## Wrapper around an imported animated model (Quaternius packs). It scales
## the model to a target height, turns it to face -Z, rests it on the floor,
## and plays its animations through generic action names.

## Generic action -> possible animation names, by order of preference. An
## animation matches when its name ends with one of them ("Armature|Walk",
## "Dragon_Attack"...).
const ACTIONS := {
	&"idle": ["Idle", "Flying"],
	&"walk": ["Walk", "Running", "Flying"],
	&"shoot": ["Shoot_OneHanded", "Shoot", "Attack"],
	# Same animation as "shoot", frozen on its first frame: arm stretched out.
	&"aim": ["Shoot_OneHanded"],
	&"melee": ["Punch", "Attack2", "Attack"],
	&"die": ["Defeat", "Death"],
	&"victory": ["Victory"],
	&"jump": ["Jump"],
}
const LOOPING: Array[StringName] = [&"idle", &"walk"]

## Height in meters once fitted.
var target_height := 1.75
## Distance kept above the floor (flying creatures).
var hover_height := 0.0

var _animation_player: AnimationPlayer
var _animations := {}  # action -> animation name
var _current_action := &""
var _skeleton: Skeleton3D


func _ready() -> void:
	_animation_player = find_child("AnimationPlayer", true, false)
	_skeleton = find_child("Skeleton3D", true, false)
	for action: StringName in ACTIONS:
		for candidate: String in ACTIONS[action]:
			var animation_name := _find_animation(candidate)
			if animation_name != &"":
				_animations[action] = animation_name
				break
	for action in LOOPING:
		if _animations.has(action):
			_animation_player.get_animation(_animations[action]).loop_mode = Animation.LOOP_LINEAR
	_fit()


## Plays an action unless it is already the current one. `restart` replays it
## from the start (one-shot actions such as a shot).
func play(action: StringName, restart := false, speed := 1.0) -> void:
	if not _animations.has(action):
		return
	if restart:
		_animation_player.stop()
	elif _current_action == action:
		return
	_current_action = action
	if action == &"aim":
		_animation_player.play(_animations[action], 0.0, 0.0)
	else:
		_animation_player.play(_animations[action], 0.15, speed)


## Holds one frame of an action, `seconds` into its animation.
func freeze(action: StringName, seconds: float) -> void:
	if not _animations.has(action):
		return
	_current_action = &""
	_animation_player.play(_animations[action], 0.0)
	_animation_player.seek(seconds, true)
	_animation_player.pause()


## Moves `item` into a hand ("R" or "L"). Returns false if the model has no
## such hand. With `along_arm`, the item's +Y axis follows the forearm, so a
## blade or a handle moves with the arm; otherwise the item keeps its own
## orientation (a gun that keeps pointing where its owner aims). `reversed`
## points the item back toward the elbow: a weapon carried at rest, tip up.
func place_in_hand(item: Node3D, side: String, along_arm: bool, reversed := false) -> bool:
	var fist := _bone_position("Fist." + side)
	var elbow := _bone_position("LowerArm." + side)
	if fist == Vector3.INF or elbow == Vector3.INF:
		return false
	item.global_position = fist
	if along_arm:
		var along := fist.direction_to(elbow) if reversed else elbow.direction_to(fist)
		var back := global_basis.x.normalized().cross(along)
		# Skip the rare frame where the arm points exactly sideways.
		if back.length() > 0.01:
			back = back.normalized()
			item.global_basis = Basis(along.cross(back), along, back)
	return true


## World position of a bone in its current pose, or Vector3.INF if missing.
func _bone_position(bone_name: String) -> Vector3:
	if _skeleton == null:
		return Vector3.INF
	var index := _skeleton.find_bone(bone_name)
	if index == -1:
		return Vector3.INF
	return _skeleton.global_transform * _skeleton.get_bone_global_pose(index).origin


func _find_animation(suffix: String) -> StringName:
	for animation_name in _animation_player.get_animation_list():
		if animation_name == suffix or animation_name.ends_with("|" + suffix) or animation_name.ends_with("_" + suffix):
			return animation_name
	return &""


## Measures the skeleton's rest pose to scale, orient and ground the model.
func _fit() -> void:
	var skeleton := _skeleton
	if skeleton == null:
		return
	var to_model := global_transform.affine_inverse() * skeleton.global_transform
	var low := INF
	var high := -INF
	var left_side_x := 0.0
	for i in skeleton.get_bone_count():
		var point := to_model * skeleton.get_bone_global_rest(i).origin
		low = minf(low, point.y)
		high = maxf(high, point.y)
		var bone_name := skeleton.get_bone_name(i)
		if left_side_x == 0.0 and (bone_name.ends_with(".L") or bone_name.begins_with("L.")):
			left_side_x = point.x
	if high <= low:
		return

	scale *= target_height / (high - low)
	position.y = hover_height - low * scale.y
	# A model whose left side is at +X faces +Z: turn it around.
	if left_side_x > 0.0:
		rotate_y(PI)
