class_name SurvivalUI
extends CanvasLayer
## The survival mode's screen, over the game's HUD: hunger and thirst, the
## day and the hour, the bar of six slots, the buttons (ACTION, SAC,
## CONSTRUIRE), the bag with its crafting list, a chest, and the building bar.
## Everything works by touch; the keys are in SurvivalGame._unhandled_input.

const CYAN := Color(0.16, 0.83, 1.0)
const GOLD := Color(1.0, 0.85, 0.3)
const FONT_SIZE := 20

var game: SurvivalGame

var _food := ProgressBar.new()
var _water := ProgressBar.new()
var _clock := Label.new()
var _bar := HBoxContainer.new()
var _buttons := VBoxContainer.new()
var _build_bar := HFlowContainer.new()
var _panel := PanelContainer.new()
var _panel_box := VBoxContainer.new()
var _toast := Label.new()
var _toast_left := 0.0
var _chest: SurvivalPiece


func _ready() -> void:
	layer = 5
	var needs := VBoxContainer.new()
	needs.position = Vector2(20, 180)
	needs.add_theme_constant_override("separation", 6)
	add_child(needs)
	_clock.add_theme_font_size_override("font_size", 22)
	_clock.add_theme_color_override("font_outline_color", Color.BLACK)
	_clock.add_theme_constant_override("outline_size", 6)
	needs.add_child(_clock)
	for entry: Array in [[_food, "FAIM", Color(1.0, 0.6, 0.2)], [_water, "SOIF", Color(0.3, 0.7, 1.0)]]:
		var row := HBoxContainer.new()
		var label := _label(entry[1], 16)
		label.custom_minimum_size.x = 60
		row.add_child(label)
		var bar: ProgressBar = entry[0]
		bar.max_value = 100.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(170, 14)
		var fill := StyleBoxFlat.new()
		fill.bg_color = entry[2]
		bar.add_theme_stylebox_override("fill", fill)
		row.add_child(bar)
		needs.add_child(row)
	# The bar of six slots, at the bottom in the middle.
	_bar.anchor_left = 0.5
	_bar.anchor_right = 0.5
	_bar.anchor_top = 1.0
	_bar.anchor_bottom = 1.0
	_bar.offset_left = -330
	_bar.offset_right = 330
	_bar.offset_top = -86
	_bar.offset_bottom = -14
	_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_bar.add_theme_constant_override("separation", 6)
	add_child(_bar)
	# The buttons, on the right under the pause button.
	_buttons.anchor_left = 1.0
	_buttons.anchor_right = 1.0
	_buttons.offset_left = -190
	_buttons.offset_right = -16
	_buttons.offset_top = 120
	_buttons.add_theme_constant_override("separation", 8)
	add_child(_buttons)
	_button(_buttons, "ACTION", game.interact, GOLD)
	_button(_buttons, "SAC", toggle_inventory, CYAN)
	_button(_buttons, "CONSTRUIRE", func() -> void: game.set_building(not game.building), Color(0.5, 1.0, 0.6))
	# The building bar, above the slots.
	_build_bar.anchor_left = 0.5
	_build_bar.anchor_right = 0.5
	_build_bar.anchor_top = 1.0
	_build_bar.anchor_bottom = 1.0
	_build_bar.offset_left = -420
	_build_bar.offset_right = 420
	_build_bar.offset_top = -200
	_build_bar.offset_bottom = -92
	_build_bar.alignment = FlowContainer.ALIGNMENT_CENTER
	_build_bar.add_theme_constant_override("h_separation", 6)
	_build_bar.add_theme_constant_override("v_separation", 6)
	add_child(_build_bar)
	# The bag (or a chest), in the middle.
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_panel.custom_minimum_size = Vector2(980, 560)
	_panel.visible = false
	_panel_box.add_theme_constant_override("separation", 10)
	_panel.add_child(_panel_box)
	add_child(_panel)
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.offset_left = -400
	_toast.offset_right = 400
	_toast.offset_top = 150
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 24)
	_toast.add_theme_color_override("font_color", GOLD)
	_toast.add_theme_color_override("font_outline_color", Color.BLACK)
	_toast.add_theme_constant_override("outline_size", 6)
	add_child(_toast)
	refresh()


func _process(delta: float) -> void:
	_food.value = game.food
	_water.value = game.water
	_clock.text = game.clock_text() + ("  ·  NUIT" if game.is_night() else "")
	_toast_left -= delta
	_toast.modulate.a = clampf(_toast_left, 0.0, 1.0)


