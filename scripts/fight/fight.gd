extends Node3D
## The fight mode (scenes/fight.tscn): two fighters on one line across an
## arena of the game, filmed from the side; best of three rounds of 60 s.
## FightSetup says who fights where; FightInput, FightPad and FightAI drive
## the fighters; FightSupers lists the supers, played here.
##
## Over the Wi-Fi (FightSetup.mode "online"), the host runs the whole fight:
## the other device sends what its player holds and draws the host's
## snapshots, the effects coming as RPCs (see _emit).

const ARENAS: Array[PackedScene] = [
	preload("res://scenes/arenas/station.tscn"),
	preload("res://scenes/arenas/desert.tscn"),
	preload("res://scenes/arenas/jungle.tscn"),
	preload("res://scenes/arenas/volcano.tscn"),
	preload("res://scenes/arenas/city.tscn"),
]
## Where the line runs in each arena: its middle (from the boss spawn point,
## plus this offset) and its direction. The camera stands on its +Z side
## (see _perp).
const LANES := [
	{"offset": Vector3.ZERO, "axis": Vector3.RIGHT},
	{"offset": Vector3.ZERO, "axis": Vector3.RIGHT},
	{"offset": Vector3.ZERO, "axis": Vector3.RIGHT},
	{"offset": Vector3.ZERO, "axis": Vector3.RIGHT},
	{"offset": Vector3.ZERO, "axis": Vector3.RIGHT},
]
const STAGE_HALF := 8.0
const MAX_GAP := 7.5
const START_GAP := 2.6
const ROUND_TIME := 60.0
const ROUNDS_TO_WIN := 2
const COLORS: Array[Color] = [Color(0.16, 0.9, 1.0), Color(1.0, 0.3, 0.85)]
const SHOT_SPEED := 9.0
const SHOT_DAMAGE := 7.0
const SHOT_HEIGHT := 1.25
const GOLD := Color(1.0, 0.8, 0.25)
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const SOUNDS := {
	"hit": "res://assets/audio/hit.wav",
	"shot": "res://assets/audio/shot.wav",
	"boom": "res://assets/audio/kenney/explosionCrunch_000.ogg",
	"laser": "res://assets/audio/kenney/laserRetro_001.ogg",
}

enum Phase { INTRO, FIGHT, ROUND_OVER, MATCH_OVER }

var fighters: Array[Fighter] = []
## Per fighter: a FightInput, a FightAI, or null (the other device's player).
var _sources: Array = [null, null]
var _remote_held := {}
var _remote_before := {}
var _arena: Node3D
var _arena_index := 0
var _origin := Vector3.ZERO
var _axis := Vector3.RIGHT
var _perp := Vector3.BACK
var _camera := Camera3D.new()
var _camera_target := Vector3.ZERO
var _layer := CanvasLayer.new()
var _hud := FightHud.new()
var _pads: Array[FightPad] = []
var _panel := PanelContainer.new()
var _phase := Phase.INTRO
var _round := 1
var _clock := ROUND_TIME
## Shots in flight: Dictionaries (see _spawn_projectile); their nodes by id.
var _projectiles: Array[Dictionary] = []
var _shot_nodes := {}
var _strikes: Array[Dictionary] = []
## [seconds left, Callable]: what a super does a little later.
var _later: Array[Array] = []
var _next_id := 1
var _hit_pause := 0.0
var _shake := 0.0
var _online := false
var _host := true
## The fighter this device plays online.
var _mine := 0
var _sounds := {}


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_online = FightSetup.mode == "online" and Net.is_online()
	_host = not _online or Net.is_host()
	_mine = 0 if _host else 1
	var index := FightSetup.arena
	if _online:
		var ids := Net.ids()
		FightSetup.heroes.assign([Net.players[ids[0]].hero, Net.players[ids[1]].hero])
		index = Net.seed_value % ARENAS.size()
		Net.left.connect(_on_net_left)
	elif FightSetup.is_arcade():
		index = FightSetup.arcade_arena()
	if index < 0:
		index = randi() % ARENAS.size()
	_load_arena(index)
	for i in 2:
		var fighter := Fighter.new()
		add_child(fighter)
		fighter.setup(FightSetup.hero_item(FightSetup.heroes[i]), COLORS[i])
		fighters.append(fighter)
		if _host:
			fighter.super_used.connect(_run_super)
			fighter.shot_fired.connect(_on_shot)
	fighters[0].opponent = fighters[1]
	fighters[1].opponent = fighters[0]
	add_child(_camera)
	_camera.fov = 50.0
	_camera.far = 300.0
	_camera.make_current()
	_build_overlay()
	_setup_sources()
	for name: String in SOUNDS:
		var player := AudioStreamPlayer.new()
		player.stream = load(SOUNDS[name])
		player.volume_db = -6.0
		add_child(player)
		_sounds[name] = player
	Music.play_track(Music.Track.BOSS if fighters[1].is_boss() else (_arena.get("music_track") as int))
	_place_camera(1.0)
	if _host:
		_start_round()


