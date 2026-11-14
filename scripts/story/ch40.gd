extends Season4Scene
## Chapitre 40 : Les miroirs. The story mode's scene before the
## mission (season 4, see scripts/anime/ep41.gd for the episode).


func _init() -> void:
	episode_number = 40
	episode_title = "LES MIROIRS"
	duration = 22.0


func _story() -> void:
	await _title_card(2.6)
	_load_world("city")
	_tint_world(MIRROR)
	_fade_shade(0.0, 0.6)
	var hero := _hero("soldier", STAGE + Vector3(-1.2, 0, 1.2), PI, "none")
	var other := _double("soldier", STAGE + Vector3(1.2, 0, 1.2), PI)
	_dolly(STAGE + Vector3(0, 1.7, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 1.2), STAGE + Vector3(0, 1.4, 1.2), 7.0)
	_narrate("Le dernier combat contre le Reflet.", 3.0)
	await _until(6.8)
	_say(hero, "Côte à côte, cette fois.", 2.4, -1.0)
	await _until(9.6)
	_say(other, "Côte à côte. Pour de bon.", 2.8, 1.0)
	await _until(13.0)
	_narrate("MISSION : bats le Reflet, héros et doubles ensemble.", 3.4)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
