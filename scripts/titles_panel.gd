class_name TitlesPanel
extends Control
## Choosing the profile title and banner (see Titles): a preview on top, then
## a grid of the titles or of the banners. A locked one says how to get it;
## the ones sold for gems are bought here.

const CYAN := Color(0.16, 0.83, 1.0)
const GOLD := Color(1.0, 0.85, 0.3)

var _banners := false
var _preview_holder := Control.new()
var _info := Label.new()
var _grid := GridContainer.new()
var _switch := Button.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 120)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var panel := PanelContainer.new()
	margin.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	_preview_holder.custom_minimum_size.y = 110
	box.add_child(_preview_holder)
	_info.add_theme_font_size_override("font_size", 20)
	_info.add_theme_color_override("font_color", GOLD)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_info)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	TouchScroll.attach(scroll)
	_grid.columns = 3
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	box.add_child(buttons)
	_switch.custom_minimum_size.y = 60
	_switch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_switch.add_theme_font_size_override("font_size", 24)
	_switch.pressed.connect(func() -> void:
		_banners = not _banners
		_info.text = ""
		_refresh())
	buttons.add_child(_switch)
	var close := Button.new()
	close.text = "FERMER"
	close.custom_minimum_size.y = 60
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.add_theme_font_size_override("font_size", 24)
	close.pressed.connect(func() -> void: visible = false)
	buttons.add_child(close)


func open() -> void:
	_info.text = ""
	_refresh()
	visible = true


func _refresh() -> void:
	_switch.text = "VOIR LES TITRES" if _banners else "VOIR LES BANNIÈRES"
	for child in _preview_holder.get_children():
		child.queue_free()
	var preview := profile_card(Loadout.selected_character().name, Titles.selected_title(), Titles.selected_banner())
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_preview_holder.add_child(preview)
	for child in _grid.get_children():
		child.queue_free()
	var items: Array[Dictionary] = Titles.BANNERS if _banners else Titles.TITLES
	var chosen := Titles.selected_banner() if _banners else Titles.selected_title()
	for item in items:
		_grid.add_child(_card(item, item.id == chosen.id))


func _card(item: Dictionary, chosen: bool) -> Control:
	var unlocked := Titles.is_unlocked(item)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 78)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.clip_contents = true
	button.add_theme_font_size_override("font_size", 20)
	var state := "CHOISI" if chosen else ("" if unlocked else ("%d GEMMES" % item.gems if item.has("gems") else "VERROUILLÉ"))
	button.text = "%s\n%s" % [str(item.name).to_upper(), state]
	if _banners:
		var rect := Titles.banner_rect(item)
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.show_behind_parent = true
		rect.modulate = Color(1, 1, 1, 0.75)
		button.add_child(rect)
	if not unlocked:
		button.modulate = Color(1, 1, 1, 0.6)
	button.pressed.connect(_on_pressed.bind(item))
	return button


func _on_pressed(item: Dictionary) -> void:
	var key := Titles.BANNER_KEY if _banners else Titles.TITLE_KEY
	if Titles.is_unlocked(item):
		Titles.select(key, item)
		_info.text = ""
	elif item.has("gems"):
		if Wallet.buy(item.id, item.gems, "gems"):
			Titles.select(key, item)
			_info.text = "Acheté : %s" % item.name
		else:
			_info.text = "Il faut %d gemmes (tu en as %d)." % [item.gems, Wallet.gems()]
	else:
		_info.text = "%s : %s" % [item.name, Titles.unlock_text(item)]
	_refresh()


## The hero's name with the title under it, on the banner. Used here, on the
## home screen and in the lobby.
static func profile_card(hero_name: String, title: Dictionary, banner: Dictionary) -> Control:
	var card := Control.new()
	card.clip_contents = true
	var rect := Titles.banner_rect(banner)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.add_child(rect)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.35)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.add_child(shade)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(box)
	var name_label := Label.new()
	name_label.text = hero_name.to_upper()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 8)
	box.add_child(name_label)
	if title.id != Titles.NO_TITLE.id:
		var title_label := Label.new()
		title_label.text = "« %s »" % title.name
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 22)
		title_label.add_theme_color_override("font_color", GOLD)
		title_label.add_theme_color_override("font_outline_color", Color.BLACK)
		title_label.add_theme_constant_override("outline_size", 6)
		box.add_child(title_label)
	return card
