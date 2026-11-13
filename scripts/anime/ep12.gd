extends Season2Episode
## Épisode 12 : Le message. At the station, the screens fill with code and
## corrupted guards corner the Kunoichi. Le Créateur deletes them with a
## gesture, leaves a message, and vanishes.


func _init() -> void:
	episode_number = 12
	episode_title = "LE MESSAGE"
	duration = 97.6


func _story() -> void:
	_load_arena(0)
	var kunoichi := _hero("kunoichi", STAGE, 0.0, "none")
	kunoichi.play(&"walk", true)
	_move(kunoichi.get_parent() as Node3D, Vector3(0, 0, -0.5))
	_dolly(STAGE + Vector3(-3, 1.4, -6), STAGE + Vector3(-2, 1.5, -5), STAGE + Vector3(0, 1.3, 0), STAGE + Vector3(0, 1.3, -2), 7.0, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La station, la nuit. La Kunoichi fait sa ronde.", 3.0)
	await _until(5.0)
	_glitch(0.8)
	_narrate("Sur tous les écrans, du code vert défile.", 3.0)
	await _until(8.6)
	_movers.clear()
	kunoichi.play(&"idle")
	await _title_card(5.0)

	# 13.6 s: the message on the screens.
	_dolly(STAGE + Vector3(1.4, 1.6, -3.2), STAGE + Vector3(1.0, 1.6, -3.6), STAGE + Vector3(0, 1.5, -2.5), STAGE + Vector3(0, 1.5, -2.5), 6.0, true)
	_say(kunoichi, "Des lettres, au milieu du code...", 2.4, 1.0)
	await _until(16.4)
	_narrate("« LE VIRUS ARRIVE. CHERCHEZ LA SOURCE. — C. »", 3.6, true)
	await _until(20.4)
	_say(kunoichi, "C ? Qui signe avec une lettre ?", 2.4, 1.0)
	await _until(23.2)

	# 23.2 s: they come out of the walls.
	_glitch(1.2)
	var guards: Array[Enemy] = []
	for index in 7:
		var angle := PI * 0.15 + PI * 0.7 * index / 6.0
		var at := STAGE + Vector3(cos(angle) * 7.0, 0, -2.0 - sin(angle) * 7.0)
		var guard := _corrupted(at, 0.0, &"aim")
		_face(guard, kunoichi)
		_appear(guard, 0.5)
		guards.append(guard)
	_face(kunoichi, guards[3])
	kunoichi.play(&"aim")
	_dolly(STAGE + Vector3(0, 6, 6), STAGE + Vector3(0, 7, 4), STAGE + Vector3(0, 0.5, -4), STAGE + Vector3(0, 0.5, -5), 4.0, true)
	await _until(25.4)
	_say(kunoichi, "Sept. Ça va.", 1.8, 1.0)
	await _until(27.4)
	for index in 3:
		_slash(guards[index], &"petals", Color(1.0, 0.5, 0.8))
		_impact_frame()
		await _until(_clock + 0.6)
	_speed(1.0)
	await _until(30.0)
	# They come back.
	for index in 3:
		var again := _corrupted(guards[3 + index].global_position + Vector3(1.5, 0, 0), 0.0, &"aim")
		_face(again, kunoichi)
		_appear(again, 0.4)
		guards.append(again)
	_dolly(STAGE + Vector3(2.2, 1.4, 2.2), STAGE + Vector3(1.8, 1.4, 1.8), STAGE + Vector3(0, 1.4, 0), STAGE + Vector3(0, 1.4, 0), 4.0, true)
	await _until(31.0)
	_say(kunoichi, "Ils se relèvent... ils se recopient !", 2.4, 1.0)
	await _until(33.8)
	kunoichi.play(&"die", true)
	_shake = 0.2
	_impact_frame()
	_narrate("Trop nombreux. Trop vite.", 2.4)
	await _until(37.0)

	# 37 s: he arrives.
	var creator := _creator(STAGE + Vector3(-1.6, 0, 1.6), PI * 0.75, "source_code")
	_appear(creator)
	_dolly(STAGE + Vector3(-4, 1.0, 4.5), STAGE + Vector3(-3.4, 1.2, 4.0), STAGE + Vector3(-1.6, 1.6, 1.6), STAGE + Vector3(-1.6, 1.6, 1.6), 4.0, true)
	await _until(38.4)
	_say(creator, "Pas encore.", 1.8, -1.0)
	await _until(40.4)
	creator.play(&"shoot", true)
	_ring(STAGE + Vector3(0, 0.2, -2), VIRUS, 18.0, 0.7)
	_impact_frame()
	for guard in guards:
		if is_instance_valid(guard):
			_kill(guard, &"pixelate", VIRUS)
	_glitch(0.6)
	_dolly(STAGE + Vector3(0, 6, 7), STAGE + Vector3(0, 6.5, 6), STAGE + Vector3(0, 0.5, -3), STAGE + Vector3(0, 0.5, -3), 4.0, true)
	await _until(42.6)
	_narrate("D'un seul geste, tous effacés.", 2.6)
	await _until(46.0)

	# 46 s: face to face.
	kunoichi.play(&"idle")
	_face(kunoichi, creator)
	_face(creator, kunoichi)
	_dolly(STAGE + Vector3(1.6, 1.6, 2.6), STAGE + Vector3(1.2, 1.6, 2.4), STAGE + Vector3(-0.8, 1.5, 0.8), STAGE + Vector3(-0.8, 1.5, 0.8), 10.0, true)
	_say(kunoichi, "C'est toi, « C » ?", 2.0, 1.0)
	await _until(48.6)
	_say(creator, "Le virus a besoin de temps pour grandir. Vous aussi.", 3.0, -1.0)
	await _until(52.2)
	_say(kunoichi, "Qui es-tu ?", 1.6, 1.0)
	await _until(54.2)
	_say(creator, "Quelqu'un qui a fait une erreur. Une seule ligne de trop.", 3.2, -1.0)
	await _until(58.0)
	_say(kunoichi, "... Une tête de vache, sérieusement ?", 2.4, 1.0)
	await _until(61.0)
	_say(creator, "Chacun ses choix de design.", 2.2, -1.0)
	await _until(63.6)
	_vanish(creator)
	await _until(64.6)
	_say(kunoichi, "Hé ! Reviens !", 1.6, 1.0)
	await _until(66.6)

	# 66.6 s: the squad, told.
	_wipe()
	_load_showroom()
	var squad := {}
	for index in 5:
		var id: String = ["captain", "kunoichi", "soldier", "sand_ghost", "ronin"][index]
		squad[id] = _hero(id, Vector3(-3.2 + 1.6 * index, 0, 0), 0.0, "none")
	_dolly(Vector3(0, 1.6, -6.5), Vector3(0, 1.5, -5.2), Vector3(0, 1.2, 0), Vector3(0, 1.2, 0), 8.0)
	await _until(67.4)
	_say(squad.kunoichi, "Il efface les ennemis d'un geste. Il connaît le virus.", 3.0, 1.0)
	await _until(71.0)
	_say(squad.captain, "Et il signe « C ».", 2.0, -1.0)
	await _until(73.4)
	_say(squad.sand_ghost, "C comme... Cow ?", 2.0, 1.0)
	await _until(75.8)
	_say(squad.ronin, "« Cherchez la source. » Il nous donne une piste.", 2.8, -1.0)
	await _until(79.0)
	_say(squad.soldier, "Alors on la suit. Dès demain, la course de la ceinture.", 3.0, 1.0)
	await _until(82.6)
	_glitch(0.6)
	await _until(83.4)
	_narrate("Quelque part, le Virus grandit.", 3.0, true)
	await _until(87.0)
	await _to_be_continued(87.6)
