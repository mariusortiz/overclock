extends Season2Scene
## Chapitre 11 : Le glitch. Peace in the city, then the world tears and the
## enemies come back corrupted; on a roof, Le Créateur watches.


func _init() -> void:
	episode_number = 11
	episode_title = "LE GLITCH"
	duration = 29.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(4)
	_fade_shade(0.0, 0.6)
	var soldier := _hero("soldier", STAGE + Vector3(-0.9, 0, 3.0), 0.0)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(0.9, 0, 3.0), 0.0)
	_dolly(STAGE + Vector3(0, 1.6, -1.6), STAGE + Vector3(0, 1.6, -0.6), STAGE + Vector3(0, 1.4, 3),
			STAGE + Vector3(0, 1.4, 3), 6.0, true)
	_narrate("Des mois après le Titan Mk II. La ville est calme.", 3.2)
	await _until(6.4)
	_say(kunoichi, "Trop calme.", 1.8, 1.0)
	await _until(8.6)
	_glitch(1.6)
	_impact_frame()
	_say(soldier, "Tu as vu ça ? L'immeuble a… sauté.", 2.6, -1.0)
	await _until(11.6)
	var enemies: Array[Enemy] = []
	for index in 4:
		enemies.append(_corrupted(STAGE + Vector3(-3.0 + 2.0 * index, 0, -3.0), PI, &"walk"))
	_glitch(0.8)
	_dolly(STAGE + Vector3(2.5, 1.2, 6.0), STAGE + Vector3(1.5, 1.0, 5.0), STAGE + Vector3(0, 1.2, -3),
			STAGE + Vector3(0, 1.2, -2), 4.0, true)
	_narrate("Les gardes du Directeur. Revenus. Verts.", 2.8)
	for hero in [soldier, kunoichi]:
		hero.play(&"aim")
	await _until(15.0)
	_shoot(soldier, enemies[0], &"pixelate", VIRUS)
	await _until(15.6)
	_shoot(kunoichi, enemies[1], &"pixelate", VIRUS)
	await _until(16.4)
	_say(kunoichi, "Ils se recopient !", 1.8, 1.0)
	enemies[0] = _corrupted(STAGE + Vector3(-3.0, 0, -3.0), PI, &"walk")
	_appear(enemies[0])
	await _until(18.6)
	var creator := _creator(STAGE + Vector3(-1.0, 0, -8.0), PI)
	_appear(creator)
	_dolly(STAGE + Vector3(-0.6, 1.7, -4.4), STAGE + Vector3(-0.8, 1.7, -5.0), STAGE + Vector3(-1.0, 1.6, -8),
			STAGE + Vector3(-1.0, 1.7, -8), 3.0, true)
	_narrate("Là-bas, un homme à tête de vache regarde.", 2.6)
	await _until(21.8)
	_vanish(creator)
	_glitch(0.6)
	await _until(22.8)
	_narrate("MISSION : repousse les ennemis corrompus jusqu'à leur boss.", 4.0)
	await _until(27.6)
	_fade_shade(1.0, 1.0)
