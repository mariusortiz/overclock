extends Node3D
## Game root: wires input sources to the player.

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	hud.touch_controls.look.connect(_on_touch_look)


func _unhandled_input(event: InputEvent) -> void:
	# Desktop/web: click to capture the mouse, Escape to release it.
	# Clicks emulated from touch are ignored (phones use the touch controls).
	if event is InputEventMouseButton and event.pressed \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_touch_look(relative: Vector2) -> void:
	player.look(relative, player.touch_sensitivity)
