extends Control
## The shop: today's four offers, the full catalog by kind, and the gem
## packs. Items are paid in credits or in gems (see Wallet); gems are bought
## with real money through Google Play (see Billing). A bought item is
## equipped at once and stays in the armory.

const MENU_SCENE := "res://scenes/menu.tscn"
const CARD_SIZE := Vector2(214, 108)
const TAB_FONT_SIZE := 17
## Characters that fit on one line of a card.
const CARD_LINE_LENGTH := 12
const BUTTON_HEIGHT := 64
const GOLD := Color(1.0, 0.85, 0.3)
const DEAL := Color(0.3, 1.0, 0.5)

const TABS := ["JOUR", "HÉROS", "ARMES", "SKINS", "VAISSEAUX", "DANSES", "CARTES", "GEMMES"]
const KINDS := ["", "Personnage", "Arme", "Skin d'arme", "Vaisseau", "Danse", "", ""]
const CARDS_TAB := 6
const GEMS_TAB := 7
## Overpowered items stand out in this color, with "ULTRA" in their detail.
const ULTRA := Color(1.0, 0.24, 0.95)
## Booster packs of collectible cards (see Cards), bought again and again.
const BOOSTERS: Array[Dictionary] = [
	{"booster": "standard", "name": "BOOSTER", "credits": 400, "gems": 30,
		"text": "3 cartes de toutes raretés."},
	{"booster": "rare", "name": "BOOSTER RARE", "credits": 1200, "gems": 90,
		"text": "3 cartes, dont une rare ou mieux."},
]

var _tab := 0
## The offer shown in the detail panel (see Shop.catalog) or a gem pack.
var _viewed := {}
var _billing := Billing.new()

@onready var _stage: CharacterStage = $Stage
@onready var _balance: Label = $Right/Box/Balance
@onready var _tab_bar: HFlowContainer = $Right/Box/Tabs
@onready var _grid: GridContainer = $Right/Box/Scroll/Grid
@onready var _name: Label = $Right/Box/Detail/Box/Name
@onready var _info: Label = $Right/Box/Detail/Box/Info
@onready var _buttons: HBoxContainer = $Right/Box/Detail/Box/Buttons


