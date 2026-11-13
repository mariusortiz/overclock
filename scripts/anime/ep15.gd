extends Season2Episode
## Épisode 15 : Le Créateur. In the station's hall, before the whole squad,
## Le Créateur tells them everything: he wrote the world, the Virus came out
## of one line too many, and three fragments of the source code can patch it.


func _init() -> void:
	episode_number = 15
	episode_title = "LE CRÉATEUR"
	duration = 110.0


func _story() -> void:
	_load_showroom()
	var ids := ["paladin", "ronin", "kunoichi", "soldier", "sand_ghost", "captain", "cowgirl"]
	var squad := {}
	for index in ids.size():
		squad[ids[index]] = _hero(ids[index], Vector3(-4.8 + 1.6 * index, 0, 0), PI, "none")
	_dolly(Vector3(0, 1.8, 7), Vector3(0, 1.6, 5.5), Vector3(0, 1.3, 0), Vector3(0, 1.3, 0), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Le hall de la station. Toute l'escouade attend.", 3.0)
	await _until(5.0)
	_say(squad.sand_ghost, "Il est en retard, ton dieu.", 2.2, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: he appears in front of them.
	_glitch(1.0)
	var creator := _creator(Vector3(0, 0, -4), PI)
	_appear(creator, 0.9)
	_dolly(Vector3(0, 1.4, 4), Vector3(0, 1.5, 3), Vector3(0, 1.5, -4), Vector3(0, 1.6, -4), 5.0)
	await _until(14.0)
	_narrate("Le Créateur.", 2.4, true)
	await _until(17.0)
	_dolly(Vector3(1.4, 1.6, -1.6), Vector3(1.2, 1.6, -2.0), Vector3(0, 1.6, -4), Vector3(0, 1.6, -4), 8.0)
	_say(creator, "Ce monde, je l'ai écrit. Ligne après ligne.", 2.8, -1.0)
	await _until(20.4)
	_say(creator, "Les arènes. Les boss. Vous.", 2.4, -1.0)
	await _until(23.2)
	_dolly(Vector3(-2, 1.6, 3), Vector3(-1.6, 1.6, 2.6), Vector3(0, 1.3, 0), Vector3(0, 1.3, 0), 6.0)
	_say(squad.soldier, "Et le Virus ?", 1.6, 1.0)
	await _until(25.4)
	_say(creator, "Une ligne de trop. Une seule. Elle s'est mise à se recopier.", 3.4, -1.0)
	await _until(29.4)
	_say(squad.paladin, "Alors efface-la.", 1.8, 1.0)
	await _until(31.6)
	_say(creator, "Je ne peux plus. Elle s'est cachée dans tout le code.", 3.0, -1.0)
	await _until(35.0)

	# 35 s: the doubt.
	_dolly(Vector3(3.2, 1.6, 2.4), Vector3(2.8, 1.6, 2.0), Vector3(1.6, 1.4, 0), Vector3(1.6, 1.4, 0), 8.0)
	_say(squad.sand_ghost, "Une vache en costume qui dit avoir créé le monde.", 3.0, 1.0)
	await _until(38.4)
	_say(squad.sand_ghost, "Et on doit la croire ?", 1.8, 1.0)
	await _until(40.6)
	creator.play(&"victory", true)
	_glitch(0.6)
	_impact_frame()
	# A gesture, and the hall changes: a moment in the volcano, a moment in the jungle.
	_load_arena(3)
	_embers(true)
	var ghost := _creator(STAGE, PI)
	_dolly(STAGE + Vector3(0, 1.6, 4), STAGE + Vector3(0, 1.7, 3.4), STAGE + Vector3(0, 1.5, 0), STAGE + Vector3(0, 1.5, 0), 2.0, true)
	await _until(42.4)
	_embers(false)
	_load_arena(2)
	ghost = _creator(STAGE, PI)
	_dolly(STAGE + Vector3(0, 1.6, 4), STAGE + Vector3(0, 1.7, 3.4), STAGE + Vector3(0, 1.5, 0), STAGE + Vector3(0, 1.5, 0), 2.0, true)
	await _until(44.0)
	_glitch(0.6)
	_load_showroom()
	squad.clear()
	for index in ids.size():
		squad[ids[index]] = _hero(ids[index], Vector3(-4.8 + 1.6 * index, 0, 0), PI, "none")
	creator = _creator(Vector3(0, 0, -4), PI)
	_dolly(Vector3(3.2, 1.6, 2.4), Vector3(2.8, 1.6, 2.0), Vector3(1.6, 1.4, 0), Vector3(1.6, 1.4, 0), 6.0)
	await _until(45.0)
	_say(squad.sand_ghost, "... D'accord. On te croit.", 2.2, 1.0)
	await _until(47.6)
	_say(creator, "Chacun ses choix de design.", 2.2, -1.0)
	await _until(50.2)

	# 50.2 s: the plan.
	_dolly(Vector3(0, 3.2, 6), Vector3(0, 2.8, 5), Vector3(0, 1.2, -2), Vector3(0, 1.2, -2), 10.0)
	_say(creator, "Trois fragments du code source sont restés propres.", 3.0, -1.0)
	await _until(53.6)
	for index in 3:
		var at := Vector3(-3.0 + 3.0 * index, 1.6, -3.0)
		_ring(at, VIRUS, 1.4, 1.2)
		Effects.burst(_set, at, VIRUS, 20)
	_narrate("La jungle. Le volcan. La station.", 3.0)
	await _until(57.0)
	_say(creator, "Avec eux, je peux réécrire le Virus. Sans eux...", 3.0, -1.0)
	await _until(60.4)
	_glitch(1.0)
	_say(creator, "... il réécrira tout. Vous compris.", 2.6, -1.0)
	await _until(63.4)
	_say(squad.ronin, "Je prends la jungle.", 1.8, 1.0)
	await _until(65.6)
	_say(squad.soldier, "Le volcan pour moi et Vipère.", 2.2, 1.0)
	await _until(68.2)
	_say(squad.kunoichi, "Et la station, on la garde tous ensemble.", 2.6, 1.0)
	await _until(71.2)
	_dolly(Vector3(1.4, 1.6, -1.6), Vector3(1.2, 1.6, -2.0), Vector3(0, 1.6, -4), Vector3(0, 1.6, -4), 6.0)
	_say(creator, "Merci. Je n'aurais pas pu l'écrire mieux.", 2.6, -1.0)
	await _until(74.4)
	_vanish(creator)
	await _until(75.6)
	_narrate("Trois fragments. Une course contre le Virus.", 3.2, true)
	await _until(79.4)
	await _to_be_continued(96.0)
