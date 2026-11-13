extends Node3D
## Zone capture: the player and three allies against four foes, all bots
## but the player. Three zones (A, B, C); each one a team holds earns it a
## point per second. The first team to WIN_SCORE wins. The fallen come back
## at their base after a few seconds.

const MENU_SCENE := "res://scenes/menu.tscn"
const ARENAS := ["station", "desert", "jungle", "volcano", "matrix", "crystal", "city", "ruins", "snow"]
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const TEAM_SIZE := 4
const WIN_SCORE := 150
const RESPAWN_TIME := 5.0
const BOT_HEALTH := 14
const BOT_SPEED := 4.0
const BOT_FIRE_INTERVAL := 0.8
const BOT_RANGE := 16.0
const KILL_SCORE := 100
const CAPTURE_SCORE := 250
const WIN_BONUS := 1500
## Allies carry no gun model of the arena's foes: they get one of these.
const BOT_WEAPONS := ["heavy", "smg", "blaster", "rifle_2", "smg_2"]

var score := 0
var _arena: Arena
var _zones: Array[CaptureZone] = []
var _points := {&"ally": 0.0, &"enemy": 0.0}
var _bases := {&"ally": Vector3.ZERO, &"enemy": Vector3.ZERO}
var _over := false
var _kills := 0
var _zone_text := RichTextLabel.new()
## Network play (see CaptureNet), or null.
var _net: CaptureNet

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	# The snow village (last) only during the Christmas event.
	var count := ARENAS.size() if Events.is_christmas() else ARENAS.size() - 1
	var index := randi() % count
	if Net.is_online():
		# The same arena everywhere.
		index = Net.seed_value % count
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--arena="):
			index = argument.get_slice("=", 1).to_int() % ARENAS.size()
	if Story.is_active():
		index = Story.mission().arena
	_arena = load("res://scenes/arenas/%s.tscn" % ARENAS[index]).instantiate()
	Enemy.corrupted = _arena.corrupted
	Enemy.arena_glow = _arena.enemy_glow
	add_child(_arena)
	move_child(_arena, 0)
	Music.play_track(Music.Track.CAPTURE)
	_arena.apply_quality(Settings.high_quality)

	_place_bases_and_zones()
	if Net.is_online():
		_net = CaptureNet.new()
		_net.name = "CaptureNet"
		add_child(_net)
		_net.setup(self)
		if _net.my_team == 1:
			# Team 1 starts at the other base.
			var home: Vector3 = _bases[&"ally"]
			_bases[&"ally"] = _bases[&"enemy"]
			_bases[&"enemy"] = home
		Net.left.connect(func(reason: String) -> void:
			hud.show_banner(reason)
			get_tree().create_timer(2.5).timeout.connect(get_tree().change_scene_to_file.bind(MENU_SCENE)))
	player.global_position = _bases[&"ally"]

	hud.touch_controls.look.connect(_on_touch_look)
	hud.replay_pressed.connect(_replay, CONNECT_DEFERRED)
	hud.menu_pressed.connect(_to_menu, CONNECT_DEFERRED)
	hud.quit_pressed.connect(_finish.bind(Hud.Result.QUIT))
	hud.dance_chosen.connect(player.dance)
	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.ultimate.charge_changed.connect(hud.set_ultimate)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.hurt_from.connect(hud.show_hurt_from)
	player.died.connect(_on_player_died)
	hud.set_ultimate(0.0)
	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.get_magazine_size(), false)
	hud.set_score(score)
	_build_zone_text()
	_refresh_top()

	# The arena bakes its navigation over the first frames: then the bots come.
	if not _arena.is_navigation_ready:
		await _arena.navigation_ready
	if _net and not Net.is_host():
		# Guests: the host runs the bots, the zones and the score.
		hud.show_banner("CAPTURE DE ZONE · ÉQUIPE %s" % ("BLEUE" if _net.my_team == 0 else "ROUGE"))
		return
	if _net:
		await _net.wait_for_guests(8.0)
	# Bots fill each team up to TEAM_SIZE (the host's team is "ally").
	var allies := TEAM_SIZE - (CaptureNet.humans_in(0) if _net else 1)
	var foes := TEAM_SIZE - (CaptureNet.humans_in(1) if _net else 0)
	for i in allies:
		_spawn_bot(&"ally")
	for i in foes:
		_spawn_bot(&"enemy")
	hud.show_banner("CAPTURE DE ZONE · %d POINTS POUR GAGNER" % WIN_SCORE)
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_second)
	add_child(timer)
	timer.start()


