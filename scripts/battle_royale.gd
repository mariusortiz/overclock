extends Node3D
## Battle royale on the island: the player and 23 bots, everyone for
## themselves, no coming back. The safe zone (StormZone) shrinks in steps;
## weapon crates fall from the sky inside it. The player first chooses where
## to jump. The last one standing wins; the XP follows the placement and the
## eliminations.

const MENU_SCENE := "res://scenes/menu.tscn"
const ARENA := preload("res://scenes/arenas/island.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const FIGHTERS := 24
const BOT_HEALTH := 60
const BOT_SPEED := 4.0
const BOT_FIRE_INTERVAL := 0.9
const BOT_RANGE := 18.0
const BOT_WEAPONS := ["heavy", "smg", "blaster", "rifle_2", "smg_2", "revolver_1"]
const KILL_SCORE := 150
const PLACE_SCORE := 80
const WIN_BONUS := 2500
const JUMP_HEIGHT := 28.0
const CRATE_INTERVAL := 15.0
## Where the player can jump: [name, x, z].
const DROPS := [["LA VILLE", 0.0, 4.0], ["LES RUINES", -42.0, -30.0], ["LES CRISTAUX", 38.0, -32.0],
		["LES HUTTES", -40.0, 26.0], ["LES DOCKS", 36.0, 38.0]]

var score := 0
var _arena: Arena
var _storm := StormZone.new()
var _over := false
var _kills := 0
var _alive := FIGHTERS
var _pet: Pet
var _drop_panel := Control.new()
var _crate_left := CRATE_INTERVAL

@onready var player: Player = $Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	_arena = ARENA.instantiate()
	add_child(_arena)
	move_child(_arena, 0)
	Music.play_track(_arena.music_track)
	_arena.apply_quality(Settings.high_quality)
	Weather.apply(_arena)
	# Weapons come from the crates; the island's chests are not for this mode.
	for chest in get_tree().get_nodes_in_group("chests"):
		chest.queue_free()
	add_child(_storm)
	_storm.step_started.connect(_on_storm_step)

	Pets.enabled = true
	Pets.in_game = true
	player.move_speed *= Pets.speed_factor()
	if Pets.selected().id != Pets.NONE.id:
		_pet = Pet.new()
		_pet.configure(Pets.selected(), player)
		add_child(_pet)

	hud.touch_controls.look.connect(_on_touch_look)
	hud.replay_pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	hud.menu_pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	hud.quit_pressed.connect(_finish.bind(false))
	hud.dance_chosen.connect(player.dance)
	player.weapon.hit_confirmed.connect(hud.reticle.show_hit)
	player.melee.hit_confirmed.connect(hud.reticle.show_hit)
	player.weapon.ammo_changed.connect(hud.set_ammo)
	player.ultimate.charge_changed.connect(hud.set_ultimate)
	player.health_changed.connect(hud.set_health)
	player.damaged.connect(hud.flash_damage)
	player.hurt_from.connect(hud.show_hurt_from)
	player.died.connect(_finish.bind(false))
	hud.set_ultimate(0.0)
	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.weapon.ammo, player.weapon.get_magazine_size(), false)
	hud.set_score(score)

	if not _arena.is_navigation_ready:
		await _arena.navigation_ready
	# The bots land all over the island, apart from one another.
	var spots: Array[Vector3] = []
	var attempts := 0
	while spots.size() < FIGHTERS - 1 and attempts < 2000:
		attempts += 1
		var at := _storm.random_point(0.95)
		var closest := NavigationServer3D.map_get_closest_point(_arena.get_navigation_map(), at)
		if closest.distance_to(Vector3(at.x, closest.y, at.z)) > 1.0:
			continue
		if spots.any(func(other: Vector3) -> bool: return other.distance_to(closest) < 16.0):
			continue
		spots.append(closest + Vector3.UP * 0.2)
	for at in spots:
		_spawn_bot(at)
	_alive = spots.size() + 1
	_refresh_top()
	# Test option: "-- --drop=0" jumps at once over that place.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--drop="):
			_jump(argument.get_slice("=", 1).to_int())
			return
	_show_drop_choice()


func _process(delta: float) -> void:
	hud.reticle.on_target = player.aiming_at_enemy
	if Input.is_action_just_pressed("emote") and player.health > 0:
		hud.toggle_dance_wheel()
	if _over or _drop_panel.visible:
		return
	_crate_left -= delta
	if _crate_left <= 0.0:
		_crate_left = CRATE_INTERVAL
		_drop_crate()


# --- The jump -------------------------------------------------------------------

