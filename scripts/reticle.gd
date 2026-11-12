class_name Reticle
extends Control
## Crosshair at the screen center, with a brief hit marker.

const COLOR := Color(1, 1, 1, 0.9)
const HIT_COLOR := Color(1, 0.24, 0.95)
const HEADSHOT_COLOR := Color(1.0, 0.9, 0.2)
const HIT_DURATION := 0.15
const KILL_COLOR := Color(1.0, 0.2, 0.2)
const KILL_DURATION := 0.35
const TARGET_COLOR := Color(1.0, 0.3, 0.3, 0.95)

var _hit_left := 0.0
var _hit_color := HIT_COLOR
var _kill_left := 0.0
## The crosshair turns red over an enemy.
var on_target := false:
	set(value):
		if value != on_target:
			on_target = value
			queue_redraw()


func _ready() -> void:
	set_process(false)
	resized.connect(queue_redraw)


func show_hit(headshot := false) -> void:
	_hit_color = HEADSHOT_COLOR if headshot else HIT_COLOR
	_hit_left = HIT_DURATION
	set_process(true)
	queue_redraw()


## A bigger red cross for a kill.
func show_kill() -> void:
	_kill_left = KILL_DURATION
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_hit_left -= delta
	_kill_left -= delta
	queue_redraw()
	if _hit_left <= 0.0 and _kill_left <= 0.0:
		set_process(false)


func _draw() -> void:
	var center := size * 0.5
	var color := TARGET_COLOR if on_target else COLOR
	draw_circle(center, 1.5, color)
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(center + dir * 6.0, center + dir * 14.0, color, 2.0)
	if _kill_left > 0.0:
		var grow := 1.0 + (KILL_DURATION - _kill_left) * 1.5
		var faded := Color(KILL_COLOR, clampf(_kill_left / KILL_DURATION * 1.5, 0.0, 1.0))
		for dir: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
			draw_line(center + dir * 10.0 * grow, center + dir * 22.0 * grow, faded, 4.0)
	if _hit_left > 0.0:
		for dir: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
			draw_line(center + dir * 7.0, center + dir * 14.0, _hit_color, 3.0)
