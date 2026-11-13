extends Season2Episode
## Épisode 17 : Mise à jour. In the volcano, the Directeur is back: the Virus
## has taken him, and a corrupted dragon with him. The heroes fight; Le
## Créateur frees the Directeur, who falls, himself again.


func _init() -> void:
	episode_number = 17
	episode_title = "MISE À JOUR"
	duration = 108.0


func _story() -> void:
	_load_arena(3)
	_embers(true)
	var soldier := _hero("soldier", STAGE + Vector3(-1.2, 0, 2.0), 0.0)
	var vipere := _hero("sand_ghost", STAGE + Vector3(1.2, 0, 2.2), 0.0)
	var paladin := _hero("paladin", STAGE + Vector3(-2.6, 0, 3.2), 0.0)
	var godfather := _hero("godfather", STAGE + Vector3(2.6, 0, 3.2), 0.0)
	var team := [soldier, vipere, paladin, godfather]
	_dolly(STAGE + Vector3(0, 1.4, -5), STAGE + Vector3(0, 1.6, -4), STAGE + Vector3(0, 1.4, 2.6), STAGE + Vector3(0, 1.4, 2.0), 7.0, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Le volcan. L'ancienne base du Directeur. Le deuxième fragment.", 3.4)
	await _until(5.4)
	_say(godfather, "Je connais ces couloirs. Il me doit toujours de l'argent.", 3.0, 1.0)
	await _until(8.6)
	await _title_card(5.0)

	# 13.6 s: the Directeur, out of his cell.
	_glitch(1.0)
	var directeur := _npc("Suit_Male.fbx", STAGE + Vector3(0, 0, -10), PI)
	directeur.get_parent().scale = Vector3.ONE * 1.6
	_corrupt(directeur)
	_appear(directeur)
	_dolly(STAGE + Vector3(1.4, 1.2, -5.0), STAGE + Vector3(1.0, 1.3, -5.6), STAGE + Vector3(0, 2.2, -10), STAGE + Vector3(0, 2.4, -10), 6.0, true)
	await _until(15.0)
	_narrate("Le Directeur. Évadé... et plus grand.", 2.8)
	await _until(18.2)
	_say(directeur, "MISE À JOUR... TERMINÉE.", 2.6, 1.0, 3.2)
	await _until(21.2)
	_dolly(STAGE + Vector3(-3, 1.5, 5.6), STAGE + Vector3(-2.6, 1.5, 5.0), STAGE + Vector3(0, 1.4, 2.4), STAGE + Vector3(0, 1.4, 2.4), 4.0, true)
	_say(paladin, "Sa voix... ce n'est plus lui.", 2.2, -1.0)
	await _until(23.8)
	_say(vipere, "Le Virus le porte comme un costume.", 2.4, 1.0)
	await _until(26.6)

	# 26.6 s: the dragon.
	var dragon := _spawn_boss(Boss.Kind.COLOSSUS, STAGE + Vector3(-6, 0, -14), 4.5)
	_corrupt(dragon)
	_rise(dragon, 6.0, 2.2)
	_shake = 0.3
	_dolly(STAGE + Vector3(2, 0.8, 0), STAGE + Vector3(1.5, 0.6, -1), STAGE + Vector3(-4, 3, -12), STAGE + Vector3(-5, 4.5, -14), 3.0, true)
	await _until(29.0)
	_stomp(STAGE + Vector3(-6, 0, -14), 1.0)
	_impact_frame()
	for hero in team:
		hero.play(&"aim")
	await _until(30.4)

	# 30.4 s: the fight.
	_dolly(STAGE + Vector3(0, 4, 9), STAGE + Vector3(0, 4.5, 8), STAGE + Vector3(-3, 3, -12), STAGE + Vector3(-3, 3.5, -12), 7.0, true)
	for round in 3:
		for hero: CharacterModel in team:
			hero.play(&"shoot", true)
			_beam(hero.global_position + Vector3.UP * 1.3, dragon.global_position + Vector3(randf_range(-1, 1), randf_range(2, 5), 0),
					[CYAN, RED, GOLD, Color(0.9, 0.9, 1.0)][team.find(hero)], 0.08)
			await _until(_clock + 0.16)
	_say(godfather, "Il encaisse tout !", 1.8, 1.0)
	await _until(35.0)
	dragon.play(&"shoot", true)
	_ring(STAGE + Vector3(0, 0.2, -2), Color(1.0, 0.5, 0.2), 16.0, 0.7)
	for hero in team:
		hero.play(&"die", true)
	_impact_frame()
	_shake = 0.3
	await _until(37.8)
	_say(directeur, "EFFACEMENT DES ANOMALIES.", 2.4, 1.0, 3.2)
	await _until(40.6)

	# 40.6 s: Le Créateur.
	var creator := _creator(STAGE + Vector3(0, 0, -2), PI, "source_code")
	_appear(creator)
	_dolly(STAGE + Vector3(-2.6, 1.2, 1.6), STAGE + Vector3(-2.2, 1.3, 1.0), STAGE + Vector3(0, 1.6, -2), STAGE + Vector3(0, 1.6, -2), 4.0, true)
	await _until(42.0)
	_say(creator, "Laisse-le partir.", 2.0, -1.0)
	await _until(44.4)
	_face(creator, dragon)
	creator.play(&"shoot", true)
	_beam(creator.global_position + Vector3.UP * 1.4, dragon.global_position + Vector3.UP * 3.0, VIRUS, 0.2)
	_ring(dragon.global_position + Vector3.UP * 2.0, VIRUS, 12.0, 0.6)
	_impact_frame()
	_vanish(dragon, 0.8)
	await _until(46.6)
	_face(creator, directeur)
	creator.play(&"shoot", true)
	_beam(creator.global_position + Vector3.UP * 1.4, directeur.global_position + Vector3.UP * 2.0, VIRUS, 0.12)
	_glitch(1.2)
	_dolly(STAGE + Vector3(1.4, 1.2, -5.0), STAGE + Vector3(1.0, 1.3, -5.6), STAGE + Vector3(0, 2.2, -10), STAGE + Vector3(0, 1.0, -10), 4.0, true)
	await _until(48.0)
	# The Virus lets go: the Directeur is himself again, and collapses.
	for mesh: MeshInstance3D in directeur.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = null
	create_tween().tween_property(directeur.get_parent(), "scale", Vector3.ONE, 0.8)
	directeur.play(&"die", true)
	await _until(50.4)
	_say(directeur, "Je... je ne contrôlais rien. Il était dans ma tête.", 3.0, 1.0)
	await _until(54.0)

	# 54 s: the second fragment.
	for hero in team:
		hero.play(&"idle")
	_dolly(STAGE + Vector3(3, 1.6, 4.0), STAGE + Vector3(2.6, 1.6, 3.6), STAGE + Vector3(0, 1.4, 0.4), STAGE + Vector3(0, 1.4, 0.4), 10.0, true)
	_face(soldier, creator)
	_face(creator, soldier)
	_say(soldier, "Le deuxième fragment ?", 1.8, -1.0)
	await _until(56.4)
	var fragment := STAGE + Vector3(0, 1.4, -6)
	_ring(fragment, VIRUS, 6.0, 0.6)
	Effects.burst(_set, fragment, VIRUS, 60)
	_say(creator, "Il était dans le Directeur. Le Virus s'en servait.", 3.0, 1.0)
	await _until(60.0)
	_narrate("Deuxième fragment : récupéré.", 2.8, true)
	await _until(63.4)
	_say(godfather, "Et mon argent ?", 1.6, -1.0)
	await _until(65.4)
	_say(creator, "Je peux l'écrire, si tu veux.", 2.2, 1.0)
	await _until(68.0)
	_say(godfather, "... Non. Ce serait de la triche.", 2.4, -1.0)
	await _until(71.0)
	_glitch(1.4)
	_impact_frame()
	await _until(72.6)
	_say(creator, "La station. Il sait qu'on arrive.", 2.4, 1.0)
	await _until(75.6)
	_vanish(creator)
	_embers(false)
	await _until(77.0)
	await _to_be_continued(94.0)
