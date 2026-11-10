extends Control
## Home screen: play, armory, settings.

const GAME_SCENE := "res://scenes/main.tscn"
const ARMORY_SCENE := "res://scenes/armory.tscn"

@onready var _stage: CharacterStage = $Stage
@onready var _best_label: Label = $Right/Box/Best
@onready var _settings_panel: Control = $SettingsPanel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.MAIN)
	_stage.show_loadout()
	_best_label.text = "Record : %d" % SaveData.load_high_score()
	_settings_panel.visible = false

	# Deferred: a scene must not be removed while its button handles the click.
	$Right/Box/Play.pressed.connect(get_tree().change_scene_to_file.bind(GAME_SCENE), CONNECT_DEFERRED)
	$Right/Box/Armory.pressed.connect(get_tree().change_scene_to_file.bind(ARMORY_SCENE), CONNECT_DEFERRED)
	$Right/Box/Settings.pressed.connect(func() -> void: _settings_panel.visible = true)
	$SettingsPanel/Center/Panel/Box/Close.pressed.connect(func() -> void: _settings_panel.visible = false)


func _notification(what: int) -> void:
	# Android back button: close the settings, or leave the game.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _settings_panel.visible:
			_settings_panel.visible = false
		else:
			get_tree().quit()
