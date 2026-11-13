extends StoryScene
## Chapitre 10 : Overclock. Every hero against the Titan Mk II.


func _init() -> void:
	episode_number = 10
	episode_title = "OVERCLOCK"
	duration = 32.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(4)
	_fade_shade(0.0, 0.6)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -12), TITAN_HEIGHT * 1.4, Color(1.0, 0.45, 0.4))
	_titan.play(&"idle")
	var ids := ["paladin", "ronin", "kunoichi", "soldier", "sand_ghost", "captain", "godfather"]
	var heroes := {}
	for index in ids.size():
		heroes[ids[index]] = _hero(ids[index], STAGE + Vector3(-4.5 + 1.5 * index, 0, 3.0 - absf(index - 3) * 0.4), PI)
	_dolly(STAGE + Vector3(0, 1.0, -4), STAGE + Vector3(0, 1.4, -2), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.6, 3), 6.0, true)
	_narrate("La dernière bataille. Tout le monde est là.", 3.0)
	await _until(6.4)
	_say(heroes.paladin, "Pour la ville !", 1.8, -1.0)
	await _until(8.4)
	_say(heroes.godfather, "Et pour mon argent.", 1.8, 1.0)
	await _until(10.6)
	_dolly(STAGE + Vector3(0, 1.4, 7), STAGE + Vector3(0, 1.6, 5.5), STAGE + Vector3(0, 1.5, 3),
			STAGE + Vector3(0, 4, -12), 5.0, true)
	_say(heroes.soldier, "Toutes les ultis. Une après l'autre.", 2.6, -1.0)
	await _until(13.6)
	_say(heroes.sand_ghost, "Et le dernier coup, ensemble.", 2.4, 1.0)
	await _until(16.4)
	for hero in heroes.values():
		(hero as CharacterModel).play(&"aim")
	_titan.play(&"walk")
	_dolly(STAGE + Vector3(-6, 0.8, 6), STAGE + Vector3(-5, 0.6, 5), STAGE + Vector3(0, 3, -12),
			STAGE + Vector3(0, TITAN_HEIGHT * 1.3, -12), 3.0, true)
	await _until(17.4)
	_stomp(STAGE + Vector3(0, 0, -12), 1.4)
	_impact_frame()
	await _until(19.0)
	_dolly(STAGE + Vector3(0, 1.5, 6), STAGE + Vector3(0, 1.5, 4.8), STAGE + Vector3(0, 1.5, 3),
			STAGE + Vector3(0, 1.5, 3), 3.0, true)
	_say(heroes.soldier, "OVERCLOCK !", 2.0, -1.0)
	_speed(2.0)
	_shake = 0.2
	await _until(21.6)
	_narrate("MISSION FINALE : la ville, le Titan Mk II, tous les héros.", 4.0)
	await _until(30.6)
	_fade_shade(1.0, 1.0)
