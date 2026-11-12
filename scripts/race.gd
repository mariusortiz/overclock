extends Node3D
## Combat race: the player and five computer pilots, three laps of a circuit
## in space. Gates fill the boost gauge, pads boost on their own, lasers slow
## down (and, after three hits, destroy for a moment) the ship they hit.

const MENU_SCENE := "res://scenes/menu.tscn"
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const LAPS := 3
const PILOTS := [
	["TOI", Color(0.16, 0.9, 1.0), 1.0],
	["VIPÈRE", Color(1.0, 0.25, 0.2), 1.03],
	["NOVA", Color(1.0, 0.8, 0.25), 1.0],
	["ÉCLAIR", Color(0.4, 1.0, 0.4), 0.98],
	["SPECTRE", Color(0.75, 0.45, 1.0), 0.96],
	["COMÈTE", Color(1.0, 0.5, 0.15), 0.94],
]
const COUNTDOWN := 3
const LASER_INTERVAL := 0.22
const LASER_RANGE := 90.0
## How far off the aim (across the track) a laser still hits.
const LASER_WIDTH := 2.6
const AI_FIRE_INTERVAL := 1.1
const AI_ACCURACY := 0.55
const GATE_CHARGE := 0.12
## Specials: how long, how far.
const SPECIAL_TIME := 4.0
const SALVO_RANGE := 150.0
const MISSILE_RANGE := 250.0
const EMP_RANGE := 45.0
const EMP_STUN := 2.0
const WARP_DISTANCE := 70.0
const MINE_RADIUS := 2.8
const MINE_STUN := 1.2
const PAD_RADIUS := 3.0
const SHIP_RADIUS := 1.6
const PLACE_SCORES := [3000, 2200, 1600, 1200, 900, 600]
const CAMERA_BACK := 9.0
const CAMERA_UP := 3.0
## Network play: states sent per second, and how long the host waits for
## every device to be ready before starting anyway.
const SEND_RATE := 15.0
const READY_TIMEOUT := 8.0

var _track := RaceTrack.new()
var _ships: Array[RaceShip] = []
var _player: RaceShip
var _camera := Camera3D.new()
var _clock := 0.0
var _started := false
var _over := false
var _paused := false
var _laser_left := 0.0
var _ai_fire_left := {}
## Per ship, the last gate and pad it went through (indices), to count each once.
var _passed := {}
var _online := false
var _send_left := 0.0
var _ready_peers := {}
## Mines on the track: [distance, offset, node, ship that laid it].
var _mines: Array[Array] = []

var _layer := CanvasLayer.new()
var _touch := TouchControls.new()
var _place_label := Label.new()
var _lap_label := Label.new()
var _speed_label := Label.new()
var _center_label := Label.new()
var _boost_bar := ProgressBar.new()
var _shield_label := Label.new()
var _end_panel := PanelContainer.new()
var _end_text := Label.new()
var _pause_panel := PanelContainer.new()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.RACE)
	_build_world()
	_online = Net.is_online()
	var seed_value := Net.seed_value if _online else randi()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--track="):
			seed_value = argument.get_slice("=", 1).to_int()
	_track.build(seed_value)
	add_child(_track)
	# Each pilot flies a different ship: the player the one chosen in the
	# armory, the computers the others, shuffled with the track's seed.
	var others := Loadout.SHIPS.filter(func(item: Dictionary) -> bool: return item.id != Loadout.selected_ship().id)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(others.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: Dictionary = others[i]
		others[i] = others[j]
		others[j] = swap
	for i in PILOTS.size():
		var ship := RaceShip.new()
		ship.configure(Loadout.selected_ship() if i == 0 else others[(i - 1) % others.size()])
		ship.display_name = PILOTS[i][0]
		ship.color = PILOTS[i][1]
		ship.skill = PILOTS[i][2]
		ship.is_player = i == 0
		if _online:
			# The players first (in the same order everywhere), then computers.
			var ids := Net.ids()
			ship.is_player = false
			if i < ids.size():
				var info: Dictionary = Net.players[ids[i]]
				ship.peer_id = ids[i]
				ship.display_name = info.name
				ship.configure(Loadout.find(info.get("ship", "ship_dart")).item)
				ship.skill = 1.0
				ship.is_player = ids[i] == Net.my_id()
			ship.remote = not ship.is_player and not (ship.peer_id == 0 and Net.is_host())
		# Grid: two columns, the player last.
		var row := PILOTS.size() - 1 - i
		ship.distance = -6.0 - row * 7.0
		ship.offset = Vector2(-4.0 if row % 2 else 4.0, 0)
		add_child(ship)
		_ships.append(ship)
		_ai_fire_left[ship] = randf_range(1.0, 3.0)
		_passed[ship] = {"gate": 0, "pad": -1}
		ship.fly(0.0, Vector2.ZERO, _track)
	_player = _ships[0]
	for ship in _ships:
		if ship.is_player:
			_player = ship
	add_child(_camera)
	_camera.make_current()
	_camera.far = 2500.0
	_build_ui()
	_place_camera(0.0)
	_refresh_ui()
	if _online:
		Net.left.connect(func(reason: String) -> void:
			_show_center(reason, 3.0)
			get_tree().create_timer(2.5).timeout.connect(_quit))
		if Net.is_host():
			_ready_peers[1] = true
			get_tree().create_timer(READY_TIMEOUT).timeout.connect(_begin_if_waiting)
		else:
			_ready_to_race.rpc_id(1)
		_show_center("EN ATTENTE…")
	else:
		_countdown()


func _build_world() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.01, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.5, 0.5, 0.7)
	environment.ambient_light_energy = 0.8
	environment.glow_enabled = Settings.high_quality
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 40, 0)
	add_child(sun)