func _exit_tree() -> void:
	Engine.time_scale = 1.0


# --- Set-up -------------------------------------------------------------------

func _load_arena(index: int) -> void:
	_arena_index = index
	_arena = ARENAS[index].instantiate()
	add_child(_arena)
	var lane: Dictionary = LANES[index]
	_origin = (_arena.get_node("BossSpawn") as Node3D).global_position + lane.offset
	_axis = lane.axis
	_perp = _axis.cross(Vector3.UP)
	if _arena.has_method("apply_quality"):
		_arena.apply_quality(Settings.high_quality)
	_clear_stage()


## Hides what stands on the line or between it and the camera (crates,
## walls, trees): the floor and what is behind stay.
func _clear_stage() -> void:
	for node: GeometryInstance3D in _arena.find_children("*", "GeometryInstance3D", true, false):
		if node is MultiMeshInstance3D or node is GPUParticles3D or node is CPUParticles3D:
			continue
		var box := node.global_transform * node.get_aabb()
		if box.size.x > 40.0 or box.size.z > 40.0:
			continue
		if box.end.y < _origin.y + 0.25 or box.position.y > _origin.y + 7.0:
			continue
		var along := Vector2(INF, -INF)
		var across := Vector2(INF, -INF)
		for corner in 8:
			var offset := box.get_endpoint(corner) - _origin
			var a := offset.dot(_axis)
			var c := offset.dot(_perp)
			along = Vector2(minf(along.x, a), maxf(along.y, a))
			across = Vector2(minf(across.x, c), maxf(across.y, c))
		if along.y > -STAGE_HALF - 3.0 and along.x < STAGE_HALF + 3.0 and across.y > -1.5 and across.x < 12.0:
			node.visible = false


func _setup_sources() -> void:
	var touch := DisplayServer.is_touchscreen_available()
	match FightSetup.mode:
		"versus":
			for i in 2:
				var pad: FightPad = null
				if touch:
					pad = _add_pad(i + 1, COLORS[i])
				var keys: Array[int] = [i]
				var gamepads: Array[int] = [i]
				_sources[i] = FightInput.new(keys, gamepads, pad)
		"online":
			var pad: FightPad = _add_pad(0, COLORS[_mine]) if touch else null
			var keys: Array[int] = [0, 1]
			var gamepads: Array[int] = [0, 1, 2, 3]
			_sources[_mine] = FightInput.new(keys, gamepads, pad)
		_:
			var pad: FightPad = _add_pad(0, COLORS[0]) if touch else null
			var keys: Array[int] = [0, 1]
			var gamepads: Array[int] = [0, 1, 2, 3]
			_sources[0] = FightInput.new(keys, gamepads, pad)
			_sources[1] = FightAI.new(fighters[1], FightSetup.difficulty)


func _add_pad(half: int, color: Color) -> FightPad:
	var pad := FightPad.new(half, color)
	_layer.add_child(pad)
	_pads.append(pad)
	return pad


func _build_overlay() -> void:
	add_child(_layer)
	_layer.add_child(_hud)
	_hud.fighters = fighters
	_hud.rounds_to_win = ROUNDS_TO_WIN
	var pause := Button.new()
	pause.text = "II"
	pause.custom_minimum_size = Vector2(72, 56)
	pause.add_theme_font_size_override("font_size", 26)
	pause.anchor_left = 0.5
	pause.anchor_right = 0.5
	pause.offset_left = -36
	pause.offset_right = 36
	pause.offset_top = 92
	pause.offset_bottom = 148
	pause.focus_mode = Control.FOCUS_NONE
	pause.pressed.connect(_toggle_pause)
	_layer.add_child(pause)
	_panel.visible = false
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_layer.add_child(_panel)


# --- The match ----------------------------------------------------------------

