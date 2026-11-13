class_name BoosterPack
extends Control
## A sealed booster, torn open by sliding a finger along the dotted line near
## its top (a tap tears it too). The strip above the line lifts as the tear
## runs, then flies off in a shower of sparks; `opened` is emitted then, and
## the pack drops away. Foil wrapper: rainbow bands that move with time.

signal opened

## Where the tear line runs, from the top, as a share of the height.
const TEAR_LINE := 0.17
## Share of the width a slide must cover to tear the pack.
const TEAR_NEEDED := 0.55
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
## Foil over whatever the pack draws: bands of rainbow light sliding across.
const SHADER := """
shader_type canvas_item;
uniform vec2 pack_size = vec2(240.0, 340.0);
varying vec2 local;
vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}
void vertex() {
	local = VERTEX;
}
void fragment() {
	vec2 uv = local / pack_size;
	float phase = uv.x * 1.2 + uv.y * 0.8 + TIME * 0.12;
	float band = smoothstep(0.7, 1.0, 0.5 + 0.5 * sin(phase * 14.0));
	COLOR.rgb += hue(fract(phase)) * band * 0.35;
}
"""

var kind := "standard"
## How far the tear has run, 0 to 1.
var _progress := 0.0
var _torn := false
var _press_x := -1.0
var _moved := false
var _strip := Control.new()
var _body := Control.new()
var _material := ShaderMaterial.new()
## The jagged tear line, shared by the strip and the body: x from 0 to 1, y in pixels.
var _teeth := PackedVector2Array()


func _init(booster_kind := "standard") -> void:
	kind = booster_kind
	custom_minimum_size = Vector2(240, 340)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shader := Shader.new()
	shader.code = SHADER
	_material.shader = shader
	for part: Control in [_body, _strip]:
		part.mouse_filter = Control.MOUSE_FILTER_IGNORE
		part.material = _material
	_body.draw.connect(_draw_body)
	_strip.draw.connect(_draw_strip)
	var random := RandomNumberGenerator.new()
	random.seed = 7
	for i in 25:
		_teeth.append(Vector2(i / 24.0, random.randf_range(-4.0, 4.0)))


func _ready() -> void:
	add_child(_body)
	add_child(_strip)
	resized.connect(_fit)
	_fit()


func _fit() -> void:
	for part: Control in [_body, _strip]:
		part.position = Vector2.ZERO
		part.size = size
	_strip.pivot_offset = Vector2(size.x, size.y * TEAR_LINE)
	_material.set_shader_parameter("pack_size", size)


func _color() -> Color:
	match kind:
		"rare":
			return Color(0.55, 0.38, 0.05)
		"legend":
			return Color(0.4, 0.05, 0.42)
	return Color(0.07, 0.12, 0.38)


func _accent() -> Color:
	match kind:
		"rare":
			return GOLD
		"legend":
			return MAGENTA
	return CYAN


# --- Tearing ------------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if _torn:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_x = event.position.x
			_moved = false
		else:
			_press_x = -1.0
			# A slide far enough, or a simple tap, tears it; a short slide springs back.
			if _progress >= TEAR_NEEDED or not _moved:
				_tear()
			else:
				_set_progress(0.0)
	elif event is InputEventMouseMotion and _press_x >= 0.0:
		var run: float = (event.position.x - _press_x) / (size.x * 0.8)
		if absf(run) > 0.03:
			_moved = true
		_set_progress(maxf(_progress, clampf(absf(run), 0.0, 1.0)))
		if _progress >= 1.0:
			_tear()


func _set_progress(value: float) -> void:
	_progress = value
	# The strip lifts from the left as the tear runs to the right.
	_strip.rotation = -0.22 * _progress
	_body.queue_redraw()
	_strip.queue_redraw()


## The tear completes: the strip flies off, sparks along the line, the pack
## drops away.
func _tear() -> void:
	if _torn:
		return
	_torn = true
	var tween := create_tween()
	tween.tween_method(_set_progress, _progress, 1.0, 0.12 * (1.0 - _progress) + 0.01)
	tween.tween_callback(_burst)
	tween.set_parallel(true)
	tween.tween_property(_strip, "position", Vector2(size.x * 0.25, -size.y * 0.45), 0.45).set_ease(Tween.EASE_OUT)
	tween.tween_property(_strip, "rotation", -0.9, 0.45)
	tween.tween_property(_strip, "modulate:a", 0.0, 0.45)
	tween.set_parallel(false)
	tween.tween_callback(opened.emit)
	tween.tween_property(_body, "position:y", size.y * 0.6, 0.35).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_body, "modulate:a", 0.0, 0.35)
	if Settings.vibration_enabled:
		Input.vibrate_handheld(40)


