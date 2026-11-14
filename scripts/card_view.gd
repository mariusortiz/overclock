class_name CardView
extends Control
## One collectible card, laid out like a trading card: name and power at the
## top, the art in a window, an ability box, a footer with its number, its
## rarity symbol and the game's bolt. Rare cards and up are holographic all
## over (frame, art and text): rainbow bands and glitter that move when the
## card (or the phone) tilts, stronger with the rarity. Legendary and mythic
## cards are full-art. A missing card is grey; a card can be face down (a
## booster).
##
## A card may be shown in a variant (see Cards): "chroma" (its frame and art
## run through the rainbow), "gold" (gold frame, gold-tinted art) or "signed"
## (Le Créateur's signature across the art, and its number). Cosmic cards
## have a field of stars behind their art.

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const BACK_COLOR := Color(0.06, 0.09, 0.25)
## Width / height of a trading card.
const ASPECT := 0.716
## Background tint of each series.
const SERIES_TINT := {
	"Héros": Color(0.95, 0.88, 0.55), "Ennemis": Color(0.75, 0.82, 0.7), "Boss": Color(0.9, 0.55, 0.45),
	"Vaisseaux": Color(0.6, 0.8, 0.95), "Armes": Color(0.78, 0.78, 0.85), "Mêlée": Color(0.85, 0.75, 0.65), "Skins": Color(0.8, 0.7, 0.95),
	"Arènes": Color(0.6, 0.85, 0.75), "Anime": Color(0.9, 0.65, 0.85), "Mythiques": Color(0.2, 0.15, 0.35), "Hacker": Color(0.04, 0.12, 0.06),
	"Matrice": Color(0.45, 0.85, 0.55), "Anime S2": Color(0.75, 0.6, 0.95), "Combat": Color(0.95, 0.6, 0.45), "Boutique": Color(0.95, 0.75, 0.9),
	"Noël": Color(0.95, 0.55, 0.55), "Passe S2": Color(0.55, 0.9, 0.75),
	"Nouveautés": Color(0.55, 0.9, 0.95), "Coulisses": Color(0.95, 0.85, 0.7), "Promo": Color(1.0, 0.8, 0.45),
}
## Stars drifting slowly behind a cosmic card's art.
const STARS_SHADER := """
shader_type canvas_item;
uniform vec2 rect_size = vec2(100.0);
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void fragment() {
	vec2 p = UV * rect_size / 4.0 + vec2(TIME * 0.6, 0.0);
	vec2 cell = floor(p);
	float star = step(0.97, hash(cell)) * (0.4 + 0.6 * sin(TIME * 2.0 + hash(cell + 7.0) * 40.0));
	vec3 sky = mix(vec3(0.02, 0.01, 0.1), vec3(0.18, 0.08, 0.4), UV.y + 0.2 * sin(UV.x * 3.0 + TIME * 0.2));
	COLOR = vec4(sky + vec3(star), 1.0);
}
"""
## The holographic foil, laid over the whole card: a faint rainbow wash,
## brighter rainbow bands that slide with the tilt and time, and glitter.
## `strength` 0 turns the bands off; the card's rounded corners stay clean.
const FOIL_SHADER := """
shader_type canvas_item;
uniform vec2 tilt = vec2(0.0);
uniform float strength = 0.5;
uniform float glitter = 0.0;
uniform float wash = 0.0;
uniform vec2 rect_size = vec2(100.0);
uniform float radius = 0.0;
vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void fragment() {
	vec2 p = abs(UV * rect_size - rect_size * 0.5) - (rect_size * 0.5 - vec2(radius));
	float outside = length(max(p, 0.0)) - radius;
	float phase = UV.x * 1.3 + UV.y * 0.9 + tilt.x * 0.8 + tilt.y * 0.5 + TIME * 0.06;
	vec3 rainbow = hue(fract(phase));
	float band = 0.5 + 0.5 * sin(phase * 18.0);
	float shine = smoothstep(0.75, 1.0, band) * strength;
	vec2 cell = floor(UV * rect_size / 3.0);
	float sparkle = step(0.985, hash(cell)) * (0.5 + 0.5 * sin(TIME * 5.0 + hash(cell + 3.0) * 30.0 + tilt.x * 6.0)) * glitter;
	vec3 color = mix(rainbow, vec3(1.0), sparkle);
	float alpha = clamp(wash + shine * 0.55 + sparkle, 0.0, 1.0);
	COLOR = vec4(color, outside > 0.0 ? 0.0 : alpha);
}
"""

