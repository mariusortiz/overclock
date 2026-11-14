extends Season4Scene
## Chapitre 35 : Le monde sans code. The story mode's scene before the
## mission (season 4, see scripts/anime/ep36.gd for the episode).


func _init() -> void:
	episode_number = 35
	episode_title = "LE MONDE SANS CODE"
	duration = 22.0


func _story() -> void:
	await _title_card(2.6)
	_load_mirror_world()
	_fade_shade(0.0, 0.6)
	var hero := _hero("captain", STAGE + Vector3(-1.2, 0, 1.2), PI, "none")
	var other := _creator(STAGE + Vector3(1.2, 0, 1.2), PI)
	_overlay(other, Color(0.95, 0.9, 1.0, 0.4))
	_dolly(STAGE + Vector3(0, 1.7, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 1.2), STAGE + Vector3(0, 1.4, 1.2), 7.0)
	_narrate("Le Créateur d'en face a des choses à dire.", 3.0)
	await _until(6.8)
	_say(hero, "Vous êtes l'autre Créateur ?", 2.4, -1.0)
	await _until(9.6)
	_say(other, "Je fais pousser des fleurs. Protégez-moi, je vous raconte.", 2.8, 1.0)
	await _until(13.0)
	_narrate("MISSION : tiens les zones de la ville-miroir.", 3.4)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
