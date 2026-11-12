extends AnimeDirector
## Épisode 5 : Le désert des secrets. Calamity, a cow-girl who knows the
## desert, leads the squad to a temple the Directeur used. A giant skeleton
## guards it; inside, a hologram of the Directeur and the plans of a second
## Titan.


func _init() -> void:
	episode_number = 5
	episode_title = "LE DÉSERT DES SECRETS"
	duration = 120.0


func _story() -> void:
	# 0 s: the desert, the squad walks under the sun.
	_load_arena(1)
	var squad: Array[CharacterModel] = []
	for index in 4:
		var id: String = ["soldier", "kunoichi", "captain", "ronin"][index]
		var hero := _hero(id, STAGE + Vector3(-3.0 + 2.0 * index, 0, -2), PI)
		hero.play(&"walk")
		_move(hero.get_parent() as Node3D, Vector3(0, 0, 0.7))
		squad.append(hero)
	var soldier := squad[0]
	var kunoichi := squad[1]
	var captain := squad[2]
	var ronin := squad[3]
	_dolly(STAGE + Vector3(0, 0.4, 7.5), STAGE + Vector3(0, 0.5, 7.0), STAGE + Vector3(0, 2.2, -2),
			STAGE + Vector3(0, 2.2, 0), 8.0, true)
	_fade_shade(0.0, 1.2)
	_narrate("Le désert. Trois jours de marche.", 3.0)
	await _until(3.4)
	_say(captain, "J'ai du sable partout.", 2.2, 1.0)
	await _until(6.0)
	_say(ronin, "Moi aussi.", 1.6, 1.0)
	await _until(8.2)

	await _title_card(5.0)

	# 13.2 s: a shot rings out; Calamity, on a wall.
	_movers.clear()
	for hero in squad:
		hero.play(&"aim")
		hero.get_parent().rotation.y = 0.0
	var calamity := _hero("cowgirl", STAGE + Vector3(3.5, 0, -6), PI * 0.8)
	_dolly(STAGE + Vector3(1.0, 0.6, 2.5), STAGE + Vector3(1.2, 0.7, 2.0), STAGE + Vector3(3.5, 1.5, -6),
			STAGE + Vector3(3.5, 1.6, -6), 4.0, true)
	calamity.play(&"shoot", true)
	_beam(calamity.global_position + Vector3.UP * 1.3, STAGE + Vector3(0, 6, 4), GOLD, 0.06)
	_shake = 0.1
	await _until(14.6)
	_say(calamity, "Vous êtes perdus, les citadins ?", 2.6, -1.0)
	await _until(17.6)
	_say(soldier, "On cherche un temple.", 2.0, 1.0)
	await _until(19.8)
	_say(calamity, "Celui des hommes en costume ? Je connais.", 2.8, -1.0)
	await _until(23.0)
	_dolly(STAGE + Vector3(5.5, 1.5, -3.0), STAGE + Vector3(5.2, 1.6, -3.3), STAGE + Vector3(3.5, 1.5, -6),
			STAGE + Vector3(3.5, 1.5, -6), 6.0, true)
	_narrate("CALAMITY · elle connaît le désert", 2.8)
	_say(calamity, "Ils ont pris mon ranch. Je viens avec vous.", 3.0, -1.0)
	await _until(26.6)
	_say(kunoichi, "Bienvenue dans l'escouade.", 2.2, -1.0)
	await _until(29.2)

	# 29.2 s: the temple's door, and its guardian.
	_wipe()
	calamity.get_parent().position = STAGE + Vector3(3.0, 0, 3)
	calamity.get_parent().rotation.y = 0.0
	for index in squad.size():
		squad[index].get_parent().position = STAGE + Vector3(-3.0 + 1.8 * index, 0, 3.5)
	var skeleton := _spawn_boss(Boss.Kind.BRUTE, STAGE + Vector3(0, 0, -6), 3.6, 2.2)
	_rise(skeleton, 8.0, 2.4)
	_dolly(STAGE + Vector3(-3.5, 0.5, 6.5), STAGE + Vector3(-2.5, 0.6, 5.5), STAGE + Vector3(0, 2, -6),
			STAGE + Vector3(0, 5, -6), 3.0, true)
	_shake = 0.25
	_speed(2.4)
	await _until(31.8)
	_stomp(STAGE + Vector3(0, 0, -6), 0.8)
	_impact_frame()
	await _until(32.6)
	_say(calamity, "Le gardien. Il ne dort jamais.", 2.4, 1.0)
	await _until(35.4)
	_say(captain, "Il a l'air content de nous voir.", 2.4, -1.0)
	await _until(38.2)

	# 38.2 s: the fight.
	skeleton.play(&"shoot", true)
	_dolly(STAGE + Vector3(4, 2.5, 6), STAGE + Vector3(3, 2.0, 5), STAGE + Vector3(0, 1, -2),
			STAGE + Vector3(0, 1, -2), 3.0, true)
	await _until(38.9)
	_stomp(STAGE + Vector3(0, 0, -2), 1.0)
	for hero in squad:
		hero.play(&"die", true)
	_impact_frame()
	await _until(41.0)
	_say(soldier, "Il frappe fort !", 1.8, -1.0)
	await _until(43.0)
	for hero in squad:
		hero.play(&"aim")
	# Calamity's dynamite.
	_dolly(STAGE + Vector3(5.0, 1.2, 5.0), STAGE + Vector3(4.6, 1.3, 4.6), STAGE + Vector3(3.0, 1.4, 3),
			STAGE + Vector3(3.0, 1.4, 3), 2.2, true)
	_say(calamity, "Bouchez-vous les oreilles !", 2.0, -1.0)
	await _until(45.2)
	calamity.play(&"shoot", true)
	_dolly(STAGE + Vector3(0, 4.0, 8), STAGE + Vector3(0, 4.5, 7), STAGE + Vector3(0, 2, -6),
			STAGE + Vector3(0, 2, -6), 3.0, true)
	_rocket(calamity.global_position + Vector3.UP * 1.4, skeleton.global_position + Vector3.UP * 2.0)
	await _until(46.0)
	_ring(STAGE + Vector3(0, 0, -6), Color(1.0, 0.6, 0.2), 16.0, 0.6)
	_impact_frame()
	_shake = 0.3
	_speed(1.5)
	await _until(47.6)
	# Then everybody.
	for index in squad.size():
		var hero := squad[index]
		hero.play(&"shoot", true)
		_beam(hero.global_position + Vector3.UP * 1.3, skeleton.global_position + Vector3(randf_range(-1, 1), randf_range(2, 6), 0),
				[CYAN, CYAN, GOLD, Color(1.0, 0.5, 0.8)][index], 0.09)
		await _until(_clock + 0.3)
	_say(ronin, "Maintenant.", 1.4, 1.0)
	ronin.play(&"melee", true)
	_impact_frame()
	_ring(STAGE + Vector3(0, 0, -6), Color(1.0, 0.85, 0.9), 12.0, 0.5)
	await _until(50.6)
	_fall(skeleton, 1.4)
	_dolly(STAGE + Vector3(-6, 1.2, 2), STAGE + Vector3(-5, 1.5, 1), STAGE + Vector3(0, 2, -6),
			STAGE + Vector3(0, 0.5, -6), 3.6, true)
	await _until(54.4)
	_say(calamity, "Yiii-haaa !", 1.8, -1.0)
	calamity.play(&"victory", true)
	await _until(56.6)

	# 56.6 s: inside the temple, a hologram lights up.
	_load_showroom()
	soldier = _hero("soldier", Vector3(-2.0, 0, 3), PI * 0.85)
	kunoichi = _hero("kunoichi", Vector3(-0.7, 0, 3.4), PI)
	calamity = _hero("cowgirl", Vector3(0.7, 0, 3.4), PI)
	captain = _hero("captain", Vector3(2.0, 0, 3), -PI * 0.85)
	for hero: CharacterModel in [soldier, kunoichi, calamity, captain]:
		hero.get_parent().rotation.y = 0.0
	var directeur := _npc("Suit_Male.fbx", Vector3(0, 0, -1.5), PI)
	directeur.get_parent().scale = Vector3.ONE * 1.6
	_tint(directeur, Color(0.3, 0.85, 1.0))
	_dolly(Vector3(0, 1.6, 8), Vector3(0, 1.8, 6.5), Vector3(0, 1.8, -1.5), Vector3(0, 2.0, -1.5), 6.0)
	Effects.flash(_set, Vector3(0, 2, -1.5), CYAN, 10.0, 0.8)
	_speed(1.0)
	await _until(58.0)
	_narrate("LE DIRECTEUR · en hologramme", 2.6)
	await _until(59.0)
	_say(directeur, "Si vous voyez ce message...", 2.4, 1.0, 3.0)
	await _until(61.8)
	_say(directeur, "...c'est que mon gardien est tombé.", 2.6, 1.0, 3.0)
	await _until(64.8)
	_dolly(Vector3(-1.5, 2.6, 0.5), Vector3(-1.2, 2.8, 0.2), Vector3(0, 2.6, -1.5), Vector3(0, 2.8, -1.5), 6.0)
	_say(directeur, "Le Titan n'était qu'un prototype.", 2.6, 1.0, 3.0)
	await _until(67.8)
	_say(directeur, "Le vrai arrive. Le TITAN MK II.", 2.8, 1.0, 3.0)
	_impact_frame()
	await _until(71.0)

	# 71 s: the plans: a red Titan, much bigger, on the hologram.
	directeur.get_parent().queue_free()
	var blueprint := _spawn_titan(Vector3(0, 0, -3), 4.5, Color(1.0, 0.35, 0.3))
	_tint(blueprint, Color(1.0, 0.3, 0.25))
	blueprint.get_parent().rotation.y = PI
	create_tween().set_loops(3).tween_property(blueprint.get_parent(), "rotation:y", PI + TAU, 3.0).from(PI)
	_dolly(Vector3(0, 1.4, 5), Vector3(0, 2.0, 4), Vector3(0, 2.2, -3), Vector3(0, 2.4, -3), 7.0)
	await _until(72.4)
	_say(captain, "Il est deux fois plus grand.", 2.4, 1.0)
	await _until(75.2)
	_say(kunoichi, "Où est-il construit ?", 2.2, -1.0)
	await _until(77.8)
	_dolly(Vector3(2.5, 1.5, 2), Vector3(2.2, 1.5, 1.6), Vector3(0.7, 1.4, 3.4), Vector3(0.7, 1.4, 3.4), 6.0)
	_say(calamity, "Les camions partaient vers la jungle.", 2.6, -1.0)
	await _until(80.8)
	_say(calamity, "Puis vers le volcan.", 2.0, -1.0)
	await _until(83.2)

	# 83.2 s: outside, the squad splits.
	_load_arena(1)
	soldier = _hero("soldier", STAGE + Vector3(-1.5, 0, 1), PI)
	kunoichi = _hero("kunoichi", STAGE + Vector3(-0.5, 0, 1.6), PI)
	ronin = _hero("ronin", STAGE + Vector3(0.6, 0, 1.4), PI)
	calamity = _hero("cowgirl", STAGE + Vector3(1.6, 0, 1), PI)
	_dolly(STAGE + Vector3(0, 1.3, 8), STAGE + Vector3(0, 1.4, 7), STAGE + Vector3(0, 1.3, 1.2),
			STAGE + Vector3(0, 1.3, 1.2), 8.0, true)
	await _until(84.0)
	_say(soldier, "Ronin, tu vas voir la jungle.", 2.4, -1.0)
	await _until(86.8)
	_say(ronin, "Seul. C'est plus discret.", 2.2, 1.0)
	await _until(89.4)
	_say(kunoichi, "Et si Vipère est là-bas ?", 2.2, -1.0)
	await _until(92.0)
	_say(ronin, "Alors on parlera.", 2.0, 1.0)
	await _until(94.4)
	_dolly(STAGE + Vector3(3, 1.0, 4), STAGE + Vector3(2.8, 1.1, 3.6), STAGE + Vector3(0.6, 1.4, 1.4),
			STAGE + Vector3(0.6, 1.4, 1.4), 6.0, true)
	ronin.get_parent().rotation.y = 0.0
	ronin.play(&"walk")
	_move(ronin.get_parent() as Node3D, Vector3(0, 0, -1.5))
	_say(calamity, "Il parle toujours aussi peu ?", 2.4, -1.0)
	await _until(97.2)
	_say(soldier, "Les bons jours.", 1.8, -1.0)
	await _until(99.6)
	_dolly(STAGE + Vector3(0, 3, 8), STAGE + Vector3(0, 9, 12), STAGE + Vector3(0, 1, -2),
			STAGE + Vector3(0, 2, -10), 8.0, true)
	_narrate("Dans la jungle, quelqu'un l'attend déjà.", 3.6)
	await _to_be_continued(106.0)
