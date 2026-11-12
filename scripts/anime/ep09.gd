extends AnimeDirector
## Épisode 9 : Titan Mk II (season 1). The red Titan walks into the city. The ships
## attack it from the sky, but a shield holds; the Soldier's ship goes down.
## On the ground, everyone gathers: it will take all of them.


func _init() -> void:
	episode_number = 9
	episode_title = "TITAN MK II"
	duration = 120.0


var _titan_shield: MeshInstance3D


func _story() -> void:
	# 0 s: the city; the red Titan's steps shake the street.
	_load_arena(4)
	var titan := _spawn_titan(STAGE + Vector3(0, 0, -14), 14.0, Color(1.0, 0.45, 0.4))
	titan.play(&"walk")
	_dolly(STAGE + Vector3(-3, 0.3, 8), STAGE + Vector3(-2, 0.5, 6), STAGE + Vector3(0, 2, -14),
			STAGE + Vector3(0, 13, -14), 8.0, true)
	_fade_shade(0.0, 1.0)
	_narrate("La ville. Le Titan Mk II arrive.", 3.0)
	for step in 3:
		get_tree().create_timer(1.2 + 2.0 * step).timeout.connect(_stomp.bind(STAGE + Vector3(0, 0, -14), 0.7))
	await _until(8.4)

	await _title_card(5.0)

	# 13.4 s: four ships come out of the clouds.
	var ships: Array[RaceShip] = []
	var pilots := ["SOLDAT", "VIPÈRE", "CAPITAINE", "KUNOICHI"]
	for index in 4:
		var color: Color = [CYAN, RED, GOLD, Color(1.0, 0.5, 0.8)][index]
		var ship := _parked_ship(color, STAGE + Vector3(-30, 40, 30), 0.0)
		ship.display_name = pilots[index]
		ship.scale = Vector3.ONE * 1.5
		ship.boost(100.0)
		ships.append(ship)
		_fly_to(ship, STAGE + Vector3(-30 + 4.0 * index, 40, 30 + 3.0 * index), STAGE + Vector3(-8 + 5.0 * index, 14, 6), 3.0)
	_dolly(STAGE + Vector3(0, 2, 10), STAGE + Vector3(0, 3, 9), STAGE + Vector3(-20, 30, 20),
			STAGE + Vector3(0, 14, 4), 3.4, true)
	_speed(3.0)
	await _until(16.8)
	_follow(ships[0], Vector3(0, 1.4, 5.0), Vector3(0, 0, -20))
	_say(ships[0], "Escadrille, en formation !", 2.2, -1.0, 1.6)
	await _until(19.4)
	_say(ships[1], "Je ne prends pas d'ordres. Mais d'accord.", 2.8, 1.0, 1.6)
	await _until(22.6)

	# 22.6 s: first pass, lasers on the Titan... a shield holds.
	for index in ships.size():
		_fly_to(ships[index], ships[index].global_position, STAGE + Vector3(-10 + 6.0 * index, 11, -6), 2.0)
	_dolly(STAGE + Vector3(12, 6, 4), STAGE + Vector3(10, 7, 2), STAGE + Vector3(0, 8, -12),
			STAGE + Vector3(0, 9, -12), 4.0, true)
	await _until(24.0)
	for burst in 8:
		var ship := ships[burst % 4]
		_beam(ship.global_position, titan.global_position + Vector3(randf_range(-3, 3), randf_range(6, 12), 4), ship.color, 0.15)
		_show_shield(titan, 0.4)
		await _until(_clock + 0.25)
	await _until(27.0)
	_say(ships[2], "Un bouclier ?!", 1.8, -1.0, 1.6)
	await _until(29.0)

	# 29 s: the Titan answers: a barrage.
	titan.play(&"shoot", true)
	_dolly(STAGE + Vector3(-6, 9, 12), STAGE + Vector3(-5, 10, 10), STAGE + Vector3(0, 10, -12),
			STAGE + Vector3(-4, 11, 0), 3.0, true)
	for missile in 6:
		var target := ships[missile % 4].global_position + Vector3(randf_range(-4, 4), randf_range(-2, 2), 0)
		get_tree().create_timer(0.2 * missile).timeout.connect(_rocket.bind(titan.global_position + Vector3(0, 12, 2), target))
	_speed(2.5)
	await _until(31.0)
	_impact_frame()
	ships[0].hit()
	ships[0].hit()
	ships[0].hit()
	_shake = 0.3
	await _until(32.0)

	# 32 s: the Soldier's ship falls, smoking.
	_follow(ships[0], Vector3(2.5, 1.0, 4.0), Vector3(0, 0, -4))
	_say(ships[0], "Je suis touché !", 1.8, -1.0, 1.6)
	_fly_to(ships[0], ships[0].global_position, STAGE + Vector3(-6, 0.8, 4), 3.0)
	for puff in 10:
		get_tree().create_timer(0.3 * puff).timeout.connect(func() -> void:
			if is_instance_valid(ships[0]):
				Effects.burst(_set, ships[0].global_position, Color(0.4, 0.4, 0.45), 6))
	await _until(34.4)
	_say(ships[1], "SOLDAT !", 1.6, 1.0, 1.6)
	await _until(35.4)
	_dolly(STAGE + Vector3(-2, 0.6, 8), STAGE + Vector3(-2.5, 0.8, 7), STAGE + Vector3(-6, 3, 4),
			STAGE + Vector3(-6, 0.8, 4), 2.0, true)
	await _until(35.8)
	_stomp(STAGE + Vector3(-6, 0, 4), 1.0)
	_impact_frame()
	await _until(38.0)

	# 38 s: on the ground, the Soldier climbs out. Alive.
	ships[0].queue_free()
	var soldier := _hero("soldier", STAGE + Vector3(-5, 0, 5), PI)
	soldier.play(&"die", true)
	_dolly(STAGE + Vector3(-3.8, 0.6, 7.5), STAGE + Vector3(-4, 0.7, 7.0), STAGE + Vector3(-5, 0.6, 5),
			STAGE + Vector3(-5, 0.8, 5), 5.0, true)
	await _until(40.0)
	soldier.play(&"idle")
	_say(soldier, "Ça va... à peu près.", 2.0, -1.0)
	await _until(42.6)

	# 42.6 s: the others land beside him.
	for index in range(1, 4):
		create_tween().tween_property(ships[index], "scale", Vector3.ONE, 2.0)
		_fly_to(ships[index], ships[index].global_position, STAGE + Vector3(-6.0 + 3.0 * index, 0.8, -3.5), 2.0)
	_dolly(STAGE + Vector3(0, 2, 10), STAGE + Vector3(0, 1.8, 9), STAGE + Vector3(-1, 3, 2),
			STAGE + Vector3(-1, 1, 2), 3.0, true)
	await _until(45.6)
	var vipere := _hero("sand_ghost", STAGE + Vector3(-2.4, 0, 3.0), PI * 0.8)
	var captain := _hero("captain", STAGE + Vector3(0.2, 0, 3.0), PI)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(2.8, 0, 3.0), -PI * 0.8)
	_dolly(STAGE + Vector3(-1, 1.5, 9), STAGE + Vector3(-1, 1.5, 8), STAGE + Vector3(-1.5, 1.3, 3.8),
			STAGE + Vector3(-1.5, 1.3, 3.8), 8.0, true)
	await _until(46.6)
	_say(vipere, "Tu m'as fait peur, débutant.", 2.4, 1.0)
	await _until(49.4)
	_say(soldier, "C'est le bouclier. Rien ne passe.", 2.6, -1.0)
	await _until(52.4)
	_say(kunoichi, "Rien de seul ne passe.", 2.2, 1.0)
	await _until(55.0)
	_say(captain, "Tu veux dire... tous en même temps ?", 2.6, 1.0)
	await _until(58.0)

	# 58 s: the Titan reaches the square. The Directeur speaks from it.
	titan.play(&"walk")
	create_tween().tween_property(titan.get_parent(), "position", STAGE + Vector3(0, 0, -8), 6.0)
	_dolly(STAGE + Vector3(4, 0.4, 7), STAGE + Vector3(3, 0.6, 6), STAGE + Vector3(0, 4, -8),
			STAGE + Vector3(0, 13, -8), 6.0, true)
	await _until(60.0)
	_say(titan, "Rendez-vous. Ou disparaissez.", 2.8, 1.0, 14.0)
	await _until(63.4)
	_say(titan, "Votre petite escouade ne suffira pas.", 3.0, 1.0, 14.0)
	await _until(67.0)

	# 67 s: then, one by one, the others arrive.
	_dolly(STAGE + Vector3(0, 1.6, 10), STAGE + Vector3(0, 1.8, 8.5), STAGE + Vector3(0, 1.5, 3),
			STAGE + Vector3(0, 1.5, 3), 12.0, true)
	var arrivals := [["ronin", Vector3(4.4, 0, 3.4)], ["viking", Vector3(-4.0, 0, 4.0)], ["witch", Vector3(5.8, 0, 4.4)],
			["cowboy", Vector3(-5.6, 0, 5.4)], ["cowgirl", Vector3(7.2, 0, 5.4)], ["paladin", Vector3(-7.0, 0, 6.6)],
			["godfather", Vector3(8.4, 0, 6.6)]]
	var lines := ["Elle suffira.", "On est là !", "Mes cartes disent : maintenant.", "Pas question de rater ça.",
			"Yiii-haaa !", "La lumière est avec nous.", "Il me doit toujours de l'argent."]
	var all_heroes: Array[CharacterModel] = [soldier, vipere, captain, kunoichi]
	for index in arrivals.size():
		await _until(67.4 + 2.6 * index)
		var hero := _hero(arrivals[index][0], STAGE + arrivals[index][1] + Vector3(0, 5, 0), PI)
		_drop(hero.get_parent() as Node3D, STAGE.y, 0.4)
		Effects.burst(_set, hero.global_position, GOLD, 20)
		_say(hero, lines[index], 2.2, 1.0 if arrivals[index][1].x > 0 else -1.0)
		all_heroes.append(hero)
	await _until(86.0)

	# 86 s: eleven heroes in a line before the Titan.
	for hero in all_heroes:
		hero.get_parent().rotation.y = 0.0
		hero.play(&"aim")
	_dolly(STAGE + Vector3(0, 0.6, 12), STAGE + Vector3(0, 1.0, 10), STAGE + Vector3(0, 2, 2),
			STAGE + Vector3(0, 9, -8), 8.0, true)
	_narrate("Onze héros. Un seul Titan.", 3.0)
	await _until(90.0)
	_dolly(STAGE + Vector3(-5, 1.55, 3.4), STAGE + Vector3(-5, 1.55, 3.0), STAGE + Vector3(-5, 1.5, 5),
			STAGE + Vector3(-5, 1.6, 5), 3.0, false)
	_speed(3.0)
	_say(soldier, "Cette fois, on frappe tous ensemble.", 2.6, 1.0)
	await _until(93.0)
	_dolly(STAGE + Vector3(-2.4, 1.55, 1.4), STAGE + Vector3(-2.4, 1.55, 1.0), STAGE + Vector3(-2.4, 1.5, 3),
			STAGE + Vector3(-2.4, 1.6, 3), 3.0, false)
	_say(vipere, "Et après, la revanche.", 2.2, 1.0)
	await _until(95.6)
	_dolly(STAGE + Vector3(0, 0.4, -2), STAGE + Vector3(0, 0.3, -3), STAGE + Vector3(0, 6, -8),
			STAGE + Vector3(0, 13, -8), 4.0, true)
	titan.play(&"shoot", true)
	_show_shield(titan, 3.0)
	_say(titan, "Essayez donc.", 2.0, 1.0, 14.0)
	_shake = 0.2
	await _until(99.6)
	_impact_frame()
	_dolly(STAGE + Vector3(0, 4, 16), STAGE + Vector3(0, 8, 20), STAGE + Vector3(0, 2, 2),
			STAGE + Vector3(0, 8, -8), 6.0, true)
	_narrate("Dernier épisode : OVERCLOCK.", 3.6)
	await _to_be_continued(104.0)


## The Titan's shield: a red bubble, shown for `seconds`.
func _show_shield(titan: CharacterModel, seconds: float) -> void:
	if not is_instance_valid(_titan_shield):
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(1.0, 0.3, 0.3, 0.25)
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		var sphere := SphereMesh.new()
		sphere.radius = 9.0
		sphere.height = 18.0
		sphere.material = material
		_titan_shield = MeshInstance3D.new()
		_titan_shield.mesh = sphere
		_set.add_child(_titan_shield)
	_titan_shield.global_position = titan.global_position + Vector3.UP * 7.0
	_titan_shield.visible = true
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if is_instance_valid(_titan_shield):
			_titan_shield.visible = false)