func _start_round() -> void:
	_phase = Phase.INTRO
	_clock = ROUND_TIME
	for i in 2:
		fighters[i].reset(-START_GAP if i == 0 else START_GAP)
		fighters[i].facing = 1 if i == 0 else -1
	_clear_shots()
	var last := fighters[0].rounds_won == ROUNDS_TO_WIN - 1 and fighters[1].rounds_won == ROUNDS_TO_WIN - 1
	_announce("MANCHE FINALE" if last else "ROUND %d" % _round, 1.0, "%s  CONTRE  %s" % [
			str(fighters[0].hero.name).to_upper(), str(fighters[1].hero.name).to_upper()], GOLD)
	await _wait(1.5)
	_announce("COMBAT !", 0.6, "", Color.WHITE)
	_phase = Phase.FIGHT


func _end_round(winner: int, knockout: bool) -> void:
	_phase = Phase.ROUND_OVER
	_announce("K.O." if knockout else "TEMPS !", 1.2, "", Color(1.0, 0.3, 0.2) if knockout else GOLD)
	if knockout and not _online:
		Engine.time_scale = 0.35
		await _wait(1.0)
		Engine.time_scale = 1.0
	else:
		await _wait(1.0)
	if winner == -1:
		for fighter in fighters:
			fighter.rounds_won += 1
	else:
		fighters[winner].rounds_won += 1
		fighters[winner].win()
	await _wait(1.6)
	var done := fighters.filter(func(f: Fighter) -> bool: return f.rounds_won >= ROUNDS_TO_WIN)
	if done.is_empty():
		_round += 1
		_start_round()
		return
	var champion := 0
	if done.size() == 2:
		champion = 0 if fighters[0].health >= fighters[1].health else 1
	else:
		champion = fighters.find(done[0])
	_end_match(champion)


func _end_match(winner: int) -> void:
	_phase = Phase.MATCH_OVER
	fighters[winner].win()
	if _online:
		_show_end.rpc(winner)
	else:
		_show_end(winner)


@rpc("authority", "call_local", "reliable")
func _show_end(winner: int) -> void:
	_phase = Phase.MATCH_OVER
	var name := str(fighters[winner].hero.name).to_upper()
	var solo := FightSetup.mode in ["ai", "arcade"]
	var won := winner == (_mine if _online else 0)
	var title := ("VICTOIRE !" if won else "DÉFAITE") if solo or _online else "%s GAGNE !" % name
	var run_over := false
	var next_fight := false
	if FightSetup.is_arcade() and won:
		next_fight = FightSetup.next_arcade_fight()
		run_over = not next_fight
	var reward := FightSetup.reward(won, run_over)
	var lines: Array[String] = []
	if run_over:
		lines.append("Arcade terminée : le Titan est tombé !")
	elif FightSetup.is_arcade() and won:
		lines.append("Combat %d / %d gagné." % [FightSetup.arcade_stage, FightSetup.arcade_opponents.size()])
	if reward != "":
		lines.append("Gagné : " + reward)
	await _wait(1.2)
	var buttons: Array = []
	if _online:
		if _host:
			buttons.append(["REVANCHE", func() -> void: _rematch.rpc()])
		else:
			lines.append("L'hôte peut lancer une revanche.")
		buttons.append(["QUITTER", _quit])
	elif next_fight:
		buttons.append(["COMBAT SUIVANT  (%d / %d)" % [FightSetup.arcade_stage + 1, FightSetup.arcade_opponents.size()],
				func() -> void: get_tree().reload_current_scene()])
		buttons.append(["ABANDONNER", _quit])
	elif FightSetup.is_arcade() and not run_over:
		buttons.append(["RÉESSAYER", func() -> void: get_tree().reload_current_scene()])
		buttons.append(["ABANDONNER", _quit])
	else:
		if not run_over:
			buttons.append(["REVANCHE", func() -> void: get_tree().reload_current_scene()])
		buttons.append(["CHANGER DE COMBATTANT", _quit])
	_show_panel(title, "\n".join(lines), buttons, GOLD if won or not solo else Color(1.0, 0.4, 0.4))


@rpc("authority", "call_local", "reliable")
func _rematch() -> void:
	_panel.visible = false
	_round = 1
	for fighter in fighters:
		fighter.rounds_won = 0
	if _host:
		_start_round()


