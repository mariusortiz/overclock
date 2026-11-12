class_name Tutorial
extends Node
## First game only: a few hints, one at a time, each gone as soon as the
## player has done what it says. Once the player has moved, shot an enemy
## down and struck in close combat, it never shows again; the hint about the
## ultimate still comes in that game, when its gauge fills.

const DONE_KEY := "tutorial_done"
## Distance to walk before the first hint is done, in meters.
const MOVE_DISTANCE := 4.0
## A beat between two hints, in seconds.
const PAUSE := 1.2

enum Step { MOVE, SHOOT, MELEE, WAIT_ULTIMATE, ULTIMATE, DONE }

const TOUCH_TEXT := {
	Step.MOVE: "Pose le pouce sur la gauche de l'écran et glisse pour te déplacer",
	Step.SHOOT: "Glisse à droite pour viser, puis appuie sur TIR pour abattre un ennemi",
	Step.MELEE: "Ennemi au contact ? Appuie sur COUP pour frapper",
	Step.ULTIMATE: "Ta jauge d'ulti est pleine : appuie sur ULTI",
}
const DESKTOP_TEXT := {
	Step.MOVE: "ZQSD pour te déplacer, la souris pour regarder",
	Step.SHOOT: "Clic gauche pour tirer : abats un ennemi",
	Step.MELEE: "Ennemi au contact ? F pour frapper",
	Step.ULTIMATE: "Ta jauge d'ulti est pleine : appuie sur E",
}
## Touch button to draw attention to during each step.
const BUTTON := {Step.SHOOT: &"fire", Step.MELEE: &"melee", Step.ULTIMATE: &"ultimate"}

var _step := Step.MOVE
var _player: Player
var _hud: Hud
var _start := Vector3.ZERO
var _waiting := false


static func is_needed() -> bool:
	return not SaveData.load_progress(DONE_KEY, false)


func setup(player: Player, hud: Hud, waves: WaveManager) -> void:
	_player = player
	_hud = hud
	_start = player.global_position
	waves.enemy_killed.connect(_complete.bind(Step.SHOOT))
	player.melee.swung.connect(_complete.bind(Step.MELEE))
	player.ultimate.charge_changed.connect(_on_ultimate_charge)
	player.ultimate.activated.connect(func(_name: String) -> void: _complete(Step.ULTIMATE))
	player.died.connect(_finish)
	_show()


func _physics_process(_delta: float) -> void:
	if _step == Step.MOVE and _player.global_position.distance_to(_start) > MOVE_DISTANCE:
		_complete(Step.MOVE)


func _on_ultimate_charge(ratio: float) -> void:
	if _step == Step.WAIT_ULTIMATE and ratio >= 1.0:
		_step = Step.ULTIMATE
		_show()


func _complete(step: Step) -> void:
	if step != _step or _waiting:
		return
	_hud.hide_hint()
	if step == Step.MELEE:
		# The basics are known: no tutorial in the next games.
		SaveData.save_progress(DONE_KEY, true)
	if step == Step.ULTIMATE:
		_finish()
		return
	_waiting = true
	await get_tree().create_timer(PAUSE, false).timeout
	_waiting = false
	_step = (step + 1) as Step
	if _step == Step.WAIT_ULTIMATE and _player.ultimate.charge >= 1.0:
		_step = Step.ULTIMATE
	_show()


func _show() -> void:
	if not TOUCH_TEXT.has(_step):
		_hud.hide_hint()
		return
	var touch := _hud.touch_controls.visible
	_hud.show_hint((TOUCH_TEXT if touch else DESKTOP_TEXT)[_step], BUTTON.get(_step, &""))


func _finish(_unused: Variant = null) -> void:
	_step = Step.DONE
	_hud.hide_hint()
	queue_free()
