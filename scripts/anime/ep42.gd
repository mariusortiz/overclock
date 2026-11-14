extends Season4Episode
## Hors-série, épisode 42 : Naufragés. The squad's ship comes down on a wild
## planet (the survival mode's island). No base, no code: they harvest wood
## and stone, build walls and a fire, and hold the night against the shadows.
## Dawn burns them away. Introduces the survival mode (SurvivalGame).


func _init() -> void:
	episode_number = 42
	episode_title = "NAUFRAGÉS"
	duration = 64.0


var _island: SurvivalWorld
var _camp := Vector3.ZERO
var _sun := DirectionalLight3D.new()
var _sky := ProceduralSkyMaterial.new()
var _environment := Environment.new()


## The survival world's island (seed 42), its sky and its sun.
func _load_island() -> Vector3:
	_clear_set()
	_island = SurvivalWorld.new()
	_island.setup(42)
	_set.add_child(_island)
	var home := _island.find_spawn()
	_island.build_around(home)
	var sky := Sky.new()
	sky.sky_material = _sky
	_sky.sky_top_color = Color(0.25, 0.5, 0.88)
	_sky.sky_horizon_color = Color(0.75, 0.85, 0.95)
	_environment.background_mode = Environment.BG_SKY
	_environment.sky = sky
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color(0.85, 0.85, 0.8)
	_environment.ambient_light_energy = 0.5
	_environment.fog_enabled = true
	_environment.fog_density = 0.006
	_environment.fog_light_color = Color(0.55, 0.65, 0.78)
	var world := WorldEnvironment.new()
	world.environment = _environment
	_set.add_child(world)
	_sun.rotation = Vector3(-0.9, deg_to_rad(30), 0)
	_sun.light_energy = 0.9
	_set.add_child(_sun)
	# The island keeps its colors (the cel shading would whiten its ground).
	_camera.far = 400.0
	return home


## A camera spot `offset` from the camp, always above the ground there.
func _cam(offset: Vector3) -> Vector3:
	var at := _camp + Vector3(offset.x, 0, offset.z)
	return Vector3(at.x, maxf(_island.height_at(at.x, at.z), _camp.y) + offset.y, at.z)


func _ground(at: Vector3) -> Vector3:
	return Vector3(at.x, _island.height_at(at.x, at.z), at.z)


## Night falls (or day breaks) over `seconds`.
func _dusk(night: bool, seconds: float) -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_sun, "light_energy", 0.25 if night else 0.9, seconds)
	tween.tween_property(_sun, "light_color", Color(0.35, 0.45, 0.85) if night else Color.WHITE, seconds)
	tween.tween_property(_sky, "sky_top_color", Color(0.02, 0.03, 0.1) if night else Color(0.25, 0.5, 0.88), seconds)
	tween.tween_property(_sky, "sky_horizon_color", Color(0.06, 0.07, 0.16) if night else Color(1.0, 0.7, 0.45), seconds)
	tween.tween_property(_environment, "ambient_light_color", Color(0.3, 0.35, 0.6) if night else Color(0.85, 0.85, 0.8), seconds)
	tween.tween_property(_environment, "fog_light_color", Color(0.05, 0.06, 0.14) if night else Color(0.8, 0.65, 0.55), seconds)


