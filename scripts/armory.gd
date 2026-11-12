extends Control
## Armory: pick the character, the weapon, the melee weapon and a skin for
## each of the two from a grid of cards. Locked items can be previewed but not equipped.

const MENU_SCENE := "res://scenes/menu.tscn"
const CARD_SIZE := Vector2(214, 108)
## Characters that fit on one line of a card.
const CARD_LINE_LENGTH := 12
## Five tabs share the width of the panel.
const TAB_FONT_SIZE := 17

## One tab per kind of item. "stats" lists what the detail panel shows:
## [label, key in the item, value that fills the bar].
var _tabs := [
	{"label": "HÉROS", "key": Loadout.CHARACTER_KEY, "items": Loadout.CHARACTERS, "stats": []},
	{"label": "ARME", "key": Loadout.WEAPON_KEY, "items": Loadout.WEAPONS,
		"stats": [["CADENCE", "fire_rate", 14.0], ["DÉGÂTS", "damage", 10.0], ["CHARGEUR", "magazine", 40.0]]},
	{"label": "MÊLÉE", "key": Loadout.MELEE_KEY, "items": Loadout.MELEE,
		"stats": [["DÉGÂTS", "damage", 10.0], ["PORTÉE", "range", 4.5], ["VITESSE", "speed", 3.4]]},
	{"label": "SKIN ARME", "key": Loadout.SKIN_KEY, "items": Loadout.SKINS, "stats": []},
	{"label": "SKIN MÊLÉE", "key": Loadout.MELEE_SKIN_KEY, "items": Loadout.SKINS, "stats": []},
]
var _tab_index := 0
var _viewed: Dictionary

@onready var _stage: CharacterStage = $Stage
@onready var _tab_bar: HBoxContainer = $Right/Box/Tabs
@onready var _grid: GridContainer = $Right/Box/Scroll/Grid
@onready var _detail_name: Label = $Right/Box/Detail/Box/Name
@onready var _detail_status: Label = $Right/Box/Detail/Box/Status
@onready var _detail_stats: VBoxContainer = $Right/Box/Detail/Box/Stats


func _ready() -> void:
	_stage.show_loadout()
	$Back.pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	for i in _tabs.size():
		var button := Button.new()
		button.text = _tabs[i].label
		button.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
		button.toggle_mode = true
		button.custom_minimum_size.y = 64
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select_tab.bind(i))
		_tab_bar.add_child(button)
	_select_tab(0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


func _select_tab(index: int) -> void:
	_tab_index = index
	for i in _tab_bar.get_child_count():
		(_tab_bar.get_child(i) as Button).button_pressed = i == index
	_viewed = _equipped()
	# Weapons are shown alone, floating; the character only in its own tab.
	match _tabs[index].key:
		Loadout.CHARACTER_KEY:
			_stage.focus(CharacterStage.Focus.CHARACTER)
		Loadout.MELEE_KEY, Loadout.MELEE_SKIN_KEY:
			_stage.focus(CharacterStage.Focus.MELEE)
		_:
			_stage.focus(CharacterStage.Focus.WEAPON)
	_stage.show_loadout()
	_refresh()


func _equipped() -> Dictionary:
	match _tabs[_tab_index].key:
		Loadout.WEAPON_KEY:
			return Loadout.selected_weapon()
		Loadout.MELEE_KEY:
			return Loadout.selected_melee()
		Loadout.SKIN_KEY:
			return Loadout.selected_skin()
		Loadout.MELEE_SKIN_KEY:
			return Loadout.selected_melee_skin()
	return Loadout.selected_character()


## Rebuilds the cards and the detail panel for the current tab.
func _refresh() -> void:
	for card in _grid.get_children():
		_grid.remove_child(card)
		card.queue_free()
	var equipped := _equipped()
	for item: Dictionary in _tabs[_tab_index].items:
		var card := Button.new()
		card.custom_minimum_size = CARD_SIZE
		card.toggle_mode = true
		# Long names wrap instead of widening the grid past the screen.
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.button_pressed = item == _viewed
		card.disabled = false
		var status := ""
		if item == equipped:
			status = "ÉQUIPÉ"
		elif not Loadout.is_unlocked(item):
			status = "VERROUILLÉ"
			card.modulate = Color(1, 1, 1, 0.55)
		# A long hyphenated name is split at the hyphen rather than mid-word.
		var title: String = item.name
		if title.length() > CARD_LINE_LENGTH:
			title = title.replace("-", "-\n")
		card.text = "%s\n%s" % [title, status]
		card.pressed.connect(_on_card_pressed.bind(item))
		_grid.add_child(card)

	_detail_name.text = _viewed.name
	if not Loadout.is_unlocked(_viewed):
		_detail_status.text = Loadout.unlock_text(_viewed)
	else:
		_detail_status.text = "Équipé"
	if _viewed.has("kill") and Loadout.KILL_NAMES.has(_viewed.kill) and _tabs[_tab_index].key == Loadout.SKIN_KEY:
		_detail_status.text += "\nÉlimination : %s" % Loadout.KILL_NAMES[_viewed.kill]
	if _viewed.has("pellets"):
		_detail_status.text += "\n%d plombs par tir" % _viewed.pellets
	if _viewed.has("ulti"):
		var ulti: Dictionary = Ultimate.INFO[_viewed.ulti]
		_detail_status.text += "\nULTI · %s : %s" % [ulti.name, ulti.text]
	for bar in _detail_stats.get_children():
		_detail_stats.remove_child(bar)
		bar.queue_free()
	for stat: Array in _tabs[_tab_index].stats:
		# A melee weapon's speed is its number of blows per second.
		var value: float = 1.0 / _viewed.cooldown if stat[1] == "speed" else _viewed[stat[1]]
		_add_stat(stat[0], value, stat[2])


## Previews the item, and equips it when it is unlocked.
func _on_card_pressed(item: Dictionary) -> void:
	_viewed = item
	var key: String = _tabs[_tab_index].key
	if Loadout.is_unlocked(item):
		Loadout.select(key, item)
	match key:
		Loadout.CHARACTER_KEY:
			_stage.show_character(item)
		Loadout.WEAPON_KEY:
			_stage.show_weapon(item)
		Loadout.MELEE_KEY:
			_stage.show_melee(item)
		Loadout.SKIN_KEY:
			_stage.show_weapon(Loadout.selected_weapon(), item)
		Loadout.MELEE_SKIN_KEY:
			_stage.show_melee(Loadout.selected_melee(), item)
	# Deferred: the cards are rebuilt, and one of them is handling this click.
	_refresh.call_deferred()


func _add_stat(label_text: String, value: float, full: float) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	label.add_theme_font_size_override("font_size", 20)
	row.add_child(label)
	var bar := ProgressBar.new()
	bar.max_value = full
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 18)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	var number := Label.new()
	number.text = String.num(value, 1).trim_suffix(".0")
	number.custom_minimum_size.x = 50
	number.add_theme_font_size_override("font_size", 20)
	row.add_child(number)
	_detail_stats.add_child(row)
