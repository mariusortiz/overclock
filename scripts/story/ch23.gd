extends Season3Scene
## Chapitre 23 : Le Chant des cristaux. Every wrong note brings more
## sentinels; Ronin hears the melody.


func _init() -> void:
	episode_number = 23
	episode_title = "LE CHANT DES CRISTAUX"
	duration = 26.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("crystal")
	_moons()
	_fade_shade(0.0, 0.6)
	var ronin := _hero("ronin", STAGE + Vector3(0, 0, 2), PI)
	_dolly(STAGE + Vector3(1.4, 1.7, 5), STAGE + Vector3(1.1, 1.7, 4.4), STAGE + Vector3(0, 1.5, 2), STAGE + Vector3(0, 1.5, 2), 7.0)
	_narrate("À chaque tir, une fausse note. Et les sentinelles reviennent.", 3.2)
	await _until(7.0)
	_say(ronin, "Silence. J'écoute.", 1.8, 1.0)
	await _until(9.4)
	_dolly(STAGE + Vector3(0, 10, 12), STAGE + Vector3(0, 13, 9), STAGE + Vector3(0, 0, -6), STAGE + Vector3(0, 0, -10), 6.0)
	for at in [Vector3(-8, 0.1, 8), Vector3(9, 0.1, 7), Vector3(-6, 0.1, -12)]:
		_note(at, CRYSTAL)
		await _until(_clock + 0.8)
	await _until(12.4)
	_dolly(STAGE + Vector3(1.4, 1.7, 5), STAGE + Vector3(1.1, 1.7, 4.4), STAGE + Vector3(0, 1.5, 2), STAGE + Vector3(0, 1.5, 2), 5.0)
	_say(ronin, "Trois cristaux, trois notes. Il faut les tenir ensemble.", 3.0, 1.0)
	await _until(16.0)
	_narrate("MISSION : tiens les zones A, B et C pour jouer la mélodie.", 3.6)
	await _until(21.0)
	_fade_shade(1.0, 1.0)
