extends Season2Episode
## Épisode 19 : Ctrl+Z. In the black, the Soldier and Vipère hear a voice:
## Le Créateur is not deleted, only scattered. He can undo, once. The squad
## comes back, the fleet with the Mainframe gathers; the Virus grows over the
## city.


func _init() -> void:
	episode_number = 19
	episode_title = "CTRL+Z"
	duration = 108.0


func _story() -> void:
	# A dark hall: the void after the deletion.
	_load_showroom()
	var soldier := _hero("soldier", Vector3(-1.0, 0, 0), PI * 0.8, "none")
	var vipere := _hero("sand_ghost", Vector3(1.0, 0, 0), -PI * 0.8, "none")
	_dolly(Vector3(0, 1.6, 6), Vector3(0, 1.5, 5), Vector3(0, 1.3, 0), Vector3(0, 1.3, 0), 8.0)
	_fade_shade(0.0, 2.0)
	await _until(2.0)
	_narrate("Le noir. Plus de station. Plus de ville.", 3.0)
	await _until(5.4)
	_say(vipere, "On est... où ?", 1.8, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: a voice, then a flicker.
	_glitch(0.6)
	_narrate("« Vous m'entendez ? »", 2.4)
	await _until(15.4)
	var creator := _creator(Vector3(0, 0, -3), PI)
	_appear(creator, 1.2)
	_dolly(Vector3(0, 1.5, 3.5), Vector3(0, 1.5, 2.8), Vector3(0, 1.5, -3), Vector3(0, 1.5, -3), 6.0)
	await _until(17.0)
	_say(creator, "Il ne m'a pas effacé. Juste... éparpillé.", 2.8, -1.0)
	await _until(20.4)
	_say(soldier, "Et les autres ?", 1.6, 1.0)
	await _until(22.4)
	_say(creator, "Je peux tout annuler. Une seule fois.", 2.6, -1.0)
	await _until(25.4)
	_say(vipere, "Comme un Ctrl+Z ?", 1.8, 1.0)
	await _until(27.6)
	_say(creator, "Exactement comme un Ctrl+Z.", 2.2, -1.0)
	await _until(30.2)

	# 30.2 s: undo.
	creator.play(&"victory", true)
	_narrate("CTRL + Z", 2.0, true)
	_impact_frame()
	_ring(Vector3(0, 0.2, 0), VIRUS, 20.0, 1.0)
	_speed(1.5)
	await _until(31.4)
	var back := {}
	var ids := ["captain", "ronin", "kunoichi", "paladin", "godfather", "cowgirl"]
	for index in ids.size():
		var at := Vector3(-5.0 + 2.0 * index, 0, 2.2)
		back[ids[index]] = _hero(ids[index], at, PI, "none")
		_appear(back[ids[index]], 0.6)
		await _until(_clock + 0.45)
	_dolly(Vector3(0, 2.4, 9), Vector3(0, 2.2, 8), Vector3(0, 1.2, 1), Vector3(0, 1.2, 1), 6.0)
	await _until(35.0)
	_narrate("Tous revenus. Comme s'ils n'étaient jamais partis.", 3.0)
	await _until(38.4)
	_say(back.kunoichi, "J'ai... rêvé ?", 1.8, 1.0)
	await _until(40.6)
	_say(back.captain, "On était effacés. Je l'ai senti.", 2.4, -1.0)
	await _until(43.4)

	# 43.4 s: the plan.
	_dolly(Vector3(1.6, 1.6, -0.6), Vector3(1.3, 1.6, -1.0), Vector3(0, 1.6, -3), Vector3(0, 1.6, -3), 10.0)
	_say(creator, "Le Virus a les trois fragments en vue. Il grandit sur la ville.", 3.4, -1.0)
	await _until(47.2)
	_say(creator, "Seul, je ne peux plus l'arrêter. Ma clé est à moitié à lui.", 3.4, -1.0)
	await _until(51.0)
	_say(creator, "Mais vous, vous êtes écrits pour gagner.", 2.8, -1.0)
	await _until(54.2)
	_say(soldier, "Alors on overclocke tout le monde. Comme la dernière fois.", 3.0, 1.0)
	await _until(57.6)

	# 57.6 s: the fleet.
	_wipe()
	_load_arena(4)
	var ships: Array[RaceShip] = []
	var ship_ids := ["ship_mainframe", "ship_dart", "ship_falcon", "ship_hornet", "ship_nova"]
	for index in ship_ids.size():
		var ship := RaceShip.new()
		ship.configure(Loadout.find(ship_ids[index]).item)
		_set.add_child(ship)
		var from := STAGE + Vector3(-40 + index * 4, 20 + index, 24)
		var to := STAGE + Vector3(-8 + index * 4, 12 + index * 0.6, -2)
		ship.scale = Vector3.ONE * 1.6
		_toon(ship)
		_fly_to(ship, from, to, 3.0)
		ships.append(ship)
	_dolly(STAGE + Vector3(0, 6, 12), STAGE + Vector3(0, 9, 9), STAGE + Vector3(-12, 16, 8), STAGE + Vector3(0, 13, -2), 3.4)
	await _until(59.4)
	_narrate("La flotte, menée par le Mainframe.", 2.8)
	await _until(62.6)
	_say(ships[0], "Formation. On suit le vert.", 2.4, -1.0, 1.0)
	await _until(65.6)

	# 65.6 s: over the city, the Virus has grown.
	var virus := _virus_titan(STAGE + Vector3(0, 0, -18), TITAN_HEIGHT * 1.8)
	_rise(virus, TITAN_HEIGHT * 1.8, 4.0)
	_glitch(2.0)
	_shake = 0.3
	_dolly(STAGE + Vector3(-4, 0.6, 9), STAGE + Vector3(-2.5, 1.0, 7), STAGE + Vector3(0, 4, -18), STAGE + Vector3(0, TITAN_HEIGHT * 1.6, -18), 6.0)
	await _until(68.0)
	_narrate("Le Virus. Deux fois plus grand que le Titan Mk II.", 3.2, true)
	await _until(72.0)
	_stomp(STAGE + Vector3(0, 0, -18), 1.6)
	_impact_frame()
	await _until(74.0)
	_say(ships[0], "Demain, on redémarre ce monde.", 2.6, -1.0, 1.0)
	await _until(77.0)
	await _to_be_continued(94.0)