func _countdown() -> void:
	for i in range(COUNTDOWN, 0, -1):
		_show_center(str(i))
		await get_tree().create_timer(1.0, false).timeout
	_show_center("GO !")
	_started = true
	await get_tree().create_timer(0.8, false).timeout
	if _center_label.text == "GO !":
		_center_label.text = ""


func _physics_process(delta: float) -> void:
	if not _started or (_paused and not _online):
		_place_camera(delta)
		return
	if not _over:
		_clock += delta
	_steer_player(delta)
	_steer_computers(delta)
	for ship in _ships:
		if ship.remote:
			ship.follow_state(delta, _track)
	_bump_ships()
	for ship in _ships:
		if not ship.remote:
			_check_track(ship)
	if _online:
		_send_states(delta)
	_check_mines()
	_check_finish()
	_place_camera(delta)
	_refresh_ui()


# --- Pilots -------------------------------------------------------------------

func _steer_player(delta: float) -> void:
	var steer := Vector2.ZERO
	if not _over:
		steer = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_back", "move_forward"))
		if Input.is_action_just_pressed("ultimate") and _player.boost_charge >= 1.0 and _player.is_flying():
			_trigger_special(_player)
		_laser_left -= delta
		if (Input.is_action_pressed("fire") or Input.is_action_pressed("jump")) and _laser_left <= 0.0 and _player.is_flying():
			_laser_left = LASER_INTERVAL / _player.fire_rate
			_fire(_player, 1.0)
	_player.fly(delta, steer, _track)


## The computers aim for the next boost pad, weave a little, close the gap on
## a player who leads (and ease off when far ahead), and shoot at the ship
## right in front of them.
func _steer_computers(delta: float) -> void:
	for ship in _ships:
		if ship == _player or ship.remote or ship.peer_id != 0:
			continue
		var goal := Vector2(sin(_clock * 0.7 + ship.skill * 9.0) * RaceTrack.HALF_WIDTH * 0.5, 0)
		for pad: Array in _track.pads:
			var ahead := fposmod(pad[0] - ship.distance, _track.length)
			if ahead > 10.0 and ahead < 120.0:
				goal = pad[1]
				break
		var steer := (goal - ship.offset).limit_length(1.0)
		var gap := _player.distance - ship.distance
		ship.skill = PILOTS[_ships.find(ship)][2] * (1.06 if gap > 60.0 else (0.95 if gap < -80.0 else 1.0))
		if ship.boost_charge >= 1.0 and randf() < 0.01 and ship.is_flying():
			_trigger_special(ship)
		ship.fly(delta, steer, _track)
		_ai_fire_left[ship] -= delta
		if _ai_fire_left[ship] <= 0.0 and ship.is_flying():
			_ai_fire_left[ship] = AI_FIRE_INTERVAL * randf_range(0.7, 1.4) / ship.fire_rate
			_fire(ship, AI_ACCURACY)


