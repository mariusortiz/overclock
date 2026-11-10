class_name Reticle
extends Control
## Crosshair at the screen center, with a brief hit marker.

const COLOR := Color(1, 1, 1, 0.9)
const HIT_COLOR := Color(1, 0.24, 0.95)
const HIT_DURATION := 0.15

var _hit_left := 0.0


func _ready() -> void:
	set_process(false)
	resized.connect(queue_redraw)


func show_hit() -> void:
	_hit_left = HIT_DURATION
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_hit_left -= delta
	if _hit_left <= 0.0:
		set_process(false)
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 1.5, COLOR)
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(center + dir * 6.0, center + dir * 14.0, COLOR, 2.0)
	if _hit_left > 0.0:
		for dir: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
			draw_line(center + dir * 7.0, center + dir * 14.0, HIT_COLOR, 3.0)
