extends StoryScene
## Chapitre 8 : Le volcan. Into the Directeur's base: his guards, his
## dragon, and the man himself.


func _init() -> void:
	episode_number = 8
	episode_title = "LE VOLCAN"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(3)
	_fade_shade(0.0, 0.6)
	_embers(true)
	var soldier := _hero("soldier", STAGE + Vector3(-1.2, 0, 2.0), 0.0)
	var vipere := _hero("sand_ghost", STAGE + Vector3(1.2, 0, 2.4), 0.0)
	for hero in [soldier, vipere]:
		hero.play(&"walk", true)
		_move(hero.get_parent() as Node3D, Vector3(0, 0, -0.35))
	_dolly(STAGE + Vector3(1.5, 1.8, -7), STAGE + Vector3(1.0, 1.8, -6), STAGE + Vector3(0, 1.3, 2),
			STAGE + Vector3(0, 1.3, 0), 6.0, true)
	_narrate("La base du Directeur, au cœur du volcan.", 3.0)
	await _until(6.6)
	_say(vipere, "Trop calme.", 1.8, 1.0)
	await _until(8.8)
	_movers.clear()
	soldier.play(&"aim")
	vipere.play(&"aim")
	var directeur := _npc("Suit_Male.fbx", STAGE + Vector3(0, 0, -12), PI)
	_dolly(STAGE + Vector3(1.2, 1.5, -8.0), STAGE + Vector3(0.8, 1.6, -8.6), STAGE + Vector3(0, 1.5, -12),
			STAGE + Vector3(0, 1.5, -12), 5.0, true)
	await _until(9.6)
	_say(directeur, "Vous arrivez trop tard.", 2.4, 1.0)
	await _until(12.4)
	_say(directeur, "Mon Titan est presque prêt. Occupez-vous d'eux !", 3.0, 1.0)
	await _until(15.6)
	var dragon := _spawn_boss(Boss.Kind.COLOSSUS, STAGE + Vector3(-6, 0, -14), 4.5)
	_rise(dragon, 6.0, 2.2)
	_dolly(STAGE + Vector3(2, 0.8, 0), STAGE + Vector3(1.5, 0.6, -1), STAGE + Vector3(-4, 3, -12),
			STAGE + Vector3(-5, 4.5, -14), 3.0, true)
	_shake = 0.3
	await _until(18.0)
	_impact_frame()
	_stomp(STAGE + Vector3(-6, 0, -14), 1.0)
	await _until(19.4)
	_dolly(STAGE + Vector3(0, 1.4, 5.0), STAGE + Vector3(0, 1.5, 4.0), STAGE + Vector3(0, 1.4, 0),
			STAGE + Vector3(0, 1.4, 0), 5.0, true)
	_say(soldier, "Les gardes d'abord. Puis le dragon.", 2.6, -1.0)
	await _until(22.6)
	_narrate("MISSION : infiltre le volcan, abats ses gardes puis son dragon.", 3.8)
	await _until(28.6)
	_fade_shade(1.0, 1.0)
