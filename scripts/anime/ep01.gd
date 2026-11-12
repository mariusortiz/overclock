extends AnimeDirector
## Épisode 1 : L'escouade. The Soldier meets the Kunoichi in the station, the
## Captain in the desert and the Ronin in the jungle; the four of them bring
## down the Titan.


func _init() -> void:
	episode_number = 1
	episode_title = "L'ESCOUADE"
	duration = 122.0


func _story() -> void:
	# 0 s: cold open. The city has fallen; the Titan walks in it.
	_load_arena(4)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -6))
	_titan.play(&"walk")
	_dolly(STAGE + Vector3(-4, 0.6, 9), STAGE + Vector3(-2.5, 1.2, 7), STAGE + Vector3(0, 2, -6),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.85, -6), 8.5)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La ville est tombée.", 3.0)
	await _until(4.8)
	_narrate("Il ne reste qu'une escouade... qui n'existe pas encore.", 3.6)
	await _until(6.5)
	_stomp(_titan.get_parent().position, 1.0)
	await _until(8.6)

	# 8.6 s: title card.
	await _title_card(5.0)

	# 13.6 s: the station. The Soldier, alone, against the guards.
	_load_arena(0)
	var soldier := _hero("soldier", STAGE, 0.0)
	soldier.play(&"aim")
	var guards: Array[Enemy] = []
	for index in 5:
		var spot := STAGE + Vector3(-4.0 + 2.0 * index, 0, -9.0 - 1.4 * (index % 2))
		guards.append(_enemy(spot, PI, &"walk"))
		_move(guards[index].get_parent() as Node3D, Vector3(0, 0, 0.45))
	_dolly(STAGE + Vector3(1.6, 1.5, 2.6), STAGE + Vector3(1.2, 1.7, 2.0), STAGE + Vector3(0, 1.4, -6),
			STAGE + Vector3(0, 1.3, -6), 4.0, true)
	await _until(14.6)
	_say(soldier, "Encore une vague.", 2.4, -1.0)
	await _until(17.6)
	_dolly(STAGE + Vector3(-5, 1.0, -1), STAGE + Vector3(-4.2, 1.2, -2.5), STAGE + Vector3(0, 1.2, -6),
			STAGE + Vector3(0, 1.2, -6), 3.5, true)
	for index in 2:
		await _until(17.8 + 0.6 * index)
		_shoot(soldier, guards[index], &"knockback", CYAN)
	await _until(19.4)
	# One of them gets behind him...
	var sneaky := _enemy(STAGE + Vector3(1.5, 0, 2.8), 0.0, &"aim")
	_dolly(STAGE + Vector3(4, 1.2, 4.5), STAGE + Vector3(3.4, 1.3, 4.0), STAGE + Vector3(0.6, 1.3, 1.2),
			STAGE + Vector3(0.6, 1.3, 1.2), 2.4, true)
	_say(soldier, "...!", 1.2, 1.0)
	await _until(20.6)
	# ...and the Kunoichi drops on him.
	var kunoichi := _hero("kunoichi", STAGE + Vector3(2.2, 6.0, 2.2), PI * 0.75)
	_drop(kunoichi.get_parent() as Node3D, STAGE.y, 0.35)
	await _until(21.0)
	kunoichi.play(&"melee", true)
	_impact_frame()
	_speed(0.6)
	_kill(sneaky, &"petals", Color(1.0, 0.5, 0.8))
	_shake = 0.15
	await _until(21.8)
	_face(soldier, kunoichi)
	_face(kunoichi, soldier)
	_dolly(STAGE + Vector3(4.2, 1.6, -1.0), STAGE + Vector3(3.6, 1.5, -0.6), STAGE + Vector3(1.1, 1.4, 1.1),
			STAGE + Vector3(1.1, 1.4, 1.1), 6.0, true)
	_say(kunoichi, "Besoin d'aide, soldat ?", 2.4, 1.0)
	await _until(24.5)
	_say(soldier, "Je travaille seul.", 2.0, -1.0)
	await _until(26.8)
	_say(kunoichi, "Plus maintenant.", 2.0, 1.0)
	await _until(28.0)
	# Her ultimate: two clones, and the rest of the guards fall.
	kunoichi.play(&"victory", true)
	_face(soldier, guards[3])
	_face(kunoichi, guards[3])
	for side: float in [-1.0, 1.0]:
		var clone := _hero("kunoichi", STAGE + Vector3(2.2 + side * 1.5, 0, 1.0), 0.0)
		_tint(clone, Color(0.4, 0.9, 1.0))
		Effects.burst(_set, clone.global_position + Vector3.UP, CYAN, 30)
	_dolly(STAGE + Vector3(0, 2.5, 7.5), STAGE + Vector3(0, 2.0, 6.0), STAGE + Vector3(0, 1.0, -4),
			STAGE + Vector3(0, 1.0, -5), 4.0, true)
	_speed(1.4)
	for index in range(2, guards.size()):
		await _until(28.6 + 0.3 * (index - 2))
		_slash(guards[index], &"vanish", CYAN)
	await _until(31.6)
	_say(soldier, "...Pas mal.", 1.8, -1.0)
	await _until(33.6)

	# 33.6 s: the desert. A giant skeleton, and the Captain.
	_wipe()
	_load_arena(1)
	soldier = _hero("soldier", STAGE + Vector3(-1.0, 0, 2), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(1.0, 0, 2), 0.0)
	soldier.play(&"aim")
	var brute := _spawn_boss(Boss.Kind.BRUTE, STAGE + Vector3(0, 0, -5), 3.6)
	# Twice the size it has in the game: the heroes look up at it.
	(brute.get_parent() as Node3D).scale = Vector3.ONE * 2.2
	_dolly(STAGE + Vector3(-4.5, 0.5, 6), STAGE + Vector3(-3.5, 0.6, 5), STAGE + Vector3(0, 3.5, -5),
			STAGE + Vector3(0, 4.5, -5), 3.0, true)
	_stomp(STAGE + Vector3(0, 0, -5), 0.7)
	_impact_frame()
	await _until(35.4)
	_say(soldier, "Il est énorme !", 1.8, -1.0)
	await _until(37.4)
	_say(kunoichi, "Mes lames ne passent pas !", 2.0, 1.0)
	kunoichi.play(&"melee", true)
	await _until(39.6)
	var captain := _hero("captain", STAGE + Vector3(5.0, 0, -1.0), 0.0)
	_face(captain, soldier)
	captain.play(&"aim")
	_dolly(STAGE + Vector3(1.6, 1.3, 1.6), STAGE + Vector3(2.2, 1.4, 1.0), STAGE + Vector3(5.0, 1.5, -1.0),
			STAGE + Vector3(5.0, 1.6, -1.0), 3.4, true)
	_say(captain, "Écartez-vous, moussaillons !", 2.6, -1.0)
	await _until(42.8)
	# Broadside: rockets from all sides.
	_face(captain, brute)
	_dolly(STAGE + Vector3(0, 4.0, 9), STAGE + Vector3(0, 5.0, 8), STAGE + Vector3(0, 2.0, -5),
			STAGE + Vector3(0, 2.5, -5), 3.0, true)
	_speed(1.6)
	for index in 8:
		var from := captain.global_position + Vector3(0, 1.4, 0)
		var target := brute.global_position + Vector3(randf_range(-1.5, 1.5), randf_range(1.0, 4.0), 0)
		get_tree().create_timer(0.12 * index).timeout.connect(_rocket.bind(from, target))
	await _until(44.2)
	_impact_frame()
	_shake = 0.3
	_fall(brute, 1.2)
	await _until(46.0)
	_face(soldier, captain)
	_face(captain, soldier)
	_dolly(STAGE + Vector3(2.0, 1.6, 6.5), STAGE + Vector3(2.4, 1.6, 6.0), STAGE + Vector3(2.0, 1.4, 0.5),
			STAGE + Vector3(2.0, 1.4, 0.5), 6.0, true)
	_say(soldier, "Pas mal, pour une pirate.", 2.4, -1.0)
	await _until(48.8)
	_say(captain, "Pas mal, pour un soldat !", 2.4, 1.0)
	await _until(51.6)

	# 51.6 s: the jungle. The Ronin, and the goblins.
	_wipe()
	_load_arena(2)
	var ronin := _hero("ronin", STAGE + Vector3(0, 0, -1), 0.0)
	soldier = _hero("soldier", STAGE + Vector3(-1.5, 0, 4), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(0, 0, 4.4), 0.0)
	captain = _hero("captain", STAGE + Vector3(1.5, 0, 4), 0.0)
	_dolly(STAGE + Vector3(-1.2, 1.4, -4.2), STAGE + Vector3(-0.6, 1.5, -3.6), STAGE + Vector3(0, 1.4, -1),
			STAGE + Vector3(0, 1.5, -1), 4.0, true)
	_say(ronin, "Vous faites trop de bruit.", 2.4, 1.0)
	var goblins: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0
		var spot := STAGE + Vector3(0, 0, -1) + Vector3(cos(angle), 0, sin(angle)) * 5.5
		var goblin := _enemy(spot, 0.0, &"walk")
		(goblin.get_parent() as Node3D).look_at(STAGE + Vector3(0, 0.1, -1))
		var inward := (STAGE + Vector3(0, 0, -1) - spot).normalized() * 0.7
		_move(goblin.get_parent() as Node3D, Vector3(inward.x, 0, inward.z))
		goblins.append(goblin)
	await _until(55.6)
	_dolly(STAGE + Vector3(0, 7.5, 6.0), STAGE + Vector3(0, 6.5, 4.0), STAGE + Vector3(0, 0, -1),
			STAGE + Vector3(0, 0, -1), 3.6, true)
	_say(soldier, "Attention, derrière toi !", 1.8, -1.0)
	await _until(57.4)
	# Whirlwind.
	ronin.play(&"melee", true)
	_ring(STAGE + Vector3(0, 0, -1), Color(1.0, 0.85, 0.9), 13.0, 0.5)
	_speed(1.2)
	_impact_frame()
	for goblin in goblins:
		_kill(goblin, &"leaves", Color(0.6, 1.0, 0.4))
	await _until(59.0)
	ronin.get_parent().rotation.y = PI
	_dolly(STAGE + Vector3(-6.5, 1.6, 1.5), STAGE + Vector3(-6.0, 1.6, 1.8), STAGE + Vector3(0, 1.3, 1.5),
			STAGE + Vector3(0, 1.3, 1.5), 5.0, true)
	_say(kunoichi, "On le garde.", 1.8, 1.0)
	await _until(61.2)
	_say(captain, "Bienvenue à bord !", 2.0, 1.0)
	await _until(63.6)

	# 63.6 s: the volcano. Four of them now, walking toward the city.
	_wipe()
	_load_arena(3)
	var squad := ["soldier", "kunoichi", "captain", "ronin"]
	for index in squad.size():
		var hero := _hero(squad[index], STAGE + Vector3(-3.0 + 2.0 * index, 0, -4), PI)
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, 0.6))
	_dolly(STAGE + Vector3(0, 0.3, 4.5), STAGE + Vector3(0, 0.35, 5.0), STAGE + Vector3(0, 2.4, -3),
			STAGE + Vector3(0, 2.4, -1), 8.0, false)
	_embers(true)
	_narrate("Quatre héros. Une seule cible.", 3.6)
	await _until(68.0)
	_narrate("Le Titan.", 2.6)
	await _until(71.6)
	_embers(false)

	# 71.6 s: the city. The Titan.
	_wipe()
	_load_arena(4)
	_titan = _spawn_titan(STAGE + Vector3(0, 0, -8))
	soldier = _hero("soldier", STAGE + Vector3(-1.5, 0, 3), 0.0)
	kunoichi = _hero("kunoichi", STAGE + Vector3(-0.5, 0, 3.6), 0.0)
	captain = _hero("captain", STAGE + Vector3(0.5, 0, 3.4), 0.0)
	ronin = _hero("ronin", STAGE + Vector3(1.5, 0, 3.2), 0.0)
	# Tilt up from its feet to its head.
	_dolly(STAGE + Vector3(-1, 0.4, 1.5), STAGE + Vector3(-1, 0.6, 1.0), STAGE + Vector3(0, 0.5, -8),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.9, -8), 4.2, true)
	await _until(74.0)
	_say(soldier, "C'est... énorme.", 2.0, -1.0)
	await _until(76.2)
	_titan.play(&"shoot", true)
	await _until(76.8)
	_stomp(STAGE + Vector3(0, 0, -8), 1.4)
	_impact_frame()
	_speed(1.0)
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.play(&"die", true)
	_dolly(STAGE + Vector3(4, 2.5, 8), STAGE + Vector3(3, 2.0, 7), STAGE + Vector3(0, 0.5, 3),
			STAGE + Vector3(0, 0.6, 3), 3.0, true)
	await _until(78.8)
	# Knocked down: they stay on their knees until they get up again.
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.freeze(&"die", 1.0)
	await _until(79.6)
	_dolly(STAGE + Vector3(-2.2, 0.6, 4.2), STAGE + Vector3(-2.0, 0.7, 3.9), STAGE + Vector3(-1.5, 0.5, 3),
			STAGE + Vector3(-1.5, 0.5, 3), 4.0, true)
	_say(soldier, "Je... je ne peux pas.", 2.4, 1.0)
	await _until(82.4)
	kunoichi.play(&"idle")
	_face(kunoichi, soldier)
	_dolly(STAGE + Vector3(-0.2, 1.4, 6.0), STAGE + Vector3(-0.4, 1.4, 5.2), STAGE + Vector3(-0.5, 1.3, 3.6),
			STAGE + Vector3(-0.5, 1.3, 3.6), 3.0, true)
	_say(kunoichi, "Debout ! On est une escouade !", 2.6, 1.0)
	await _until(85.4)
	captain.play(&"idle")
	ronin.play(&"idle")
	_say(captain, "Tous ensemble !", 1.8, -1.0)
	await _until(87.4)
	_say(ronin, "Maintenant.", 1.6, 1.0)
	await _until(89.2)
	soldier.play(&"idle")
	_face(kunoichi, _titan)
	_dolly(STAGE + Vector3(-1.5, 1.6, 0.9), STAGE + Vector3(-1.5, 1.6, 1.3), STAGE + Vector3(-1.5, 1.5, 3),
			STAGE + Vector3(-1.5, 1.6, 3), 2.6, false)
	_speed(2.6)
	_say(soldier, "OVERCLOCK !", 2.2, 1.0)
	await _until(91.8)

	# 91.8 s: all together.
	for hero: CharacterModel in [soldier, kunoichi, captain, ronin]:
		hero.play(&"aim")
	_dolly(STAGE + Vector3(0, 1.0, 8), STAGE + Vector3(0, 2.5, 6), STAGE + Vector3(0, 3, -8),
			STAGE + Vector3(0, TITAN_HEIGHT * 0.6, -8), 6.0, true)
	_speed(6.0)
	var colors := [CYAN, MAGENTA, GOLD, Color(1.0, 0.5, 0.8)]
	var heroes: Array[CharacterModel] = [soldier, kunoichi, captain, ronin]
	for beat in 14:
		await _until(92.0 + 0.32 * beat)
		var hero := heroes[beat % 4]
		hero.play(&"shoot", true)
		var target := _titan.global_position + Vector3(randf_range(-1.5, 1.5), randf_range(3.0, 8.0), 0)
		_beam(hero.global_position + Vector3(0, 1.3, -0.4), target, colors[beat % 4], 0.12)
		Effects.burst(_set, target, colors[beat % 4], 16)
	await _until(96.8)
	_impact_frame()
	_shake = 0.4
	Effects.flash(_set, _titan.global_position + Vector3.UP * 5, Color.WHITE, 30.0, 0.8)
	for index in 6:
		var at := _titan.global_position + Vector3(randf_range(-2, 2), randf_range(1, 8), randf_range(-1, 1))
		get_tree().create_timer(0.15 * index).timeout.connect(Effects.burst.bind(_set, at, GOLD, 50))
	await _until(97.8)
	_impact_frame()
	_fall(_titan, 2.4)
	_dolly(STAGE + Vector3(-6, 1.5, 6), STAGE + Vector3(-5, 2.5, 4), STAGE + Vector3(0, 4, -8),
			STAGE + Vector3(0, 1, -8), 3.6, true)
	await _until(101.4)

	# 101.4 s: victory.
	_wipe()
	var trophy := Trophy.new()
	_set.add_child(trophy)
	trophy.position = STAGE + Vector3(0, 0, -3)
	_ring(trophy.position, GOLD, 10.0, 0.9)
	for hero in heroes:
		hero.play(&"victory", true)
		hero.get_parent().rotation.y = PI
	_dolly(STAGE + Vector3(0, 1.3, 9.0), STAGE + Vector3(0, 1.6, 7.0), STAGE + Vector3(0, 1.4, 0),
			STAGE + Vector3(0, 1.6, -1), 7.0, true)
	await _until(102.6)
	_say(captain, "On a réussi !", 1.8, 1.0)
	await _until(104.6)
	_say(soldier, "Prochaine vague ?", 2.0, -1.0)
	await _until(106.8)
	for index in heroes.size():
		_say(heroes[index], "PROCHAINE VAGUE !", 2.2, -1.0 if index < 2 else 1.0)
	_speed(2.2)
	await _until(109.4)

	# 109.4 s: to be continued, then the end card.
	_shade.color = Color(0, 0, 0, 0)
	_fade_shade(0.85, 0.4)
	_narrate("À SUIVRE...", 3.0, true)
	await _until(112.8)
	_fade_shade(1.0, 0.5)
	await _until(113.4)
	_end_card()
