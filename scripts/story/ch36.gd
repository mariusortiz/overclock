extends Season4Scene
## Chapitre 36 : Échange. The story mode's scene before the
## mission (season 4, see scripts/anime/ep37.gd for the episode).


func _init() -> void:
	episode_number = 36
	episode_title = "ÉCHANGE"
	duration = 22.0


func _story() -> void:
	await _title_card(2.6)
	_load_mirror_world()
	_fade_shade(0.0, 0.6)
	var hero := _hero("witch", STAGE + Vector3(-1.2, 0, 1.2), PI, "none")
	var other := _double("witch", STAGE + Vector3(1.2, 0, 1.2), PI)
	_dolly(STAGE + Vector3(0, 1.7, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 1.2), STAGE + Vector3(0, 1.4, 1.2), 7.0)
	_narrate("Les doubles de l'Écarlate changent de camp.", 3.0)
	await _until(6.8)
	_say(hero, "Ici, c'est moi la gentille.", 2.4, -1.0)
	await _until(9.6)
	_say(other, "Ne t'y habitue pas.", 2.8, 1.0)
	await _until(13.0)
	_narrate("MISSION : reprenez les rues au Reflet.", 3.4)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
