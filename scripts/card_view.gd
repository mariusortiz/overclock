class_name CardView
extends Control
## One collectible card: its art in a frame of its rarity's color, its name
## and rarity. Legendary frames shimmer, mythic ones cycle through the
## colors. A card the player does not have is shown dark, with a "?"; a card
## can also be shown face down (a booster before it is turned).

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const BACK_COLOR := Color(0.06, 0.09, 0.25)
const ASPECT := 1.4

var card := {}
var owned := true
var face_down := false
var copies := 0

var _time := 0.0
var _art: Texture2D


func _init(shown: Dictionary = {}, is_owned := true, card_copies := 0) -> void:
	card = shown
	owned = is_owned
	copies = card_copies
	mouse_filter = Control.MOUSE_FILTER_PASS


func _ready() -> void:
	if not card.is_empty():
		_art = Cards.art(card)


func set_card(shown: Dictionary) -> void:
	card = shown
	_art = Cards.art(card)
	queue_redraw()


func _process(delta: float) -> void:
	if card.is_empty() or not owned or face_down:
		return
	if card.rarity >= Cards.Rarity.LEGENDARY:
		_time += delta
		queue_redraw()


func frame_color() -> Color:
	if card.is_empty():
		return Color.WHITE
	var color: Color = Cards.RARITY[card.rarity].color
	if card.rarity == Cards.Rarity.MYTHIC:
		return Color.from_hsv(fmod(_time * 0.25, 1.0), 0.7, 1.0)
	if card.rarity == Cards.Rarity.LEGENDARY:
		return color.lerp(Color.WHITE, 0.25 + 0.25 * sin(_time * 3.0))
	return color


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var border := maxf(size.x * 0.035, 3.0)
	if face_down:
		_draw_back(rect, border)
		return
	var color := frame_color()
	if not owned:
		color = color.darkened(0.6)
	draw_rect(rect, Color(0.03, 0.04, 0.1))
	# The art, square, at the top.
	var art_rect := Rect2(border * 2.0, border * 2.0, size.x - border * 4.0, size.x - border * 4.0)
	if _art:
		draw_texture_rect(_art, art_rect, false, Color.WHITE if owned else Color(0.08, 0.08, 0.12))
	if not owned:
		_text("?", art_rect.get_center() + Vector2(0, size.x * 0.12), size.x * 0.4, Color(1, 1, 1, 0.35))
	# Name and rarity under it.
	var name_size := size.x * 0.085
	_text(str(card.name).to_upper(), Vector2(size.x / 2.0, art_rect.end.y + name_size * 1.6), name_size, Color.WHITE if owned else Color(1, 1, 1, 0.4))
	_text(str(Cards.RARITY[card.rarity].name).to_upper(), Vector2(size.x / 2.0, art_rect.end.y + name_size * 3.1), name_size * 0.75, color)
	if copies > 1:
		_text("x%d" % copies, Vector2(size.x - border * 5.0, border * 6.0), name_size, Color.WHITE)
	draw_rect(rect.grow(-border / 2.0), color, false, border)


func _draw_back(rect: Rect2, border: float) -> void:
	draw_rect(rect, BACK_COLOR)
	draw_rect(rect.grow(-border / 2.0), Color(0.16, 0.83, 1.0), false, border)
	var center := rect.get_center()
	var s := size.x * 0.22
	# The lightning bolt of the logo.
	var bolt := PackedVector2Array()
	for point: Vector2 in [Vector2(0.15, -1), Vector2(-0.5, 0.15), Vector2(0, 0.15), Vector2(-0.25, 1), Vector2(0.5, -0.2), Vector2(0, -0.2)]:
		bolt.append(center + point * s)
	draw_colored_polygon(bolt, Color(1.0, 0.24, 0.95))


func _text(text: String, at: Vector2, font_size: float, color: Color) -> void:
	var size_px := int(maxf(font_size, 8.0))
	var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	var scale := minf(1.0, (size.x * 0.92) / maxf(width, 1.0))
	draw_set_transform(at, 0.0, Vector2.ONE * scale)
	draw_string(FONT, Vector2(-width / 2.0, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)
	draw_set_transform(Vector2.ZERO)