func _physics_process(delta: float) -> void:
	if _over:
		return
	if _net and not Net.is_host():
		_refresh_zone_text()
		return
	for zone in _zones:
		var allies := 0
		var enemies := 0
		if player.health > 0 and zone.contains(player.global_position):
			allies += 1
		for bot: Node3D in get_tree().get_nodes_in_group("allies"):
			if zone.contains(bot.global_position):
				allies += 1
		for bot: Node3D in get_tree().get_nodes_in_group("targets"):
			if zone.contains(bot.global_position):
				enemies += 1
		zone.update(delta, allies, enemies)
	_refresh_zone_text()


func _process(_delta: float) -> void:
	hud.reticle.on_target = player.aiming_at_enemy
	if Input.is_action_just_pressed("emote") and player.health > 0:
		hud.toggle_dance_wheel()


## Each zone held is worth a point a second to its team.
func _on_second() -> void:
	if _over:
		return
	for zone in _zones:
		if zone.holder != &"":
			_points[zone.holder] += 1
	_refresh_top()
	if _points[&"ally"] >= WIN_SCORE:
		if _net:
			_net.announce_winner(0)
		else:
			_finish(Hud.Result.TEAM_WIN)
	elif _points[&"enemy"] >= WIN_SCORE:
		if _net:
			_net.announce_winner(1)
		else:
			_finish(Hud.Result.DEFEAT)


# --- Map ----------------------------------------------------------------------

## The player's team starts where the player does in the waves; the foes at
## the spawn point farthest from it. B is the arena's center; A and C the
## spawn points farthest apart across the line between the two bases.
func _place_bases_and_zones() -> void:
	var home := _arena.player_spawn_position()
	var spawns: Array[Vector3] = []
	for marker: Node3D in get_tree().get_nodes_in_group("enemy_spawns"):
		spawns.append(marker.global_position)
	var away := home
	for point in spawns:
		if point.distance_to(home) > away.distance_to(home):
			away = point
	_bases[&"ally"] = home
	_bases[&"enemy"] = away
	var middle := _arena.boss_spawn_position()
	var across := Vector3(-(away - home).z, 0, (away - home).x).normalized()
	var left := middle
	var right := middle
	for point in spawns:
		if point == away:
			continue
		var side := (point - middle).dot(across)
		if side < (left - middle).dot(across):
			left = point
		if side > (right - middle).dot(across):
			right = point
	for entry: Array in [["A", left], ["B", middle], ["C", right]]:
		var zone := CaptureZone.new()
		zone.letter = entry[0]
		add_child(zone)
		zone.global_position = entry[1]
		zone.owner_changed.connect(_on_zone_owner_changed)
		_zones.append(zone)


# --- Fighters -----------------------------------------------------------------

func _spawn_bot(team: StringName) -> void:
	if _over:
		return
	var bot := ENEMY_SCENE.instantiate()
	# The scene's own settings are lost with its script: carry them over.
	var bolt: PackedScene = bot.projectile_scene
	bot.set_script(CaptureBot)
	var capture_bot := bot as CaptureBot
	capture_bot.projectile_scene = bolt
	capture_bot.team = team
	capture_bot.zones = _zones
	capture_bot.max_health = BOT_HEALTH
	capture_bot.move_speed = BOT_SPEED
	capture_bot.fire_interval = BOT_FIRE_INTERVAL
	capture_bot.attack_range = BOT_RANGE
	capture_bot.drop_chance = 0.0
	if team == &"ally":
		var heroes := Loadout.CHARACTERS.filter(func(item: Dictionary) -> bool:
			return not item.get("shop", false) and item.id != Loadout.selected_character().id)
		capture_bot.model_scene = load(Loadout.CHARACTER_DIR + str(heroes.pick_random().model))
		capture_bot.weapon_id = BOT_WEAPONS.pick_random()
	else:
		capture_bot.model_scene = _arena.enemy_model
		capture_bot.weapon_id = BOT_WEAPONS.pick_random()
	var spread := Vector2.from_angle(randf() * TAU) * randf_range(0.5, 2.5)
	capture_bot.position = _bases[team] + Vector3(spread.x, 0.2, spread.y)
	add_child(capture_bot)
	capture_bot.died.connect(_on_bot_died.bind(capture_bot, team))
	if _net:
		_net.register_bot(capture_bot)


func _on_bot_died(bot: CaptureBot, team: StringName) -> void:
	if team == &"enemy" and bot._kill_style != &"":
		# Its last hit came from the player.
		count_kill()
	get_tree().create_timer(RESPAWN_TIME, false).timeout.connect(_spawn_bot.bind(team))


func count_kill() -> void:
	_kills += 1
	score += KILL_SCORE
	hud.set_score(score)
	player.on_enemy_killed()
	hud.reticle.show_kill()


## Network play: the host announced the end.
func finish_online(won: bool) -> void:
	_finish(Hud.Result.TEAM_WIN if won else Hud.Result.DEFEAT)


## Online, only the host starts the next match, for everyone.
func _replay() -> void:
	if not Net.is_online():
		get_tree().reload_current_scene()
	elif Net.is_host():
		Net.start_game("capture")
	else:
		hud.show_banner("L'HÔTE RELANCE LA PARTIE")


