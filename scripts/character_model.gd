class_name CharacterModel
extends Node3D
## Wrapper around an imported Kenney "Mini Characters" model: plays its
## animations by name. The models face +Z, so the node is rotated 180° in scenes.

const LOOPING: Array[StringName] = [&"idle", &"walk", &"sprint", &"fall", &"holding-right"]

var _animation_player: AnimationPlayer


func _ready() -> void:
	_animation_player = find_child("AnimationPlayer", true, false)
	for animation_name in LOOPING:
		if _animation_player.has_animation(animation_name):
			_animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR


## Plays an animation unless it is already the current one. `restart` replays
## it from the start (one-shot actions such as a shot).
func play(animation_name: StringName, restart := false) -> void:
	if not _animation_player.has_animation(animation_name):
		return
	if restart:
		_animation_player.stop()
	elif _animation_player.assigned_animation == animation_name:
		return
	_animation_player.play(animation_name, 0.15)
