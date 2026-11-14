extends Season4Episode
## Épisode 32 : Le Reflet. Back at the station, a mirror nobody put there.
## The soldier's reflection does not move like him; it steps out of the glass,
## thanks him for opening the door, and runs off. Le Créateur: no glitch this
## time, that one had a shadow.


func _init() -> void:
	episode_number = 32
	episode_title = "LE REFLET"
	duration = 62.0


func _story() -> void:
	_load_arena(0)
	var heroes := _squad(STAGE + Vector3(0, 0, -1), PI)
	_dolly(STAGE + Vector3(-8, 4, 14), STAGE + Vector3(-3, 2.4, 8), STAGE + Vector3(0, 1, -1), STAGE + Vector3(0, 1.2, -1), 7.0)
	_fade_shade(0.0, 1.2)
	await _until(1.4)
	_narrate("De retour à la station. Enfin.", 2.6)
	await _until(4.2)
	_say(heroes.captain, "Tout le monde est rentré ?", 1.8, 1.0)
	await _until(6.2)
	_say(heroes.cowgirl, "Tout le monde. Même la vache.", 1.8, -1.0)
	await _until(8.2)
	await _title_card(5.0)

	# 13.2 s: the mirror.
	for id: String in heroes:
		if id != "soldier":
			_pivot_of(heroes[id]).visible = false
	var soldier: CharacterModel = heroes.soldier
	var pivot := _pivot_of(soldier)
	pivot.position = STAGE
	pivot.rotation.y = 0.0
	var mirror := _mirror(STAGE + Vector3(0, 0, -3.2), 0.0)
	_dolly(STAGE + Vector3(1.6, 1.8, 2.6), STAGE + Vector3(1.2, 1.7, 2.0), STAGE + Vector3(0, 1.4, -3.2), STAGE + Vector3(0, 1.5, -3.2), 6.0)
	await _until(14.0)
	_say(soldier, "Ce miroir n'était pas là hier.", 2.2, 1.0)
	await _until(16.6)
	var double := _double("soldier", STAGE + Vector3(0, 0, -3.6), PI)
	soldier.play(&"victory")
	await _until(17.4)
	_narrate("Son reflet ne bouge pas comme lui.", 2.6, true)
	await _until(20.4)
	_dolly(STAGE + Vector3(3.6, 1.7, -0.6), STAGE + Vector3(3.4, 1.7, -1.0), STAGE + Vector3(0, 1.4, -2.0), STAGE + Vector3(0, 1.4, -2.0), 8.0)
	soldier.play(&"idle")
	_say(double, "Enfin. Quelqu'un a ouvert la porte.", 2.4, -1.0)
	await _until(23.2)

	# 23.2 s: it steps out.
	_impact_frame()
	_shatter(mirror)
	_shake = 0.25
	_move(_pivot_of(double), Vector3(0, 0, 1.2))
	double.play(&"walk")
	await _until(24.6)
	_movers.clear()
	double.play(&"idle")
	_say(soldier, "Tu es... moi ?", 1.6, 1.0)
	await _until(26.6)
	_say(double, "Toi, en mieux. Merci pour le passage.", 2.4, -1.0)
	await _until(29.4)
	_vanish(double, 0.8)
	await _until(30.6)
	_dolly(STAGE + Vector3(-0.4, 1.7, 3.6), STAGE + Vector3(-0.3, 1.7, 3.0), STAGE + Vector3(0, 1.4, 0), STAGE + Vector3(0, 1.4, 0), 6.0)
	pivot.rotation.y = PI
	_narrate("Il ne reste que des éclats de verre.", 2.6)
	await _until(33.6)

	# 33.6 s: Le Créateur.
	var creator := _creator(STAGE + Vector3(1.6, 0, 0.6), PI)
	_appear(creator, 0.6)
	for id: String in heroes:
		if id != "soldier":
			_pivot_of(heroes[id]).visible = true
			_pivot_of(heroes[id]).position.z = STAGE.z - 2.0
	_dolly(STAGE + Vector3(1.4, 1.7, 5.4), STAGE + Vector3(1.0, 1.6, 4.6), STAGE + Vector3(0.8, 1.4, 0), STAGE + Vector3(0.8, 1.4, 0), 8.0)
	await _until(34.6)
	_say(heroes.soldier, "C'était un glitch, hein ? Dis-moi que c'était un glitch.", 2.8, -1.0)
	await _until(37.8)
	_say(creator, "Les glitchs n'ont pas d'ombre.", 2.2, 1.0)
	await _until(40.4)
	_say(creator, "Celui-là en avait une.", 2.0, 1.0)
	await _until(42.8)
	_say(heroes.kunoichi, "Alors d'où il vient ?", 1.8, -1.0)
	await _until(45.0)
	_say(creator, "D'un endroit où je n'ai jamais rien écrit.", 2.6, 1.0)
	await _until(48.0)
	_dolly(STAGE + Vector3(0, 6, 12), STAGE + Vector3(0, 9, 18), STAGE + Vector3(0, 1, -2), STAGE + Vector3(0, 6, -10), 6.0)
	_shards(STAGE + Vector3(0, 8, -10), 8, 10.0)
	_narrate("Dans le ciel de la station, des éclats de miroir.", 3.0, true)
	await _until(51.6)
	await _to_be_continued(52.0)