func _quit() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if _online:
		Net.leave()
		get_tree().change_scene_to_file.call_deferred("res://scenes/menu.tscn")
		return
	get_tree().change_scene_to_file.call_deferred(FightSetup.MENU)


func _on_net_left(reason: String) -> void:
	_show_panel("PARTIE TERMINÉE", reason, [["MENU", _quit]], Color(1.0, 0.4, 0.4))


func _toggle_pause() -> void:
	if _online:
		_show_panel("PAUSE", "Le combat continue en Wi-Fi.", [["REPRENDRE", func() -> void: _panel.visible = false],
				["QUITTER", _quit]], GOLD)
		return
	if _phase == Phase.MATCH_OVER:
		return
	if get_tree().paused:
		get_tree().paused = false
		_panel.visible = false
		return
	get_tree().paused = true
	_show_panel("PAUSE", _controls_text(), [["REPRENDRE", _toggle_pause], ["QUITTER", _quit]], GOLD)


func _controls_text() -> String:
	return "Garde : recule (ou bas + recule).\nBas + POING : uppercut · Bas + ARME : tir\nAvant + PIED : coup de pied sauté · SUPER quand la jauge est pleine.\nClavier : ZQSD + F G H, R pour le super (joueur 2 : flèches + J K L, I)."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _show_panel(title: String, text: String, buttons: Array, color: Color) -> void:
	for child in _panel.get_children():
		child.queue_free()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size.x = 560
	_panel.add_child(box)
	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 44)
	heading.add_theme_color_override("font_color", color)
	box.add_child(heading)
	if text != "":
		var body := Label.new()
		body.text = text
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_theme_font_size_override("font_size", 20)
		box.add_child(body)
	for entry: Array in buttons:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size.y = 66
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(entry[1])
		box.add_child(button)
	_panel.visible = true
	_panel.reset_size()
	_panel.position = (get_viewport().get_visible_rect().size - _panel.size) / 2.0


## Waits `seconds` of real time (slow motion included).
func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, false, false, true).timeout


func _announce(text: String, seconds: float, line: String, color: Color) -> void:
	if _online:
		_announce_rpc.rpc(text, seconds, line, color)
	else:
		_hud.announce(text, seconds, line, color)


@rpc("authority", "call_local", "reliable")
func _announce_rpc(text: String, seconds: float, line: String, color: Color) -> void:
	_hud.announce(text, seconds, line, color)


# --- Each step ----------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not _host:
		var mine: FightInput = _sources[_mine]
		_client_input.rpc_id(1, FightInput.pack(mine.held()))
		return
	if _hit_pause > 0.0:
		_hit_pause -= delta
		return
	if _phase == Phase.FIGHT:
		_clock -= delta
	for i in 2:
		var input := {"x": 0, "up": false, "down": false}
		if _phase == Phase.FIGHT:
			input = _read(i, delta)
		fighters[i].step(input, delta)
	_keep_apart()
	for i in 2:
		if fighters[i].is_hitting():
			_melee(fighters[i], fighters[1 - i])
	_run_projectiles(delta)
	_run_strikes(delta)
	for entry: Array in _later.duplicate():
		entry[0] -= delta
		if entry[0] <= 0.0:
			_later.erase(entry)
			(entry[1] as Callable).call()
	if _phase == Phase.FIGHT:
		for i in 2:
			if fighters[i].state == Fighter.State.KO:
				_end_round(1 - i, true)
				break
		if _phase == Phase.FIGHT and _clock <= 0.0:
			var shares := fighters.map(func(f: Fighter) -> float: return f.health / f.max_health)
			_end_round(-1 if is_equal_approx(shares[0], shares[1]) else (0 if shares[0] > shares[1] else 1), false)
	if _online:
		_snapshot.rpc(_snapshot_data())


func _read(index: int, delta: float) -> Dictionary:
	var source: Variant = _sources[index]
	if source is FightInput:
		return (source as FightInput).read()
	if source is FightAI:
		return (source as FightAI).read(delta)
	var input := FightInput.presses(_remote_held, _remote_before)
	_remote_before = _remote_held
	return input


@rpc("any_peer", "unreliable_ordered")
func _client_input(bits: int) -> void:
	if _host:
		_remote_held = FightInput.unpack(bits)


