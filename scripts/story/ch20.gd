extends Season2Scene
## Chapitre 20 : Redémarrage. The last battle over the city: every hero, the
## three fragments, Le Créateur's root access.


func _init() -> void:
	episode_number = 20
	episode_title = "REDÉMARRAGE"
	duration = 32.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(4)
	_fade_shade(0.0, 0.6)
	var virus := _virus_titan(STAGE + Vector3(0, 0, -18), TITAN_HEIGHT * 1.6)
	virus.play(&"idle")
	var ids := ["paladin", "ronin", "kunoichi", "soldier", "sand_ghost", "captain", "cowgirl"]
	var heroes := {}
	for index in ids.size():
		heroes[ids[index]] = _hero(ids[index], STAGE + Vector3(-4.5 + 1.5 * index, 0, 3.0 - absf(index - 3) * 0.4), 0.0)
	var creator := _creator(STAGE + Vector3(6.0, 0, 1.6), 0.0, "source_code")
	_dolly(STAGE + Vector3(0, 1.2, -1.8), STAGE + Vector3(0, 1.5, -0.6), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.6, 3), 6.0, true)
	_narrate("La ville. Le Virus est devenu immense. Tout le monde est là.", 3.2)
	_glitch(0.6)
	await _until(6.4)
	_say(heroes.soldier, "Toutes les ultis. Maintenant !", 2.2, -1.0)
	await _until(8.8)
	_dolly(STAGE + Vector3(-6, 0.8, 6), STAGE + Vector3(-5, 0.6, 5), STAGE + Vector3(0, 3, -18),
			STAGE + Vector3(0, TITAN_HEIGHT * 1.4, -18), 3.6, true)
	for hero in heroes.values():
		(hero as CharacterModel).play(&"shoot", true)
		_beam((hero as Node3D).global_position + Vector3(0, 1.3, 0),
				virus.global_position + Vector3(randf_range(-2, 2), TITAN_HEIGHT * randf_range(0.5, 1.2), 0), CYAN, 0.06)
	_airstrike(STAGE + Vector3(0, 0, -18), 6, 5.0)
	_shake = 0.2
	await _until(12.6)
	_stomp(STAGE + Vector3(0, 0, -18), 1.6)
	_impact_frame()
	_glitch(1.0)
	await _until(14.0)
	_dolly(STAGE + Vector3(4.2, 1.6, -0.6), STAGE + Vector3(4.6, 1.7, -0.2), STAGE + Vector3(6.0, 1.7, 1.6),
			STAGE + Vector3(6.0, 1.8, 1.6), 5.0, true)
	_say(creator, "Les trois fragments. Accès root.", 2.6, 1.0)
	await _until(17.0)
	creator.play(&"shoot", true)
	_beam(creator.global_position + Vector3(0, 1.3, 0), virus.global_position + Vector3(0, TITAN_HEIGHT, 0), VIRUS, 0.2)
	_ring(STAGE + Vector3(0, 0.1, -18), VIRUS, 14.0, 1.6)
	_glitch(2.0)
	_speed(2.0)
	_shake = 0.3
	await _until(19.4)
	_dolly(STAGE + Vector3(0, 1.4, -1.4), STAGE + Vector3(0, 1.6, -0.4), STAGE + Vector3(0, 1.5, 3),
			STAGE + Vector3(0, 1.6, 3), 4.0, true)
	_say(heroes.kunoichi, "Il… redémarre ?", 2.0, 1.0)
	await _until(21.8)
	_narrate("MISSION FINALE : la ville, le Virus, tous les héros.", 4.0)
	await _until(26.4)
	_say(heroes.soldier, "OVERCLOCK !", 2.0, -1.0)
	await _until(30.6)
	_fade_shade(1.0, 1.0)
