class_name DamageMarks
extends Control
## Red arcs around the crosshair, each pointing toward where a hit came from,
## fading out in a second. They turn with the camera while they last.

const LIFETIME := 1.0
const RADIUS := 170.0
const SPREAD := 0.45  # radians each side
const COLOR := Color(1.0, 0.15, 0.1)

## [world position, seconds left]
var _marks: Array[Array] = []


func add(from: Vector3) -> void:
	_marks.append([from, LIFETIME])
	set_process(true)


func _process(delta: float) -> void:
	for mark in _marks:
		mark[1] -= delta
	_marks = _marks.filter(func(mark: Array) -> bool: return mark[1] > 0.0)
	queue_redraw()
	if _marks.is_empty():
		set_process(false)


func _draw() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var center := size / 2.0
	for mark in _marks:
		# Where the hit came from, seen from above in the camera's frame: 0 is
		# straight ahead (top of the screen).
		var local := camera.global_basis.inverse() * ((mark[0] as Vector3) - camera.global_position)
		var angle := atan2(local.x, -local.z) - PI / 2.0
		var alpha: float = mark[1] / LIFETIME
		draw_arc(center, RADIUS, angle - SPREAD, angle + SPREAD, 24, Color(COLOR, alpha * 0.9), 10.0)
