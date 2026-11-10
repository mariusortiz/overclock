extends Node3D
## Game root: wires the player, the waves and the HUD together, and keeps the score.

const KILL_SCORE := 100
const WAVE_BONUS := 250  # multiplied by the wave number
const WAVE_HEAL := 25
const MENU_SCENE := "res://scenes/menu.tscn"
const DAMAGE_VIBRATION_MS := 40
const PERK_CHOICE_DELAY := 2.0

var score := 0

var _mouse_was_captured := false

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var waves: WaveManager = $WaveManager
@onready var _sun: DirectionalLight3D = $Sun
@onready var _world: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	hud.touch_controls.look.connect(_on_touch_look)
	# Deferred: the scene must not be removed while the button is still handling its click.
	hud.replay_pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.perk_chosen.connect(_on_perk_chosen)

	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.damaged.connect(_vibrate)
	player.died.connect(_on_player_died)

	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_add_score.bind(KILL_SCORE))
	waves.enemy_killed.connect(player.on_enemy_killed)
	waves.enemies_left_changed.connect(_on_enemies_left_changed)

	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.get_magazine_size(), false)
	hud.set_score(score)

	Settings.changed.connect(_apply_quality)
	_apply_quality()


func _process(_delta: float) -> void:
	hud.set_status(player.get_effects(), player.perks)


func _unhandled_input(event: InputEvent) -> void:
	# Desktop/web: the first click captures the mouse, later clicks fire (Escape
	# opens the pause menu). Clicks emulated from touch are ignored (phones use the touch controls).
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if not event.pressed:
			Input.action_release("fire")
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.action_press("fire")
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		# Hold the right button to zoom in.
		if event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.action_press("aim")
		else:
			Input.action_release("aim")
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F9 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): destroys every robot.
		for enemy in get_tree().get_nodes_in_group("targets"):
			enemy.take_damage(9999)


func _apply_quality() -> void:
	_sun.shadow_enabled = Settings.high_quality
	_world.environment.glow_enabled = Settings.high_quality


func _vibrate() -> void:
	if Settings.vibration_enabled:
		Input.vibrate_handheld(DAMAGE_VIBRATION_MS)


func _add_score(points: int) -> void:
	score += points
	hud.set_score(score)


func _on_wave_started(number: int) -> void:
	hud.show_banner("VAGUE %d" % number)


func _on_wave_cleared(number: int) -> void:
	if player.health <= 0:
		return
	var bonus := WAVE_BONUS * number
	_add_score(bonus)
	player.heal(WAVE_HEAL)
	hud.show_banner("VAGUE %d TERMINÉE   +%d" % [number, bonus])

	# A short breather, then pause and let the player pick a perk.
	await get_tree().create_timer(PERK_CHOICE_DELAY, false).timeout
	if player.health <= 0:
		return
	# The mouse is freed for the click.
	_mouse_was_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.action_release("fire")
	Input.action_release("aim")
	get_tree().paused = true
	hud.show_perk_choice("Choisis un pouvoir", Perk.pick_choices(3), player.perks)


func _on_perk_chosen(type: Perk.Type) -> void:
	player.add_perk(type)
	get_tree().paused = false
	if _mouse_was_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
