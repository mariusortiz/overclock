extends StoryScene
## Chapitre 4 : L'Escouade Écarlate. Squad against squad for the station's
## three zones.


func _init() -> void:
	episode_number = 4
	episode_title = "L'ESCOUADE ÉCARLATE"
	duration = 28.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var zones := [_zone("A", STAGE + Vector3(-9, 0, -6), 0.0), _zone("B", STAGE + Vector3(0, 0, -10), 0.0),
			_zone("C", STAGE + Vector3(9, 0, -6), 0.0)]
	var kunoichi := _hero("kunoichi", STAGE + Vector3(-1.0, 0, 2.0), 0.0)
	var soldier := _hero("soldier", STAGE + Vector3(1.0, 0, 2.4), 0.0)
	var vipere := _hero("sand_ghost", STAGE + Vector3(0, 0, -14.0), PI)
	var rival := _hero("cowboy", STAGE + Vector3(2.0, 0, -14.5), PI)
	_dolly(STAGE + Vector3(0, 8, 10), STAGE + Vector3(0, 6, 7), STAGE + Vector3(0, 0, -6),
			STAGE + Vector3(0, 0, -8), 5.0, true)
	_narrate("La station est l'enjeu. Trois zones, deux escouades.", 3.4)
	await _until(7.0)
	_dolly(STAGE + Vector3(0, 1.5, -10.0), STAGE + Vector3(0.6, 1.6, -10.6), STAGE + Vector3(0, 1.5, -14),
			STAGE + Vector3(0, 1.5, -14), 4.0, true)
	_say(vipere, "Les zones, c'est notre terrain.", 2.4, -1.0)
	await _until(9.8)
	_say(rival, "Faites vos prières !", 2.0, 1.0)
	await _until(12.2)
	_dolly(STAGE + Vector3(-2.4, 1.5, 5.0), STAGE + Vector3(-2.0, 1.6, 4.4), STAGE + Vector3(-0.4, 1.5, 1.6),
			STAGE + Vector3(-0.4, 1.5, 1.6), 5.0, true)
	_say(kunoichi, "Je prends la A. Toi, la B.", 2.4, -1.0)
	await _until(14.8)
	_say(soldier, "Et la C ?", 1.6, 1.0)
	await _until(16.6)
	_say(kunoichi, "La C, c'est quand on aura gagné.", 2.4, -1.0)
	await _until(19.2)
	kunoichi.play(&"walk", true)
	_move(kunoichi.get_parent() as Node3D, Vector3(-1.6, 0, -1.4))
	_dolly(STAGE + Vector3(-12, 3, 0), STAGE + Vector3(-11, 2.5, -2), STAGE + Vector3(-9, 0.5, -6),
			STAGE + Vector3(-9, 0.5, -6), 4.0, true)
	_turn_zone(zones[0], 1.0, 2.8)
	_turn_zone(zones[2], -1.0, 2.8)
	await _until(22.8)
	_narrate("MISSION : prends les zones de la station à l'Écarlate.", 3.6)
	await _until(26.6)
	_fade_shade(1.0, 1.0)