## Bodies do not overlap; both stay on the stage and within the camera's reach.
func _keep_apart() -> void:
	var a := fighters[0]
	var b := fighters[1]
	var least := a.body_width() + b.body_width()
	var gap := b.x - a.x
	if absf(gap) < least and absf(a.height - b.height) < 1.4:
		var push := (least - absf(gap)) / 2.0 * (1.0 if gap >= 0.0 else -1.0)
		if is_zero_approx(gap):
			push = least / 2.0 * (1.0 if a.facing > 0 else -1.0)
		a.x -= push
		b.x += push
	for fighter in fighters:
		fighter.x = clampf(fighter.x, -STAGE_HALF, STAGE_HALF)
		fighter.x = clampf(fighter.x, fighter.opponent.x - MAX_GAP, fighter.opponent.x + MAX_GAP)


func _melee(attacker: Fighter, target: Fighter) -> void:
	if target.invulnerable_left > 0.0 or target.state == Fighter.State.KO:
		return
	var move := attacker.move
	var ahead := (target.x - attacker.x) * attacker.facing
	var reach := float(move.reach) + target.body_width() + attacker.body_width() * 0.5
	if ahead < -0.3 or ahead > reach:
		return
	var vertical := float(move.get("air_reach", 1.4)) + (1.2 if attacker.is_boss() else 0.0)
	if absf(target.height - attacker.height) > vertical:
		return
	attacker.move_hit = true
	var damage := float(move.damage) * attacker.damage_scale()
	var landed := target.take_hit(damage, float(move.stun), float(move.push), attacker.x,
			move.get("knockdown", false), move.get("launch", false))
	attacker.meter = minf(attacker.meter + (damage * 0.9 if landed else 3.0), Fighter.METER_MAX)
	var at := _world(target.x - attacker.facing * 0.2, target.height + 1.2)
	if landed:
		_emit("burst", [at, Color(1.0, 0.85, 0.5), 18 if damage < 9.0 else 32])
		_emit("damage", [at, int(round(damage))])
		_emit("sound", ["hit"])
		_hit_pause = 0.05 if damage < 9.0 else 0.1
		_emit("shake", [0.05 + damage * 0.01])
	else:
		_emit("burst", [at, Color(0.5, 0.8, 1.0), 10])


## A world point on the line: `along` it, `up` above the ground.
func _world(along: float, up: float) -> Vector3:
	return _origin + _axis * along + Vector3.UP * up


# --- Shots --------------------------------------------------------------------

## The weapon's shot (down + weapon): a ball of light at chest height; the
## Titan's runs along the ground instead (jump over it).
func _on_shot(fighter: Fighter) -> void:
	var damage := SHOT_DAMAGE * fighter.damage_scale()
	if fighter.is_boss():
		_spawn_projectile(fighter, {"y": 0.3, "speed": 8.0, "damage": 14.0, "size": 0.35, "color": Color(1.0, 0.5, 0.1), "kind": "wave", "knockdown": true})
	else:
		_spawn_projectile(fighter, {"y": SHOT_HEIGHT, "speed": SHOT_SPEED, "damage": damage, "size": 0.14, "color": fighter.color, "kind": "orb"})
	_emit("sound", ["shot"])


## `spec`: y, speed, damage, size, color, kind ("orb", "wave", "clone",
## "bomb"), and optionally arc (falls, explodes), knockdown, curse.
func _spawn_projectile(owner: Fighter, spec: Dictionary) -> void:
	var id := _next_id
	_next_id += 1
	var shot := {
		"id": id, "owner": fighters.find(owner), "x": owner.x + owner.facing * 0.6, "y": owner.height + float(spec.y),
		"vx": owner.facing * float(spec.speed), "vy": 4.5 if spec.get("arc", false) else 0.0,
		"damage": spec.damage, "size": spec.size, "arc": spec.get("arc", false), "knockdown": spec.get("knockdown", false),
		"curse": spec.get("curse", 0.0), "kind": spec.kind, "life": 3.0, "color": spec.color,
	}
	_projectiles.append(shot)
	_emit("projectile", [id, spec.kind, spec.color, float(spec.size), str(owner.hero.id) if spec.kind == "clone" else ""])


