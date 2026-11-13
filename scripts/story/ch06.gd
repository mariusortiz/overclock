extends StoryScene
## Chapitre 6 : Duel dans la jungle. The Ronin and Vipère cross blades,
## until the Directeur's monsters surround them both.


func _init() -> void:
	episode_number = 6
	episode_title = "DUEL DANS LA JUNGLE"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(2)
	_fade_shade(0.0, 0.6)
	var ronin := _hero("ronin", STAGE + Vector3(-1.8, 0, 0), PI / 2.0)
	var vipere := _hero("sand_ghost", STAGE + Vector3(1.8, 0, 0), -PI / 2.0)
	_dolly(STAGE + Vector3(0, 1.2, 6), STAGE + Vector3(0, 1.3, 4.5), STAGE + Vector3(0, 1.2, 0),
			STAGE + Vector3(0, 1.3, 0), 6.0, true)
	_narrate("La jungle. Le Ronin a retrouvé Vipère.", 3.0)
	await _until(6.0)
	_say(ronin, "Tu travailles pour le Directeur.", 2.4, -1.0)
	await _until(8.8)
	_say(vipere, "Je travaille pour moi. Dégaine.", 2.4, 1.0)
	await _until(11.4)
	ronin.play(&"melee", true)
	vipere.play(&"melee", true)
	_impact_frame()
	_speed(1.0)
	_ring(STAGE + Vector3(0, 0.5, 0), Color(1.0, 0.9, 0.95), 6.0, 0.4)
	_shake = 0.2
	await _until(13.0)
	var enemies: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0
		enemies.append(_enemy(STAGE + Vector3(cos(angle) * 8.0, 0, sin(angle) * 8.0), -angle - PI / 2.0, &"walk"))
	var slime := _spawn_boss(Boss.Kind.SUMMONER, STAGE + Vector3(0, 0, -12), 3.0)
	_dolly(STAGE + Vector3(0, 9, 8), STAGE + Vector3(0, 10, 6), STAGE + Vector3(0, 0, -2),
			STAGE + Vector3(0, 0, -4), 4.0, true)
	await _until(15.0)
	_say(ronin, "On a de la compagnie.", 2.0, -1.0)
	await _until(17.4)
	ronin.play(&"aim")
	vipere.play(&"aim")
	_face(ronin, slime)
	_face(vipere, enemies[0])
	_dolly(STAGE + Vector3(0.4, 1.4, 3.0), STAGE + Vector3(0, 1.5, 2.4), STAGE + Vector3(0, 1.4, 0),
			STAGE + Vector3(0, 1.4, 0), 5.0, true)
	_say(vipere, "Dos à dos, samouraï ?", 2.2, 1.0)
	await _until(20.0)
	_say(ronin, "Dos à dos.", 1.8, -1.0)
	await _until(22.4)
	_narrate("MISSION : survis aux monstres de la jungle, jusqu'à leur boss.", 3.8)
	await _until(28.6)
	_fade_shade(1.0, 1.0)
