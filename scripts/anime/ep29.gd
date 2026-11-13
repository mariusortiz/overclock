extends Season3Episode
## Épisode 29 : Le Gardien. The heart of the galaxy: a giant portal, and its
## Gardien, a titan of crystal. Both squads fight it; it sings shards all
## around, they answer with everything they have. It kneels, then asks its
## riddle: "Who created the Creator?"


func _init() -> void:
	episode_number = 29
	episode_title = "LE GARDIEN"
	duration = 82.0


const GUARDIAN_AT := Vector3(0, 0.1, -14)


func _story() -> void:
	_load_world("crystal")
	_night_sky()
	var gate := _portal(Vector3(0, 16, -27), 9.0)
	var heroes := _squad(STAGE + Vector3(0, 0, 0), 0.0, SQUAD, 1.4, true)
	var scarlet := _squad(STAGE + Vector3(0, 0, 2.2), 0.0, ["viking", "witch", "cowboy"], 1.6, true)
	var creator := _creator(STAGE + Vector3(4.6, 0, 1.8), 0.0)
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 2.4, 8), STAGE + Vector3(0, 2, -6), Vector3(0, 14, -27), 8.0)
	_fade_shade(0.0, 1.0)
	await _until(1.5)
	_narrate("Le cœur de la galaxie. Un portail grand comme une montagne.", 3.2)
	await _until(5.2)
	_say(heroes.captain, "Notre ticket de retour.", 1.8, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: the Gardien rises.
	_shake = 0.4
	var guardian := _guardian(GUARDIAN_AT, PI, 11.0)
	_rise(guardian, 11.0, 3.0)
	_dolly(STAGE + Vector3(-4, 1.2, 4), STAGE + Vector3(-3, 1.0, 3), GUARDIAN_AT + Vector3(0, 3, 0), GUARDIAN_AT + Vector3(0, 10, 0), 4.0)
	await _until(15.6)
	_narrate("LE GARDIEN", 2.4, true)
	_stomp(GUARDIAN_AT, 1.2)
	await _until(18.4)
	_dolly(GUARDIAN_AT + Vector3(-3, 6, 10), GUARDIAN_AT + Vector3(-2, 7, 8), GUARDIAN_AT + Vector3(0, 9, 0), GUARDIAN_AT + Vector3(0, 9.5, 0), 5.0)
	_say(guardian, "La porte ne s'ouvre pas pour les faibles.", 2.8, 1.0, 11.4)
	await _until(21.6)
	_say(guardian, "Montrez-moi.", 1.8, 1.0, 11.4)
	await _until(24.0)

	# 24 s: the song.
	guardian.play(&"shoot", true)
	_dolly(STAGE + Vector3(0, 8, 14), STAGE + Vector3(0, 10, 12), GUARDIAN_AT + Vector3(0, 2, 6), GUARDIAN_AT + Vector3(0, 2, 8), 5.0)
	for wave in 2:
		for index in 14:
			var angle := TAU * index / 14.0 + wave * 0.2
			var from := GUARDIAN_AT + Vector3(0, 5, 0)
			_beam(from, from + Vector3(cos(angle), -0.12, sin(angle)) * 30.0, CRYSTAL if index % 2 else CRYSTAL_PINK, 0.12)
		_ring(GUARDIAN_AT, CRYSTAL, 50.0, 1.0)
		_shake = 0.3
		await _until(_clock + 1.2)
	_narrate("Il chante. Et son chant coupe comme du verre.", 3.0)
	await _until(30.0)
	_say(heroes.soldier, "Tout le monde, ensemble !", 2.0, -1.0)
	await _until(32.4)

	# 32.4 s: everything they have.
	var target := GUARDIAN_AT + Vector3(0, 7, 0)
	var attackers := [heroes.soldier, heroes.cowgirl, heroes.sand_ghost, scarlet.cowboy, heroes.kunoichi]
	_dolly(STAGE + Vector3(-6, 2, 6), STAGE + Vector3(-5, 2.4, 4), STAGE + Vector3(0, 2, -2), target, 6.0)
	for hero: CharacterModel in attackers:
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3(0, 1.3, 0), target, [CYAN, GOLD, RED][randi() % 3], 0.08)
		Effects.burst(_set, target, CRYSTAL, 30)
		await _until(_clock + 0.35)
	await _until(35.0)
	_say(scarlet.witch, "Malédiction !", 1.4, 1.0)
	_beam(scarlet.witch.global_position + Vector3(0, 1.5, 0), target, MAGENTA, 0.3)
	_overlay(guardian, Color(MAGENTA, 0.3))
	await _until(36.8)
	_say(heroes.captain, "Bordée complète !", 1.6, 1.0)
	_airstrike(GUARDIAN_AT, 8, 3.0)
	_dolly(GUARDIAN_AT + Vector3(14, 8, 22), GUARDIAN_AT + Vector3(12, 9, 20), GUARDIAN_AT + Vector3(0, 4, 0), GUARDIAN_AT + Vector3(0, 6, 0), 4.0)
	await _until(40.0)
	_say(scarlet.viking, "RAGE !", 1.2, -1.0)
	_stomp(GUARDIAN_AT + Vector3(0, 0, 4), 1.0)
	await _until(41.6)
	_dolly(STAGE + Vector3(2, 2.0, 0), Vector3(2, 6.5, -2), heroes.ronin.global_position + Vector3.UP, target, 1.6)
	_say(heroes.ronin, "...", 1.0, 1.0)
	await _until(43.0)
	_impact_frame()
	_beam(target + Vector3(-4, 3, 2), target + Vector3(4, -4, 2), Color.WHITE, 0.25)
	_speed(1.0)
	_shake = 0.5
	await _until(44.4)

	# 44.4 s: it kneels.
	_overlay(guardian, Color(0.95, 0.45, 1.0, 0.18))
	var pivot := guardian.get_parent() as Node3D
	var kneel := create_tween()
	kneel.tween_property(pivot, "position:y", pivot.position.y - 3.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	kneel.parallel().tween_property(pivot, "rotation:x", 0.3, 1.2)
	_dolly(STAGE + Vector3(0, 2, 6), STAGE + Vector3(0, 3, 3), GUARDIAN_AT + Vector3(0, 4, 0), GUARDIAN_AT + Vector3(0, 5, 0), 6.0)
	await _until(45.6)
	_stomp(GUARDIAN_AT, 1.4)
	_narrate("Le Gardien pose un genou à terre.", 2.8)
	await _until(49.0)
	_say(heroes.cowgirl, "On a gagné ?", 1.6, 1.0)
	await _until(51.0)
	_dolly(GUARDIAN_AT + Vector3(-2, 6.5, 9), GUARDIAN_AT + Vector3(-1.5, 6.8, 8), GUARDIAN_AT + Vector3(0, 6.2, 0), GUARDIAN_AT + Vector3(0, 6.4, 0), 9.0)
	_say(guardian, "Vous êtes forts. Ce n'est pas assez.", 2.6, 1.0, 8.4)
	await _until(54.0)
	_say(guardian, "La porte s'ouvre pour qui répond à une question.", 3.0, 1.0, 8.4)
	await _until(57.4)

	# 57.4 s: the riddle.
	_dolly(STAGE + Vector3(5.8, 1.7, 4.4), STAGE + Vector3(5.4, 1.7, 4.0), creator.global_position + Vector3.UP * 1.5,
			creator.global_position + Vector3.UP * 1.5, 6.0)
	creator.get_parent().look_at(Vector3(GUARDIAN_AT.x, STAGE.y, GUARDIAN_AT.z))
	await _until(58.4)
	_narrate("« QUI A CRÉÉ LE CRÉATEUR ? »", 3.4, true)
	_glitch(0.3)
	await _until(62.4)
	_say(creator, "...", 1.6, -1.0)
	await _until(64.4)
	_say(heroes.kunoichi, "La version 0 ?", 1.6, 1.0)
	await _until(66.4)
	_say(guardian, "Non.", 1.4, 1.0, 8.4)
	_shake = 0.2
	await _until(68.2)
	_dolly(STAGE + Vector3(0, 2, 7), STAGE + Vector3(0, 2.2, 6), STAGE + Vector3(0, 1.4, 1), STAGE + Vector3(0, 1.4, 1), 6.0)
	_narrate("Le silence. Tout le monde se regarde.", 2.8)
	await _until(71.4)
	await _to_be_continued(71.8)