## A laser straight ahead: the first ship in its path within range is hit
## (with `accuracy`, the chance a computer's aim is good).
func _fire(shooter: RaceShip, accuracy: float) -> void:
	var target: RaceShip = null
	var best := LASER_RANGE
	for ship in _ships:
		if ship == shooter or not ship.is_flying() or ship.is_untouchable():
			continue
		var ahead := ship.distance - shooter.distance
		if ahead > 0.0 and ahead < best and ship.offset.distance_to(shooter.offset) < LASER_WIDTH:
			target = ship
			best = ahead
	# Computers only bother when there is someone to hit.
	if target == null and not shooter.is_player:
		return
	var from := shooter.global_position - shooter.global_basis.z * 2.0
	var to := from - shooter.global_basis.z * LASER_RANGE
	if target and randf() < accuracy:
		to = target.global_position
		if _online:
			_hit.rpc(_ships.find(target))
		else:
			target.hit()
		if shooter == _player:
			_show_center("TOUCHÉ" if target.is_flying() else "DÉTRUIT !", 0.5)
	Effects.tracer(self, from, to, shooter.color.lerp(Color.WHITE, 0.3))


## The gauge is full: the ship's special (online, on every device at once).
func _trigger_special(ship: RaceShip) -> void:
	ship.boost_charge = 0.0
	if _online:
		_special.rpc(_ships.find(ship))
	else:
		_apply_special(ship)


@rpc("any_peer", "call_local", "reliable")
func _special(index: int) -> void:
	if index >= 0 and index < _ships.size():
		_apply_special(_ships[index])


func _apply_special(ship: RaceShip) -> void:
	var info: Array = Loadout.SHIP_SPECIALS[ship.special]
	if ship == _player:
		_show_center(info[0] + " !", 1.0)
	Effects.flash(self, ship.global_position, ship.color, 8.0, 0.4)
	match ship.special:
		&"surboost":
			ship.boost(SPECIAL_TIME)
		&"salvo":
			for target in _ships:
				var ahead := target.distance - ship.distance
				if target != ship and ahead > 0.0 and ahead < SALVO_RANGE and target.is_flying() and not target.is_untouchable():
					Effects.tracer(self, ship.global_position, target.global_position, ship.color)
					target.hit()
					_warn(target, ship, info[0])
		&"rampart":
			ship.raise_shield(SPECIAL_TIME)
		&"cloak":
			ship.cloak_left = SPECIAL_TIME
		&"warp":
			Effects.burst(self, ship.global_position, ship.color, 40)
			ship.distance += WARP_DISTANCE
			ship.boost(1.0)
		&"missile":
			var target: RaceShip = null
			for other in _ships:
				var ahead := other.distance - ship.distance
				if other != ship and ahead > 0.0 and ahead < MISSILE_RANGE and other.is_flying() and not other.is_untouchable():
					if target == null or ahead < target.distance - ship.distance:
						target = other
			if target:
				Effects.tracer(self, ship.global_position, target.global_position, Color(1.0, 0.6, 0.2))
				target.hit()
				target.hit()
				_warn(target, ship, info[0])
		&"emp":
			_emp_ring(ship)
			for other in _ships:
				if other != ship and absf(other.distance - ship.distance) < EMP_RANGE and not other.is_untouchable():
					other.stun_left = EMP_STUN
					_warn(other, ship, info[0])
		&"mines":
			for i in 3:
				_lay_mine(ship, ship.distance - 6.0 - 5.0 * i, ship.offset + Vector2((i - 1) * 3.0, 0))


## Tells the player who just got them, and with what.
func _warn(target: RaceShip, attacker: RaceShip, what: String) -> void:
	if target == _player:
		_show_center("%s : %s" % [attacker.display_name, what], 1.2)


func _emp_ring(ship: RaceShip) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.0
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(ship.color, 0.7)
	torus.material = material
	ring.mesh = torus
	add_child(ring)
	ring.global_transform = ship.global_transform * Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3.ZERO)
	var tween := ring.create_tween()
	tween.tween_property(ring, "scale", Vector3.ONE * EMP_RANGE, 0.6)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.6)
	tween.tween_callback(ring.queue_free)


