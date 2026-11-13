extends StoryScene
## Chapitre 9 : Titan Mk II. The red Titan walks into the city; the fleet
## attacks it from the sky.


func _init() -> void:
	episode_number = 9
	episode_title = "TITAN MK II"
	duration = 28.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(4)
	_fade_shade(0.0, 0.6)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -10), TITAN_HEIGHT * 1.4, Color(1.0, 0.45, 0.4))
	_titan.play(&"walk")
	_dolly(STAGE + Vector3(-4, 0.6, 9), STAGE + Vector3(-2.5, 1.2, 7), STAGE + Vector3(0, 2, -10),
			STAGE + Vector3(0, TITAN_HEIGHT * 1.2, -10), 6.0)
	_narrate("Le Titan Mk II entre dans la ville. Deux fois plus grand.", 3.4)
	await _until(6.4)
	_stomp(STAGE + Vector3(0, 0, -10), 1.2)
	await _until(7.6)
	var ships: Array[RaceShip] = []
	for index in 4:
		var ship := _parked_ship([CYAN, RED, GOLD, Color(1.0, 0.5, 0.8)][index], STAGE + Vector3(-40 + index * 3, 20 + index, 20), 0.0)
		ship.scale = Vector3.ONE * 1.6
		_fly_to(ship, STAGE + Vector3(-40 + index * 3, 20 + index, 20), STAGE + Vector3(-6 + index * 4, 14 + index, -6), 3.0)
		ships.append(ship)
	_dolly(STAGE + Vector3(0, 6, 12), STAGE + Vector3(0, 9, 8), STAGE + Vector3(-10, 16, 5),
			STAGE + Vector3(0, 14, -6), 3.2)
	await _until(9.0)
	_say(ships[0], "Escadrille, en formation !", 2.4, -1.0, 1.0)
	await _until(11.4)
	for index in ships.size():
		_beam(ships[index].global_position, _titan.global_position + Vector3(0, TITAN_HEIGHT, 0), ships[index].color, 0.12)
		await _until(_clock + 0.25)
	_ring(_titan.global_position + Vector3(0, TITAN_HEIGHT * 0.9, 0), CYAN, 10.0, 0.6)
	_impact_frame()
	await _until(13.6)
	_say(ships[1], "Un bouclier ! Il encaisse tout !", 2.4, 1.0, 1.0)
	await _until(16.4)
	_say(ships[0], "Encore un passage. Restez groupés !", 2.6, -1.0, 1.0)
	await _until(19.4)
	_narrate("MISSION : attaque depuis le ciel, termine dans les 3 premiers.", 3.8)
	await _until(26.8)
	_fade_shade(1.0, 1.0)
