class_name SettingsControls
extends VBoxContainer
## The settings widgets (sensitivity, music, vibration, graphics), built by
## code so the pause menu and the home screen share them.


func _ready() -> void:
	add_theme_constant_override("separation", 8)

	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 60
	row.add_theme_constant_override("separation", 16)
	var label := Label.new()
	label.text = "Sensibilité"
	label.add_theme_font_size_override("font_size", 26)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.4
	slider.max_value = 2.0
	slider.step = 0.1
	slider.value = Settings.sensitivity
	slider.custom_minimum_size = Vector2(260, 48)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(func(value: float) -> void: Settings.set_value(&"sensitivity", value))
	row.add_child(slider)
	add_child(row)

	_add_toggle("Musique", &"music_enabled")
	_add_toggle("Vibrations", &"vibration_enabled")
	_add_toggle("Tremblement de l'écran", &"camera_shake")
	_add_toggle("Graphismes élevés", &"high_quality")
	_add_toggle("Météo et heure du jour", &"weather")
	_add_toggle("Afficher les FPS", &"show_fps")


func _add_toggle(text: String, property: StringName) -> void:
	var toggle := CheckButton.new()
	toggle.text = text
	toggle.custom_minimum_size.y = 52
	toggle.add_theme_font_size_override("font_size", 26)
	toggle.button_pressed = Settings.get(property)
	toggle.toggled.connect(func(on: bool) -> void: Settings.set_value(property, on))
	add_child(toggle)