static var _foil_shader: Shader
static var _stars_shader: Shader

var card := {}
var owned := true
var face_down := false:
	set(value):
		face_down = value
		_layout()
var copies := 0
## "", "chroma", "gold" or "signed" (see Cards).
var variant := "":
	set(value):
		variant = value
		_layout()

var _time := 0.0
var _art := TextureRect.new()
## The foil over the whole card, under the ink.
var _foil := ColorRect.new()
var _foil_material := ShaderMaterial.new()
## Texts and symbols, drawn over the art (see _draw_ink).
var _ink := Control.new()
## A cosmic card's starry background.
var _stars := ColorRect.new()
## Where the drawing helpers draw: this card, or the ink layer.
var _canvas: CanvasItem = self


func _init(shown: Dictionary = {}, is_owned := true, card_copies := 0, shown_variant := "") -> void:
	card = shown
	owned = is_owned
	copies = card_copies
	variant = shown_variant
	if _stars_shader == null:
		_stars_shader = Shader.new()
		_stars_shader.code = STARS_SHADER
	var stars_material := ShaderMaterial.new()
	stars_material.shader = _stars_shader
	_stars.material = stars_material
	_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_PASS
	if _foil_shader == null:
		_foil_shader = Shader.new()
		_foil_shader.code = FOIL_SHADER
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_foil_material.shader = _foil_shader
	_foil.color = Color.WHITE
	_foil.material = _foil_material
	_foil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink.draw.connect(_draw_ink)


func _ready() -> void:
	add_child(_stars)
	add_child(_art)
	add_child(_foil)
	add_child(_ink)
	resized.connect(_layout)
	_layout()


func set_card(shown: Dictionary) -> void:
	card = shown
	_layout()


func _rarity() -> int:
	return card.get("rarity", 0)


## Places the art and the foils for the card's rarity.
func _layout() -> void:
	if not is_inside_tree():
		return
	var show_face := not card.is_empty() and not face_down
	_art.visible = show_face
	_ink.visible = show_face
	_ink.position = Vector2.ZERO
	_ink.size = size
	_ink.queue_redraw()
	_foil.visible = false
	if not show_face:
		queue_redraw()
		return
	_art.texture = Cards.art(card)
	var full_art := _is_full_art()
	_art.position = Vector2(size.x * 0.05, size.y * 0.05) if full_art else Vector2(size.x * 0.08, size.y * 0.13)
	_art.size = Vector2(size.x * 0.9, size.y * 0.9) if full_art else Vector2(size.x * 0.84, size.y * 0.42)
	_art.self_modulate = Color.WHITE if owned else Color(0.12, 0.12, 0.16)
	if owned and variant == "gold":
		_art.self_modulate = Color(1.0, 0.88, 0.6)
	var cosmic := _rarity() == Cards.Rarity.COSMIC and owned
	_stars.visible = cosmic
	if cosmic:
		_stars.position = _art.position
		_stars.size = _art.size
		(_stars.material as ShaderMaterial).set_shader_parameter("rect_size", _stars.size)
		_art.self_modulate = Color(1, 1, 1, 0.82)
	_foil.visible = owned and (_rarity() >= Cards.Rarity.RARE or variant != "")
	_foil.position = Vector2.ZERO
	_foil.size = size
	_foil_material.set_shader_parameter("rect_size", size)
	_foil_material.set_shader_parameter("radius", float(int(size.x * 0.05)))
	_foil_material.set_shader_parameter("strength", [0.0, 0.35, 0.5, 0.6, 0.75, 0.9, 0.9][_rarity()])
	_foil_material.set_shader_parameter("wash", [0.0, 0.05, 0.08, 0.11, 0.14, 0.18, 0.12][_rarity()])
	_foil_material.set_shader_parameter("glitter", [0.0, 0.5, 0.8, 1.0, 1.0, 1.0, 1.0][_rarity()])
	if variant == "chroma":
		_foil_material.set_shader_parameter("strength", 1.0)
		_foil_material.set_shader_parameter("wash", 0.28)
		_foil_material.set_shader_parameter("glitter", 1.0)
	_foil.modulate = Color(1.0, 0.85, 0.4) if variant == "gold" else Color.WHITE
	queue_redraw()