func _lay_mine(owner_ship: RaceShip, at: float, offset: Vector2) -> void:
	var mine := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.6
	sphere.height = 1.2
	var material := StandardMaterial3D.new()
	material.albedo_color = owner_ship.color
	material.emission_enabled = true
	material.emission = owner_ship.color
	material.emission_energy_multiplier = 3.0
	sphere.material = material
	mine.mesh = sphere
	add_child(mine)
	var clamped := RaceTrack.clamp_offset(offset)
	mine.transform = _track.frame_at(at, clamped)
	_mines.append([at, clamped, mine, owner_ship])


## A ship (flown on this device) that runs into a mine is hit and slowed.
func _check_mines() -> void:
	for mine: Array in _mines.duplicate():
		for ship in _ships:
			if ship == mine[3] or ship.remote or not ship.is_flying():
				continue
			var lap_gap := fposmod(ship.distance - mine[0] + 10.0, _track.length) - 10.0
			if absf(lap_gap) < 2.0 and ship.offset.distance_to(mine[1]) < MINE_RADIUS:
				if not ship.is_untouchable():
					ship.hit()
					ship.stun_left = MINE_STUN
					_warn(ship, mine[3], "MINE")
				Effects.burst(self, ship.global_position, mine[3].color, 40)
				(mine[2] as Node3D).queue_free()
				_mines.erase(mine)
				break


## Ships side by side push each other apart; the one behind loses speed.
func _bump_ships() -> void:
	for i in _ships.size():
		for j in range(i + 1, _ships.size()):
			var a := _ships[i]
			var b := _ships[j]
			if not a.is_flying() or not b.is_flying() or (a.remote and b.remote):
				continue
			if absf(a.distance - b.distance) < RaceShip.LENGTH and a.offset.distance_to(b.offset) < SHIP_RADIUS * 2.0:
				var push := (a.offset - b.offset).normalized()
				if push == Vector2.ZERO:
					push = Vector2.RIGHT
				a.offset = RaceTrack.clamp_offset(a.offset + push * 0.4)
				b.offset = RaceTrack.clamp_offset(b.offset - push * 0.4)
				var behind := a if a.distance < b.distance else b
				behind.speed *= 0.97
				# A rampart knocks the other one off course.
				for pair: Array in [[a, b], [b, a]]:
					if pair[0].shielded_left > 0.0 and pair[1].stun_left <= 0.0:
						pair[1].stun_left = RaceShip.STUN_TIME
						pair[1].offset = RaceTrack.clamp_offset(pair[1].offset - push * (3.0 if pair[1] == b else -3.0))


## Gates crossed fill the boost gauge; pads flown over boost.
func _check_track(ship: RaceShip) -> void:
	var lap_distance := fposmod(ship.distance, _track.length)
	var state: Dictionary = _passed[ship]
	var gate_index := int(lap_distance / RaceTrack.GATE_SPACING)
	if gate_index != state.gate:
		state.gate = gate_index
		ship.boost_charge = minf(ship.boost_charge + GATE_CHARGE, 1.0)
	for i in _track.pads.size():
		var pad: Array = _track.pads[i]
		if i != state.pad and absf(lap_distance - pad[0]) < 2.0 and ship.offset.distance_to(pad[1]) < PAD_RADIUS:
			state.pad = i
			ship.boost()
			if ship == _player:
				_show_center("BOOST", 0.5)


func _check_finish() -> void:
	for ship in _ships:
		if not ship.remote and not ship.finished and ship.distance >= _track.length * LAPS:
			ship.finished = true
			ship.finish_time = _clock
	if _player.finished and not _over:
		_over = true
		_show_results()


## Places, best first: finished ships by time, then by distance.
func _standings() -> Array[RaceShip]:
	var order := _ships.duplicate()
	order.sort_custom(func(a: RaceShip, b: RaceShip) -> bool:
		if a.finished and b.finished:
			return a.finish_time < b.finish_time
		if a.finished != b.finished:
			return a.finished
		return a.distance > b.distance)
	return order


# --- Camera -------------------------------------------------------------------

