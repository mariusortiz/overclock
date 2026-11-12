class_name PoseLayer
extends SkeletonModifier3D
## Turns some bones on top of the animation that is playing: the jump, the
## lean of a run and the dances are made this way, since the character models
## come with no such animations.
##
## `targets` maps a bone name to a rotation in degrees (x, y, z) expressed in
## the model's space (`space`), not in the bone's: -x swings a limb forward,
## +z raises a left limb sideways (-z a right one), y twists. The same numbers
## therefore mean the same move on every bone. `weight` (0 to 1) fades the
## whole pose in and out.

var targets := {}
var weight := 0.0
## The model's root node: its axes are those of `targets` (+X its left side,
## +Y up, +Z its front). The imported skeleton is often turned relative to it.
var space: Node3D

## Bone name -> index, or -1 when the model has no such bone.
var _indices := {}


func _process_modification_with_delta(_delta: float) -> void:
	if weight <= 0.001 or targets.is_empty():
		return
	var skeleton := get_skeleton()
	if skeleton == null:
		return
	# Parents first, so that a child is turned from where its parent ended up.
	var bones: Array[int] = []
	var angles := {}
	for bone_name: String in targets:
		var index := _index(skeleton, bone_name)
		if index != -1:
			bones.append(index)
			angles[index] = targets[bone_name]
	bones.sort()
	# Model space -> skeleton space.
	var to_skeleton := Basis()
	if space:
		to_skeleton = (space.global_basis.inverse() * skeleton.global_basis).orthonormalized()
	for index in bones:
		var degrees: Vector3 = angles[index] * weight
		var turn := Basis.from_euler(Vector3(deg_to_rad(degrees.x), deg_to_rad(degrees.y), deg_to_rad(degrees.z)))
		turn = to_skeleton.inverse() * turn * to_skeleton
		var current := skeleton.get_bone_global_pose(index).basis.orthonormalized()
		var parent := skeleton.get_bone_parent(index)
		var parent_basis := Basis()
		if parent != -1:
			parent_basis = skeleton.get_bone_global_pose(parent).basis.orthonormalized()
		var local := parent_basis.inverse() * (turn * current)
		skeleton.set_bone_pose_rotation(index, local.get_rotation_quaternion())


func _index(skeleton: Skeleton3D, bone_name: String) -> int:
	if not _indices.has(bone_name):
		_indices[bone_name] = skeleton.find_bone(bone_name)
	return _indices[bone_name]


## A pose for both sides at once: `left` holds the .L bones' angles; the .R
## bones get the mirror image (same bend, opposite twist and side raise).
static func symmetric(left: Dictionary, center := {}) -> Dictionary:
	var pose := center.duplicate()
	for bone: String in left:
		var angles: Vector3 = left[bone]
		pose[bone + ".L"] = angles
		pose[bone + ".R"] = Vector3(angles.x, -angles.y, -angles.z)
	return pose


## Blends two poses: `t` = 0 gives `from`, 1 gives `to`. Missing bones count
## as not turned.
static func blend(from: Dictionary, to: Dictionary, t: float) -> Dictionary:
	var pose := {}
	for bone: String in from:
		pose[bone] = (from[bone] as Vector3).lerp(to.get(bone, Vector3.ZERO), t)
	for bone: String in to:
		if not from.has(bone):
			pose[bone] = Vector3.ZERO.lerp(to[bone], t)
	return pose
