extends Node3D
## Game root: wires the player, the waves and the HUD together, and keeps the score.

const KILL_SCORE := 100
const WAVE_BONUS := 250  # multiplied by the wave number
const WAVE_HEAL := 25
const MENU_SCENE := "res://scenes/menu.tscn"

var score := 0

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var waves: WaveManager = $WaveManager


func _ready() -> void:
	hud.touch_controls.look.connect(_on_touch_look)
	# Deferred: the scene must not be removed while the button is still handling its click.
	hud.replay_pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)

	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.died.connect(_on_player_died)

	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_add_score.bind(KILL_SCORE))
	waves.enemies_left_changed.connect(_on_enemies_left_changed)

	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.magazine_size, false)
	hud.set_score(score)


func _process(_delta: float) -> void:
	hud.set_effects(player.get_effects())


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


func _add_score(points: int) -> void:
	score += points
	hud.set_score(score)


func _on_wave_started(number: int) -> void:
	hud.show_banner("VAGUE %d" % number)


func _on_wave_cleared(number: int) -> void:
	var bonus := WAVE_BONUS * number
	_add_score(bonus)
	player.heal(WAVE_HEAL)
	hud.show_banner("VAGUE %d TERMINÉE   +%d" % [number, bonus])


func _on_enemies_left_changed(count: int) -> void:
	hud.set_wave(waves.wave, count)


func _on_player_died() -> void:
	waves.stop()
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var best := SaveData.load_high_score()
	var is_record := score > best
	if is_record:
		SaveData.save_high_score(score)
	hud.show_game_over(score, maxi(score, best), is_record)


func _on_touch_look(relative: Vector2) -> void:
	if player.health > 0:
		player.look(relative, player.touch_sensitivity)
