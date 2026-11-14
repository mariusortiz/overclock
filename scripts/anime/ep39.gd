extends Season4Episode
## Épisode 39 : Le Miroir-Titan. Le Reflet becomes a Titan of mirror glass in
## the middle of the mirror city. The squad and the mirror world's allies
## fight it together; every hero attacks at once, the one thing it cannot
## copy. It cracks, but the two worlds start to overlap.


func _init() -> void:
	episode_number = 39
	episode_title = "LE MIROIR-TITAN"
	duration = 50.0


func _story() -> void:
	_load_mirror_world()
	var titan := _mirror_titan(STAGE + Vector3(0, 0, -16))
	titan.play(&"idle")
	_dolly(STAGE + Vector3(0, 2, 8), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 6, -16), STAGE + Vector3(0, 9, -16), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_stomp(STAGE + Vector3(0, 0, -16), 0.5)
	_narrate("Le Miroir-Titan.", 2.2, true)
	await _until(4.0)
	var heroes := _squad(STAGE + Vector3(0, 0, 2), 0.0, SQUAD, 1.6, true)
	_say(heroes.captain, "Tout le monde. Ensemble. Maintenant.", 2.2, 1.0)
	await _until(6.8)
	await _title_card(5.0)

	# 11.8 s: everyone at once.
	_speed(5.0)
	_dolly(STAGE + Vector3(-8, 2.4, 6), STAGE + Vector3(8, 2.4, 6), STAGE + Vector3(0, 4, -16), STAGE + Vector3(0, 5, -16), 6.0)
	for index in SQUAD.size():
		var hero: CharacterModel = heroes[SQUAD[index]]
		hero.play(&"shoot", true)
		var color: Color = [GOLD, MIRROR, CRYSTAL, RED][index % 4]
		get_tree().create_timer(0.15 * index).timeout.connect(
				_beam.bind(hero.global_position + Vector3.UP * 1.3, titan.global_position + Vector3.UP * 6.0, color, 0.08))
	await _until(13.4)
	_narrate("Sept attaques à la fois. Il ne sait plus laquelle copier.", 3.2, true)
	await _until(17.0)
	_shake = 0.35
	_overlay(titan, Color(1.0, 1.0, 1.0, 0.35))
	_dolly(STAGE + Vector3(3, 6, -6), STAGE + Vector3(2.6, 7, -7), STAGE + Vector3(0, 8, -16), STAGE + Vector3(0, 8, -16), 6.0)
	await _until(17.8)
	_narrate("Le verre se fend.", 2.0)
	await _until(20.2)
	var creator := _creator(STAGE + Vector3(2.4, 0, 4.4), PI)
	_appear(creator, 0.5)
	_dolly(STAGE + Vector3(2.8, 1.7, 7.8), STAGE + Vector3(2.6, 1.7, 7.2), STAGE + Vector3(2.4, 1.5, 4.4), STAGE + Vector3(2.4, 1.5, 4.4), 6.0)
	await _until(20.8)
	_say(creator, "Encore ! Il ne peut pas copier une équipe.", 2.6, 1.0)
	await _until(23.8)

	# 23.8 s: the second volley, and the cost.
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 2.6, 8), STAGE + Vector3(0, 5, -16), STAGE + Vector3(0, 6, -16), 6.0)
	for index in SQUAD.size():
		var hero: CharacterModel = heroes[SQUAD[index]]
		hero.play(&"shoot", true)
		get_tree().create_timer(0.12 * index).timeout.connect(
				_beam.bind(hero.global_position + Vector3.UP * 1.3, titan.global_position + Vector3.UP * 6.0, GOLD, 0.1))
	await _until(25.0)
	_impact_frame()
	titan.play(&"die")
	_shake = 0.4
	Effects.spray(_set, titan.global_position + Vector3.UP * 6, [GLASS, MIRROR, Color.WHITE], 120, Vector3(0.2, 0.2, 0.03),
			Vector2(5.0, 10.0), Vector3(0, -6.0, 0), 80.0, 2.0)
	await _until(26.0)
	_pivot_of(titan).visible = false
	await _until(26.4)
	_narrate("Le Miroir-Titan éclate.", 2.4, true)
	await _until(29.4)
	_tint_world(Color(1.0, 0.8, 0.5))
	_dolly(STAGE + Vector3(0, 10, 14), STAGE + Vector3(0, 14, 20), STAGE + Vector3(0, 2, -4), STAGE + Vector3(0, 6, -20), 8.0)
	_narrate("Mais le ciel change. Le soleil de leur monde perce le verre.", 3.4)
	await _until(33.4)
	_say(heroes.sand_ghost, "Les deux mondes... se touchent.", 2.2, 1.0)
	await _until(36.0)
	_say(creator, "Ou ils fusionnent. Et ça, je ne l'ai pas écrit non plus.", 3.0, 1.0)
	await _until(39.6)
	await _to_be_continued(40.0)
