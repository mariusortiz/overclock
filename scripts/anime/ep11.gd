extends Season2Episode
## Épisode 11 : Le glitch. Peace in the city, months after the Titan Mk II.
## Then the world tears: buildings flicker, enemies come back corrupted. On a
## roof, a man with a cow's head watches, and vanishes.


func _init() -> void:
	episode_number = 11
	episode_title = "LE GLITCH"
	duration = 110.0


func _story() -> void:
	# 0 s: the city at peace.
	_load_arena(4)
	var soldier := _hero("soldier", STAGE + Vector3(-1.2, 0, 1.5), PI * 0.9, "none")
	var vipere := _hero("sand_ghost", STAGE + Vector3(1.0, 0, 1.8), -PI * 0.9, "none")
	soldier.play(&"idle")
	vipere.play(&"idle")
	_dolly(STAGE + Vector3(-6, 6, 12), STAGE + Vector3(-3, 3, 8), STAGE + Vector3(0, 2, -4), STAGE + Vector3(0, 1.4, 1), 7.5, true)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Trois mois après le Titan Mk II. La ville respire.", 3.4)
	await _until(5.5)
	_narrate("Personne ne se doute que le monde lui-même est en train de casser.", 3.6)
	await _until(9.4)
	await _title_card(5.0)

	# 14.4 s: an ordinary day.
	_face(soldier, vipere)
	_face(vipere, soldier)
	_dolly(STAGE + Vector3(3.0, 1.5, 4.0), STAGE + Vector3(2.4, 1.5, 3.6), STAGE + Vector3(0, 1.4, 1.6), STAGE + Vector3(0, 1.4, 1.6), 9.0, true)
	await _until(15.0)
	_say(vipere, "Tu t'ennuies, soldat ? Ça fait trois mois sans une vague.", 3.0, 1.0)
	await _until(18.4)
	_say(soldier, "Je m'habitue au calme.", 2.2, -1.0)
	await _until(21.0)
	_say(vipere, "Moi, je déteste ça.", 2.0, 1.0)
	await _until(23.6)

	# 23.6 s: the first glitch.
	_glitch(1.2)
	_impact_frame()
	await _until(24.8)
	_dolly(STAGE + Vector3(0, 1.2, 6), STAGE + Vector3(0, 1.4, 5), STAGE + Vector3(0, 2, -6), STAGE + Vector3(0, 3, -10), 4.0, true)
	_say(soldier, "... Tu as vu ça ?", 2.0, -1.0)
	await _until(27.2)
	_say(vipere, "La rue a sauté. Comme une vieille vidéo.", 2.6, 1.0)
	await _until(30.2)
	_glitch(0.8)
	await _until(31.2)

	# 31.2 s: they come back, but wrong.
	var enemies: Array[Enemy] = []
	for index in 6:
		var at := STAGE + Vector3(-5.0 + 2.0 * index, 0, -10.0 - (index % 2) * 1.5)
		var enemy := _corrupted(at, 0.0, &"walk")
		_move(enemy.get_parent() as Node3D, Vector3(0, 0, 0.6))
		enemies.append(enemy)
		_appear(enemy, 0.4)
	_dolly(STAGE + Vector3(-4, 1.0, -2), STAGE + Vector3(-3, 1.2, -3), STAGE + Vector3(0, 1.2, -10), STAGE + Vector3(0, 1.2, -9), 4.0, true)
	await _until(33.0)
	_narrate("Des gardes du Directeur. Mais le Directeur est en prison...", 3.2)
	await _until(36.4)
	soldier.play(&"aim")
	vipere.play(&"aim")
	_face(soldier, enemies[2])
	_face(vipere, enemies[3])
	_dolly(STAGE + Vector3(2.5, 1.5, 5), STAGE + Vector3(2, 1.5, 4.4), STAGE + Vector3(0, 1.2, -4), STAGE + Vector3(0, 1.2, -6), 4.0, true)
	_say(soldier, "Ils sont... verts ?", 1.8, -1.0)
	await _until(38.6)
	_say(vipere, "Pose les questions après !", 2.0, 1.0)
	await _until(40.8)

	# 40.8 s: the fight.
	var first_spot := enemies[0].global_position
	for index in 4:
		await _until(41.0 + 0.7 * index)
		var hero := soldier if index % 2 == 0 else vipere
		_shoot(hero, enemies[index], &"pixelate", CYAN if hero == soldier else RED)
	_speed(1.0)
	await _until(44.4)
	# Shot down, one stands up again, flickering.
	var back := _corrupted(first_spot, 0.0, &"walk")
	_appear(back, 0.5)
	_dolly(STAGE + Vector3(-3, 0.8, -4), STAGE + Vector3(-2.5, 1.0, -4.5), back.global_position + Vector3.UP, back.global_position + Vector3.UP, 3.0, true)
	await _until(45.4)
	_say(soldier, "Il s'est relevé !", 1.6, -1.0)
	await _until(47.6)
	_glitch(1.0)
	for index in range(4, 6):
		_shoot(vipere, enemies[index], &"pixelate", RED)
		await _until(_clock + 0.5)
	_shoot(soldier, back, &"pixelate", CYAN)
	await _until(50.4)

	# 50.4 s: a figure on the roof.
	_dolly(STAGE + Vector3(0, 1.4, 4), STAGE + Vector3(0, 1.6, 3), STAGE + Vector3(0, 2, -4), STAGE + Vector3(4, 7, -16), 3.0, true)
	await _until(51.0)
	var creator := _creator(STAGE + Vector3(4, 6.0, -16), PI)
	_appear(creator)
	await _until(53.4)
	_dolly(STAGE + Vector3(4.6, 7.2, -13.2), STAGE + Vector3(4.4, 7.0, -13.6), STAGE + Vector3(4, 7.2, -16), STAGE + Vector3(4, 7.2, -16), 4.0)
	_narrate("Sur un toit, un homme en costume... avec une tête de vache.", 3.4)
	await _until(57.2)
	_say(creator, "Ça commence.", 2.0, 1.0)
	await _until(59.6)
	_vanish(creator)
	await _until(60.6)
	_dolly(STAGE + Vector3(2.5, 1.5, 5), STAGE + Vector3(2, 1.6, 4.4), STAGE + Vector3(0, 1.4, 1.5), STAGE + Vector3(0, 1.4, 1.5), 6.0, true)
	soldier.play(&"idle")
	vipere.play(&"idle")
	_face(soldier, vipere)
	_face(vipere, soldier)
	_say(vipere, "Une vache. En costume. Sur un toit.", 2.6, 1.0)
	await _until(63.6)
	_say(soldier, "J'ai vu pareil. Et elle a disparu comme les gardes.", 3.0, -1.0)
	await _until(67.2)

	# 67.2 s: the squad.
	_wipe()
	_load_showroom()
	var squad := {}
	for index in 4:
		var id: String = ["kunoichi", "soldier", "captain", "ronin"][index]
		squad[id] = _hero(id, Vector3(-2.4 + 1.6 * index, 0, 0), 0.0 if index != 1 else PI, "none")
	squad["sand_ghost"] = _hero("sand_ghost", Vector3(4.0, 0, 0.6), 0.0, "none")
	_dolly(Vector3(0, 1.6, -6.5), Vector3(0, 1.5, -5.0), Vector3(0, 1.2, 0), Vector3(0, 1.2, 0), 6.0)
	await _until(68.0)
	_say(squad.soldier, "Des ennemis qui reviennent. La rue qui saute.", 2.8, 1.0)
	await _until(71.2)
	_say(squad.kunoichi, "Sur les écrans de la station aussi. Du code qui défile.", 3.0, -1.0)
	await _until(74.6)
	_say(squad.captain, "Une panne ?", 1.6, 1.0)
	await _until(76.6)
	_say(squad.ronin, "Une maladie.", 1.8, -1.0)
	await _until(78.8)
	_glitch(1.5)
	_impact_frame()
	await _until(80.4)
	_narrate("Le monde d'Overclock vient d'attraper un virus.", 3.4, true)
	await _until(84.4)
	_fade_shade(0.8, 0.6)
	await _until(85.0)
	_fade_shade(0.0, 0.6)
	_dolly(Vector3(4, 1.6, -4), Vector3(3.6, 1.6, -4.6), Vector3(0, 1.3, 0), Vector3(0, 1.3, 0), 8.0)
	_say(squad.sand_ghost, "Et la vache ?", 1.6, 1.0)
	await _until(87.2)
	_say(squad.soldier, "Elle sait quelque chose. Il faut la retrouver.", 2.8, -1.0)
	await _until(90.6)
	await _to_be_continued(96.0)
