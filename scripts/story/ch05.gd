extends StoryScene
## Chapitre 5 : Le désert des secrets. Calamity leads the squad to the
## Directeur's temple; its guardian wakes up.


func _init() -> void:
	episode_number = 5
	episode_title = "LE DÉSERT DES SECRETS"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(1)
	_fade_shade(0.0, 0.6)
	var calamity := _hero("cowgirl", STAGE + Vector3(0, 0, 1.0), 0.0)
	var soldier := _hero("soldier", STAGE + Vector3(-1.6, 0, 2.2), 0.0)
	var captain := _hero("captain", STAGE + Vector3(1.6, 0, 2.2), 0.0)
	for hero in [calamity, soldier, captain]:
		hero.play(&"walk", true)
		_move(hero.get_parent() as Node3D, Vector3(0, 0, -0.4))
	_dolly(STAGE + Vector3(1.5, 1.8, -9), STAGE + Vector3(1.0, 1.8, -8), STAGE + Vector3(0, 1.3, 1),
			STAGE + Vector3(0, 1.3, -2), 6.0, true)
	_narrate("Le badge mène au désert. Calamity connaît le chemin.", 3.4)
	await _until(6.6)
	_say(calamity, "Le temple du Directeur est derrière la dune.", 2.6, 1.0)
	await _until(9.6)
	_say(captain, "Et c'est gardé ?", 1.8, -1.0)
	await _until(11.8)
	_say(calamity, "Un peu. Par un squelette. Géant.", 2.4, 1.0)
	await _until(14.6)
	for hero in [calamity, soldier, captain]:
		_movers.clear()
		hero.play(&"aim")
	var skeleton := _spawn_boss(Boss.Kind.BRUTE, STAGE + Vector3(0, 0, -10), 3.6)
	_rise(skeleton, 4.0, 2.0)
	_dolly(STAGE + Vector3(3, 0.8, -2), STAGE + Vector3(2, 0.6, -3), STAGE + Vector3(0, 2, -10),
			STAGE + Vector3(0, 3.4, -10), 3.0, true)
	_shake = 0.25
	await _until(16.8)
	_impact_frame()
	_stomp(STAGE + Vector3(0, 0, -10), 1.0)
	await _until(18.0)
	_dolly(STAGE + Vector3(-1.5, 1.6, 4.5), STAGE + Vector3(-1.2, 1.6, 3.8), STAGE + Vector3(0, 1.5, 0),
			STAGE + Vector3(0, 1.5, 0), 5.0, true)
	_say(soldier, "« Un peu » ?", 1.6, -1.0)
	await _until(20.0)
	_say(calamity, "Bouchez-vous les oreilles !", 2.2, 1.0)
	await _until(22.6)
	_narrate("MISSION : traverse le désert et abats le gardien du temple.", 3.8)
	await _until(28.6)
	_fade_shade(1.0, 1.0)
