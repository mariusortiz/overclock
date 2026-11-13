extends Season2Episode
## Épisode 16 : Code source. In the jungle, the Ronin and the Kunoichi look
## for the first fragment; corrupted goblins and a corrupted royal slime guard
## it. Le Créateur shows them what "root access" means.


func _init() -> void:
	episode_number = 16
	episode_title = "CODE SOURCE"
	duration = 108.0


func _story() -> void:
	_load_arena(2)
	var ronin := _hero("ronin", STAGE + Vector3(-1.0, 0, 2.0), 0.0)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(1.0, 0, 2.2), 0.0)
	for hero in [ronin, kunoichi]:
		hero.play(&"walk", true)
		_move(hero.get_parent() as Node3D, Vector3(0, 0, -0.4))
	_dolly(STAGE + Vector3(1.5, 1.8, -8), STAGE + Vector3(1.0, 1.8, -7), STAGE + Vector3(0, 1.3, 2), STAGE + Vector3(0, 1.3, 0), 7.0, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("La jungle. Le premier fragment est quelque part ici.", 3.2)
	await _until(5.2)
	_say(kunoichi, "Tu sens ? L'air grésille.", 2.2, 1.0)
	await _until(8.0)
	_movers.clear()
	await _title_card(5.0)

	# 13 s: the fragment, guarded.
	var fragment := STAGE + Vector3(0, 1.4, -10)
	_ring(fragment, VIRUS, 2.0, 2.5)
	_dolly(STAGE + Vector3(0, 2.0, -4), STAGE + Vector3(0, 2.2, -5), fragment, fragment, 4.0, true)
	_narrate("Le fragment : une ligne de code propre, qui brille.", 3.0)
	await _until(16.4)
	_glitch(1.0)
	var goblins: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0
		var goblin := _corrupted(STAGE + Vector3(cos(angle) * 6.0, 0, -6.0 + sin(angle) * 4.0), 0.0, &"walk")
		_appear(goblin, 0.4)
		goblins.append(goblin)
	var slime := _spawn_boss(Boss.Kind.SUMMONER, STAGE + Vector3(0, 0, -13), 3.0)
	_corrupt(slime)
	for hero in [ronin, kunoichi]:
		hero.play(&"aim")
	_dolly(STAGE + Vector3(0, 7, 6), STAGE + Vector3(0, 8, 5), STAGE + Vector3(0, 0, -6), STAGE + Vector3(0, 0, -7), 4.0, true)
	await _until(18.4)
	_say(ronin, "Des gobelins. Et le slime royal... corrompu.", 2.8, -1.0)
	await _until(21.6)

	# 21.6 s: the fight.
	_dolly(STAGE + Vector3(3, 1.4, 3), STAGE + Vector3(2.6, 1.4, 2.6), STAGE + Vector3(0, 1.2, -4), STAGE + Vector3(0, 1.2, -4), 6.0, true)
	for index in 4:
		var hero := ronin if index % 2 == 0 else kunoichi
		hero.play(&"melee", true)
		_slash(goblins[index], &"pixelate", VIRUS)
		_impact_frame()
		await _until(_clock + 0.6)
	_speed(1.0)
	await _until(25.0)
	for index in 2:
		var again := _corrupted(STAGE + Vector3(-3 + 6 * index, 0, -4), 0.0, &"walk")
		_appear(again, 0.4)
		goblins.append(again)
	_say(kunoichi, "Ils se recopient encore !", 2.0, 1.0)
	await _until(27.6)
	slime.play(&"shoot", true)
	_stomp(STAGE + Vector3(0, 0, -10), 1.0)
	for hero in [ronin, kunoichi]:
		hero.play(&"die", true)
	_impact_frame()
	await _until(30.0)

	# 30 s: Le Créateur, and root access.
	var creator := _creator(STAGE + Vector3(0, 0, 0.5), PI, "source_code")
	_appear(creator)
	_dolly(STAGE + Vector3(-2, 1.0, 4), STAGE + Vector3(-1.6, 1.2, 3.4), STAGE + Vector3(0, 1.6, 0.5), STAGE + Vector3(0, 1.6, 0.5), 4.0, true)
	await _until(31.4)
	_say(creator, "Regardez bien. C'est ça, un accès root.", 2.8, -1.0)
	await _until(34.6)
	_face(creator, slime)
	creator.play(&"shoot", true)
	_narrate("ACCÈS ROOT", 1.6, true)
	_ring(STAGE + Vector3(0, 0.3, -6), VIRUS, 26.0, 0.9)
	_impact_frame()
	_speed(1.5)
	for goblin in goblins:
		if is_instance_valid(goblin):
			_kill(goblin, &"pixelate", VIRUS)
	_glitch(0.8)
	_dolly(STAGE + Vector3(0, 6, 8), STAGE + Vector3(0, 7, 7), STAGE + Vector3(0, 1, -8), STAGE + Vector3(0, 2, -12), 4.0, true)
	await _until(37.0)
	_fall(slime, 1.4)
	await _until(40.0)
	_narrate("Effacés. Jusqu'au dernier octet.", 2.6)
	await _until(43.0)

	# 43 s: the lesson.
	for hero in [ronin, kunoichi]:
		hero.play(&"idle")
		_face(hero, creator)
	_face(creator, ronin)
	_dolly(STAGE + Vector3(2.6, 1.6, 4.0), STAGE + Vector3(2.2, 1.6, 3.6), STAGE + Vector3(0, 1.4, 1.2), STAGE + Vector3(0, 1.4, 1.2), 12.0, true)
	_say(ronin, "Apprends-moi.", 1.8, 1.0)
	await _until(45.4)
	_say(creator, "Ce n'est pas un secret de sabre. C'est une clé.", 2.8, -1.0)
	await _until(48.6)
	_say(creator, "Et je n'en ai qu'une.", 2.0, -1.0)
	await _until(51.0)
	_say(kunoichi, "Alors pourquoi ne pas effacer le Virus toi-même ?", 2.8, 1.0)
	await _until(54.2)
	_say(creator, "Parce qu'il se cache dans mon code. M'en servir contre lui, c'est lui ouvrir la porte.", 3.8, -1.0)
	await _until(58.6)

	# 58.6 s: the fragment.
	_dolly(STAGE + Vector3(0, 1.6, -6.5), STAGE + Vector3(0, 1.6, -7.4), fragment, fragment, 6.0, true)
	kunoichi.play(&"walk", true)
	_move(kunoichi.get_parent() as Node3D, Vector3(0, 0, -1.6))
	await _until(62.0)
	_movers.clear()
	kunoichi.play(&"victory", true)
	_ring(fragment, VIRUS, 6.0, 0.6)
	Effects.burst(_set, fragment, VIRUS, 60)
	_impact_frame()
	_narrate("Premier fragment : récupéré.", 2.8, true)
	await _until(66.0)
	_dolly(STAGE + Vector3(2.6, 1.6, 4.0), STAGE + Vector3(2.2, 1.6, 3.6), STAGE + Vector3(0, 1.4, 1.2), STAGE + Vector3(0, 1.4, 1.2), 8.0, true)
	_say(creator, "Il en reste deux. Le volcan, maintenant.", 2.6, -1.0)
	await _until(69.2)
	_glitch(1.0)
	_say(creator, "... Et quelqu'un vous y attend.", 2.4, -1.0)
	await _until(72.2)
	_vanish(creator)
	await _until(73.6)
	await _to_be_continued(94.0)
