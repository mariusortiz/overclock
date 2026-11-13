extends Season3Episode
## Épisode 30 : Retour. The answer: nobody creates alone; Le Créateur was made
## by those he wrote. The Gardien opens the gate. Back at the station, Le
## Créateur gets his code back, the two squads celebrate, and in a corner of
## the hangar a shard of crystal starts to sing. End of season 3.


func _init() -> void:
	episode_number = 30
	episode_title = "RETOUR"
	duration = 91.0


const GUARDIAN_AT := Vector3(0, 0.1, -14)


func _story() -> void:
	_load_world("crystal")
	_night_sky()
	var gate := _portal(Vector3(0, 16, -27), 9.0)
	var guardian := _guardian(GUARDIAN_AT + Vector3(0, -3, 0), PI, 11.0)
	(guardian.get_parent() as Node3D).rotation.x = 0.3
	var heroes := _squad(STAGE + Vector3(0, 0, 0), 0.0)
	var scarlet := _squad(STAGE + Vector3(0, 0, 2.2), 0.0, ["viking", "witch", "cowboy"], 1.6)
	var creator := _creator(STAGE + Vector3(4.6, 0, 1.8), 0.0)
	_dolly(STAGE + Vector3(-4, 2, 7), STAGE + Vector3(-3, 2, 6), STAGE + Vector3(0, 1.6, 0), STAGE + Vector3(0, 2, -4), 7.0)
	_fade_shade(0.0, 1.0)
	await _until(1.5)
	_narrate("« Qui a créé le Créateur ? » La question flotte.", 3.0)
	await _until(5.0)
	_say(heroes.paladin, "Une vache encore plus vieille ?", 2.0, 1.0)
	await _until(7.6)
	await _title_card(5.0)

	# 12.6 s: the answer.
	_dolly(STAGE + Vector3(-5.8, 1.7, -2.6), STAGE + Vector3(-5.4, 1.7, -2.8), STAGE + Vector3(-4.5, 1.5, 0), STAGE + Vector3(-4.5, 1.5, 0), 9.0)
	_say(heroes.soldier, "Moi, je sais.", 1.6, -1.0)
	await _until(15.0)
	heroes.soldier.get_parent().look_at(Vector3(creator.global_position.x, STAGE.y, creator.global_position.z))
	_say(heroes.soldier, "Avant nous, tu n'étais qu'un type qui écrivait du code.", 3.0, -1.0)
	await _until(18.6)
	_say(heroes.soldier, "C'est nous qui t'avons fait Créateur. Personne ne crée seul.", 3.4, -1.0)
	await _until(22.6)
	_dolly(STAGE + Vector3(5.8, 1.7, 4.4), STAGE + Vector3(5.4, 1.7, 4.0), creator.global_position + Vector3.UP * 1.5,
			creator.global_position + Vector3.UP * 1.5, 8.0)
	_face(creator, heroes.soldier)
	_say(creator, "Je vous ai écrits... et vous m'avez écrit en retour.", 3.0, -1.0)
	await _until(26.2)
	creator.get_parent().look_at(Vector3(GUARDIAN_AT.x, STAGE.y, GUARDIAN_AT.z))
	_say(creator, "Gardien. La réponse, c'est eux.", 2.4, -1.0)
	await _until(29.2)

	# 29.2 s: the gate opens.
	var pivot := guardian.get_parent() as Node3D
	var stand := create_tween()
	stand.tween_property(pivot, "position:y", GUARDIAN_AT.y, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	stand.parallel().tween_property(pivot, "rotation:x", 0.0, 1.4)
	_dolly(GUARDIAN_AT + Vector3(-3, 6, 12), GUARDIAN_AT + Vector3(-2, 7, 10), GUARDIAN_AT + Vector3(0, 9, 0), GUARDIAN_AT + Vector3(0, 10, 0), 6.0)
	await _until(30.8)
	_say(guardian, "Juste.", 1.6, 1.0, 11.4)
	await _until(33.0)
	_say(guardian, "Rentrez chez vous. Tous.", 2.2, 1.0, 11.4)
	await _until(35.6)
	_open(gate, 1.0)
	gate.scale = Vector3.ONE * 1.3
	_dolly(STAGE + Vector3(0, 1.0, 8), STAGE + Vector3(0, 1.2, 6), STAGE + Vector3(0, 2, -4), Vector3(0, 16, -27), 5.0)
	_narrate("Le portail s'ouvre en grand.", 2.6)
	await _until(38.8)
	_say(scarlet.cowboy, "Plus de caillou qui tombe. J'en pleurerais.", 2.6, 1.0)
	await _until(41.6)

	# 41.6 s: through the gate.
	var everyone: Array = heroes.values() + scarlet.values() + [creator]
	for index in everyone.size():
		_pull_in(everyone[index], gate, 1.6, 0.25 * index)
	_speed(3.0)
	_shake = 0.3
	await _until(46.0)
	_impact_frame()
	_fade_shade(1.0, 0.4)
	await _until(46.6)

	# 46.6 s: home.
	_load_arena(0)
	var home := {}
	var ids := SQUAD + ["viking", "witch", "cowboy"]
	for index in ids.size():
		var id: String = ids[index]
		var hero := _hero(id, STAGE + Vector3(-6.75 + 1.5 * index, 6, -1 - (index % 2) * 1.2), PI, "none")
		get_tree().create_timer(0.15 * index).timeout.connect(_drop.bind(hero.get_parent(), STAGE.y, 0.8))
		home[id] = hero
	var back := _creator(STAGE + Vector3(0, 7, -7), PI)
	get_tree().create_timer(1.6).timeout.connect(_drop.bind(back.get_parent(), STAGE.y, 0.8))
	_dolly(STAGE + Vector3(0, 6, 12), STAGE + Vector3(0, 2.2, 8), STAGE + Vector3(0, 3, -2), STAGE + Vector3(0, 1.3, -2), 4.0)
	_fade_shade(0.0, 0.6)
	_narrate("La station. Chez eux.", 2.4)
	await _until(50.0)
	_stomp(STAGE + Vector3(0, 0, -7), 0.5)
	await _until(51.0)

	# 51 s: the code comes back.
	_dolly(STAGE + Vector3(1.2, 1.7, -4.6), STAGE + Vector3(0.9, 1.7, -5.0), STAGE + Vector3(0, 1.5, -7), STAGE + Vector3(0, 1.6, -7), 8.0)
	_glitch(0.8)
	_appear(back, 0.8)
	await _until(52.4)
	_say(back, "Ça revient. Je sens chaque ligne.", 2.4, -1.0)
	await _until(55.2)
	back.play(&"victory", true)
	Effects.burst(_set, back.global_position + Vector3.UP * 1.8, VIRUS, 60)
	_say(back, "Le code est revenu !", 1.8, -1.0)
	await _until(57.4)
	for hero in home.values():
		(hero as CharacterModel).play(&"victory")
	_dolly(STAGE + Vector3(-6, 2.2, 8), STAGE + Vector3(6, 2.2, 8), STAGE + Vector3(-2, 1.3, -1), STAGE + Vector3(2, 1.3, -1), 8.0)
	_say(home.captain, "Deux escouades, une vache, zéro perte !", 2.6, 1.0)
	await _until(60.4)
	_say(home.sand_ghost, "Et ma revanche ?", 1.6, -1.0)
	await _until(62.4)
	_say(back, "Demain. Promis. Pour de vrai.", 2.2, 1.0)
	await _until(65.0)
	_say(home.viking, "On est combien de jours après notre départ ?", 2.6, 1.0)
	await _until(68.0)
	_say(back, "Ici ? Une heure.", 1.8, -1.0)
	await _until(70.2)
	_say(home.cowboy, "... Une heure.", 1.6, 1.0)
	await _until(72.2)

	# 72.2 s: in a corner of the hangar.
	var shard := Vector3(-14, 0.1, 6)
	_dolly(shard + Vector3(2.4, 0.8, 3.2), shard + Vector3(1.4, 0.5, 2.0), shard + Vector3(0, 0.3, 0), shard + Vector3(0, 0.3, 0), 6.0)
	var crystal := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.2, 0.6, 0.2)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = CRYSTAL
	prism.material = glow
	crystal.mesh = prism
	_set.add_child(crystal)
	crystal.global_position = shard + Vector3.UP * 0.3
	crystal.rotation.z = 0.4
	await _until(73.6)
	_narrate("Dans un coin du hangar, un éclat de cristal...", 2.8)
	await _until(76.6)
	_note(shard, CRYSTAL)
	await _until(77.4)
	_narrate("... se met à chanter.", 2.4)
	await _until(80.2)
	_fade_shade(0.85, 0.6)
	_narrate("FIN DE LA SAISON 3", 3.4, true)
	await _until(84.0)
	_fade_shade(1.0, 0.6)
	await _until(85.0)
	_end_card()