func is_open() -> bool:
	return _panel.visible


func toast(text: String) -> void:
	_toast.text = text
	_toast_left = 2.4


func refresh() -> void:
	if not is_inside_tree():
		return
	for child in _bar.get_children():
		child.queue_free()
	for index in SurvivalGame.HOTBAR_SIZE:
		var item: String = game.hotbar[index]
		var text := "%d\n%s" % [index + 1, SurvivalData.item_name(item) if item != "" else "—"]
		if item != "" and game.count(item) > 1:
			text += " ×%d" % game.count(item)
		var slot := _button(_bar, text, game.select_slot.bind(index), GOLD if index == game.selected else Color.WHITE)
		slot.custom_minimum_size = Vector2(104, 70)
		slot.add_theme_font_size_override("font_size", 14)
		slot.clip_text = true
	_refresh_build_bar()
	if _panel.visible:
		if _chest:
			_show_chest()
		else:
			_show_bag()


func _refresh_build_bar() -> void:
	for child in _build_bar.get_children():
		child.queue_free()
	_build_bar.visible = game.building
	if not game.building:
		return
	for piece: String in SurvivalData.PIECES:
		var info: Dictionary = SurvivalData.PIECES[piece]
		var owned := 0
		if info.get("station", false):
			owned = game.count("piece:" + piece)
			if owned <= 0:
				continue
		var text: String = info.name + (" ×%d" % owned if owned > 0 else "")
		var button := _button(_build_bar, text, game.choose_piece.bind(piece), GOLD if piece == game.build_piece else Color.WHITE)
		button.add_theme_font_size_override("font_size", 15)
	for material_id: String in SurvivalData.MATERIALS:
		var button := _button(_build_bar, "%s (%d)" % [SurvivalData.MATERIALS[material_id].name, game.count(material_id)],
				game.choose_piece.bind(game.build_piece, material_id), CYAN if material_id == game.build_material else Color(0.7, 0.7, 0.75))
		button.add_theme_font_size_override("font_size", 15)
	_button(_build_bar, "POSER", game.place_piece, Color(0.5, 1.0, 0.6)).add_theme_font_size_override("font_size", 15)
	_button(_build_bar, "TOURNER", game.rotate_piece).add_theme_font_size_override("font_size", 15)
	_button(_build_bar, "DÉMONTER", game.dismantle, Color(1.0, 0.5, 0.4)).add_theme_font_size_override("font_size", 15)
	var cost := game.piece_cost()
	var parts: Array[String] = []
	for item: String in cost:
		parts.append("%d %s" % [cost[item], SurvivalData.item_name(item)])
	var label := _label("Coût : " + (", ".join(parts) if not parts.is_empty() else "rien"), 16)
	_build_bar.add_child(label)


# --- The bag and the crafting list ------------------------------------------------------------

func toggle_inventory() -> void:
	_chest = null
	_panel.visible = not _panel.visible
	_set_mouse(_panel.visible)
	if _panel.visible:
		_show_bag()


func _set_mouse(free: bool) -> void:
	if free:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game.player.set_process_unhandled_input(not free)


func _clear_panel() -> void:
	for child in _panel_box.get_children():
		child.queue_free()


