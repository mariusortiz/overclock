class_name PauseMenu
extends Control
## Pause screen with the settings. Keeps running while the game is paused.
## Opens with the pause button, Escape, or the Android back button.

signal menu_pressed

## Set to false when the game must not be paused (game over).
var enabled := true

var _mouse_was_captured := false

@onready var _resume_button: Button = $Center/Box/Resume
@onready var _menu_button: Button = $Center/Box/Menu
@onready var _sensitivity: HSlider = $Center/Box/SensitivityRow/Slider
@onready var _music: CheckButton = $Center/Box/Music
@onready var _vibration: CheckButton = $Center/Box/Vibration
@onready var _quality: CheckButton = $Center/Box/Quality


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(close)
	_menu_button.pressed.connect(_on_menu_pressed)

	_sensitivity.value = Settings.sensitivity
	_music.button_pressed = Settings.music_enabled
	_vibration.button_pressed = Settings.vibration_enabled
	_quality.button_pressed = Settings.high_quality
	_sensitivity.value_changed.connect(_on_sensitivity_changed)
	_music.toggled.connect(func(on: bool) -> void: Settings.set_value(&"music_enabled", on))
	_vibration.toggled.connect(func(on: bool) -> void: Settings.set_value(&"vibration_enabled", on))
	_quality.toggled.connect(func(on: bool) -> void: Settings.set_value(&"high_quality", on))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		toggle()


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
	get_tree().paused = true
	visible = true


func close() -> void:
	visible = false
	get_tree().paused = false
	if _mouse_was_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_sensitivity_changed(value: float) -> void:
	Settings.set_value(&"sensitivity", value)


func _on_menu_pressed() -> void:
	get_tree().paused = false
	menu_pressed.emit()
