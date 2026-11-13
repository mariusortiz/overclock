extends Season3Episode
## Épisode 27 : La Lune qui boucle. On the moon, the same thirty seconds come
## back again and again: they land, a meteor falls, everything starts over.
## The Kunoichi notices, Le Créateur understands: change one detail. Vipère
## shoots the meteor out of the sky; the loop breaks, and three figures who
## had been stuck in it for years come to life.


func _init() -> void:
	episode_number = 27
	episode_title = "LA LUNE QUI BOUCLE"
	duration = 82.0


const IMPACT := Vector3(0, 0.1, 9)

var _heroes := {}
var _creator_model: CharacterModel


## The same landing, every time; `loop` is how many times it has come round.
func _landing(loop: int) -> void:
	_load_arena(1)
	_night_sky()
	_heroes = _squad(STAGE + Vector3(0, 0, 1), PI, SQUAD, 1.4, true)
	_creator_model = _creator(STAGE + Vector3(0, 0, -1.2), PI)
	_dolly(STAGE + Vector3(-4, 1.8, 7.5), STAGE + Vector3(-3, 1.8, 6.5), STAGE + Vector3(0, 1.3, 0.5), STAGE + Vector3(0, 1.3, 0), 5.0)
	_narrate("BOUCLE %d" % loop, 1.4, true)