func _run_projectiles(delta: float) -> void:
	for shot: Dictionary in _projectiles.duplicate():
		shot.x += shot.vx * delta
		if shot.arc:
			shot.vy -= Fighter.GRAVITY * 0.6 * delta
		shot.y += shot.vy * delta
		shot.life -= delta
		var target := fighters[1 - int(shot.owner)]
		var gone: bool = shot.life <= 0.0 or absf(shot.x) > STAGE_HALF + 4.0
		if shot.arc and shot.y <= 0.0:
			_explode(shot, target)
			gone = true
		elif not gone and _touches(shot, target):
			if shot.arc:
				_explode(shot, target)
			else:
				var landed := target.take_hit(shot.damage, 0.4, 3.0, shot.x - signf(shot.vx), shot.knockdown)
				if landed and float(shot.curse) > 0.0:
					target.curse_left = float(shot.curse)
				fighters[int(shot.owner)].meter = minf(fighters[int(shot.owner)].meter + (6.0 if landed else 2.0), Fighter.METER_MAX)
				_emit("burst", [_world(shot.x, shot.y), shot.color, 22])
				if landed:
					_emit("damage", [_world(shot.x, shot.y + 0.4), int(round(float(shot.damage)))])
				_emit("sound", ["hit"])
			gone = shot.kind != "clone"
		# Two shots meeting cancel out (the Titan's wave and the clones go through).
		if not gone and shot.kind == "orb":
			for other: Dictionary in _projectiles:
				if other != shot and other.owner != shot.owner and other.kind == "orb" and absf(other.x - shot.x) < 0.4 \
						and absf(other.y - shot.y) < 0.4:
					other.life = 0.0
					gone = true
					_emit("burst", [_world(shot.x, shot.y), Color.WHITE, 16])
		if gone:
			_projectiles.erase(shot)
			_drop_shot_node(shot.id)


func _touches(shot: Dictionary, target: Fighter) -> bool:
	if target.invulnerable_left > 0.0 or target.state == Fighter.State.KO:
		return false
	if shot.kind == "clone" and shot.get("hit", false):
		return false
	if absf(target.x - shot.x) > float(shot.size) + target.body_width():
		return false
	var reach := 0.9 if shot.kind == "clone" else float(shot.size)
	var touched: bool = shot.y + reach > target.height and shot.y - reach < target.height + target.body_height()
	if touched and shot.kind == "clone":
		shot["hit"] = true
	return touched


func _explode(shot: Dictionary, target: Fighter) -> void:
	_emit("burst", [_world(shot.x, maxf(shot.y, 0.3)), shot.color, 40])
	_emit("sound", ["boom"])
	_emit("shake", [0.3])
	if absf(target.x - shot.x) < 1.8 and target.height < 1.6 and target.invulnerable_left <= 0.0 and target.state != Fighter.State.KO:
		if target.take_hit(shot.damage, 0.5, 6.0, shot.x, true):
			_emit("damage", [_world(target.x, target.height + 1.6), int(round(float(shot.damage)))])


func _clear_shots() -> void:
	for shot in _projectiles:
		_drop_shot_node(shot.id)
	_projectiles.clear()
	_strikes.clear()
	_later.clear()


# --- Supers -------------------------------------------------------------------

func _run_super(fighter: Fighter) -> void:
	var info := FightSupers.of(fighter)
	var power := FightSupers.power(fighter)
	var target := fighter.opponent
	var color: Color = info.color
	_announce(FightSupers.name_of(fighter).to_upper(), 0.7, str(fighter.hero.name).to_upper(), color)
	_emit("burst", [_world(fighter.x, 1.2), color, 50])
	_emit("sound", ["laser"])
	_hit_pause = 0.35
	match info.kind:
		"projectiles":
			for i in int(info.count):
				_after(0.2 + float(info.every) * i, func() -> void:
					_spawn_projectile(fighter, {"y": 1.1, "speed": info.speed, "damage": float(info.damage) * power,
							"size": info.get("size", 0.16), "color": color, "kind": "bomb" if info.get("arc", false) else "orb",
							"arc": info.get("arc", false), "knockdown": info.get("arc", false)})
					_emit("sound", ["shot"]))
		"strikes":
			var spread: float = info.spread
			for i in int(info.count):
				var x := target.x + (randf_range(-spread, spread) if int(info.count) > 3 else (i - 1) * spread)
				_strike(fighter, x, 0.6 + 0.18 * i, float(info.damage) * power, color)
		"beam":
			_after(float(info.delay), func() -> void: _beam(fighter, float(info.damage) * power, color))
		"move":
			fighter.state = Fighter.State.IDLE
			fighter.start_super_move(info.move, float(info.damage) * power)
		"clones":
			for i in int(info.count):
				_after(0.15 + 0.3 * i, func() -> void:
					_spawn_projectile(fighter, {"y": 0.0, "speed": 11.0, "damage": float(info.damage) * power, "size": 0.5,
							"color": color, "kind": "clone"}))
		"freeze":
			_after(0.3, func() -> void:
				if target.state != Fighter.State.KO:
					target.freeze(float(info.seconds))
				_emit("burst", [_world(target.x, 1.2), color, 60]))
		"rage":
			fighter.rage_left = float(info.seconds)
		"heal":
			fighter.health = minf(fighter.health + fighter.max_health * float(info.share), fighter.max_health)
			_strike(fighter, target.x, 0.6, float(info.damage) * power, color)
		"curse":
			_after(0.2, func() -> void:
				_spawn_projectile(fighter, {"y": 1.1, "speed": 6.0, "damage": float(info.damage) * power, "size": 0.3,
						"color": color, "kind": "orb", "curse": float(info.seconds)}))


