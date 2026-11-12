extends Control
## Battle pass screen: current tier, XP toward the next one, and the track of
## rewards.

const MENU_SCENE := "res://scenes/menu.tscn"
const CARD_SIZE := Vector2(200, 250)
const UNLOCKED_COLOR := Color(0.16, 0.83, 1.0)
const TEST_XP := 1000

@onready var _tier_label: Label = $Top/Tier
@onready var _xp_label: Label = $Top/Xp
@onready var _xp_bar: ProgressBar = $Top/Bar
@onready var _scroll: ScrollContainer = $Scroll
@onready var _track: HBoxContainer = $Scroll/Track


func _ready() -> void:
	$Back.pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


func _unhandled_key_input(event: InputEvent) -> void:
	# Test shortcut (debug and web builds): F7 adds XP.
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_F7 \
			and (OS.is_debug_build() or OS.has_feature("web")):
		BattlePass.add_xp(TEST_XP)
		_refresh()


func _refresh() -> void:
	var progress := BattlePass.progress()
	var tier: int = progress.tier
	_tier_label.text = "PALIER %d / %d" % [tier, BattlePass.REWARDS.size()]
	if progress.needed == 0:
		_xp_label.text = "Passe terminé"
		_xp_bar.value = 100.0
	else:
		_xp_label.text = "%d / %d XP" % [progress.xp, progress.needed]
		_xp_bar.value = 100.0 * progress.xp / progress.needed

	for card in _track.get_children():
		_track.remove_child(card)
		card.queue_free()
	for i in BattlePass.REWARDS.size():
		_track.add_child(_create_card(i + 1, tier))
	# Bring the next reward into view once the cards are laid out.
	_scroll.set_deferred("scroll_horizontal", int(maxf(tier - 1, 0) * (CARD_SIZE.x + 12)))


func _create_card(number: int, reached: int) -> Control:
	var reward := Loadout.find(BattlePass.REWARDS[number - 1])
	var unlocked := number <= reached
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_SIZE
	if not unlocked:
		card.modulate = Color(1, 1, 1, 0.6)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	box.add_child(_label("PALIER %d" % number, 22, UNLOCKED_COLOR if unlocked else Color.WHITE))
	# Long names get a smaller size so that words are not cut.
	var item_name: String = reward.item.name
	box.add_child(_label(item_name, 28 if item_name.length() <= 7 else 19, Color.WHITE))
	box.add_child(_label(reward.kind, 18, Color(0.7, 0.8, 1.0)))
	box.add_child(_label("OBTENU" if unlocked else "%d XP" % BattlePass.tier_cost(number), 20,
			UNLOCKED_COLOR if unlocked else Color(1.0, 0.24, 0.95)))
	return card


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