## Before anything, the player picks where to land; meanwhile the game waits.
func _show_drop_choice() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_drop_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_drop_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(_drop_panel)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drop_panel.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drop_panel.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)
	var title := Label.new()
	title.text = "OÙ SAUTER ?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.16, 0.83, 1.0))
	box.add_child(title)
	var hint := Label.new()
	hint.text = "%d combattants · un seul gagnant · la zone violette rétrécit" % FIGHTERS
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 20)
	box.add_child(hint)
	for index in DROPS.size():
		var button := Button.new()
		button.text = DROPS[index][0]
		button.custom_minimum_size = Vector2(460, 64)
		button.add_theme_font_size_override("font_size", 26)
		button.pressed.connect(_jump.bind(index))
		box.add_child(button)


func _jump(index: int) -> void:
	_drop_panel.visible = false
	get_tree().paused = false
	player.global_position = Vector3(DROPS[index][1], JUMP_HEIGHT, DROPS[index][2])
	player.velocity = Vector3.ZERO
	hud.show_banner("SAUT : %s" % DROPS[index][0])


# --- Fighters -------------------------------------------------------------------

func _spawn_bot(at: Vector3) -> void:
	var bot := ENEMY_SCENE.instantiate()
	var bolt: PackedScene = bot.projectile_scene
	var power_up: PackedScene = bot.power_up_scene
	bot.set_script(BrBot)
	var fighter := bot as BrBot
	fighter.projectile_scene = bolt
	fighter.power_up_scene = power_up
	fighter.storm = _storm
	fighter.max_health = BOT_HEALTH
	fighter.move_speed = BOT_SPEED
	fighter.fire_interval = BOT_FIRE_INTERVAL
	fighter.attack_range = BOT_RANGE
	fighter.drop_chance = 0.15
	var heroes := Loadout.CHARACTERS.filter(func(item: Dictionary) -> bool:
		return not item.get("shop", false) and not item.get("code", false))
	fighter.model_scene = load(Loadout.CHARACTER_DIR + str(heroes.pick_random().model))
	fighter.weapon_id = BOT_WEAPONS.pick_random()
	fighter.position = at
	add_child(fighter)
	fighter.died.connect(_on_bot_died.bind(fighter))


func _on_bot_died(bot: BrBot) -> void:
	_alive -= 1
	if bot._kill_style != &"":
		# Its last hit came from the player.
		_kills += 1
		score += KILL_SCORE
		hud.set_score(score)
		player.on_enemy_killed()
		hud.reticle.show_kill()
		if _pet:
			_pet.cheer()
	_refresh_top()
	if _alive == 1 and player.health > 0:
		_finish(true)


func _drop_crate() -> void:
	var crate := SupplyCrate.new()
	var at := _storm.random_point(0.8)
	crate.position = Vector3(at.x, 0, at.z)
	crate.collected.connect(player.weapon.equip_temporary)
	add_child(crate)


func _on_storm_step(index: int) -> void:
	if index > 0:
		hud.show_banner("LA ZONE RÉTRÉCIT")


func _refresh_top() -> void:
	hud.set_mode_text("EN VIE %d  ·  ÉLIMINATIONS %d" % [_alive, _kills])


# --- End ------------------------------------------------------------------------

func _finish(won: bool) -> void:
	if _over:
		return
	_over = true
	var place := 1 if won else _alive
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for bot in get_tree().get_nodes_in_group("br_fighters"):
		bot.process_mode = Node.PROCESS_MODE_DISABLED
	Input.action_release("fire")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	score += PLACE_SCORE * (FIGHTERS - place) + (WIN_BONUS if won else 0)
	if won:
		Achievements.set_flag("royale_win")
		hud.show_banner("TOP 1 !")
	var xp := BattlePass.xp_for_score(score)
	var credits := Wallet.credits_for_score(score)
	var unlocked := []
	var tier_before: int = BattlePass.progress().tier
	for id in BattlePass.add_xp(xp):
		unlocked.append(Loadout.find(id).item.name)
	Wallet.add_credits(credits)
	var boosters := Cards.reward_game(score, tier_before)
	hud.show_game_over(score, score, false, xp, unlocked, Hud.Result.TEAM_WIN if won else Hud.Result.DEFEAT)
	hud.set_result_line("Place : %d / %d  ·  %d éliminations" % [place, FIGHTERS, _kills])
	hud.show_rewards(credits, 0, boosters)


func _on_touch_look(relative: Vector2) -> void:
	if player.health > 0:
		player.look(relative, player.touch_sensitivity)
