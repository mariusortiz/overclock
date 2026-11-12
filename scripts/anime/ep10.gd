extends AnimeDirector
## Épisode 10 : Overclock. Every hero's ultimate, one after the other, until
## the shield breaks; the Soldier and Vipère strike together; the Titan Mk II
## falls. The Directeur is caught; the city dances. End of season 1.


func _init() -> void:
	episode_number = 10
	episode_title = "OVERCLOCK"
	duration = 124.0


var _shield: MeshInstance3D
var _shield_material := StandardMaterial3D.new()


func _story() -> void:
	# 0 s: the line of heroes before the red Titan, its shield up.
	_load_arena(4)
	var titan := _spawn_titan(STAGE + Vector3(0, 0, -8), 14.0, Color(1.0, 0.45, 0.4))
	_build_shield(titan)
	var ids := ["paladin", "cowboy", "viking", "soldier", "sand_ghost", "captain", "kunoichi", "ronin", "witch", "cowgirl", "godfather"]
	var heroes := {}
	for index in ids.size():
		var hero := _hero(ids[index], STAGE + Vector3(-7.0 + 1.4 * index, 0, 4.0 + absf(index - 5) * 0.35), 0.0)
		hero.play(&"aim")
		heroes[ids[index]] = hero
	_dolly(STAGE + Vector3(0, 0.5, 12), STAGE + Vector3(0, 0.8, 10), STAGE + Vector3(0, 2, 2),
			STAGE + Vector3(0, 9, -8), 8.0, true)
	_fade_shade(0.0, 1.0)
	_narrate("Précédemment : onze héros, un Titan, un bouclier.", 3.4)
	await _until(4.4)
	_say(heroes["soldier"], "Tout le monde, vos ultis. MAINTENANT !", 3.0, -1.0)
	await _until(8.4)

	await _title_card(5.0)

	# 13.4 s: the ultimates, one after another.
	# Soldier: air strike.
	_ulti_shot(heroes["soldier"], "FRAPPE AÉRIENNE")
	await _until(14.6)
	_wide_on_titan(2.6)
	_airstrike(titan.global_position + Vector3(0, 8, 0), 6, 4.0)
	await _until(16.0)
	_hit_shield(0.92)
	await _until(17.4)

	# Kunoichi: clones.
	_ulti_shot(heroes["kunoichi"], "CLONES")
	await _until(18.6)
	for side: float in [-1.5, 1.5, -3.0]:
		var clone := _hero("kunoichi", heroes["kunoichi"].global_position + Vector3(side, 0, -1.5), 0.0)
		_tint(clone, Color(0.4, 0.9, 1.0))
		_beam(clone.global_position + Vector3.UP * 1.3, titan.global_position + Vector3(0, 8, 0), CYAN, 0.1)
	_wide_on_titan(2.0)
	_hit_shield(0.84)
	await _until(20.8)

	# Captain: broadside.
	_ulti_shot(heroes["captain"], "BORDÉE")
	await _until(22.0)
	_wide_on_titan(2.4)
	for rocket in 10:
		var from: Vector3 = heroes["captain"].global_position + Vector3(0, 1.5, 0)
		get_tree().create_timer(0.1 * rocket).timeout.connect(_rocket.bind(from, titan.global_position + Vector3(randf_range(-4, 4), randf_range(5, 12), 4)))
	await _until(23.4)
	_hit_shield(0.74)
	await _until(24.6)

	# Ronin: whirlwind, on the Titan's feet.
	_ulti_shot(heroes["ronin"], "TOURBILLON")
	await _until(25.8)
	_dolly(STAGE + Vector3(4, 1, -2), STAGE + Vector3(3, 1.5, -3), STAGE + Vector3(0, 1, -8), STAGE + Vector3(0, 2, -8), 2.0, true)
	_ring(titan.global_position, Color(1.0, 0.85, 0.9), 16.0, 0.5)
	_impact_frame()
	_hit_shield(0.66)
	await _until(28.0)

	# Witch: curse.
	_ulti_shot(heroes["witch"], "MALÉDICTION")
	await _until(29.2)
	_wide_on_titan(2.0)
	Effects.burst(_set, titan.global_position + Vector3(0, 8, 0), Color(0.6, 0.2, 1.0), 120)
	_hit_shield(0.56)
	await _until(31.2)

	# Paladine: blessing, everyone glows.
	_ulti_shot(heroes["paladin"], "BÉNÉDICTION")
	await _until(32.4)
	_dolly(STAGE + Vector3(0, 3, 12), STAGE + Vector3(0, 3.2, 11), STAGE + Vector3(0, 1, 4), STAGE + Vector3(0, 1, 4), 2.2, true)
	for hero: CharacterModel in heroes.values():
		Effects.burst(_set, hero.global_position + Vector3.UP, GOLD, 12, true)
	_ring(STAGE + Vector3(0, 0, 4.5), GOLD, 18.0, 0.8)
	await _until(34.6)

	# Godfather: deadeye, a dozen shots at once.
	_ulti_shot(heroes["godfather"], "DUEL")
	await _until(35.8)
	_wide_on_titan(2.0)
	for shot in 12:
		_beam(heroes["godfather"].global_position + Vector3.UP * 1.3, titan.global_position + Vector3(randf_range(-4, 4), randf_range(3, 13), 3), GOLD, 0.05)
	_impact_frame()
	_hit_shield(0.44)
	await _until(38.0)

	# Viking and cow-girl: rage and dynamite.
	_ulti_shot(heroes["viking"], "RAGE")
	await _until(39.0)
	_ulti_shot(heroes["cowgirl"], "DYNAMITE")
	await _until(40.0)
	_wide_on_titan(2.2)
	_rocket(heroes["cowgirl"].global_position + Vector3.UP * 1.5, titan.global_position + Vector3(0, 2, 2))
	await _until(40.8)
	_ring(titan.global_position, Color(1.0, 0.6, 0.2), 22.0, 0.6)
	_shake = 0.3
	_hit_shield(0.3)
	await _until(42.4)

	# Cowboy: one shot, to the eye.
	_ulti_shot(heroes["cowboy"], "UN SEUL TIR")
	await _until(43.6)
	_dolly(heroes["cowboy"].global_position + Vector3(0.4, 1.6, 0.8), heroes["cowboy"].global_position + Vector3(0.4, 1.6, 0.6),
			titan.global_position + Vector3(0, 12, 0), titan.global_position + Vector3(0, 12, 0), 1.6, false)
	await _until(44.4)
	_beam(heroes["cowboy"].global_position + Vector3.UP * 1.3, titan.global_position + Vector3(0, 12, 2), Color(0.75, 0.45, 1.0), 0.08)
	_impact_frame()
	_hit_shield(0.18)
	await _until(46.0)

	# 46 s: the shield shatters.
	_wide_on_titan(4.0)
	_say(titan, "IMPOSSIBLE !", 2.0, 1.0, 14.0)
	await _until(47.0)
	_impact_frame()
	_speed(2.0)
	_shield.visible = false
	Effects.burst(_set, titan.global_position + Vector3(0, 7, 0), Color(1.0, 0.4, 0.4), 160)
	Effects.flash(_set, titan.global_position + Vector3(0, 7, 0), Color.WHITE, 30.0, 0.6)
	_shake = 0.4
	await _until(49.4)
	_say(heroes["kunoichi"], "Le bouclier est tombé !", 2.2, 1.0)
	await _until(52.0)

	# 52 s: the Titan strikes back. Everyone down but two.
	titan.play(&"shoot", true)
	_dolly(STAGE + Vector3(6, 3, 10), STAGE + Vector3(5, 2.5, 9), STAGE + Vector3(0, 1, 4), STAGE + Vector3(0, 1, 4), 3.0, true)
	await _until(52.8)
	_stomp(STAGE + Vector3(0, 0, 3), 2.0)
	_impact_frame()
	for id: String in heroes:
		if id != "soldier" and id != "sand_ghost":
			(heroes[id] as CharacterModel).play(&"die", true)
	await _until(54.0)
	for id: String in heroes:
		if id != "soldier" and id != "sand_ghost":
			(heroes[id] as CharacterModel).freeze(&"die", 1.0)
	await _until(55.6)

	# 55.6 s: the Soldier and Vipère, standing.
	var soldier: CharacterModel = heroes["soldier"]
	var vipere: CharacterModel = heroes["sand_ghost"]
	_dolly(STAGE + Vector3(-1.6, 1.5, 6.8), STAGE + Vector3(-1.4, 1.5, 6.4), STAGE + Vector3(-1.4, 1.4, 4.2),
			STAGE + Vector3(-1.4, 1.4, 4.2), 6.0, true)
	_say(vipere, "Il ne reste que nous.", 2.2, 1.0)
	await _until(58.4)
	_say(soldier, "Comme à la course. Côte à côte.", 2.6, -1.0)
	await _until(61.4)
	_say(vipere, "Cette fois, on finit ensemble.", 2.4, 1.0)
	await _until(64.2)
	_dolly(STAGE + Vector3(-1.4, 1.55, 1.8), STAGE + Vector3(-1.4, 1.55, 2.2), STAGE + Vector3(-1.4, 1.5, 4.2),
			STAGE + Vector3(-1.4, 1.6, 4.2), 3.0, false)
	_speed(3.0)
	_say(soldier, "OVERCLOCK !", 1.6, -1.0)
	_say(vipere, "OVERCLOCK !", 1.6, 1.0)
	await _until(67.2)

	# 67.2 s: the double strike.
	_dolly(STAGE + Vector3(0, 1.0, 10), STAGE + Vector3(0, 3.0, 8), STAGE + Vector3(0, 4, -8),
			STAGE + Vector3(0, 10, -8), 6.0, true)
	_speed(6.0)
	for beat in 16:
		var shooter: CharacterModel = soldier if beat % 2 == 0 else vipere
		shooter.play(&"shoot", true)
		_beam(shooter.global_position + Vector3.UP * 1.3, titan.global_position + Vector3(randf_range(-2, 2), randf_range(6, 12), 2),
				CYAN if shooter == soldier else RED, 0.16)
		Effects.burst(_set, titan.global_position + Vector3(0, 9, 2), CYAN if shooter == soldier else RED, 14)
		await _until(67.4 + 0.25 * beat)
	_impact_frame()
	Effects.flash(_set, titan.global_position + Vector3(0, 9, 0), Color.WHITE, 40.0, 1.0)
	_shake = 0.5
	await _until(72.4)
	_impact_frame()
	for blast in 8:
		var at := titan.global_position + Vector3(randf_range(-4, 4), randf_range(2, 13), randf_range(-2, 2))
		get_tree().create_timer(0.15 * blast).timeout.connect(Effects.burst.bind(_set, at, GOLD, 60))
	await _until(73.6)
	_fall(titan, 2.6)
	_dolly(STAGE + Vector3(-12, 2, 6), STAGE + Vector3(-10, 4, 3), STAGE + Vector3(0, 8, -8),
			STAGE + Vector3(0, 1, -8), 4.0, true)
	await _until(78.0)
	_narrate("Le Titan Mk II est tombé.", 3.0)
	await _until(81.4)

	# 81.4 s: the Directeur crawls out of the wreck. Brutus is waiting.
	for id: String in heroes:
		(heroes[id] as CharacterModel).play(&"idle")
	var directeur := _npc("Suit_Male.fbx", STAGE + Vector3(1.5, 0, -4), PI)
	directeur.play(&"walk")
	_move(directeur.get_parent() as Node3D, Vector3(-0.8, 0, 0.6))
	var brutus: CharacterModel = heroes["viking"]
	brutus.get_parent().position = STAGE + Vector3(-1.0, 0, -2.0)
	_face(brutus, directeur)
	_dolly(STAGE + Vector3(2, 1.4, 1), STAGE + Vector3(1.8, 1.4, 0.6), STAGE + Vector3(0, 1.3, -3),
			STAGE + Vector3(0, 1.3, -3), 6.0, true)
	await _until(82.4)
	_say(directeur, "Vous n'avez pas fini d'entendre parler de...", 2.6, 1.0)
	await _until(85.0)
	_movers.clear()
	directeur.play(&"idle")
	_say(brutus, "Où tu crois aller, patron ?", 2.4, -1.0)
	await _until(87.6)
	_say(directeur, "...Ah.", 1.6, 1.0)
	await _until(89.4)
	_say(heroes["godfather"], "Et mon argent, on en parle ?", 2.4, 1.0)
	await _until(92.0)

	# 92 s: the trophy; the whole city dances.
	_wipe()
	directeur.get_parent().queue_free()
	var trophy := Trophy.new()
	_set.add_child(trophy)
	trophy.position = STAGE + Vector3(0, 0, -1)
	_ring(trophy.position, GOLD, 12.0, 1.0)
	var index := 0
	for id: String in heroes:
		var hero: CharacterModel = heroes[id]
		var angle := PI + TAU * index / heroes.size() * 0.5 - PI * 0.25
		hero.get_parent().position = STAGE + Vector3(0, 0, -1) + Vector3(cos(angle) * 4.0, 0, -sin(angle) * 3.0 + 3.0)
		hero.get_parent().rotation.y = PI
		hero.play(&"victory", true)
		index += 1
	_dolly(STAGE + Vector3(0, 2, 11), STAGE + Vector3(0, 2.5, 9), STAGE + Vector3(0, 1.5, 0),
			STAGE + Vector3(0, 2, -1), 10.0, true)
	await _until(94.0)
	_say(heroes["captain"], "On a réussi !", 2.0, 1.0)
	await _until(96.4)
	_say(heroes["kunoichi"], "Tous ensemble.", 2.0, -1.0)
	await _until(98.8)
	_say(heroes["witch"], "Mes cartes l'avaient dit.", 2.2, 1.0)
	await _until(101.4)

	# 101.4 s: the Soldier and Vipère, at their ships, at sunset.
	_wipe()
	_load_arena(4)
	soldier = _hero("soldier", STAGE + Vector3(-1.0, 0, 1), PI * 0.8)
	vipere = _hero("sand_ghost", STAGE + Vector3(1.0, 0, 1), -PI * 0.8)
	_parked_ship(CYAN, STAGE + Vector3(-3.2, 0.8, -1.5), 0.3)
	_parked_ship(RED, STAGE + Vector3(3.2, 0.8, -1.5), -0.3)
	_dolly(STAGE + Vector3(0, 1.4, 7), STAGE + Vector3(0, 1.5, 6), STAGE + Vector3(0, 1.3, 1),
			STAGE + Vector3(0, 1.3, 1), 10.0, true)
	await _until(102.4)
	_say(vipere, "Alors, cette revanche ?", 2.2, 1.0)
	await _until(105.0)
	_say(soldier, "Quand tu veux.", 1.8, -1.0)
	await _until(107.2)
	_say(vipere, "Maintenant !", 1.6, 1.0)
	_speed(1.6)
	await _until(109.0)

	# 109 s: end of season 1.
	_shade.color = Color(0, 0, 0, 0)
	_fade_shade(0.85, 0.4)
	_narrate("FIN DE LA SAISON 1", 3.4, true)
	await _until(113.0)
	_fade_shade(1.0, 0.5)
	await _until(113.6)
	_end_card(true)


