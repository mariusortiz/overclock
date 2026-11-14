extends Season4Episode
## Épisode 33 : Les Doubles. The doubles of the whole squad sabotage the
## desert's temple; a fight, hero against double, nobody can tell them apart.
## The doubles break like glass and leave a shard behind: a way through.


func _init() -> void:
	episode_number = 33
	episode_title = "LES DOUBLES"
	duration = 54.0


func _story() -> void:
	_load_arena(1)
	var doubles := {}
	for index in SQUAD.size():
		var id: String = SQUAD[index]
		doubles[id] = _double(id, STAGE + Vector3(-6.0 + 2.0 * index, 0, -6), PI, AnimeDirector.GUNS.get(id, "heavy"))
	_shards(STAGE + Vector3(0, 7, -12), 6, 8.0)
	_dolly(STAGE + Vector3(0, 6, 8), STAGE + Vector3(0, 2.4, 4), STAGE + Vector3(0, 1, -6), STAGE + Vector3(0, 1.4, -6), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Le désert. Le temple tremble.", 2.6)
	await _until(4.2)
	_say(doubles.captain, "Coupez tout. Qu'ils ne trouvent rien.", 2.2, 1.0)
	await _until(6.8)
	await _title_card(5.0)

	# 11.8 s: the squad arrives.
	var heroes := _squad(STAGE + Vector3(0, 0, 2), 0.0, SQUAD, 1.5, true)
	_dolly(STAGE + Vector3(7, 1.8, -2), STAGE + Vector3(7, 1.8, -3), STAGE + Vector3(0, 1.2, -2), STAGE + Vector3(0, 1.2, -2), 8.0)
	await _until(12.6)
	_say(heroes.paladin, "Ils ont nos têtes. Et nos armes.", 2.2, -1.0)
	await _until(15.2)
	_say(heroes.cowgirl, "Mais pas nos chapeaux. Ah si.", 2.0, -1.0)
	await _until(17.6)

	# 17.6 s: the fight.
	_speed(4.0)
	_dolly(STAGE + Vector3(-4, 2.6, 4), STAGE + Vector3(4, 2.6, 4), STAGE + Vector3(0, 1.2, -2), STAGE + Vector3(0, 1.2, -2), 6.0)
	for index in SQUAD.size():
		var id: String = SQUAD[index]
		var hero: CharacterModel = heroes[id]
		var double: CharacterModel = doubles[id]
		get_tree().create_timer(0.4 * index).timeout.connect(func() -> void:
			hero.play(&"shoot", true)
			double.play(&"shoot", true)
			_beam(hero.global_position + Vector3.UP * 1.3, double.global_position + Vector3.UP * 1.3, GOLD, 0.06)
			_beam(double.global_position + Vector3.UP * 1.3, hero.global_position + Vector3.UP * 1.3, MIRROR, 0.06))
	await _until(20.6)
	_narrate("Qui tire sur qui ? Personne ne sait plus.", 2.8, true)
	await _until(23.8)
	_dolly(STAGE + Vector3(-2, 1.7, -3.0), STAGE + Vector3(-1.6, 1.7, -3.4), STAGE + Vector3(0, 1.4, -6), STAGE + Vector3(0, 1.4, -6), 6.0)
	_say(doubles.soldier, "Vous allez perdre contre vous-mêmes.", 2.4, 1.0)
	await _until(26.6)
	_dolly(STAGE + Vector3(1.6, 1.7, -0.6), STAGE + Vector3(1.3, 1.7, -0.9), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 3.0)
	_say(heroes.soldier, "Pas si on vise mieux que nous.", 2.2, -1.0)
	await _until(29.2)

	# 29.2 s: the doubles break.
	_impact_frame()
	for index in SQUAD.size():
		var id: String = SQUAD[index]
		get_tree().create_timer(0.25 * index).timeout.connect(_break.bind(doubles[id]))
	_shake = 0.3
	_dolly(STAGE + Vector3(0, 3, 4), STAGE + Vector3(0, 2.6, 2), STAGE + Vector3(0, 1, -6), STAGE + Vector3(0, 0.6, -6), 4.0)
	await _until(31.4)
	_narrate("Ils se brisent comme du verre.", 2.4)
	await _until(34.2)
	var shard := _mirror(STAGE + Vector3(0, 0, -6), 0.0, 2.4)
	_dolly(STAGE + Vector3(0.8, 1.7, -1.0), STAGE + Vector3(0.6, 1.7, -1.3), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 5.4)
	_say(heroes.kunoichi, "Il en reste un éclat. Il est tiède.", 2.4, -1.0)
	await _until(37.0)
	_say(heroes.sand_ghost, "Et derrière... il y a une rue.", 2.2, 1.0)
	await _until(39.6)
	_dolly(STAGE + Vector3(0.8, 1.6, -2.6), STAGE + Vector3(0.6, 1.6, -3.4), STAGE + Vector3(0, 1.2, -6), STAGE + Vector3(0, 1.2, -6), 4.0)
	_narrate("Dans l'éclat, une ville. La leur. À l'envers.", 3.0, true)
	await _until(43.0)
	_overlay(shard, Color(MIRROR, 0.4))
	await _to_be_continued(43.6)
