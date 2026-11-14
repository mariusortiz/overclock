extends Season4Episode
## Épisode 35 : De l'autre côté. Through the mirror, the squad steps into the
## mirror world: their own city, in reverse colors, glass shards in the sky,
## and no game: no arenas, no waves, nobody ever told to fight.


func _init() -> void:
	episode_number = 35
	episode_title = "DE L'AUTRE CÔTÉ"
	duration = 50.0


func _story() -> void:
	_load_mirror_world()
	var door := _mirror(STAGE + Vector3(0, 0, 0.6), 0.0, 3.4)
	_dolly(STAGE + Vector3(0, 12, 22), STAGE + Vector3(0, 5, 12), STAGE + Vector3(0, 2, 0), STAGE + Vector3(0, 1.4, 1), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.6)
	_narrate("De l'autre côté du miroir.", 2.6)
	await _until(4.6)
	var heroes := _squad(STAGE + Vector3(0, 0, 2.6), PI)
	for id: String in heroes:
		_appear(heroes[id], 0.5)
	await _until(6.0)
	_say(heroes.captain, "C'est... notre ville ?", 1.8, 1.0)
	await _until(8.2)
	await _title_card(5.0)

	# 13.2 s: the city upside down.
	_dolly(STAGE + Vector3(0, 1.8, 8.6), STAGE + Vector3(0, 1.6, 7.0), STAGE + Vector3(0, 1.2, 2.6), STAGE + Vector3(0, 1.3, 2.6), 8.0)
	await _until(13.8)
	_say(heroes.ronin, "Les couleurs sont à l'envers.", 1.8, -1.0)
	await _until(16.0)
	_say(heroes.paladin, "Et le silence. Aucune sirène, aucune vague.", 2.6, 1.0)
	await _until(19.0)
	_dolly(STAGE + Vector3(-6, 3, 4), STAGE + Vector3(6, 4, 4), STAGE + Vector3(0, 6, -10), STAGE + Vector3(0, 8, -16), 8.0)
	_narrate("Ici, personne n'a jamais écrit de jeu.", 2.8, true)
	await _until(22.4)
	_narrate("Pas d'arène. Pas de boss. Pas de règles.", 2.8)
	await _until(25.6)

	# 25.6 s: someone watches.
	var watcher := _double("kunoichi", STAGE + Vector3(-7, 0, -6), 0.6)
	_dolly(STAGE + Vector3(-4.6, 1.6, -2.6), STAGE + Vector3(-4.8, 1.6, -3.0), STAGE + Vector3(-7, 1.4, -6), STAGE + Vector3(-7, 1.4, -6), 6.0)
	await _until(26.4)
	_say(watcher, "Vous n'avez rien à faire ici.", 2.0, 1.0)
	await _until(28.8)
	_dolly(STAGE + Vector3(-1.4, 1.7, 5.6), STAGE + Vector3(-1.0, 1.7, 5.0), STAGE + Vector3(-0.8, 1.4, 2.6), STAGE + Vector3(-0.8, 1.4, 2.6), 6.0)
	_say(heroes.kunoichi, "Elle a ma voix. Et ma mauvaise humeur.", 2.4, -1.0)
	await _until(31.6)
	_vanish(watcher, 0.6)
	_say(heroes.soldier, "On la suit. Doucement.", 1.8, 1.0)
	await _until(34.0)
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 3.4, 14), STAGE + Vector3(0, 1, 2), STAGE + Vector3(0, 1, 6), 6.0)
	for id: String in heroes:
		_move(_pivot_of(heroes[id]), Vector3(0, 0, 1.0))
		(heroes[id] as CharacterModel).play(&"walk")
	await _until(36.0)
	_narrate("Derrière eux, le miroir se referme.", 2.6, true)
	_overlay(door, Color(0.1, 0.0, 0.2, 0.8))
	await _until(39.2)
	await _to_be_continued(39.6)
