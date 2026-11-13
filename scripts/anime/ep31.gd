extends Season3Episode
## Hors-série, épisode 31 : Les Compagnons. A quiet day at the station: each
## hero shows off a pet, Le Créateur brings an egg he found in the hangar (a
## calf hatches out of it), and a little dragon sneezes fire. Introduces the
## game's pets (Pets).


func _init() -> void:
	episode_number = 31
	episode_title = "LES COMPAGNONS"
	duration = 67.0


## Each hero and the pet beside them.
const PAIRS := [["soldier", "pet_dog"], ["kunoichi", "pet_fox"], ["sand_ghost", "pet_drone"], ["cowgirl", "pet_pig"], ["captain", "pet_eagle"], ["ronin", "pet_wolf"]]


## A pet of Pets.LIST at `at`, facing `facing`, cel-shaded, its idle on.
func _pet(id: String, at: Vector3, facing: float) -> Node3D:
	var pet := Pets.find(id)
	var model := Pet.build_model(pet)
	_set.add_child(model)
	model.position = at + (Vector3.UP * 1.2 if pet.get("fly", false) else Vector3.ZERO)
	model.rotation.y = facing
	Pet.play_idle(model)
	_toon(model)
	return model


func _hop(model: Node3D, times: int) -> void:
	var tween := create_tween()
	var ground := model.position.y
	for i in times:
		tween.tween_property(model, "position:y", ground + 0.35, 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(model, "position:y", ground, 0.15).set_ease(Tween.EASE_IN)


func _story() -> void:
	_load_arena(0)
	var heroes := {}
	var pets := {}
	for index in PAIRS.size():
		var at := STAGE + Vector3(-6.0 + 2.4 * index, 0, -1)
		heroes[PAIRS[index][0]] = _hero(PAIRS[index][0], at, PI, "none")
		pets[PAIRS[index][0]] = _pet(PAIRS[index][1], at + Vector3(0.75, 0, 0.5), PI)
	_dolly(STAGE + Vector3(-7, 2.4, 9), STAGE + Vector3(-3, 2.0, 7), STAGE + Vector3(0, 0.8, -1), STAGE + Vector3(0, 1.0, -1), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Hors-série. Une journée tranquille à la station.", 3.0)
	await _until(4.8)
	_say(heroes.captain, "Présentation des nouvelles recrues !", 2.2, 1.0)
	await _until(7.4)
	await _title_card(5.0)

	# 12.4 s: each hero and their pet.
	var lines := {
		"soldier": "Lui, il rapporte tout ce qui brille.",
		"kunoichi": "Le renard me trouve, même cachée.",
		"sand_ghost": "Mon drone vise mieux que vous tous.",
		"cowgirl": "Le cochon, c'est pour les économies.",
		"captain": "Un aigle. Évidemment.",
	}
	var time := 12.4
	for id: String in lines:
		var hero: CharacterModel = heroes[id]
		var pet: Node3D = pets[id]
		var spot: Vector3 = (hero.global_position + pet.global_position) * 0.5
		_dolly(spot + Vector3(-0.6, 1.4, 3.2), spot + Vector3(0.4, 1.3, 2.8), spot + Vector3(0, 0.9, 0), spot + Vector3(0, 0.9, 0), 3.2)
		_say(hero, lines[id], 2.6, -1.0)
		get_tree().create_timer(0.8).timeout.connect(_hop.bind(pet, 2))
		time += 3.2
		await _until(time)

	# 28.4 s: Le Créateur and his egg.
	var creator := _creator(STAGE + Vector3(0, 0, 3.2), PI)
	_appear(creator, 0.6)
	var egg := MeshInstance3D.new()
	var shell := SphereMesh.new()
	shell.radius = 0.3
	shell.height = 0.8
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.95, 0.88)
	shell.material = white
	egg.mesh = shell
	_set.add_child(egg)
	egg.position = STAGE + Vector3(0, 0.4, 4.2)
	_toon(egg)
	_dolly(STAGE + Vector3(1.4, 1.5, 7.6), STAGE + Vector3(1.0, 1.3, 7.0), STAGE + Vector3(0, 1.0, 3.6), STAGE + Vector3(0, 0.6, 4.0), 8.0)
	await _until(29.2)
	_say(creator, "J'ai trouvé ça dans le hangar.", 2.2, 1.0)
	await _until(31.8)
	_say(heroes.soldier, "Un œuf ? Il bouge !", 1.8, -1.0)
	var wobble := create_tween().set_loops(6)
	wobble.tween_property(egg, "rotation:z", 0.3, 0.12)
	wobble.tween_property(egg, "rotation:z", -0.3, 0.12)
	await _until(34.4)
	_impact_frame()
	Effects.burst(_set, egg.global_position, white.albedo_color, 50)
	Effects.flash(_set, egg.global_position, GOLD, 8.0, 0.4)
	egg.queue_free()
	var calf := _pet("pet_calf", STAGE + Vector3(0, 0, 4.2), PI)
	_hop(calf, 3)
	# He turns round to the camera, beyond the calf.
	(creator.get_parent() as Node3D).rotation.y = PI
	await _until(35.6)
	_narrate("Un veau.", 1.8, true)
	await _until(38.0)
	_say(heroes.sand_ghost, "Il te ressemble.", 1.8, -1.0)
	await _until(40.2)
	_dolly(STAGE + Vector3(0.6, 1.6, 5.4), STAGE + Vector3(0.5, 1.6, 5.2), STAGE + Vector3(0, 1.5, 3.2), STAGE + Vector3(0, 1.5, 3.2), 5.0)
	_say(creator, "Il a mes yeux. Et mon sens du design.", 2.6, 1.0)
	await _until(43.4)

	# 43.4 s: the little dragon.
	var ronin: CharacterModel = heroes.ronin
	_dolly(ronin.global_position + Vector3(2.2, 1.6, 3.4), ronin.global_position + Vector3(1.8, 1.6, 3.0),
			ronin.global_position + Vector3(0.4, 1.2, 0), ronin.global_position + Vector3(0.4, 1.2, 0), 8.0)
	_say(ronin, "Le mien est le plus calme de tous.", 2.2, -1.0)
	await _until(46.0)
	var dragon := _pet("pet_dragon", ronin.global_position + Vector3(0.8, 0, 0.6), PI)
	(pets.ronin as Node3D).visible = false
	_appear(dragon, 0.4)
	await _until(47.0)
	_narrate("ATCHOUM", 1.2, true)
	_beam(dragon.global_position + Vector3(0, 0.4, 0), ronin.global_position + Vector3(0, 1.8, 0), Color(1.0, 0.5, 0.1), 0.25)
	Effects.burst(_set, ronin.global_position + Vector3(0, 1.8, 0), Color(1.0, 0.55, 0.15), 60)
	_shake = 0.2
	await _until(48.6)
	_say(ronin, "... Le plus calme. Presque.", 2.0, -1.0)
	await _until(51.0)
	for id: String in heroes:
		(heroes[id] as CharacterModel).play(&"victory")
	for id: String in pets:
		_hop(pets[id], 4)
	_hop(calf, 4)
	_dolly(STAGE + Vector3(0, 3.0, 12), STAGE + Vector3(0, 2.4, 9), STAGE + Vector3(0, 1.0, 0), STAGE + Vector3(0, 1.0, 1), 8.0)
	await _until(52.0)
	_narrate("Les animaux de compagnie, dans Overclock : 17 compagnons à trouver.", 3.6)
	await _until(56.4)
	_narrate("À la boutique, dans le passe, et dans les œufs des boss.", 3.4)
	await _until(60.4)
	_fade_shade(1.0, 0.6)
	await _until(61.2)
	_end_card()
