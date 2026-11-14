extends Season4Scene
## Chapitre 34 : De l'autre côté. The story mode's scene before the
## mission (season 4, see scripts/anime/ep35.gd for the episode).


func _init() -> void:
	episode_number = 34
	episode_title = "DE L'AUTRE CÔTÉ"
	duration = 22.0


func _story() -> void:
	await _title_card(2.6)
	_load_mirror_world()
	_fade_shade(0.0, 0.6)
	var hero := _hero("ronin", STAGE + Vector3(-1.2, 0, 1.2), PI, "none")
	var other := _double("ronin", STAGE + Vector3(1.2, 0, 1.2), PI)
	_dolly(STAGE + Vector3(0, 1.7, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 1.2), STAGE + Vector3(0, 1.4, 1.2), 7.0)
	_narrate("Le monde-miroir. Ses gardiens approchent.", 3.0)
	await _until(6.8)
	_say(hero, "Les couleurs sont à l'envers.", 2.4, -1.0)
	await _until(9.6)
	_say(other, "Vous n'avez rien à faire ici.", 2.8, 1.0)
	await _until(13.0)
	_narrate("MISSION : tiens jusqu'à leur reine.", 3.4)
	await _until(17.0)
	_fade_shade(1.0, 1.0)
