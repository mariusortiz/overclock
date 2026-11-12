extends Control
## Home screen: play, armory, shop, battle pass, daily challenges and stats, settings.

const GAME_SCENE := "res://scenes/main.tscn"
const CAPTURE_SCENE := "res://scenes/capture.tscn"
const RACE_SCENE := "res://scenes/race.tscn"
## The game modes offered by JOUER: [title, description, scene].
const MODES := [
	["VAGUES", "Survis aux vagues et bats les 5 boss", GAME_SCENE],
	["CAPTURE DE ZONE", "4 contre 4 avec des bots · tiens les zones A, B et C", CAPTURE_SCENE],
	["COURSE DE VAISSEAUX", "3 tours contre 5 pilotes · boost et lasers", RACE_SCENE],
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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.MAIN)
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
	$Right/Box/Gear/Armory.pressed.connect(get_tree().change_scene_to_file.bind(ARMORY_SCENE), CONNECT_DEFERRED)
	$Right/Box/Gear/Shop.pressed.connect(get_tree().change_scene_to_file.bind(SHOP_SCENE), CONNECT_DEFERRED)
	$Right/Box/Pass.pressed.connect(get_tree().change_scene_to_file.bind(PASS_SCENE), CONNECT_DEFERRED)
	$Right/Box/Row/Settings.pressed.connect(func() -> void: _settings_panel.visible = true)
	$Right/Box/Row/Profile.pressed.connect(_profile_panel.open)
	$SettingsPanel/Center/Panel/Box/Close.pressed.connect(func() -> void: _settings_panel.visible = false)


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
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = "MODE DE JEU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.16, 0.83, 1.0))
	box.add_child(title)
	for mode: Array in MODES:
		var button := Button.new()
		button.text = "%s\n%s" % [mode[0], mode[1]]
		button.custom_minimum_size = Vector2(560, 104)
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(get_tree().change_scene_to_file.bind(mode[2]), CONNECT_DEFERRED)
		box.add_child(button)
	var back := Button.new()
	back.text = "RETOUR"
	back.custom_minimum_size.y = 64
	back.add_theme_font_size_override("font_size", 24)
	back.pressed.connect(func() -> void: _mode_panel.visible = false)
	box.add_child(back)
	move_child(_mode_panel, -1)
