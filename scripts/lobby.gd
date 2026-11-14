extends Control
## Multiplayer lobby: host a game, or join one found on the Wi-Fi (or typed
## by address). Once in, the list of players; the host picks the mode and
## starts it for everyone.

const MENU_SCENE := "res://scenes/menu.tscn"
const CYAN := Color(0.16, 0.83, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.95)

var _box := VBoxContainer.new()
var _status := Label.new()


func _ready() -> void:
	Music.play_track(Music.Track.LOBBY)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var background := ColorRect.new()
	background.color = Color(0.02, 0.04, 0.16)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	TouchScroll.attach(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	_box.custom_minimum_size.x = 600
	_box.add_theme_constant_override("separation", 14)
	center.add_child(_box)
	Net.players_changed.connect(_show)
	Net.hosts_changed.connect(_show)
	Net.left.connect(func(reason: String) -> void:
		_status.text = reason
		_show())
	if Net.is_supported() and not Net.is_online():
		Net.start_listening()
	_show()
	# Test options (two devices simulated on one computer):
	# "-- --host=race" hosts and starts that mode once a second player is in;
	# "-- --join=127.0.0.1" joins that address.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--host="):
			_host()
			var test_mode := argument.get_slice("=", 1)
			Net.players_changed.connect(func() -> void:
				if Net.players.size() >= 2:
					get_tree().create_timer(1.0).timeout.connect(Net.start_game.bind(test_mode)))
		elif argument.begins_with("--join="):
			_join(argument.get_slice("=", 1))


func _exit_tree() -> void:
	Net.stop_listening()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_back()


## Rebuilds the screen for the current state.
func _show() -> void:
	for child in _box.get_children():
		if child != _status:
			child.queue_free()
	if _status.get_parent() == null:
		_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_status.add_theme_color_override("font_color", MAGENTA)
		_box.add_child(_status)
	_title("MULTIJOUEUR · WI-FI LOCAL")
	if not Net.is_supported():
		_text("Le multijoueur se joue avec l'APK Android : tous les téléphones sur le même Wi-Fi.")
		_button("RETOUR", _back)
	elif Net.is_online() and not Net.players.is_empty():
		_show_room()
	else:
		_show_search()
	_box.move_child(_status, -1)


func _show_search() -> void:
	_button("HÉBERGER UNE PARTIE", _host, CYAN)
	_text("Parties trouvées sur ce Wi-Fi :")
	if Net.hosts.is_empty():
		_text("(aucune pour l'instant, la liste se met à jour toute seule)", 18)
	for address: String in Net.hosts:
		var info: Dictionary = Net.hosts[address]
		_button("REJOINDRE %s  ·  %d joueur%s" % [info.name, info.players, "" if info.players == 1 else "s"], _join.bind(address))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var field := LineEdit.new()
	field.placeholder_text = "ou l'adresse de l'hôte (192.168…)"
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.custom_minimum_size.y = 64
	field.add_theme_font_size_override("font_size", 22)
	row.add_child(field)
	var join := Button.new()
	join.text = "REJOINDRE"
	join.custom_minimum_size = Vector2(180, 64)
	join.pressed.connect(func() -> void: _join(field.text.strip_edges()))
	row.add_child(join)
	_box.add_child(row)
	_button("RETOUR", _back)


func _show_room() -> void:
	_text("Joueurs (%d / %d) :" % [Net.players.size(), Net.MAX_PLAYERS])
	for id: int in Net.ids():
		var info: Dictionary = Net.players[id]
		var title: String = info.get("title", "")
		var label := _text("%s%s%s%s" % [info.name, "  « %s »" % title if title != "" else "", "  · hôte" if id == 1 else "", "  · toi" if id == Net.my_id() else ""], 24)
		label.add_theme_color_override("font_color", Color.html(info.color))
	if Net.is_host():
		_text("Ton adresse : %s · les places libres sont prises par des bots." % Net.local_address(), 18)
		_button("LANCER LA COURSE", Net.start_game.bind("race"), CYAN)
		_button("LANCER LA CAPTURE DE ZONE", Net.start_game.bind("capture"), CYAN)
		var coop := _button("LANCER LES VAGUES EN COOP (2 à 4)", Net.start_game.bind("waves"), CYAN)
		coop.disabled = Net.players.size() < 2 or Net.players.size() > 4
		var raid := _button("LANCER LE RAID : LE LÉVIATHAN (2 à 4)", Net.start_game.bind("raid"), CYAN)
		raid.disabled = coop.disabled
		var fight := _button("LANCER LE COMBAT (2 joueurs)", Net.start_game.bind("fight"), CYAN)
		fight.disabled = Net.players.size() != 2
	else:
		_text("En attente du lancement par l'hôte…")
	_button("QUITTER LA PARTIE", func() -> void:
		Net.leave()
		Net.start_listening()
		_show())


func _host() -> void:
	Net.stop_listening()
	var error := Net.host()
	_status.text = "" if error == OK else "Impossible d'héberger (erreur %d)" % error
	_show()


func _join(address: String) -> void:
	if address == "":
		return
	var error := Net.join(address)
	_status.text = "Connexion à %s…" % address if error == OK else "Adresse invalide"
	_show()


func _back() -> void:
	Net.leave()
	get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


func _title(text: String) -> void:
	var label := _text(text, 34)
	label.add_theme_color_override("font_color", CYAN)


func _text(text: String, size := 22) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	_box.add_child(label)
	return label


func _button(text: String, action: Callable, color := Color.WHITE) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 76
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", color)
	button.pressed.connect(action, CONNECT_DEFERRED)
	_box.add_child(button)
	return button
