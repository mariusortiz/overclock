class_name Logo
extends Control
## The OVERCLOCK badge, drawn by code so it stays sharp at any size: a slanted
## plate with a lightning bolt, in the game's cyan and magenta.

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const PLATE := Color(0.03, 0.07, 0.2)
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const SLANT := 0.22  # horizontal shift of the plate, as a fraction of its height


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var shift := h * SLANT
	var plate := PackedVector2Array([Vector2(shift, 0), Vector2(w, 0), Vector2(w - shift, h), Vector2(0, h)])
	draw_colored_polygon(plate, PLATE)
	plate.append(plate[0])
	draw_polyline(plate, CYAN, maxf(h * 0.045, 2.0), true)
	# Magenta stripe under the name.
	draw_colored_polygon([
		Vector2(shift * 0.35 + w * 0.08, h * 0.8), Vector2(w * 0.92 - shift * 0.8, h * 0.8),
		Vector2(w * 0.92 - shift * 0.86, h * 0.87), Vector2(shift * 0.3 + w * 0.08, h * 0.87)], MAGENTA)

	# Lightning bolt on the left.
	var bolt_origin := Vector2(shift + h * 0.2, h * 0.14)
	var s := h * 0.62
	var bolt := PackedVector2Array()
	for point: Vector2 in [Vector2(0.55, 0), Vector2(0.1, 0.56), Vector2(0.42, 0.56), Vector2(0.28, 1), Vector2(0.8, 0.4), Vector2(0.47, 0.4)]:
		bolt.append(bolt_origin + point * s)
	draw_colored_polygon(bolt, MAGENTA)

	var font_size := int(h * 0.4)
	var text_left := bolt_origin.x + s * 0.9
	var text_width := w - shift - text_left - h * 0.15
	draw_string(FONT, Vector2(text_left, h * 0.66), "OVERCLOCK", HORIZONTAL_ALIGNMENT_CENTER, text_width, font_size, Color.WHITE)
