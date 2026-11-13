extends Control
## Home screen: play, armory, shop, battle pass, daily challenges and stats, settings.

const GAME_SCENE := "res://scenes/main.tscn"
const CAPTURE_SCENE := "res://scenes/capture.tscn"
const RACE_SCENE := "res://scenes/race.tscn"
const LOBBY_SCENE := "res://scenes/lobby.tscn"
const CARDS_SCENE := "res://scenes/cards.tscn"
## The game modes offered by JOUER: [title, description, scene].
const MODES := [
	["HISTOIRE", "Les saisons 1 et 2 de l'anime, en 20 chapitres", Story.SCREEN],
	["VAGUES", "Survis aux vagues et bats les 6 boss", GAME_SCENE],
	["CAPTURE DE ZONE", "4 contre 4 avec des bots · tiens les zones A, B et C", CAPTURE_SCENE],
	["COURSE DE VAISSEAUX", "3 tours contre 5 pilotes · boost et lasers", RACE_SCENE],
	["COMBAT", "Un contre un, de profil · IA, 2 joueurs, arcade, Wi-Fi", FightSetup.MENU],
	["MULTIJOUEUR", "Wi-Fi local · course, capture ou combat", LOBBY_SCENE],
]
const ARMORY_SCENE := "res://scenes/armory.tscn"
const PASS_SCENE := "res://scenes/battle_pass.tscn"
const SHOP_SCENE := "res://scenes/shop.tscn"
const POSTER_SCENE := "res://scenes/tools/poster.tscn"

@onready var _stage: CharacterStage = $Stage
@onready var _best_label: Label = $Right/Box/Best
@onready var _settings_panel: Control = $SettingsPanel
var _profile_panel := ProfilePanel.new()
var _mode_panel := Control.new()


func _ready() -> void:
	Loadout.fair_play = false
	Story.leave()
	Events.christmas_run = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.CHRISTMAS if Events.is_christmas() else Music.Track.MAIN)
	_stage.show_loadout()
	_best_label.text = "Record : %d  ·  Palier %d\nDéfis du jour : %d / %d\n%d crédits  ·  %d gemmes" % [
			SaveData.load_high_score(), BattlePass.progress().tier, Challenges.done_count(), Challenges.PER_DAY,
			Wallet.credits(), Wallet.gems()]
	_settings_panel.visible = false
	add_child(_profile_panel)
	_profile_panel.visible = false
	_add_corner_labels()
	# Test option: "-- --pose=2" shows the third dance on the home screen,
	# "--pose=jump" the jump.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--pose="):
			var value := argument.get_slice("=", 1)
			_stage.preview_pose = -2 if value == "jump" else value.to_int()

	# Deferred: a scene must not be removed while its button handles the click.
	_build_mode_panel()
	$Right/Box/Play.pressed.connect(func() -> void: _mode_panel.visible = true)
	if Events.is_christmas():
		_add_christmas()
	_announce_achievements(Achievements.check())
	$Right/Box/Gear/Armory.pressed.connect(get_tree().change_scene_to_file.bind(ARMORY_SCENE), CONNECT_DEFERRED)
	$Right/Box/Gear/Shop.pressed.connect(get_tree().change_scene_to_file.bind(SHOP_SCENE), CONNECT_DEFERRED)
	$Right/Box/PassRow/Pass.pressed.connect(get_tree().change_scene_to_file.bind(PASS_SCENE), CONNECT_DEFERRED)
	$Right/Box/PassRow/Cards.pressed.connect(get_tree().change_scene_to_file.bind(CARDS_SCENE), CONNECT_DEFERRED)
	var waiting: Dictionary = Cards.boosters()
	var boosters: int = waiting.get("standard", 0) + waiting.get("rare", 0) + waiting.get("legend", 0)
	if boosters > 0:
		$Right/Box/PassRow/Cards.text = "CARTES (%d)" % boosters
	$Right/Box/Row/Settings.pressed.connect(func() -> void: _settings_panel.visible = true)
	$Right/Box/Row/Profile.pressed.connect(_profile_panel.open)
	$SettingsPanel/Center/Panel/Box/Close.pressed.connect(func() -> void: _settings_panel.visible = false)
	$Right/Box/Row/Code.pressed.connect(_open_code_panel)
	$Right.resized.connect(_fit_buttons)
	_fit_buttons.call_deferred()


