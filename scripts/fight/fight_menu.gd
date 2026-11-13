extends Control
## The fight mode's menu (scenes/fight_menu.tscn): the kind of fight (against
## the computer, two players on this device, arcade, Wi-Fi), the two
## fighters (player 1 picks among the heroes they own; the opponent among
## all but Le Créateur, or at random), the arena and the difficulty. The two
## fighters stand in 3D on each side.

const STAGE_SCENE := preload("res://scenes/ui/character_stage.tscn")
const MENU_SCENE := "res://scenes/menu.tscn"
const LOBBY_SCENE := "res://scenes/lobby.tscn"
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.3, 0.85)
const GOLD := Color(1.0, 0.8, 0.25)
const MODES := [["ai", "VS IA"], ["versus", "2 JOUEURS"], ["arcade", "ARCADE"], ["training", "ENTRAÎNEMENT"], ["online", "WI-FI"]]
const DIFFICULTIES := ["FACILE", "NORMAL", "DIFFICILE"]
const RANDOM := ""

## Which fighter the hero buttons choose: 0 player 1, 1 the opponent.
var _picking := 0
## The opponent's hero id, RANDOM for one at random.
var _opponent := RANDOM
var _stages: Array[CharacterStage] = []
var _modes := HBoxContainer.new()
var _pickers := HBoxContainer.new()
var _grid := GridContainer.new()
var _arenas := HFlowContainer.new()
var _levels := HBoxContainer.new()
var _hint := Label.new()
var _go := Button.new()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.FIGHT_MENU)
	if FightSetup.mode == "online":
		FightSetup.mode = "ai"
	if not Loadout.is_unlocked(Loadout.find(FightSetup.heroes[0]).item):
		FightSetup.heroes[0] = Loadout.selected_character().id
	var background := ColorRect.new()
	background.color = Color(0.02, 0.04, 0.16)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	for side in 2:
		var stage: CharacterStage = STAGE_SCENE.instantiate()
		stage.anchor_top = 0.12
		stage.anchor_bottom = 0.86
		stage.anchor_left = 0.0 if side == 0 else 0.78
		stage.anchor_right = 0.22 if side == 0 else 1.0
		stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(stage)
		_stages.append(stage)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	page.add_child(top)
	var back := _button("<  MENU", func() -> void: get_tree().change_scene_to_file.call_deferred(MENU_SCENE))
	back.custom_minimum_size.x = 150
	top.add_child(back)
	var title := Label.new()
	title.text = "COMBAT"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", GOLD)
	top.add_child(title)
	_modes.add_theme_constant_override("separation", 8)
	_modes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_modes.alignment = BoxContainer.ALIGNMENT_END
	top.add_child(_modes)
	# The middle: who chooses, and the heroes.
	var middle := VBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	middle.custom_minimum_size.x = 700
	middle.add_theme_constant_override("separation", 8)
	page.add_child(middle)
	_pickers.alignment = BoxContainer.ALIGNMENT_CENTER
	_pickers.add_theme_constant_override("separation", 8)
	middle.add_child(_pickers)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	middle.add_child(scroll)
	TouchScroll.attach(scroll)
	_grid.columns = 3
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(_grid)
	# The bottom: arena, difficulty, go.
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 14)
	page.add_child(bottom)
	var settings := VBoxContainer.new()
	settings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(settings)
	_arenas.add_theme_constant_override("h_separation", 6)
	_arenas.add_theme_constant_override("v_separation", 6)
	settings.add_child(_arenas)
	_levels.add_theme_constant_override("separation", 6)
	settings.add_child(_levels)
	_hint.add_theme_font_size_override("font_size", 16)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings.add_child(_hint)
	_go.text = "COMBAT !"
	_go.custom_minimum_size = Vector2(260, 96)
	_go.theme_type_variation = &"PrimaryButton"
	_go.add_theme_font_size_override("font_size", 36)
	_go.pressed.connect(_start)
	bottom.add_child(_go)
	_refresh()