func _piece(type: String, piece_material: String, at: Vector3, facing: float) -> SurvivalPiece:
	var piece := SurvivalPiece.new()
	piece.configure(type, piece_material)
	piece.position = at
	piece.rotation.y = facing
	piece.scale = Vector3.ONE * 0.05
	_set.add_child(piece)
	_toon(piece)
	create_tween().tween_property(piece, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Effects.burst(_set, at + Vector3.UP, Color(1, 1, 1), 14)
	return piece


func _story() -> void:
	var home := _load_island()
	var camp := _ground(home + Vector3(0, 0, -2))
	_camp = camp
	# 0 s: the ship comes down.
	var ship := _parked_ship(GOLD, camp + Vector3(-30, 25, -20), 0.6)
	_fly_to(ship, camp + Vector3(-40, 30, -30), camp + Vector3(-7, 0.4, -6), 3.2)
	_dolly(_cam(Vector3(6, 6, 14)), _cam(Vector3(4, 4, 10)), camp + Vector3(-10, 4, -10), camp + Vector3(-7, 1, -6), 5.0)
	_fade_shade(0.0, 1.0)
	await _until(1.4)
	_narrate("Hors-série. Une planète sauvage. Pas d'arène, pas de code.", 3.2)
	await _until(3.4)
	_impact_frame()
	_shake = 0.4
	Effects.burst(_set, camp + Vector3(-7, 1, -6), Color(1.0, 0.55, 0.15), 60)
	ship.queue_free()
	_wreck(GOLD, camp + Vector3(-7, 0.4, -6), 0.6)
	await _until(5.2)
	var heroes := _squad(camp + Vector3(0, 0, 3), PI, ["soldier", "kunoichi", "captain", "cowgirl"], 1.8)
	for id: String in heroes:
		var pivot := _pivot_of(heroes[id])
		pivot.global_position = _ground(pivot.global_position)
	_dolly(_cam(Vector3(0, 1.8, 8.6)), _cam(Vector3(0, 1.7, 7.8)), camp + Vector3(0, 1.3, 3), camp + Vector3(0, 1.4, 3), 6.0)
	await _until(5.8)
	_say(heroes.captain, "Tout le monde va bien ?", 1.8, 1.0)
	await _until(8.0)
	_say(heroes.cowgirl, "Le vaisseau, beaucoup moins.", 1.8, -1.0)
	await _until(10.2)
	await _title_card(5.0)

	# 15.2 s: harvest.
	var tree: SurvivalNode = null
	for node: SurvivalNode in get_tree().get_nodes_in_group("survival_nodes"):
		if node.kind in ["tree", "palm"] and (tree == null or node.global_position.distance_to(camp) < tree.global_position.distance_to(camp)):
			tree = node
	var soldier: CharacterModel = heroes.soldier
	if tree:
		var pivot := _pivot_of(soldier)
		pivot.global_position = _ground(tree.global_position + Vector3(0, 0, 1.6))
		pivot.look_at(Vector3(tree.global_position.x, pivot.global_position.y, tree.global_position.z))
		_dolly(tree.global_position + Vector3(3.5, 2.2, 3.5), tree.global_position + Vector3(3.0, 2.0, 3.0),
				tree.global_position + Vector3(0, 1.5, 0.8), tree.global_position + Vector3(0, 1.5, 0.8), 8.0)
	_narrate("D'abord, du bois.", 2.2)
	for i in 4:
		await _until(16.4 + i * 1.0)
		soldier.play(&"melee", true)
		if tree and is_instance_valid(tree):
			tree.hit({"tool": "axe", "power": 3})
	await _until(21.0)
	_say(soldier, "Quatre bois. On est riches.", 2.0, 1.0)
	await _until(23.4)

	# 23.4 s: build.
	_dolly(_cam(Vector3(7, 5, 9)), _cam(Vector3(6, 4.5, 8)), camp + Vector3(0, 1, 0), camp + Vector3(0, 1, 0), 10.0)
	_narrate("Puis des murs. Et un feu.", 2.4)
	var cell := SurvivalPiece.CELL
	var spots := []
	for side in 4:
		for offset in range(-1, 2):
			if side == 2 and offset == 0:
				spots.append(["door", side, offset])
			else:
				spots.append(["wall", side, offset])
	var time := 24.0
	for spot: Array in spots:
		await _until(time)
		var facing: float = spot[1] * PI / 2.0
		var at: Vector3 = camp + Vector3(spot[2] * cell, 0, -cell * 1.5).rotated(Vector3.UP, facing)
		_piece(spot[0], "wood" if spot[1] % 2 == 0 else "stone", _ground(at), facing)
		time += 0.35
	await _until(time + 0.2)
	_piece("campfire", "wood", _ground(camp), 0.0)
	for id: String in heroes:
		var pivot := _pivot_of(heroes[id])
		pivot.global_position = _ground(camp + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)))
	await _until(30.0)
	_say(heroes.kunoichi, "Pas mal, pour une première maison.", 2.2, -1.0)
	await _until(32.6)

	# 32.6 s: night.
	_dusk(true, 3.0)
	_narrate("Puis la nuit tombe.", 2.4, true)
	await _until(35.6)
	var shadows: Array[CharacterModel] = []
	for i in 5:
		var angle := TAU * i / 5.0
		var at := _ground(camp + Vector3(cos(angle), 0, sin(angle)) * 9.0)
		var shadow := _actor(load(Loadout.CHARACTER_DIR + "Zombie_Male.fbx"), HERO_HEIGHT, at, 0.0)
		_overlay(shadow, Color(0.45, 0.1, 0.6, 0.6))
		_pivot_of(shadow).look_at(Vector3(camp.x, at.y, camp.z))
		shadow.play(&"walk")
		shadows.append(shadow)
	_dolly(_cam(Vector3(0, 9, 12)), _cam(Vector3(0, 8, 10)), camp, camp, 6.0)
	await _until(37.0)
	_say(heroes.captain, "Derrière les murs ! Personne ne sort !", 2.4, 1.0)
	await _until(39.6)
	for index in shadows.size():
		var shadow := shadows[index]
		var hero: CharacterModel = heroes.values()[index % heroes.size()]
		get_tree().create_timer(0.6 * index).timeout.connect(func() -> void:
			hero.play(&"shoot", true)
			_beam(hero.global_position + Vector3.UP * 1.3, shadow.global_position + Vector3.UP * 1.0, GOLD, 0.06)
			Effects.burst(_set, shadow.global_position + Vector3.UP, Color(0.6, 0.2, 0.9), 30)
			_pivot_of(shadow).visible = false)
	await _until(43.0)
	_narrate("Les ombres reviennent. Toute la nuit.", 2.6)
	await _until(46.0)

	# 46 s: dawn.
	_dusk(false, 3.0)
	_dolly(_cam(Vector3(0, 2, 9)), _cam(Vector3(0, 2.4, 11)), camp + Vector3(0, 1, 0), camp + Vector3(0, 2, -4), 8.0)
	await _until(47.0)
	_narrate("Et au matin, elles brûlent.", 2.4, true)
	await _until(50.0)
	_say(heroes.cowgirl, "Jour 2. On reste ?", 1.8, -1.0)
	await _until(52.2)
	_say(heroes.soldier, "On reste. J'ai encore des arbres à couper.", 2.6, 1.0)
	await _until(55.0)
	_narrate("Le mode Survie, dans Overclock : récolte, fabrique, construis, tiens la nuit.", 3.6)
	await _until(58.8)
	_fade_shade(1.0, 0.6)
	await _until(59.6)
	_end_card()
