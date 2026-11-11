extends Node
## Directs the two-minute trailer. It runs the real game with a bot at the
## controls, moves it from arena to arena on a fixed timeline, cuts to a free
## camera for the wide shots and lays title cards on top.
##
## Rendered by .github/workflows/trailer.yml with Godot's movie mode:
##   godot --write-movie trailer.avi --fixed-fps 30 res://scenes/tools/trailer.tscn
## This is a tool: it reaches into private members of the game on purpose.

const MAIN_SCENE := "res://scenes/main.tscn"
const URL := "mariusortiz.github.io/overclock-builds"
const DURATION := 120.0
const TEXT_COLOR := Color(0.16, 0.9, 1.0)
const ACCENT := Color(1.0, 0.24, 0.95)
## The bot shoots once its aim is this close to the target, in radians.
const AIM_TOLERANCE := 0.05
const AIM_SPEED := 9.0
## A choice panel stays on screen this long before the bot answers it.
const PANEL_TIME := 1.4
const WORLD_LAYER := 1
## The bot walks up to a target farther than this.
const APPROACH_DISTANCE := 16.0

var _clock := 0.0
var _main: Node
var _player: Player
var _hud: Hud
var _waves: WaveManager
var _bot := false
var _paused_for := 0.0
var _release_ultimate_at := -1.0

var _cine := Camera3D.new()
var _cine_on := false
var _cine_target: Node3D
var _cine_center := Vector3.ZERO
var _cine_radius := 10.0
var _cine_height := 4.0
var _cine_speed := 0.3
var _cine_angle := 0.0

var _shade := ColorRect.new()
var _title := Label.new()
var _subtitle := Label.new()
var _card := Label.new()
var _card_tween: Tween


func _ready() -> void:
	# Everything unlocked, and a loadout worth showing.
	BattlePass.add_xp(1000000)
	SaveData.save_progress(Loadout.CHAMPION_KEY, true)
	Loadout.select(Loadout.CHARACTER_KEY, Loadout.find("ninja").item)
	Loadout.select(Loadout.WEAPON_KEY, Loadout.find("heavy").item)
	Loadout.select(Loadout.SKIN_KEY, Loadout.find("skin_neon").item)
	_build_overlay()
	_start.call_deferred()


func _start() -> void:
	_main = load(MAIN_SCENE).instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main
	_player = _main.player
	_hud = _main.hud
	_waves = _main.waves
	_player.invulnerable = true
	_hud.get_node("FpsLabel").modulate.a = 0.0
	_hud.get_node("DesktopHint").modulate.a = 0.0
	_main.add_child(_cine)
	_cine.fov = 60.0
	_run()


# --- Timeline ---------------------------------------------------------------

func _run() -> void:
	# Opening: the station from above, and the name of the game.
	_hud.visible = false
	_orbit(null, Vector3(0, 1, 0), 30.0, 11.0, 0.22)
	_fade_shade(0.0, 1.5)
	await _until(1.5)
	_show_title("OVERCLOCK", "SHOOTER D'ARÈNE · 3D LOW-POLY", 4.5)
	await _until(7.0)

	_stage(0, 3)
	_play()
	_show_card("DES VAGUES D'ENNEMIS, AU SOL ET DANS LES AIRS")
	await _until(18.0)

	_stage(1, 7)
	_show_card("5 ARÈNES")
	await _until(22.0)
	_give("shotgun_1", "skin_lava")
	_show_card("40 ARMES")
	await _until(26.0)
	_give("bazooka", "skin_gold")
	await _until(30.0)
	_give("sniper_3", "skin_ice")
	await _until(34.0)

	_stage(2, 9)
	_give("smg", "skin_toxic")
	_show_card("CHAQUE SKIN A SA FAÇON DE TUER")
	await _until(42.0)
	_show_card("13 HÉROS · 13 ULTIS")
	_ultimate()
	await _until(43.0)
	_orbit(_player, Vector3.ZERO, 8.0, 3.0, 0.5)
	await _until(48.0)
	_play()
	await _until(52.0)

	_stage(3, 5)
	_give("rifle_3", "skin_solar")
	_show_card("DES BOSS")
	await _until(57.0)
	await _ensure_boss(3, 5)
	_orbit(_boss(), Vector3.ZERO, 11.0, 3.5, 0.45)
	await _until(63.0)
	_play()
	await _until(72.0)

	_stage(4, 25)
	_give("rifle_5", "skin_champion")
	_show_card("ET AU BOUT DE LA VILLE…")
	await _until(77.0)
	await _ensure_boss(4, 25)
	_orbit(_boss(), Vector3.ZERO, 13.0, 2.5, 0.4)
	_show_card("LE TITAN")
	await _until(84.0)
	_play()
	await _until(90.0)
	_ultimate()
	await _until(96.0)

	# The Titan falls: trophy, then the victory screen.
	var boss := _boss()
	if boss:
		_orbit(null, boss.global_position + Vector3.UP, 9.0, 3.0, 0.5)
		boss.take_damage(99999)
	await _until(101.5)
	_hud.visible = true
	await _until(106.0)

	# End card.
	_fade_shade(1.0, 1.0)
	await _until(107.5)
	_show_title("OVERCLOCK", "JOUEZ MAINTENANT\n" + URL, 10.5)
	await _until(DURATION)
	get_tree().quit()


