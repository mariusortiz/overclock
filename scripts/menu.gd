extends Control
## Home screen: play, armory, battle pass, daily challenges and stats, settings.

const GAME_SCENE := "res://scenes/main.tscn"
const ARMORY_SCENE := "res://scenes/armory.tscn"
const PASS_SCENE := "res://scenes/battle_pass.tscn"
const POSTER_SCENE := "res://scenes/tools/poster.tscn"

@onready var _stage: CharacterStage = $Stage
@onready var _best_label: Label = $Right/Box/Best
@onready var _settings_panel: Control = $SettingsPanel
var _profile_panel := ProfilePanel.new()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.MAIN)
	_stage.show_loadout()
	_best_label.text = "Record : %d  ·  Palier %d\nDéfis du jour : %d / %d" % [
			SaveData.load_high_score(), BattlePass.progress().tier, Challenges.done_count(), Challenges.PER_DAY]
	_settings_panel.visible = false
	add_child(_profile_panel)
	_profile_panel.visible = false

	# Deferred: a scene must not be removed while its button handles the click.
	$Right/Box/Play.pressed.connect(get_tree().change_scene_to_file.bind(GAME_SCENE), CONNECT_DEFERRED)
	$Right/Box/Armory.pressed.connect(get_tree().change_scene_to_file.bind(ARMORY_SCENE), CONNECT_DEFERRED)
	$Right/Box/Pass.pressed.connect(get_tree().change_scene_to_file.bind(PASS_SCENE), CONNECT_DEFERRED)
	$Right/Box/Row/Settings.pressed.connect(func() -> void: _settings_panel.visible = true)
	$Right/Box/Row/Profile.pressed.connect(_profile_panel.open)
	$SettingsPanel/Center/Panel/Box/Close.pressed.connect(func() -> void: _settings_panel.visible = false)


func _unhandled_key_input(event: InputEvent) -> void:
	# Test shortcut (debug and web builds): F6 opens the scene used to render
	# the loading screen artwork.
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_F6 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		get_tree().change_scene_to_file.call_deferred(POSTER_SCENE)


func _notification(what: int) -> void:
	# Android back button: close the settings, or leave the game.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _settings_panel.visible:
			_settings_panel.visible = false
		elif _profile_panel.visible:
			_profile_panel.visible = false
		else:
			get_tree().quit()
