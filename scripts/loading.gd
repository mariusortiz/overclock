extends Control
## Start-up screen: shows the cast while the other scenes load, then opens
## the menu. Scenes are loaded one per frame so the bar can move; background
## (threaded) loading failed on the arena shader.

const MENU_SCENE := "res://scenes/menu.tscn"
const SCENES_TO_LOAD: Array[String] = [
	MENU_SCENE, "res://scenes/armory.tscn", "res://scenes/battle_pass.tscn", "res://scenes/main.tscn",
]
const MINIMUM_TIME := 2.0
const FRAMES_BEFORE_LOADING := 3  # let the screen appear first
const MONSTERS := "res://assets/models/quaternius/monsters/"
const CHARACTERS := "res://assets/models/quaternius/characters/"

var _elapsed := 0.0
var _frames := 0
## Keeps the loaded scenes in memory until the menu takes over.
var _loaded: Array[Resource] = []

@onready var _stage: CharacterStage = $Stage
@onready var _bar: ProgressBar = $Bottom/Bar
@onready var _version: Label = $Version


func _ready() -> void:
	_version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	_stage.show_loadout()
	_stage.add_extra(MONSTERS + "Dragon.fbx", Vector3(0.2, 0.0, -3.5), 3.4, 0.6)
	_stage.add_extra(CHARACTERS + "Ninja_Sand.fbx", Vector3(-1.7, 0.0, -1.2), 1.75)
	_stage.add_extra(CHARACTERS + "Goblin_Male.fbx", Vector3(1.7, 0.0, -1.2), 1.75)


func _process(delta: float) -> void:
	_elapsed += delta
	_frames += 1
	if _frames > FRAMES_BEFORE_LOADING and _loaded.size() < SCENES_TO_LOAD.size():
		_loaded.append(load(SCENES_TO_LOAD[_loaded.size()]))

	# The bar never runs ahead of the minimum display time.
	var loaded := float(_loaded.size()) / SCENES_TO_LOAD.size()
	_bar.value = minf(loaded, _elapsed / MINIMUM_TIME) * 100.0

	if _loaded.size() == SCENES_TO_LOAD.size() and _elapsed >= MINIMUM_TIME:
		set_process(false)
		get_tree().change_scene_to_packed(_loaded[0])