## Legendary and mythic cards: the art fills the card, under the texts.
func _is_full_art() -> bool:
	return _rarity() >= Cards.Rarity.LEGENDARY


func _process(delta: float) -> void:
	if card.is_empty() or face_down or not owned or (_rarity() < Cards.Rarity.RARE and variant == ""):
		return
	_time += delta
	# The light moves with the tilt: the phone's, or the mouse over the card.
	var tilt := Vector2(sin(_time * 0.7), cos(_time * 0.5)) * 0.3
	var gravity := Input.get_accelerometer()
	if gravity != Vector3.ZERO:
		tilt = Vector2(gravity.x, gravity.y) / 9.8
	elif get_global_rect().has_point(get_global_mouse_position()):
		tilt = (get_local_mouse_position() / size - Vector2(0.5, 0.5)) * 2.0
	_foil_material.set_shader_parameter("tilt", tilt)
	if _rarity() >= Cards.Rarity.LEGENDARY or variant != "":
		queue_redraw()
		_ink.queue_redraw()
	if variant == "chroma":
		# The art itself runs through the colors.
		_art.self_modulate = Color.from_hsv(fmod(_time * 0.25, 1.0), 0.35, 1.0)


## The card itself: border and panel (or its back).
func _draw() -> void:
	_canvas = self
	var rect := Rect2(Vector2.ZERO, size)
	var radius := int(size.x * 0.05)
	if face_down or card.is_empty():
		_draw_back(rect, radius)
		return
	var rarity_color: Color = Cards.RARITY[_rarity()].color
	var border_color := _border_color()
	var outer := StyleBoxFlat.new()
	outer.bg_color = border_color
	outer.set_corner_radius_all(radius)
	draw_style_box(outer, rect)
	# Inner panel, tinted by the series.
	var tint: Color = SERIES_TINT.get(card.series, Color.WHITE)
	if not owned:
		tint = Color(0.25, 0.25, 0.28)
	var inner := StyleBoxFlat.new()
	inner.bg_color = tint
	inner.set_corner_radius_all(int(radius * 0.6))
	var panel := rect.grow(-size.x * 0.035)
	if not _is_full_art():
		draw_style_box(inner, panel)


## Over the art: name, power, the art's border, the ability box, the footer.
func _draw_ink() -> void:
	if face_down or card.is_empty():
		return
	_canvas = _ink
	var rarity_color: Color = Cards.RARITY[_rarity()].color
	var border_color := _border_color()
	var full_art := _is_full_art()
	var ink := Color(0.08, 0.08, 0.12) if owned and not full_art else Color.WHITE
	if not owned:
		ink = Color(0.6, 0.6, 0.65)
	var font_size := size.x * 0.075
	# Full-art: a dark band behind the header, so the name reads on the art.
	if full_art:
		_canvas.draw_rect(Rect2(size.x * 0.05, size.y * 0.05, size.x * 0.9, size.y * 0.075), Color(0, 0, 0, 0.45))
	# Header: name, power.
	_text(str(card.name).to_upper(), Vector2(size.x * 0.08, size.y * 0.1), font_size, ink, false, size.x * 0.6)
	_text("%d" % Cards.power(card), Vector2(size.x * 0.92, size.y * 0.1), font_size * 1.2, ink, true)
	# Art window border.
	if not full_art:
		_canvas.draw_rect(Rect2(_art.position, _art.size).grow(size.x * 0.012), border_color.darkened(0.2), false, size.x * 0.018)
		if not owned:
			_text("?", Rect2(_art.position, _art.size).get_center() + Vector2(-size.x * 0.06, size.x * 0.1), size.x * 0.35, Color(1, 1, 1, 0.3), false)
	# Type line, ability box.
	var y := size.y * (0.6 if not full_art else 0.62)
	if full_art:
		_canvas.draw_rect(Rect2(size.x * 0.06, y - font_size * 1.4, size.x * 0.88, size.y * 0.33), Color(0, 0, 0, 0.55))
	_text("%s · %s" % [card.series.to_upper(), str(Cards.RARITY[_rarity()].name).to_upper()], Vector2(size.x * 0.08, y), font_size * 0.62, ink.lerp(rarity_color, 0.5), false)
	var ability := Cards.ability(card)
	if ability[0] != "":
		_text(ability[0], Vector2(size.x * 0.08, y + font_size * 1.3), font_size * 0.78, ink, false, size.x * 0.84)
	_canvas.draw_multiline_string(FONT, Vector2(size.x * 0.08, y + font_size * 2.3), ability[1], HORIZONTAL_ALIGNMENT_LEFT,
			size.x * 0.84, int(maxf(font_size * 0.55, 7.0)), 4, ink)
	# Footer: number, rarity symbol, bolt.
	var foot := size.y * 0.94
	_text(Cards.number(card), Vector2(size.x * 0.08, foot), font_size * 0.55, ink, false)
	_rarity_symbol(Vector2(size.x * 0.5, foot - font_size * 0.2), size.x * 0.03, ink if owned else Color.GRAY)
	_bolt(Vector2(size.x * 0.88, foot - font_size * 0.25), size.x * 0.035)
	if copies > 1:
		_text("x%d" % copies, Vector2(size.x * 0.92, size.y * 0.2), font_size, Color.WHITE, true)
	if owned:
		_draw_variant(font_size)


