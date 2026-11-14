extends Season4Episode
## Épisode 41 : Les Miroirs (fin de la saison 4). The final fight: heroes and
## doubles side by side, all at once, nothing the Reflet can copy. He shatters;
## from the shards steps the soldier's double, free. The worlds fuse: the
## mirror world gets its stories, the squad gets new friends, the two
## Créateurs plant a tree. The capybara has two mandarins now.


func _init() -> void:
	episode_number = 41
	episode_title = "LES MIROIRS"
	duration = 61.0


func _story() -> void:
	_load_world("city")
	_tint_world(MIRROR)
	_shards(STAGE + Vector3(0, 9, -10), 18, 24.0)
	var reflect := _reflect(STAGE + Vector3(0, 0, -11), PI, 4.0)
	_overlay(reflect, Color(1.0, 1.0, 1.0, 0.3))
	var ids := ["soldier", "kunoichi", "ronin", "captain"]
	var heroes := _squad(STAGE + Vector3(0, 0, 1), 0.0, ids, 2.2, true)
	var doubles := {}
	for index in ids.size():
		doubles[ids[index]] = _double(ids[index], STAGE + Vector3(-3.3 + 2.2 * index + 1.0, 0, 2.2), 0.0, AnimeDirector.GUNS.get(ids[index], "heavy"))
	_dolly(STAGE + Vector3(0, 3, 9), STAGE + Vector3(0, 2.6, 7), STAGE + Vector3(0, 2, -11), STAGE + Vector3(0, 3, -11), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Le dernier combat. Héros et doubles, côte à côte.", 3.0)
	await _until(4.6)
	_say(reflect, "Je copierai chacun de vous !", 2.2, 1.0, 4.2)
	await _until(7.2)
	await _title_card(5.0)

	# 12.2 s: all at once.
	_speed(5.0)
	_dolly(STAGE + Vector3(-7, 2.2, 3), STAGE + Vector3(7, 2.2, 3), STAGE + Vector3(0, 2, -11), STAGE + Vector3(0, 2.4, -11), 6.0)
	var all: Array = []
	for id: String in ids:
		all.append(heroes[id])
		all.append(doubles[id])
	for index in all.size():
		var fighter: CharacterModel = all[index]
		fighter.play(&"shoot", true)
		get_tree().create_timer(0.1 * index).timeout.connect(
				_beam.bind(fighter.global_position + Vector3.UP * 1.3, reflect.global_position + Vector3.UP * 2.6,
						GOLD if index % 2 == 0 else MIRROR, 0.08))
	await _until(13.6)
	_narrate("Huit tirs, deux mondes. Il ne peut pas tout copier.", 3.0, true)
	await _until(17.0)
	_impact_frame()
	_shake = 0.4
	_dolly(STAGE + Vector3(0, 2.4, -5), STAGE + Vector3(0, 2.6, -6), STAGE + Vector3(0, 2.4, -11), STAGE + Vector3(0, 2.4, -11), 4.0)
	_break(reflect)
	Effects.flash(_set, reflect.global_position + Vector3.UP * 2, Color.WHITE, 12.0, 0.6)
	await _until(18.4)
	_narrate("Le Reflet vole en éclats.", 2.4, true)
	await _until(21.4)

	# 21.4 s: the soldier's double, free.
	var freed := _double("soldier", STAGE + Vector3(0, 0, -10), PI)
	_overlay(freed, Color(0.95, 0.9, 1.0, 0.4))
	_appear(freed, 0.8)
	_dolly(STAGE + Vector3(0.6, 1.7, -6.6), STAGE + Vector3(0.5, 1.7, -7.2), STAGE + Vector3(0, 1.4, -10), STAGE + Vector3(0, 1.4, -10), 6.0)
	await _until(22.6)
	_say(freed, "Il m'avait pris ma place. Merci de me l'avoir rendue.", 3.0, 1.0)
	await _until(26.0)
	_dolly(STAGE + Vector3(-1.4, 1.7, -2.0), STAGE + Vector3(-1.1, 1.7, -2.4), STAGE + Vector3(0, 1.4, 1), STAGE + Vector3(0, 1.4, 1), 6.0)
	_say(heroes.soldier, "Le Reflet, c'était toi ?", 1.8, 1.0)
	await _until(28.2)
	_say(doubles.soldier, "C'était ce qu'il y a de pire en nous deux.", 2.6, -1.0)
	await _until(31.2)

	# 31.2 s: the worlds fuse.
	_tint_world(Color(1.0, 0.85, 0.6))
	_dolly(STAGE + Vector3(0, 12, 16), STAGE + Vector3(0, 16, 24), STAGE + Vector3(0, 2, -4), STAGE + Vector3(0, 8, -20), 8.0)
	_narrate("Les deux mondes fusionnent.", 2.6, true)
	await _until(34.2)
	_narrate("L'un a des histoires. L'autre a des jardins. Maintenant, ils ont les deux.", 3.8)
	await _until(38.4)

	# 38.4 s: the two Créateurs and the tree.
	var creator := _creator(STAGE + Vector3(-1.4, 0, 6), PI)
	var other := _creator(STAGE + Vector3(1.4, 0, 6), PI)
	_overlay(other, Color(0.95, 0.9, 1.0, 0.4))
	var tree: Node3D = load("res://assets/models/nature/tree_oak.glb").instantiate()
	_set.add_child(tree)
	tree.position = STAGE + Vector3(0, 0, 5)
	tree.scale = Vector3.ONE * 0.2
	_toon(tree)
	create_tween().tween_property(tree, "scale", Vector3.ONE * 2.2, 4.0).set_ease(Tween.EASE_OUT)
	_dolly(STAGE + Vector3(0, 2.0, 11.4), STAGE + Vector3(0, 1.9, 10.4), STAGE + Vector3(0, 1.6, 6), STAGE + Vector3(0, 2.2, 6), 9.0)
	await _until(39.4)
	_say(other, "On plante ça ici ?", 1.6, 1.0)
	await _until(41.4)
	_say(creator, "Ici, c'est parfait. Il n'y a pas de boss au programme.", 2.8, -1.0)
	await _until(44.6)
	var capybara := Pet.build_model(Pets.find("pet_capybara"))
	_set.add_child(capybara)
	capybara.position = STAGE + Vector3(0, 0, 7.4)
	capybara.rotation.y = PI
	Pet.play_idle(capybara)
	_toon(capybara)
	_narrate("Le capybara a maintenant deux mandarines.", 2.6)
	await _until(47.6)
	for id: String in ids:
		_pivot_of(heroes[id]).rotation.y = PI
		_pivot_of(doubles[id]).rotation.y = PI
		(heroes[id] as CharacterModel).play(&"victory")
		(doubles[id] as CharacterModel).play(&"victory")
	_dolly(STAGE + Vector3(0, 3, 14), STAGE + Vector3(0, 2.6, 12), STAGE + Vector3(0, 1.2, 3), STAGE + Vector3(0, 1.4, 3), 8.0)
	_narrate("Fin de la saison 4 : Les Miroirs.", 3.0, true)
	await _until(51.4)
	_fade_shade(1.0, 0.8)
	await _until(52.4)
	_end_card()
