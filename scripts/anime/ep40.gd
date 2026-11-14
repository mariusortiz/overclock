extends Season4Episode
## Épisode 40 : Fusion. The two worlds overlap: half the city in its own
## colors, half in reverse; doubles and heroes face each other in the street.
## Le Reflet, a man again, cracked, wants to finish what the Titan started.
## The other Créateur crosses over: maybe the worlds need each other.


func _init() -> void:
	episode_number = 40
	episode_title = "FUSION"
	duration = 58.0


func _story() -> void:
	_load_world("city")
	_tint_world(MIRROR)
	_shards(STAGE + Vector3(0, 9, -8), 16, 24.0)
	var heroes := _squad(STAGE + Vector3(0, 0, 1), 0.0, ["soldier", "kunoichi", "ronin", "captain"], 1.8, true)
	var doubles := {}
	for index in 4:
		var id: String = ["soldier", "kunoichi", "ronin", "captain"][index]
		doubles[id] = _double(id, STAGE + Vector3(-2.7 + 1.8 * index, 0, -5), PI, AnimeDirector.GUNS.get(id, "heavy"))
	_dolly(STAGE + Vector3(0, 14, 16), STAGE + Vector3(0, 6, 9), STAGE + Vector3(0, 2, -2), STAGE + Vector3(0, 1.4, -2), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.6)
	_narrate("Les deux mondes se superposent.", 2.6)
	await _until(4.6)
	_narrate("La moitié de la ville est à l'envers.", 2.6)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: face to face.
	_dolly(STAGE + Vector3(6, 1.7, -2), STAGE + Vector3(5.6, 1.7, -2.4), STAGE + Vector3(0, 1.4, -2), STAGE + Vector3(0, 1.4, -2), 10.0)
	await _until(13.2)
	_say(doubles.soldier, "Votre monde a tout. Le nôtre n'a rien.", 2.4, 1.0)
	await _until(16.0)
	_say(heroes.soldier, "Alors partageons. On ne prend rien à personne.", 2.6, -1.0)
	await _until(19.0)
	_say(doubles.kunoichi, "Le Reflet ne partage pas.", 1.8, 1.0)
	await _until(21.2)

	# 21.2 s: Le Reflet, cracked.
	var reflect := _reflect(STAGE + Vector3(0, 0, -10), PI, 3.0)
	_overlay(reflect, Color(1.0, 1.0, 1.0, 0.3))
	_appear(reflect, 0.8)
	_dolly(STAGE + Vector3(0, 1.8, -5.8), STAGE + Vector3(0, 1.9, -6.4), STAGE + Vector3(0, 2.2, -10), STAGE + Vector3(0, 2.4, -10), 6.0)
	_shake = 0.2
	await _until(22.4)
	_say(reflect, "Un monde. Un seul. Le mien.", 2.2, 1.0, 3.2)
	await _until(25.0)
	_narrate("Fissuré de partout, il tient encore debout.", 2.8)
	await _until(28.2)

	# 28.2 s: the other Créateur.
	var creator := _creator(STAGE + Vector3(-1.6, 0, 4.6), PI)
	var other := _creator(STAGE + Vector3(1.6, 0, 4.6), PI)
	_overlay(other, Color(0.95, 0.9, 1.0, 0.4))
	_appear(other, 0.6)
	_dolly(STAGE + Vector3(0, 1.8, 9.0), STAGE + Vector3(0, 1.7, 8.2), STAGE + Vector3(0, 1.4, 4.6), STAGE + Vector3(0, 1.4, 4.6), 9.0)
	await _until(29.0)
	_say(other, "J'ai traversé. Pour la première fois.", 2.4, 1.0)
	await _until(31.8)
	_say(creator, "Tu n'as pas peur ?", 1.6, -1.0)
	await _until(33.8)
	_say(other, "Si. Mais toi, tu as écrit des héros. Moi, je fais pousser des choses.", 3.4, 1.0)
	await _until(37.6)
	_say(creator, "Un monde qui crée, un monde qui fait pousser.", 2.6, -1.0)
	await _until(40.6)
	_say(other, "Ensemble, ils seraient complets.", 2.2, 1.0)
	await _until(43.2)
	_dolly(STAGE + Vector3(0, 5, 14), STAGE + Vector3(0, 7, 18), STAGE + Vector3(0, 2, -4), STAGE + Vector3(0, 3, -10), 6.0)
	_narrate("Le Reflet lève les bras. Tous les miroirs du ciel se tournent vers eux.", 3.6, true)
	await _until(47.4)
	await _to_be_continued(47.8)