## The variant's marks: a signature and its number, a GOLD band, a CHROMA band.
func _draw_variant(font_size: float) -> void:
	match variant:
		"signed":
			var art := Rect2(_art.position, _art.size)
			var points := PackedVector2Array()
			# Always the same flourish: a loop and a long tail.
			for i in 40:
				var t := i / 39.0
				points.append(art.position + art.size * Vector2(0.12 + 0.76 * t, 0.62 - 0.18 * sin(t * TAU * 1.5) * (1.0 - t * 0.5)))
			_canvas.draw_polyline(points, Color(1, 1, 1, 0.95), maxf(size.x * 0.012, 1.5), true)
			_canvas.draw_line(art.position + art.size * Vector2(0.2, 0.75), art.position + art.size * Vector2(0.85, 0.72), Color(1, 1, 1, 0.9), maxf(size.x * 0.008, 1.0), true)
			var number := Cards.signed_number(card.id)
			_text("SIGNÉE · N° %d / %d" % [number, Cards.SIGNED_RUN], art.position + art.size * Vector2(0.5, 0.92), font_size * 0.55, Color.WHITE, false, -1, true)
		"gold":
			_canvas.draw_rect(Rect2(size.x * 0.62, size.y * 0.135, size.x * 0.3, font_size * 1.1), Color(0.95, 0.75, 0.2))
			_text("OR", Vector2(size.x * 0.77, size.y * 0.135 + font_size * 0.9), font_size * 0.8, Color(0.25, 0.15, 0.0), false, -1, true)
		"chroma":
			var band := Color.from_hsv(fmod(_time * 0.3, 1.0), 0.8, 1.0)
			_canvas.draw_rect(Rect2(size.x * 0.5, size.y * 0.135, size.x * 0.42, font_size * 1.1), band)
			_text("CHROMA", Vector2(size.x * 0.71, size.y * 0.135 + font_size * 0.9), font_size * 0.7, Color.BLACK, false, -1, true)


## Gold from epic up; legendary gold shimmers, mythic runs through the rainbow.
func _border_color() -> Color:
	if not owned:
		return Color(0.35, 0.35, 0.4)
	if variant == "chroma":
		return Color.from_hsv(fmod(_time * 0.35, 1.0), 0.75, 1.0)
	if variant == "gold":
		return Color(1.0, 0.82, 0.3).lerp(Color.WHITE, 0.25 + 0.25 * sin(_time * 4.0))
	match _rarity():
		Cards.Rarity.COSMIC:
			return Color(0.35, 0.3, 1.0).lerp(Color(0.9, 0.5, 1.0), 0.5 + 0.5 * sin(_time * 1.5))
		Cards.Rarity.HACKER:
			# Neon green that flickers, like a screen.
			return Color(0.2, 1.0, 0.45).lerp(Color.WHITE, 0.4 * float(int(_time * 12.0) % 7 == 0))
		Cards.Rarity.MYTHIC:
			return Color.from_hsv(fmod(_time * 0.2, 1.0), 0.6, 1.0)
		Cards.Rarity.LEGENDARY:
			return Color(0.98, 0.85, 0.35).lerp(Color.WHITE, 0.3 + 0.3 * sin(_time * 3.0))
		Cards.Rarity.EPIC:
			return Color(0.98, 0.85, 0.35)
	return Cards.RARITY[_rarity()].color


