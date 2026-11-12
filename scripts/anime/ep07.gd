extends AnimeDirector
## Épisode 7 : Alliance. The squad and the Écarlate meet in the station's
## hall. Two new allies come forward, the Paladine d'or and the Parrain; the
## exotic guns are handed out; the plan for the volcano is made.


func _init() -> void:
	episode_number = 7
	episode_title = "ALLIANCE"
	duration = 120.0


func _story() -> void:
	# 0 s: the hall, the two squads face each other.
	_load_showroom()
	var squad: Array[CharacterModel] = []
	for index in 5:
		var id: String = ["soldier", "kunoichi", "captain", "ronin", "cowgirl"][index]
		squad.append(_hero(id, Vector3(-7.0 + 1.4 * index, 0, 0), PI / 2.0))
	var crimson: Array[CharacterModel] = []
	for index in 4:
		var id: String = ["sand_ghost", "viking", "witch", "cowboy"][index]
		crimson.append(_hero(id, Vector3(7.0 - 1.4 * index, 0, 0), -PI / 2.0))
	var soldier := squad[0]
	var kunoichi := squad[1]
	var captain := squad[2]
	var ronin := squad[3]
	var vipere := crimson[0]
	var brutus := crimson[1]
	var hex := crimson[2]
	var colt := crimson[3]
	for hero in squad:
		hero.get_parent().rotation.y = -PI / 2.0
	for hero in crimson:
		hero.get_parent().rotation.y = PI / 2.0
	_dolly(Vector3(0, 2.5, 12), Vector3(0, 2.0, 9), Vector3(0, 1.2, 0), Vector3(0, 1.2, 0), 8.0)
	_fade_shade(0.0, 1.2)
	_narrate("Le hall de la station. Terrain neutre.", 3.0)
	await _until(3.6)
	_say(brutus, "On ne va pas se faire de câlins.", 2.4, 1.0)
	await _until(6.2)
	_say(captain, "Ça me va très bien.", 2.0, -1.0)
	await _until(8.4)

	await _title_card(5.0)

	# 13.4 s: Soldier and Vipère step forward and shake hands.
	_dolly(Vector3(0, 1.5, 4), Vector3(0, 1.5, 3.2), Vector3(0, 1.4, 0), Vector3(0, 1.4, 0), 8.0)
	soldier.play(&"walk")
	vipere.play(&"walk")
	create_tween().tween_property(soldier.get_parent(), "position", Vector3(-0.8, 0, 0), 1.6)
	create_tween().tween_property(vipere.get_parent(), "position", Vector3(0.8, 0, 0), 1.6)
	await _until(15.2)
	soldier.play(&"idle")
	vipere.play(&"idle")
	_say(vipere, "Une trêve. Jusqu'à la chute du Directeur.", 3.0, 1.0)
	await _until(18.6)
	_say(soldier, "Et après ?", 1.6, -1.0)
	await _until(20.6)
	_say(vipere, "Après, je te rebats à la course.", 2.6, 1.0)
	await _until(23.6)
	soldier.play(&"melee", true)
	vipere.play(&"melee", true)
	_impact_frame()
	_ring(Vector3(0, 0, 0), GOLD, 8.0, 0.6)
	_speed(1.4)
	_say(hex, "Mes cartes l'avaient prédit.", 2.4, 1.0)
	await _until(26.4)
	_say(colt, "Tes cartes prédisent tout, Hex.", 2.4, 1.0)
	await _until(29.2)

	# 29.2 s: two strangers arrive: gold armour, and a hat.
	var paladin := _hero("paladin", Vector3(-1.5, 0, -14), 0.0)
	var godfather := _hero("godfather", Vector3(1.5, 0, -14), 0.0)
	for newcomer: CharacterModel in [paladin, godfather]:
		newcomer.get_parent().rotation.y = PI
		newcomer.play(&"walk")
		_move(newcomer.get_parent() as Node3D, Vector3(0, 0, 2.2))
	_dolly(Vector3(0, 0.6, 3), Vector3(0, 0.7, 2), Vector3(0, 1.6, -12), Vector3(0, 1.6, -6), 4.4)
	await _until(30.4)
	_say(paladin, "On a entendu parler du Titan Mk II.", 2.6, -1.0)
	await _until(33.6)
	_movers.clear()
	paladin.play(&"idle")
	godfather.play(&"idle")
	_narrate("LA PALADINE D'OR · LE PARRAIN", 2.6)
	_dolly(Vector3(-1.5, 1.6, -2.5), Vector3(-1.4, 1.6, -3.0), Vector3(-1.5, 1.6, -5.2), Vector3(-1.5, 1.7, -5.2), 3.0)
	_say(paladin, "La lumière est avec vous.", 2.2, 1.0)
	await _until(36.4)
	_dolly(Vector3(1.5, 1.5, -2.5), Vector3(1.4, 1.5, -3.0), Vector3(1.5, 1.6, -5.2), Vector3(1.5, 1.6, -5.2), 3.0)
	_say(godfather, "Et le Directeur me doit de l'argent.", 2.6, -1.0)
	await _until(39.4)
	_say(captain, "Lui, je l'aime bien.", 1.8, 1.0)
	await _until(41.6)

	# 41.6 s: the armoury: the exotic guns, floating in a row.
	_load_showroom()
	var guns: Array[Node3D] = []
	var exotic := Loadout.WEAPONS.filter(func(item: Dictionary) -> bool: return item.get("shop", false))
	var finishes := Loadout.SKINS.filter(func(item: Dictionary) -> bool: return item.get("shop", false))
	for index in exotic.size():
		var gun := Loadout.instantiate_weapon(exotic[index], finishes[index % finishes.size()])
		var holder := Node3D.new()
		holder.position = Vector3(index * 2.4, 1.3, 0)
		holder.add_child(gun)
		gun.scale = Vector3.ONE * (1.0 / float(exotic[index].length))
		gun.position.z = 0.4
		_set.add_child(holder)
		create_tween().set_loops(4).tween_property(holder, "rotation:y", TAU, 4.0).from(0.0)
		guns.append(holder)
		var label := Label3D.new()
		label.text = str(exotic[index].name).to_upper()
		label.font = FONT
		label.font_size = 40
		label.pixel_size = 0.005
		label.outline_size = 10
		label.position = Vector3(index * 2.4, 0.55, 0)
		_set.add_child(label)
	_dolly(Vector3(-1.5, 1.5, 3.5), Vector3((exotic.size() - 1) * 2.4 + 1.5, 1.5, 3.5), Vector3(-1.5, 1.2, 0),
			Vector3((exotic.size() - 1) * 2.4 + 1.5, 1.2, 0), 9.0)
	_narrate("L'arsenal du Parrain.", 3.0)
	await _until(45.0)
	var host := _hero("godfather", Vector3(-1.2, 0, 1.6), PI * 0.8)
	_say(host, "Laser, fusil à rail, plasma, minigun...", 3.0, 1.0)
	await _until(48.4)
	_say(host, "Servez-vous. C'est la maison qui offre.", 3.0, 1.0)
	await _until(51.6)

	# 51.6 s: each picks one.
	_load_showroom()
	soldier = _hero("soldier", Vector3(-3.0, 0, 0), PI, "minigun")
	kunoichi = _hero("kunoichi", Vector3(-1.5, 0, 0.3), PI, "laser")
	vipere = _hero("sand_ghost", Vector3(0, 0, 0.4), PI, "railgun")
	captain = _hero("captain", Vector3(1.5, 0, 0.3), PI, "plasma")
	ronin = _hero("ronin", Vector3(3.0, 0, 0), PI, "flamer")
	_dolly(Vector3(-3.0, 1.5, 2.6), Vector3(-2.8, 1.5, 2.3), Vector3(-3.0, 1.3, 0), Vector3(-3.0, 1.3, 0), 2.4)
	soldier.play(&"aim")
	_say(soldier, "Le minigun. Évidemment.", 2.0, 1.0)
	await _until(54.0)
	_dolly(Vector3(0, 1.5, 2.6), Vector3(0.2, 1.5, 2.3), Vector3(0, 1.3, 0.4), Vector3(0, 1.3, 0.4), 2.4)
	vipere.play(&"aim")
	_say(vipere, "Le fusil à rail. Il traverse tout.", 2.2, 1.0)
	await _until(56.6)
	_dolly(Vector3(3.0, 1.5, 2.6), Vector3(2.8, 1.5, 2.3), Vector3(3.0, 1.3, 0), Vector3(3.0, 1.3, 0), 2.4)
	ronin.play(&"aim")
	_say(ronin, "...Le lance-flammes ?", 2.0, -1.0)
	await _until(59.0)
	_say(captain, "Tout le monde peut changer !", 2.0, -1.0)
	await _until(61.4)
	_dolly(Vector3(0, 2.2, 8), Vector3(0, 1.8, 6.5), Vector3(0, 1.2, 0), Vector3(0, 1.2, 0), 4.0)
	for hero: CharacterModel in [soldier, kunoichi, vipere, captain, ronin]:
		hero.play(&"shoot", true)
	_impact_frame()
	_speed(1.5)
	await _until(64.0)

	# 64 s: the plan, around a map of the volcano.
	_load_arena(3)
	var planners: Array[CharacterModel] = []
	var ids := ["soldier", "kunoichi", "captain", "ronin", "cowgirl", "sand_ghost", "viking", "witch", "cowboy", "paladin", "godfather"]
	for index in ids.size():
		var angle := TAU * index / ids.size()
		var hero := _hero(ids[index], STAGE + Vector3(cos(angle) * 3.2, 0, sin(angle) * 3.2), 0.0, "none")
		var pivot := hero.get_parent() as Node3D
		pivot.look_at(Vector3(STAGE.x, pivot.position.y, STAGE.z))
		planners.append(hero)
	soldier = planners[0]
	vipere = planners[5]
	brutus = planners[6]
	var godfather_again := planners[10]
	_dolly(STAGE + Vector3(0, 9, 7), STAGE + Vector3(2, 8, 6), STAGE, STAGE, 9.0, true)
	_embers(true)
	_narrate("Onze héros. Un seul plan.", 3.0)
	await _until(67.0)
	_say(vipere, "L'entrée de service est au nord.", 2.4, 1.0)
	await _until(69.8)
	_say(soldier, "On entre par là. Discrètement.", 2.4, -1.0)
	await _until(72.6)
	_say(brutus, "Discrètement ? Moi ?", 2.0, 1.0)
	await _until(75.0)
	_say(godfather_again, "J'ai prévu une diversion.", 2.2, -1.0)
	await _until(77.6)
	_dolly(STAGE + Vector3(-5, 1.6, 5), STAGE + Vector3(-4.5, 1.6, 4.5), STAGE + Vector3(0, 1.3, 0),
			STAGE + Vector3(0, 1.3, 0), 8.0, true)
	_say(planners[1], "Et si le Titan Mk II est déjà prêt ?", 2.6, 1.0)
	await _until(80.6)
	_say(planners[9], "Alors on prie très fort.", 2.2, -1.0)
	await _until(83.2)
	_say(planners[3], "Et on frappe plus fort encore.", 2.4, 1.0)
	await _until(86.0)

	# 86 s: everybody's hand in the middle.
	_dolly(STAGE + Vector3(0, 5.5, 0.5), STAGE + Vector3(0, 5.0, 0.5), STAGE, STAGE, 6.0, true)
	for hero in planners:
		hero.play(&"melee", true)
	await _until(87.0)
	_impact_frame()
	_ring(STAGE, GOLD, 12.0, 0.8)
	_speed(2.0)
	_say(soldier, "ESCOUADE !", 1.8, -1.0)
	await _until(89.2)
	for index in planners.size():
		if index % 3 == 0:
			_say(planners[index], "ESCOUADE !", 1.6, -1.0 if index < 5 else 1.0)
	await _until(91.6)

	# 91.6 s: night falls on the volcano.
	_embers(false)
	_dolly(STAGE + Vector3(0, 3, 10), STAGE + Vector3(0, 12, 18), STAGE + Vector3(0, 2, -5),
			STAGE + Vector3(0, 10, -40), 10.0, true)
	_narrate("Cette nuit, ils entrent dans le volcan.", 3.4)
	await _until(96.0)
	_narrate("Le Directeur les attend.", 3.0)
	await _to_be_continued(101.0)
