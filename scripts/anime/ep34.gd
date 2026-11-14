extends Season4Episode
## Épisode 34 : Sans double. Every hero has a double; Le Créateur too (they
## saw it from afar). Only the capybara has none. It walks through the shard
## and comes back with a mandarin from the other side: the way is open, and
## only what Le Créateur never wrote can cross without changing.


func _init() -> void:
	episode_number = 34
	episode_title = "SANS DOUBLE"
	duration = 56.0


func _capybara(at: Vector3, facing: float) -> Node3D:
	var model := Pet.build_model(Pets.find("pet_capybara"))
	_set.add_child(model)
	model.position = at
	model.rotation.y = facing
	Pet.play_idle(model)
	_toon(model)
	return model


func _story() -> void:
	_load_arena(0)
	var creator := _creator(STAGE + Vector3(0.8, 0, 0), PI)
	var capybara := _capybara(STAGE + Vector3(-0.8, 0, 0.4), PI)
	var shard := _mirror(STAGE + Vector3(0, 0, -4), 0.0, 2.6)
	_dolly(STAGE + Vector3(0, 2.2, 7), STAGE + Vector3(0, 1.8, 5), STAGE + Vector3(0, 0.9, -1), STAGE + Vector3(0, 1.0, 0), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Le laboratoire du Créateur. Enfin, le hangar.", 2.8)
	await _until(4.6)
	_say(creator, "Chaque héros a son double. Moi aussi, je l'ai vu.", 2.8, 1.0)
	await _until(7.8)
	await _title_card(5.0)

	# 12.8 s: the capybara.
	_dolly(STAGE + Vector3(-1.4, 0.9, 2.6), STAGE + Vector3(-1.1, 0.8, 2.2), STAGE + Vector3(-0.8, 0.4, 0.4), STAGE + Vector3(-0.8, 0.4, 0.4), 6.0)
	await _until(13.4)
	_say(creator, "Sauf lui. Aucun double. J'ai cherché partout.", 2.6, 1.0)
	await _until(16.4)
	_narrate("Le capybara mâche. Il ne s'inquiète de rien.", 2.8)
	await _until(19.6)
	_dolly(STAGE + Vector3(2.4, 1.4, 0.6), STAGE + Vector3(2.2, 1.3, 0), STAGE + Vector3(-0.4, 0.5, -2), STAGE + Vector3(0, 0.8, -4), 6.0)
	capybara.rotation.y = 0.0
	var walk := create_tween()
	walk.tween_property(capybara, "position", STAGE + Vector3(0, 0, -4), 3.0)
	await _until(22.6)
	capybara.visible = false
	Effects.flash(_set, STAGE + Vector3(0, 1, -4), MIRROR, 6.0, 0.4)
	_narrate("Il traverse le miroir. Comme une porte.", 2.6, true)
	await _until(25.6)
	_say(creator, "... Reviens ! Tu n'as même pas ton manteau !", 2.4, 1.0)
	await _until(28.4)

	# 28.4 s: it comes back.
	_dolly(STAGE + Vector3(0, 1.0, -1.6), STAGE + Vector3(0, 0.9, -1.4), STAGE + Vector3(0, 0.5, -4), STAGE + Vector3(0, 0.5, -3.4), 5.0)
	Effects.flash(_set, STAGE + Vector3(0, 1, -4), MIRROR, 6.0, 0.4)
	capybara.visible = true
	capybara.rotation.y = PI
	var back := create_tween()
	back.tween_property(capybara, "position", STAGE + Vector3(0, 0, -2.6), 1.6)
	await _until(30.4)
	_narrate("Il revient. Avec une deuxième mandarine.", 2.6, true)
	await _until(33.4)
	_dolly(STAGE + Vector3(1.6, 1.7, 2.8), STAGE + Vector3(1.2, 1.6, 2.4), STAGE + Vector3(0.6, 1.2, -0.6), STAGE + Vector3(0.6, 1.2, -0.6), 8.0)
	_say(creator, "Il est passé sans changer. Parce que je ne l'ai pas écrit.", 3.0, 1.0)
	await _until(36.8)
	_say(creator, "Il était déjà là quand j'ai commencé le jeu.", 2.6, 1.0)
	await _until(39.8)
	_say(creator, "Si lui peut passer, on peut le suivre.", 2.4, 1.0)
	await _until(42.6)
	_overlay(shard, Color(MIRROR, 0.4))
	_narrate("Le chemin du monde-miroir est ouvert.", 2.6)
	await _until(45.6)
	await _to_be_continued(46.0)