## Under the hero: what is equipped. Bottom right: the version.
func _add_corner_labels() -> void:
	var loadout := Label.new()
	loadout.text = "%s  ·  %s  ·  %s\n%s  ·  skin %s" % [
			Loadout.selected_character().name, Loadout.selected_weapon().name, Loadout.selected_skin().name,
			Loadout.selected_melee().name, Loadout.selected_melee_skin().name]
	loadout.add_theme_font_size_override("font_size", 18)
	loadout.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	loadout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loadout.anchor_left = 0.0
	loadout.anchor_right = 0.55
	loadout.anchor_top = 1.0
	loadout.anchor_bottom = 1.0
	loadout.offset_top = -78.0
	loadout.offset_bottom = -30.0
	add_child(loadout)
	move_child(loadout, _settings_panel.get_index())
	var version := Label.new()
	version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	version.add_theme_font_size_override("font_size", 14)
	version.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	version.anchor_left = 1.0
	version.anchor_right = 1.0
	version.anchor_top = 1.0
	version.anchor_bottom = 1.0
	version.offset_left = -90.0
	version.offset_top = -26.0
	version.offset_bottom = -8.0
	add_child(version)
	move_child(version, _settings_panel.get_index())
	move_child(_profile_panel, -1)


func _unhandled_key_input(event: InputEvent) -> void:
	# Test shortcut (debug and web builds): F6 opens the scene used to render
	# the loading screen artwork.
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_F6 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		get_tree().change_scene_to_file.call_deferred(POSTER_SCENE)


func _notification(what: int) -> void:
	# Android back button: close the settings, or leave the game.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _mode_panel.visible:
			_mode_panel.visible = false
		elif _settings_panel.visible:
			_settings_panel.visible = false
		elif _profile_panel.visible:
			_profile_panel.visible = false
		else:
			get_tree().quit()


## JOUER opens this: one big button per mode, and a way back.
func _build_mode_panel() -> void:
	_mode_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_panel.visible = false
	add_child(_mode_panel)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_panel.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_panel.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10 if Events.is_christmas() else 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = "MODE DE JEU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.16, 0.83, 1.0))
	box.add_child(title)
	var modes := MODES.duplicate()
	if Events.is_christmas():
		modes.push_front(["VAGUES DE NOËL", "10 vagues dans le village enneigé · le Père Glaçon", GAME_SCENE, true])
	for mode: Array in modes:
		var button := Button.new()
		button.text = "%s\n%s" % [mode[0], mode[1]]
		button.custom_minimum_size = Vector2(560, 88)
		button.add_theme_font_size_override("font_size", 24)
		# Seven modes at Christmas: a little less tall each.
		button.custom_minimum_size.y = 64 if modes.size() > 6 else 88
		if modes.size() > 6:
			button.add_theme_font_size_override("font_size", 20)
		var christmas: bool = mode.size() > 3
		button.pressed.connect(func() -> void:
			Events.christmas_run = christmas
			get_tree().change_scene_to_file(mode[2]), CONNECT_DEFERRED)
		box.add_child(button)
	var back := Button.new()
	back.text = "RETOUR"
	back.custom_minimum_size.y = 50 if Events.is_christmas() else 64
	back.add_theme_font_size_override("font_size", 24)
	back.pressed.connect(func() -> void: _mode_panel.visible = false)
	box.add_child(back)
	move_child(_mode_panel, -1)


## The code field: a code typed here gives its rewards (see PromoCodes).
func _open_code_panel() -> void:
	var panel_root := Control.new()
	panel_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_root.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = "CODE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.16, 0.83, 1.0))
	box.add_child(title)
	var field := LineEdit.new()
	field.placeholder_text = "Code promo ou d'échange"
	field.custom_minimum_size = Vector2(520, 72)
	field.add_theme_font_size_override("font_size", 30)
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	box.add_child(field)
	var message := Label.new()
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size.x = 520
	message.add_theme_font_size_override("font_size", 22)
	box.add_child(message)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var submit := func() -> void:
		var result := Trade.receive(field.text) if Trade.is_code(field.text) else PromoCodes.redeem(field.text)
		message.text = ("Obtenu : " + result[1]) if result[0] else result[1]
		message.add_theme_color_override("font_color", Color(1.0, 0.8, 0.25) if result[0] else Color(1.0, 0.4, 0.4))
		if result[0]:
			field.text = ""
	var validate := Button.new()
	validate.text = "VALIDER"
	validate.custom_minimum_size = Vector2(0, 64)
	validate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	validate.add_theme_font_size_override("font_size", 24)
	validate.pressed.connect(submit)
	row.add_child(validate)
	field.text_submitted.connect(func(_text: String) -> void: submit.call())
	var close := Button.new()
	close.text = "FERMER"
	close.custom_minimum_size = Vector2(0, 64)
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.add_theme_font_size_override("font_size", 24)
	# Reloads the home screen, so its credits, gems and boosters are up to date.
	close.pressed.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
	row.add_child(close)
	field.grab_focus()


