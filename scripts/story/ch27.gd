extends Season3Scene
## Chapitre 27 : La Lune qui boucle. The same thirty seconds, again and again.


func _init() -> void:
	episode_number = 27
	episode_title = "LA LUNE QUI BOUCLE"
	duration = 26.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(1)
	_night_sky()
	_fade_shade(0.0, 0.6)
	var vipere := _hero("sand_ghost", STAGE + Vector3(0, 0, 2), PI)
	_dolly(STAGE + Vector3(0, 1.6, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 4.0)
	_narrate("La lune. Un météore tombe.", 2.4)
	await _until(5.6)
	_rewind()
	_narrate("La lune. Un météore tombe.", 2.4)
	await _until(8.6)
	_rewind()
	_narrate("La lune. Un météore tombe.", 2.4)
	await _until(11.4)
	_say(vipere, "On a déjà vécu ça. Trois fois.", 2.2, -1.0)
	await _until(14.0)
	_say(vipere, "Cette fois, c'est le ciel qui change.", 2.4, -1.0)
	await _until(17.0)
	_narrate("MISSION : survis aux météores jusqu'à briser la boucle.", 3.4)
	await _until(21.6)
	_fade_shade(1.0, 1.0)