## A close shot of `hero` with the name of their ultimate, a flash and
## speed lines.
func _ulti_shot(hero: CharacterModel, ulti_name: String) -> void:
	var at := hero.global_position
	_dolly(at + Vector3(0.6, 1.6, -1.8), at + Vector3(0.4, 1.6, -1.5), at + Vector3(0, 1.4, 0), at + Vector3(0, 1.5, 0), 1.2, false)
	hero.play(&"shoot", true)
	Effects.flash(_set, at + Vector3.UP, GOLD, 8.0, 0.4)
	_speed(1.2)
	_narrate(ulti_name, 1.1)


func _wide_on_titan(seconds: float) -> void:
	_dolly(STAGE + Vector3(-6, 3, 10), STAGE + Vector3(-5, 4, 9), STAGE + Vector3(0, 8, -8), STAGE + Vector3(0, 9, -8), seconds, true)


func _build_shield(titan: CharacterModel) -> void:
	_shield_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_shield_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_shield_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_shield_material.albedo_color = Color(1.0, 0.3, 0.3, 0.28)
	var sphere := SphereMesh.new()
	sphere.radius = 9.5
	sphere.height = 19.0
	sphere.material = _shield_material
	_shield = MeshInstance3D.new()
	_shield.mesh = sphere
	_set.add_child(_shield)
	_shield.global_position = titan.global_position + Vector3.UP * 7.0


## The shield flickers under a hit and fades toward `strength` (1 full).
func _hit_shield(strength: float) -> void:
	_shield_material.albedo_color = Color(1.0, 1.0, 1.0, 0.6)
	create_tween().tween_property(_shield_material, "albedo_color", Color(1.0, 0.3, 0.3, 0.28 * strength), 0.5)
	_shake = maxf(_shake, 0.15)
