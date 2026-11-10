class_name TouchControls
extends Control
## Touch input: a floating joystick on the left half of the screen drives the
## move_* actions, and dragging on the right half emits `look`.

signal look(relative: Vector2)

const JUMP_MARGIN := Vector2(48, 48)

@export var joystick_radius := 110.0
@export var knob_radius := 42.0
@export var dead_zone := 0.15

var _move_finger := -1
var _look_finger := -1
var _joy_origin := Vector2.ZERO
var _joy_vector := Vector2.ZERO

@onready var _jump_button: TouchScreenButton = $JumpButton


func _ready() -> void:
	resized.connect(_place_jump_button)
	_place_jump_button()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_touch_start(event)
		else:
			_on_touch_end(event)
	elif event is InputEventScreenDrag:
		if event.index == _move_finger:
			_update_joystick(event.position)
		elif event.index == _look_finger:
			look.emit(event.relative)


func _on_touch_start(event: InputEventScreenTouch) -> void:
	if _jump_rect().has_point(event.position):
		return  # handled by the TouchScreenButton itself
	if event.position.x < size.x * 0.5:
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
	if _move_finger == -1:
		return
	draw_circle(_joy_origin, joystick_radius, Color(1, 1, 1, 0.08))
	draw_arc(_joy_origin, joystick_radius, 0.0, TAU, 48, Color(0, 0.9, 1, 0.5), 3.0)
	draw_circle(_joy_origin + _joy_vector * joystick_radius, knob_radius, Color(0, 0.9, 1, 0.55))


func _jump_rect() -> Rect2:
	return Rect2(_jump_button.position, _jump_button.texture_normal.get_size())


func _place_jump_button() -> void:
	_jump_button.position = size - _jump_button.texture_normal.get_size() - JUMP_MARGIN
