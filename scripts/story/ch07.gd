extends StoryScene
## Chapitre 7 : Alliance. The squad, the Écarlate and two new allies.


func _init() -> void:
	episode_number = 7
	episode_title = "ALLIANCE"
	duration = 30.0


func _story() -> void:
	await _title_card(2.6)
	_load_showroom()
	_fade_shade(0.0, 0.6)
	var ids := ["ronin", "kunoichi", "soldier", "sand_ghost", "captain"]
	var line := {}
	for index in ids.size():
		line[ids[index]] = _hero(ids[index], Vector3(-4.0 + 2.0 * index, 0, 0), 0.0 if index != 2 else PI)
	_dolly(Vector3(0, 1.6, -6.5), Vector3(0, 1.5, -5.0), Vector3(0, 1.2, 0), Vector3(0, 1.2, 0), 6.0)
	_narrate("La station. L'escouade et l'Écarlate, enfin du même côté.", 3.4)
	await _until(6.4)
	_say(line.soldier, "Le Directeur construit un second Titan.", 2.6, 1.0)
	await _until(9.4)
	_say(line.sand_ghost, "Et il nous faut plus de monde.", 2.4, -1.0)
	await _until(12.0)
	var paladin := _hero("paladin", Vector3(-6, 0, -8), PI * 0.8)
	var godfather := _hero("godfather", Vector3(6, 0, -8), -PI * 0.8)
	for hero in [paladin, godfather]:
		hero.play(&"walk", true)
	_move(paladin.get_parent() as Node3D, Vector3(0.9, 0, 1.2))
	_move(godfather.get_parent() as Node3D, Vector3(-0.9, 0, 1.2))
	_dolly(Vector3(0, 2.4, -14), Vector3(0, 2.0, -12), Vector3(0, 1.2, -6), Vector3(0, 1.2, -5), 4.0)
	await _until(15.4)
	_movers.clear()
	paladin.play(&"idle")
	godfather.play(&"idle")
	_say(godfather, "Le Directeur me doit de l'argent.", 2.6, 1.0)
	await _until(18.2)
	_say(paladin, "Et à moi, une revanche.", 2.2, -1.0)
	await _until(20.8)
	_dolly(Vector3(0, 1.6, -6.5), Vector3(0, 1.8, -7.5), Vector3(0, 1.2, -1), Vector3(0, 1.2, -1), 5.0)
	_say(line.soldier, "Entraînement en ville. Puis, le volcan.", 2.8, 1.0)
	for hero in line.values():
		(hero as CharacterModel).play(&"victory", true)
	await _until(24.0)
	_narrate("MISSION : avec le Parrain, tiens les zones de la ville.", 3.8)
	await _until(28.6)
	_fade_shade(1.0, 1.0)