func _burst() -> void:
	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.explosiveness = 0.85
	sparks.amount = 40 if kind == "standard" else 70
	sparks.lifetime = 0.8
	sparks.position = Vector2(size.x / 2.0, size.y * TEAR_LINE)
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparks.emission_rect_extents = Vector2(size.x / 2.0, 3.0)
	sparks.direction = Vector2(0, -1)
	sparks.spread = 70.0
	sparks.gravity = Vector2(0, 500)
	sparks.initial_velocity_min = 120.0
	sparks.initial_velocity_max = 320.0
	sparks.scale_amount_min = 2.0
	sparks.scale_amount_max = 5.0
	sparks.color = _accent()
	add_child(sparks)
	sparks.emitting = true


# --- Drawing ------------------------------------------------------------------

## The tear line in pixels, from left to right.
func _tear_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for tooth in _teeth:
		points.append(Vector2(tooth.x * size.x, size.y * TEAR_LINE + tooth.y))
	return points


## Crimped edge: a band of small teeth, at `y`, pointing up (-1) or down (1).
func _crimp(canvas: CanvasItem, y: float, direction: float) -> void:
	var band := PackedVector2Array([Vector2(0, y)])
	var count := 24
	for i in count + 1:
		var x := size.x * i / count
		band.append(Vector2(x, y + direction * (12.0 if i % 2 == 0 else 6.0)))
	band.append(Vector2(size.x, y))
	canvas.draw_colored_polygon(band, _color().lightened(0.35))


func _draw_body() -> void:
	var line := _tear_points()
	var outline := PackedVector2Array()
	outline.append_array(line)
	outline.append(Vector2(size.x, size.y - 12.0))
	outline.append(Vector2(0, size.y - 12.0))
	_body.draw_colored_polygon(outline, _color())
	_crimp(_body, size.y - 12.0, 1.0)
	# Side seams.
	_body.draw_line(Vector2(6, line[0].y), Vector2(6, size.y - 12), _color().lightened(0.2), 2.0)
	_body.draw_line(Vector2(size.x - 6, line[-1].y), Vector2(size.x - 6, size.y - 12), _color().lightened(0.2), 2.0)
	# The bolt, the name, the content.
	var center := Vector2(size.x / 2.0, size.y * 0.5)
	var bolt := PackedVector2Array()
	for point: Vector2 in [Vector2(0.15, -1), Vector2(-0.5, 0.15), Vector2(0, 0.15), Vector2(-0.25, 1), Vector2(0.5, -0.2), Vector2(0, -0.2)]:
		bolt.append(center + point * size.x * 0.22)
	_body.draw_colored_polygon(bolt, MAGENTA)
	_centered(_body, "OVERCLOCK", Vector2(size.x / 2.0, size.y * 0.3), size.x * 0.11, Color.WHITE)
	_centered(_body, {"rare": "BOOSTER RARE", "legend": "LÉGENDAIRE"}.get(kind, "BOOSTER"), Vector2(size.x / 2.0, size.y * 0.78), size.x * 0.085, _accent())
	_centered(_body, "%d CARTES" % Cards.cards_in(kind), Vector2(size.x / 2.0, size.y * 0.86), size.x * 0.06, Color(1, 1, 1, 0.8))
	# The hint arrow, until the tear starts.
	if _progress < 1.0:
		if _progress == 0.0 and not _torn:
			var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)
			var tip := Vector2(size.x * 0.5 + pulse * 20.0, size.y * TEAR_LINE + 18.0)
			_body.draw_colored_polygon([tip, tip + Vector2(-12, -7), tip + Vector2(-12, 7)], Color(1, 1, 1, 0.9))
			_body.draw_line(tip - Vector2(40, 0), tip - Vector2(12, 0), Color(1, 1, 1, 0.9), 3.0)


func _draw_strip() -> void:
	var line := _tear_points()
	var outline := PackedVector2Array([Vector2(0, 12.0), Vector2(size.x, 12.0)])
	for i in range(line.size() - 1, -1, -1):
		outline.append(line[i])
	_strip.draw_colored_polygon(outline, _color().lightened(0.08))
	_crimp(_strip, 12.0, -1.0)
	# The dotted line, along what is not torn yet.
	var x := size.x * _progress
	var y := size.y * TEAR_LINE - 7.0
	while x < size.x - 8.0:
		_strip.draw_line(Vector2(x, y), Vector2(x + 6.0, y), Color(1, 1, 1, 0.85), 2.0)
		x += 12.0


func _process(_delta: float) -> void:
	if not _torn and _progress == 0.0:
		_body.queue_redraw()


func _centered(canvas: CanvasItem, text: String, at: Vector2, font_size: float, color: Color) -> void:
	var size_px := int(maxf(font_size, 8.0))
	var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	canvas.draw_string(FONT, at - Vector2(width / 2.0, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)
