extends StoryScene
## Chapitre 3 : La course. Dawn, in space: the start of the real race.


func _init() -> void:
	episode_number = 3
	episode_title = "LA COURSE"
	duration = 28.0


func _story() -> void:
	await _title_card(2.6)
	_load_space(2)
	_fade_shade(0.0, 0.6)
	var soldier := _ship("SOLDAT", CYAN, -10.0, Vector2(-3.5, 0), 0.0)
	var vipere := _ship("VIPÈRE", RED, -10.0, Vector2(3.5, 0), 0.0)
	var brutus := _ship("BRUTUS", Color(1.0, 0.5, 0.15), -18.0, Vector2(-3.5, 0), 0.0)
	var colt := _ship("COLT", Color(0.75, 0.45, 1.0), -18.0, Vector2(3.5, 0), 0.0)
	_follow(brutus, Vector3(0, 3.0, 9.0), Vector3(0, 0.5, -20.0))
	_narrate("À l'aube, dans la ceinture d'astéroïdes.", 3.0)
	await _until(6.0)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "Pas de règles, pas de pitié.", 2.4, -1.0, 1.0)
	await _until(8.8)
	_follow(soldier, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(soldier, "Ça me va.", 1.8, 1.0, 1.0)
	await _until(11.0)
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	for count in ["3", "2", "1"]:
		_narrate(count, 0.9, true)
		await _until(_clock + 1.0)
	_narrate("GO !", 0.8, true)
	for ship in [soldier, vipere, brutus, colt]:
		ship.skill = 1.0
		ship.boost(2.0)
	_speed(2.0)
	_impact_frame()
	await _until(16.4)
	_follow(colt, Vector3(4.0, 2.0, 6.0), Vector3(0, 0.3, -8.0))
	_ship_laser(colt, soldier)
	_say(colt, "Désolé, rien de personnel !", 2.2, 1.0, 1.0)
	await _until(19.2)
	_follow(soldier, Vector3(0, 1.4, 5.0), Vector3(0, 0.5, -10.0))
	_say(soldier, "L'Écarlate joue sale. Moi, j'apprends vite.", 2.8, -1.0, 1.0)
	await _until(22.6)
	_narrate("MISSION : termine 2e ou mieux.", 3.4)
	await _until(26.8)
	_fade_shade(1.0, 1.0)