func _refresh() -> void:
	for box: Node in [_modes, _pickers, _grid, _arenas, _levels]:
		for child in box.get_children():
			child.queue_free()
	var mode := FightSetup.mode
	for entry: Array in MODES:
		var id: String = entry[0]
		var button := _button(entry[1], func() -> void:
			if id == "online":
				get_tree().change_scene_to_file.call_deferred(LOBBY_SCENE)
				return
			FightSetup.mode = id
			_picking = 0
			_refresh(), mode == id)
		button.add_theme_font_size_override("font_size", 15)
		if id == "online" and not Net.is_supported():
			button.disabled = true
			button.tooltip_text = "Pas dans le navigateur : avec l'application."
		_modes.add_child(button)
	# Who picks: player 1, and in a versus player 2, against the computer its hero.
	if mode != "arcade":
		_pickers.add_child(_button("JOUEUR 1", func() -> void:
			_picking = 0
			_refresh(), _picking == 0, CYAN))
		_pickers.add_child(_button("JOUEUR 2" if mode == "versus" else ("MANNEQUIN" if mode == "training" else "ADVERSAIRE"), func() -> void:
			_picking = 1
			_refresh(), _picking == 1, MAGENTA))
	if _picking == 1 and mode in ["ai", "training"]:
		var random := _button("AU HASARD", func() -> void:
			_opponent = RANDOM
			_refresh(), _opponent == RANDOM, MAGENTA)
		random.custom_minimum_size = Vector2(222, 54)
		random.add_theme_font_size_override("font_size", 15)
		_grid.add_child(random)
	for item: Dictionary in Loadout.CHARACTERS:
		var id: String = item.id
		var open := Loadout.is_unlocked(item)
		if _picking == 1 and mode in ["ai", "training"]:
			open = not item.get("code", false)
		var chosen := FightSetup.heroes[0] == id if _picking == 0 else (FightSetup.heroes[1] == id if mode == "versus" else _opponent == id)
		var button := _button(str(item.name).to_upper(), func() -> void:
			if _picking == 0:
				FightSetup.heroes[0] = id
			elif mode == "versus":
				FightSetup.heroes[1] = id
			else:
				_opponent = id
			_refresh(), chosen, CYAN if _picking == 0 else MAGENTA)
		button.disabled = not open
		button.custom_minimum_size = Vector2(222, 54)
		button.add_theme_font_size_override("font_size", 15)
		button.clip_text = true
		_grid.add_child(button)
	if mode == "versus" and not Loadout.is_unlocked(Loadout.find(FightSetup.heroes[1]).item):
		FightSetup.heroes[1] = FightSetup.heroes[0]
	# Arena and difficulty.
	_arenas.visible = mode != "arcade"
	_arenas.add_child(_button("AU HASARD", func() -> void:
		FightSetup.arena = -1
		_refresh(), FightSetup.arena == -1))
	for index in FightSetup.arena_count():
		_arenas.add_child(_button(FightSetup.ARENA_NAMES[index].to_upper(), func() -> void:
			FightSetup.arena = index
			_refresh(), FightSetup.arena == index))
	_levels.visible = mode == "ai"
	for index in DIFFICULTIES.size():
		_levels.add_child(_button(DIFFICULTIES[index], func() -> void:
			FightSetup.difficulty = index
			_refresh(), FightSetup.difficulty == index, GOLD))
	match mode:
		"versus":
			_hint.text = "Deux joueurs sur cet appareil : clavier (ZQSD + F G H, R / flèches + J K L, I), deux manettes, ou l'écran partagé en deux."
		"training":
			_hint.text = "Un mannequin qui ne tombe jamais, un tutoriel en 8 étapes (la première fois : %d gemmes et un booster), un compteur de combo." % FightTraining.REWARD_GEMS
		"arcade":
			_hint.text = "%d combats contre l'ordinateur, de plus en plus durs, puis le Titan Mk II dans la ville. Première victoire : %d gemmes et un booster rare." % [
					FightSetup.ARCADE_FIGHTS, FightSetup.ARCADE_GEMS]
		_:
			_hint.text = "Garde en reculant. Bas + POING : uppercut · Bas + ARME : tir · Avant + PIED : coup sauté. SUPER : l'ulti du héros, jauge pleine."
	_stages[0].show_character(Loadout.find(FightSetup.heroes[0]).item)
	var right := FightSetup.heroes[1] if mode == "versus" else _opponent
	_stages[1].visible = mode != "arcade" and right != RANDOM
	if _stages[1].visible:
		_stages[1].show_character(Loadout.find(right).item)


func _start() -> void:
	match FightSetup.mode:
		"arcade":
			FightSetup.start_arcade(FightSetup.heroes[0])
		"ai", "training":
			var pool := FightSetup.computer_heroes()
			FightSetup.heroes[1] = _opponent if _opponent != RANDOM else pool.pick_random()
	get_tree().change_scene_to_file.call_deferred(FightSetup.SCENE)


func _button(text: String, action: Callable, pressed := false, color := Color.WHITE) -> Button:
	var button := Button.new()
	button.text = text
	button.toggle_mode = true
	button.button_pressed = pressed
	button.custom_minimum_size.y = 52
	button.add_theme_font_size_override("font_size", 18)
	if pressed:
		button.add_theme_color_override("font_color", color)
		button.add_theme_color_override("font_pressed_color", Color.BLACK)
	button.pressed.connect(action)
	return button
