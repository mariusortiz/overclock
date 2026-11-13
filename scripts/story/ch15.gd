extends Season2Scene
## Chapitre 15 : Le Créateur. Before the whole squad, he tells them: he wrote
## the world, and three fragments of the source code can patch it.


func _init() -> void:
	episode_number = 15
	episode_title = "LE CRÉATEUR"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_arena(0)
	_fade_shade(0.0, 0.6)
	var creator := _creator(STAGE + Vector3(0, 0, -1.0), PI)
	var ids := ["kunoichi", "soldier", "captain", "ronin", "cowgirl"]
	var squad := {}
	for index in ids.size():
		squad[ids[index]] = _hero(ids[index], STAGE + Vector3(-3.0 + 1.5 * index, 0, 3.4 - absf(index - 2) * 0.3), 0.0, "none")
	_dolly(STAGE + Vector3(-1.6, 1.6, 2.6), STAGE + Vector3(-1.0, 1.6, 1.8), STAGE + Vector3(0, 1.6, -1),
			STAGE + Vector3(0, 1.6, -1), 6.0, true)
	_narrate("La station. Toute l'escouade est là. Lui aussi.", 3.0)
	await _until(6.4)
	_say(creator, "J'ai écrit ce monde. Chaque arène, chaque ennemi.", 3.0, -1.0)
	await _until(9.8)
	# The reverse shot: the squad, facing him (and the camera).
	_dolly(STAGE + Vector3(0, 1.6, -0.2), STAGE + Vector3(0, 1.6, 0.4), STAGE + Vector3(0, 1.4, 3.2),
			STAGE + Vector3(0, 1.4, 3.2), 4.0, true)
	_say(squad.soldier, "Et le Virus ?", 1.8, -1.0)
	await _until(12.2)
	_say(squad.ronin, "Toi aussi, tu l'as écrit ?", 2.2, 1.0)
	await _until(14.8)
	_dolly(STAGE + Vector3(1.6, 1.6, 2.6), STAGE + Vector3(1.0, 1.7, 1.8), STAGE + Vector3(0, 1.6, -1),
			STAGE + Vector3(0, 1.7, -1), 6.0, true)
	_glitch(0.6)
	_say(creator, "Une ligne de trop. Elle a grandi seule.", 2.8, -1.0)
	await _until(18.0)
	_say(creator, "Trois fragments du code source peuvent la corriger.", 3.0, -1.0)
	await _until(21.4)
	_say(squad.kunoichi, "Alors on les trouve.", 2.0, 1.0)
	await _until(23.6)
	_narrate("MISSION : montre-lui ce que vaut l'escouade. Tiens les zones de la station.", 4.4)
	await _until(28.6)
	_fade_shade(1.0, 1.0)

