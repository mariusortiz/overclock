extends Node3D
## Game root: wires the player, the waves and the HUD together, and keeps the score.

## Seconds between a story mission's win and the story screen.
const STORY_END_TIME := 2.5
const KILL_SCORE := 100
const WAVE_BONUS := 250  # multiplied by the wave number
const WAVE_HEAL := 25
const BOSS_SCORE := 1000
const ELITE_SCORE := 400
## Kills less than this many seconds apart make a streak.
const STREAK_WINDOW := 1.6
const STREAK_BONUS := 50  # per kill after the first
const STREAK_NAMES := {2: "DOUBLÉ", 3: "TRIPLÉ", 4: "QUADRUPLÉ"}
const KILL_VIBRATION_MS := 15
## The boss's arrival: slow motion for this long (real time).
const BOSS_ENTRANCE_TIME := 0.8
const MENU_SCENE := "res://scenes/menu.tscn"
const DAMAGE_VIBRATION_MS := 40
const PERK_CHOICE_DELAY := 2.0
const DEATH_SLOW_MOTION := 0.3
const DEATH_TITLE_TIME := 3.0
## The last enemy of a wave falls in slow motion, for this long (real time).
const WAVE_END_SLOW_MOTION := 0.35
const WAVE_END_SLOW_TIME := 0.7
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
## After the Titan, the game can go on: arenas come around again, and bosses
## get tougher each time (see WaveManager._create_boss).
var _endless := false
var _boss: Boss
var _stats := GameStats.new()
var _streak := 0
var _last_kill_time := -100.0

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var waves: WaveManager = $WaveManager


func _ready() -> void:
	# Test options: "-- --arena=2" on the command line starts in that arena;
	# "--autofire" holds the trigger down; "--ulti" fires the ultimate after 5 s.
	var first_arena := 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--arena="):
			first_arena = argument.get_slice("=", 1).to_int()
		elif argument == "--autofire":
			Input.action_press("fire")
		elif argument == "--ulti":
			get_tree().create_timer(5.0, false).timeout.connect(func() -> void:
				player.ultimate.add_charge(1.0)
				Input.action_press("ultimate")
				get_tree().create_timer(0.2, false).timeout.connect(Input.action_release.bind("ultimate")))
	if Story.is_active():
		first_arena = Story.mission().arena
	_load_arena(first_arena)

	hud.touch_controls.look.connect(_on_touch_look)
	# Deferred: the scene must not be removed while the button is still handling its click.
	hud.replay_pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.perk_chosen.connect(_on_perk_chosen)
	hud.exit_chosen.connect(_on_exit_chosen)
	hud.quit_pressed.connect(_on_quit_pressed)
	hud.dance_chosen.connect(player.dance)

	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.weapon.equipped.connect(_on_weapon_equipped)
	player.ultimate.charge_changed.connect(hud.set_ultimate)
	player.ultimate.activated.connect(_on_weapon_equipped)
	hud.set_ultimate(0.0)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.damaged.connect(_vibrate)
	player.died.connect(_on_player_died)

	waves.wave_started.connect(_on_wave_started)
	waves.wave_cleared.connect(_on_wave_cleared)
	waves.enemy_killed.connect(_add_score.bind(KILL_SCORE))
	waves.enemy_killed.connect(player.on_enemy_killed)
	waves.enemy_killed.connect(_on_enemy_killed)
	waves.countdown.connect(hud.show_countdown)
	player.hurt_from.connect(hud.show_hurt_from)
	waves.enemies_left_changed.connect(_on_enemies_left_changed)
	waves.boss_spawned.connect(_on_boss_spawned)
	waves.boss_killed.connect(_on_boss_killed)
	waves.elite_spawned.connect(hud.show_banner.bind("UN ENNEMI D'ÉLITE ARRIVE"))
	waves.elite_killed.connect(_on_elite_killed)

	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.get_magazine_size(), false)
	hud.set_score(score)

	Settings.changed.connect(_apply_quality)

	add_child(_stats)
	_stats.setup(player, waves)

	if Story.is_active():
		_start_story_mission()
	elif Tutorial.is_needed():
		var tutorial := Tutorial.new()
		add_child(tutorial)
		tutorial.setup(player, hud, waves)


func _process(_delta: float) -> void:
	hud.set_status(player.get_effects(), player.perks)
	hud.reticle.on_target = player.aiming_at_enemy
	if Input.is_action_just_pressed("emote") and player.health > 0:
		hud.toggle_dance_wheel()


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
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F4 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): nothing can hurt the player.
		player.invulnerable = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F6 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut (debug and web builds): charges the ultimate.
		player.ultimate.add_charge(1.0)
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
	crate.collected.connect(func(_weapon: Dictionary) -> void: _stats.add("crates"))
	add_child(crate)
	hud.show_banner("CAISSE D'ARME EN APPROCHE")


