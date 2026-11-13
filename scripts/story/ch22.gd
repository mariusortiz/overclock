extends Season3Scene
## Chapitre 22 : Terre inconnue. The crystal planet; Le Créateur has no power
## here; the sentinels rise.


func _init() -> void:
	episode_number = 22
	episode_title = "TERRE INCONNUE"
	duration = 27.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("crystal")
	_moons()
	_fade_shade(0.0, 0.6)
	var cowgirl := _hero("cowgirl", STAGE + Vector3(-1, 0, 2), PI)
	var creator := _creator(STAGE + Vector3(1, 0, 2.2), PI)
	_dolly(STAGE + Vector3(0, 1.6, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 6.0)
	_narrate("Une planète de cristal, sous trois lunes.", 2.8)
	await _until(6.4)
	_say(cowgirl, "Ramène-nous, la vache.", 2.0, -1.0)
	await _until(8.6)
	_no_power(creator)
	await _until(9.6)
	_say(creator, "Rien. Pas une ligne de code, ici.", 2.4, 1.0)
	await _until(12.4)
	_shake = 0.3
	for index in 4:
		var sentinel := _crystal_creature(STAGE + Vector3(-4.5 + 3.0 * index, 0, -5), PI, &"aim")
		_rise(sentinel, 2.2, 1.2)
	_dolly(STAGE + Vector3(0, 2, 8), STAGE + Vector3(0, 2.4, 7), STAGE + Vector3(0, 1.2, -4), STAGE + Vector3(0, 1.2, -5), 5.0)
	_narrate("Le sol se fend. Les sentinelles se lèvent.", 2.8)
	await _until(16.0)
	_say(cowgirl, "Ça, je sais faire.", 1.8, -1.0)
	await _until(18.4)
	_narrate("MISSION : tiens la planète de cristal jusqu'à la reine des sentinelles.", 4.0)
	await _until(23.0)
	_fade_shade(1.0, 1.0)
