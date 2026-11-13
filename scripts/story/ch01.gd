extends StoryScene
## Chapitre 1 : L'escouade. The Soldier holds the station alone, until the
## Kunoichi drops in.


func _init() -> void:
	episode_number = 1
	episode_title = "L'ESCOUADE"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var soldier := _hero("soldier", STAGE, 0.0)
	soldier.play(&"aim")
	var guards: Array[Enemy] = []
	for index in 4:
		guards.append(_enemy(STAGE + Vector3(-3.0 + 2.0 * index, 0, -9.0 - 1.2 * (index % 2)), PI, &"walk"))
		_move(guards[index].get_parent() as Node3D, Vector3(0, 0, 0.5))
	_dolly(STAGE + Vector3(1.6, 1.5, 2.6), STAGE + Vector3(1.2, 1.7, 2.0), STAGE + Vector3(0, 1.4, -6),
			STAGE + Vector3(0, 1.3, -6), 4.0, true)
	_narrate("La station. Un soldat, seul contre la garde du Directeur.", 3.4)
	await _until(6.4)
	_say(soldier, "Encore une vague.", 2.2, -1.0)
	await _until(8.8)
	_dolly(STAGE + Vector3(-5, 1.0, -1), STAGE + Vector3(-4.2, 1.2, -2.5), STAGE + Vector3(0, 1.2, -6),
			STAGE + Vector3(0, 1.2, -6), 3.0, true)
	for index in 2:
		await _until(9.0 + 0.6 * index)
		_shoot(soldier, guards[index], &"knockback", CYAN)
	await _until(11.0)
	var sneaky := _enemy(STAGE + Vector3(1.5, 0, 2.8), 0.0, &"aim")
	_dolly(STAGE + Vector3(4, 1.2, 4.5), STAGE + Vector3(3.4, 1.3, 4.0), STAGE + Vector3(0.6, 1.3, 1.2),
			STAGE + Vector3(0.6, 1.3, 1.2), 2.4, true)
	_say(soldier, "...!", 1.0, 1.0)
	await _until(12.2)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(2.2, 6.0, 2.2), PI * 0.75)
	_drop(kunoichi.get_parent() as Node3D, STAGE.y, 0.35)
	await _until(12.6)
	kunoichi.play(&"melee", true)
	_impact_frame()
	_speed(0.6)
	_kill(sneaky, &"petals", Color(1.0, 0.5, 0.8))
	_shake = 0.15
	await _until(13.4)
	_face(soldier, kunoichi)
	_face(kunoichi, soldier)
	_dolly(STAGE + Vector3(4.2, 1.6, -1.0), STAGE + Vector3(3.6, 1.5, -0.6), STAGE + Vector3(1.1, 1.4, 1.1),
			STAGE + Vector3(1.1, 1.4, 1.1), 7.0, true)
	_say(kunoichi, "Besoin d'aide, soldat ?", 2.4, 1.0)
	await _until(16.2)
	_say(soldier, "Je travaille seul.", 2.0, -1.0)
	await _until(18.6)
	_say(kunoichi, "Plus maintenant.", 2.0, 1.0)
	await _until(21.0)
	soldier.play(&"aim")
	kunoichi.play(&"aim")
	_face(soldier, guards[3])
	_face(kunoichi, guards[3])
	_dolly(STAGE + Vector3(-1.5, 2.8, 7.5), STAGE + Vector3(-1.0, 2.5, 6.5), STAGE + Vector3(0.5, 1.2, -3),
			STAGE + Vector3(0.5, 1.2, -5), 5.0, true)
	_say(soldier, "Alors on tient la station. Ensemble.", 2.6, -1.0)
	await _until(24.4)
	_narrate("MISSION : tiens la station, puis abats son boss.", 4.0)
	await _until(28.6)
	_fade_shade(1.0, 1.2)