## Announces a gun taken in hand, or an ultimate.
func _on_weapon_equipped(title: String) -> void:
	hud.show_banner(title.to_upper())


## Kill marker, a short buzz, and the streak count.
func _on_enemy_killed() -> void:
	hud.reticle.show_kill()
	if Settings.vibration_enabled:
		Input.vibrate_handheld(KILL_VIBRATION_MS)
	var now := Time.get_ticks_msec() / 1000.0
	_streak = _streak + 1 if now - _last_kill_time <= STREAK_WINDOW else 1
	_last_kill_time = now
	if _streak >= 2:
		var bonus := STREAK_BONUS * (_streak - 1)
		_add_score(bonus)
		hud.show_streak("%s   +%d" % [STREAK_NAMES.get(_streak, "SÉRIE ×%d" % _streak), bonus])


func _on_elite_killed() -> void:
	_add_score(ELITE_SCORE)
	hud.show_banner("ÉLITE ABATTUE   +%d" % ELITE_SCORE)


func _on_boss_spawned(boss: Boss) -> void:
	_boss = boss
	Music.play_track(Music.Track.BOSS)
	hud.show_boss(Boss.INFO[boss.kind].name)
	hud.set_boss_health(boss.max_health, boss.max_health)
	boss.health_changed.connect(hud.set_boss_health)
	# Its arrival: a moment of slow motion and a jolt.
	player.shake(0.2)
	Engine.time_scale = 0.4
	await get_tree().create_timer(BOSS_ENTRANCE_TIME, true, false, true).timeout
	if player.health > 0:
		Engine.time_scale = 1.0


func _on_boss_killed(kind: Boss.Kind) -> void:
	Music.play_track(_arena.music_track)
	hud.hide_boss()
	_add_score(BOSS_SCORE)
	if Story.is_active():
		_end_story_mission(true)
		return
	if kind == Boss.Kind.TITAN and not _endless:
		_win()


## The final boss is down: a trophy rises where it fell, the Champion skin is
## won, then the player chooses: go home, or carry on in endless mode.
func _win() -> void:
	_won = true
	waves.stop()
	player.invulnerable = true
	for enemy in get_tree().get_nodes_in_group("targets"):
		enemy.take_damage(9999)

	var trophy := Trophy.new()
	trophy.position = Vector3(_boss.global_position.x, _arena.global_position.y, _boss.global_position.z)
	trophy.add_to_group("transient")
	add_child(trophy)
	# Confetti and a golden flash over the fallen Titan.
	var top := trophy.position + Vector3.UP * 3.0
	Effects.flash(self, top, Color(1.0, 0.8, 0.25), 10.0, 1.2)
	for burst in 3:
		Effects.spray(self, top + Vector3.UP * burst, [Color(1.0, 0.85, 0.3), Color(1.0, 0.24, 0.95), Color(0.16, 0.9, 1.0), Color.WHITE],
				90, Vector3(0.16, 0.1, 0.01), Vector2(4.0, 8.0), Vector3(0, -3.0, 0), 70.0, 3.0)
	hud.show_banner("VICTOIRE")
	SaveData.save_progress(Loadout.CHAMPION_KEY, true)
	await get_tree().create_timer(VICTORY_TIME).timeout

	_mouse_was_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.action_release("fire")
	Input.action_release("aim")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	hud.show_exit_choice("", _earned_xp(), true)


func _on_wave_cleared(number: int) -> void:
	if player.health <= 0 or _won:
		return
	_slow_motion()
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
	# A boss was just beaten: go on to the next arena, or go home with the XP.
	if _arena_change_pending:
		var next: Arena = ARENAS[(_arena_index + 1) % ARENAS.size()].instantiate()
		hud.show_exit_choice(next.display_name, _earned_xp())
		next.free()
		return
	_resume()


func _resume() -> void:
	get_tree().paused = false
	if _mouse_was_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_chosen(leave: bool) -> void:
	_arena_change_pending = false
	if leave:
		waves.stop()
		get_tree().paused = false
		player.process_mode = Node.PROCESS_MODE_DISABLED
		_show_results(Hud.Result.VICTORY if _won else Hud.Result.LEFT)
		return
	if _won:
		_start_endless()
		return
	_resume()
	await hud.fade_to_black()
	_load_arena(_arena_index + 1)
	hud.show_banner(_arena.display_name)
	hud.fade_from_black()