func _place_camera(delta: float) -> void:
	var frame := _track.frame_at(_player.distance - CAMERA_BACK, _player.offset * 0.7)
	var at := frame.origin + frame.basis.y * CAMERA_UP
	var look := _track.frame_at(_player.distance + 14.0, _player.offset * 0.8).origin + frame.basis.y * 0.8
	if delta > 0.0:
		at = _camera.global_position.lerp(at, minf(delta * 8.0, 1.0))
	_camera.look_at_from_position(at, look, frame.basis.y)
	# The faster, the wider.
	_camera.fov = lerpf(_camera.fov, 68.0 + (_player.speed - RaceShip.BASE_SPEED) * 0.35, minf(delta * 3.0, 1.0))


# --- Interface ----------------------------------------------------------------

func _build_ui() -> void:
	add_child(_layer)
	_touch.buttons = [
		{"action": "fire", "label": "TIR", "radius": TouchControls.FIRE_RADIUS, "offset": Vector2.ZERO, "toggle": false},
		{"action": "ultimate", "label": "CAPACITÉ", "radius": 60.0, "offset": Vector2(-170, 20), "toggle": false},
	]
	_touch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_touch.visible = DisplayServer.is_touchscreen_available()
	_layer.add_child(_touch)
	_style(_place_label, 54, Color.WHITE)
	_place_label.position = Vector2(30, 20)
	_style(_lap_label, 28, Color(0.16, 0.9, 1.0))
	_lap_label.position = Vector2(30, 92)
	_style(_shield_label, 24, Color(1.0, 0.8, 0.25))
	_shield_label.position = Vector2(30, 132)
	_style(_speed_label, 30, Color.WHITE)
	_speed_label.anchor_left = 0.5
	_speed_label.anchor_right = 0.5
	_speed_label.anchor_top = 1.0
	_speed_label.anchor_bottom = 1.0
	_speed_label.offset_left = -200
	_speed_label.offset_right = 200
	_speed_label.offset_top = -110
	_speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boost_bar.anchor_left = 0.5
	_boost_bar.anchor_right = 0.5
	_boost_bar.anchor_top = 1.0
	_boost_bar.anchor_bottom = 1.0
	_boost_bar.offset_left = -160
	_boost_bar.offset_right = 160
	_boost_bar.offset_top = -60
	_boost_bar.offset_bottom = -40
	_boost_bar.max_value = 1.0
	_boost_bar.show_percentage = false
	_layer.add_child(_boost_bar)
	_style(_center_label, 96, Color(1.0, 0.24, 0.95))
	_center_label.anchor_right = 1.0
	_center_label.anchor_top = 0.3
	_center_label.anchor_bottom = 0.3
	_center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var pause := Button.new()
	pause.text = "II"
	pause.custom_minimum_size = Vector2(72, 64)
	pause.anchor_left = 1.0
	pause.anchor_right = 1.0
	pause.offset_left = -100
	pause.offset_top = 20
	pause.pressed.connect(_toggle_pause)
	_layer.add_child(pause)
	_build_pause_panel()
	_build_end_panel()


