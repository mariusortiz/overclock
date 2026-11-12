extends AnimeDirector
## Épisode 3 : La course. Dawn, in space: the Soldier races Vipère and the
## Écarlate. She plays dirty, he learns fast; she wins by a nose.

const SEED := 4242


func _init() -> void:
	episode_number = 3
	episode_title = "LA COURSE"
	duration = 120.0


func _story() -> void:
	# 0 s: the starting grid.
	var track := _load_space(SEED)
	var length := track.length
	var soldier := _ship("SOLDAT", CYAN, -10.0, Vector2(-3.5, 0), 0.0)
	var vipere := _ship("VIPÈRE", RED, -10.0, Vector2(3.5, 0), 0.0)
	var captain := _ship("CAPITAINE", GOLD, -18.0, Vector2(-3.5, 0), 0.0)
	var brutus := _ship("BRUTUS", Color(1.0, 0.5, 0.15), -18.0, Vector2(3.5, 0), 0.0)
	var colt := _ship("COLT", Color(0.75, 0.45, 1.0), -26.0, Vector2(0, 0), 0.0)
	var ships: Array[RaceShip] = [soldier, vipere, captain, brutus, colt]
	for ship in ships:
		ship.speed = 0.0
	_follow(captain, Vector3(0, 3.0, 9.0), Vector3(0, 0.5, -20.0))
	_fade_shade(0.0, 1.0)
	_narrate("L'aube. La course.", 2.6)
	await _until(2.8)
	_follow(soldier, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(soldier, "Bleu, c'est le boost... tout est bleu.", 2.4, -1.0, 1.4)
	await _until(5.4)
	_follow(vipere, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(vipere, "Essaie de suivre, débutant.", 2.4, 1.0, 1.4)
	await _until(8.2)

	await _title_card(5.0)

	# 13.2 s: 3, 2, 1... GO.
	_follow(soldier, Vector3(0, 2.6, 8.0), Vector3(0, 0.5, -20.0))
	for count in ["3", "2", "1"]:
		_narrate(count, 0.8, true)
		await _until(_clock + 0.9)
	_narrate("GO !", 0.8, true)
	for ship in ships:
		ship.skill = 1.0
	vipere.skill = 1.06
	vipere.boost(2.0)
	_speed(2.0)
	await _until(18.0)

	# 18 s: Vipère leads; the Soldier finds a boost pad.
	_follow(soldier, Vector3(0, 2.4, 8.5), Vector3(0, 0.5, -24.0))
	var pad: Array = track.pads[0]
	_steer(soldier, pad[1])
	await _until(21.0)
	_say(soldier, "La plaque cyan !", 1.8, -1.0, 1.4)
	await _until(24.0)
	soldier.boost(2.5)
	soldier.skill = 1.08
	_speed(2.5)
	_impact_frame()
	await _until(26.0)

	# 26 s: side by side, she shoots.
	soldier.distance = vipere.distance - 6.0
	_steer(soldier, Vector2(-2.0, 0))
	_steer(vipere, Vector2(2.0, 0))
	_follow(vipere, Vector3(-6.0, 1.5, 4.0), Vector3(-2.0, 0.3, -4.0))
	await _until(28.0)
	_say(vipere, "Bonne chance !", 1.6, 1.0, 1.4)
	await _until(29.0)
	_ship_laser(vipere, soldier)
	_impact_frame()
	_shake = 0.2
	await _until(30.0)
	_follow(soldier, Vector3(0, 1.4, 5.0), Vector3(0, 0.5, -10.0))
	_say(soldier, "Elle triche !", 1.8, -1.0, 1.4)
	await _until(32.2)

	# 32.2 s: meanwhile, the Captain and Brutus.
	captain.distance = brutus.distance + 4.0
	_steer(captain, Vector2(0, 2.0))
	_steer(brutus, Vector2(0, -1.0))
	_follow(brutus, Vector3(4.0, 2.0, 6.0), Vector3(0, 0.5, -8.0))
	_say(brutus, "Pousse-toi, la pirate !", 2.0, 1.0, 1.4)
	await _until(34.6)
	for shot in 3:
		_ship_laser(captain, brutus)
		await _until(_clock + 0.25)
	_say(captain, "À l'abordage !", 1.8, -1.0, 1.4)
	_speed(1.5)
	await _until(37.4)

	# 37.4 s: second lap, the gauge fills.
	_narrate("Deuxième tour", 1.8)
	soldier.distance = length + 120.0
	vipere.distance = soldier.distance + 30.0
	captain.distance = soldier.distance - 15.0
	brutus.distance = soldier.distance - 40.0
	colt.distance = soldier.distance - 25.0
	for ship in ships:
		ship.skill = 1.0
	_steer(soldier, Vector2.ZERO)
	_follow(soldier, Vector3(0, 2.4, 8.0), Vector3(0, 0.5, -20.0))
	await _until(41.0)
	_say(soldier, "Un anneau... encore un...", 2.2, -1.0, 1.4)
	await _until(43.6)
	# Colt tries it too.
	colt.distance = soldier.distance - 4.0
	_steer(colt, soldier.offset + Vector2(0, 0.5))
	_follow(colt, Vector3(3.0, 2.0, 6.0), Vector3(0, 0.3, -12.0))
	_say(colt, "Dans le viseur, gamin.", 2.0, 1.0, 1.4)
	await _until(46.0)
	_steer(soldier, Vector2(5.0, -2.0))
	_beam(colt.global_position - colt.global_basis.z * 2.0, soldier.global_position + soldier.global_basis.x * 3.0, colt.color, 0.15)
	_follow(soldier, Vector3(-3.0, 1.0, 5.0), Vector3(0, 0.3, -6.0))
	_say(soldier, "Raté !", 1.4, -1.0, 1.4)
	_speed(1.5)
	await _until(48.0)
	_ship_laser(soldier, colt)
	_impact_frame()
	await _until(49.0)
	for shot in 2:
		_ship_laser(soldier, colt)
		await _until(_clock + 0.3)
	_follow(colt, Vector3(0, 3.0, 8.0), Vector3(0, 0, -5.0))
	_say(colt, "Mon moteur !", 1.8, 1.0, 1.4)
	await _until(52.6)

	# 52.6 s: last lap.
	_narrate("DERNIER TOUR", 2.0, true)
	soldier.distance = 2.0 * length + 200.0
	vipere.distance = soldier.distance + 45.0
	captain.distance = soldier.distance - 30.0
	brutus.distance = soldier.distance - 60.0
	colt.distance = soldier.distance - 90.0
	for ship in ships:
		ship.skill = 1.0
		_steer(ship, Vector2.ZERO)
	_follow(vipere, Vector3(0, 2.0, -9.0), Vector3(0, 0.6, 0))
	await _until(55.0)
	_say(vipere, "Personne ne bat Vipère.", 2.2, 1.0, 1.4)
	await _until(57.6)
	_follow(soldier, Vector3(0, 1.5, 6.0), Vector3(0, 0.5, -30.0))
	_say(captain, "Le boost, moussaillon ! MAINTENANT !", 2.4, 1.0, 1.4)
	await _until(60.4)
	_follow(soldier, Vector3(1.2, 0.9, -2.5), Vector3(0, 0.5, 0))
	_speed(2.0)
	_say(soldier, "OVERCLOCK !", 1.8, -1.0, 1.4)
	await _until(62.4)
	soldier.boost(8.0)
	soldier.skill = 1.25
	_impact_frame()
	_shake = 0.25
	_follow(soldier, Vector3(0, 2.0, 7.0), Vector3(0, 0.5, -30.0))
	_speed(10.0)
	await _until(68.0)

	# 68 s: he catches her up.
	soldier.distance = vipere.distance - 8.0
	_steer(soldier, Vector2(-2.0, 0.5))
	_steer(vipere, Vector2(2.0, 0))
	soldier.skill = 1.02
	vipere.skill = 1.0
	_follow(vipere, Vector3(-7.0, 1.5, 2.0), Vector3(-2.0, 0.3, -2.0))
	_say(vipere, "Quoi ?!", 1.6, 1.0, 1.4)
	await _until(70.4)
	_follow(soldier, Vector3(2.5, 1.0, -4.0), Vector3(0, 0.4, 0))
	_say(soldier, "J'apprends vite.", 1.8, -1.0, 1.4)
	await _until(72.8)

	# 72.8 s: the finish line, side by side.
	var finish := 3.0 * length
	soldier.distance = finish - 120.0
	vipere.distance = finish - 119.0
	soldier.skill = 1.0
	vipere.skill = 1.0
	soldier.boost_left = 0.0
	vipere.boost_left = 0.0
	soldier.speed = RaceShip.BASE_SPEED
	vipere.speed = RaceShip.BASE_SPEED
	_follow(soldier, Vector3(-3.0, 1.0, 6.0), Vector3(2.0, 0.5, -12.0))
	_speed(4.0)
	await _until(75.0)
	# Watched from the gold gate, as they come through.
	_dolly(track.frame_at(finish + 6.0, Vector2(9, 3)).origin, track.frame_at(finish + 4.0, Vector2(9, 3)).origin,
			track.frame_at(finish - 5.0).origin, track.frame_at(finish + 1.0).origin, 2.0)
	vipere.skill = 1.02
	await _until(77.0)
	_impact_frame()
	_shake = 0.3
	await _until(78.0)
	_narrate("VIPÈRE GAGNE... d'un cheveu.", 3.0, true)
	await _until(81.6)

	# 81.6 s: after the race, in the hangar.
	_load_arena(0)
	var pilot := _hero("soldier", STAGE + Vector3(-1.2, 0, 1), PI * 0.75)
	var rival := _hero("sand_ghost", STAGE + Vector3(1.2, 0, 0.6), -PI * 0.75)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(-2.8, 0, 2.6), PI * 0.6)
	_parked_ship(CYAN, STAGE + Vector3(-3.5, 0.8, -3.5), 0.4)
	_parked_ship(RED, STAGE + Vector3(3.5, 0.8, -3.5), -0.4)
	_dolly(STAGE + Vector3(0, 1.5, 7), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 1.3, 0.8),
			STAGE + Vector3(0, 1.3, 0.8), 8.0, true)
	await _until(83.0)
	_say(rival, "Pas mal... pour un débutant.", 2.4, 1.0)
	await _until(86.0)
	_say(pilot, "La prochaine fois, je gagne.", 2.4, -1.0)
	await _until(89.0)
	_say(rival, "Il n'y aura pas de prochaine fois.", 2.6, 1.0)
	await _until(92.0)
	_dolly(STAGE + Vector3(2.5, 1.6, 3.5), STAGE + Vector3(2.2, 1.6, 3.0), STAGE + Vector3(1.2, 1.5, 0.6),
			STAGE + Vector3(1.2, 1.5, 0.6), 6.0, true)
	_say(rival, "La station est à nous. On s'installe demain.", 3.0, 1.0)
	await _until(95.6)
	_dolly(STAGE + Vector3(-4.5, 1.5, 4.5), STAGE + Vector3(-4.0, 1.5, 4.0), STAGE + Vector3(-1.5, 1.4, 1.2),
			STAGE + Vector3(-1.5, 1.4, 1.2), 8.0, true)
	_say(kunoichi, "Non. Le pari, c'était une course...", 2.6, -1.0)
	await _until(98.6)
	_say(kunoichi, "...pas une guerre. Défendez-la, si vous l'osez.", 3.0, -1.0)
	_speed(1.5)
	await _until(102.0)
	_say(rival, "Avec plaisir.", 1.8, 1.0)
	_impact_frame()
	await _until(104.4)
	_dolly(STAGE + Vector3(0, 8, 12), STAGE + Vector3(0, 14, 16), STAGE + Vector3(0, 0, 0),
			STAGE + Vector3(0, 0, -6), 6.0, true)
	_narrate("La station sera le prochain champ de bataille.", 3.6)
	await _to_be_continued(108.4)
