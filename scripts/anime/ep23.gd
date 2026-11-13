extends Season3Episode
## Épisode 23 : Le Chant des cristaux. The sentinels attack, and more come at
## every wrong note. Ronin hears the melody; the squad plays it back with their
## guns, crystal after crystal. The sentinels shatter, and a map of the stars
## lights up over the mesa: it points to ruins.


func _init() -> void:
	episode_number = 23
	episode_title = "LE CHANT DES CRISTAUX"
	duration = 81.0


## The four crystals of the melody, in its order.
const MELODY: Array[Vector3] = [Vector3(-8, 0.1, 8), Vector3(9, 0.1, 7), Vector3(-6, 0.1, -12), Vector3(7, 0.1, -12)]


func _story() -> void:
	_load_world("crystal")
	_moons()
	var heroes := _squad(STAGE + Vector3(0, 0, 1), 0.0, SQUAD, 1.4, true)
	var creator := _creator(STAGE + Vector3(0, 0, 3.2), 0.0)
	var sentinels: Array[Enemy] = []
	for index in 6:
		var at := STAGE + Vector3(-7.5 + 3.0 * index, 0, -8 - absf(index - 2.5) * 0.8)
		sentinels.append(_crystal_creature(at, PI, &"aim"))
	_dolly(STAGE + Vector3(0, 2.6, 9), STAGE + Vector3(0, 2.2, 7.5), STAGE + Vector3(0, 1.2, -6), STAGE + Vector3(0, 1.2, -6), 7.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Les sentinelles de cristal encerclent l'escouade.", 3.0)
	await _until(5.0)
	_say(heroes.soldier, "Feu à volonté !", 1.8, -1.0)
	await _until(7.2)
	await _title_card(5.0)

	# 12.2 s: they fire; it does not help.
	_dolly(STAGE + Vector3(-4, 1.4, 4), STAGE + Vector3(-3, 1.6, 3.4), STAGE + Vector3(0, 1.2, -7), STAGE + Vector3(2, 1.2, -7), 6.0)
	var shooters := ["soldier", "sand_ghost", "cowgirl", "captain"]
	for index in 4:
		_shoot(heroes[shooters[index]], sentinels[index], &"shatter", CRYSTAL)
		_note(sentinels[index].global_position, CRYSTAL_PINK)
		await _until(_clock + 0.5)
	await _until(15.0)
	_glitch(0.3)
	_narrate("À chaque tir, une fausse note. Et ils reviennent.", 3.0)
	for index in 4:
		var at := STAGE + Vector3(-9 + 6.0 * index, 0, -11)
		var sentinel := _crystal_creature(at, PI, &"aim")
		_rise(sentinel, 2.2, 1.0)
		sentinels.append(sentinel)
	await _until(18.4)
	_say(heroes.kunoichi, "Il y en a deux fois plus !", 2.0, 1.0)
	await _until(20.8)
	_dolly(STAGE + Vector3(1.4, 1.6, 6), STAGE + Vector3(1.0, 1.6, 5.6), STAGE + Vector3(0, 1.5, 3.2), STAGE + Vector3(0, 1.5, 3.2), 6.0)
	_say(creator, "Arrêtez ! Vous jouez faux, ils attaquent !", 2.8, -1.0)
	await _until(24.0)
	_say(heroes.paladin, "On joue quoi, alors ?", 1.8, 1.0)
	await _until(26.2)

	# 26.2 s: Ronin listens.
	_dolly(STAGE + Vector3(1.8, 1.7, -1.2), STAGE + Vector3(1.4, 1.7, -1.6), STAGE + Vector3(0.7, 1.6, 1), STAGE + Vector3(0.7, 1.6, 1), 10.0)
	heroes.ronin.play(&"idle")
	_narrate("Ronin ferme les yeux. Il écoute.", 2.6)
	await _until(29.0)
	for index in MELODY.size():
		_note(MELODY[index], CRYSTAL if index % 2 == 0 else CRYSTAL_PINK)
		await _until(_clock + 0.7)
	await _until(32.0)
	_say(heroes.ronin, "Bleu, rose... bleu, rose. De gauche à droite, puis au fond.", 3.4, 1.0)
	await _until(35.8)
	_say(heroes.soldier, "Quatre cristaux, quatre tireurs. En rythme !", 2.8, -1.0)
	await _until(39.0)

	# 39 s: the melody, played with guns.
	for index in MELODY.size():
		var hero: CharacterModel = heroes[shooters[index]]
		var target: Vector3 = MELODY[index]
		hero.get_parent().look_at(Vector3(target.x, STAGE.y, target.z))
		_dolly(hero.global_position + Vector3(0.6, 1.7, 2.4), hero.global_position + Vector3(0.4, 1.7, 2.0),
				target + Vector3.UP * 1.2, target + Vector3.UP * 1.2, 1.6)
		await _until(_clock + 0.5)
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3(0, 1.3, 0), target + Vector3.UP * 1.3, CRYSTAL, 0.06)
		_note(target, CRYSTAL if index % 2 == 0 else CRYSTAL_PINK)
		await _until(_clock + 1.4)
	await _until(47.6)

	# 47.6 s: the sentinels shatter, one after the other.
	_dolly(STAGE + Vector3(0, 4, 10), STAGE + Vector3(0, 5, 8), STAGE + Vector3(0, 1, -7), STAGE + Vector3(0, 1, -8), 5.0)
	_impact_frame()
	for sentinel in sentinels:
		if is_instance_valid(sentinel) and not sentinel._dead:
			_kill(sentinel, &"shatter", CRYSTAL)
			await _until(_clock + 0.15)
	await _until(50.6)
	_narrate("Plus une fausse note. Plus une sentinelle.", 2.8)
	await _until(53.6)

	# 53.6 s: the map of the stars.
	var mesa := Vector3(0, 7.0, 3)
	_dolly(STAGE + Vector3(0, 2, 2), STAGE + Vector3(0, 3, 0), STAGE + Vector3(0, 3, -4), mesa, 4.0)
	for hero in heroes.values():
		(hero as CharacterModel).get_parent().look_at(Vector3(mesa.x, STAGE.y, mesa.z))
	_ring(Vector3(0, 3.6, -2), CRYSTAL, 10.0, 1.2)
	var map := _star_map(mesa, 7.0)
	await _until(56.0)
	_narrate("Au-dessus de la mesa, une carte des étoiles.", 3.0)
	await _until(59.4)
	_dolly(STAGE + Vector3(0.8, 1.7, 2.0), STAGE + Vector3(0.6, 1.7, 2.1), STAGE + Vector3(0, 1.55, 3.2), STAGE + Vector3(0, 1.55, 3.2), 8.0)
	_face(creator, map)
	_say(creator, "Une carte. Et un point qui clignote.", 2.6, 1.0)
	await _until(62.4)
	_say(heroes.captain, "Pas loin. Une ceinture d'astéroïdes à traverser.", 2.8, -1.0)
	await _until(65.6)
	_say(heroes.kunoichi, "Et là-bas, c'est quoi ? Une ville ?", 2.4, 1.0)
	await _until(68.4)
	_say(creator, "Des ruines. Très vieilles.", 2.2, 1.0)
	await _until(71.0)
	await _to_be_continued(71.4)