## Circle, diamond, star, two stars, a star in a ring.
func _rarity_symbol(at: Vector2, r: float, color: Color) -> void:
	match _rarity():
		Cards.Rarity.COMMON:
			_canvas.draw_circle(at, r * 0.8, color)
		Cards.Rarity.RARE:
			_canvas.draw_colored_polygon([at + Vector2(0, -r), at + Vector2(r, 0), at + Vector2(0, r), at + Vector2(-r, 0)], color)
		Cards.Rarity.EPIC:
			_star(at, r * 1.2, color)
		Cards.Rarity.LEGENDARY:
			_star(at - Vector2(r * 1.1, 0), r, color)
			_star(at + Vector2(r * 1.1, 0), r, color)
		Cards.Rarity.COSMIC:
			# An eight-point star.
			var points := PackedVector2Array()
			for i in 16:
				var angle := -PI / 2.0 + PI * i / 8.0
				points.append(at + Vector2(cos(angle), sin(angle)) * (r * 1.6 if i % 2 == 0 else r * 0.6))
			_canvas.draw_colored_polygon(points, Color(0.6, 0.5, 1.0))
		Cards.Rarity.HACKER:
			_text("</>", at + Vector2(0, r), r * 2.6, Color(0.2, 1.0, 0.45), false, -1, true)
		_:
			_canvas.draw_arc(at, r * 1.6, 0, TAU, 24, color, r * 0.3)
			_star(at, r * 1.1, color)


func _star(at: Vector2, r: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 10:
		var angle := -PI / 2.0 + PI * i / 5.0
		points.append(at + Vector2(cos(angle), sin(angle)) * (r if i % 2 == 0 else r * 0.45))
	_canvas.draw_colored_polygon(points, color)


func _bolt(at: Vector2, s: float) -> void:
	var bolt := PackedVector2Array()
	for point: Vector2 in [Vector2(0.15, -1), Vector2(-0.5, 0.15), Vector2(0, 0.15), Vector2(-0.25, 1), Vector2(0.5, -0.2), Vector2(0, -0.2)]:
		bolt.append(at + point * s)
	_canvas.draw_colored_polygon(bolt, Color(1.0, 0.24, 0.95))


func _draw_back(rect: Rect2, radius: int) -> void:
	var back := StyleBoxFlat.new()
	back.bg_color = BACK_COLOR
	back.border_color = Color(0.16, 0.83, 1.0)
	back.set_border_width_all(int(maxf(size.x * 0.035, 3.0)))
	back.set_corner_radius_all(radius)
	draw_style_box(back, rect)
	_bolt(rect.get_center(), size.x * 0.22)
	_text("OVERCLOCK", rect.get_center() + Vector2(0, size.y * 0.25), size.x * 0.09, Color(0.16, 0.83, 1.0), false, -1, true)


## Text at `at` (its baseline's left end, or its right end with `right`, or
## its middle with `center`), shrunk to fit `max_width`.
func _text(text: String, at: Vector2, font_size: float, color: Color, right := false, max_width := -1.0, center := false) -> void:
	var size_px := int(maxf(font_size, 7.0))
	var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	var scale := 1.0 if max_width <= 0.0 else minf(1.0, max_width / maxf(width, 1.0))
	var x := -width if right else (-width / 2.0 if center else 0.0)
	_canvas.draw_set_transform(at, 0.0, Vector2.ONE * scale)
	_canvas.draw_string(FONT, Vector2(x, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)
	_canvas.draw_set_transform(Vector2.ZERO)
