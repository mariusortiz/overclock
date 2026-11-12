class_name ProfilePanel
extends Control
## Home screen panel: today's challenges on the left, career stats on the
## right. Built by code; open() refreshes it.

const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)
const GOLD := Color(1.0, 0.85, 0.3)

var _challenges := VBoxContainer.new()
var _stats := GridContainer.new()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1100, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	box.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	left.add_child(_title("DÉFIS DU JOUR"))
	left.add_child(_label("Renouvelés chaque jour. L'XP est gagnée même si tu meurs.", 18, Color(1, 1, 1, 0.7)))
	_challenges.add_theme_constant_override("separation", 14)
	left.add_child(_challenges)
	columns.add_child(left)

	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 420
	right.add_theme_constant_override("separation", 12)
	right.add_child(_title("CARRIÈRE"))
	_stats.columns = 2
	_stats.add_theme_constant_override("h_separation", 24)
	_stats.add_theme_constant_override("v_separation", 6)
	right.add_child(_stats)
	columns.add_child(right)

	var close := Button.new()
	close.text = "FERMER"
	close.custom_minimum_size.y = 64
	close.add_theme_font_size_override("font_size", 28)
	close.pressed.connect(func() -> void: visible = false)
	box.add_child(close)


func open() -> void:
	for child in _challenges.get_children() + _stats.get_children():
		child.queue_free()
	for challenge in Challenges.today():
		_challenges.add_child(_challenge_row(challenge))
	for line in GameStats.career_lines():
		_stats.add_child(_label(line[0], 20, Color(1, 1, 1, 0.75)))
		var value := _label(line[1], 20, CYAN)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_stats.add_child(value)
	visible = true


func _challenge_row(challenge: Dictionary) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	var text := _label(challenge.text, 22, GOLD if challenge.done else Color.WHITE)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(text)
	top.add_child(_label("RÉUSSI" if challenge.done else "+%d XP" % challenge.xp, 20, GOLD if challenge.done else MAGENTA))
	row.add_child(top)
	var bar := ProgressBar.new()
	bar.max_value = challenge.goal
	bar.value = challenge.progress
	bar.show_percentage = false
	bar.custom_minimum_size.y = 14
	row.add_child(bar)
	row.add_child(_label("%d / %d" % [challenge.progress, challenge.goal], 16, Color(1, 1, 1, 0.6)))
	return row


func _title(text: String) -> Label:
	return _label(text, 32, CYAN)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if font_size <= 18 else TextServer.AUTOWRAP_OFF
	return label