func _after(seconds: float, action: Callable) -> void:
	_later.append([seconds, action])


## A blow from the sky at `x` in `seconds`, its spot marked on the ground.
func _strike(owner: Fighter, x: float, seconds: float, damage: float, color: Color) -> void:
	_strikes.append({"owner": fighters.find(owner), "x": x, "left": seconds, "damage": damage, "color": color})
	_emit("strike", [_world(x, 0.05), color, seconds])


func _run_strikes(delta: float) -> void:
	for strike: Dictionary in _strikes.duplicate():
		strike.left -= delta
		if strike.left > 0.0:
			continue
		_strikes.erase(strike)
		_emit("burst", [_world(strike.x, 0.4), strike.color, 36])
		_emit("sound", ["boom"])
		_emit("shake", [0.2])
		var target := fighters[1 - int(strike.owner)]
		if absf(target.x - strike.x) < 1.1 + target.body_width() and target.height < 2.0 \
				and target.invulnerable_left <= 0.0 and target.state != Fighter.State.KO:
			if target.take_hit(strike.damage, 0.45, 3.0, strike.x, false):
				_emit("damage", [_world(target.x, target.height + 1.6), int(round(float(strike.damage)))])


func _beam(owner: Fighter, damage: float, color: Color) -> void:
	_emit("beam", [_world(owner.x + owner.facing * 0.5, owner.height + 1.2), _axis * owner.facing, color])
	_emit("sound", ["laser"])
	_emit("shake", [0.35])
	var target := owner.opponent
	if (target.x - owner.x) * owner.facing > 0.0 and target.height < 2.4 and target.invulnerable_left <= 0.0 \
			and target.state != Fighter.State.KO:
		if target.take_hit(damage, 0.6, 6.0, owner.x, true):
			_emit("damage", [_world(target.x, target.height + 1.6), int(round(damage))])
			_emit("burst", [_world(target.x, 1.2), color, 50])


# --- Effects (on every device) ------------------------------------------------

func _emit(kind: String, args: Array) -> void:
	if _online:
		_fx.rpc(kind, args)
	else:
		_fx(kind, args)


@rpc("authority", "call_local", "reliable")
func _fx(kind: String, args: Array) -> void:
	match kind:
		"burst":
			Effects.burst(self, args[0], args[1], args[2])
		"damage":
			Effects.damage_number(self, args[0], args[1], Color(1.0, 0.85, 0.3), args[1] >= 15)
		"sound":
			(_sounds[args[0]] as AudioStreamPlayer).play()
		"shake":
			_shake = maxf(_shake, float(args[0]))
			if Settings.vibration_enabled:
				Input.vibrate_handheld(int(30 + 80 * float(args[0])))
		"projectile":
			_make_shot_node(args[0], args[1], args[2], args[3], args[4])
		"strike":
			_make_strike(args[0], args[1], args[2])
		"beam":
			_make_beam(args[0], args[1], args[2])


