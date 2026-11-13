extends Season3Episode
## Épisode 25 : Les Ruines stellaires. The ships land among the columns. On
## top of the portal arch stands a gold statue: a cow. The glyphs name him the
## First Coder, gone by the door. The arch wakes; something stirs in the stone.


func _init() -> void:
	episode_number = 25
	episode_title = "LES RUINES STELLAIRES"
	duration = 79.0


const ARCH := Vector3(0, 0.1, -26)


func _story() -> void:
	_load_world("ruins")
	_moons()
	var statue := _statue(ARCH + Vector3(0, 10.6, 0), PI, 4.0)
	var gold := _parked_ship(GOLD, STAGE + Vector3(-9, 6, 2), 0.3)
	var red := _parked_ship(RED, STAGE + Vector3(9, 6, 1), -0.3)
	_fly_to(gold, STAGE + Vector3(-30, 20, 20), STAGE + Vector3(-9, 0.6, 2), 3.0)
	_fly_to(red, STAGE + Vector3(30, 22, 20), STAGE + Vector3(9, 0.6, 1), 3.4)
	_dolly(STAGE + Vector3(0, 3, 12), STAGE + Vector3(0, 2.4, 9), STAGE + Vector3(0, 4, -4), STAGE + Vector3(0, 1.4, 0), 6.0)
	_fade_shade(0.0, 1.0)
	await _until(1.5)
	_narrate("Les ruines. Personne depuis des siècles.", 2.8)
	await _until(4.6)
	_stomp(STAGE + Vector3(0, 0, 1), 0.4)
	await _until(5.2)
	var heroes := _squad(STAGE + Vector3(0, 0, 2), 0.0)
	var creator := _creator(STAGE + Vector3(0, 0, 3.6), 0.0)
	_say(heroes.captain, "Atterrissage parfait. Presque.", 2.0, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: the walk among the columns.
	for hero in heroes.values():
		_move(hero.get_parent(), Vector3(0, 0, -0.9))
		(hero as CharacterModel).play(&"walk")
	_move(creator.get_parent(), Vector3(0, 0, -0.9))
	creator.play(&"walk")
	_dolly(STAGE + Vector3(-6, 1.6, -2), STAGE + Vector3(-5, 1.8, -6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, -2), 8.0)
	await _until(13.4)
	_say(heroes.paladin, "Ces colonnes... on dirait une salle du trône.", 2.6, -1.0)
	await _until(16.4)
	_say(heroes.cowgirl, "Ou un hangar très chic.", 1.8, 1.0)
	await _until(18.6)
	_dolly(Vector3(-12, 2.6, 6), Vector3(-12.6, 2.4, 5), Vector3(-17, 1.2, 0), Vector3(-17, 1.2, 0), 6.0)
	_narrate("Partout, des signes qui brillent d'or.", 2.8)
	await _until(21.6)
	_movers.clear()
	for hero in heroes.values():
		(hero as CharacterModel).play(&"idle")
	creator.play(&"idle")

	# 21.6 s: the statue.
	_dolly(STAGE + Vector3(1.5, 3.4, -2), STAGE + Vector3(1.5, 3.2, -3), STAGE + Vector3(0, 2, -14), ARCH + Vector3(0, 12, 0), 5.0)
	await _until(23.6)
	_say(heroes.kunoichi, "Là-haut. Sur l'arche.", 1.8, 1.0)
	await _until(26.0)
	_dolly(ARCH + Vector3(-4, 10, 10), ARCH + Vector3(-2.6, 11.4, 7), ARCH + Vector3(0, 12, 0), ARCH + Vector3(0, 12.4, 0), 5.0)
	_impact_frame()
	_narrate("Une statue d'or. Une tête de vache.", 2.8, true)
	await _until(30.0)
	_dolly(STAGE + Vector3(1.6, 1.6, -7.6), STAGE + Vector3(1.2, 1.6, -8.0), creator.global_position + Vector3.UP * 1.5,
			creator.global_position + Vector3.UP * 1.5, 7.0)
	_say(heroes.sand_ghost, "C'est... toi ?", 1.6, -1.0)
	await _until(32.4)
	_say(creator, "Je n'ai jamais mis les pieds ici.", 2.2, 1.0)
	await _until(35.0)
	_say(creator, "Je crois.", 1.4, 1.0)
	await _until(37.0)

	# 37 s: the glyphs.
	var kunoichi: CharacterModel = heroes.kunoichi
	var glyph := Vector3(9, 0.1, -20)
	_wipe()
	var pivot := kunoichi.get_parent() as Node3D
	pivot.position = glyph + Vector3(-1.4, 0, 1.6)
	pivot.look_at(Vector3(glyph.x, pivot.position.y, glyph.z))
	kunoichi.play(&"idle")
	_dolly(glyph + Vector3(2.6, 1.9, 4.6), glyph + Vector3(2.2, 1.9, 4.0), glyph + Vector3(-0.6, 1.3, 0.6), glyph + Vector3(-0.6, 1.3, 0.6), 12.0)
	await _until(40.0)
	_say(kunoichi, "Mon clan lisait ce genre de signes.", 2.4, 1.0)
	await _until(43.0)
	_say(kunoichi, "« Le Premier Codeur. Il a écrit les étoiles. »", 3.0, 1.0)
	await _until(46.4)
	_say(kunoichi, "« Puis il est parti par la porte. »", 2.4, 1.0)
	await _until(49.4)
	_dolly(STAGE + Vector3(-1.6, 1.6, -7.6), STAGE + Vector3(-1.2, 1.6, -8.0), creator.global_position + Vector3.UP * 1.5,
			creator.global_position + Vector3.UP * 1.5, 6.0)
	_say(heroes.soldier, "La porte. L'arche ?", 1.8, 1.0)
	await _until(51.6)
	_say(creator, "Un portail. Comme celui qui nous a amenés.", 2.6, -1.0)
	await _until(54.6)

	# 54.6 s: the arch wakes.
	var door := _portal(ARCH + Vector3(0, 4.5, 0.4), 3.6)
	_open(door, 1.4)
	_dolly(STAGE + Vector3(2, 4.0, -1), STAGE + Vector3(2, 4.4, -3), ARCH + Vector3(0, 4.5, 0), ARCH + Vector3(0, 5, 0), 6.0)
	_narrate("L'arche s'allume.", 2.4)
	await _until(57.6)
	_say(heroes.ronin, "Le chemin du retour ?", 1.8, 1.0)
	await _until(60.0)
	_say(creator, "Ou le chemin vers ce qu'il a laissé.", 2.4, -1.0)
	await _until(63.0)

	# 63 s: the stone stirs.
	_shake = 0.3
	_dolly(Vector3(-17, 1.2, 10), Vector3(-17.6, 1.6, 9), Vector3(-24, 2, 2), Vector3(-24, 3, 2), 5.0)
	var golem := _golem(Vector3(-24, 0.1, 2), 0.0, 4.4)
	# The skeleton's face is on its +Z side.
	golem.get_parent().look_at(Vector3(-30, 0.1, -6))
	_rise(golem, 4.0, 2.0)
	await _until(65.0)
	_narrate("Dans la pierre, deux yeux d'or s'ouvrent.", 3.0, true)
	await _until(68.6)
	await _to_be_continued(69.0)