## The meteor: a ball of fire from the sky onto IMPACT. Returns it, so that it
## can be shot down.
func _meteor(seconds: float) -> MeshInstance3D:
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.8
	sphere.height = 1.6
	var fire := StandardMaterial3D.new()
	fire.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fire.albedo_color = Color(1.0, 0.55, 0.2)
	sphere.material = fire
	ball.mesh = sphere
	_set.add_child(ball)
	ball.position = IMPACT + Vector3(-20, 40, -40)
	ball.create_tween().tween_property(ball, "position", IMPACT, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return ball


func _blast() -> void:
	Effects.burst(_set, IMPACT, Color(1.0, 0.55, 0.15), 120)
	Effects.flash(_set, IMPACT, Color(1.0, 0.6, 0.2), 20.0, 0.5)
	_impact_frame()
	_shake = 0.5
	_fade_shade(1.0, 0.3)


func _story() -> void:
	# 0 s: loop 1.
	_landing(1)
	_fade_shade(0.0, 1.0)
	await _until(1.8)
	_narrate("La lune. Grise, immobile, silencieuse.", 2.6)
	await _until(4.6)
	_say(_heroes.soldier, "On cherche une clé. Dispersez-vous.", 2.4, -1.0)
	await _until(7.2)
	_say(_heroes.cowgirl, "Facile.", 1.4, 1.0)
	var meteor := _meteor(2.2)
	await _until(9.4)
	_blast()
	await _until(10.2)
	_fade_shade(0.0, 0.1)
	await _title_card(4.6)

	# 14.8 s: loop 2.
	_rewind()
	_landing(2)
	await _until(16.6)
	_narrate("La lune. Grise, immobile, silencieuse.", 2.6)
	await _until(19.4)
	_say(_heroes.soldier, "On cherche une clé. Dispersez-vous.", 2.4, -1.0)
	await _until(22.0)
	_say(_heroes.cowgirl, "Facile.", 1.4, 1.0)
	await _until(23.2)
	_dolly(STAGE + Vector3(-1.0, 1.7, 3.6), STAGE + Vector3(-1.2, 1.7, 3.2), STAGE + Vector3(-2.8, 1.5, 1), STAGE + Vector3(-2.8, 1.5, 1), 3.0)
	_say(_heroes.kunoichi, "Attends... Tu as déjà dit « facile ».", 2.4, 1.0)
	meteor = _meteor(2.2)
	await _until(25.4)
	_blast()
	await _until(26.4)
	_fade_shade(0.0, 0.1)

	# 26.4 s: loop 3.
	_rewind()
	_landing(3)
	await _until(28.0)
	_dolly(STAGE + Vector3(0.8, 1.7, 0.4), STAGE + Vector3(0.7, 1.7, 0.2), STAGE + Vector3(0, 1.55, -1.2), STAGE + Vector3(0, 1.55, -1.2), 10.0)
	_say(_heroes.kunoichi, "Encore ! On revit la même scène !", 2.4, -1.0)
	await _until(30.8)
	_say(_creator_model, "Une boucle. Le temps est écrit en rond, ici.", 2.8, 1.0)
	await _until(34.0)
	_say(_creator_model, "Pour en sortir, il faut changer un détail.", 2.6, 1.0)
	await _until(37.0)
	_say(_heroes.cowgirl, "Je dis « difficile », cette fois ?", 2.2, -1.0)
	await _until(39.6)
	_say(_heroes.sand_ghost, "Non. Le détail, c'est ce qui tombe du ciel.", 2.6, 1.0)
	await _until(42.6)

	# 42.6 s: Vipère takes the shot.
	var vipere: CharacterModel = _heroes.sand_ghost
	vipere.get_parent().look_at(Vector3(-20, STAGE.y, -40 + IMPACT.z))
	meteor = _meteor(4.0)
	_dolly(vipere.global_position + Vector3(0.8, 1.8, 2.6), vipere.global_position + Vector3(0.6, 1.9, 2.2),
			vipere.global_position + Vector3(-6, 10, -12), vipere.global_position + Vector3(-6, 8, -10), 2.4)
	await _until(44.4)
	_narrate("Un seul tir.", 1.4)
	await _until(45.6)
	vipere.play(&"shoot", true)
	_beam(vipere.global_position + Vector3(0, 1.4, 0), meteor.global_position, RED, 0.08)
	Effects.burst(_set, meteor.global_position, Color(1.0, 0.55, 0.15), 120)
	Effects.flash(_set, meteor.global_position, Color(1.0, 0.6, 0.2), 20.0, 0.5)
	meteor.queue_free()
	_impact_frame()
	await _until(46.6)
	_dolly(STAGE + Vector3(0, 6, 14), STAGE + Vector3(0, 9, 12), STAGE + Vector3(0, 1, -2), STAGE + Vector3(-10, 20, -40), 5.0)
	_narrate("Le ciel se fissure... et la boucle se brise.", 3.0)
	_ring(STAGE, CYAN, 40.0, 1.6)
	await _until(50.0)
	_say(_heroes.soldier, "Le temps repart. Joli tir.", 2.0, -1.0)
	await _until(52.4)
	_say(vipere, "Je sais.", 1.4, 1.0)
	await _until(54.4)

	# 54.4 s: three statues that are not statues.
	var stuck := {}
	var ids := {"viking": Vector3(-3, 0, -6), "witch": Vector3(0, 0, -7), "cowboy": Vector3(3, 0, -6)}
	for id: String in ids:
		stuck[id] = _hero(id, STAGE + ids[id], PI, "none")
		_tint(stuck[id], Color(0.6, 0.6, 0.65))
	_dolly(STAGE + Vector3(1.0, 2.0, -2.0), STAGE + Vector3(0.8, 2.0, -2.8), STAGE + Vector3(0, 1.4, -6), STAGE + Vector3(0, 1.4, -6.4), 7.0)
	_narrate("Trois silhouettes de pierre grise, là depuis toujours.", 3.0)
	await _until(58.0)
	_say(_heroes.kunoichi, "Elles étaient là, avant ? À chaque boucle ?", 2.6, 1.0)
	await _until(61.0)
	# The color comes back to them.
	for id: String in stuck:
		var position: Vector3 = (stuck[id] as CharacterModel).get_parent().position
		(stuck[id] as CharacterModel).get_parent().queue_free()
		stuck[id] = _hero(id, position, PI, "none")
		Effects.burst(_set, position + Vector3.UP, CYAN, 30)
	_impact_frame()
	await _until(62.0)
	_dolly(vipere.global_position + Vector3(-1.4, 1.8, -2.2), vipere.global_position + Vector3(-1.1, 1.8, -1.8),
			vipere.global_position + Vector3.UP * 1.5, vipere.global_position + Vector3.UP * 1.5, 6.0)
	vipere.get_parent().look_at(Vector3(0, STAGE.y, STAGE.z - 6))
	_say(vipere, "... Brutus ? Hex ? Colt ?", 2.4, 1.0)
	await _until(65.0)
	_dolly(STAGE + Vector3(0, 1.6, -2.4), STAGE + Vector3(0, 1.6, -2.8), STAGE + Vector3(0, 1.5, -6.4), STAGE + Vector3(0, 1.5, -6.4), 5.0)
	_say(stuck.viking, "Vipère ?! Ça fait combien de boucles ?", 2.6, -1.0)
	await _until(68.0)
	_narrate("L'Escouade Écarlate. Aspirée ici bien avant eux.", 3.0, true)
	await _until(71.4)
	await _to_be_continued(71.8)