func _until(time: float) -> void:
	while _clock < time:
		await get_tree().process_frame


# --- Staging ----------------------------------------------------------------

## Jumps to an arena and starts the given wave there.
func _stage(arena_index: int, wave: int) -> void:
	get_tree().paused = false
	_hud._perk_choice.visible = false
	_hud._exit_choice.visible = false
	_hud.hide_boss()
	for enemy in get_tree().get_nodes_in_group("targets"):
		enemy.remove_from_group("targets")
		enemy.queue_free()
	_waves._spawn_timer.stop()
	_waves._to_spawn = 0
	_waves._alive = 0
	_waves._boss_pending = false
	_main._arena_change_pending = false
	_main._load_arena(arena_index)
	_hud.show_banner(_main._arena.display_name)
	_waves.wave = wave - 1
	_waves._start_next_wave(0.3)


## A leftover timer of the previous wave can swallow a boss wave: start it again.
func _ensure_boss(arena_index: int, wave: int) -> void:
	if _boss() == null:
		_stage(arena_index, wave)
		await get_tree().create_timer(1.5).timeout


## The boss in play, or null (the game keeps a dangling reference to a dead one).
func _boss() -> Boss:
	var boss: Variant = _main._boss
	if is_instance_valid(boss) and not boss.is_queued_for_deletion():
		return boss
	return null


## Hands the player a gun with a skin, for as long as the scene lasts.
func _give(weapon_id: String, skin_id: String) -> void:
	Loadout.select(Loadout.SKIN_KEY, Loadout.find(skin_id).item)
	_player.weapon.equip_temporary(Loadout.find(weapon_id).item)
	_player.weapon._temporary_magazines = 99


func _ultimate() -> void:
	_player.ultimate.add_charge(1.0)
	Input.action_press("ultimate")
	_release_ultimate_at = _clock + 0.2


## Back to the game's own camera, with the bot fighting.
func _play() -> void:
	_cine_on = false
	_bot = true
	_hud.visible = true
	(_player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D).make_current()


## Cuts to a camera circling `target` (or the fixed point `center`).
func _orbit(target: Node3D, center: Vector3, radius: float, height: float, speed: float) -> void:
	_cine_on = true
	_bot = false
	Input.action_release("fire")
	if _hud:
		_hud.visible = false
	_cine_target = target
	_cine_center = center
	_cine_radius = radius
	_cine_height = height
	_cine_speed = speed
	_cine.make_current()


# --- Every frame ------------------------------------------------------------

func _process(delta: float) -> void:
	_clock += delta
	if _release_ultimate_at >= 0.0 and _clock >= _release_ultimate_at:
		_release_ultimate_at = -1.0
		Input.action_release("ultimate")
	if _main == null:
		return
	_answer_panels(delta)
	if _cine_on:
		if is_instance_valid(_cine_target):
			_cine_center = _cine_target.global_position + Vector3.UP * 1.2
		_cine_angle += _cine_speed * delta
		var offset := Vector3(cos(_cine_angle), 0, sin(_cine_angle)) * _cine_radius + Vector3.UP * _cine_height
		_cine.look_at_from_position(_cine_center + _clear_of_walls(offset), _cine_center)


## Shortens the camera's offset so that no wall stands between it and its subject.
func _clear_of_walls(offset: Vector3) -> Vector3:
	var query := PhysicsRayQueryParameters3D.create(_cine_center, _cine_center + offset, WORLD_LAYER)
	var hit := _cine.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return offset
	var free := maxf(_cine_center.distance_to(hit.position) - 0.6, 2.0)
	return offset.normalized() * free


