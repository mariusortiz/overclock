extends Node
## Player settings, saved locally. Autoloaded as "Settings".

signal changed

const LOW_QUALITY_SCALE := 0.7

## Multiplies the look speed (mouse and touch).
var sensitivity := 1.0
var music_enabled := true
var vibration_enabled := true
## The view shakes when the player is hit or a rocket goes off.
var camera_shake := true
## Frames per second in the corner of the screen, for checking performance.
var show_fps := false
## Off: no shadows, no glow and a lower 3D resolution, for slower phones.
var high_quality := true


func _ready() -> void:
	for property: StringName in [&"sensitivity", &"music_enabled", &"vibration_enabled", &"camera_shake", &"high_quality", &"show_fps"]:
		set(property, SaveData.load_setting(property, get(property)))
	_apply()


func set_value(property: StringName, value: Variant) -> void:
	set(property, value)
	SaveData.save_setting(property, value)
	_apply()
	changed.emit()


func _apply() -> void:
	Music.stream_paused = not music_enabled
	get_tree().root.scaling_3d_scale = 1.0 if high_quality else LOW_QUALITY_SCALE
