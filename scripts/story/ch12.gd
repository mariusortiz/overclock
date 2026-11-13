extends Season2Scene
## Chapitre 12 : Le message. Corrupted guards corner the Kunoichi at the
## station; Le Créateur deletes them with a gesture and leaves a message.


func _init() -> void:
	episode_number = 12
	episode_title = "LE MESSAGE"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0, 0, 3.0), PI)
	var guards: Array[Enemy] = []
	for index in 3:
		guards.append(_corrupted(STAGE + Vector3(-2.4 + 2.4 * index, 0, 6.5), 0.0, &"aim"))
	_dolly(STAGE + Vector3(0.7, 1.5, 5.6), STAGE + Vector3(0.4, 1.5, 5.0), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 5.0, true)
	_narrate("La station. Tous les écrans affichent du code.", 3.0)
	_glitch(0.8)
	await _until(6.6)
	_say(kunoichi, "Trois. Et ils ne tombent pas.", 2.4, 1.0)
	await _until(9.4)
	_dolly(STAGE + Vector3(3.5, 1.4, 1.0), STAGE + Vector3(3.0, 1.4, 1.8), STAGE + Vector3(0, 1.2, 5),
			STAGE + Vector3(0, 1.2, 5), 3.0, true)
	_narrate("Ils se rapprochent.", 1.8)
	await _until(12.4)
	var creator := _creator(STAGE + Vector3(0, 0, 0.6), PI)
	_appear(creator)
	_dolly(STAGE + Vector3(1.8, 1.6, 2.6), STAGE + Vector3(1.3, 1.7, 2.2), STAGE + Vector3(0, 1.6, 0.6),
			STAGE + Vector3(0, 1.7, 0.6), 4.0, true)
	await _until(13.6)
	_say(creator, "Supprimer.", 1.6, -1.0)
	creator.play(&"melee")
	_glitch(0.6)
	for guard in guards:
		_kill(guard, &"pixelate", VIRUS)
	_impact_frame()
	await _until(16.0)
	# She turns to him: seen from his side.
	create_tween().tween_property(kunoichi.get_parent(), "rotation:y", 0.0, 0.5)
	_dolly(STAGE + Vector3(-1.8, 1.6, -1.6), STAGE + Vector3(-1.4, 1.6, -1.0), STAGE + Vector3(0, 1.5, 1.8),
			STAGE + Vector3(0, 1.5, 1.8), 6.0, true)
	_say(kunoichi, "Une tête de vache. Sérieusement ?", 2.4, 1.0)
	await _until(18.8)
	_say(creator, "Ne le laissez pas grandir.", 2.4, -1.0)
	await _until(21.6)
	_vanish(creator)
	_glitch(0.5)
	await _until(22.6)
	_narrate("MISSION : la station est infestée. Repousse les gardes corrompus.", 4.2)
	await _until(27.6)
	_fade_shade(1.0, 1.0)
