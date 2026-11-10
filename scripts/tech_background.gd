class_name TechBackground
extends Control
## Menu backdrop drawn by code: deep blue gradient, large faint chevrons and
## thin technical markings.

const TOP := Color(0.05, 0.13, 0.4)
const BOTTOM := Color(0.02, 0.05, 0.2)
const SHAPE := Color(0.25, 0.5, 1.0, 0.07)
const LINE := Color(0.16, 0.83, 1.0, 0.28)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_polygon([Vector2.ZERO, Vector2(w, 0), Vector2(w, h), Vector2(0, h)], [TOP, TOP, BOTTOM, BOTTOM])

	# Large chevrons pointing up, like hangar markings.
	for i in 5:
		var x := w * (0.02 + 0.24 * i)
		var top := h * (0.2 + 0.08 * (i % 2))
		_chevron(Vector2(x, top), w * 0.2, h * 0.75)

	# Horizontal rules with tick marks.
	for y: float in [h * 0.12, h * 0.9]:
		draw_line(Vector2(w * 0.04, y), Vector2(w * 0.96, y), LINE, 1.0)
		for i in 24:
			var x := w * 0.04 + w * 0.92 * i / 23.0
			draw_line(Vector2(x, y - 4), Vector2(x, y + (8 if i % 4 == 0 else 4)), LINE, 1.0)

	# Corner brackets and small readout blocks.
	_bracket(Vector2(w * 0.03, h * 0.06), 1.0, 1.0)
	_bracket(Vector2(w * 0.97, h * 0.06), -1.0, 1.0)
	_bracket(Vector2(w * 0.03, h * 0.94), 1.0, -1.0)
	_bracket(Vector2(w * 0.97, h * 0.94), -1.0, -1.0)
	for i in 4:
		draw_rect(Rect2(w * 0.05, h * (0.17 + 0.035 * i), w * (0.03 + 0.012 * ((i * 7) % 4)), 6), LINE)
		draw_rect(Rect2(w * 0.89, h * (0.72 + 0.035 * i), w * (0.03 + 0.012 * ((i * 5) % 4)), 6), LINE)


func _chevron(top: Vector2, width: float, height: float) -> void:
	var thickness := width * 0.32
	draw_colored_polygon([
		top + Vector2(width * 0.5, 0), top + Vector2(width, height),
		top + Vector2(width - thickness, height), top + Vector2(width * 0.5, height * 0.3),
		top + Vector2(thickness, height), top + Vector2(0, height),
	], SHAPE)


func _bracket(corner: Vector2, x_sign: float, y_sign: float) -> void:
	draw_line(corner, corner + Vector2(36 * x_sign, 0), LINE, 2.0)
	draw_line(corner, corner + Vector2(0, 36 * y_sign), LINE, 2.0)
