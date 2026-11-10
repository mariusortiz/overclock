class_name TouchControls
extends Control
## Touch input. Left half: floating joystick driving the move_* actions.
## Right half: drag to look, plus round action buttons. A finger holding a
## button also looks when dragged, so the same thumb can shoot and aim.

signal look(relative: Vector2)

const ACCENT := Color(0, 0.9, 1)
const FIRE_RADIUS := 85.0
const FIRE_MARGIN := Vector2(70, 60)
const BUTTON_GAP := 16.0

## Round buttons. "offset" is measured from the center of the fire button.
## A "toggle" button switches its action on and off at each tap.
const BUTTONS := [
	{"action": "fire", "label": "TIR", "radius": FIRE_RADIUS, "font_size": 30, "offset": Vector2.ZERO, "toggle": false},
	{"action": "reload", "label": "RECH.", "radius": 52.0, "font_size": 20, "offset": Vector2(-153, 30), "toggle": false},
	{"action": "melee", "label": "COUP", "radius": 52.0, "font_size": 20, "offset": Vector2(-140, -95), "toggle": false},
	{"action": "aim", "label": "VISER", "radius": 52.0, "font_size": 20, "offset": Vector2(-265, -40), "toggle": true},
]

@export var joystick_radius := 110.0
@export var knob_radius := 42.0
@export var dead_zone := 0.15

var _move_finger := -1
var _look_finger := -1
## Finger index holding each button (same order as BUTTONS), -1 when free.
var _button_fingers: Array[int] = []
var _joy_origin := Vector2.ZERO
var _joy_vector := Vector2.ZERO

@onready var _jump_button: TouchScreenButton = $JumpButton


func _ready() -> void:
	_button_fingers.resize(BUTTONS.size())
	_button_fingers.fill(-1)
	resized.connect(_on_resized)
	_on_resized()


func _exit_tree() -> void:
	_release_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_release_all()


## Fingers may still be down when the scene reloads or the game pauses.
func _release_all() -> void:
	_move_finger = -1
	_look_finger = -1
	_button_fingers.fill(-1)
	_set_joystick(Vector2.ZERO)
	for button: Dictionary in BUTTONS:
		Input.action_release(button.action)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_touch_start(event)
		else:
			_on_touch_end(event)
	elif event is InputEventScreenDrag:
		if event.index == _move_finger:
			_update_joystick(event.position)
		elif event.index == _look_finger or event.index in _button_fingers:
			look.emit(event.relative)


func _on_touch_start(event: InputEventScreenTouch) -> void:
	if _jump_rect().has_point(event.position):
		return  # handled by the TouchScreenButton itself
	var button_index := _button_at(event.position)
	if button_index != -1:
		_press_button(button_index, event.index)
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
	else:
		var button_index := _button_fingers.find(event.index)
		if button_index != -1:
			_button_fingers[button_index] = -1
			if not BUTTONS[button_index].toggle:
				Input.action_release(BUTTONS[button_index].action)
			queue_redraw()


## Index of the free button under `point`, or -1.
func _button_at(point: Vector2) -> int:
	for i in BUTTONS.size():
		if _button_fingers[i] == -1 and point.distance_to(_button_center(i)) <= BUTTONS[i].radius:
			return i
	return -1


func _press_button(index: int, finger: int) -> void:
	var action: String = BUTTONS[index].action
	_button_fingers[index] = finger
	if BUTTONS[index].toggle and Input.is_action_pressed(action):
		Input.action_release(action)
	else:
		Input.action_press(action)
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
	for i in BUTTONS.size():
		var button: Dictionary = BUTTONS[i]
		var active: bool = Input.is_action_pressed(button.action) if button.toggle else _button_fingers[i] != -1
		_draw_button(_button_center(i), button.radius, button.label, button.font_size, active)
	if _move_finger != -1:
		draw_circle(_joy_origin, joystick_radius, Color(1, 1, 1, 0.08))
		draw_arc(_joy_origin, joystick_radius, 0.0, TAU, 48, Color(ACCENT, 0.5), 3.0)
		draw_circle(_joy_origin + _joy_vector * joystick_radius, knob_radius, Color(ACCENT, 0.55))


func _draw_button(center: Vector2, radius: float, label: String, font_size: int, active: bool) -> void:
	draw_circle(center, radius, Color(ACCENT, 0.45 if active else 0.15))
	draw_arc(center, radius, 0.0, TAU, 48, Color(ACCENT, 1.0 if active else 0.7), 4.0)
	var text_origin := center + Vector2(-radius, font_size * 0.35)
	draw_string(ThemeDB.fallback_font, text_origin, label, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, font_size)


func _fire_center() -> Vector2:
	return size - FIRE_MARGIN - Vector2(FIRE_RADIUS, FIRE_RADIUS)


func _button_center(index: int) -> Vector2:
	return _fire_center() + BUTTONS[index].offset


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