func _to_menu() -> void:
	if Net.is_online():
		Net.leave()
	get_tree().change_scene_to_file(Story.SCREEN if Story.is_active() else MENU_SCENE)


func _on_player_died() -> void:
	if _over:
		return
	hud.show_banner("RÉAPPARITION DANS %d S" % int(RESPAWN_TIME))
	await get_tree().create_timer(RESPAWN_TIME, false).timeout
	if not _over:
		player.revive(_bases[&"ally"])


func _on_zone_owner_changed(zone: CaptureZone) -> void:
	match zone.holder:
		&"ally":
			hud.show_banner("ZONE %s PRISE" % zone.letter)
			if player.health > 0 and zone.contains(player.global_position):
				score += CAPTURE_SCORE
				hud.set_score(score)
		&"enemy":
			hud.show_banner("ZONE %s PERDUE" % zone.letter)


# --- HUD ----------------------------------------------------------------------

func _refresh_top() -> void:
	hud.set_mode_text("ÉQUIPE %d  ·  ADVERSES %d  /  %d" % [_points[&"ally"], _points[&"enemy"], WIN_SCORE])


## The three letters under the score, each in its holder's color.
func _build_zone_text() -> void:
	_zone_text.bbcode_enabled = true
	_zone_text.fit_content = true
	_zone_text.scroll_active = false
	_zone_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zone_text.add_theme_font_override("normal_font", preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf"))
	_zone_text.add_theme_font_size_override("normal_font_size", 34)
	_zone_text.add_theme_constant_override("outline_size", 8)
	_zone_text.add_theme_color_override("font_outline_color", Color.BLACK)
	_zone_text.anchor_left = 0.5
	_zone_text.anchor_right = 0.5
	_zone_text.offset_left = -150
	_zone_text.offset_right = 150
	_zone_text.offset_top = 64
	_zone_text.offset_bottom = 110
	hud.add_child(_zone_text)


func _refresh_zone_text() -> void:
	var parts: Array[String] = []
	for zone in _zones:
		parts.append("[color=#%s]%s[/color]" % [zone.color().to_html(false), zone.letter])
	_zone_text.text = "[center]%s[/center]" % "   ".join(parts)


# --- End ----------------------------------------------------------------------

func _finish(result: Hud.Result) -> void:
	if _over:
		return
	_over = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for bot in get_tree().get_nodes_in_group("allies") + get_tree().get_nodes_in_group("targets"):
		bot.process_mode = Node.PROCESS_MODE_DISABLED
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Story.is_active():
		_end_story_mission(result == Hud.Result.TEAM_WIN)
		return
	if result == Hud.Result.TEAM_WIN:
		score += WIN_BONUS
	var xp := BattlePass.xp_for_score(score)
	var credits := Wallet.credits_for_score(score)
	if result == Hud.Result.TEAM_WIN:
		Achievements.set_flag("capture_win")
	if result != Hud.Result.TEAM_WIN:
		@warning_ignore("integer_division")
		xp /= 2
		@warning_ignore("integer_division")
		credits /= 2
	var unlocked := []
	var tier_before: int = BattlePass.progress().tier
	for id in BattlePass.add_xp(xp):
		unlocked.append(Loadout.find(id).item.name)
	Wallet.add_credits(credits)
	var boosters := Cards.reward_game(score, tier_before)
	hud.show_game_over(score, score, false, xp, unlocked, result)
	hud.set_result_line("Équipe %d  ·  Adverses %d  ·  %d éliminations" % [_points[&"ally"], _points[&"enemy"], _kills])
	hud.show_rewards(credits, 0, boosters)


# --- Controls (as in the waves) ------------------------------------------------

func _on_touch_look(relative: Vector2) -> void:
	if player.health > 0:
		player.look(relative, player.touch_sensitivity)


func _unhandled_input(event: InputEvent) -> void:
	# Desktop/web: the first click captures the mouse, later clicks fire.
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
		if event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.action_press("aim")
		else:
			Input.action_release("aim")
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F9 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		# Test shortcut: the foes fall.
		for enemy in get_tree().get_nodes_in_group("targets"):
			player.weapon.tag_kill(enemy)
			enemy.take_damage(9999)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F4 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		player.invulnerable = true


## A story mission ends: a banner, then the story screen.
func _end_story_mission(won: bool) -> void:
	hud.show_banner("MISSION ACCOMPLIE" if won else "MISSION ÉCHOUÉE")
	var stars := Story.stars_for_capture(_points[&"enemy"], WIN_SCORE)
	await get_tree().create_timer(2.5).timeout
	Story.finish(won, stars)
	get_tree().change_scene_to_file.call_deferred(Story.SCREEN)
