extends Node3D
## Game root: wires the player, the waves and the HUD together, and keeps the score.

const KILL_SCORE := 100
const WAVE_BONUS := 250  # multiplied by the wave number
const WAVE_HEAL := 25
const BOSS_SCORE := 1000
const MENU_SCENE := "res://scenes/menu.tscn"
const DAMAGE_VIBRATION_MS := 40
const PERK_CHOICE_DELAY := 2.0
const DEATH_SLOW_MOTION := 0.3
const DEATH_TITLE_TIME := 3.0
const VICTORY_TIME := 5.0
## Seconds into a wave before its weapon crate is dropped.
const CRATE_DELAY := 8.0
## Crates land within this distance of the arena center, on each axis.
const CRATE_AREA := 24.0
## Arenas, in the order they are visited: a new one after each boss.
const ARENAS: Array[PackedScene] = [
	preload("res://scenes/arenas/station.tscn"),
	preload("res://scenes/arenas/desert.tscn"),
	preload("res://scenes/arenas/jungle.tscn"),
	preload("res://scenes/arenas/volcano.tscn"),
	preload("res://scenes/arenas/city.tscn"),
]

var score := 0

var _mouse_was_captured := false
var _arena: Arena
var _arena_index := 0
var _arena_change_pending := false
## XP found in chests during this game, added to the battle pass at the end.
var _bonus_xp := 0
var _won := false
var _boss: Boss

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var waves: WaveManager = $WaveManager


func _ready() -> void:
	# Test option: "-- --arena=2" on the command line starts in that arena.
	var first_arena := 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--arena="):
			first_arena = argument.get_slice("=", 1).to_int()
	_load_arena(first_arena)

	hud.touch_controls.look.connect(_on_touch_look)
	# Deferred: the scene must not be removed while the button is still handling its click.
	hud.replay_pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.perk_chosen.connect(_on_perk_chosen)

	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.weapon.equipped.connect(_on_weapon_equipped)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.damaged.connect(_vibrate)
	player.died.connect(_on_player_died)

	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_add_score.bind(KILL_SCORE))
	waves.enemy_killed.connect(player.on_enemy_killed)
	waves.enemies_left_changed.connect(_on_enemies_left_changed)
	waves.boss_spawned.connect(_on_boss_spawned)
	waves.boss_killed.connect(_on_boss_killed)

	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.get_magazine_size(), false)
	hud.set_score(score)

	Settings.changed.connect(_apply_quality)


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
			player.weapon.tag_kill(enemy)
			enemy.take_damage(9999)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F7 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): drops a weapon crate.
		_drop_crate()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F8 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): the next wave is a boss wave.
		waves.skip_to_next_boss()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F10 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): jumps to the next arena.
		_load_arena(_arena_index + 1)
		hud.show_banner(_arena.display_name)


## Replaces the current arena and puts the player at its starting point.
func _load_arena(index: int) -> void:
	if _arena:
		remove_child(_arena)
		_arena.queue_free()
	# Projectiles, power-ups and other leftovers of the previous arena.
	get_tree().call_group("transient", "queue_free")

	_arena_index = index % ARENAS.size()
	_arena = ARENAS[_arena_index].instantiate()
	add_child(_arena)
	move_child(_arena, 0)
	player.global_position = _arena.player_spawn_position()
	player.velocity = Vector3.ZERO
	_apply_quality()
	Music.play_track(_arena.music_track)
	for chest: Chest in get_tree().get_nodes_in_group("chests"):
		chest.opened.connect(_on_chest_opened)


func _on_chest_opened(message: String, bonus_xp: int) -> void:
	_bonus_xp += bonus_xp
	hud.show_banner(message)


func _apply_quality() -> void:
	_arena.apply_quality(Settings.high_quality)


func _vibrate() -> void:
	if Settings.vibration_enabled:
		Input.vibrate_handheld(DAMAGE_VIBRATION_MS)


func _add_score(points: int) -> void:
	score += points
	hud.set_score(score)


