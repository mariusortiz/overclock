extends Season3Scene
## Chapitre 28 : Écarlate. Brutus, Hex and Colt, back; the two squads together.


func _init() -> void:
	episode_number = 28
	episode_title = "ÉCARLATE"
	duration = 25.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(1)
	_night_sky()
	_fade_shade(0.0, 0.6)
	var heroes := _squad(STAGE + Vector3(0, 0, 2), PI, ["viking", "witch", "cowboy", "sand_ghost"], 1.6)
	_dolly(STAGE + Vector3(0, 1.6, 7.6), STAGE + Vector3(0, 1.6, 6.6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 6.0)
	_narrate("L'Escouade Écarlate, libre après des années de boucles.", 3.0)
	await _until(6.6)
	_say(heroes.witch, "Les deux escouades ensemble ? Ça me va.", 2.4, -1.0)
	await _until(9.4)
	_say(heroes.sand_ghost, "On montre aux nouveaux comment on fait ?", 2.4, 1.0)
	await _until(12.2)
	_narrate("MISSION : tiens les zones avec les deux escouades.", 3.4)
	await _until(16.8)
	_fade_shade(1.0, 1.0)
