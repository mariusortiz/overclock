extends StoryScene
## Chapitre 2 : Le défi. A red ship lands in the city: Vipère challenges the
## squad to a race.


func _init() -> void:
	episode_number = 2
	episode_title = "LE DÉFI"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(4)
	_fade_shade(0.0, 0.6)
	var soldier := _hero("soldier", STAGE + Vector3(-1.2, 0, 2.0), PI)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0.4, 0, 2.6), PI)
	var red := _parked_ship(RED, STAGE + Vector3(-30, 22, -30), 0.0)
	red.scale = Vector3.ONE * 1.3
	_fly_to(red, STAGE + Vector3(-30, 22, -30), STAGE + Vector3(2.5, 1.2, -8), 3.5)
	_dolly(STAGE + Vector3(3, 1.2, 6), STAGE + Vector3(2, 1.4, 5), STAGE + Vector3(-10, 8, -15),
			STAGE + Vector3(0, 1.5, -5), 3.6, true)
	_narrate("Un mois après le Titan. Un vaisseau rouge se pose en ville.", 3.4)
	await _until(7.0)
	_stomp(STAGE + Vector3(0, 0, -5), 0.4)
	var vipere := _hero("sand_ghost", STAGE + Vector3(0.6, 0, -2.6), 0.0)
	_face(vipere, soldier)
	_dolly(STAGE + Vector3(3.0, 1.5, -0.4), STAGE + Vector3(2.4, 1.6, -0.8), STAGE + Vector3(0.6, 1.5, -2.6),
			STAGE + Vector3(0.6, 1.5, -2.6), 6.0, true)
	await _until(7.6)
	_say(vipere, "C'est vous, l'escouade qui a battu le Titan ?", 2.8, 1.0)
	await _until(10.8)
	_say(vipere, "Vipère. Meilleure pilote du secteur.", 2.6, 1.0)
	await _until(13.8)
	_dolly(STAGE + Vector3(-3.0, 1.5, 4.5), STAGE + Vector3(-2.4, 1.6, 4.0), STAGE + Vector3(-0.4, 1.5, 2.0),
			STAGE + Vector3(-0.4, 1.5, 2.0), 5.0, true)
	_say(kunoichi, "Et elle est modeste.", 2.0, 1.0)
	await _until(16.2)
	_say(soldier, "Qu'est-ce que tu veux ?", 2.2, -1.0)
	await _until(18.8)
	_dolly(STAGE + Vector3(2.0, 1.4, 0.4), STAGE + Vector3(1.4, 1.5, 0.0), STAGE + Vector3(0.6, 1.5, -2.6),
			STAGE + Vector3(0.6, 1.5, -2.6), 6.0, true)
	vipere.play(&"victory", true)
	_say(vipere, "Une course. Si je gagne, la station est à moi !", 3.0, 1.0)
	await _until(22.2)
	_say(soldier, "Et si on gagne ?", 1.8, -1.0)
	await _until(24.2)
	_say(vipere, "Ça n'arrivera pas.", 2.0, 1.0)
	await _until(26.0)
	_narrate("MISSION : termine la course dans les 3 premiers.", 3.4)
	await _until(28.8)
	_fade_shade(1.0, 1.0)
