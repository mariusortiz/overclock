class_name FightPad
extends Control
## Touch controls of the fight mode: a cross on one side (eight directions:
## slide the thumb over it) and four round buttons on the other: POING, PIED,
## ARME, SUPER (lit when the meter is full). Two pads share the screen in a
## two-player game on one device: each takes the touches that start in its
## half (`half`: 0 the whole screen, 1 the left half, 2 the right half, its
## cross on the outer edge).

const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const CROSS_RADIUS := 105.0
const BUTTON_RADIUS := 50.0
const LABELS := {"punch": "POING", "kick": "PIED", "weapon": "ARME", "super": "SUPER"}

var half := 0
var accent := Color(0.16, 0.9, 1.0)
## Is the super ready (the button glows)?
var super_ready := false
## How much smaller everything is (two pads on one screen).
var scale_factor := 1.0

var _cross_finger := -1
var _direction := Vector2.ZERO
## Button name -> finger index holding it.
var _fingers := {}


func _init(screen_half := 0, color := Color(0.16, 0.9, 1.0)) -> void:
	half = screen_half
	accent = color
	scale_factor = 1.0 if half == 0 else 0.8
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func is_held(name: String) -> bool:
	match name:
		"left":
			return _direction.x < -0.4
		"right":
			return _direction.x > 0.4
		"up":
			return _direction.y < -0.5
		"down":
			return _direction.y > 0.5
	return _fingers.has(name)


func _cross_center() -> Vector2:
	var screen := size
	var inset := (CROSS_RADIUS + 60.0) * scale_factor
	# Above the super meters at the bottom.
	var lift := inset + 50.0
	if half == 2:
		return Vector2(screen.x - inset, screen.y - lift)
	return Vector2(inset, screen.y - lift)


## The four buttons, in a diamond: punch on the left, kick at the bottom,
## weapon on the right, super on top.
func _button_centers() -> Dictionary:
	var screen := size
	var gap := 1.25 * BUTTON_RADIUS * scale_factor
	var center: Vector2
	match half:
		1:
			center = Vector2(screen.x * 0.5 - 2.4 * gap, screen.y - 2.0 * gap - 80.0)
		2:
			center = Vector2(screen.x * 0.5 + 2.4 * gap, screen.y - 2.0 * gap - 80.0)
		_:
			center = Vector2(screen.x - 2.0 * gap - 50.0, screen.y - 2.0 * gap - 90.0)
	return {"punch": center + Vector2(-1.4 * gap, 0), "kick": center + Vector2(0, 1.4 * gap),
			"weapon": center + Vector2(1.4 * gap, 0), "super": center + Vector2(0, -1.4 * gap)}


func _in_half(at: Vector2) -> bool:
	match half:
		1:
			return at.x < size.x / 2.0
		2:
			return at.x >= size.x / 2.0
	return true


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		var at: Vector2 = event.position - global_position
		if event.pressed:
			if not _in_half(at):
				return
			if at.distance_to(_cross_center()) < CROSS_RADIUS * scale_factor * 1.5 and _cross_finger == -1:
				_cross_finger = event.index
				_aim(at)
				return
			for name: String in LABELS:
				if at.distance_to(_button_centers()[name]) < BUTTON_RADIUS * scale_factor * 1.25:
					_fingers[name] = event.index
					queue_redraw()
					return
		else:
			if event.index == _cross_finger:
				_cross_finger = -1
				_direction = Vector2.ZERO
				queue_redraw()
			for name: String in _fingers.keys():
				if _fingers[name] == event.index:
					_fingers.erase(name)
					queue_redraw()
	elif event is InputEventScreenDrag and event.index == _cross_finger:
		_aim(event.position - global_position)


func _aim(at: Vector2) -> void:
	var offset := (at - _cross_center()) / (CROSS_RADIUS * scale_factor)
	_direction = offset.limit_length(1.0) if offset.length() > 0.25 else Vector2.ZERO
	queue_redraw()


func _process(_delta: float) -> void:
	if super_ready:
		queue_redraw()


func _draw() -> void:
	var cross := _cross_center()
	var radius := CROSS_RADIUS * scale_factor
	draw_circle(cross, radius, Color(0, 0, 0, 0.25))
	draw_arc(cross, radius, 0, TAU, 48, Color(accent, 0.5), 3.0)
	# The four arms, the held one lit.
	for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var lit := _direction.dot(direction) > 0.4
		var tip := cross + direction * radius * 0.75
		var side := direction.orthogonal() * radius * 0.22
		draw_colored_polygon([tip + direction * radius * 0.18, tip + side, tip - side],
				Color(accent, 0.95) if lit else Color(1, 1, 1, 0.45))
	for name: String in LABELS:
		var center: Vector2 = _button_centers()[name]
		var held := _fingers.has(name)
		var color := Color(1.0, 0.8, 0.25) if name == "super" else accent
		var alpha := 0.85 if held else 0.35
		if name == "super":
			alpha = (0.6 + 0.35 * sin(Time.get_ticks_msec() / 120.0)) if super_ready else 0.15
		draw_circle(center, BUTTON_RADIUS * scale_factor, Color(color, alpha * 0.5))
		draw_arc(center, BUTTON_RADIUS * scale_factor, 0, TAU, 40, Color(color, 0.9), 3.0)
		var font_size := int(18 * scale_factor)
		var text: String = LABELS[name]
		var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(FONT, center + Vector2(-width / 2.0, font_size * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
