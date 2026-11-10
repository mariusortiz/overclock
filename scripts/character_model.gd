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
	&"shoot": ["Shoot_OneHanded", "Attack"],
	# Same animation as "shoot", frozen on its first frame: arm stretched out.
	&"aim": ["Shoot_OneHanded"],
	&"melee": ["Punch", "Attack2", "Attack"],
	&"die": ["Defeat", "Death"],
}
const LOOPING: Array[StringName] = [&"idle", &"walk"]

## Height in meters once fitted.
var target_height := 1.75
## Distance kept above the floor (flying creatures).
var hover_height := 0.0

var _animation_player: AnimationPlayer
var _animations := {}  # action -> animation name
var _current_action := &""


func _ready() -> void:
	_animation_player = find_child("AnimationPlayer", true, false)
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


## Returns a node that follows a bone (for example "Fist.R"), or null if the
## model has no such bone.
func get_attachment(bone_name: String) -> Node3D:
	var skeleton: Skeleton3D = find_child("Skeleton3D", true, false)
	if skeleton == null or skeleton.find_bone(bone_name) == -1:
		return null
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = bone_name
	skeleton.add_child(attachment)
	return attachment


func _find_animation(suffix: String) -> StringName:
	for animation_name in _animation_player.get_animation_list():
		if animation_name == suffix or animation_name.ends_with("|" + suffix) or animation_name.ends_with("_" + suffix):
			return animation_name
	return &""


## Measures the skeleton's rest pose to scale, orient and ground the model.
func _fit() -> void:
	var skeleton: Skeleton3D = find_child("Skeleton3D", true, false)
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