func _show_bag() -> void:
	_clear_panel()
	_panel_box.add_child(_label("SAC  ·  touche un objet : le manger, ou le mettre dans l'emplacement %d" % (game.selected + 1), 18, CYAN))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel_box.add_child(columns)
	# The items.
	var bag_scroll := ScrollContainer.new()
	bag_scroll.custom_minimum_size = Vector2(440, 440)
	bag_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	TouchScroll.attach(bag_scroll)
	columns.add_child(bag_scroll)
	var bag := GridContainer.new()
	bag.columns = 3
	bag.add_theme_constant_override("h_separation", 6)
	bag.add_theme_constant_override("v_separation", 6)
	bag_scroll.add_child(bag)
	var items := game.inventory.keys()
	items.sort()
	if items.is_empty():
		bag.add_child(_label("Vide. Frappe un arbre, un rocher ou un buisson.", 16))
	for item: String in items:
		var button := _button(bag, "%s\n×%d" % [SurvivalData.item_name(item), game.count(item)], _use_item.bind(item))
		button.custom_minimum_size = Vector2(140, 64)
		button.add_theme_font_size_override("font_size", 14)
	# The recipes.
	var recipes_box := VBoxContainer.new()
	recipes_box.add_theme_constant_override("separation", 4)
	var stations := game.stations_near()
	var names: Array[String] = []
	for station: String in stations:
		names.append(SurvivalData.STATIONS[station])
	recipes_box.add_child(_label("FABRIQUER  ·  près de : %s" % (", ".join(names) if not names.is_empty() else "rien"), 16, GOLD))
	var recipes_scroll := ScrollContainer.new()
	recipes_scroll.custom_minimum_size = Vector2(480, 420)
	recipes_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	TouchScroll.attach(recipes_scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	recipes_scroll.add_child(list)
	recipes_box.add_child(recipes_scroll)
	columns.add_child(recipes_box)
	for recipe: Array in SurvivalData.RECIPES:
		var parts: Array[String] = []
		for item: String in recipe[2]:
			parts.append("%d %s" % [recipe[2][item], SurvivalData.item_name(item)])
		var where: String = "" if recipe[3] == "" else "  [%s]" % SurvivalData.STATIONS[recipe[3]]
		var text := "%s%s : %s%s" % [SurvivalData.item_name(recipe[0]), " ×%d" % recipe[1] if recipe[1] > 1 else "", ", ".join(parts), where]
		var ready := game.can_craft(recipe)
		var button := _button(list, text, func() -> void:
			game.craft(recipe)
			_show_bag(), Color(0.5, 1.0, 0.6) if ready else Color(1, 1, 1, 0.45))
		button.add_theme_font_size_override("font_size", 14)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 40
	_button(_panel_box, "FERMER", toggle_inventory).size_flags_horizontal = Control.SIZE_SHRINK_CENTER


## Tapping an item: food and heals are used, tools and guns go to the
## selected slot.
func _use_item(item: String) -> void:
	if game.consume(item):
		toast("%s : faim %d, soif %d" % [SurvivalData.item_name(item), int(game.food), int(game.water)])
	elif SurvivalData.ITEMS.get(item, {}).get("kind", "") in ["tool", "gun"]:
		var old := game.hotbar.find(item)
		if old >= 0:
			game.hotbar[old] = ""
		game.hotbar[game.selected] = item
		game.select_slot(game.selected)
	elif item.begins_with("piece:"):
		toggle_inventory()
		game.choose_piece(item.trim_prefix("piece:"))
		game.set_building(true)
		return
	_show_bag()
	refresh()


# --- A chest ----------------------------------------------------------------------------------

func open_chest(chest: SurvivalPiece) -> void:
	_chest = chest
	_panel.visible = true
	_set_mouse(true)
	_show_chest()


func _show_chest() -> void:
	_clear_panel()
	_panel_box.add_child(_label("COFFRE  ·  touche un objet pour le déplacer (tout le tas)", 18, CYAN))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 30)
	_panel_box.add_child(columns)
	for side: Array in [["SAC", game.inventory, true], ["COFFRE", _chest.content, false]]:
		var box := VBoxContainer.new()
		box.custom_minimum_size.x = 440
		box.add_child(_label(side[0], 18, GOLD))
		var grid := GridContainer.new()
		grid.columns = 3
		box.add_child(grid)
		var source: Dictionary = side[1]
		for item: String in source.keys():
			var button := _button(grid, "%s\n×%d" % [SurvivalData.item_name(item), int(source[item])], _move.bind(item, side[2]))
			button.custom_minimum_size = Vector2(140, 60)
			button.add_theme_font_size_override("font_size", 14)
		columns.add_child(box)
	_button(_panel_box, "FERMER", func() -> void:
		_chest = null
		_panel.visible = false
		_set_mouse(false)).size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _move(item: String, to_chest: bool) -> void:
	if to_chest:
		var amount := game.count(item)
		game.remove(item, amount)
		_chest.content[item] = int(_chest.content.get(item, 0)) + amount
	else:
		var amount := int(_chest.content.get(item, 0))
		_chest.content.erase(item)
		game.add(item, amount)
	_show_chest()


# --- Helpers ------------------------------------------------------------------------------------

func _button(parent: Node, text: String, action: Callable, color := Color.WHITE) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 56
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	button.add_theme_color_override("font_color", color)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action, CONNECT_DEFERRED)
	parent.add_child(button)
	return button


func _label(text: String, size: int, color := Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	return label
