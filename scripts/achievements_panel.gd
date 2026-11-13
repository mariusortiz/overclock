class_name AchievementsPanel
extends Control
## The 50 achievements (see Achievements): a scrolling list, each with its
## name, goal, progress bar and reward, the reached ones in gold.

const CYAN := Color(0.16, 0.83, 1.0)
const GOLD := Color(1.0, 0.85, 0.3)

var _list := VBoxContainer.new()
var _heading := Label.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
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
	_heading.add_theme_font_size_override("font_size", 30)
	_heading.add_theme_color_override("font_color", CYAN)
	box.add_child(_heading)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	TouchScroll.attach(scroll)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)
	var close := Button.new()
	close.text = "FERMER"
	close.custom_minimum_size.y = 60
	close.add_theme_font_size_override("font_size", 24)
	close.pressed.connect(func() -> void: visible = false)
	box.add_child(close)


func open() -> void:
	Achievements.check()
	for child in _list.get_children():
		child.queue_free()
	_heading.text = "SUCCÈS  %d / %d" % [Achievements.done_count(), Achievements.LIST.size()]
	# The reached ones first, then the closest to being reached.
	var order := Achievements.LIST.duplicate()
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var done_a := Achievements.is_done(a.id)
		var done_b := Achievements.is_done(b.id)
		if done_a != done_b:
			return done_a
		return _share(a) > _share(b))
	for achievement: Dictionary in order:
		_list.add_child(_row(achievement))
	visible = true


func _share(achievement: Dictionary) -> float:
	var state := Achievements.progress(achievement)
	return clampf(float(state[0]) / maxf(state[1], 1.0), 0.0, 1.0)


func _row(achievement: Dictionary) -> Control:
	var done := Achievements.is_done(achievement.id)
	var state := Achievements.progress(achievement)
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	var top := HBoxContainer.new()
	var name := _label(str(achievement.name).to_upper(), 22, GOLD if done else Color.WHITE)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name)
	var reward := "+%d gemmes" % achievement.gems
	if achievement.id == "platinum":
		reward += " · skin Platine"
	top.add_child(_label("OBTENU" if done else reward, 18, GOLD if done else Color(1.0, 0.24, 0.95)))
	row.add_child(top)
	var text := _label(achievement.text, 17, Color(1, 1, 1, 0.7))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(text)
	if not done and state[1] > 1:
		var bar := ProgressBar.new()
		bar.max_value = state[1]
		bar.value = mini(state[0], state[1])
		bar.show_percentage = false
		bar.custom_minimum_size.y = 10
		row.add_child(bar)
		row.add_child(_label("%d / %d" % [mini(state[0], state[1]), state[1]], 15, Color(1, 1, 1, 0.55)))
	return row


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
