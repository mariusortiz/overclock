extends Control
## The card album: the cards by series (owned ones in color, missing ones
## dark), the boosters waiting to be opened, the dust and the series
## rewards. A card opens large, with a button to craft it if missing.

const MENU_SCENE := "res://scenes/menu.tscn"
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)
const CARD_SIZE := Vector2(150, 210)

var _series := 0
var _top := HBoxContainer.new()
var _actions := HBoxContainer.new()
var _tabs := HBoxContainer.new()
var _grid := GridContainer.new()
var _footer := HBoxContainer.new()
var _overlay := Control.new()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var background := ColorRect.new()
	background.color = Color(0.02, 0.04, 0.16)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	_top.add_theme_constant_override("separation", 10)
	box.add_child(_top)
	_actions.add_theme_constant_override("separation", 10)
	box.add_child(_actions)
	var tab_scroll := ScrollContainer.new()
	tab_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tab_scroll.custom_minimum_size.y = 62
	tab_scroll.add_child(_tabs)
	box.add_child(tab_scroll)
	TouchScroll.attach(tab_scroll)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	TouchScroll.attach(scroll)
	_grid.columns = 7
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_grid)
	_footer.add_theme_constant_override("separation", 12)
	box.add_child(_footer)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)
	resized.connect(_fit_columns)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _overlay.visible:
			_close_overlay()
		else:
			get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


func _unhandled_key_input(event: InputEvent) -> void:
	# Test shortcut (debug and web builds): F7 gives three boosters of each kind.
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_F7 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		Cards.give_booster("standard", 3)
		Cards.give_booster("rare", 3)
		_refresh()


func _fit_columns() -> void:
	_grid.columns = maxi(int((size.x - 40.0) / (CARD_SIZE.x + 12.0)), 2)


func _refresh() -> void:
	for container: Node in [_top, _actions, _tabs, _grid, _footer]:
		for child in container.get_children():
			child.queue_free()
	_button(_top, "< RETOUR", func() -> void: get_tree().change_scene_to_file.call_deferred(MENU_SCENE))
	var title := Label.new()
	title.text = "CARTES  %d / %d  ·  POUSSIÈRE %d" % [Cards.owned_total(), Cards.CATALOG.size(), Cards.dust()]
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", CYAN)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_top.add_child(title)
	var pending := Cards.boosters()
	var open_standard := _button(_actions, "OUVRIR UN BOOSTER (%d)" % pending.get("standard", 0), _open.bind("standard"), CYAN)
	open_standard.disabled = pending.get("standard", 0) <= 0
	var open_rare := _button(_actions, "BOOSTER RARE (%d)" % pending.get("rare", 0), _open.bind("rare"), GOLD)
	open_rare.disabled = pending.get("rare", 0) <= 0
	_button(_actions, "RECYCLER LES DOUBLONS", _recycle)

	for index in Cards.SERIES.size():
		var series: String = Cards.SERIES[index][0]
		var done := Cards.in_series(series).filter(func(card: Dictionary) -> bool: return Cards.count(card.id) > 0).size()
		var tab := _button(_tabs, "%s %d/%d" % [series.to_upper(), done, Cards.in_series(series).size()], _select.bind(index))
		tab.toggle_mode = true
		tab.button_pressed = index == _series
		tab.custom_minimum_size.y = 56
		tab.add_theme_font_size_override("font_size", 18)

	var shown: String = Cards.SERIES[_series][0]
	for card: Dictionary in Cards.in_series(shown):
		var view := CardView.new(card, Cards.count(card.id) > 0, Cards.count(card.id))
		view.custom_minimum_size = CARD_SIZE
		view.gui_input.connect(func(event: InputEvent) -> void:
			# On release: a finger sliding to scroll the grid opens nothing
			# (TouchScroll keeps that release from the card).
			if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_show_card(card))
		_grid.add_child(view)

	var reward: Array = Cards.SERIES[_series]
	var line := Label.new()
	line.add_theme_font_size_override("font_size", 20)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.text = "Série complète : +%d crédits, +%d gemmes." % [reward[1], reward[2]]
	if shown == "Mythiques":
		line.text += " L'album entier débloque le skin Collectionneur."
	_footer.add_child(line)
	if Cards.is_claimed(shown):
		line.text += "  (déjà reçue)"
	else:
		var claim := _button(_footer, "RÉCUPÉRER", func() -> void:
			Cards.claim(shown)
			_refresh(), GOLD)
		claim.disabled = not Cards.series_done(shown)
	_fit_columns()


