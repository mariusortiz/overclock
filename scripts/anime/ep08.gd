extends AnimeDirector
## Épisode 8 : Le volcan. The heroes slip into the Directeur's volcano base,
## take down his guards and his dragon, and meet the man himself: too late,
## the Titan Mk II rises from the lava.


func _init() -> void:
	episode_number = 8
	episode_title = "LE VOLCAN"
	duration = 120.0


func _story() -> void:
	# 0 s: the volcano at night; the heroes walk in a line.
	_load_arena(3)
	var ids := ["soldier", "sand_ghost", "kunoichi", "captain", "ronin", "viking"]
	var team: Array[CharacterModel] = []
	for index in ids.size():
		var hero := _hero(ids[index], STAGE + Vector3(-5.0 + 2.0 * index, 0, -3 - (index % 2)), PI)
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, 0.7))
		team.append(hero)
	var soldier := team[0]
	var vipere := team[1]
	var kunoichi := team[2]
	var captain := team[3]
	var ronin := team[4]
	var brutus := team[5]
	_embers(true)
	_dolly(STAGE + Vector3(0, 0.3, 6), STAGE + Vector3(0, 0.4, 5.5), STAGE + Vector3(0, 2.3, -3),
			STAGE + Vector3(0, 2.3, -1), 8.0, true)
	_fade_shade(0.0, 1.4)
	_narrate("Le volcan. L'entrée de service.", 3.0)
	await _until(3.6)
	_say(vipere, "Par ici. Sans bruit.", 2.2, 1.0)
	await _until(6.2)
	_say(brutus, "Je ne fais jamais de bruit.", 2.0, -1.0)
	await _until(8.4)

	await _title_card(5.0)

	# 13.4 s: two guards at the door. The Kunoichi and the Ronin, silently.
	_movers.clear()
	_embers(false)
	for hero in team:
		hero.play(&"idle")
		hero.get_parent().rotation.y = 0.0
	var door_guards: Array[Enemy] = []
	for side: float in [-1.0, 1.0]:
		door_guards.append(_enemy(STAGE + Vector3(side * 2.0, 0, -10), PI, &"idle"))
	_dolly(STAGE + Vector3(-4, 1.2, -4), STAGE + Vector3(-3.6, 1.3, -4.4), STAGE + Vector3(0, 1.2, -10),
			STAGE + Vector3(0, 1.2, -10), 6.0, true)
	await _until(14.6)
	_say(kunoichi, "La gauche est à moi.", 1.8, -1.0)
	await _until(16.6)
	_say(ronin, "La droite.", 1.4, 1.0)
	await _until(18.2)
	kunoichi.get_parent().position = STAGE + Vector3(-2.0, 0, -9)
	ronin.get_parent().position = STAGE + Vector3(2.0, 0, -9)
	kunoichi.play(&"melee", true)
	ronin.play(&"melee", true)
	_speed(1.0)
	_slash(door_guards[0], &"petals", Color(1.0, 0.5, 0.8))
	_slash(door_guards[1], &"vanish", CYAN)
	_impact_frame()
	await _until(20.0)
	_say(brutus, "...J'aurais fait pareil.", 2.0, 1.0)
	await _until(22.4)

	# 22.4 s: inside, a hall full of guards. No more silence.
	_wipe()
	team[0].get_parent().position = STAGE + Vector3(-1.5, 0, 2)
	for index in team.size():
		team[index].get_parent().position = STAGE + Vector3(-5.0 + 2.0 * index, 0, 2)
		team[index].play(&"aim")
	var hall_guards: Array[Enemy] = []
	for index in 8:
		var spot := STAGE + Vector3(-7.0 + 2.0 * index, 0, -9 - (index % 3))
		hall_guards.append(_enemy(spot, PI, &"aim"))
	_dolly(STAGE + Vector3(0, 0.6, -14), STAGE + Vector3(0, 0.7, -13.5), STAGE + Vector3(0, 1.4, 2),
			STAGE + Vector3(0, 1.4, 2), 3.0, true)
	await _until(23.4)
	_say(captain, "Bon. Plan B.", 1.6, -1.0)
	await _until(25.0)
	_say(brutus, "PLAN B !", 1.4, 1.0)
	_speed(6.0)
	_dolly(STAGE + Vector3(-8, 2.5, 4), STAGE + Vector3(8, 2.5, 4), STAGE + Vector3(-5, 1, -6),
			STAGE + Vector3(5, 1, -6), 5.5, true)
	var styles := [&"knockback", &"burn", &"vanish", &"confetti", &"shatter", &"pixelate", &"flare", &"melt"]
	for index in hall_guards.size():
		var hero := team[index % team.size()]
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3.UP * 1.3, hall_guards[index].global_position + Vector3.UP,
				[CYAN, RED, CYAN, GOLD, Color(1.0, 0.5, 0.8), Color(1.0, 0.55, 0.15)][index % 6], 0.08)
		_kill(hall_guards[index], styles[index], [CYAN, RED, CYAN, GOLD, Color(1.0, 0.5, 0.8), Color(1.0, 0.55, 0.15)][index % 6])
		await _until(_clock + 0.6)
	_impact_frame()
	await _until(31.0)

	# 31 s: a roar from the lava: the Directeur's dragon.
	var dragon := _spawn_boss(Boss.Kind.COLOSSUS, STAGE + Vector3(0, 3.0, -10), 4.0, 2.2)
	_rise(dragon, 12.0, 2.0)
	_dolly(STAGE + Vector3(0, 0.6, 4), STAGE + Vector3(0, 0.8, 3), STAGE + Vector3(0, 3, -10),
			STAGE + Vector3(0, 7, -10), 3.0, true)
	_shake = 0.3
	_embers(true)
	await _until(33.4)
	_impact_frame()
	_say(soldier, "Un dragon. Évidemment.", 2.0, -1.0)
	await _until(35.8)
	dragon.play(&"shoot", true)
	await _until(36.4)
	for blast in 4:
		_rocket(dragon.global_position + Vector3(0, 4, 2), STAGE + Vector3(randf_range(-5, 5), 0, randf_range(0, 3)))
	await _until(38.0)
	for hero in team:
		hero.play(&"die", true)
	_shake = 0.3
	await _until(39.4)

	# 39.4 s: Vipère and the Soldier, together.
	for hero in team:
		hero.play(&"idle")
	_dolly(STAGE + Vector3(-1.6, 1.5, 4.5), STAGE + Vector3(-1.4, 1.5, 4.0), STAGE + Vector3(-0.5, 1.4, 2),
			STAGE + Vector3(-0.5, 1.4, 2), 4.0, true)
	vipere.get_parent().position = STAGE + Vector3(0.6, 0, 2.2)
	soldier.get_parent().position = STAGE + Vector3(-1.4, 0, 2.2)
	_say(vipere, "Son cou. C'est là que l'armure s'ouvre.", 2.8, 1.0)
	await _until(42.6)
	_say(soldier, "Je le distrais. Tu tires.", 2.2, -1.0)
	await _until(45.2)
	soldier.play(&"walk")
	create_tween().tween_property(soldier.get_parent(), "position", STAGE + Vector3(-5, 0, -3), 1.2)
	_dolly(STAGE + Vector3(-8, 1.5, 2), STAGE + Vector3(-7.5, 1.6, 1.5), STAGE + Vector3(-5, 1.2, -3),
			STAGE + Vector3(-5, 1.2, -3), 3.0, true)
	_say(soldier, "Hé, le lézard ! Par ici !", 2.2, -1.0)
	await _until(47.6)
	soldier.play(&"shoot", true)
	_beam(soldier.global_position + Vector3.UP * 1.3, dragon.global_position + Vector3(0, 3, 0), CYAN, 0.1)
	dragon.get_parent().look_at(soldier.global_position * Vector3(1, 0, 1) + Vector3(0, dragon.get_parent().position.y, 0))
	await _until(48.6)
	# The rail gun, through the gap in the armour.
	_dolly(STAGE + Vector3(1.4, 1.6, 3.6), STAGE + Vector3(1.2, 1.6, 3.2), STAGE + Vector3(0.6, 1.4, 2.2),
			dragon.global_position + Vector3(0, 4, 0), 2.0, false)
	_speed(2.0)
	vipere.play(&"aim")
	await _until(50.4)
	vipere.play(&"shoot", true)
	_beam(vipere.global_position + Vector3.UP * 1.3, dragon.global_position + Vector3(0, 4.5, 0), RED, 0.2)
	_impact_frame()
	_shake = 0.3
	await _until(51.2)
	_fall(dragon, 1.6)
	_dolly(STAGE + Vector3(6, 2, 2), STAGE + Vector3(5, 3, 1), STAGE + Vector3(0, 3, -10),
			STAGE + Vector3(0, 0.5, -10), 3.6, true)
	await _until(55.0)
	_say(captain, "Joli tir !", 1.6, 1.0)
	await _until(57.0)

	# 57 s: slow applause. The Directeur, on a ledge.
	_embers(false)
	for hero in team:
		hero.play(&"idle")
		hero.get_parent().rotation.y = 0.0
	var directeur := _npc("Suit_Male.fbx", STAGE + Vector3(0, 4.0, -12), PI)
	_dolly(STAGE + Vector3(0, 1.0, 3), STAGE + Vector3(0, 1.2, 2), STAGE + Vector3(0, 5.5, -12),
			STAGE + Vector3(0, 5.6, -12), 5.0, true)
	await _until(58.0)
	_narrate("LE DIRECTEUR · en personne", 2.6)
	_say(directeur, "Bravo. Vraiment.", 2.0, 1.0)
	await _until(60.6)
	_dolly(STAGE + Vector3(-1.5, 5.2, -9), STAGE + Vector3(-1.3, 5.3, -9.4), STAGE + Vector3(0, 5.6, -12),
			STAGE + Vector3(0, 5.6, -12), 8.0, true)
	_say(directeur, "Vipère. Ma meilleure employée.", 2.6, 1.0)
	await _until(63.6)
	_say(vipere, "Ancienne employée.", 2.0, -1.0)
	await _until(66.0)
	_say(directeur, "Peu importe. Vous arrivez trop tard.", 2.8, 1.0)
	await _until(69.2)
	_say(directeur, "Réveille-toi, mon Titan.", 2.4, 1.0)
	_impact_frame()
	await _until(72.0)

	# 72 s: the lava boils; the Titan Mk II rises.
	var titan := _spawn_titan(STAGE + Vector3(0, 0, -20), 14.0, Color(1.0, 0.45, 0.4))
	_rise(titan, 16.0, 6.0)
	_embers(true)
	_shake = 0.4
	_dolly(STAGE + Vector3(0, 0.3, 4), STAGE + Vector3(0, 0.5, 3), STAGE + Vector3(0, 2, -20),
			STAGE + Vector3(0, 12, -20), 6.0, true)
	_speed(6.0)
	await _until(75.0)
	_ring(STAGE + Vector3(0, 0, -20), Color(1.0, 0.55, 0.15), 30.0, 1.2)
	await _until(78.0)
	_impact_frame()
	_stomp(STAGE + Vector3(0, 0, -20), 1.6)
	await _until(79.0)
	_say(captain, "Il est... deux fois plus grand.", 2.4, -1.0)
	await _until(81.8)
	_say(brutus, "TROIS fois !", 1.8, 1.0)
	await _until(84.0)

	# 84 s: it turns toward the city. The Directeur laughs.
	titan.play(&"walk")
	_dolly(STAGE + Vector3(10, 3, 0), STAGE + Vector3(12, 5, -2), STAGE + Vector3(0, 8, -20),
			STAGE + Vector3(0, 9, -20), 6.0, true)
	await _until(85.0)
	_say(directeur, "Direction : la ville. Elle est à moi.", 2.8, 1.0)
	await _until(88.2)
	directeur.get_parent().queue_free()
	Effects.burst(_set, STAGE + Vector3(0, 5, -12), CYAN, 40)
	_dolly(STAGE + Vector3(-2, 1.5, 4), STAGE + Vector3(-1.8, 1.5, 3.6), STAGE + Vector3(-0.5, 1.4, 1.5),
			STAGE + Vector3(-0.5, 1.4, 1.5), 8.0, true)
	_say(kunoichi, "Il s'est téléporté !", 2.0, -1.0)
	await _until(90.8)
	_say(soldier, "Tout le monde aux vaisseaux.", 2.4, -1.0)
	await _until(93.6)
	_say(vipere, "Au sol, on ne l'arrêtera pas. Il faut le prendre par le ciel.", 3.4, 1.0)
	await _until(97.4)

	# 97.4 s: the ships take off from the volcano.
	_movers.clear()
	_embers(false)
	var ships: Array[RaceShip] = []
	for index in 4:
		var color: Color = [CYAN, RED, GOLD, Color(1.0, 0.5, 0.8)][index]
		var ship := _parked_ship(color, STAGE + Vector3(-3.0 + 2.0 * index, 0.8, 0), 0.0)
		ship.scale = Vector3.ONE * 1.4
		ship.boost(6.0)
		ships.append(ship)
	_dolly(STAGE + Vector3(0, 2, 8), STAGE + Vector3(0, 3, 7), STAGE + Vector3(0, 1, 0),
			STAGE + Vector3(0, 15, -30), 6.0, true)
	for index in ships.size():
		get_tree().create_timer(0.3 * index).timeout.connect(_fly_to.bind(ships[index], ships[index].global_position,
				STAGE + Vector3(-6.0 + 4.0 * index, 30, -60), 3.0))
	_speed(4.0)
	await _until(101.0)
	_narrate("La bataille finale commence.", 3.4)
	await _to_be_continued(106.0)
