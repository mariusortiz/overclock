extends Node3D
## Game root: wires input sources to the player and the HUD.

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	hud.touch_controls.look.connect(_on_touch_look)
	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)


func _unhandled_input(event: InputEvent) -> void:
	# Desktop/web: the first click captures the mouse, later clicks fire, Escape
	# releases. Clicks emulated from touch are ignored (phones use the touch controls).
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if not event.pressed:
			Input.action_release("fire")
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.action_press("fire")
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.action_release("fire")


func _on_touch_look(relative: Vector2) -> void:
	player.look(relative, player.touch_sensitivity)