func _select(index: int) -> void:
	_series = index
	_refresh.call_deferred()


func _recycle() -> void:
	var gained := Cards.recycle_duplicates()
	_refresh()
	_flash_message("+%d poussière" % gained if gained > 0 else "Aucun doublon")


func _button(parent: Node, text: String, action: Callable, color := Color.WHITE) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 60
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", color)
	button.pressed.connect(action, CONNECT_DEFERRED)
	parent.add_child(button)
	return button


# --- Overlays ---------------------------------------------------------------------

func _open_overlay() -> VBoxContainer:
	for child in _overlay.get_children():
		child.queue_free()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	_overlay.visible = true
	return box


func _close_overlay() -> void:
	_overlay.visible = false
	_refresh()


## One card, large, with what to do with it.
func _show_card(card: Dictionary) -> void:
	var box := _open_overlay()
	var owned := Cards.count(card.id) > 0
	var view := CardView.new(card, owned, Cards.count(card.id))
	view.custom_minimum_size = Vector2(300, 420)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(view)
	var info := Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 20)
	info.text = "%s · %s · %s" % [card.series, Cards.RARITY[card.rarity].name, "%d exemplaire%s" % [Cards.count(card.id), "s" if Cards.count(card.id) > 1 else ""] if owned else "manquante"]
	box.add_child(info)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	if not owned:
		var craft := _button(row, "FABRIQUER · %d POUSSIÈRE" % Cards.craft_cost(card.id), func() -> void:
			if Cards.craft(card.id):
				_show_card(card), GOLD)
		craft.disabled = Cards.dust() < Cards.craft_cost(card.id)
	else:
		_button(row, "ENVOYER", _confirm_send.bind(card), MAGENTA)
	_button(row, "FERMER", _close_overlay)


## Sending takes the card out of the collection: ask first.
func _confirm_send(card: Dictionary) -> void:
	var box := _open_overlay()
	var text := Label.new()
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 620
	text.add_theme_font_size_override("font_size", 22)
	var left := Cards.count(card.id) - 1
	text.text = "Envoyer %s ?\nTu obtiens un code à donner : la carte quitte ta collection (il t'en restera %d), et celui qui tape le code dans CODE, sur l'accueil, la reçoit." % [card.name, left]
	box.add_child(text)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	_button(row, "ENVOYER", func() -> void: _show_sent(card, Trade.send(card.id)), MAGENTA)
	_button(row, "ANNULER", _show_card.bind(card))


## The code of a card just sent, with buttons to copy it or its web page.
func _show_sent(card: Dictionary, code: String) -> void:
	var box := _open_overlay()
	var title := Label.new()
	title.text = "%s ENVOYÉE" % str(card.name).to_upper()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", MAGENTA)
	box.add_child(title)
	var field := LineEdit.new()
	field.text = code
	field.editable = false
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.custom_minimum_size = Vector2(560, 72)
	field.add_theme_font_size_override("font_size", 34)
	field.add_theme_color_override("font_uneditable_color", GOLD)
	box.add_child(field)
	var hint := Label.new()
	hint.text = "Donne ce code (ou le lien de sa page web) à qui tu veux.\nGarde-le bien : il n'est affiché qu'une fois."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	box.add_child(hint)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	_button(row, "COPIER LE CODE", func() -> void:
		DisplayServer.clipboard_set(code)
		_flash_message("Code copié"), GOLD)
	_button(row, "COPIER LE LIEN", func() -> void:
		DisplayServer.clipboard_set(Trade.link(code))
		_flash_message("Lien copié"), CYAN)
	_button(row, "FERMER", _close_overlay)