## The game pauses on its choice panels: leave them up a moment, then answer.
func _answer_panels(delta: float) -> void:
	if not get_tree().paused:
		_paused_for = 0.0
		return
	_paused_for += delta
	if _paused_for < PANEL_TIME:
		return
	_paused_for = 0.0
	if _hud._exit_choice.visible:
		# Stay in this arena: the timeline decides when to travel.
		_hud._exit_choice.visible = false
		_main._arena_change_pending = false
		_main._resume()
	elif _hud._perk_choice.visible:
		_hud._on_perk_button_pressed(0)
	else:
		get_tree().paused = false


func _physics_process(delta: float) -> void:
	if _main == null or get_tree().paused:
		return
	# Keep moving in every shot: strafe, back off when crowded, hop now and then.
	var left := int(_clock / 2.5) % 2 == 0
	_set_action("move_left", left)
	_set_action("move_right", not left)
	_set_action("jump", fmod(_clock, 4.0) < 0.1)
	var target := _nearest_enemy()
	var distance := INF if target == null else target.global_position.distance_to(_player.global_position)
	_set_action("move_back", distance < 6.0)
	_set_action("move_forward", _bot and target != null and distance > APPROACH_DISTANCE)
	if not _bot or target == null:
		Input.action_release("fire")
		return

	# Turn the view until the crosshair is on the target, then shoot.
	var camera := get_viewport().get_camera_3d()
	var wanted := camera.global_position.direction_to(target.get_aim_position())
	var forward := -camera.global_basis.z
	var yaw_error := wrapf(atan2(-wanted.x, -wanted.z) - atan2(-forward.x, -forward.z), -PI, PI)
	var pitch_error := asin(wanted.y) - asin(forward.y)
	var step := minf(AIM_SPEED * delta, 1.0)
	_player.rotate_y(yaw_error * step)
	var arm: SpringArm3D = _player._spring_arm
	arm.rotation.x = clampf(arm.rotation.x + pitch_error * step,
			deg_to_rad(_player.min_pitch_deg), deg_to_rad(_player.max_pitch_deg))
	_player.weapon.rotation.x = arm.rotation.x
	_set_action("fire", absf(yaw_error) < AIM_TOLERANCE and absf(pitch_error) < AIM_TOLERANCE)


func _set_action(action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


## The boss when there is one (it is the subject of the shot), else the nearest enemy.
func _nearest_enemy() -> Node3D:
	var boss := _boss()
	if boss:
		return boss
	var nearest: Node3D = null
	var best := 80.0
	for enemy: Node3D in get_tree().get_nodes_in_group("targets"):
		var distance := _player.global_position.distance_to(enemy.global_position)
		if distance < best:
			best = distance
			nearest = enemy
	return nearest


# --- Titles -----------------------------------------------------------------

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_shade.color = Color.BLACK
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_shade)
	_setup_label(layer, _title, 150, TEXT_COLOR, 0.30)
	_setup_label(layer, _subtitle, 40, Color.WHITE, 0.56)
	_setup_label(layer, _card, 46, Color.WHITE, 0.80)


func _setup_label(layer: CanvasLayer, label: Label, font_size: int, color: Color, anchor_y: float) -> void:
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = anchor_y
	label.anchor_bottom = anchor_y
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 12)
	label.modulate.a = 0.0
	layer.add_child(label)


func _fade_shade(alpha: float, seconds: float) -> void:
	create_tween().tween_property(_shade, "color:a", alpha, seconds)


## Big title with a line under it, shown for `seconds`.
func _show_title(title: String, subtitle: String, seconds: float) -> void:
	_title.text = title
	_subtitle.text = subtitle
	_subtitle.add_theme_color_override("font_color", ACCENT if subtitle.contains(URL) else Color.WHITE)
	var tween := create_tween()
	tween.tween_property(_title, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(_subtitle, "modulate:a", 1.0, 0.6).set_delay(0.5)
	tween.tween_interval(seconds - 1.8)
	tween.tween_property(_title, "modulate:a", 0.0, 0.6)
	tween.parallel().tween_property(_subtitle, "modulate:a", 0.0, 0.6)


## One line near the bottom of the picture, for a few seconds.
func _show_card(text: String) -> void:
	if _card_tween:
		_card_tween.kill()
	_card.text = text
	_card.modulate.a = 0.0
	_card_tween = create_tween()
	_card_tween.tween_property(_card, "modulate:a", 1.0, 0.4)
	_card_tween.tween_interval(2.8)
	_card_tween.tween_property(_card, "modulate:a", 0.0, 0.5)
