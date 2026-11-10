extends Node3D
## Game root: wires input sources to the player and the HUD.

const RESTART_DELAY := 2.0

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	hud.touch_controls.look.connect(_on_touch_look)
	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	hud.set_health(player.health, player.max_health)


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


func _on_player_health_changed(current: int, maximum: int) -> void:
	hud.set_health(current, maximum)
	hud.flash_damage()


func _on_player_died() -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.action_release("fire")
	hud.show_death()
	await get_tree().create_timer(RESTART_DELAY).timeout
	get_tree().reload_current_scene()


func _on_touch_look(relative: Vector2) -> void:
	player.look(relative, player.touch_sensitivity)