func _ready() -> void:
	TouchScroll.attach($Right/Box/Scroll)
	add_child(_billing)
	_billing.status_changed.connect(_refresh)
	_billing.gems_granted.connect(func(_gems: int) -> void: _refresh())
	_stage.show_loadout()
	$Back.pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	for i in TABS.size():
		var button := Button.new()
		button.text = TABS[i]
		button.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
		button.toggle_mode = true
		button.custom_minimum_size.y = BUTTON_HEIGHT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select_tab.bind(i))
		_tab_bar.add_child(button)
	_select_tab(0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


func _unhandled_key_input(event: InputEvent) -> void:
	# Test shortcut (debug and web builds): F7 adds credits and gems.
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_F7 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		Wallet.add_credits(5000)
		Wallet.add_gems(300)
		_refresh()


func _select_tab(index: int) -> void:
	_tab = index
	for i in _tab_bar.get_child_count():
		(_tab_bar.get_child(i) as Button).button_pressed = i == index
	var offers := _offers()
	_viewed = offers[0] if not offers.is_empty() else {}
	_preview()
	_refresh()


## What the current tab lists.
func _offers() -> Array:
	if _tab == 0:
		return Shop.daily()
	if _tab == CARDS_TAB:
		return BOOSTERS
	if _tab == GEMS_TAB:
		return Shop.GEM_PACKS
	return Shop.catalog().filter(func(offer: Dictionary) -> bool: return offer.kind == KINDS[_tab])


func _refresh() -> void:
	_balance.text = "%d CRÉDITS  ·  %d GEMMES" % [Wallet.credits(), Wallet.gems()]
	if _tab == 0:
		var left := Shop.seconds_to_refresh()
		@warning_ignore("integer_division")
		_balance.text += "\nNouvelles offres dans %d h %02d" % [left / 3600, (left % 3600) / 60]
	for card in _grid.get_children():
		_grid.remove_child(card)
		card.queue_free()
	for offer: Dictionary in _offers():
		var card := Button.new()
		card.custom_minimum_size = CARD_SIZE
		card.toggle_mode = true
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.button_pressed = _same(offer, _viewed)
		card.text = _card_text(offer)
		if offer.get("discount", false):
			card.add_theme_color_override("font_color", DEAL)
		elif offer.has("item") and offer.item.get("op", false):
			card.add_theme_color_override("font_color", ULTRA)
		card.pressed.connect(_on_card_pressed.bind(offer))
		_grid.add_child(card)
	_show_detail()


func _card_text(offer: Dictionary) -> String:
	if offer.has("booster"):
		return "%s\n%d CR" % [offer.name, offer.credits]
	if offer.has("product"):
		return "%d GEMMES\n%s" % [offer.gems, offer.label]
	var item: Dictionary = offer.item
	# A long hyphenated name is split at the hyphen rather than mid-word.
	var title: String = item.name
	if title.length() > CARD_LINE_LENGTH:
		title = title.replace("-", "-\n")
	if Wallet.owns(item.id):
		return "%s\nPOSSÉDÉ" % title
	var price := "%d CR" % offer.credits
	if offer.discount:
		price = "-%d %%  %s" % [roundi(Shop.DAILY_DISCOUNT * 100), price]
	return "%s\n%s" % [title, price]


func _same(a: Dictionary, b: Dictionary) -> bool:
	if a.has("booster") or b.has("booster"):
		return a.get("booster", "") == b.get("booster", "")
	if a.has("product") or b.has("product"):
		return a.get("product", "") == b.get("product", "")
	return not b.is_empty() and a.item.id == b.item.id


func _on_card_pressed(offer: Dictionary) -> void:
	_viewed = offer
	_preview()
	# Deferred: the cards are rebuilt, and one of them is handling this click.
	_refresh.call_deferred()


## Shows the viewed item on the stage: the hero, or the gun with its finish.
func _preview() -> void:
	_stage.preview_pose = -1
	if _viewed.is_empty() or _viewed.has("product") or _viewed.has("booster"):
		_stage.focus(CharacterStage.Focus.CHARACTER)
		_stage.show_loadout()
		return
	match _viewed.kind:
		"Personnage":
			_stage.focus(CharacterStage.Focus.CHARACTER)
			_stage.show_character(_viewed.item)
		"Arme":
			_stage.focus(CharacterStage.Focus.WEAPON)
			_stage.show_weapon(_viewed.item)
		"Skin d'arme":
			_stage.focus(CharacterStage.Focus.WEAPON)
			_stage.show_weapon(Loadout.selected_weapon(), _viewed.item)
		"Vaisseau":
			_stage.focus(CharacterStage.Focus.SHIP)
			_stage.show_ship(_viewed.item)
		"Danse":
			# The hero dances it, on the spot.
			_stage.focus(CharacterStage.Focus.CHARACTER)
			_stage.show_loadout()
			_stage.preview_pose = Dances.LIST.find(_viewed.item)


func _show_detail() -> void:
	for button in _buttons.get_children():
		_buttons.remove_child(button)
		button.queue_free()
	if _viewed.is_empty():
		_name.text = ""
		_info.text = ""
		return
	if _viewed.has("booster"):
		_name.text = _viewed.name
		var waiting: int = Cards.boosters().get(_viewed.booster, 0)
		_info.text = "%s À ouvrir dans CARTES, depuis l'accueil.%s" % [_viewed.text, " (%d en attente)" % waiting if waiting > 0 else ""]
		var by_credits := _add_button("%d CRÉDITS" % _viewed.credits, GOLD)
		by_credits.disabled = Wallet.credits() < _viewed.credits
		by_credits.pressed.connect(_buy_booster.bind(Wallet.CREDITS_KEY))
		var by_gems := _add_button("%d GEMMES" % _viewed.gems, Color(0.5, 0.9, 1.0))
		by_gems.disabled = Wallet.gems() < _viewed.gems
		by_gems.pressed.connect(_buy_booster.bind(Wallet.GEMS_KEY))
		return
	if _viewed.has("product"):
		_name.text = "%d GEMMES" % _viewed.gems
		_info.text = "Les gemmes achètent tout le contenu de la boutique. On en gagne aussi en jeu : %d par boss vaincu, %d pour tous les défis du jour." % [
				Wallet.GEMS_PER_BOSS, Wallet.GEMS_FOR_ALL_CHALLENGES]
		var price: String = _billing.prices.get(_viewed.product, "")
		var button := _add_button("ACHETER  %s" % price if _billing.available else _billing.status, GOLD)
		button.disabled = not _billing.available
		button.pressed.connect(_billing.buy.bind(_viewed.product))
		return
	var item: Dictionary = _viewed.item
	_name.text = item.name
	_info.text = "%s exclusif" % _viewed.kind.to_lower() if _viewed.kind != "Arme" else "Arme exotique"
	if _viewed.kind == "Danse":
		_info.text = "Danse exclusive"
	_info.text += "\n" + _description(item, _viewed.kind)
	if Wallet.owns(item.id):
		if _viewed.kind == "Danse":
			_add_button("POSSÉDÉE · DANS LA ROUE", Color.WHITE).disabled = true
			return
		_add_button("POSSÉDÉ · ÉQUIPÉ" if _is_equipped(item) else "ÉQUIPER", Color.WHITE).pressed.connect(_equip.bind(item))
		return
	var by_credits := _add_button("%d CRÉDITS" % _viewed.credits, GOLD)
	by_credits.disabled = Wallet.credits() < _viewed.credits
	by_credits.pressed.connect(_buy.bind(Wallet.CREDITS_KEY, _viewed.credits))
	var by_gems := _add_button("%d GEMMES" % _viewed.gems, Color(0.5, 0.9, 1.0))
	by_gems.disabled = Wallet.gems() < _viewed.gems
	by_gems.pressed.connect(_buy.bind(Wallet.GEMS_KEY, _viewed.gems))


## What makes the item special, in one or two lines.
func _description(item: Dictionary, kind: String) -> String:
	var text := _traits(item, kind)
	if item.get("op", false):
		text = "ULTRA · " + text
	if item.has("fair"):
		text += "\nEn multijoueur, revient au niveau des autres."
	return text


func _traits(item: Dictionary, kind: String) -> String:
	match kind:
		"Personnage":
			var ulti: Dictionary = Ultimate.INFO[item.ulti]
			return "%s · %s : %s" % [Ultimate.boost_text(item.boost), ulti.name, ulti.text]
		"Arme":
			var traits: Array[String] = []
			if item.get("pierce", false):
				traits.append("transperce les ennemis")
			if item.get("beam", false):
				traits.append("rayon continu")
			if item.has("blast_radius"):
				traits.append("explose (%s m)" % str(item.blast_radius).trim_suffix(".0"))
			if item.has("ignite"):
				traits.append("enflamme, portée %d m" % item.range)
			if item.has("pellets"):
				traits.append("%d projectiles par tir" % item.pellets)
			traits.append("cadence %s/s · dégâts %d · chargeur %d" % [str(item.fire_rate).trim_suffix(".0"), item.damage, item.magazine])
			return ", ".join(traits)
		"Danse":
			return "Se lance en jeu avec DANSE (touche B), dans la roue des danses."
		"Vaisseau":
			var special: Array = Loadout.SHIP_SPECIALS[item.special]
			return "%s : %s · vitesse %d %%, maniabilité %d %%, bouclier %d, tir x%s" % [special[0], special[1],
					roundi(item.velocity * 100), roundi(item.handling * 100), item.shield, str(item.fire)]
		_:
			return "Finition animée · élimination : %s" % Loadout.KILL_NAMES.get(item.kill, "")


func _add_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = BUTTON_HEIGHT
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", color)
	_buttons.add_child(button)
	return button


func _buy_booster(currency: String) -> void:
	var price: int = _viewed.credits if currency == Wallet.CREDITS_KEY else _viewed.gems
	if Wallet.spend(price, currency):
		Cards.give_booster(_viewed.booster)
	_refresh.call_deferred()


func _buy(currency: String, price: int) -> void:
	var item: Dictionary = _viewed.item
	if Wallet.buy(item.id, price, currency) and _viewed.kind != "Danse":
		_equip(item)
	else:
		_refresh.call_deferred()


func _equip(item: Dictionary) -> void:
	Loadout.select(_key(_viewed.kind), item)
	_preview()
	_refresh.call_deferred()


func _is_equipped(item: Dictionary) -> bool:
	match _viewed.kind:
		"Personnage":
			return Loadout.selected_character().id == item.id
		"Arme":
			return Loadout.selected_weapon().id == item.id
		"Vaisseau":
			return Loadout.selected_ship().id == item.id
	return Loadout.selected_skin().id == item.id


func _key(kind: String) -> String:
	match kind:
		"Personnage":
			return Loadout.CHARACTER_KEY
		"Arme":
			return Loadout.WEAPON_KEY
		"Vaisseau":
			return Loadout.SHIP_KEY
	return Loadout.SKIN_KEY
