extends Season4Scene
## Chapitre 31 : Le reflet. The story mode's scene before the
## mission (season 4, see scripts/anime/ep32.gd for the episode).


func _init() -> void:
	episode_number = 31
	episode_title = "LE REFLET"
	duration = 22.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var hero := _hero("soldier", STAGE + Vector3(-1.2, 0, 1.2), PI, "none")
	var other := _double("soldier", STAGE + Vector3(1.2, 0, 1.2), PI)
	_dolly(STAGE + Vector3(0, 1.7, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 1.2), STAGE + Vector3(0, 1.4, 1.2), 7.0)
	_narrate("Des doubles sortent du miroir, partout dans la station.", 3.0)
	await _until(6.8)
	_say(hero, "Ce miroir n'était pas là hier.", 2.4, -1.0)
	await _until(9.6)
	_say(other, "Merci d'avoir ouvert la porte.", 2.8, 1.0)
	await _until(13.0)
	_narrate("MISSION : tiens les zones de la station.", 3.4)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
