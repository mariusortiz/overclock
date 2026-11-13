extends Season3Scene
## Chapitre 29 : Le Gardien. The heart of the galaxy, and its Gardien.


func _init() -> void:
	episode_number = 29
	episode_title = "LE GARDIEN"
	duration = 27.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("crystal")
	_night_sky()
	_fade_shade(0.0, 0.6)
	_portal(Vector3(0, 16, -27), 9.0)
	var soldier := _hero("soldier", STAGE + Vector3(0, 0, 0), 0.0)
	_dolly(STAGE + Vector3(0, 2.4, 8), STAGE + Vector3(0, 2, 6), STAGE + Vector3(0, 2, -6), Vector3(0, 14, -27), 5.0)
	_narrate("Le cœur de la galaxie. Un portail grand comme une montagne.", 3.2)
	await _until(7.0)
	_shake = 0.4
	var guardian := _guardian(Vector3(0, 0.1, -14), PI, 11.0)
	_rise(guardian, 11.0, 2.4)
	_dolly(STAGE + Vector3(-3, 1.2, 4), STAGE + Vector3(-2.4, 1.0, 3), Vector3(0, 3, -14), Vector3(0, 10, -14), 4.0)
	await _until(9.6)
	_narrate("LE GARDIEN", 2.2, true)
	await _until(12.0)
	_say(guardian, "La porte ne s'ouvre pas pour les faibles.", 2.8, 1.0, 11.4)
	await _until(15.2)
	_say(soldier, "Alors on va te montrer.", 2.0, -1.0)
	await _until(17.6)
	_narrate("MISSION : traverse la planète de cristal jusqu'au Gardien.", 3.4)
	await _until(22.2)
	_fade_shade(1.0, 1.0)
