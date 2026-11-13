extends Season2Episode
## Épisode 14 : Le Virus. In the desert, the Virus takes a body: a black
## Titan rises from the sand. The heroes' shots pass through it. Le Créateur
## appears on a dune: "You can't beat it. Not yet."


func _init() -> void:
	episode_number = 14
	episode_title = "LE VIRUS"
	duration = 108.0


func _story() -> void:
	_load_arena(1)
	var calamity := _hero("cowgirl", STAGE + Vector3(0, 0, 1.0), 0.0)
	var captain := _hero("captain", STAGE + Vector3(-1.6, 0, 2.0), 0.0)
	var ronin := _hero("ronin", STAGE + Vector3(1.6, 0, 2.0), 0.0)
	_dolly(STAGE + Vector3(0, 1.2, -5), STAGE + Vector3(0, 1.4, -4), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 1), 7.0, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Le temple du désert. Calamity a vu le sable bouger tout seul.", 3.4)
	await _until(5.4)
	_say(calamity, "Là. Il respire.", 2.0, 1.0)
	await _until(8.0)
	await _title_card(5.0)

	# 13 s: it rises.
	_shake = 0.3
	_glitch(1.5)
	var virus := _virus_titan(STAGE + Vector3(0, 0, -12), TITAN_HEIGHT * 1.2)
	_rise(virus, TITAN_HEIGHT * 1.2, 4.0)
	_dolly(STAGE + Vector3(-3, 0.6, 6), STAGE + Vector3(-2.4, 0.8, 5), STAGE + Vector3(0, 3, -12), STAGE + Vector3(0, TITAN_HEIGHT * 1.1, -12), 5.0, true)
	for hero in [calamity, captain, ronin]:
		hero.play(&"aim")
	await _until(15.0)
	_narrate("Le Virus a pris un corps.", 2.8, true)
	await _until(18.4)
	_stomp(STAGE + Vector3(0, 0, -12), 1.2)
	_impact_frame()
	await _until(19.6)
	_dolly(STAGE + Vector3(2.4, 1.5, 5.0), STAGE + Vector3(2.0, 1.5, 4.4), STAGE + Vector3(0, 1.4, 1.6), STAGE + Vector3(0, 1.4, 1.6), 4.0, true)
	_say(captain, "C'est un Titan... en pire.", 2.2, -1.0)
	await _until(22.2)
	_say(calamity, "Feu à volonté !", 1.8, 1.0)
	await _until(24.2)

	# 24.2 s: their shots pass through.
	_dolly(STAGE + Vector3(0, 4, 9), STAGE + Vector3(0, 4.5, 8), STAGE + Vector3(0, 6, -12), STAGE + Vector3(0, 7, -12), 6.0, true)
	for round in 3:
		for hero in [calamity, captain, ronin]:
			hero.play(&"shoot", true)
			_beam(hero.global_position + Vector3.UP * 1.3, virus.global_position + Vector3(randf_range(-2, 2), randf_range(4, 9), 0),
					[GOLD, Color(1.0, 0.6, 0.2), Color(1.0, 0.85, 0.9)][[calamity, captain, ronin].find(hero)], 0.08)
			await _until(_clock + 0.18)
		_glitch(0.3)
	await _until(30.0)
	_narrate("Les tirs le traversent comme s'il n'existait pas.", 3.0)
	await _until(33.4)
	_say(ronin, "Il n'est pas vraiment là.", 2.0, 1.0)
	await _until(35.8)
	virus.play(&"shoot", true)
	_stomp(STAGE + Vector3(0, 0, -6), 1.5)
	_ring(STAGE + Vector3(0, 0.2, -8), VIRUS, 20.0, 0.8)
	for hero in [calamity, captain, ronin]:
		hero.play(&"die", true)
	_impact_frame()
	_shake = 0.35
	await _until(38.6)
	_dolly(STAGE + Vector3(-2, 0.5, 5), STAGE + Vector3(-1.6, 0.6, 4.4), STAGE + Vector3(0, 0.5, 1.5), STAGE + Vector3(0, 0.5, 1.5), 4.0, true)
	_say(captain, "Repli ! Repli !", 1.8, -1.0)
	await _until(41.0)

	# 41 s: on the dune, a man in a suit.
	_glitch(0.8)
	var creator := _creator(STAGE + Vector3(7, 0, 4), -PI / 2.0)
	_appear(creator)
	_dolly(STAGE + Vector3(10, 1.6, 7), STAGE + Vector3(9.4, 1.6, 6.4), STAGE + Vector3(7, 1.5, 4), STAGE + Vector3(7, 1.5, 4), 5.0, true)
	await _until(42.6)
	_say(creator, "Vous ne pouvez pas le battre.", 2.4, -1.0)
	await _until(45.4)
	_say(creator, "Pas encore.", 1.8, -1.0)
	await _until(47.6)
	creator.play(&"shoot", true)
	_ring(virus.global_position + Vector3.UP * 2.0, VIRUS, 14.0, 0.7)
	_glitch(1.2)
	_rise(virus, -TITAN_HEIGHT * 1.2, 3.0)
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 4, 9), STAGE + Vector3(0, 5, -12), STAGE + Vector3(0, 2, -12), 4.0, true)
	_narrate("Le Titan noir s'enfonce dans le sable. Pour l'instant.", 3.2)
	await _until(52.0)

	# 52 s: who are you?
	for hero in [calamity, captain, ronin]:
		hero.play(&"idle")
		_face(hero, creator)
	_face(creator, captain)
	_dolly(STAGE + Vector3(3.5, 1.6, 6), STAGE + Vector3(3.0, 1.6, 5.4), STAGE + Vector3(4, 1.4, 3), STAGE + Vector3(4, 1.4, 3), 12.0, true)
	_say(captain, "Qui êtes-vous ?!", 1.8, -1.0)
	await _until(54.4)
	_say(creator, "Celui qui a écrit ce monde.", 2.6, 1.0)
	await _until(57.4)
	_say(calamity, "... Écrit ?", 1.6, -1.0)
	await _until(59.4)
	_say(creator, "Chaque dune. Chaque balle. Chacun de vous.", 3.0, 1.0)
	await _until(62.8)
	_say(ronin, "Et le Virus ?", 1.6, -1.0)
	await _until(64.8)
	_say(creator, "Lui aussi. Par erreur.", 2.2, 1.0)
	await _until(67.4)
	_say(creator, "Réunissez toute l'escouade. Demain, je vous dirai tout.", 3.2, 1.0)
	await _until(71.0)
	_vanish(creator)
	await _until(72.4)
	_dolly(STAGE + Vector3(0, 1.4, 6), STAGE + Vector3(0, 1.6, 5), STAGE + Vector3(0, 1.4, 1.6), STAGE + Vector3(0, 1.4, 1.6), 6.0, true)
	_say(calamity, "Bon. On a un dieu à tête de vache.", 2.6, 1.0)
	await _until(75.6)
	_say(captain, "Et un virus qu'on ne peut pas toucher.", 2.4, -1.0)
	await _until(78.4)
	await _to_be_continued(94.0)
