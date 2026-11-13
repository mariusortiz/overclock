class_name FightTraining
extends Control
## The training (FightSetup.mode "training"), over the fight: a tutorial of
## eight steps that checks each move as it is done, a combo counter, and a
## button that changes what the dummy does. Nothing ends: health comes back
## (see Fight). The tutorial's first completion pays gems and a booster.

const DONE_KEY := "fight_training_done"
const REWARD_GEMS := 150
const GOLD := Color(1.0, 0.8, 0.25)
const CYAN := Color(0.16, 0.9, 1.0)
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
## [what to do, what is checked (see _check)].
const STEPS := [
	["Avance vers le mannequin, puis recule", "walk"],
	["Saute (haut)", "jump"],
	["Garde : recule quand le mannequin attaque", "guard"],
	["Uppercut : bas + POING", "uppercut"],
	["Tir : bas + ARME", "shot"],
	["Coup de pied sauté : avant + PIED", "dashkick"],
	["Ton spécial : bas + PIED", "signature"],
	["Ta jauge est pleine : SUPER !", "super"],
]

var player: Fighter
var dummy: Fighter
var dummy_input: FightDummy
var _step := 0
var _walked := {}
var _combo := 0
var _combo_damage := 0.0
var _combo_left := 0.0
var _dummy_health := 0.0
var _dummy_state := Fighter.State.IDLE
var _task := Label.new()
var _combo_label := Label.new()
var _mode_button := Button.new()


func setup(me: Fighter, other: Fighter, other_input: FightDummy) -> void:
	player = me
	dummy = other
	dummy_input = other_input
	player.move_started.connect(_on_move)
	player.super_used.connect(func(_f: Fighter) -> void: _passed("super"))
	_dummy_health = dummy.health


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for label: Label in [_task, _combo_label]:
		label.add_theme_font_override("font", FONT)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 8)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.anchor_right = 1.0
		add_child(label)
	_task.add_theme_font_size_override("font_size", 26)
	_task.add_theme_color_override("font_color", GOLD)
	_task.offset_top = 160
	_combo_label.add_theme_font_size_override("font_size", 34)
	_combo_label.add_theme_color_override("font_color", CYAN)
	_combo_label.offset_top = 205
	_mode_button.anchor_left = 1.0
	_mode_button.anchor_right = 1.0
	_mode_button.offset_left = -340
	_mode_button.offset_right = -24
	_mode_button.offset_top = 92
	_mode_button.offset_bottom = 148
	_mode_button.add_theme_font_size_override("font_size", 18)
	_mode_button.focus_mode = Control.FOCUS_NONE
	_mode_button.pressed.connect(func() -> void:
		dummy_input.next_mode()
		_refresh())
	add_child(_mode_button)
	_refresh()


func _refresh() -> void:
	_mode_button.text = "MANNEQUIN : %s" % FightDummy.NAMES[dummy_input.mode]
	if _step < STEPS.size():
		_task.text = "ÉTAPE %d / %d  ·  %s" % [_step + 1, STEPS.size(), STEPS[_step][0]]
	else:
		_task.text = "TUTORIEL TERMINÉ  ·  entraîne-toi librement"


func _physics_process(delta: float) -> void:
	if player == null:
		return
	# Combos: a hit while the dummy is still reeling from the last one adds up.
	if dummy.health < _dummy_health - 0.01:
		var taken := _dummy_health - dummy.health
		if _dummy_state in [Fighter.State.HITSTUN, Fighter.State.KNOCKDOWN, Fighter.State.FROZEN] and _combo_left > 0.0:
			_combo += 1
			_combo_damage += taken
		else:
			_combo = 1
			_combo_damage = taken
		_combo_left = 1.5
		_combo_label.text = ("COMBO x%d  ·  " % _combo if _combo > 1 else "") + "%d DÉGÂTS" % roundi(_combo_damage)
		_combo_label.modulate.a = 1.0
	_dummy_health = dummy.health
	_dummy_state = dummy.state
	_combo_left = maxf(_combo_left - delta, 0.0)
	if _combo_left <= 0.0:
		_combo_label.modulate.a = move_toward(_combo_label.modulate.a, 0.0, delta * 2.0)
	if _step >= STEPS.size():
		return
	match STEPS[_step][1]:
		"walk":
			var going := int(player.last_input.get("x", 0))
			if going != 0 and player.on_ground():
				_walked[going == player.facing] = true
			if _walked.size() == 2:
				_passed("walk")
		"jump":
			if player.state == Fighter.State.JUMP:
				_passed("jump")
		"guard":
			if player.state == Fighter.State.BLOCKSTUN:
				_passed("guard")


func _on_move(_fighter: Fighter, name: String) -> void:
	_passed(name)


## The step `what` is done if it is the current one: on to the next.
func _passed(what: String) -> void:
	if _step >= STEPS.size() or STEPS[_step][1] != what:
		return
	_step += 1
	Effects.burst(get_tree().current_scene, player.global_position + Vector3.UP * 2.0, GOLD, 24)
	if _step < STEPS.size():
		match STEPS[_step][1]:
			"guard":
				dummy_input.mode = "attack"
			"super":
				player.meter = Fighter.METER_MAX
			_:
				dummy_input.mode = "idle"
	else:
		dummy_input.mode = "idle"
		if not SaveData.load_progress(DONE_KEY, false):
			SaveData.save_progress(DONE_KEY, true)
			Wallet.add_gems(REWARD_GEMS)
			Cards.give_booster("standard")
			_task.text = "BRAVO ! +%d GEMMES ET UN BOOSTER" % REWARD_GEMS
			get_tree().create_timer(3.0).timeout.connect(_refresh)
			return
	_refresh()
