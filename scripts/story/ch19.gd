extends Season2Scene
## Chapitre 19 : Ctrl+Z. In the black, a voice: Le Créateur was only
## scattered. He undoes, once. The fleet gathers over the city.


func _init() -> void:
	episode_number = 19
	episode_title = "CTRL+Z"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_space(4)
	_fade_shade(0.0, 0.6)
	var soldier := _ship("SOLDAT", CYAN, -10.0, Vector2(-3.5, 0), 0.4)
	var vipere := _ship("VIPÈRE", RED, -10.0, Vector2(3.5, 0), 0.4)
	_follow(soldier, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_narrate("Le noir. Deux vaisseaux, seuls.", 2.8)
	await _until(6.0)
	_say(soldier, "Tu l'entends ? Une voix.", 2.2, 1.0, 1.0)
	await _until(8.6)
	_glitch(0.8)
	_narrate("« Je ne suis pas effacé. Seulement dispersé. »", 3.2)
	await _until(12.0)
	_narrate("« Je peux annuler. Une fois. »", 2.6)
	await _until(14.8)
	_glitch(1.2)
	_impact_frame()
	var fleet: Array[RaceShip] = []
	for index in 4:
		var ship := _ship(["CAPITAINE", "KUNOICHI", "RONIN", "CALAMITY"][index], [GOLD, MAGENTA, Color(0.6, 0.6, 1.0), Color(1.0, 0.55, 0.2)][index],
				soldier.distance - 6.0 - 4.0 * index, Vector2(-4.5 + 3.0 * index, 1.2), 1.0)
		_appear(ship, 0.5)
		fleet.append(ship)
	var mainframe := _ship_of("ship_mainframe", "LE CRÉATEUR", soldier.distance - 22.0, Vector2(0, 2.4), 1.2)
	_appear(mainframe)
	_follow(mainframe, Vector3(0, 3.0, 9.0), Vector3(0, 0.5, -20.0))
	_narrate("CTRL+Z. Tout le monde revient.", 2.8)
	await _until(18.4)
	for ship in [soldier, vipere]:
		ship.skill = 1.0
		ship.boost(2.0)
	_speed(2.0)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "On a une ville à sauver. On y va !", 2.4, -1.0, 1.0)
	await _until(21.6)
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	_narrate("MISSION : rejoins la ville avec la flotte. Termine 2e ou mieux.", 4.0)
	await _until(26.6)
	_fade_shade(1.0, 1.0)