func _on_wave_started(number: int) -> void:
	get_tree().call_group("chests", "close")
	hud.show_banner("VAGUE %d  ·  BOSS" % number if waves.is_boss_wave() else "VAGUE %d" % number)
	# One weapon crate per wave, a moment after it starts.
	var arena := _arena
	await get_tree().create_timer(CRATE_DELAY, false).timeout
	if arena == _arena and not _arena_change_pending:
		_drop_crate()


## Drops a weapon crate a few meters from the player.
func _drop_crate() -> void:
	if player.health <= 0:
		return
	var offset := Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU) * randf_range(8.0, 14.0)
	var at := player.global_position + offset
	var crate := SupplyCrate.new()
	crate.position = Vector3(clampf(at.x, -CRATE_AREA, CRATE_AREA), 0, clampf(at.z, -CRATE_AREA, CRATE_AREA))
	crate.collected.connect(player.weapon.equip_temporary)
	add_child(crate)
	hud.show_banner("CAISSE D'ARME EN APPROCHE")


func _on_weapon_equipped(weapon_name: String) -> void:
	hud.show_banner(weapon_name.to_upper())


func _on_boss_spawned(boss: Boss) -> void:
	_boss = boss
	Music.play_track(Music.Track.BOSS)
	hud.show_boss(Boss.INFO[boss.kind].name)
	hud.set_boss_health(boss.max_health, boss.max_health)
	boss.health_changed.connect(hud.set_boss_health)


func _on_boss_killed(kind: Boss.Kind) -> void:
	Music.play_track(_arena.music_track)
	hud.hide_boss()
	_add_score(BOSS_SCORE)
	if kind == Boss.Kind.TITAN:
		_win()


## The final boss is down: a trophy rises where it fell, then the results.
func _win() -> void:
	_won = true
	waves.stop()
	player.invulnerable = true
	for enemy in get_tree().get_nodes_in_group("targets"):
		enemy.take_damage(9999)

	var trophy := Trophy.new()
	trophy.position = Vector3(_boss.global_position.x, _arena.global_position.y, _boss.global_position.z)
	add_child(trophy)
	hud.show_banner("VICTOIRE")
	await get_tree().create_timer(VICTORY_TIME).timeout

	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	SaveData.save_progress(Loadout.CHAMPION_KEY, true)
	_show_results(true)


func _on_wave_cleared(number: int) -> void:
	if player.health <= 0 or _won:
		return
	var bonus := WAVE_BONUS * number
	_add_score(bonus)
	player.heal(WAVE_HEAL)
	_arena_change_pending = waves.is_boss_wave()
	hud.show_banner("VAGUE %d TERMINÉE   +%d" % [number, bonus])

	# A short breather, then pause and let the player pick a perk.
	await get_tree().create_timer(PERK_CHOICE_DELAY, false).timeout
	if player.health <= 0 or _won:
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

	# A boss was just beaten: travel to the next arena.
	if _arena_change_pending:
		_arena_change_pending = false
		await hud.fade_to_black()
		_load_arena(_arena_index + 1)
		hud.show_banner(_arena.display_name)
		hud.fade_from_black()


func _on_enemies_left_changed(count: int) -> void:
	hud.set_wave(waves.wave, count)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _on_player_died() -> void:
	if _won:
		return
	waves.stop()
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Slow motion and a big title, then the results.
	Music.play_track(Music.Track.DEATH)
	Engine.time_scale = DEATH_SLOW_MOTION
	hud.show_death_title()
	await get_tree().create_timer(DEATH_TITLE_TIME, true, false, true).timeout
	Engine.time_scale = 1.0
	_show_results(false)


## Saves the record, feeds the battle pass and shows the end screen.
func _show_results(victory: bool) -> void:
	var best := SaveData.load_high_score()
	var is_record := score > best
	if is_record:
		SaveData.save_high_score(score)
	var xp := BattlePass.xp_for_score(score) + _bonus_xp
	var unlocked := []
	for id in BattlePass.add_xp(xp):
		unlocked.append(Loadout.find(id).item.name)
	if victory:
		unlocked.append("skin Champion")
	hud.show_game_over(score, maxi(score, best), is_record, xp, unlocked, victory)


func _on_touch_look(relative: Vector2) -> void:
	if player.health > 0:
		player.look(relative, player.touch_sensitivity)
