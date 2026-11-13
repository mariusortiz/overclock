extends Season2Scene
## Chapitre 14 : Le Virus. In the desert, the Virus takes a body: a black
## Titan rises from the sand. Le Créateur: "Not yet."


func _init() -> void:
	episode_number = 14
	episode_title = "LE VIRUS"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(1)
	_fade_shade(0.0, 0.6)
	var calamity := _hero("cowgirl", STAGE + Vector3(-0.9, 0, 3.0), PI)
	var captain := _hero("captain", STAGE + Vector3(0.9, 0, 3.0), PI)
	_dolly(STAGE + Vector3(0, 1.6, 7.6), STAGE + Vector3(0, 1.6, 6.4), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 5.0, true)
	_narrate("Le désert. Le sable se met à grésiller.", 3.0)
	_glitch(0.6)
	await _until(6.2)
	_say(calamity, "Ça, c'est pas du vent.", 2.2, -1.0)
	await _until(8.6)
	var titan := _virus_titan(STAGE + Vector3(0, 0, -12))
	_rise(titan, TITAN_HEIGHT, 2.4)
	_glitch(2.0)
	_shake = 0.25
	_dolly(STAGE + Vector3(2.5, 0.8, 6.0), STAGE + Vector3(2.0, 0.6, 5.0), STAGE + Vector3(0, 2, -12),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.8, -12), 3.2, true)
	_narrate("Le Virus prend corps.", 2.4)
	await _until(12.0)
	_stomp(STAGE + Vector3(0, 0, -12), 1.2)
	_impact_frame()
	for hero in [calamity, captain]:
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3(0, 1.3, 0), titan.global_position + Vector3(0, TITAN_HEIGHT * 0.6, 0), GOLD, 0.06)
	await _until(13.6)
	_dolly(STAGE + Vector3(0, 1.6, 6.0), STAGE + Vector3(0, 1.6, 5.0), STAGE + Vector3(0, 1.5, 3),
			STAGE + Vector3(0, 1.5, 3), 4.0, true)
	_say(captain, "Les tirs passent au travers !", 2.4, 1.0)
	await _until(16.4)
	var creator := _creator(STAGE + Vector3(-3.5, 0, 4.0), PI * 0.8)
	_appear(creator)
	_dolly(STAGE + Vector3(-3.0, 1.6, 7.6), STAGE + Vector3(-3.2, 1.7, 6.6), STAGE + Vector3(-3.5, 1.6, 4),
			STAGE + Vector3(-3.5, 1.7, 4), 5.0, true)
	await _until(17.4)
	_say(creator, "Vous ne pouvez pas le battre.", 2.2, 1.0)
	await _until(19.8)
	_say(creator, "Pas encore.", 1.6, 1.0)
	await _until(21.6)
	_vanish(creator)
	_glitch(0.6)
	await _until(22.6)
	_narrate("MISSION : tiens le désert contre ses créatures, jusqu'à leur gardien.", 4.2)
	await _until(27.6)
	_fade_shade(1.0, 1.0)
