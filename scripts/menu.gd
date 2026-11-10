extends Control
## Title screen: best score and play button.

const GAME_SCENE := "res://scenes/main.tscn"

@onready var _best_label: Label = $Center/Box/Best
@onready var _play_button: Button = $Center/Box/Play


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_best_label.text = "Record : %d" % SaveData.load_high_score()
	_play_button.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	# Deferred: the scene must not be removed while the button handles its click.
	get_tree().change_scene_to_file.call_deferred(GAME_SCENE)
