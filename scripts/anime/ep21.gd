extends Season3Episode
## Épisode 21 : Le Portail. A week after the reboot, the squad celebrates at
## the station, Le Créateur drops by for Vipère's rematch, and a ring of light
## opens over the hangar. It pulls in the squad and their ships; Le Créateur
## jumps after them. They land under a sky with three moons.


func _init() -> void:
	episode_number = 21
	episode_title = "LE PORTAIL"
	duration = 77.0


func _story() -> void:
	_load_arena(0)
	var heroes := _squad(STAGE + Vector3(0, 0, -1), PI)
	for id in ["soldier", "cowgirl", "captain"]:
		(heroes[id] as CharacterModel).play(&"victory")
	var ships := [_parked_ship(CYAN, STAGE + Vector3(-9, 0.6, -6), 0.4), _parked_ship(RED, STAGE + Vector3(9, 0.6, -7), -0.4)]
	_dolly(STAGE + Vector3(-6, 2.0, 9), STAGE + Vector3(-3, 1.8, 7), STAGE + Vector3(0, 1.2, -1), STAGE + Vector3(0, 1.3, -1), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La station. Une semaine après le redémarrage.", 3.0)
	await _until(4.8)
	_say(heroes.captain, "Au monde tout neuf !", 2.0, 1.0)
	await _until(7.4)
	await _title_card(5.0)

	# 12.4 s: Le Créateur drops by.
	_glitch(0.8)
	var creator := _creator(STAGE + Vector3(0, 0, -5), PI)
	_appear(creator, 0.8)
	for id: String in heroes:
		_face(heroes[id], creator)
		(heroes[id] as CharacterModel).play(&"idle")
	_dolly(STAGE + Vector3(6.0, 2.4, 1.6), STAGE + Vector3(5.0, 2.2, 0.6), STAGE + Vector3(0, 1.5, -5), STAGE + Vector3(0, 1.6, -5), 7.0)
	await _until(13.6)
	_say(creator, "Je passais. Une revanche avait été promise.", 2.8, -1.0)
	await _until(16.8)
	_say(heroes.sand_ghost, "Enfin ! Cette fois, je te bats.", 2.4, 1.0)
	await _until(19.6)

	# 19.6 s: the sky hums.
	_shake = 0.25
	var portal := _portal(STAGE + Vector3(0, 10, -12), 4.5)
	_open(portal, 1.6)
	_dolly(STAGE + Vector3(0, 1.4, 8), STAGE + Vector3(0, 1.0, 6), STAGE + Vector3(0, 2, -3), STAGE + Vector3(0, 9, -12), 4.0)
	_narrate("Au-dessus du hangar, un anneau de lumière.", 3.0)
	await _until(23.6)
	_dolly(STAGE + Vector3(1.8, 1.7, -3.0), STAGE + Vector3(1.4, 1.7, -3.4), STAGE + Vector3(0, 1.6, -5), STAGE + Vector3(0, 2.2, -5), 5.0)
	_say(creator, "Ce n'est pas moi. Ça, je ne l'ai pas écrit.", 2.8, -1.0)
	await _until(26.8)
	_say(heroes.soldier, "Tout le monde à couvert !", 2.0, 1.0)
	await _until(29.0)

	# 29 s: it pulls.
	_dolly(STAGE + Vector3(-7, 1.0, 8), STAGE + Vector3(-6, 1.4, 7), STAGE + Vector3(0, 3, -4), STAGE + Vector3(0, 8, -10), 9.0)
	_pull_in(ships[0], portal, 1.6)
	_pull_in(ships[1], portal, 1.6, 0.4)
	await _until(30.6)
	_say(heroes.kunoichi, "Ça m'aspire !", 1.6, 1.0)
	var order := ["kunoichi", "cowgirl", "captain", "ronin", "paladin", "sand_ghost", "soldier"]
	for index in order.size():
		_pull_in(heroes[order[index]], portal, 1.4, 0.5 + 0.6 * index)
	await _until(33.0)
	_speed(3.0)
	_shake = 0.3
	await _until(36.0)
	_say(heroes.soldier, "La vache ! Reste en arrière !", 2.0, 1.0)
	await _until(38.6)

	# 38.6 s: he follows them.
	_dolly(STAGE + Vector3(1.8, 1.5, -2.6), STAGE + Vector3(1.2, 1.3, -3.0), STAGE + Vector3(0, 1.5, -5), STAGE + Vector3(0, 2.4, -5), 4.0)
	_face(creator, portal)
	await _until(39.4)
	_say(creator, "Je ne les laisse pas seuls.", 2.0, -1.0)
	await _until(41.6)
	_pull_in(creator, portal, 1.2)
	await _until(43.0)
	_impact_frame()
	_fade_shade(1.0, 0.3)
	await _until(43.6)

	# 43.6 s: elsewhere.
	_load_world("crystal")
	_moons()
	var landed := {}
	for index in SQUAD.size():
		var id: String = SQUAD[index]
		var hero := _hero(id, STAGE + Vector3(-4.5 + 1.5 * index, 6, -2 - (index % 2)), PI, "none")
		var pivot := hero.get_parent() as Node3D
		get_tree().create_timer(0.25 * index).timeout.connect(_drop.bind(pivot, STAGE.y, 0.8))
		landed[id] = hero
	var lost := _creator(STAGE + Vector3(0, 7, -7), PI)
	get_tree().create_timer(2.0).timeout.connect(_drop.bind(lost.get_parent(), STAGE.y, 0.8))
	_dolly(STAGE + Vector3(0, 30, 10), STAGE + Vector3(0, 3, 8), STAGE + Vector3(0, 2, -60), STAGE + Vector3(0, 1.4, -2), 4.0)
	_fade_shade(0.0, 0.8)
	_narrate("Ailleurs. Très loin.", 2.6)
	await _until(48.0)
	_stomp(STAGE + Vector3(0, 0, -7), 0.6)
	_dolly(STAGE + Vector3(-3, 1.6, 4), STAGE + Vector3(-2.4, 1.6, 3.4), STAGE + Vector3(0, 1.3, -2), STAGE + Vector3(0, 1.3, -2), 9.0)
	await _until(49.4)
	_say(landed.ronin, "Où sommes-nous ?", 1.8, 1.0)
	await _until(51.6)
	_say(landed.paladin, "Le Créateur doit savoir. C'est son monde.", 2.6, 1.0)
	await _until(54.6)
	_dolly(STAGE + Vector3(1.2, 1.7, -4.2), STAGE + Vector3(0.9, 1.7, -4.6), STAGE + Vector3(0, 1.6, -7), STAGE + Vector3(0, 1.6, -7), 7.0)
	_say(lost, "Non. Ce n'est pas le mien.", 2.2, -1.0)
	await _until(57.2)
	_say(lost, "Pour la première fois... je ne sais pas.", 2.8, -1.0)
	await _until(60.4)

	# 60.4 s: the sky.
	_dolly(STAGE + Vector3(0, 1.2, 6), STAGE + Vector3(0, 1.0, 5), STAGE + Vector3(0, 2, -4), STAGE + Vector3(-10, 60, -150), 7.0)
	await _until(63.0)
	_narrate("Trois lunes. Aucune étoile connue.", 3.4, true)
	await _until(67.0)
	await _to_be_continued(67.6)
