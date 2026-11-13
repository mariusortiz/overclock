extends Season3Episode
## Épisode 26 : L'Archive. The arch projects a hologram: the First Coder, a cow,
## "version 0". He built this galaxy, forgot it, and left by the portal; Le
## Créateur is his copy. The golems wake and attack; the squad brings them
## down. The last words of the archive: the key is on the moon where time loops.


func _init() -> void:
	episode_number = 26
	episode_title = "L'ARCHIVE"
	duration = 85.0


const ARCH := Vector3(0, 0.1, -26)


func _story() -> void:
	_load_world("ruins")
	_moons()
	_statue(ARCH + Vector3(0, 10.6, 0), PI, 4.0)
	var door := _portal(ARCH + Vector3(0, 4.5, 0.4), 3.6)
	var heroes := _squad(ARCH + Vector3(0, 0, 9), 0.0, SQUAD, 1.4, true)
	var creator := _creator(ARCH + Vector3(0, 0, 6.2), 0.0)
	_dolly(ARCH + Vector3(-5, 2, 16), ARCH + Vector3(-3, 2, 13), ARCH + Vector3(0, 3, 0), ARCH + Vector3(0, 4, 0), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.5)
	_narrate("Devant l'arche. Le portail tourne, sans s'ouvrir.", 3.0)
	await _until(5.0)
	_say(creator, "Il attend quelque chose. Quelqu'un.", 2.4, 1.0)
	await _until(7.8)
	await _title_card(5.0)

	# 12.8 s: the hologram.
	var ghost := _actor(load(Loadout.CHARACTER_DIR + "Cow.fbx"), 3.2, ARCH + Vector3(0, 0.6, 2.2), PI)
	_tint(ghost, CRYSTAL)
	_appear(ghost, 1.0)
	_dolly(ARCH + Vector3(5.5, 2.6, 12), ARCH + Vector3(4.8, 2.6, 11.4), ARCH + Vector3(0, 2.4, 2.2), ARCH + Vector3(0, 2.6, 2.2), 8.0)
	await _until(14.4)
	_narrate("Une vache de lumière. Plus grande. Plus vieille.", 3.0)
	await _until(17.6)
	_say(ghost, "Version 0. Archive du Premier Codeur.", 2.6, 1.0, 3.4)
	await _until(20.6)
	_say(ghost, "J'ai écrit cette galaxie. Les cristaux, les pierres, les lunes.", 3.2, 1.0, 3.4)
	await _until(24.2)
	_say(ghost, "Puis j'ai tout oublié... et je suis parti par la porte.", 3.0, 1.0, 3.4)
	await _until(27.6)
	_say(ghost, "De l'autre côté, je me suis réécrit. Version 1.", 3.0, 1.0, 3.4)
	await _until(31.0)

	# 31 s: Le Créateur understands.
	_dolly(ARCH + Vector3(1.0, 1.7, 7.9), ARCH + Vector3(0.8, 1.7, 7.7), creator.global_position + Vector3.UP * 1.55,
			creator.global_position + Vector3.UP * 1.55, 8.0)
	creator.get_parent().rotation.y = PI
	await _until(31.6)
	_say(creator, "Version 1... C'est moi.", 2.2, 1.0)
	await _until(34.2)
	_say(creator, "Je ne suis pas le premier. Je suis une copie.", 2.8, 1.0)
	await _until(37.4)
	_say(heroes.soldier, "Copie ou pas, t'es notre vache.", 2.2, -1.0)
	await _until(40.0)
	_say(heroes.sand_ghost, "Et une copie qui doit encore me battre.", 2.4, 1.0)
	await _until(42.8)

	# 42.8 s: the golems.
	_vanish(ghost, 0.6)
	_shake = 0.35
	var golems: Array[CharacterModel] = []
	for at in [Vector3(-9, 0.1, -3), Vector3(9, 0.1, -3), Vector3(4, 0.1, -1)]:
		var golem := _golem(at, 0.0, 4.4)
		# The skeleton's face is on its +Z side: it turns its back to what it looks at, then around.
		golem.get_parent().look_at(Vector3(0, at.y, -17))
		golem.get_parent().rotate_y(PI)
		_rise(golem, 4.0, 1.6)
		golems.append(golem)
	creator.get_parent().rotation.y = 0.0
	_dolly(ARCH + Vector3(1.2, 2.2, 5.8), ARCH + Vector3(0.8, 2.4, 5.2), ARCH + Vector3(2, 2.4, 22), ARCH + Vector3(2, 2.6, 23), 5.0)
	await _until(44.4)
	_say(heroes.paladin, "Les gardiens de l'archive !", 2.0, -1.0)
	await _until(46.6)
	for golem in golems:
		golem.play(&"walk")
	_say(heroes.soldier, "Visez les yeux !", 1.6, 1.0)
	await _until(48.6)

	# 48.6 s: the fight.
	var shooters := ["soldier", "cowgirl", "captain"]
	for index in golems.size():
		var golem := golems[index]
		var hero: CharacterModel = heroes[shooters[index]]
		hero.get_parent().look_at(Vector3(golem.global_position.x, hero.global_position.y, golem.global_position.z))
		_dolly(hero.global_position + Vector3(0.8, 1.8, 3), hero.global_position + Vector3(0.6, 1.8, 2.4),
				golem.global_position + Vector3.UP * 3.6, golem.global_position + Vector3.UP * 3.6, 2.4)
		for shot in 3:
			hero.play(&"shoot", true)
			_beam(hero.global_position + Vector3(0, 1.3, 0), golem.global_position + Vector3.UP * 3.8, GOLD, 0.06)
			Effects.burst(_set, golem.global_position + Vector3.UP * 3.8, STONE, 20)
			await _until(_clock + 0.4)
		await _until(_clock + 0.6)
	# The Paladin finishes them.
	var paladin: CharacterModel = heroes.paladin
	_dolly(Vector3(-14, 4, -12), Vector3(-13, 4.4, -10), Vector3(2, 2, -3), Vector3(2, 2, -2), 6.0)
	_impact_frame()
	_say(paladin, "Pour l'escouade !", 1.6, -1.0)
	for golem in golems:
		_beam(golem.global_position + Vector3(-2, 3, 0), golem.global_position + Vector3(2, 0.5, 0), Color.WHITE, 0.08)
		_fall(golem, 1.0)
		await _until(_clock + 0.4)
	await _until(61.0)
	_narrate("Trois tas de pierres. Et le silence revient.", 2.8)
	await _until(64.0)

	# 64 s: the archive's last words.
	_appear(ghost, 0.6)
	_dolly(ARCH + Vector3(5.5, 2.6, 12), ARCH + Vector3(5.0, 2.6, 11.4), ARCH + Vector3(0, 2.6, 2.2), ARCH + Vector3(0, 2.6, 2.2), 8.0)
	await _until(64.8)
	_say(ghost, "Pour rouvrir la porte, il faut la clé.", 2.6, 1.0, 3.4)
	await _until(67.8)
	_say(ghost, "Je l'ai cachée sur la lune où le temps tourne en rond.", 3.2, 1.0, 3.4)
	await _until(71.4)
	_vanish(ghost, 0.8)
	_say(heroes.captain, "Une lune où le temps tourne en rond. Super.", 2.6, -1.0)
	await _until(74.4)
	await _to_be_continued(74.8)
