extends Node3D
## Pet race, a mini-game: the equipped pet runs against five others on a
## straight track with hurdles and mud. The player only jumps and sprints
## (sprinting tires the pet out); the others run on their own. Before the
## start, a bet in credits: first doubles it, second gets one and a half
## times it back, third gets it back. A win may also give an egg accessory.
## Everything is built by code.

const MENU_SCENE := "res://scenes/menu.tscn"
const RACERS := 6
const LANE_WIDTH := 2.6
const LENGTH := 160.0
const SPEED := 7.0
const SPRINT := 1.5
const DRAIN := 0.4
const RECOVER := 0.22
const JUMP_SPEED := 5.6
const GRAVITY := 14.0
const HURDLE_HEIGHT := 0.5
const HURDLES := [18.0, 34.0, 52.0, 66.0, 84.0, 100.0, 112.0, 128.0, 144.0]
## Mud patches: [start, end] along the track, everyone slowed down in them.
const MUD := [[40.0, 46.0], [90.0, 96.0], [118.0, 124.0]]
const MUD_FACTOR := 0.55
const STUMBLE_TIME := 0.9
const BETS := [0, 100, 250, 500, 1000]
const PAYOUT := [2.0, 1.5, 1.0]
const ACCESSORY_CHANCE := 0.1
const COLORS := [Color(0.16, 0.83, 1.0), Color(1.0, 0.24, 0.95), Color(1.0, 0.85, 0.3), Color(0.3, 1.0, 0.45), Color(1.0, 0.45, 0.2), Color(0.75, 0.6, 1.0)]

## One racer: {"pet", "node", "z", "y", "vy", "stamina", "stumble", "done",
## "time", "lead" (AI: how far before a hurdle it jumps), "player"}.
var _racers: Array[Dictionary] = []
var _camera := Camera3D.new()
var _ui := CanvasLayer.new()
var _top := Label.new()
var _stamina := ProgressBar.new()
var _panel := VBoxContainer.new()
var _bet := 0
var _running := false
var _clock := 0.0
var _finished: Array[Dictionary] = []
var _sprint_held := false


func _ready() -> void:
	Music.play_track(Music.Track.RACE)
	_build_world()
	_build_racers()
	_build_ui()
	# Test option: "-- --bet=100" starts at once with that bet.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--bet="):
			_start(argument.get_slice("=", 1).to_int())
			return
	_show_bets()


# --- World ---------------------------------------------------------------------

func _build_world() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.25, 0.5, 0.9)
	sky_material.sky_horizon_color = Color(0.8, 0.88, 0.98)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.8
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.shadow_enabled = Settings.high_quality
	add_child(sun)
	var width := LANE_WIDTH * RACERS
	_box(Vector3(width + 30.0, 0.2, LENGTH + 60.0), Vector3(0, -0.1, -LENGTH / 2.0), Color(0.35, 0.6, 0.3))
	_box(Vector3(width, 0.02, LENGTH + 20.0), Vector3(0, 0.01, -LENGTH / 2.0), Color(0.75, 0.42, 0.3))
	for lane in RACERS + 1:
		_box(Vector3(0.08, 0.03, LENGTH + 20.0), Vector3(_lane_x(lane) - LANE_WIDTH / 2.0, 0.02, -LENGTH / 2.0), Color.WHITE)
	for mud: Array in MUD:
		_box(Vector3(width, 0.04, mud[1] - mud[0]), Vector3(0, 0.03, -(mud[0] + mud[1]) / 2.0), Color(0.35, 0.22, 0.12))
	for z: float in HURDLES:
		for lane in RACERS:
			var hurdle := _box(Vector3(LANE_WIDTH * 0.8, 0.08, 0.08), Vector3(_lane_x(lane), HURDLE_HEIGHT, -z), Color.WHITE)
			hurdle.name = "Hurdle_%d_%d" % [lane, int(z)]
			for side in [-1.0, 1.0]:
				_box(Vector3(0.06, HURDLE_HEIGHT, 0.06), Vector3(_lane_x(lane) + side * LANE_WIDTH * 0.4, HURDLE_HEIGHT / 2.0, -z), Color(0.9, 0.2, 0.2))
	# The finish: a checkered line and an arch.
	for i in 24:
		_box(Vector3(width / 24.0, 0.03, 1.0), Vector3(-width / 2.0 + width / 24.0 * (i + 0.5), 0.03, -LENGTH), Color.WHITE if i % 2 == 0 else Color.BLACK)
	for side in [-1.0, 1.0]:
		_box(Vector3(0.5, 5.0, 0.5), Vector3(side * (width / 2.0 + 0.6), 2.5, -LENGTH), Color(1.0, 0.24, 0.95))
	_box(Vector3(width + 1.7, 0.8, 0.5), Vector3(0, 5.0, -LENGTH), Color(1.0, 0.24, 0.95))
	add_child(_camera)
	_camera.current = true


