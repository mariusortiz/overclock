extends AnimeDirector
## Épisode 2 : Le défi. A month after the Titan, a red ship lands in the city:
## Vipère, the best pilot around, and her Escouade Écarlate. She challenges
## the squad to a race; the stake is the station.


func _init() -> void:
	episode_number = 2
	episode_title = "LE DÉFI"
	duration = 120.0


func _story() -> void:
	# 0 s: the city, at peace. The squad celebrates.
	_load_arena(4)
	var soldier := _hero("soldier", STAGE + Vector3(-1.5, 0, 1), PI)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(-0.5, 0, 1.6), PI)
	var captain := _hero("captain", STAGE + Vector3(0.6, 0, 1.4), PI)
	var ronin := _hero("ronin", STAGE + Vector3(1.6, 0, 1), PI)
	for hero: CharacterModel in [kunoichi, captain]:
		hero.play(&"victory", true)
	_dolly(STAGE + Vector3(0, 1.2, 9), STAGE + Vector3(0, 1.4, 7.5), STAGE + Vector3(0, 1.3, 1),
			STAGE + Vector3(0, 1.3, 1), 8.0, true)
	_fade_shade(0.0, 1.2)
	_narrate("Un mois après la chute du Titan.", 3.0)
	await _until(3.2)
	_say(soldier, "Un mois sans attaque.", 2.2, -1.0)
	await _until(5.6)
	_say(ronin, "Trop calme.", 2.0, 1.0)
	await _until(8.4)

	await _title_card(5.0)

	# 13.4 s: a red ship cuts through the sky and lands.
	var red := _parked_ship(RED, STAGE + Vector3(-40, 25, -30), 0.0)
	red.scale = Vector3.ONE * 1.6
	_fly_to(red, STAGE + Vector3(-40, 25, -30), STAGE + Vector3(0, 6, -4), 3.0)
	_dolly(STAGE + Vector3(2.5, 0.8, 6), STAGE + Vector3(2, 0.9, 5), STAGE + Vector3(-6, 10, -10),
			STAGE + Vector3(0, 4, -4), 3.2, true)
	_speed(2.0)
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.play(&"aim")
		hero.get_parent().rotation.y = 0.0
	await _until(16.6)
	create_tween().tween_property(red, "global_position", STAGE + Vector3(0, 0.6, -4), 1.0) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await _until(17.6)
	_stomp(STAGE + Vector3(0, 0, -4), 0.6)
	_impact_frame()
	await _until(18.4)
	# Vipère steps out.
	var vipere := _hero("sand_ghost", STAGE + Vector3(1.6, 0, -3.2), PI)
	Effects.burst(_set, vipere.global_position + Vector3.UP, RED, 30)
	_dolly(STAGE + Vector3(2.4, 1.5, -0.5), STAGE + Vector3(2.2, 1.6, -0.9), STAGE + Vector3(1.6, 1.5, -3.2),
			STAGE + Vector3(1.6, 1.6, -3.2), 5.0, true)
	_narrate("VIPÈRE · meilleure pilote du secteur", 3.0)
	await _until(20.0)
	_say(vipere, "C'est vous, les tombeurs du Titan ?", 2.6, -1.0)
	await _until(23.0)

	# 23 s: face to face.
	_dolly(STAGE + Vector3(5.5, 1.5, -0.5), STAGE + Vector3(5.2, 1.6, -0.2), STAGE + Vector3(0, 1.3, -1),
			STAGE + Vector3(0, 1.3, -1), 8.0, true)
	_say(soldier, "Et toi, tu es qui ?", 2.2, 1.0)
	await _until(25.6)
	_say(vipere, "Vipère. La meilleure pilote du secteur.", 2.8, -1.0)
	await _until(28.8)
	_say(captain, "La deuxième meilleure !", 2.0, 1.0)
	await _until(31.0)

	# 31 s: her squad jumps down from the ship.
	var brutus := _hero("viking", STAGE + Vector3(-0.6, 5.0, -4.8), PI)
	var hex := _hero("witch", STAGE + Vector3(0.6, 5.0, -5.6), PI)
	var colt := _hero("cowboy", STAGE + Vector3(2.8, 5.0, -4.8), PI)
	for index in 3:
		var landing: Node3D = [brutus, hex, colt][index].get_parent()
		get_tree().create_timer(0.25 * index).timeout.connect(_drop.bind(landing, STAGE.y, 0.4))
	_dolly(STAGE + Vector3(0, 0.5, 4.5), STAGE + Vector3(0, 0.7, 3.8), STAGE + Vector3(0.8, 2.5, -4.5),
			STAGE + Vector3(0.8, 1.6, -4.5), 4.0, true)
	await _until(32.4)
	_shake = 0.2
	await _until(33.4)
	_narrate("L'ESCOUADE ÉCARLATE", 2.6)
	await _until(35.8)
	_dolly(STAGE + Vector3(-1.2, 1.6, -1.5), STAGE + Vector3(-1.0, 1.6, -1.8), STAGE + Vector3(-0.6, 1.4, -4.8),
			STAGE + Vector3(-0.6, 1.5, -4.8), 3.0, true)
	_say(brutus, "Alors c'est eux ? Ils sont petits.", 2.4, 1.0)
	await _until(38.6)
	_dolly(STAGE + Vector3(1.0, 1.6, -2.6), STAGE + Vector3(0.9, 1.6, -2.9), STAGE + Vector3(0.6, 1.4, -5.6),
			STAGE + Vector3(0.6, 1.5, -5.6), 3.0, true)
	_say(hex, "Mes cartes disent qu'ils vont perdre.", 2.6, -1.0)
	await _until(41.6)

	# 41.6 s: the challenge.
	_dolly(STAGE + Vector3(-3.5, 1.0, 3.5), STAGE + Vector3(-3, 1.1, 3), STAGE + Vector3(0.5, 1.6, -2),
			STAGE + Vector3(0.8, 1.7, -2.6), 7.0, true)
	_say(vipere, "Une course de vaisseaux. Demain.", 2.6, 1.0)
	await _until(44.6)
	_say(soldier, "Et on gagne quoi ?", 2.0, -1.0)
	await _until(46.8)
	_say(vipere, "Si je gagne, la station est à nous.", 2.8, 1.0)
	await _until(49.8)
	_say(kunoichi, "Et si on gagne ?", 2.0, -1.0)
	await _until(52.0)
	_say(colt, "Ça n'arrivera pas, petite.", 2.4, 1.0)
	await _until(54.8)

	# 54.8 s: the stare-down.
	_dolly(STAGE + Vector3(-1.5, 1.55, -0.6), STAGE + Vector3(-1.5, 1.55, -0.2), STAGE + Vector3(1.6, 1.5, -3.2),
			STAGE + Vector3(1.6, 1.5, -3.2), 2.4, false)
	_speed(2.4)
	await _until(57.2)
	_dolly(STAGE + Vector3(1.6, 1.55, -1.4), STAGE + Vector3(1.6, 1.55, -1.8), STAGE + Vector3(-1.5, 1.5, 1),
			STAGE + Vector3(-1.5, 1.5, 1), 2.4, false)
	_speed(2.4)
	await _until(59.6)
	_impact_frame()
	_say(soldier, "On accepte !", 2.0, 1.0)
	await _until(62.0)
	_say(vipere, "À l'aube. Ne sois pas en retard.", 2.6, -1.0)
	await _until(65.0)

	# 65 s: the Écarlate leave.
	_dolly(STAGE + Vector3(0, 2.0, 8), STAGE + Vector3(0, 3.5, 6), STAGE + Vector3(0, 2, -4),
			STAGE + Vector3(0, 9, -10), 6.0, true)
	for leaving: CharacterModel in [vipere, brutus, hex, colt]:
		leaving.get_parent().queue_free()
	Effects.burst(_set, red.global_position + Vector3.UP, RED, 40)
	_fly_to(red, red.global_position, STAGE + Vector3(30, 30, -60), 3.5)
	_speed(1.5)
	await _until(71.0)

	# 71 s: the squad, alone.
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.get_parent().rotation.y = PI
		hero.play(&"idle")
	_dolly(STAGE + Vector3(-2, 1.4, 6.5), STAGE + Vector3(-1, 1.5, 5.5), STAGE + Vector3(0, 1.3, 1),
			STAGE + Vector3(0, 1.3, 1), 10.0, true)
	_say(kunoichi, "Tu ne sais même pas piloter.", 2.4, -1.0)
	await _until(74.0)
	_say(soldier, "J'apprendrai vite.", 2.0, -1.0)
	await _until(76.4)
	_say(ronin, "Il a une nuit.", 2.0, 1.0)
	await _until(78.8)
	_say(captain, "Une nuit avec moi, moussaillon !", 2.6, 1.0)
	await _until(81.8)

	# 81.8 s: training, in the station's hangar.
	_wipe()
	_load_arena(0)
	soldier = _hero("soldier", STAGE + Vector3(-1.2, 0, 1), PI * 0.8)
	captain = _hero("captain", STAGE + Vector3(1.2, 0, 1), -PI * 0.8)
	var cyan := _parked_ship(CYAN, STAGE + Vector3(0, 0.8, -2.5), 0.0)
	cyan.scale = Vector3.ONE * 1.6
	_dolly(STAGE + Vector3(4, 2.2, 6), STAGE + Vector3(3, 2.0, 5), STAGE + Vector3(0, 0.9, -1),
			STAGE + Vector3(0, 0.9, -1), 8.0, true)
	_narrate("La nuit, dans le hangar de la station.", 3.0)
	await _until(84.0)
	_say(captain, "Le boost, c'est la touche bleue !", 2.6, 1.0)
	await _until(87.0)
	_say(soldier, "Elles sont toutes bleues !", 2.4, -1.0)
	await _until(89.8)
	_say(captain, "...On a du travail.", 2.2, 1.0)
	await _until(92.4)

	# 92.4 s: the ship's engines light up.
	_dolly(STAGE + Vector3(0, 1.0, 2.0), STAGE + Vector3(0, 1.2, 1.2), STAGE + Vector3(0, 0.9, -2.5),
			STAGE + Vector3(0, 0.9, -2.5), 4.0, true)
	cyan.boost(6.0)
	Effects.flash(_set, cyan.global_position, CYAN, 12.0, 0.6)
	_speed(3.0)
	await _until(95.0)
	_fly_to(cyan, cyan.global_position, STAGE + Vector3(0, 1.5, -40), 2.0)
	_impact_frame()
	await _until(97.0)
	_say(soldier, "WOOOAAH !", 1.8, -1.0)
	await _until(99.4)

	# 99.4 s: dawn is coming.
	_load_arena(4)
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 8, 6), STAGE + Vector3(0, 6, -10),
			STAGE + Vector3(0, 14, -30), 9.0, true)
	_narrate("Demain, à l'aube : la course.", 4.0)
	await _to_be_continued(108.0)