## Achievements just reached (outside a game: cards, pass, shop…): a banner
## at the top, one after the other.
func _announce_achievements(reached: Array[Dictionary]) -> void:
	for achievement in reached:
		var banner := Label.new()
		banner.text = "SUCCÈS : %s  ·  +%d GEMMES" % [str(achievement.name).to_upper(), achievement.gems]
		banner.add_theme_font_size_override("font_size", 28)
		banner.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		banner.add_theme_color_override("font_outline_color", Color.BLACK)
		banner.add_theme_constant_override("outline_size", 10)
		banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		banner.anchor_right = 1.0
		banner.offset_top = 14
		banner.modulate.a = 0.0
		add_child(banner)
		var tween := banner.create_tween()
		tween.tween_interval(1.2 + 2.6 * reached.find(achievement))
		tween.tween_property(banner, "modulate:a", 1.0, 0.25)
		tween.tween_interval(2.0)
		tween.tween_property(banner, "modulate:a", 0.0, 0.3)
		tween.tween_callback(banner.queue_free)


## The Christmas event: snow over the home screen, and the gift of the day.
func _add_christmas() -> void:
	var flake := GradientTexture2D.new()
	flake.fill = GradientTexture2D.FILL_RADIAL
	flake.fill_from = Vector2(0.5, 0.5)
	flake.fill_to = Vector2(1.0, 0.5)
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	flake.gradient = gradient
	flake.width = 16
	flake.height = 16
	var snow := CPUParticles2D.new()
	snow.texture = flake
	snow.amount = 140
	snow.lifetime = 9.0
	snow.preprocess = 9.0
	snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow.emission_rect_extents = Vector2(get_viewport_rect().size.x / 2.0 + 40.0, 4)
	snow.position = Vector2(get_viewport_rect().size.x / 2.0, -10)
	snow.direction = Vector2(0.15, 1)
	snow.spread = 12.0
	snow.gravity = Vector2(4, 12)
	snow.initial_velocity_min = 40.0
	snow.initial_velocity_max = 80.0
	snow.scale_amount_min = 0.3
	snow.scale_amount_max = 1.0
	add_child(snow)
	move_child(snow, 2)
	if not Events.gift_ready():
		return
	var gift := Button.new()
	gift.text = "CADEAU DU JOUR"
	gift.custom_minimum_size.y = 64
	gift.theme_type_variation = &"PrimaryButton"
	gift.add_theme_font_size_override("font_size", 26)
	gift.pressed.connect(func() -> void:
		var given := Events.open_gift()
		gift.text = "JOYEUX NOËL : %s !" % given.to_upper()
		gift.disabled = true
		var waiting: Dictionary = Cards.boosters()
		$Right/Box/PassRow/Cards.text = "CARTES (%d)" % (waiting.get("standard", 0) + waiting.get("rare", 0) + waiting.get("legend", 0)))
	$Right/Box.add_child(gift)
	$Right/Box.move_child(gift, $Right/Box/Play.get_index() + 1)


## The buttons need about 600 pixels: on a wide phone the right part of the
## screen has them, on a 16:9 screen it is narrower, so they shrink to fit
## instead of running off the edge.
func _fit_buttons() -> void:
	var right: Control = $Right
	var needed: Vector2 = $Right/Box.get_combined_minimum_size()
	# The share of the screen meant for the buttons (the container itself
	# grows past it when they are too wide).
	var screen := get_viewport_rect().size
	var room := Vector2(screen.x * (right.anchor_right - right.anchor_left) - 40.0, screen.y - 24.0)
	var fit := minf(1.0, minf(room.x / needed.x, room.y / needed.y))
	# The box sits in a container, which resets its scale: the whole right
	# part shrinks, around its center (the center of that share).
	right.pivot_offset = right.size / 2.0
	right.scale = Vector2.ONE * fit
