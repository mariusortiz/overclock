extends Control
## The story mode's screen: the season's chapters with their stars (locked
## until the one before is won), the chosen chapter's mission, and, back
## from a mission, its result.

const MENU_SCENE := "res://scenes/menu.tscn"
const FONT := preload("res://assets/ui/fonts/kenney_mini_square_mono.ttf")
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.8, 0.25)
const MODE_NAMES := {"waves": "Vagues", "race": "Course de vaisseaux", "capture": "Capture de zone"}

var _selected := 0
var _list := VBoxContainer.new()
var _title := Label.new()
var _info := Label.new()
var _stars := StarRow.new()
var _play := Button.new()
var _overlay := Control.new()


## Three stars, drawn (the game's font has none): gold when earned.
class StarRow extends Control:
	var count := 0
	var size_px := 22.0

	func _init(earned := 0, star_size := 22.0) -> void:
		count = earned
		size_px = star_size
		custom_minimum_size = Vector2(star_size * 3.6, star_size * 1.2)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		for i in 3:
			var center := Vector2(size_px * (0.6 + 1.2 * i), size_px * 0.6)
			var points := PackedVector2Array()
			for k in 10:
				var angle := -PI / 2.0 + PI * k / 5.0
				points.append(center + Vector2(cos(angle), sin(angle)) * size_px * (0.55 if k % 2 == 0 else 0.24))
			draw_colored_polygon(points, GOLD if i < count else Color(1, 1, 1, 0.18))


func _ready() -> void:
	Story.leave()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Music.play_track(Music.Track.STORY)
	var background := ColorRect.new()
	background.color = Color(0.02, 0.04, 0.16)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 28)
	margin.add_child(columns)

	# Left: the chapters.
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	columns.add_child(left)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	left.add_child(top)
	var back := Button.new()
	back.text = "<  MENU"
	back.custom_minimum_size = Vector2(160, 56)
	back.add_theme_font_size_override("font_size", 22)
	back.pressed.connect(get_tree().change_scene_to_file.bind(MENU_SCENE), CONNECT_DEFERRED)
	top.add_child(back)
	var heading := Label.new()
	heading.text = "SAISON 1  ·  %d / %d ÉTOILES" % [Story.total_stars(), Story.CHAPTERS.size() * 3]
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", CYAN)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scroll)
	TouchScroll.attach(scroll)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	# Right: the chosen chapter.
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 470
	columns.add_child(panel)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 14)
	panel.add_child(detail)
	_title.add_theme_font_size_override("font_size", 32)
	_title.add_theme_color_override("font_color", MAGENTA)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(_title)
	detail.add_child(_stars)
	_info.add_theme_font_size_override("font_size", 20)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(_info)
	_play.text = "JOUER"
	_play.custom_minimum_size.y = 84
	_play.theme_type_variation = &"PrimaryButton"
	_play.add_theme_font_size_override("font_size", 36)
	_play.pressed.connect(func() -> void: _start(_selected))
	detail.add_child(_play)

	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)

	# The first chapter not won yet, or the one just played.
	_selected = 0
	while _selected < Story.CHAPTERS.size() - 1 and Story.stars_of(_selected) > 0:
		_selected += 1
	if not Story.last_result.is_empty():
		_selected = Story.last_result.chapter
	_refresh()
	if not Story.last_result.is_empty():
		_show_result(Story.last_result)
		Story.last_result = {}


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()
	for index in Story.CHAPTERS.size():
		var info: Dictionary = Story.CHAPTERS[index]
		var row := Button.new()
		row.toggle_mode = true
		row.button_pressed = index == _selected
		row.custom_minimum_size.y = 62
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_theme_font_size_override("font_size", 22)
		row.text = "  %d.  %s" % [index + 1, str(info.title).to_upper()] if Story.is_open(index) else "  %d.  ???" % (index + 1)
		row.disabled = not Story.is_open(index)
		row.pressed.connect(func() -> void:
			_selected = index
			_refresh())
		var stars := StarRow.new(Story.stars_of(index), 18.0)
		stars.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
		stars.position.x -= 90
		row.add_child(stars)
		_list.add_child(row)
	var chosen: Dictionary = Story.CHAPTERS[_selected]
	_title.text = "CHAPITRE %d\n%s" % [_selected + 1, str(chosen.title).to_upper()]
	_stars.count = Story.stars_of(_selected)
	_stars.queue_redraw()
	var hero: String = Loadout.find(chosen.hero).item.name
	var lines := [chosen.goal, "", "Héros : %s  ·  %s" % [hero, MODE_NAMES[chosen.mode]]]
	lines.append(_star_rule(chosen))
	if Story.stars_of(_selected) == 0:
		lines.append("Première victoire : %d gemmes, un booster rare, la carte de l'épisode%s." % [
				100 + 20 * _selected, " et le vaisseau Écarlate" if _selected == Story.CHAPTERS.size() - 1 else ""])
	_info.text = "\n".join(lines)
	_play.text = "REJOUER" if Story.stars_of(_selected) > 0 else "JOUER"


## How the stars are earned, for the mission's mode.
func _star_rule(info: Dictionary) -> String:
	match info.mode:
		"race":
			return "Étoiles : 1re place 3, 2e place 2, sinon 1."
		"capture":
			return "Étoiles : moins l'équipe adverse marque, plus tu en gagnes."
	return "Étoiles : selon la santé qui te reste quand le boss tombe."


func _start(index: int) -> void:
	Story.begin(index)
	get_tree().change_scene_to_file.call_deferred(Story.CUTSCENE)


## Back from a mission: won (stars, the closing line, the rewards) or lost.
func _show_result(result: Dictionary) -> void:
	for child in _overlay.get_children():
		child.queue_free()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 640
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	var info: Dictionary = Story.CHAPTERS[result.chapter]
	var title := Label.new()
	title.text = "MISSION ACCOMPLIE" if result.won else "MISSION ÉCHOUÉE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", GOLD if result.won else Color(1.0, 0.4, 0.4))
	box.add_child(title)
	if result.won:
		var stars := StarRow.new(result.stars, 40.0)
		stars.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(stars)
	var text := Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 22)
	var lines: Array = [info.outro if result.won else info.goal]
	if not result.rewards.is_empty():
		lines.append("")
		lines.append("Obtenu : " + ", ".join(result.rewards))
	text.text = "\n".join(lines)
	box.add_child(text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var next: int = result.chapter + 1
	if result.won and next < Story.CHAPTERS.size():
		_add_button(row, "CHAPITRE SUIVANT", func() -> void: _start(next), true)
	_add_button(row, "RÉESSAYER" if not result.won else "REJOUER", func() -> void: _start(result.chapter), not result.won)
	_add_button(row, "FERMER", func() -> void: _overlay.visible = false, false)
	_overlay.visible = true


func _add_button(parent: Node, text: String, action: Callable, primary: bool) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 72
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 22)
	if primary:
		button.theme_type_variation = &"PrimaryButton"
	button.pressed.connect(action)
	parent.add_child(button)
