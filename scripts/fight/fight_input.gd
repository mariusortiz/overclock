class_name FightInput
extends RefCounted
## Where a fighter's commands come from: the keyboard (one of two layouts), a
## gamepad, a touch pad (FightPad), or several at once. read() gives the input
## of one physics step (see Fighter): directions held, buttons pressed since
## the last step.
##
## Keys are physical (the same places on AZERTY and QWERTY):
##   player 1: W A S D (Z Q S D in AZERTY) to move, F punch, G kick, H weapon, R super;
##   player 2: the arrows, J punch, K kick, L weapon, I super (or 1 2 3 0 on the keypad).
## Gamepads: the cross or the left stick, X punch, A kick, B weapon, Y or RB super.

const KEYS := [
	{"left": [KEY_A], "right": [KEY_D], "up": [KEY_W], "down": [KEY_S],
			"punch": [KEY_F], "kick": [KEY_G], "weapon": [KEY_H], "super": [KEY_R]},
	{"left": [KEY_LEFT], "right": [KEY_RIGHT], "up": [KEY_UP], "down": [KEY_DOWN],
			"punch": [KEY_J, KEY_KP_1], "kick": [KEY_K, KEY_KP_2], "weapon": [KEY_L, KEY_KP_3], "super": [KEY_I, KEY_KP_0]},
]
const PAD_BUTTONS := {"punch": [JOY_BUTTON_X], "kick": [JOY_BUTTON_A], "weapon": [JOY_BUTTON_B],
		"super": [JOY_BUTTON_Y, JOY_BUTTON_RIGHT_SHOULDER]}
const BUTTONS := ["punch", "kick", "weapon", "super"]

## Keyboard layouts (indexes of KEYS) and gamepad devices read.
var layouts: Array[int] = []
var pads: Array[int] = []
var touch: FightPad
var _held := {}


func _init(key_layouts: Array[int], gamepads: Array[int], pad: FightPad = null) -> void:
	layouts = key_layouts
	pads = gamepads
	touch = pad


func read() -> Dictionary:
	var left := _any("left")
	var right := _any("right")
	var input := {"x": int(right) - int(left), "up": _any("up"), "down": _any("down")}
	for button: String in BUTTONS:
		var now := _any(button)
		input[button] = now and not _held.get(button, false)
		_held[button] = now
	return input


## Everything held, buttons included (sent over the network: the host finds
## the presses itself, so that a lost packet loses no press).
func held() -> Dictionary:
	var input := {"x": int(_any("right")) - int(_any("left")), "up": _any("up"), "down": _any("down")}
	for button: String in BUTTONS:
		input[button] = _any(button)
	return input


## `now` with its buttons turned into presses: held now, not `before`.
static func presses(now: Dictionary, before: Dictionary) -> Dictionary:
	var input := now.duplicate()
	for button: String in BUTTONS:
		input[button] = now.get(button, false) and not before.get(button, false)
	return input


func _any(name: String) -> bool:
	for layout in layouts:
		for key: Key in KEYS[layout][name]:
			if Input.is_physical_key_pressed(key):
				return true
	for device in pads:
		if _pad(device, name):
			return true
	return touch != null and touch.is_held(name)


func _pad(device: int, name: String) -> bool:
	var stick := Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
	match name:
		"left":
			return Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT) or stick.x < -0.5
		"right":
			return Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT) or stick.x > 0.5
		"up":
			return Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) or stick.y < -0.6
		"down":
			return Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) or stick.y > 0.6
	for button: JoyButton in PAD_BUTTONS[name]:
		if Input.is_joy_button_pressed(device, button):
			return true
	return false


## Packs an input for the network: 4 direction bits and 4 button bits.
static func pack(input: Dictionary) -> int:
	var bits := 0
	if int(input.x) < 0: bits |= 1
	if int(input.x) > 0: bits |= 2
	if input.up: bits |= 4
	if input.down: bits |= 8
	for index in BUTTONS.size():
		if input[BUTTONS[index]]:
			bits |= 16 << index
	return bits


static func unpack(bits: int) -> Dictionary:
	var input := {"x": int(bits & 2 != 0) - int(bits & 1 != 0), "up": bits & 4 != 0, "down": bits & 8 != 0}
	for index in BUTTONS.size():
		input[BUTTONS[index]] = bits & (16 << index) != 0
	return input
