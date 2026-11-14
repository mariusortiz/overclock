extends Season4Episode
## Épisode 37 : Échange. The mirror world's people side with the squad: the
## Escouade Écarlate's doubles, kind ones here, help them through the
## Reflet's guards. Allies and enemies trade places.


func _init() -> void:
	episode_number = 37
	episode_title = "ÉCHANGE"
	duration = 52.0


func _story() -> void:
	_load_mirror_world()
	var heroes := _squad(STAGE + Vector3(0, 0, 2), 0.0, ["soldier", "kunoichi", "ronin", "sand_ghost"], 1.6, true)
	var guards: Array[Enemy] = []
	for index in 5:
		guards.append(_enemy(STAGE + Vector3(-6 + 3.0 * index, 0, -8), 0.0, &"shoot"))
	for guard in guards:
		_glass(guard._model, Color(0.3, 0.25, 0.45))
	_dolly(STAGE + Vector3(-6, 2.4, 9), STAGE + Vector3(-2, 2, 7), STAGE + Vector3(0, 1, -2), STAGE + Vector3(0, 1.2, -2), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Les gardes du Reflet barrent la grande rue.", 2.8)
	await _until(4.4)
	_dolly(STAGE + Vector3(-1.5, 1.6, -1.0), STAGE + Vector3(-1.2, 1.6, -1.4), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 3.0)
	_say(heroes.ronin, "Trop nombreux. Et en verre blindé.", 2.2, 1.0)
	await _until(7.0)
	await _title_card(5.0)

	# 12 s: help from the other side.
	var witch := _double("witch", STAGE + Vector3(-5, 0, 4), PI, "heavy")
	var godfather := _double("godfather", STAGE + Vector3(5, 0, 4), PI, "heavy")
	_overlay(witch, Color(0.95, 0.9, 1.0, 0.4))
	_overlay(godfather, Color(0.95, 0.9, 1.0, 0.4))
	_appear(witch, 0.6)
	_appear(godfather, 0.6)
	_dolly(STAGE + Vector3(-3.4, 1.7, 7.6), STAGE + Vector3(-3.0, 1.7, 7.0), STAGE + Vector3(-5, 1.4, 4), STAGE + Vector3(-5, 1.4, 4), 6.0)
	await _until(12.8)
	_say(witch, "Ici, je suis gentille. Ne t'habitue pas.", 2.4, 1.0)
	await _until(15.6)
	_dolly(STAGE + Vector3(3.4, 1.7, 7.6), STAGE + Vector3(3.0, 1.7, 7.0), STAGE + Vector3(5, 1.4, 4), STAGE + Vector3(5, 1.4, 4), 6.0)
	_say(godfather, "Le Reflet nous a pris nos rues. On les reprend.", 2.6, -1.0)
	await _until(18.6)
	_say(heroes.sand_ghost, "Les ennemis deviennent des alliés.", 2.0, 1.0)
	await _until(21.0)
	_say(heroes.kunoichi, "Et nos doubles, des ennemis. Logique.", 2.2, -1.0)
	await _until(23.6)

	# 23.6 s: the charge.
	_speed(4.0)
	_dolly(STAGE + Vector3(0, 3, 8), STAGE + Vector3(0, 2.4, 3), STAGE + Vector3(0, 1, -6), STAGE + Vector3(0, 1, -8), 6.0)
	var shooters: Array = [heroes.soldier, heroes.kunoichi, heroes.ronin, heroes.sand_ghost, witch]
	for index in guards.size():
		var shooter: CharacterModel = shooters[index % shooters.size()]
		var guard := guards[index]
		get_tree().create_timer(0.5 + 0.45 * index).timeout.connect(_shoot.bind(shooter, guard, &"shatter", GOLD))
	await _until(27.0)
	_narrate("Le verre blindé ne résiste pas à deux mondes.", 2.8, true)
	await _until(30.2)
	_dolly(STAGE + Vector3(0, 1.8, 7.4), STAGE + Vector3(0, 1.8, 6.6), STAGE + Vector3(0, 1.4, 2), STAGE + Vector3(0, 1.4, 2), 8.0)
	for id: String in heroes:
		_pivot_of(heroes[id]).rotation.y = PI
		(heroes[id] as CharacterModel).play(&"victory")
	_say(heroes.soldier, "Merci. Vraiment.", 1.8, 1.0)
	await _until(32.4)
	_say(godfather, "Remerciez-nous en battant le Reflet.", 2.2, -1.0)
	await _until(35.0)
	_say(witch, "Il est dans la tour. Il copie tout ce qu'il voit.", 2.6, 1.0)
	await _until(38.0)
	_narrate("La tour du Reflet. Au bout de la rue.", 2.6)
	await _until(41.0)
	await _to_be_continued(41.4)
