extends Control
## Start-up screen: shows the artwork (assets/ui/loading_art.jpg, see
## tools/make_poster.py) while the other scenes load, then opens the menu. Scenes are loaded one per frame so the bar can move; background
## (threaded) loading failed on the arena shader.

const MENU_SCENE := "res://scenes/menu.tscn"
const SCENES_TO_LOAD: Array[String] = [
	MENU_SCENE, "res://scenes/armory.tscn", "res://scenes/battle_pass.tscn", "res://scenes/main.tscn",
]
const MINIMUM_TIME := 2.0
const FRAMES_BEFORE_LOADING := 3  # let the screen appear first

var _elapsed := 0.0
var _frames := 0
## Keeps the loaded scenes in memory until the menu takes over.
var _loaded: Array[Resource] = []

@onready var _bar: ProgressBar = $Bottom/Bar
@onready var _version: Label = $Version
@onready var _tip: Label = $Bottom/Label


## One is shown, at random, while the game loads.
const TIPS: Array[String] = [
	"Un tir à la tête fait le double de dégâts.",
	"Les tireurs d'élite te visent au laser : sors de leur ligne de vue.",
	"Abats les kamikazes de loin : ils explosent quand ils tombent.",
	"Après un boss, rentrer au menu rapporte toute l'XP. Mourir, la moitié.",
	"Chaque skin a sa propre façon d'éliminer les ennemis.",
	"Les ennemis d'élite lâchent toujours un bonus.",
	"Les défis du jour rapportent de l'XP, même si tu meurs.",
	"Plusieurs éliminations à la suite rapportent des points en plus.",
	"Saute pour éviter l'onde de choc du Titan.",
	"Les caisses qui tombent du ciel contiennent une autre arme.",
	"Bouton DANSE : six danses, la caméra passe devant ton héros.",
	"Les coffres sur les passerelles rapportent de l'XP.",
]


func _ready() -> void:
	_version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	_tip.text = TIPS.pick_random()


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