func _slow_motion() -> void:
	Engine.time_scale = WAVE_END_SLOW_MOTION
	await get_tree().create_timer(WAVE_END_SLOW_TIME, true, false, true).timeout
	# Dying meanwhile starts its own slow motion: leave it alone.
	if player.health > 0:
		Engine.time_scale = 1.0


## Giving up from the pause menu ends the game like a death: half the XP,
## the challenges and stats counted, then the end screen.
func _on_quit_pressed() -> void:
	if Story.is_active():
		get_tree().paused = false
		get_tree().change_scene_to_file.call_deferred(Story.SCREEN)
		return
	waves.stop()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_show_results(Hud.Result.QUIT)


## A story mission: the waves of the chapter's arena (from its first one),
## with a power-up for each arena skipped, as if the player had come this far.
func _start_story_mission() -> void:
	var arena: int = Story.mission().arena
	waves.wave = arena * WaveManager.BOSS_EVERY
	for i in arena * 2:
		player.add_perk(Perk.pick_choices(1)[0])
	hud.show_banner("CHAPITRE %d  ·  %s" % [Story.chapter + 1, str(Story.mission().title).to_upper()])


## The chapter's boss is down: the mission is won, stars by health left.
func _end_story_mission(won: bool) -> void:
	_won = true
	waves.stop()
	player.invulnerable = true
	for enemy in get_tree().get_nodes_in_group("targets"):
		enemy.take_damage(9999)
	hud.show_banner("MISSION ACCOMPLIE")
	Effects.flash(self, player.global_position + Vector3.UP * 2.0, Color(1.0, 0.8, 0.25), 8.0, 1.0)
	var stars := Story.stars_for_health(float(player.health) / float(player.max_health))
	await get_tree().create_timer(STORY_END_TIME).timeout
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Story.finish(won, stars)
	get_tree().change_scene_to_file.call_deferred(Story.SCREEN)


## The game goes on past the Titan, from the first arena.
func _start_endless() -> void:
	_won = false
	_endless = true
	player.invulnerable = false
	_resume()
	await hud.fade_to_black()
	_load_arena(_arena_index + 1)
	hud.show_banner("MODE SANS FIN")
	hud.fade_from_black()
	waves.resume()


## XP this game is worth so far, if it ends without dying.
func _earned_xp() -> int:
	return BattlePass.xp_for_score(score) + _bonus_xp


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
	if Story.is_active():
		Story.finish(false, 0)
		get_tree().change_scene_to_file.call_deferred(Story.SCREEN)
		return
	_show_results(Hud.Result.DEATH)


## Saves the record, feeds the battle pass and shows the end screen.
## Dying only pays half the XP: going home after a boss is the safe way.
func _show_results(result: Hud.Result) -> void:
	var best := SaveData.load_high_score()
	var is_record := score > best
	if is_record:
		SaveData.save_high_score(score)
	var xp := _earned_xp()
	if result == Hud.Result.DEATH or result == Hud.Result.QUIT:
		@warning_ignore("integer_division")
		xp /= 2
	# Challenges pay in full, even after a death.
	var completed := _stats.finish()
	var challenge_xp := 0
	for challenge in completed:
		challenge_xp += challenge.xp
	var unlocked := []
	var tier_before: int = BattlePass.progress().tier
	for id in BattlePass.add_xp(xp + challenge_xp):
		unlocked.append(Loadout.find(id).item.name)
	if result == Hud.Result.VICTORY or _endless:
		unlocked.append("skin Champion")
	var rank := Leaderboard.add(score, waves.wave, Loadout.selected_character().name, _endless)
	hud.show_game_over(score, maxi(score, best), is_record, xp, unlocked, result, completed, rank, _stats.counts)
	# Shop money: credits from the score (halved like the XP), gems for the
	# bosses beaten and for finishing all of the day's challenges.
	var credits := Wallet.credits_for_score(score)
	if result == Hud.Result.DEATH or result == Hud.Result.QUIT:
		@warning_ignore("integer_division")
		credits /= 2
	var gems: int = int(_stats.counts.get("bosses", 0)) * Wallet.GEMS_PER_BOSS
	if not completed.is_empty() and Challenges.done_count() == Challenges.PER_DAY:
		gems += Wallet.GEMS_FOR_ALL_CHALLENGES
		Cards.give_booster("rare")
	Wallet.add_credits(credits)
	Wallet.add_gems(gems)
	hud.show_rewards(credits, gems, Cards.reward_game(score, tier_before))


func _on_touch_look(relative: Vector2) -> void:
	if player.health > 0:
		player.look(relative, player.touch_sensitivity)