## Opens a booster: three cards face down, each turned with a tap.
func _open(kind: String) -> void:
	var drawn := Cards.open_booster(kind)
	if drawn.is_empty():
		return
	var box := _open_overlay()
	var title := Label.new()
	title.text = "BOOSTER RARE" if kind == "rare" else "BOOSTER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", GOLD if kind == "rare" else CYAN)
	box.add_child(title)
	var hint := Label.new()
	hint.text = "Glisse sur le pointillé pour ouvrir"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	box.add_child(hint)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var done := _button(box, "CONTINUER", _close_overlay)
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.custom_minimum_size.x = 300
	# The sealed pack first; the cards come out once it is torn.
	var pack := BoosterPack.new(kind)
	pack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(pack)
	box.move_child(pack, row.get_index())
	row.visible = false
	done.visible = false
	pack.opened.connect(func() -> void:
		hint.text = "Touche une carte pour la retourner"
		await get_tree().create_timer(0.35).timeout
		pack.queue_free()
		row.visible = true
		done.visible = true
		# The cards rise from where the pack was, one after the other.
		for index in row.get_child_count():
			var view: Control = row.get_child(index).get_child(0)
			view.position.y = 160.0
			view.modulate.a = 0.0
			var tween := view.create_tween()
			tween.tween_interval(0.08 * index)
			tween.tween_property(view, "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.parallel().tween_property(view, "modulate:a", 1.0, 0.2))
	var seen := {}
	for card: Dictionary in drawn:
		# "New" for the first copy of a card the player did not have before
		# this booster.
		var in_booster := drawn.filter(func(other: Dictionary) -> bool: return other.id == card.id).size()
		var is_new: bool = Cards.count(card.id) == in_booster and not seen.has(card.id)
		seen[card.id] = true
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(200, 280)
		row.add_child(holder)
		var view := CardView.new(card, true, 0)
		view.face_down = true
		view.size = Vector2(200, 280)
		view.pivot_offset = view.size / 2.0
		holder.add_child(view)
		view.gui_input.connect(func(event: InputEvent) -> void:
			if view.face_down and event is InputEventMouseButton and event.pressed:
				_turn(view, holder, is_new))


## Turns a card over: it narrows, shows its face, widens; a burst in its
## rarity's color, bigger for the rarer ones.
func _turn(view: CardView, holder: Control, is_new: bool) -> void:
	var tween := create_tween()
	tween.tween_property(view, "scale:x", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		view.face_down = false
		view.queue_redraw())
	tween.tween_property(view, "scale:x", 1.0, 0.15)
	tween.tween_property(view, "scale", Vector2.ONE * 1.08, 0.12)
	tween.tween_property(view, "scale", Vector2.ONE, 0.12)
	var color: Color = Cards.RARITY[view.card.rarity].color
	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.explosiveness = 0.9
	sparks.amount = 30 + 40 * int(view.card.rarity)
	sparks.lifetime = 0.9
	sparks.position = view.size / 2.0
	sparks.spread = 180.0
	sparks.gravity = Vector2(0, 200)
	sparks.initial_velocity_min = 150.0
	sparks.initial_velocity_max = 380.0 + 80.0 * int(view.card.rarity)
	sparks.scale_amount_min = 3.0
	sparks.scale_amount_max = 7.0
	sparks.color = color
	holder.add_child(sparks)
	sparks.emitting = true
	if is_new:
		var badge := Label.new()
		badge.text = "NOUVELLE !"
		badge.add_theme_font_size_override("font_size", 22)
		badge.add_theme_color_override("font_color", MAGENTA)
		badge.add_theme_color_override("font_outline_color", Color.BLACK)
		badge.add_theme_constant_override("outline_size", 8)
		badge.position = Vector2(16, 12)
		holder.add_child(badge)


func _flash_message(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", GOLD)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
	var tween := label.create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
