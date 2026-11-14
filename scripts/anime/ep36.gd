extends Season4Episode
## Épisode 36 : Le monde sans code. In the mirror city, Le Créateur meets his
## own double: a Créateur who never wrote the game, a quiet cow who grows
## flowers on a rooftop. Kind, a little sad. He warns them: someone here
## wants their world, the one with the game in it. Le Reflet.


func _init() -> void:
	episode_number = 36
	episode_title = "LE MONDE SANS CODE"
	duration = 57.0


func _story() -> void:
	_load_mirror_world()
	var heroes := _squad(STAGE + Vector3(0, 0, -1.8), PI, ["soldier", "kunoichi", "captain", "cowgirl"], 1.8)
	var creator := _creator(STAGE + Vector3(-2.2, 0, 0.6), PI)
	var other := _creator(STAGE + Vector3(2.2, 0, 0.6), PI)
	_overlay(other, Color(0.95, 0.9, 1.0, 0.4))
	_pivot_of(other).visible = false
	_dolly(STAGE + Vector3(0, 4, 12), STAGE + Vector3(0, 2.4, 9), STAGE + Vector3(0, 1.2, 1), STAGE + Vector3(0, 1.4, 1), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Le monde-miroir. Une rue calme.", 2.6)
	await _until(4.2)
	_say(creator, "Je sens... quelqu'un qui me ressemble.", 2.4, -1.0)
	await _until(7.0)
	await _title_card(5.0)

	# 12 s: the other Créateur.
	_pivot_of(other).visible = true
	_appear(other, 0.8)
	_dolly(STAGE + Vector3(0, 1.8, 6.4), STAGE + Vector3(0, 1.7, 5.6), STAGE + Vector3(0, 1.4, 0.6), STAGE + Vector3(0, 1.4, 0.6), 8.0)
	await _until(13.2)
	_say(other, "Bonjour. Vous venez de l'autre côté ?", 2.4, 1.0)
	await _until(16.0)
	_say(creator, "Tu... tu n'as jamais codé ?", 2.0, -1.0)
	await _until(18.4)
	_say(other, "Coder ? Je fais pousser des fleurs.", 2.2, 1.0)
	await _until(21.0)
	_say(heroes.cowgirl, "Il est plus détendu que le nôtre.", 2.0, -1.0)
	await _until(23.4)
	_say(creator, "Je suis très détendu.", 1.6, -1.0)
	await _until(25.4)

	# 25.4 s: the warning.
	_dolly(STAGE + Vector3(3.6, 1.7, 2.6), STAGE + Vector3(3.2, 1.7, 2.2), STAGE + Vector3(2.2, 1.5, 0.6), STAGE + Vector3(2.2, 1.5, 0.6), 8.0)
	_say(other, "Ici, rien n'arrive jamais. Pas de héros, pas d'histoires.", 3.0, 1.0)
	await _until(28.8)
	_say(other, "Et quelqu'un en a eu assez.", 2.0, 1.0)
	await _until(31.2)
	_say(heroes.soldier, "Mon double ?", 1.4, -1.0)
	await _until(33.0)
	_say(other, "Le premier. Il s'appelle le Reflet.", 2.4, 1.0)
	await _until(35.8)
	_say(other, "Il veut votre monde. Celui où il se passe quelque chose.", 3.0, 1.0)
	await _until(39.2)

	# 39.2 s: Le Reflet, far away.
	var reflect := _reflect(STAGE + Vector3(0, 6.2, -18), PI, 4.0)
	_dolly(STAGE + Vector3(0, 2, 0), STAGE + Vector3(0, 3, -4), STAGE + Vector3(0, 7, -18), STAGE + Vector3(0, 8.2, -18), 6.0)
	_narrate("Sur un toit, une silhouette de verre les regarde.", 3.0, true)
	await _until(42.6)
	_say(reflect, "Bienvenue chez moi. Pour l'instant.", 2.4, 1.0, 4.2)
	await _until(45.4)
	_vanish(reflect, 0.8)
	await _until(46.6)
	await _to_be_continued(47.0)
