class_name FightHud
extends Control
## What is drawn over a fight: the two health bars (the damage just taken
## fades out in white), the names and the rounds won, the clock, the super
## meters (they flash when full), and big words in the middle (ROUND 1,
## COMBAT !, K.O.) with a smaller line under them.

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const GOLD := Color(1.0, 0.8, 0.25)
const BAR_HEIGHT := 30.0

var fighters: Array[Fighter] = []
var clock := 99.0
var rounds_to_win := 2
var _trail := [1.0, 1.0]
var _big := Label.new()
var _small := Label.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for label: Label in [_big, _small]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Across the whole width, centered there.
		label.anchor_right = 1.0
		label.anchor_top = 0.5
		label.anchor_bottom = 0.5
		label.add_theme_font_override("font", FONT)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.modulate.a = 0.0
		add_child(label)
	_big.add_theme_font_size_override("font_size", 96)
	_big.add_theme_constant_override("outline_size", 18)
	_big.add_theme_color_override("font_color", GOLD)
	_big.offset_top = -150
	_big.offset_bottom = -40
	_small.add_theme_font_size_override("font_size", 30)
	_small.add_theme_constant_override("outline_size", 10)
	_small.offset_top = -20
	_small.offset_bottom = 30


## Big words in the middle for `seconds`, with an optional line under them.
func announce(text: String, seconds: float, line := "", color := GOLD) -> void:
	_big.text = text
	_big.add_theme_color_override("font_color", color)
	_small.text = line
	for label: Label in [_big, _small]:
		var tween := label.create_tween()
		tween.tween_property(label, "modulate:a", 1.0, 0.12)
		tween.tween_interval(seconds)
		tween.tween_property(label, "modulate:a", 0.0, 0.25)
	_big.pivot_offset = _big.size / 2.0
	_big.create_tween().tween_property(_big, "scale", Vector2.ONE, 0.25).from(Vector2.ONE * 1.8) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	for index in fighters.size():
		var share := fighters[index].health / fighters[index].max_health
		_trail[index] = maxf(share, move_toward(_trail[index], share, 0.35 * delta))
	queue_redraw()


func _draw() -> void:
	if fighters.size() < 2:
		return
	var width := size.x
	var bar_width := minf(width * 0.38, 520.0)
	var top := 22.0
	for index in 2:
		var fighter := fighters[index]
		var left := 24.0 if index == 0 else width - 24.0 - bar_width
		var share := fighter.health / fighter.max_health
		var trail: float = _trail[index]
		draw_rect(Rect2(left - 3, top - 3, bar_width + 6, BAR_HEIGHT + 6), Color(0, 0, 0, 0.6))
		# Bars empty toward the middle: player 1's from the right, 2's from the left.
		var full := Rect2(left, top, bar_width, BAR_HEIGHT)
		draw_rect(full, Color(0.35, 0.05, 0.08))
		draw_rect(_part(full, trail, index), Color(1, 1, 1, 0.85))
		var color := Color(1.0, 0.85, 0.2).lerp(Color(0.2, 1.0, 0.45), share) if share > 0.25 else Color(1.0, 0.25, 0.2)
		draw_rect(_part(full, share, index), color)
		# Name and rounds won.
		var name := str(fighter.hero.name).to_upper()
		var name_x := left if index == 0 else left + bar_width - _text_width(name, 24)
		_text(name, Vector2(name_x, top + BAR_HEIGHT + 30), 24, fighter.color)
		for round_index in rounds_to_win:
			var pip_x := left + bar_width - 14 - 26 * round_index if index == 0 else left + 14 + 26 * round_index
			var won := round_index < fighter.rounds_won
			draw_circle(Vector2(pip_x, top + BAR_HEIGHT + 20), 9, GOLD if won else Color(1, 1, 1, 0.25))
		# Super meter, at the bottom corner.
		var meter_width := minf(width * 0.26, 340.0)
		var meter_left := 24.0 if index == 0 else width - 24.0 - meter_width
		var meter_top := size.y - 40.0
		var meter := Rect2(meter_left, meter_top, meter_width, 14)
		draw_rect(meter.grow(3), Color(0, 0, 0, 0.6))
		var filled := fighter.meter / Fighter.METER_MAX
		var ready := filled >= 1.0
		var meter_color := GOLD if not ready else Color(1, 1, 1).lerp(GOLD, 0.5 + 0.5 * sin(Time.get_ticks_msec() / 90.0))
		draw_rect(_part(meter, filled, 1 - index), meter_color)
		var label := "SUPER PRÊT !" if ready else "SUPER"
		var label_x := meter_left if index == 0 else meter_left + meter_width - _text_width(label, 18)
		_text(label, Vector2(label_x, meter_top - 8), 18, GOLD if ready else Color(1, 1, 1, 0.7))
	# The clock.
	var seconds := str(ceili(maxf(clock, 0.0)))
	_text(seconds, Vector2(width / 2.0 - _text_width(seconds, 52) / 2.0, top + 46), 52, Color.WHITE)


## The part of `rect` worth `share`, emptying toward the middle.
func _part(rect: Rect2, share: float, index: int) -> Rect2:
	var part_width := rect.size.x * clampf(share, 0.0, 1.0)
	if index == 0:
		return Rect2(rect.position.x + rect.size.x - part_width, rect.position.y, part_width, rect.size.y)
	return Rect2(rect.position.x, rect.position.y, part_width, rect.size.y)


func _text(text: String, at: Vector2, font_size: int, color: Color) -> void:
	draw_string_outline(FONT, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 6, Color.BLACK)
	draw_string(FONT, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _text_width(text: String, font_size: int) -> float:
	return FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
