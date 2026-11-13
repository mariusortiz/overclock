extends Control
## The card album: the cards by series (owned ones in color, missing ones
## dark), the boosters waiting to be opened, the dust and the series
## rewards. A card opens large, with a button to craft it if missing.

const MENU_SCENE := "res://scenes/menu.tscn"
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)
const CARD_SIZE := Vector2(150, 210)
## A card of the booster's pile.
const PILE_CARD := Vector2(280, 392)
const FANFARE_LEGENDARY := "res://assets/audio/fanfare_legendary.ogg"
const FANFARE_MYTHIC := "res://assets/audio/fanfare_mythic.ogg"

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
	# The hacker cards owned come after the series' own.
	var hacker := Cards.HACKER_CARDS.filter(func(card: Dictionary) -> bool: return card.series == shown and Cards.count(card.id) > 0)
	for card: Dictionary in Cards.in_series(shown) + hacker:
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


## Opens a booster: the sealed pack first, then its cards in a pile, face
## down, the rarest at the bottom. A tap turns the top card over; another
## sends it aside, until the pile is empty and the three are laid out.
## Legendary and mythic cards come with a show (see _celebrate).
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
	# "New" for the first copy of a card the player did not have before this booster.
	var news := []
	var seen := {}
	for card: Dictionary in drawn:
		var in_booster := drawn.filter(func(other: Dictionary) -> bool: return other.id == card.id).size()
		news.append(Cards.count(card.id) == in_booster and not seen.has(card.id))
		seen[card.id] = true
	# The rarest last, for the suspense.
	var order := range(drawn.size())
	order.sort_custom(func(a: int, b: int) -> bool: return drawn[a].rarity > drawn[b].rarity)
	var pile := Control.new()
	pile.custom_minimum_size = PILE_CARD + Vector2(40, 40)
	pile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pile.visible = false
	box.add_child(pile)
	var views: Array[CardView] = []
	for slot in order.size():
		var view := CardView.new(drawn[order[slot]], true, 0)
		view.face_down = true
		view.size = PILE_CARD
		view.pivot_offset = PILE_CARD / 2.0
		# Untidy, like a real pile.
		view.position = Vector2(20, 20) + Vector2(-6, -4) * slot
		view.rotation = [-0.05, 0.04, -0.02][slot % 3]
		view.set_meta("new", news[order[slot]])
		pile.add_child(view)
		views.append(view)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	row.visible = false
	box.add_child(row)
	var done := _button(box, "CONTINUER", _close_overlay)
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.custom_minimum_size.x = 300
	done.visible = false
	var pack := BoosterPack.new(kind)
	pack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(pack)
	box.move_child(pack, pile.get_index())
	pack.opened.connect(func() -> void:
		hint.text = "Touche la pile pour retourner la carte"
		await get_tree().create_timer(0.35).timeout
		pack.queue_free()
		pile.visible = true
		# The cards rise out of the pack, one after the other.
		for index in views.size():
			var view := views[index]
			var rest := view.position
			view.position.y += 160.0
			view.modulate.a = 0.0
			var tween := view.create_tween()
			tween.tween_interval(0.08 * index)
			tween.tween_property(view, "position", rest, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.parallel().tween_property(view, "modulate:a", 1.0, 0.2))
	pile.gui_input.connect(func(event: InputEvent) -> void:
		if not (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			return
		if views.is_empty() or pile.has_meta("busy"):
			return
		var top: CardView = views[-1]
		if top.face_down:
			pile.set_meta("busy", true)
			await _reveal(top, pile)
			pile.remove_meta("busy")
			hint.text = "Touche la carte pour la suivante" if views.size() > 1 else "Touche la carte pour voir le tirage"
			return
		# Sent aside; once the pile is empty, the three cards side by side.
		views.pop_back()
		var out := top.create_tween()
		out.tween_property(top, "position", top.position + Vector2(520, -60), 0.3).set_ease(Tween.EASE_IN)
		out.parallel().tween_property(top, "rotation", 0.5, 0.3)
		out.parallel().tween_property(top, "modulate:a", 0.0, 0.3)
		out.tween_callback(top.queue_free)
		if views.is_empty():
			await out.finished
			pile.visible = false
			hint.text = ""
			_lay_out(row, drawn, news)
			row.visible = true
			done.visible = true)


## Turns a card of the pile over. Legendary and mythic ones build up first,
## then burst (see _celebrate); the others get a spray in their color.
func _reveal(view: CardView, pile: Control) -> void:
	var rarity: int = view.card.rarity
	if rarity >= Cards.Rarity.LEGENDARY:
		await _celebrate(view, pile)
	var tween := create_tween()
	tween.tween_property(view, "scale:x", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		view.face_down = false
		view.rotation = 0.0
		view.queue_redraw())
	tween.tween_property(view, "scale:x", 1.0, 0.15)
	tween.tween_property(view, "scale", Vector2.ONE * 1.08, 0.12)
	tween.tween_property(view, "scale", Vector2.ONE, 0.12)
	_sparks(pile, view.position + view.size / 2.0, Cards.RARITY[rarity].color, 30 + 40 * rarity, 380.0 + 80.0 * rarity)
	await tween.finished
	if view.get_meta("new", false):
		var badge := Label.new()
		badge.text = "NOUVELLE !"
		badge.add_theme_font_size_override("font_size", 26)
		badge.add_theme_color_override("font_color", MAGENTA)
		badge.add_theme_color_override("font_outline_color", Color.BLACK)
		badge.add_theme_constant_override("outline_size", 8)
		badge.position = Vector2(18, -6)
		badge.rotation = -0.12
		view.add_child(badge)


## The show of a legendary or mythic card: it trembles and glows, columns of
## light rise behind it, then a flash, confetti and a fanfare as it turns.
func _celebrate(view: CardView, pile: Control) -> void:
	var mythic: bool = view.card.rarity >= Cards.Rarity.MYTHIC
	var colors: Array = [Color(1.0, 0.24, 0.95), GOLD, Color(0.3, 1.0, 0.6), CYAN, Color(0.7, 0.4, 1.0)] if mythic else [GOLD, Color(1.0, 0.95, 0.7)]
	if view.card.rarity == Cards.Rarity.HACKER:
		colors = [Color(0.2, 1.0, 0.45), Color(0.6, 1.0, 0.7), Color(0.0, 0.6, 0.25), Color.WHITE]
	# Columns of light, behind the pile.
	var beams := Control.new()
	beams.mouse_filter = Control.MOUSE_FILTER_IGNORE
	beams.position = view.position + view.size / 2.0
	pile.add_child(beams)
	pile.move_child(beams, 0)
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.set_color(1, Color(1, 1, 1, 0))
	fade.add_point(0.5, Color(1, 1, 1, 0.9))
	var texture := GradientTexture2D.new()
	texture.gradient = fade
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(1, 0)
	for index in 7:
		var beam := TextureRect.new()
		beam.texture = texture
		beam.material = glow
		beam.stretch_mode = TextureRect.STRETCH_SCALE
		beam.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		beam.size = Vector2(60 + 30 * (index % 2), 1400)
		beam.pivot_offset = Vector2(beam.size.x / 2.0, 1400)
		beam.position = Vector2(-beam.size.x / 2.0, -1400 + view.size.y * 0.3)
		beam.rotation = (index - 3) * 0.28
		beam.modulate = Color(colors[index % colors.size()], 0.0)
		beam.scale.y = 0.0
		beams.add_child(beam)
		var rise := beam.create_tween()
		rise.tween_interval(0.06 * index)
		rise.tween_property(beam, "scale:y", 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		rise.parallel().tween_property(beam, "modulate:a", 0.75, 0.4)
		# They sway, then fade away slowly.
		rise.tween_property(beam, "rotation", beam.rotation + 0.12, 1.2).set_trans(Tween.TRANS_SINE)
		rise.tween_property(beam, "modulate:a", 0.0, 1.4)
	beams.create_tween().tween_interval(4.0).finished.connect(beams.queue_free)
	# The card trembles and glows, more and more.
	var shake := view.create_tween()
	for i in 10:
		shake.tween_property(view, "rotation", 0.06 if i % 2 == 0 else -0.06, 0.06)
		shake.parallel().tween_property(view, "scale", Vector2.ONE * (1.0 + 0.012 * i), 0.06)
	shake.parallel().tween_property(view, "modulate", Color(1.6, 1.5, 1.2), 0.3)
	_play_fanfare(mythic)
	await shake.finished
	view.modulate = Color.WHITE
	# The burst: a white flash over everything, confetti raining down.
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.85)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(flash)
	flash.create_tween().tween_property(flash, "color:a", 0.0, 0.5).finished.connect(flash.queue_free)
	_confetti(colors, 160 if mythic else 100)
	_sparks(pile, view.position + view.size / 2.0, colors[0], 120, 700.0)
	if Settings.vibration_enabled:
		Input.vibrate_handheld(120)


## Confetti falling over the whole screen, from above it.
func _confetti(colors: Array, amount: int) -> void:
	var screen := get_viewport_rect().size
	var ramp := Gradient.new()
	ramp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	var tints := PackedColorArray()
	for index in colors.size():
		offsets.append(float(index) / colors.size())
		tints.append(colors[index])
	ramp.offsets = offsets
	ramp.colors = tints
	var confetti := CPUParticles2D.new()
	confetti.one_shot = true
	confetti.explosiveness = 0.7
	confetti.amount = amount
	confetti.lifetime = 3.2
	confetti.position = Vector2(screen.x / 2.0, -20)
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(screen.x / 2.0, 10)
	confetti.direction = Vector2(0, 1)
	confetti.spread = 30.0
	confetti.gravity = Vector2(0, 260)
	confetti.initial_velocity_min = 80.0
	confetti.initial_velocity_max = 260.0
	confetti.angular_velocity_min = -360.0
	confetti.angular_velocity_max = 360.0
	confetti.scale_amount_min = 6.0
	confetti.scale_amount_max = 11.0
	confetti.color_initial_ramp = ramp
	_overlay.add_child(confetti)
	confetti.emitting = true
	confetti.finished.connect(confetti.queue_free)


func _sparks(parent: Control, at: Vector2, color: Color, amount: int, speed: float) -> void:
	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.explosiveness = 0.9
	sparks.amount = amount
	sparks.lifetime = 0.9
	sparks.position = at
	sparks.spread = 180.0
	sparks.gravity = Vector2(0, 200)
	sparks.initial_velocity_min = 150.0
	sparks.initial_velocity_max = speed
	sparks.scale_amount_min = 3.0
	sparks.scale_amount_max = 7.0
	sparks.color = color
	parent.add_child(sparks)
	sparks.emitting = true
	sparks.finished.connect(sparks.queue_free)


## The fanfare, over the music turned down for a moment.
func _play_fanfare(mythic: bool) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load(FANFARE_MYTHIC if mythic else FANFARE_LEGENDARY)
	add_child(player)
	player.play()
	var level: float = Music.volume_db
	var duck := Music.create_tween()
	duck.tween_property(Music, "volume_db", level - 18.0, 0.2)
	duck.tween_interval(player.stream.get_length() - 0.4)
	duck.tween_property(Music, "volume_db", level, 0.8)
	player.finished.connect(player.queue_free)


## The booster's three cards side by side, once all are turned.
func _lay_out(row: HBoxContainer, drawn: Array[Dictionary], news: Array) -> void:
	for index in drawn.size():
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(200, 280)
		row.add_child(holder)
		var view := CardView.new(drawn[index], true, 0)
		view.size = Vector2(200, 280)
		view.pivot_offset = view.size / 2.0
		holder.add_child(view)
		if news[index]:
			var badge := Label.new()
			badge.text = "NOUVELLE !"
			badge.add_theme_font_size_override("font_size", 20)
			badge.add_theme_color_override("font_color", MAGENTA)
			badge.add_theme_color_override("font_outline_color", Color.BLACK)
			badge.add_theme_constant_override("outline_size", 8)
			badge.position = Vector2(14, -30)
			holder.add_child(badge)
		view.scale = Vector2.ONE * 0.6
		view.modulate.a = 0.0
		var tween := view.create_tween()
		tween.tween_interval(0.1 * index)
		tween.tween_property(view, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(view, "modulate:a", 1.0, 0.2)


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