func _box(size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	var box := MeshInstance3D.new()
	box.mesh = mesh
	box.position = at
	add_child(box)
	return box


func _lane_x(lane: int) -> float:
	return (lane - (RACERS - 1) / 2.0) * LANE_WIDTH


# --- Racers --------------------------------------------------------------------

func _build_racers() -> void:
	var mine := Pets.selected()
	if mine.id == Pets.NONE.id:
		mine = Pets.find("pet_dog")
	var others := Pets.LIST.filter(func(pet: Dictionary) -> bool:
		return pet.id != Pets.NONE.id and pet.id != mine.id and not pet.get("code", false))
	others.shuffle()
	# The player's pet runs in the middle.
	var player_lane := RACERS / 2 - 1
	var other_index := 0
	for lane in RACERS:
		var is_player := lane == player_lane
		var pet: Dictionary = mine if is_player else others[other_index]
		if not is_player:
			other_index += 1
		var node := Node3D.new()
		var model := Pet.build_model(pet, Pets.selected_accessory() if is_player else {})
		# Small and big pets alike, about the same size on the track.
		model.scale *= 0.9 / maxf(float(pet.height), 0.3)
		node.add_child(model)
		node.position = Vector3(_lane_x(lane), 0, 0)
		node.rotation.y = 0.0
		add_child(node)
		var animation := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if animation:
			for name in animation.get_animation_list():
				if "run" in name.to_lower() or "walk" in name.to_lower():
					animation.get_animation(name).loop_mode = Animation.LOOP_LINEAR
					animation.play(name)
					animation.speed_scale = 1.6
					break
		_racers.append({"pet": pet, "node": node, "lane": lane, "z": 0.0, "y": 0.0, "vy": 0.0, "stamina": 1.0,
				"stumble": 0.0, "done": false, "time": 0.0, "player": is_player, "lead": randf_range(1.2, 3.0),
				"skill": randf_range(0.82, 0.97), "sprinting": false, "color": COLORS[lane]})


func _player_racer() -> Dictionary:
	for racer in _racers:
		if racer.player:
			return racer
	return {}


func _physics_process(delta: float) -> void:
	_follow_camera(delta)
	if not _running:
		return
	_clock += delta
	for racer in _racers:
		if racer.done:
			continue
		_step(racer, delta)
	var mine := _player_racer()
	_stamina.value = mine.stamina
	_top.text = "%s  ·  %d m  ·  %s" % [_place_text(mine), int(minf(mine.z, LENGTH)), _time_text(_clock)]


func _step(racer: Dictionary, delta: float) -> void:
	var next := _next_hurdle(racer.z)
	if racer.player:
		if Input.is_action_just_pressed("jump"):
			_jump(racer)
		racer.sprinting = (_sprint_held or Input.is_action_pressed("fire") or Input.is_action_pressed("move_forward")) and racer.stamina > 0.05
	else:
		# The bots jump a little before each hurdle, not always at the right time.
		if next >= 0.0 and next - racer.z <= racer.lead and racer.y <= 0.0:
			_jump(racer)
			racer.lead = randf_range(1.2, 3.0) if randf() < racer.skill else randf_range(0.1, 5.0)
		if racer.sprinting:
			racer.sprinting = racer.stamina > 0.15
		else:
			racer.sprinting = racer.stamina > 0.7 and randf() < 0.02
	var speed := SPEED
	if racer.sprinting:
		speed *= SPRINT
		racer.stamina = maxf(racer.stamina - DRAIN * delta, 0.0)
	else:
		racer.stamina = minf(racer.stamina + RECOVER * delta, 1.0)
	for mud: Array in MUD:
		if racer.z >= mud[0] and racer.z <= mud[1] and racer.y <= 0.05:
			speed *= MUD_FACTOR
	if racer.stumble > 0.0:
		racer.stumble -= delta
		speed *= 0.3
	var before: float = racer.z
	racer.z += speed * delta
	# Over a hurdle: high enough, or a stumble.
	for z: float in HURDLES:
		if before < z and racer.z >= z and racer.y < HURDLE_HEIGHT * 0.9:
			racer.stumble = STUMBLE_TIME
			var hurdle := get_node_or_null("Hurdle_%d_%d" % [racer.lane, int(z)]) as Node3D
			if hurdle:
				hurdle.rotation.x = -1.2
	if racer.y > 0.0 or racer.vy > 0.0:
		racer.vy -= GRAVITY * delta
		racer.y = maxf(racer.y + racer.vy * delta, 0.0)
		if racer.y <= 0.0:
			racer.vy = 0.0
	racer.node.position = Vector3(_lane_x(racer.lane), racer.y + (absf(sin(_clock * 14.0 + racer.lane)) * 0.06), -racer.z)
	if racer.z >= LENGTH:
		racer.done = true
		racer.time = _clock
		_finished.append(racer)
		if racer.player:
			_on_player_finished()


func _jump(racer: Dictionary) -> void:
	if racer.y <= 0.0 and racer.vy <= 0.0:
		racer.vy = JUMP_SPEED


func _next_hurdle(z: float) -> float:
	for hurdle: float in HURDLES:
		if hurdle > z:
			return hurdle
	return -1.0


func _place_of(racer: Dictionary) -> int:
	if racer.done:
		return _finished.find(racer) + 1
	var ahead := _finished.size()
	for other in _racers:
		if not other.done and other.z > racer.z:
			ahead += 1
	return ahead + 1


func _place_text(racer: Dictionary) -> String:
	var place := _place_of(racer)
	return "%d%s / %d" % [place, "er" if place == 1 else "e", RACERS]


func _time_text(seconds: float) -> String:
	return "%.1f s" % seconds


func _follow_camera(delta: float) -> void:
	var mine := _player_racer()
	if mine.is_empty():
		return
	var target: Vector3 = mine.node.position
	var wanted := Vector3(target.x * 0.5, 3.4, target.z + 7.5)
	_camera.position = _camera.position.lerp(wanted, minf(delta * 5.0, 1.0)) if _camera.position != Vector3.ZERO else wanted
	_camera.look_at(Vector3(target.x * 0.5, 0.8, target.z - 6.0))


# --- Bets, start and end ---------------------------------------------------------

func _build_ui() -> void:
	add_child(_ui)
	_top.add_theme_font_size_override("font_size", 34)
	_top.add_theme_color_override("font_outline_color", Color.BLACK)
	_top.add_theme_constant_override("outline_size", 8)
	_top.anchor_left = 0.5
	_top.anchor_right = 0.5
	_top.offset_left = -400
	_top.offset_right = 400
	_top.offset_top = 18
	_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ui.add_child(_top)
	_stamina.max_value = 1.0
	_stamina.show_percentage = false
	_stamina.anchor_left = 0.5
	_stamina.anchor_right = 0.5
	_stamina.offset_left = -200
	_stamina.offset_right = 200
	_stamina.offset_top = 70
	_stamina.offset_bottom = 88
	_ui.add_child(_stamina)
	# Touch: two big buttons (keyboard: space to jump, hold the fire button,
	# Z or W to sprint).
	var jump := _corner_button("SAUTER", false)
	jump.button_down.connect(func() -> void:
		Input.action_press("jump")
		await get_tree().physics_frame
		Input.action_release("jump"))
	var sprint := _corner_button("SPRINT", true)
	sprint.button_down.connect(func() -> void: _sprint_held = true)
	sprint.button_up.connect(func() -> void: _sprint_held = false)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_panel.add_theme_constant_override("separation", 12)
	_ui.add_child(_panel)


func _corner_button(text: String, left: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 30)
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.anchor_left = 0.0 if left else 1.0
	button.anchor_right = 0.0 if left else 1.0
	button.offset_left = 30.0 if left else -260.0
	button.offset_right = 260.0 if left else -30.0
	button.offset_top = -150.0
	button.offset_bottom = -40.0
	_ui.add_child(button)
	return button


func _clear_panel() -> void:
	for child in _panel.get_children():
		child.queue_free()
	_panel.visible = true


func _title(text: String, size: int, color := Color.WHITE) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	_panel.add_child(label)


func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(480, 60)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(action)
	_panel.add_child(button)
	return button


func _show_bets() -> void:
	_clear_panel()
	var mine := _player_racer()
	_title("COURSE D'ANIMAUX", 42, Color(0.16, 0.83, 1.0))
	_title("Ton animal : %s · %d crédits" % [mine.pet.name, Wallet.credits()], 22)
	_title("1er : mise ×2 · 2e : ×1,5 · 3e : remboursée", 20, Color(1.0, 0.85, 0.3))
	for amount: int in BETS:
		var button := _button("SANS MISE" if amount == 0 else "MISER %d CRÉDITS" % amount, _start.bind(amount))
		button.disabled = amount > Wallet.credits()
	_button("RETOUR", get_tree().change_scene_to_file.bind(MENU_SCENE))


func _start(amount: int) -> void:
	_bet = amount if Wallet.spend(amount, Wallet.CREDITS_KEY) else 0
	_panel.visible = false
	for seconds in [3, 2, 1]:
		_top.text = str(seconds)
		await get_tree().create_timer(0.8).timeout
	_top.text = "PARTEZ !"
	_running = true


func _on_player_finished() -> void:
	var mine := _player_racer()
	var place := _place_of(mine)
	_running = false
	var gain := 0
	if place <= PAYOUT.size() and _bet > 0:
		gain = roundi(_bet * PAYOUT[place - 1])
		Wallet.add_credits(gain)
	var extra := ""
	if place == 1 and randf() < ACCESSORY_CHANCE:
		var hats := Pets.ACCESSORIES.filter(func(item: Dictionary) -> bool:
			return item.get("egg", false) and not Wallet.owns(item.id))
		if not hats.is_empty():
			var hat: Dictionary = hats.pick_random()
			Wallet.give(hat.id)
			extra = "Accessoire gagné : %s" % hat.name
	if place == 1:
		Achievements.set_flag("pet_race_win")
	_clear_panel()
	_title("%s !" % ("VICTOIRE" if place == 1 else "%de PLACE" % place), 44, Color(1.0, 0.85, 0.3) if place == 1 else Color.WHITE)
	_title("%s · %s" % [mine.pet.name, _time_text(mine.time)], 24)
	if _bet > 0:
		_title("Mise %d · gain %d crédits" % [_bet, gain], 24, Color(0.3, 1.0, 0.45) if gain > 0 else Color(1.0, 0.4, 0.4))
	if extra != "":
		_title(extra, 24, Color(1.0, 0.24, 0.95))
	_button("REJOUER", get_tree().reload_current_scene)
	_button("MENU", get_tree().change_scene_to_file.bind(MENU_SCENE))
