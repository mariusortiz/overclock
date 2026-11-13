extends Season3Episode
## Épisode 28 : Écarlate. Brutus, Hex and Colt were pulled in by a portal
## during the war against the Virus; here, they have lived years of loops. Hex
## holds the key: the loop was its lock. The two squads join up; the key
## points to the heart of the galaxy, where the Gardien waits.


func _init() -> void:
	episode_number = 28
	episode_title = "ÉCARLATE"
	duration = 79.0


func _story() -> void:
	_load_arena(1)
	_night_sky()
	var heroes := _squad(STAGE + Vector3(0, 0, 1.4), 0.0, SQUAD, 1.4)
	var creator := _creator(STAGE + Vector3(6.4, 0, -0.6), PI / 2.0)
	var brutus := _hero("viking", STAGE + Vector3(-2.2, 0, -3), PI, "none")
	var hex := _hero("witch", STAGE + Vector3(0, 0, -3.4), PI, "none")
	var colt := _hero("cowboy", STAGE + Vector3(2.2, 0, -3), PI, "none")
	var vipere: CharacterModel = heroes.sand_ghost
	_dolly(STAGE + Vector3(-6, 2.2, 3), STAGE + Vector3(-5, 2, 2), STAGE + Vector3(0, 1.3, -1), STAGE + Vector3(0, 1.3, -1), 8.0)
	_fade_shade(0.0, 1.0)
	await _until(1.5)
	_narrate("Deux escouades, face à face, sur une lune grise.", 3.0)
	await _until(4.8)
	_say(colt, "Vous en avez mis, du temps.", 2.0, -1.0)
	await _until(7.4)
	await _title_card(5.0)

	# 12.4 s: what happened to them.
	_dolly(STAGE + Vector3(-0.8, 1.7, -0.4), STAGE + Vector3(-0.6, 1.7, -0.8), STAGE + Vector3(-1.1, 1.5, -3.2), STAGE + Vector3(-1.1, 1.5, -3.2), 10.0)
	_say(brutus, "Pendant votre guerre contre le Virus, un anneau s'est ouvert.", 3.2, -1.0)
	await _until(16.2)
	_say(brutus, "Il nous a pris tous les trois. Et puis ici...", 2.8, -1.0)
	await _until(19.4)
	_say(hex, "Trente secondes. Encore et encore. Pendant des années.", 3.0, 1.0)
	await _until(23.0)
	_say(colt, "J'ai vu ce caillou tomber neuf mille fois.", 2.6, 1.0)
	await _until(26.0)

	# 26 s: Vipère.
	_dolly(STAGE + Vector3(-5.6, 2.0, 0.4), STAGE + Vector3(-5.2, 2.0, 0.0), STAGE + Vector3(-1.8, 1.5, -1.4), STAGE + Vector3(-1.8, 1.5, -1.4), 9.0)
	_move(vipere.get_parent(), Vector3(-0.4, 0, -1.1))
	vipere.play(&"walk")
	await _until(27.4)
	_movers.clear()
	vipere.play(&"idle")
	_face(vipere, brutus)
	_say(vipere, "Je vous ai cherchés partout.", 2.2, 1.0)
	await _until(30.0)
	_say(brutus, "Tu as une nouvelle escouade, on dirait.", 2.4, -1.0)
	await _until(32.8)
	_say(vipere, "J'en ai deux. C'est mieux.", 2.0, 1.0)
	await _until(35.2)
	brutus.play(&"victory", true)
	vipere.play(&"victory", true)
	_impact_frame()
	await _until(36.4)

	# 36.4 s: the key.
	_dolly(STAGE + Vector3(0.6, 1.6, -0.4), STAGE + Vector3(0.5, 1.6, -0.8), STAGE + Vector3(0, 1.5, -3.4), STAGE + Vector3(0, 1.5, -3.4), 10.0)
	_say(hex, "Le premier jour, j'ai trouvé ça.", 2.2, 1.0)
	var key := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.18, 0.5, 0.18)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = GOLD
	prism.material = glow
	key.mesh = prism
	_set.add_child(key)
	key.global_position = hex.global_position + Vector3(0, 1.3, 0.4)
	key.create_tween().set_loops().tween_property(key, "rotation:y", TAU, 2.0).from(0.0)
	Effects.flash(_set, key.global_position, GOLD, 6.0, 0.4)
	await _until(39.0)
	_say(hex, "Depuis, le temps tourne en rond.", 2.2, 1.0)
	await _until(41.6)
	_dolly(STAGE + Vector3(4.9, 1.7, 0.6), STAGE + Vector3(5.0, 1.7, 0.2), STAGE + Vector3(6.4, 1.55, -0.6), STAGE + Vector3(6.4, 1.55, -0.6), 8.0)
	_say(creator, "La clé du portail. La version 0 l'a enfermée dans une boucle.", 3.2, -1.0)
	await _until(45.2)
	_say(creator, "Pour que seuls des gens patients la trouvent.", 2.6, -1.0)
	await _until(48.2)
	_say(colt, "Patients. On peut le dire.", 1.8, 1.0)
	await _until(50.4)

	# 50.4 s: the key shows the way.
	_dolly(STAGE + Vector3(0, 1.4, 5), STAGE + Vector3(0, 1.2, 4), STAGE + Vector3(0, 1.6, -3), STAGE + Vector3(0, 30, -60), 6.0)
	hex.play(&"victory", true)
	create_tween().tween_property(key, "global_position", key.global_position + Vector3.UP * 1.6, 1.0)
	await _until(51.6)
	_beam(key.global_position + Vector3.UP * 1.6, key.global_position + Vector3(10, 120, -200), GOLD, 0.25)
	Effects.flash(_set, key.global_position + Vector3.UP * 1.6, GOLD, 16.0, 0.6)
	_shake = 0.2
	await _until(53.0)
	_narrate("Un rayon d'or, vers le cœur de la galaxie.", 3.0)
	await _until(56.4)
	_narrate("« VENEZ. »", 2.4, true)
	_glitch(0.3)
	await _until(59.2)
	_dolly(STAGE + Vector3(-5.4, 1.7, -1.4), STAGE + Vector3(-5.2, 1.7, -1.8), STAGE + Vector3(-4.2, 1.5, 1.4), STAGE + Vector3(-4.2, 1.5, 1.4), 9.0)
	_say(heroes.soldier, "Qui a dit ça ?", 1.6, 1.0)
	await _until(61.2)
	_say(creator, "Le Gardien du portail. Il nous attend.", 2.4, -1.0)
	await _until(64.0)
	_say(heroes.soldier, "Alors on y va. Les deux escouades.", 2.4, 1.0)
	await _until(66.8)
	_say(brutus, "Et la vache.", 1.4, -1.0)
	await _until(68.6)
	await _to_be_continued(69.0)
