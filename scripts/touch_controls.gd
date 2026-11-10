class_name TouchControls
extends Control
## Touch input. Left half: floating joystick driving the move_* actions.
## Right half: drag to look. The fire button also looks while held, so the
## same thumb can shoot and aim.

signal look(relative: Vector2)

const ACCENT := Color(0, 0.9, 1)
const FIRE_RADIUS := 85.0
const FIRE_MARGIN := Vector2(70, 60)
const BUTTON_GAP := 16.0
const RELOAD_RADIUS := 52.0

@export var joystick_radius := 110.0
@export var knob_radius := 42.0
@export var dead_zone := 0.15

var _move_finger := -1
var _look_finger := -1
var _fire_finger := -1
var _reload_finger := -1
var _joy_origin := Vector2.ZERO
var _joy_vector := Vector2.ZERO

@onready var _jump_button: TouchScreenButton = $JumpButton


func _ready() -> void:
	resized.connect(_on_resized)
	_on_resized()


func _exit_tree() -> void:
	# A finger may still be down when the scene reloads.
	_set_joystick(Vector2.ZERO)
	Input.action_release("fire")
	Input.action_release("reload")


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_touch_start(event)
		else:
			_on_touch_end(event)
	elif event is InputEventScreenDrag:
		if event.index == _move_finger:
			_update_joystick(event.position)
		elif event.index == _look_finger or event.index == _fire_finger:
			look.emit(event.relative)


func _on_touch_start(event: InputEventScreenTouch) -> void:
	if _jump_rect().has_point(event.position):
		return  # handled by the TouchScreenButton itself
	if _fire_finger == -1 and event.position.distance_to(_fire_center()) <= FIRE_RADIUS:
		_fire_finger = event.index
		Input.action_press("fire")
		queue_redraw()
	elif _reload_finger == -1 and event.position.distance_to(_reload_center()) <= RELOAD_RADIUS:
		_reload_finger = event.index
		Input.action_press("reload")
		queue_redraw()
	elif event.position.x < size.x * 0.5:
		if _move_finger == -1:
			_move_finger = event.index
			_joy_origin = event.position
			_update_joystick(event.position)
	elif _look_finger == -1:
		_look_finger = event.index


func _on_touch_end(event: InputEventScreenTouch) -> void:
	if event.index == _move_finger:
		_move_finger = -1
		_set_joystick(Vector2.ZERO)
	elif event.index == _look_finger:
		_look_finger = -1
	elif event.index == _fire_finger:
		_fire_finger = -1
		Input.action_release("fire")
		queue_redraw()
	elif event.index == _reload_finger:
		_reload_finger = -1
		Input.action_release("reload")
		queue_redraw()


func _update_joystick(finger_position: Vector2) -> void:
	var v := (finger_position - _joy_origin) / joystick_radius
	_set_joystick(v.limit_length(1.0))


func _set_joystick(v: Vector2) -> void:
	_joy_vector = v
	var effective := v if v.length() > dead_zone else Vector2.ZERO
	_apply_axis("move_left", "move_right", effective.x)
	_apply_axis("move_forward", "move_back", effective.y)
	queue_redraw()


func _apply_axis(negative: StringName, positive: StringName, value: float) -> void:
	if value < 0.0:
		Input.action_press(negative, -value)
		Input.action_release(positive)
	elif value > 0.0:
		Input.action_press(positive, value)
		Input.action_release(negative)
	else:
		Input.action_release(negative)
		Input.action_release(positive)


func _draw() -> void:
	_draw_button(_fire_center(), FIRE_RADIUS, "TIR", 30, _fire_finger != -1)
	_draw_button(_reload_center(), RELOAD_RADIUS, "RECH.", 20, _reload_finger != -1)
	if _move_finger != -1:
		draw_circle(_joy_origin, joystick_radius, Color(1, 1, 1, 0.08))
		draw_arc(_joy_origin, joystick_radius, 0.0, TAU, 48, Color(ACCENT, 0.5), 3.0)
		draw_circle(_joy_origin + _joy_vector * joystick_radius, knob_radius, Color(ACCENT, 0.55))


func _draw_button(center: Vector2, radius: float, label: String, font_size: int, pressed: bool) -> void:
	draw_circle(center, radius, Color(ACCENT, 0.45 if pressed else 0.15))
	draw_arc(center, radius, 0.0, TAU, 48, Color(ACCENT, 1.0 if pressed else 0.7), 4.0)
	var text_origin := center + Vector2(-radius, font_size * 0.35)
	draw_string(ThemeDB.fallback_font, text_origin, label, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, font_size)


func _fire_center() -> Vector2:
	return size - FIRE_MARGIN - Vector2(FIRE_RADIUS, FIRE_RADIUS)


func _reload_center() -> Vector2:
	return _fire_center() + Vector2(-FIRE_RADIUS - BUTTON_GAP - RELOAD_RADIUS, 30.0)


func _jump_rect() -> Rect2:
	return Rect2(_jump_button.position, _jump_button.texture_normal.get_size())


func _on_resized() -> void:
	# Jump sits right above the fire button.
	var jump_size := _jump_button.texture_normal.get_size()
	var fire_center := _fire_center()
	_jump_button.position = Vector2(
		fire_center.x - jump_size.x * 0.5,
		fire_center.y - FIRE_RADIUS - BUTTON_GAP - jump_size.y)
	queue_redraw()
