class_name PauseMenu
extends Control
## Pause screen; the settings come from SettingsControls. Its last button
## gives up the game (see Main._on_quit_pressed). Keeps running while the game is paused.
## Opens with the pause button, Escape, or the Android back button.

signal menu_pressed

## Set to false when the game must not be paused (game over).
var enabled := true

var _mouse_was_captured := false

@onready var _resume_button: Button = $Center/Box/Resume
@onready var _menu_button: Button = $Center/Box/Menu


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(close)
	_menu_button.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		toggle()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		# Leaving the app (a call, the home button) pauses the game.
		open()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	# Already paused means another screen (perk choice) is up.
	if not enabled or get_tree().paused:
		return
	_mouse_was_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.action_release("fire")
	Input.action_release("aim")
	get_tree().paused = true
	visible = true


func close() -> void:
	visible = false
	get_tree().paused = false
	if _mouse_was_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	menu_pressed.emit()
