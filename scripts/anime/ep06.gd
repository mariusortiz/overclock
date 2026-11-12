extends AnimeDirector
## Épisode 6 : Duel dans la jungle. The Ronin finds Vipère in the jungle;
## they fight, evenly. The Directeur sends his royal slime and goblins after
## them both; they win back to back, and Vipère changes sides.


func _init() -> void:
	episode_number = 6
	episode_title = "DUEL DANS LA JUNGLE"
	duration = 120.0


func _story() -> void:
	# 0 s: the jungle, the Ronin sitting still.
	_load_arena(2)
	var ronin := _hero("ronin", STAGE + Vector3(0, 0, 0), PI, "none")
	ronin.freeze(&"die", 0.9)
	_dolly(STAGE + Vector3(0, 1.0, 6), STAGE + Vector3(0, 1.0, 4.5), STAGE + Vector3(0, 0.8, 0),
			STAGE + Vector3(0, 0.8, 0), 8.0, true)
	_fade_shade(0.0, 1.5)
	_narrate("La jungle. Le Ronin attend.", 3.0)
	await _until(4.0)
	_say(ronin, "Je sais que tu es là.", 2.2, 1.0, 1.2)
	await _until(6.6)
	var vipere := _hero("sand_ghost", STAGE + Vector3(4, 4.0, -5), -PI * 0.75)
	_drop(vipere.get_parent() as Node3D, STAGE.y, 0.5)
	await _until(8.2)

	await _title_card(5.0)

	# 13.2 s: face to face.
	ronin.play(&"idle")
	ronin.get_parent().position = STAGE + Vector3(-1.5, 0, 0)
	vipere.get_parent().position = STAGE + Vector3(1.5, 0, -1)
	_face(ronin, vipere)
	_face(vipere, ronin)
	_dolly(STAGE + Vector3(0, 1.5, 5), STAGE + Vector3(0.4, 1.5, 4.4), STAGE + Vector3(0, 1.4, -0.5),
			STAGE + Vector3(0, 1.4, -0.5), 8.0, true)
	await _until(14.0)
	_say(vipere, "Tu me suivais ?", 1.8, 1.0)
	await _until(16.2)
	_say(ronin, "Tu cherches le Directeur. Moi aussi.", 2.6, -1.0)
	await _until(19.2)
	_say(vipere, "Je travaille pour lui.", 2.0, 1.0)
	await _until(21.6)
	_say(ronin, "Alors tu dois choisir.", 2.0, -1.0)
	await _until(24.0)
	_say(vipere, "D'abord, je dois savoir ce que tu vaux.", 2.8, 1.0)
	_speed(2.0)
	await _until(27.2)

	# 27.2 s: the duel. Close shots, slashes, impact frames.
	_impact_frame()
	ronin.play(&"melee", true)
	vipere.play(&"melee", true)
	_dolly(STAGE + Vector3(-0.5, 1.6, 1.6), STAGE + Vector3(0.5, 1.5, 1.4), STAGE + Vector3(0, 1.4, -0.5),
			STAGE + Vector3(0, 1.4, -0.5), 1.6, false)
	_beam(STAGE + Vector3(-0.8, 2.0, -0.5), STAGE + Vector3(0.8, 0.8, -0.5), Color.WHITE, 0.05)
	_speed(1.6)
	await _until(28.8)
	_dolly(STAGE + Vector3(3.5, 0.5, -3), STAGE + Vector3(3.0, 0.7, -2.5), STAGE + Vector3(-1.5, 1.4, 0),
			STAGE + Vector3(-1.5, 1.4, 0), 1.6, false)
	vipere.play(&"shoot", true)
	for dart in 5:
		_beam(vipere.global_position + Vector3.UP * 1.3, ronin.global_position + Vector3(randf_range(-0.6, 0.6), 1.2 + randf() * 0.6, 0),
				Color(0.9, 0.85, 0.5), 0.04)
	await _until(29.6)
	ronin.play(&"melee", true)
	_ring(ronin.global_position, Color(1.0, 0.85, 0.9), 4.0, 0.3)
	_say(ronin, "Trop lent.", 1.2, -1.0)
	await _until(30.8)
	# They switch places in a blur.
	var ronin_at: Vector3 = ronin.get_parent().position
	ronin.get_parent().position = vipere.get_parent().position + Vector3(0, 0, 1.5)
	vipere.get_parent().position = ronin_at
	_face(ronin, vipere)
	_face(vipere, ronin)
	_impact_frame()
	_speed(1.2)
	_dolly(STAGE + Vector3(0, 4, 4), STAGE + Vector3(1, 4.5, 3.5), STAGE + Vector3(0, 0.8, -0.3),
			STAGE + Vector3(0, 0.8, -0.3), 2.0, true)
	await _until(32.8)
	for blow in 4:
		var striker: CharacterModel = ronin if blow % 2 == 0 else vipere
		striker.play(&"melee", true)
		if blow == 3:
			_impact_frame()
		else:
			_ring(striker.global_position, Color.WHITE, 3.0, 0.25)
		_shake = 0.12
		await _until(_clock + 0.5)
	_dolly(STAGE + Vector3(-2.2, 1.4, 2.6), STAGE + Vector3(-2.0, 1.4, 2.4), STAGE + Vector3(0, 1.4, -0.3),
			STAGE + Vector3(0, 1.4, -0.3), 5.0, true)
	_say(vipere, "Pas mal, samouraï.", 2.0, 1.0)
	await _until(37.6)
	_say(ronin, "Toi aussi. Égalité.", 2.0, -1.0)
	await _until(40.0)

	# 40 s: the ground shakes. A royal slime, and goblins.
	_shake = 0.3
	_impact_frame()
	var slime := _spawn_boss(Boss.Kind.SUMMONER, STAGE + Vector3(0, 0, -9), 2.6, 2.4)
	_rise(slime, 6.0, 2.0)
	var goblins: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0 + 0.3
		var spot := STAGE + Vector3(0, 0, -1) + Vector3(cos(angle) * 7.0, 0, sin(angle) * 6.0)
		var goblin := _enemy(spot, 0.0, &"walk")
		(goblin.get_parent() as Node3D).look_at(STAGE + Vector3(0, 0.1, -1))
		goblins.append(goblin)
	_dolly(STAGE + Vector3(0, 0.6, 5), STAGE + Vector3(0, 0.8, 4.5), STAGE + Vector3(0, 1.5, -9),
			STAGE + Vector3(0, 3, -9), 4.0, true)
	await _until(42.0)
	_stomp(STAGE + Vector3(0, 0, -9), 0.8)
	_say(vipere, "Ses monstres... il nous a suivis.", 2.6, -1.0)
	await _until(45.0)
	_say(ronin, "Il ne t'a jamais fait confiance.", 2.4, 1.0)
	await _until(47.8)

	# 47.8 s: back to back.
	ronin.get_parent().position = STAGE + Vector3(-0.6, 0, -1)
	vipere.get_parent().position = STAGE + Vector3(0.6, 0, -1)
	ronin.get_parent().rotation.y = PI / 2.0
	vipere.get_parent().rotation.y = -PI / 2.0
	_dolly(STAGE + Vector3(0, 1.3, 2.5), STAGE + Vector3(0, 1.4, 2.0), STAGE + Vector3(0, 1.3, -1),
			STAGE + Vector3(0, 1.3, -1), 4.0, true)
	_speed(4.0)
	_say(vipere, "Dos à dos ?", 1.6, 1.0)
	await _until(50.0)
	_say(ronin, "Dos à dos.", 1.6, -1.0)
	await _until(52.0)
	for goblin in goblins:
		_move(goblin.get_parent() as Node3D, ((STAGE + Vector3(0, 0, -1)) - goblin.global_position).normalized() * Vector3(1, 0, 1) * 1.5)
	_dolly(STAGE + Vector3(0, 8, 6), STAGE + Vector3(0, 7, 5), STAGE + Vector3(0, 0, -2),
			STAGE + Vector3(0, 0, -2), 6.0, true)
	await _until(54.0)
	_movers.clear()
	ronin.play(&"melee", true)
	_ring(STAGE + Vector3(0, 0, -1), Color(1.0, 0.85, 0.9), 12.0, 0.5)
	_impact_frame()
	for index in 3:
		_kill(goblins[index], &"petals", Color(1.0, 0.5, 0.8))
	await _until(55.0)
	vipere.play(&"shoot", true)
	for index in range(3, 6):
		_beam(vipere.global_position + Vector3.UP * 1.3, goblins[index].global_position + Vector3.UP, RED, 0.06)
		_kill(goblins[index], &"burn", RED)
	_speed(1.0)
	await _until(57.0)

	# 57 s: the slime.
	_dolly(STAGE + Vector3(-4, 1, 3), STAGE + Vector3(-3, 1.2, 2), STAGE + Vector3(0, 2, -9),
			STAGE + Vector3(0, 2.5, -9), 4.0, true)
	slime.play(&"shoot", true)
	await _until(58.0)
	_stomp(STAGE + Vector3(0, 0, -7), 1.0)
	ronin.play(&"die", true)
	vipere.play(&"die", true)
	_impact_frame()
	await _until(60.0)
	_say(vipere, "Il est trop gros !", 1.8, 1.0)
	await _until(62.2)
	_say(ronin, "Vise le cœur. Je le découpe.", 2.4, -1.0)
	await _until(64.8)
	ronin.play(&"idle")
	vipere.play(&"aim")
	_face(vipere, slime)
	_face(ronin, slime)
	_dolly(STAGE + Vector3(2.5, 1.5, 2.5), STAGE + Vector3(2.2, 1.5, 2.2), STAGE + Vector3(0, 2, -9),
			STAGE + Vector3(0, 2, -9), 3.0, true)
	for shot in 6:
		vipere.play(&"shoot", true)
		_beam(vipere.global_position + Vector3.UP * 1.3, slime.global_position + Vector3(randf_range(-0.5, 0.5), 2.5, 0), RED, 0.09)
		Effects.burst(_set, slime.global_position + Vector3.UP * 2.5, RED, 16)
		await _until(_clock + 0.25)
	await _until(67.0)
	# The Ronin dashes in.
	ronin.play(&"walk")
	create_tween().tween_property(ronin.get_parent(), "position", STAGE + Vector3(0, 0, -7.5), 0.4)
	_speed(1.2)
	_dolly(STAGE + Vector3(-5, 2, -5), STAGE + Vector3(-4.5, 2.2, -5.5), STAGE + Vector3(0, 2, -8),
			STAGE + Vector3(0, 2, -8), 3.0, true)
	await _until(67.6)
	ronin.play(&"melee", true)
	_impact_frame()
	_beam(STAGE + Vector3(-2, 5, -9), STAGE + Vector3(2, 0.5, -9), Color.WHITE, 0.12)
	_beam(STAGE + Vector3(2, 5, -9), STAGE + Vector3(-2, 0.5, -9), Color.WHITE, 0.12)
	await _until(68.6)
	_impact_frame()
	_fall(slime, 1.2)
	_ring(STAGE + Vector3(0, 0, -9), Color(0.5, 1.0, 0.5), 14.0, 0.8)
	await _until(71.0)

	# 71 s: in the calm, Vipère chooses.
	ronin.get_parent().position = STAGE + Vector3(-1.2, 0, -1)
	vipere.get_parent().position = STAGE + Vector3(1.2, 0, -1.5)
	ronin.play(&"idle")
	vipere.play(&"idle")
	_face(ronin, vipere)
	_face(vipere, ronin)
	_dolly(STAGE + Vector3(0, 1.5, 4.5), STAGE + Vector3(0, 1.5, 4.0), STAGE + Vector3(0, 1.4, -1.2),
			STAGE + Vector3(0, 1.4, -1.2), 10.0, true)
	await _until(72.0)
	_say(vipere, "Il voulait se débarrasser de moi.", 2.6, 1.0)
	await _until(75.0)
	_say(ronin, "Il se débarrasse de tout le monde.", 2.6, -1.0)
	await _until(78.0)
	_say(vipere, "Le Titan Mk II est au volcan.", 2.4, 1.0)
	await _until(80.8)
	_say(vipere, "J'ai livré les pièces moi-même.", 2.4, 1.0)
	await _until(83.6)
	_say(ronin, "Alors tu sais comment entrer.", 2.4, -1.0)
	await _until(86.4)
	_dolly(STAGE + Vector3(2.4, 1.6, 0.8), STAGE + Vector3(2.2, 1.6, 0.6), STAGE + Vector3(1.2, 1.5, -1.5),
			STAGE + Vector3(1.2, 1.5, -1.5), 6.0, true)
	_say(vipere, "Dis à ton soldat...", 2.0, 1.0)
	await _until(88.8)
	_say(vipere, "...que l'Écarlate le rejoint.", 2.6, 1.0)
	_speed(1.5)
	await _until(92.0)

	# 92 s: the city, the squad hears the news.
	_load_arena(4)
	var soldier := _hero("soldier", STAGE + Vector3(-1, 0, 1), PI)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0.4, 0, 1.4), PI)
	var captain := _hero("captain", STAGE + Vector3(1.6, 0, 1), PI)
	_dolly(STAGE + Vector3(0, 1.4, 7), STAGE + Vector3(0, 1.5, 6), STAGE + Vector3(0, 1.3, 1),
			STAGE + Vector3(0, 1.3, 1), 8.0, true)
	_narrate("En ville, un message du Ronin.", 2.6)
	await _until(95.0)
	_say(soldier, "Vipère... avec nous ?", 2.2, -1.0)
	await _until(97.6)
	_say(captain, "Je surveille mes poches.", 2.2, 1.0)
	await _until(100.2)
	_say(kunoichi, "Il nous faut plus de monde.", 2.2, -1.0)
	await _until(102.8)
	_dolly(STAGE + Vector3(0, 4, 9), STAGE + Vector3(0, 9, 13), STAGE + Vector3(0, 1.4, 0),
			STAGE + Vector3(0, 4, -10), 6.0, true)
	_narrate("L'heure des alliances.", 3.0)
	await _to_be_continued(106.4)