func _style(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(label)


func _refresh_ui() -> void:
	var standings := _standings()
	_place_label.text = "%d / %d" % [standings.find(_player) + 1, _ships.size()]
	var lap := mini(int(maxf(_player.distance, 0.0) / _track.length) + 1, LAPS)
	_lap_label.text = "TOUR %d / %d  ·  %s" % [lap, LAPS, _time_text(_clock)]
	_shield_label.text = "BOUCLIER %d / %d" % [_player.shield, _player.max_shield] if _player.is_flying() else "RÉPARATION..."
	_speed_label.text = "%d KM/H" % int(_player.speed * 3.6 * 3.0)
	_boost_bar.value = _player.boost_charge
	_boost_bar.modulate = Color(1.0, 0.8, 0.25) if _player.boost_charge >= 1.0 else Color.WHITE


func _show_center(text: String, seconds := 0.0) -> void:
	_center_label.text = text
	if seconds > 0.0:
		get_tree().create_timer(seconds, false).timeout.connect(func() -> void:
			if _center_label.text == text:
				_center_label.text = "")


static func _time_text(seconds: float) -> String:
	return "%d:%05.2f" % [floori(seconds / 60.0), fmod(seconds, 60.0)]


func _build_pause_panel() -> void:
	_pause_panel.anchor_left = 0.5
	_pause_panel.anchor_right = 0.5
	_pause_panel.anchor_top = 0.5
	_pause_panel.anchor_bottom = 0.5
	_pause_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_pause_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_pause_panel.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_pause_panel.add_child(box)
	for entry: Array in [["REPRENDRE", _toggle_pause], ["QUITTER LA COURSE", _quit]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(420, 80)
		button.add_theme_font_size_override("font_size", 28)
		button.pressed.connect(entry[1])
		box.add_child(button)
	_layer.add_child(_pause_panel)


func _toggle_pause() -> void:
	if _over:
		return
	_paused = not _paused
	_pause_panel.visible = _paused
	get_tree().paused = false


func _quit() -> void:
	if _online:
		Net.leave()
	get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


# --- Network ------------------------------------------------------------------

## This device's ships (its player, and the computers on the host), a few
## times a second, to everyone.
func _send_states(delta: float) -> void:
	_send_left -= delta
	if _send_left > 0.0:
		return
	_send_left = 1.0 / SEND_RATE
	for index in _ships.size():
		if not _ships[index].remote:
			_state.rpc(index, _ships[index].get_state())


@rpc("any_peer", "unreliable_ordered")
func _state(index: int, state: Array) -> void:
	if index >= 0 and index < _ships.size() and _ships[index].remote:
		_ships[index].apply_state(state)


@rpc("any_peer", "call_local", "reliable")
func _hit(index: int) -> void:
	if index >= 0 and index < _ships.size():
		_ships[index].hit()


@rpc("any_peer", "reliable")
func _ready_to_race() -> void:
	_ready_peers[multiplayer.get_remote_sender_id()] = true
	if _ready_peers.size() >= Net.players.size():
		_begin_if_waiting()


func _begin_if_waiting() -> void:
	if Net.is_host() and not _started and _center_label.text == "EN ATTENTE…":
		_center_label.text = ""
		_begin.rpc()


@rpc("authority", "call_local", "reliable")
func _begin() -> void:
	_center_label.text = ""
	_countdown()


func _build_end_panel() -> void:
	_end_panel.anchor_left = 0.5
	_end_panel.anchor_right = 0.5
	_end_panel.anchor_top = 0.5
	_end_panel.anchor_bottom = 0.5
	_end_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_end_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_end_panel.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_end_panel.add_child(box)
	_end_text.add_theme_font_override("font", FONT)
	_end_text.add_theme_font_size_override("font_size", 26)
	_end_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_end_text)
	var replay := func() -> void:
		if _online:
			Net.start_game("race")
		else:
			get_tree().reload_current_scene.call_deferred()
	for entry: Array in [["REJOUER", replay], ["MENU", _quit]]:
		# Online, only the host starts the next race.
		if entry[0] == "REJOUER" and _online and not Net.is_host():
			continue
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(420, 80)
		button.add_theme_font_size_override("font_size", 28)
		button.pressed.connect(entry[1])
		box.add_child(button)
	_layer.add_child(_end_panel)


## Place, time, the others' places; XP and credits for the place.
func _show_results() -> void:
	Input.action_release("fire")
	var standings := _standings()
	var place := standings.find(_player)
	var score: int = PLACE_SCORES[place]
	var xp := BattlePass.xp_for_score(score)
	var credits := Wallet.credits_for_score(score)
	var unlocked := []
	var tier_before: int = BattlePass.progress().tier
	for id in BattlePass.add_xp(xp):
		unlocked.append(Loadout.find(id).item.name)
	Wallet.add_credits(credits)
	var boosters := Cards.reward_game(score, tier_before)
	var lines := ["%s  ·  %s" % ["VICTOIRE !" if place == 0 else "%de PLACE" % (place + 1), _time_text(_player.finish_time)], ""]
	for i in standings.size():
		lines.append("%d. %s" % [i + 1, standings[i].display_name])
	lines.append("")
	lines.append("+%d XP  ·  +%d crédits  ·  +%d booster%s" % [xp, credits, boosters, "s" if boosters > 1 else ""])
	if not unlocked.is_empty():
		lines.append("Débloqué : " + ", ".join(unlocked))
	_end_text.text = "\n".join(lines)
	_end_panel.visible = true
	_touch.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Desktop: the left button fires too.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.pressed and not _over and not _paused:
			Input.action_press("fire")
		else:
			Input.action_release("fire")
	elif event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_toggle_pause()
