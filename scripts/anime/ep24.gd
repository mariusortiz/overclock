extends Season3Episode
## Épisode 24 : La Ceinture. The Captain feeds crystal shards to two ships,
## and they wake up glowing. Off to the ruins, across an asteroid belt, with
## crystal drones on their tail. Vipère flies; the drones fall.


func _init() -> void:
	episode_number = 24
	episode_title = "LA CEINTURE"
	duration = 78.0


func _story() -> void:
	_load_world("crystal")
	_moons()
	var gold := _wreck(GOLD, STAGE + Vector3(-3, 0.4, -4), 0.5)
	var red := _wreck(RED, STAGE + Vector3(4, 0.4, -5), -0.4)
	var captain := _hero("captain", STAGE + Vector3(-3, 0, -1.4), 0.0, "none")
	var vipere := _hero("sand_ghost", STAGE + Vector3(2.2, 0, -1.6), 0.0, "none")
	var creator := _creator(STAGE + Vector3(0, 0, 1.4), PI)
	_dolly(STAGE + Vector3(-1, 1.8, 5), STAGE + Vector3(0, 1.8, 4.2), STAGE + Vector3(0, 1.0, -4), STAGE + Vector3(0, 1.2, -4), 8.0)
	_fade_shade(0.0, 1.2)
	await _until(1.5)
	_narrate("Pour aller aux ruines, il faut voler.", 2.8)
	await _until(4.6)
	_say(captain, "Et pour voler, il faut de l'énergie.", 2.4, 1.0)
	await _until(7.4)
	await _title_card(5.0)

	# 12.4 s: crystal for fuel.
	_dolly(STAGE + Vector3(-6, 1.6, 1.6), STAGE + Vector3(-5.4, 1.6, 1.0), STAGE + Vector3(-3, 1.0, -4), STAGE + Vector3(-3, 1.0, -4), 8.0)
	_say(captain, "Ces cristaux chantent. Donc ils vibrent. Donc ils ont de l'énergie.", 3.4, 1.0)
	await _until(16.4)
	_say(creator, "C'est... de la vraie physique, ça ?", 2.2, -1.0)
	await _until(19.0)
	_say(captain, "Ici, oui.", 1.4, 1.0)
	await _until(20.8)
	for ship: RaceShip in [gold, red]:
		for index in 5:
			var from := ship.global_position + Vector3(randf_range(-6, 6), 0.5, randf_range(3, 6))
			var shard := MeshInstance3D.new()
			var prism := PrismMesh.new()
			prism.size = Vector3(0.2, 0.5, 0.2)
			var glow := StandardMaterial3D.new()
			glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			glow.albedo_color = CRYSTAL
			prism.material = glow
			shard.mesh = prism
			_set.add_child(shard)
			shard.global_position = from
			var tween := shard.create_tween()
			tween.tween_interval(index * 0.25)
			tween.tween_property(shard, "global_position", ship.global_position + Vector3.UP * 0.5, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.tween_callback(shard.queue_free)
	await _until(23.0)
	for ship: RaceShip in [gold, red]:
		_overlay(ship, Color(CRYSTAL, 0.25))
		_note(ship.global_position, CRYSTAL)
		create_tween().tween_property(ship, "rotation", Vector3(0, ship.rotation.y, 0), 0.8)
		create_tween().tween_property(ship, "position:y", 1.2, 0.8)
	_shake = 0.2
	_narrate("Les moteurs se rallument. En bleu.", 2.6)
	await _until(26.0)
	_dolly(STAGE + Vector3(3.6, 1.7, 0.6), STAGE + Vector3(3.2, 1.7, 0.2), STAGE + Vector3(2.2, 1.6, -1.6), STAGE + Vector3(2.2, 1.6, -1.6), 4.0)
	_say(vipere, "Le rouge, c'est pour moi. Montez, les autres.", 2.6, 1.0)
	await _until(29.0)

	# 29 s: the belt.
	_wipe()
	_load_space(2)
	var ship_gold := _ship("CAPITAINE", GOLD, -10.0, Vector2(-3, 0), 1.0)
	var ship_red := _ship("VIPÈRE", RED, -6.0, Vector2(3, 0), 1.0)
	for ship in [ship_gold, ship_red]:
		_overlay(ship, Color(CRYSTAL, 0.25))
	_follow(ship_red, Vector3(0, 2.6, 8), Vector3(0, 0.5, -20))
	_speed(2.0)
	await _until(30.0)
	_narrate("La ceinture. Des montagnes qui flottent.", 2.6)
	await _until(33.0)
	_follow(ship_red, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(ship_red, "Enfin un endroit où piloter pour de vrai.", 2.6, -1.0, 1.0)
	await _until(36.0)

	# 36 s: the drones.
	var drones: Array[RaceShip] = []
	for index in 4:
		var drone := _ship("DRONE", Color(0.3, 0.5, 0.9), ship_gold.distance - 14.0 - 6.0 * index, Vector2((index % 2) * 6.0 - 3.0, 1.0), 1.2)
		_overlay(drone, Color(CRYSTAL, 0.5))
		drone.boost(4.0)
		drones.append(drone)
	_follow(ship_gold, Vector3(0, 2.0, -9), Vector3(0, 0.5, 6))
	await _until(37.0)
	_say(ship_gold, "Des drones de cristal ! Dans nos réacteurs !", 2.6, 1.0, 1.0)
	await _until(40.0)
	for index in 3:
		_ship_laser(drones[index], ship_gold)
		_impact_frame()
		await _until(_clock + 0.45)
	_say(ship_gold, "Le bouclier ne tiendra pas !", 2.0, 1.0, 1.0)
	await _until(44.0)

	# 44 s: Vipère turns around.
	_follow(ship_red, Vector3(2.0, 1.4, 5.0), Vector3(0, 0.5, -10))
	_say(ship_red, "Tenez-vous bien.", 1.6, -1.0, 1.0)
	await _until(46.0)
	ship_red.speed *= 0.4
	_speed(1.6)
	_follow(ship_red, Vector3(0, 3.0, 9), Vector3(0, 0.5, -16))
	await _until(47.6)
	for drone in drones:
		_ship_laser(ship_red, drone)
		_ring(drone.global_position, CRYSTAL, 6.0, 0.4)
		Effects.burst(_set, drone.global_position, CRYSTAL, 40)
		drone.visible = false
		await _until(_clock + 0.5)
	await _until(50.4)
	ship_red.speed /= 0.4
	ship_red.boost(2.0)
	_follow(ship_gold, Vector3(-1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(ship_gold, "... Tu as fait demi-tour en pleine ceinture ?", 2.6, -1.0, 1.0)
	await _until(53.4)
	_follow(ship_red, Vector3(1.8, 1.1, -3.5), Vector3(0, 0.6, 0))
	_say(ship_red, "Écris-moi une revanche, j'avais dit.", 2.4, 1.0, 1.0)
	await _until(56.2)
	_say(ship_red, "Le Créateur a écouté.", 1.8, 1.0, 1.0)
	await _until(58.4)

	# 58.4 s: the ruins planet.
	_follow(ship_red, Vector3(0, 6, 16), Vector3(0, 0, -40))
	_speed(2.0)
	await _until(60.0)
	_fade_shade(1.0, 0.5)
	await _until(60.6)
	_load_world("ruins")
	_fade_shade(0.0, 0.8)
	_dolly(Vector3(0, 40, 50), Vector3(0, 14, 30), Vector3(0, 0, -10), Vector3(0, 4, -24), 8.0)
	_narrate("Une planète de pierre. Des ruines à perte de vue.", 3.2)
	await _until(65.0)
	_narrate("Et, sur l'arche, une silhouette qu'ils connaissent.", 3.2, true)
	await _until(68.8)
	await _to_be_continued(69.2)
