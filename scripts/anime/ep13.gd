extends Season2Episode
## Épisode 13 : La course corrompue. A race in the asteroid belt: the circuit
## tears, black ships of the Virus attack, and a green ship nobody knows
## clears the way before vanishing.


func _init() -> void:
	episode_number = 13
	episode_title = "LA COURSE CORROMPUE"
	duration = 88.6


func _story() -> void:
	_load_space(2)
	var soldier := _ship("SOLDAT", CYAN, -10.0, Vector2(-3.5, 0), 0.0)
	var vipere := _ship("VIPÈRE", RED, -10.0, Vector2(3.5, 0), 0.0)
	var captain := _ship("CAPITAINE", GOLD, -18.0, Vector2(0, 0), 0.0)
	_follow(captain, Vector3(0, 3.0, 9.0), Vector3(0, 0.5, -20.0))
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La ceinture d'astéroïdes. Une course d'entraînement.", 3.0)
	await _until(5.0)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "Le perdant paie les réparations.", 2.4, -1.0, 1.0)
	await _until(8.0)
	await _title_card(5.0)

	# 13 s: go.
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	for count in ["3", "2", "1"]:
		_narrate(count, 0.8, true)
		await _until(_clock + 0.9)
	_narrate("GO !", 0.7, true)
	for ship in [soldier, vipere, captain]:
		ship.skill = 1.0
		ship.boost(2.0)
	_speed(2.0)
	await _until(19.0)
	_follow(soldier, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(soldier, "Elle prend l'intérieur...", 2.0, 1.0, 1.0)
	await _until(21.4)

	# 21.4 s: the circuit tears.
	_glitch(1.4)
	_impact_frame()
	_follow(captain, Vector3(4.0, 2.0, 6.0), Vector3(0, 0.3, -8.0))
	_say(captain, "La piste ! Elle saute !", 2.0, 1.0, 1.0)
	await _until(24.0)
	var virus_ships: Array[RaceShip] = []
	for index in 4:
		var ship := _ship("VIRUS", VIRUS_DARK, soldier.distance + 30.0 + 8.0 * index, Vector2((index % 2) * 6.0 - 3.0, 1.0), 1.0)
		_corrupt(ship)
		virus_ships.append(ship)
	_follow(virus_ships[0], Vector3(0, 2.0, -8.0), Vector3(0, 0.5, 6.0))
	_narrate("Des vaisseaux noirs. Sans pilote.", 2.6)
	await _until(27.0)
	for index in 3:
		_ship_laser(virus_ships[index], [soldier, vipere, captain][index])
		_impact_frame()
		await _until(_clock + 0.5)
	_follow(vipere, Vector3(0, 1.4, 5.0), Vector3(0, 0.5, -10.0))
	_say(vipere, "Ils tirent sur tout ce qui bouge !", 2.2, -1.0, 1.0)
	await _until(31.0)
	_ship_laser(vipere, virus_ships[0])
	_ship_laser(soldier, virus_ships[1])
	await _until(32.0)
	_follow(soldier, Vector3(0, 1.4, 5.0), Vector3(0, 0.5, -10.0))
	_say(soldier, "On les touche, ils ne tombent pas !", 2.4, 1.0, 1.0)
	await _until(35.0)
	_glitch(0.8)
	for ship in virus_ships:
		_ship_laser(ship, soldier)
		await _until(_clock + 0.3)
	_say(soldier, "Bouclier à zéro...", 1.8, 1.0, 1.0)
	await _until(39.0)

	# 39 s: a green ship.
	var mainframe := _ship_of("ship_mainframe", "???", soldier.distance - 14.0, Vector2(0, 2.0), 1.4)
	mainframe.boost(6.0)
	_appear(mainframe)
	_follow(mainframe, Vector3(-3.0, 1.5, 6.0), Vector3(0, 0.5, -12.0))
	_speed(2.0)
	await _until(41.0)
	_narrate("Un vaisseau vert, venu de nulle part.", 2.6)
	await _until(43.6)
	for ship in virus_ships:
		_ship_laser(mainframe, ship)
		_ring(ship.global_position, VIRUS, 6.0, 0.4)
		await _until(_clock + 0.35)
	for ship in virus_ships:
		_vanish(ship, 0.4)
	_impact_frame()
	await _until(46.4)
	_follow(soldier, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(soldier, "Personne ne pilote comme ça...", 2.4, -1.0, 1.0)
	await _until(49.2)
	_follow(mainframe, Vector3(2.0, 1.2, -4.0), Vector3(0, 0.6, 0))
	_say(mainframe, "Sortez de la piste. Elle est à lui, maintenant.", 3.0, 1.0, 1.0)
	await _until(52.6)
	_vanish(mainframe)
	_glitch(0.6)
	await _until(54.0)
	_follow(vipere, Vector3(0, 2.4, 8.0), Vector3(0, 0.5, -20.0))
	_say(vipere, "« À lui » ? À qui ?!", 2.0, -1.0, 1.0)
	await _until(56.6)

	# 56.6 s: back in the station's hall.
	_wipe()
	_load_showroom()
	_camera.far = 400.0
	var hero_soldier := _hero("soldier", Vector3(-1.0, 0, 1.0), PI * 0.8, "none")
	var hero_vipere := _hero("sand_ghost", Vector3(1.0, 0, 1.2), -PI * 0.8, "none")
	var hero_captain := _hero("captain", Vector3(0, 0, -0.4), 0.0, "none")
	_face(hero_captain, hero_soldier)
	_dolly(Vector3(3, 1.6, 4.5), Vector3(2.4, 1.6, 4.0), Vector3(0, 1.3, 0.6), Vector3(0, 1.3, 0.6), 10.0)
	await _until(57.4)
	_say(hero_captain, "Trois vaisseaux en miettes. Un circuit qui n'existe plus.", 3.2, 1.0)
	await _until(61.2)
	_say(hero_soldier, "Et un pilote en vert qui nous sauve.", 2.4, -1.0)
	await _until(64.0)
	_say(hero_vipere, "Le même que ta vache ?", 2.0, 1.0)
	await _until(66.4)
	_say(hero_soldier, "Je parie que oui.", 1.8, -1.0)
	await _until(68.6)
	_say(hero_captain, "« La piste est à lui. » Le virus prend le contrôle des lieux.", 3.2, 1.0)
	await _until(72.4)
	_glitch(1.0)
	await _until(73.6)
	_narrate("Au même moment, dans le désert, le sable se met à trembler.", 3.6, true)
	await _until(78.0)
	await _to_be_continued(78.6)
