extends Control
## Start-up screen: shows the cast while the other scenes load in the
## background, then opens the menu.

const MENU_SCENE := "res://scenes/menu.tscn"
const SCENES_TO_LOAD: Array[String] = [MENU_SCENE, "res://scenes/armory.tscn", "res://scenes/battle_pass.tscn", "res://scenes/main.tscn"]
const MINIMUM_TIME := 2.0
const MONSTERS := "res://assets/models/quaternius/monsters/"
const CHARACTERS := "res://assets/models/quaternius/characters/"

var _elapsed := 0.0

@onready var _stage: CharacterStage = $Stage
@onready var _bar: ProgressBar = $Bottom/Bar
@onready var _version: Label = $Version


func _ready() -> void:
	_version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	_stage.show_loadout()
	_stage.add_extra(MONSTERS + "Dragon.fbx", Vector3(0.2, 0.0, -3.5), 3.4, 0.6)
	_stage.add_extra(CHARACTERS + "Ninja_Sand.fbx", Vector3(-1.7, 0.0, -1.2), 1.75)
	_stage.add_extra(CHARACTERS + "Goblin_Male.fbx", Vector3(1.7, 0.0, -1.2), 1.75)
	for path in SCENES_TO_LOAD:
		ResourceLoader.load_threaded_request(path)


func _process(delta: float) -> void:
	_elapsed += delta
	var loaded := 0.0
	var finished := true
	for path in SCENES_TO_LOAD:
		var progress := []
		if ResourceLoader.load_threaded_get_status(path, progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			finished = false
		loaded += progress[0] if not progress.is_empty() else 1.0
	# The bar never runs ahead of the minimum display time.
	_bar.value = minf(loaded / SCENES_TO_LOAD.size(), _elapsed / MINIMUM_TIME) * 100.0

	if finished and _elapsed >= MINIMUM_TIME:
		set_process(false)
		get_tree().change_scene_to_file(MENU_SCENE)
