extends Season2Episode
## Épisode 20 : Redémarrage. The last battle over the city: the fleet, every
## hero's ultimate, then Le Créateur's root access with the three fragments.
## The Virus is deleted, the world reboots. Le Créateur says goodbye. End of
## season 2.


func _init() -> void:
	episode_number = 20
	episode_title = "REDÉMARRAGE"
	duration = 120.0


func _story() -> void:
	_load_arena(4)
	var virus := _virus_titan(STAGE + Vector3(0, 0, -18), TITAN_HEIGHT * 1.8)
	virus.play(&"walk")
	_dolly(STAGE + Vector3(-4, 0.6, 9), STAGE + Vector3(-2.5, 1.2, 7), STAGE + Vector3(0, 4, -18), STAGE + Vector3(0, TITAN_HEIGHT * 1.6, -18), 8.0)
	_fade_shade(0.0, 1.2)
	_glitch(1.0)
	await _until(1.5)
	_narrate("La ville. Le Virus avance. Tout ce qu'il touche disparaît.", 3.4)
	await _until(5.4)
	_stomp(STAGE + Vector3(0, 0, -18), 1.6)
	_impact_frame()
	await _until(8.0)
	await _title_card(5.0)

	# 13 s: the fleet attacks.
	var ships: Array[RaceShip] = []
	var ship_ids := ["ship_mainframe", "ship_dart", "ship_falcon", "ship_hornet", "ship_nova"]
	for index in ship_ids.size():
		var ship := RaceShip.new()
		ship.configure(Loadout.find(ship_ids[index]).item)
		_set.add_child(ship)
		ship.scale = Vector3.ONE * 1.6
		_toon(ship)
		_fly_to(ship, STAGE + Vector3(-40 + index * 4, 22 + index, 20), STAGE + Vector3(-10 + index * 5, 18 + index, -6), 3.0)
		ships.append(ship)
	_dolly(STAGE + Vector3(0, 6, 12), STAGE + Vector3(0, 9, 9), STAGE + Vector3(-10, 18, 6), STAGE + Vector3(0, 16, -8), 3.2)
	await _until(16.4)
	for round in 2:
		for ship in ships:
			_beam(ship.global_position, virus.global_position + Vector3(randf_range(-3, 3), TITAN_HEIGHT * 1.4, 0), ship.color, 0.14)
			await _until(_clock + 0.2)
		_glitch(0.4)
	_narrate("Les tirs le font grésiller. Pas tomber.", 2.8)
	await _until(22.4)

	# 22.4 s: on the ground, all the heroes.
	var ids := ["paladin", "ronin", "kunoichi", "soldier", "sand_ghost", "captain", "godfather", "cowgirl"]
	var heroes := {}
	for index in ids.size():
		heroes[ids[index]] = _hero(ids[index], STAGE + Vector3(-5.6 + 1.6 * index, 0, 3.0 - absf(index - 3.5) * 0.3), 0.0)
	_dolly(STAGE + Vector3(0, 1.0, -4), STAGE + Vector3(0, 1.4, -2), STAGE + Vector3(0, 1.4, 3), STAGE + Vector3(0, 1.6, 3), 6.0, true)
	await _until(23.4)
	_say(heroes.soldier, "Toutes les ultis. Maintenant !", 2.4, -1.0)
	await _until(26.2)

	# 26.2 s: each ultimate, one after the other.
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 4, 9), STAGE + Vector3(0, 8, -18), STAGE + Vector3(0, 10, -18), 12.0, true)
	var colors := [GOLD, Color(1.0, 0.85, 0.9), Color(1.0, 0.5, 0.8), CYAN, RED, Color(1.0, 0.6, 0.2), Color(0.9, 0.9, 1.0), GOLD]
	for index in ids.size():
		var hero: CharacterModel = heroes[ids[index]]
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3.UP * 1.3, virus.global_position + Vector3(randf_range(-2, 2), TITAN_HEIGHT * randf_range(0.6, 1.5), 0), colors[index], 0.16)
		_ring(virus.global_position + Vector3.UP * 4.0, colors[index], 6.0 + index, 0.4)
		_shake = 0.12
		await _until(_clock + 0.9)
	_glitch(1.0)
	_narrate("Le Virus vacille... mais il se recopie.", 3.0)
	await _until(37.6)
	virus.play(&"shoot", true)
	_stomp(STAGE + Vector3(0, 0, -10), 1.6)
	_ring(STAGE + Vector3(0, 0.2, -6), VIRUS, 24.0, 0.8)
	for hero in heroes.values():
		(hero as CharacterModel).play(&"die", true)
	_impact_frame()
	_shake = 0.35
	await _until(40.0)

	# 40 s: Le Créateur, with the three fragments.
	var creator := _creator(STAGE + Vector3(0, 0, 0.5), 0.0, "source_code")
	_appear(creator)
	_dolly(STAGE + Vector3(-3.0, 1.6, -2.5), STAGE + Vector3(-2.6, 1.6, -2.0), STAGE + Vector3(0, 1.6, 0.5), STAGE + Vector3(0, 1.6, 0.5), 5.0, true)
	await _until(41.6)
	for index in 3:
		var at := creator.global_position + Vector3(-1.2 + 1.2 * index, 2.6, 0)
		_ring(at, VIRUS, 1.2, 1.4)
		Effects.burst(_set, at, VIRUS, 20)
	_say(creator, "Trois fragments. Une clé entière. Une dernière fois.", 3.0, -1.0)
	await _until(45.0)
	_say(heroes.sand_ghost, "Vas-y, la vache !", 1.8, 1.0)
	await _until(47.2)

	# 47.2 s: root access.
	creator.play(&"shoot", true)
	_narrate("ACCÈS ROOT", 2.0, true)
	_dolly(STAGE + Vector3(0, 2, 9), STAGE + Vector3(0, 5, 7), STAGE + Vector3(0, 6, -18), STAGE + Vector3(0, TITAN_HEIGHT * 1.4, -18), 6.0)
	await _until(48.0)
	for index in 4:
		_beam(creator.global_position + Vector3.UP * 1.4, virus.global_position + Vector3(0, TITAN_HEIGHT * (0.5 + 0.3 * index), 0), VIRUS, 0.4)
		_ring(virus.global_position + Vector3.UP * (4.0 + 3.0 * index), VIRUS, 14.0 + 4.0 * index, 0.6)
		_impact_frame()
		_shake = 0.3
		await _until(_clock + 0.6)
	_speed(2.0)
	_glitch(2.4)
	await _until(51.0)
	_vanish(virus, 2.0)
	_narrate("VIRUS : SUPPRIMÉ.", 2.6, true)
	await _until(54.4)

	# 54.4 s: reboot.
	_shade.color = Color(1, 1, 1, 0)
	_fade_shade(1.0, 0.6)
	await _until(55.2)
	_narrate("REDÉMARRAGE...", 2.4, true)
	await _until(58.0)
	_shade.color = Color(1, 1, 1, 1)
	for hero in heroes.values():
		(hero as CharacterModel).play(&"victory", true)
	_fade_shade(0.0, 1.4)
	_dolly(STAGE + Vector3(0, 1.4, 9), STAGE + Vector3(0, 1.6, 7.5), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 8.0, true)
	await _until(60.0)
	_narrate("Le soleil sur la ville. Plus un glitch.", 3.0)
	await _until(63.4)

	# 63.4 s: goodbye.
	for hero in heroes.values():
		_face(hero, creator)
		(hero as CharacterModel).play(&"idle")
	_face(creator, heroes.soldier)
	_dolly(STAGE + Vector3(3.0, 1.8, -2.2), STAGE + Vector3(2.6, 1.8, -1.8), STAGE + Vector3(0, 1.5, 1.4), STAGE + Vector3(0, 1.5, 1.4), 14.0, true)
	_say(creator, "Mon monde est entre de bonnes mains.", 2.6, -1.0)
	await _until(66.6)
	_say(heroes.soldier, "Tu pars ?", 1.6, 1.0)
	await _until(68.6)
	_say(creator, "J'ai d'autres lignes à écrire. Des meilleures, j'espère.", 3.0, -1.0)
	await _until(72.2)
	_say(heroes.sand_ghost, "Écris-moi une revanche, alors.", 2.4, 1.0)
	await _until(75.0)
	_say(creator, "Promis.", 1.6, -1.0)
	await _until(77.0)
	_vanish(creator, 1.2)
	await _until(78.6)
	_say(heroes.soldier, "Hé, la vache !... Merci.", 2.4, 1.0)
	await _until(81.6)
	_dolly(STAGE + Vector3(-6, 6, 12), STAGE + Vector3(-3, 3, 8), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 2, -4), 8.0, true)
	_narrate("Quelque part, sur un toit, une tête de vache sourit.", 3.4)
	await _until(86.0)
	_fade_shade(0.85, 0.6)
	_narrate("FIN DE LA SAISON 2", 3.4, true)
	await _until(90.0)
	_fade_shade(1.0, 0.6)
	await _until(91.0)
	_end_card()
