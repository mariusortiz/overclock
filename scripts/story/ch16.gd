extends Season2Scene
## Chapitre 16 : Code source. In the jungle, the Ronin and the Kunoichi look
## for the first fragment; Le Créateur shows them his root access.


func _init() -> void:
	episode_number = 16
	episode_title = "CODE SOURCE"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(2)
	_fade_shade(0.0, 0.6)
	var ronin := _hero("ronin", STAGE + Vector3(-0.9, 0, 3.0), 0.0)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0.9, 0, 3.0), 0.0)
	_dolly(STAGE + Vector3(0, 1.6, -1.6), STAGE + Vector3(0, 1.6, -0.6), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 5.0, true)
	_narrate("La jungle. Le premier fragment est quelque part ici.", 3.0)
	await _until(6.2)
	_say(ronin, "Je sens quelque chose. Vert.", 2.2, -1.0)
	await _until(8.6)
	var goblins: Array[Enemy] = []
	for index in 5:
		goblins.append(_corrupted(STAGE + Vector3(-4.0 + 2.0 * index, 0, -2.5 - absf(index - 2) * 0.6), PI, &"walk"))
	_glitch(0.8)
	_dolly(STAGE + Vector3(2.6, 1.2, 5.6), STAGE + Vector3(2.0, 1.0, 4.8), STAGE + Vector3(0, 1.0, -3),
			STAGE + Vector3(0, 1.0, -2.5), 4.0, true)
	_narrate("Des monstres corrompus. Beaucoup.", 2.6)
	for hero in [ronin, kunoichi]:
		hero.play(&"aim")
	await _until(12.6)
	var creator := _creator(STAGE + Vector3(2.4, 0, 0.6), 0.0, "source_code")
	_appear(creator)
	await _until(13.4)
	_dolly(STAGE + Vector3(0.4, 1.5, -1.6), STAGE + Vector3(0.8, 1.6, -0.8), STAGE + Vector3(2.4, 1.5, 0.6),
			STAGE + Vector3(2.4, 1.5, 0.6), 4.0, true)
	_say(creator, "Accès root.", 1.8, 1.0)
	await _until(15.4)
	creator.play(&"shoot", true)
	_glitch(0.8)
	_impact_frame()
	for goblin in goblins:
		_beam(creator.global_position + Vector3(0, 1.3, 0), goblin.global_position + Vector3.UP, VIRUS, 0.08)
		_kill(goblin, &"pixelate", VIRUS)
	_ring(STAGE + Vector3(2.4, 0.1, 0.6), VIRUS, 8.0, 1.0)
	await _until(17.6)
	_dolly(STAGE + Vector3(0, 1.6, -1.6), STAGE + Vector3(0, 1.6, -0.8), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 5.0, true)
	_say(kunoichi, "… Tous. D'un coup.", 2.0, 1.0)
	await _until(20.0)
	_say(ronin, "Pourquoi nous, alors ?", 2.0, -1.0)
	await _until(22.2)
	_say(creator, "Parce que je ne pourrai pas le faire seul.", 2.4, 1.0)
	_vanish(creator, 1.2)
	await _until(24.0)
	_narrate("MISSION : trouve le fragment. La jungle est corrompue jusqu'au boss.", 3.8)
	await _until(27.6)
	_fade_shade(1.0, 1.0)
