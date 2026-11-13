extends Season2Scene
## Chapitre 13 : La course corrompue. The circuit tears, black ships attack,
## and a green ship nobody knows clears the way.


func _init() -> void:
	episode_number = 13
	episode_title = "LA COURSE CORROMPUE"
	duration = 28.0


func _story() -> void:
	await _title_card(2.6)
	_load_space(2)
	_fade_shade(0.0, 0.6)
	var soldier := _ship("SOLDAT", CYAN, -10.0, Vector2(-3.5, 0), 0.0)
	var vipere := _ship("VIPÈRE", RED, -10.0, Vector2(3.5, 0), 0.0)
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	_narrate("Une course d'entraînement, dans la ceinture d'astéroïdes.", 3.0)
	await _until(6.2)
	for ship in [soldier, vipere]:
		ship.skill = 1.0
		ship.boost(2.0)
	_speed(1.5)
	await _until(8.0)
	_glitch(1.2)
	_impact_frame()
	var virus_ships: Array[RaceShip] = []
	for index in 3:
		var ship := _ship("VIRUS", VIRUS_DARK, soldier.distance + 24.0 + 8.0 * index, Vector2(index * 3.0 - 3.0, 1.0), 1.0)
		_corrupt(ship)
		virus_ships.append(ship)
	_follow(virus_ships[0], Vector3(0, 2.0, -8.0), Vector3(0, 0.5, 6.0))
	_narrate("La piste se déchire. Des vaisseaux noirs, sans pilote.", 3.0)
	await _until(11.4)
	_ship_laser(virus_ships[0], soldier)
	_ship_laser(virus_ships[1], vipere)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "Ils tirent sur tout ce qui bouge !", 2.4, -1.0, 1.0)
	await _until(14.4)
	var mainframe := _ship_of("ship_mainframe", "???", soldier.distance - 12.0, Vector2(0, 2.0), 1.4)
	mainframe.boost(6.0)
	_appear(mainframe)
	_follow(mainframe, Vector3(2.0, 1.4, 5.0), Vector3(0, 0.5, -10.0))
	_narrate("Un vaisseau vert, que personne ne connaît.", 2.6)
	await _until(17.4)
	for ship in virus_ships:
		_ship_laser(mainframe, ship)
		_glitch(0.3)
		await _until(_clock + 0.4)
	for ship in virus_ships:
		_vanish(ship, 0.4)
	await _until(19.6)
	_follow(soldier, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(soldier, "Qui pilote ce truc ?", 2.0, 1.0, 1.0)
	_vanish(mainframe)
	await _until(22.0)
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	_narrate("MISSION : la course continue. Termine dans les 3 premiers.", 4.0)
	await _until(26.6)
	_fade_shade(1.0, 1.0)