func _make_shot_node(id: int, kind: String, color: Color, size: float, hero_id: String) -> void:
	var node: Node3D
	if kind == "clone":
		var item := FightSetup.hero_item(hero_id)
		var instance: Node3D = load(Loadout.CHARACTER_DIR + str(item.model)).instantiate()
		instance.set_script(CharacterModel)
		var model := instance as CharacterModel
		node = Node3D.new()
		node.add_child(model)
		model.play(&"melee", true, 1.5)
		var ghost := StandardMaterial3D.new()
		ghost.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ghost.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ghost.albedo_color = Color(color, 0.55)
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			mesh.material_override = ghost
	else:
		var mesh := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = size
		sphere.height = size * (0.8 if kind == "wave" else 2.0)
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color.lightened(0.3)
		mesh.material_override = material
		mesh.mesh = sphere
		if kind == "wave":
			mesh.scale = Vector3(3.0, 1.0, 1.0)
		node = mesh
		var light := OmniLight3D.new()
		light.light_color = color
		light.omni_range = 2.5
		light.light_energy = 2.0
		node.add_child(light)
	add_child(node)
	_shot_nodes[id] = node


func _drop_shot_node(id: int) -> void:
	if _shot_nodes.has(id):
		(_shot_nodes[id] as Node).queue_free()
		_shot_nodes.erase(id)


func _make_strike(at: Vector3, color: Color, seconds: float) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.1
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	ring.material_override = material
	ring.scale = Vector3(1, 0.05, 1)
	add_child(ring)
	ring.global_position = at
	var bomb := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.6
	bomb.mesh = sphere
	bomb.material_override = material
	add_child(bomb)
	bomb.global_position = at + Vector3.UP * 9.0
	var tween := create_tween()
	tween.tween_property(bomb, "global_position", at, seconds).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(bomb.queue_free)
	tween.tween_callback(ring.queue_free)


func _make_beam(from: Vector3, direction: Vector3, color: Color) -> void:
	var beam := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 24.0)
	beam.mesh = box
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color.lightened(0.4), 0.9)
	beam.material_override = material
	add_child(beam)
	beam.global_position = from + direction * 12.0
	beam.look_at(beam.global_position + direction, Vector3.UP)
	var tween := create_tween()
	tween.tween_property(beam, "scale", Vector3(0.1, 0.1, 1.0), 0.5)
	tween.tween_callback(beam.queue_free)


# --- Network ------------------------------------------------------------------

func _snapshot_data() -> Array:
	var shots: Array = []
	for shot in _projectiles:
		shots.append([shot.id, shot.x, shot.y])
	return [fighters[0].snapshot(), fighters[1].snapshot(), _clock, shots]


@rpc("authority", "unreliable_ordered")
func _snapshot(data: Array) -> void:
	fighters[0].apply_snapshot(data[0])
	fighters[1].apply_snapshot(data[1])
	_clock = data[2]
	var seen := {}
	for entry: Array in data[3]:
		seen[entry[0]] = true
		if _shot_nodes.has(entry[0]):
			(_shot_nodes[entry[0]] as Node3D).global_position = _world(entry[1], entry[2])
	for id: int in _shot_nodes.keys():
		if not seen.has(id):
			_drop_shot_node(id)


# --- Drawing ------------------------------------------------------------------

func _process(delta: float) -> void:
	for fighter in fighters:
		fighter.show_on(_origin, _axis)
	if _host:
		for shot in _projectiles:
			if _shot_nodes.has(shot.id):
				var node: Node3D = _shot_nodes[shot.id]
				node.global_position = _world(shot.x, shot.y)
				if shot.kind == "clone":
					node.global_basis = Basis.looking_at(_axis * signf(shot.vx), Vector3.UP)
	_hud.clock = _clock
	for pad in _pads:
		var index := _mine if _online else _pads.find(pad)
		pad.super_ready = fighters[index].meter >= Fighter.METER_MAX
	_place_camera(minf(delta * 4.0, 1.0))


func _place_camera(weight: float) -> void:
	var a := fighters[0]
	var b := fighters[1]
	var middle := (a.x + b.x) / 2.0
	var gap := absf(a.x - b.x)
	var boss := a.is_boss() or b.is_boss()
	var distance := clampf(4.4 + gap * 0.6, 5.2, 9.5) + (2.0 if boss else 0.0)
	var target := _world(middle, 1.25 + (0.7 if boss else 0.0) + maxf(a.height, b.height) * 0.3)
	_camera_target = _camera_target.lerp(target, weight) if weight < 1.0 else target
	var wanted := _camera_target + _perp * distance + Vector3.UP * 0.45
	_camera.global_position = _camera.global_position.lerp(wanted, weight) if weight < 1.0 else wanted
	_shake = move_toward(_shake, 0.0, get_process_delta_time() * 1.5)
	var jitter := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * _shake * 0.25
	_camera.look_at(_camera_target + jitter, Vector3.UP)
