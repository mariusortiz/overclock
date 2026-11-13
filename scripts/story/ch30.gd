extends Season3Scene
## Chapitre 30 : Retour. Home, and the rematch promised to Vipère.


func _init() -> void:
	episode_number = 30
	episode_title = "RETOUR"
	duration = 26.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var vipere := _hero("sand_ghost", STAGE + Vector3(-1, 0, 2), PI * 0.8, "none")
	var creator := _creator(STAGE + Vector3(1, 0, 2), -PI * 0.8)
	_dolly(STAGE + Vector3(0, 1.6, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 6.0)
	_narrate("La station. Chez eux. Le Créateur a retrouvé son code.", 3.2)
	await _until(6.8)
	_say(vipere, "Personne ne crée seul, hein ?", 2.2, -1.0)
	await _until(9.4)
	_say(vipere, "Alors ma revanche, on la court maintenant.", 2.6, -1.0)
	await _until(12.4)
	_say(creator, "Promis. Pour de vrai.", 2.0, 1.0)
	_appear(creator, 0.6)
	await _until(15.0)
	_narrate("MISSION : la revanche. Gagne la course.", 3.0)
	await _until(19.0)
	_fade_shade(1.0, 1.0)
