extends Season3Episode
## Épisode 22 : Terre inconnue. The crystal planet. The ships are dead, and
## Le Créateur finds out he is only a cow here: no code to bend. The Cowgirl
## shoots a crystal by reflex; it sings, and the others answer. Then the
## sentinels rise.


func _init() -> void:
	episode_number = 22
	episode_title = "TERRE INCONNUE"
	duration = 74.0


func _story() -> void:
	_load_world("crystal")
	_moons()
	var wreck := _wreck(GOLD, STAGE + Vector3(-7, 0.4, -3), 0.6)
	_wreck(RED, STAGE + Vector3(8, 0.4, -6), -0.5)
	var heroes := _squad(STAGE + Vector3(1, 0, 1), PI, ["soldier", "kunoichi", "sand_ghost", "ronin", "paladin", "cowgirl"], 1.6)
	var captain := _hero("captain", STAGE + Vector3(-5.4, 0, -2), -PI / 2.0, "none")
	var creator := _creator(STAGE + Vector3(4, 0, -1.5), PI * 0.8)
	_dolly(STAGE + Vector3(10, 7, 12), STAGE + Vector3(6, 3, 9), STAGE + Vector3(0, 1, -2), STAGE + Vector3(0, 1.4, -2), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Une planète de cristal. Le silence.", 3.0)
	await _until(5.0)
	_say(heroes.cowgirl, "Joli. Un peu trop violet.", 2.2, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: the ships.
	_dolly(STAGE + Vector3(-2.8, 1.7, -0.6), STAGE + Vector3(-3.2, 1.7, -1.0), STAGE + Vector3(-5.4, 1.4, -2.0), STAGE + Vector3(-5.6, 1.3, -2.4), 9.0)
	await _until(13.0)
	_say(captain, "Moteurs morts. Plus une goutte d'énergie.", 2.8, 1.0)
	await _until(16.2)
	_say(heroes.paladin, "On attend le jour pour recharger ?", 2.4, -1.0)
	await _until(19.0)
	_say(captain, "Il n'y a pas de soleil. Juste ce ciel.", 2.6, 1.0)
	await _until(22.0)

	# 22 s: no code here.
	_dolly(STAGE + Vector3(1.8, 1.6, 3.4), STAGE + Vector3(2.4, 1.6, 2.8), STAGE + Vector3(4, 1.5, -1.5), STAGE + Vector3(4, 1.5, -1.5), 14.0)
	_face(heroes.soldier, creator)
	_say(heroes.soldier, "Fais ton truc. Le glitch. Ramène-nous.", 2.6, -1.0)
	await _until(25.0)
	_no_power(creator)
	await _until(26.6)
	_say(creator, "...", 1.2, 1.0)
	await _until(28.0)
	_no_power(creator)
	await _until(29.6)
	_say(creator, "Rien. Pas une ligne de code, ici.", 2.4, 1.0)
	await _until(32.4)
	_say(heroes.sand_ghost, "Donc... juste une vache.", 2.0, -1.0)
	await _until(34.8)
	_say(creator, "Merci, Vipère.", 1.6, 1.0)
	await _until(36.8)

	# 36.8 s: the crystal sings.
	var cluster := Vector3(9, 0.1, 7)
	_dolly(STAGE + Vector3(-1, 1.6, 4), STAGE + Vector3(0, 1.6, 3.4), STAGE + Vector3(5, 1.2, -4), STAGE + Vector3(7, 1.4, -6), 4.0)
	_face(heroes.cowgirl, heroes.soldier)
	heroes.cowgirl.get_parent().look_at(Vector3(cluster.x, STAGE.y, cluster.z))
	_say(heroes.cowgirl, "Qu'est-ce qui brille, là ?", 2.0, -1.0)
	await _until(39.4)
	heroes.cowgirl.play(&"shoot", true)
	_beam(heroes.cowgirl.global_position + Vector3(0, 1.3, 0), cluster + Vector3.UP * 1.4, GOLD, 0.06)
	_note(cluster, CRYSTAL)
	_dolly(cluster + Vector3(4, 2.4, 7), cluster + Vector3(3, 2.6, 6), cluster + Vector3(0, 1.2, 0), cluster + Vector3(0, 1.4, 0), 4.0)
	await _until(40.6)
	_narrate("Le cristal... chante.", 2.6)
	await _until(43.6)

	# 43.6 s: the others answer.
	_dolly(STAGE + Vector3(0, 12, 14), STAGE + Vector3(0, 16, 10), STAGE + Vector3(0, 0, -10), STAGE + Vector3(0, 0, -16), 9.0)
	var answers := [Vector3(-8, 0.1, 8), Vector3(-6, 0.1, -12), Vector3(7, 0.1, -12), Vector3(-20, 0.1, 13), Vector3(19, 0.1, 14)]
	for index in answers.size():
		_note(answers[index], CRYSTAL_PINK if index % 2 else CRYSTAL)
		await _until(_clock + 0.6)
	await _until(47.6)
	_say(heroes.ronin, "Ils se répondent.", 1.8, 1.0)
	await _until(50.0)
	_dolly(STAGE + Vector3(5, 1.6, 2.4), STAGE + Vector3(4.6, 1.6, 1.8), STAGE + Vector3(4, 1.5, -1.5), STAGE + Vector3(4, 1.5, -1.5), 6.0)
	_say(creator, "Une mélodie. Quelqu'un l'a écrite.", 2.4, 1.0)
	await _until(53.0)
	_say(creator, "Et je sais reconnaître du code quand j'en vois.", 2.8, 1.0)
	await _until(56.4)

	# 56.4 s: the sentinels rise.
	_shake = 0.3
	var sentinels: Array[Enemy] = []
	for index in 6:
		var angle := -PI * 0.15 - PI * 0.7 * index / 5.0
		var at := STAGE + Vector3(cos(angle) * 9.0, 0, -2 + sin(angle) * 7.0)
		var sentinel := _crystal_creature(at, 0.0, &"aim")
		(sentinel.get_parent() as Node3D).look_at(Vector3(STAGE.x, at.y, STAGE.z))
		_rise(sentinel, 2.2, 1.4)
		sentinels.append(sentinel)
	for id: String in heroes:
		(heroes[id] as CharacterModel).play(&"idle")
	_dolly(STAGE + Vector3(0, 2.0, 9), STAGE + Vector3(0, 2.6, 8), STAGE + Vector3(0, 1.2, -4), STAGE + Vector3(0, 1.2, -6), 6.0)
	_narrate("Le sol se fend. Quelque chose se lève.", 3.0)
	await _until(60.4)
	_say(heroes.soldier, "On a de la compagnie.", 2.0, -1.0)
	await _until(63.0)
	_impact_frame()
	await _to_be_continued(64.0)
