extends AnimeDirector
## Épisode 4 : L'Escouade Écarlate. Squad against squad for the station's
## three zones. Neither side gives way, until the Directeur's guards attack
## them both; the Kunoichi finds his badge, and Vipère recognises it.


func _init() -> void:
	episode_number = 4
	episode_title = "L'ESCOUADE ÉCARLATE"
	duration = 120.0


func _story() -> void:
	# 0 s: the station, at night; three zones light up.
	_load_arena(0)
	var zone_a := _zone("A", STAGE + Vector3(-5, 0, -4), 0.0)
	var zone_b := _zone("B", STAGE + Vector3(0, 0, -10), 0.0)
	var zone_c := _zone("C", STAGE + Vector3(5, 0, -4), 0.0)
	_dolly(STAGE + Vector3(0, 9, 10), STAGE + Vector3(0, 7, 7), STAGE + Vector3(0, 0, -5),
			STAGE + Vector3(0, 0, -6), 8.0, true)
	_fade_shade(0.0, 1.2)
	_narrate("La station. Trois zones. Deux escouades.", 3.2)
	await _until(4.0)
	_narrate("Celle qui les tient toutes, garde la station.", 3.4)
	await _until(8.2)

	await _title_card(5.0)

	# 13.2 s: the two lines face each other.
	var soldier := _hero("soldier", STAGE + Vector3(-2.2, 0, 4), 0.0)
	var kunoichi := _hero("kunoichi", STAGE + Vector3(-0.8, 0, 4.4), 0.0)
	var captain := _hero("captain", STAGE + Vector3(0.8, 0, 4.4), 0.0)
	var ronin := _hero("ronin", STAGE + Vector3(2.2, 0, 4), 0.0)
	var vipere := _hero("sand_ghost", STAGE + Vector3(-2.2, 0, -14), PI)
	var brutus := _hero("viking", STAGE + Vector3(-0.8, 0, -14.4), PI)
	var hex := _hero("witch", STAGE + Vector3(0.8, 0, -14.4), PI)
	var colt := _hero("cowboy", STAGE + Vector3(2.2, 0, -14), PI)
	var squad: Array[CharacterModel] = [soldier, kunoichi, captain, ronin]
	var crimson: Array[CharacterModel] = [vipere, brutus, hex, colt]
	_dolly(STAGE + Vector3(-7, 1.0, -5), STAGE + Vector3(-6.5, 1.2, -5.5), STAGE + Vector3(0, 1.3, -5),
			STAGE + Vector3(0, 1.3, -5), 6.0, true)
	await _until(14.4)
	_say(vipere, "Prêts à perdre encore ?", 2.4, 1.0)
	await _until(17.2)
	_say(soldier, "J'ai perdu une course. Pas un combat.", 2.8, -1.0)
	await _until(20.4)
	_say(brutus, "BAGARRE !", 1.6, 1.0)
	_speed(1.6)
	await _until(22.0)

	# 22 s: the charge. Both lines run for the zones.
	for hero in squad:
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, -2.6))
	for hero in crimson:
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, 2.6))
	_dolly(STAGE + Vector3(0, 0.4, 7), STAGE + Vector3(0, 0.6, 6), STAGE + Vector3(0, 1.0, -5),
			STAGE + Vector3(0, 1.2, -5), 2.6, true)
	_speed(2.6)
	await _until(24.6)
	_movers.clear()
	for hero in squad + crimson:
		hero.play(&"aim")
	_impact_frame()

	# 24.6 s: zone A — the Kunoichi against Hex.
	_dolly(STAGE + Vector3(-9, 1.4, -1), STAGE + Vector3(-8.5, 1.5, -1.5), STAGE + Vector3(-5, 1.2, -4),
			STAGE + Vector3(-5, 1.2, -4), 6.0, true)
	kunoichi.get_parent().position = STAGE + Vector3(-5.5, 0, -2.5)
	hex.get_parent().position = STAGE + Vector3(-4.5, 0, -5.8)
	_face(kunoichi, hex)
	_face(hex, kunoichi)
	_turn_zone(zone_a, 0.6, 2.0)
	await _until(25.6)
	_say(hex, "Mes malédictions ne ratent jamais.", 2.4, 1.0)
	await _until(27.6)
	hex.play(&"shoot", true)
	_beam(hex.global_position + Vector3.UP * 1.3, kunoichi.global_position + Vector3.UP, Color(0.7, 0.3, 1.0), 0.12)
	Effects.burst(_set, kunoichi.global_position + Vector3.UP, Color(0.7, 0.3, 1.0), 30)
	await _until(28.4)
	# A clone took it: the real one is behind her.
	_tint(kunoichi, Color(0.4, 0.9, 1.0))
	var real := _hero("kunoichi", STAGE + Vector3(-3.2, 0, -6.6), -PI * 0.6)
	real.play(&"melee", true)
	_say(real, "Raté. C'était un clone.", 2.2, 1.0)
	_turn_zone(zone_a, 1.0, 1.5)
	await _until(31.0)
	kunoichi.get_parent().queue_free()
	kunoichi = real

	# 31 s: zone C — Brutus charges the Ronin.
	brutus.get_parent().position = STAGE + Vector3(4.5, 0, -7)
	ronin.get_parent().position = STAGE + Vector3(5.5, 0, -1.5)
	_face(brutus, ronin)
	_face(ronin, brutus)
	_dolly(STAGE + Vector3(9.5, 1.2, -4), STAGE + Vector3(9, 1.3, -4.5), STAGE + Vector3(5, 1.2, -4.3),
			STAGE + Vector3(5, 1.2, -4.3), 6.0, true)
	brutus.play(&"walk")
	_move(brutus.get_parent() as Node3D, (ronin.get_parent().position - brutus.get_parent().position).normalized() * 3.5)
	_turn_zone(zone_c, -0.7, 2.5)
	await _until(32.6)
	_say(brutus, "RAAAH !", 1.4, -1.0)
	_speed(1.4)
	await _until(33.8)
	_movers.clear()
	ronin.play(&"melee", true)
	_impact_frame()
	_ring(STAGE + Vector3(5, 0, -4.3), Color(1.0, 0.85, 0.9), 6.0, 0.4)
	brutus.play(&"die", true)
	_shake = 0.2
	await _until(35.0)
	_say(ronin, "Trop de bruit.", 1.8, 1.0)
	await _until(37.2)
	brutus.play(&"idle")
	_say(brutus, "...Il est fort, le petit.", 2.2, -1.0)
	await _until(39.8)

	# 39.8 s: zone B — the Captain and Colt shoot it out.
	captain.get_parent().position = STAGE + Vector3(-1.5, 0, -7)
	colt.get_parent().position = STAGE + Vector3(1.5, 0, -13)
	_face(captain, colt)
	_face(colt, captain)
	_dolly(STAGE + Vector3(-4, 1.0, -6), STAGE + Vector3(-3.5, 1.1, -6.5), STAGE + Vector3(0, 1.3, -10),
			STAGE + Vector3(0, 1.3, -10), 7.0, true)
	await _until(40.8)
	_say(colt, "Dégaine, pirate.", 1.8, 1.0)
	await _until(43.0)
	for shot in 4:
		var shooter: CharacterModel = captain if shot % 2 == 0 else colt
		var target: CharacterModel = colt if shot % 2 == 0 else captain
		shooter.play(&"shoot", true)
		_beam(shooter.global_position + Vector3.UP * 1.3, target.global_position + Vector3(randf_range(-1, 1), 1.6, 0),
				GOLD if shooter == captain else Color(0.75, 0.45, 1.0), 0.07)
		await _until(_clock + 0.45)
	_say(captain, "On est à égalité !", 2.0, -1.0)
	_turn_zone(zone_b, 0.0, 1.0)
	await _until(47.0)

	# 47 s: zones flip back and forth (a minute of battle, in seconds).
	_dolly(STAGE + Vector3(0, 12, 8), STAGE + Vector3(2, 11, 6), STAGE + Vector3(0, 0, -6),
			STAGE + Vector3(0, 0, -6), 8.0, true)
	_narrate("Dix minutes plus tard...", 2.6)
	_turn_zone(zone_a, -0.5, 1.5)
	_turn_zone(zone_c, 0.5, 1.5)
	await _until(49.0)
	_turn_zone(zone_a, 0.8, 1.5)
	_turn_zone(zone_b, -0.8, 1.5)
	await _until(51.0)
	_turn_zone(zone_c, -0.4, 1.5)
	_turn_zone(zone_b, 0.3, 1.5)
	await _until(53.0)
	_narrate("Personne ne lâche rien.", 2.4)
	await _until(55.6)

	# 55.6 s: Soldier and Vipère in the middle of B.
	soldier.get_parent().position = STAGE + Vector3(-1.2, 0, -9)
	vipere.get_parent().position = STAGE + Vector3(1.2, 0, -11)
	_face(soldier, vipere)
	_face(vipere, soldier)
	_dolly(STAGE + Vector3(-3.0, 1.5, -6.5), STAGE + Vector3(-2.8, 1.5, -7.0), STAGE + Vector3(0, 1.4, -10),
			STAGE + Vector3(0, 1.4, -10), 5.0, true)
	await _until(56.6)
	_say(vipere, "Tu ne lâches jamais, hein ?", 2.4, 1.0)
	await _until(59.4)
	_say(soldier, "Jamais.", 1.6, -1.0)
	await _until(61.4)
	_say(vipere, "...Moi non plus.", 2.0, 1.0)
	await _until(63.8)

	# 63.8 s: an alarm. Guards come out of the dark, at both squads.
	_impact_frame()
	_shake = 0.2
	_narrate("ALERTE", 1.6, true)
	var guards: Array[Enemy] = []
	for index in 6:
		var angle := TAU * index / 6.0
		var spot := STAGE + Vector3(0, 0, -6) + Vector3(cos(angle) * 11.0, 0, sin(angle) * 9.0)
		var guard := _enemy(spot, 0.0, &"walk")
		(guard.get_parent() as Node3D).look_at(STAGE + Vector3(0, 0.1, -6))
		var inward := (STAGE + Vector3(0, 0, -6) - spot).normalized() * 1.2
		_move(guard.get_parent() as Node3D, Vector3(inward.x, 0, inward.z))
		guards.append(guard)
	_dolly(STAGE + Vector3(0, 3, 8), STAGE + Vector3(0, 2.5, 7), STAGE + Vector3(0, 1, -6),
			STAGE + Vector3(0, 1, -6), 4.0, true)
	await _until(66.0)
	_say(colt, "C'est quoi, ça ?!", 1.8, 1.0)
	await _until(68.0)
	_say(soldier, "Pas les tiens ?", 1.8, -1.0)
	await _until(70.0)
	_say(vipere, "...Non.", 1.6, 1.0)
	await _until(71.8)

	# 71.8 s: back to back, both squads fight the guards.
	var everyone: Array[CharacterModel] = [soldier, kunoichi, captain, ronin, vipere, brutus, hex, colt]
	for index in everyone.size():
		var angle := TAU * index / everyone.size()
		var pivot := everyone[index].get_parent() as Node3D
		pivot.position = STAGE + Vector3(0, 0, -6) + Vector3(cos(angle), 0, sin(angle)) * 2.0
		pivot.look_at(pivot.position * 2.0 - (STAGE + Vector3(0, 0, -6)))
		everyone[index].play(&"aim")
	_dolly(STAGE + Vector3(-1, 5.5, -2.5), STAGE + Vector3(1, 5.5, -2.5), STAGE + Vector3(0, 0, -6),
			STAGE + Vector3(0, 0, -6), 6.0, true)
	_speed(6.0)
	_say(ronin, "Dos à dos.", 1.6, 1.0)
	await _until(73.8)
	for index in guards.size():
		var hero := everyone[index]
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3.UP * 1.3, guards[index].global_position + Vector3.UP, CYAN if index < 4 else RED, 0.08)
		_kill(guards[index], [&"vanish", &"burn", &"shatter", &"confetti", &"pixelate", &"flare"][index], CYAN if index < 4 else RED)
		await _until(_clock + 0.45)
	_impact_frame()
	await _until(78.0)

	# 78 s: on a fallen guard, a badge.
	_movers.clear()
	_dolly(STAGE + Vector3(-1.5, 0.9, -3.0), STAGE + Vector3(-1.4, 0.8, -3.4), STAGE + Vector3(-1.2, 0.3, -5.5),
			STAGE + Vector3(-1.2, 0.3, -5.5), 6.0, true)
	var badge := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.25
	disc.bottom_radius = 0.25
	disc.height = 0.04
	var gold := StandardMaterial3D.new()
	gold.albedo_color = GOLD
	gold.emission_enabled = true
	gold.emission = GOLD
	gold.emission_energy_multiplier = 1.5
	disc.material = gold
	badge.mesh = disc
	badge.position = STAGE + Vector3(-1.2, 0.15, -5.5)
	_set.add_child(badge)
	kunoichi.get_parent().position = STAGE + Vector3(-2.2, 0, -4.6)
	_face(kunoichi, badge)
	await _until(79.0)
	_say(kunoichi, "Un insigne... « Le Directeur ».", 2.8, -1.0)
	await _until(82.4)
	_dolly(STAGE + Vector3(1.8, 1.6, -3.2), STAGE + Vector3(1.6, 1.6, -3.6), STAGE + Vector3(0.8, 1.5, -6.6),
			STAGE + Vector3(0.8, 1.5, -6.6), 6.0, true)
	vipere.get_parent().position = STAGE + Vector3(0.8, 0, -6.6)
	_face(vipere, badge)
	_say(vipere, "Le Directeur...", 2.0, 1.0)
	await _until(84.8)
	_speed(1.8)
	_say(vipere, "C'est lui qui nous paie.", 2.4, 1.0)
	_impact_frame()
	await _until(87.8)
	_dolly(STAGE + Vector3(-3, 1.5, -1), STAGE + Vector3(-2.5, 1.5, -1.5), STAGE + Vector3(-1.2, 1.4, -4.8),
			STAGE + Vector3(-1.2, 1.4, -4.8), 6.0, true)
	soldier.get_parent().position = STAGE + Vector3(-1.2, 0, -4.6)
	_face(soldier, vipere)
	_say(soldier, "Et qui a construit le Titan, d'après toi ?", 3.0, -1.0)
	await _until(91.4)
	_say(hex, "Mes cartes avaient raison. Mais pas sur vous.", 3.0, 1.0)
	await _until(95.0)

	# 95 s: the Écarlate leave, troubled.
	_dolly(STAGE + Vector3(0, 2.0, 6), STAGE + Vector3(0, 2.5, 5), STAGE + Vector3(0, 1.2, -8),
			STAGE + Vector3(0, 1.2, -12), 6.0, true)
	for hero: CharacterModel in [vipere, brutus, hex, colt]:
		hero.get_parent().rotation.y = 0.0
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, -2.0))
	_say(vipere, "La station est à vous. Pour l'instant.", 2.8, 1.0)
	await _until(98.4)
	_say(captain, "Elle a l'air secouée.", 2.0, -1.0)
	await _until(100.8)
	_say(kunoichi, "Il faut trouver ce Directeur.", 2.4, -1.0)
	await _until(103.6)
	_movers.clear()
	_dolly(STAGE + Vector3(0, 6, 9), STAGE + Vector3(0, 12, 14), STAGE + Vector3(0, 1, -2),
			STAGE + Vector3(0, 1, -4), 6.0, true)
	_narrate("Ses traces mènent au désert.", 3.4)
	await _to_be_continued(108.0)
